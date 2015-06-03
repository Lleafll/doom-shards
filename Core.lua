----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


--------------
-- Upvalues --
--------------
local C_TimerAfter = C_Timer.After
local GetTime = GetTime
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsItemInRange = IsItemInRange
local ItemHasRange = ItemHasRange
local pairs = pairs
local tableinsert = table.insert  -- only used sparingly
local tableremove = table.remove
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitPower = UnitPower


---------------
-- Variables --
---------------
local SAVelocity = 6.07  -- extrapolated
local initialSATimeCorrection = 1  -- seconds to add to initial travel time prediction
local SAGraceTime = 3  -- maximum additional wait time before SA timer gets purged if it should not have hit in the meantime
local cacheMaxTime = 1  -- seconds in which the cache does not get refreshed

local orbs = 0
local targets = {}  -- used to attribute timer IDs to mobs
local SATimeCorrection = {}  -- converging additional travel time due to hit box size
local timers = {}  -- ordered table of all timer IDs
local distanceCache = {}
local playerGUID
local aggressiveCachingInterval

-- from HaloPro (ultimately from LibRangeCheck it seems), with several own additions
local distanceTable = {}
distanceTable[3] = 42732 -- Everfrost Razor 3 yards
distanceTable[5] = 63427 -- Worgsaw 5 yards, possible alternative: Darkmender's Tincture
distanceTable[8] = 34368 -- Attuned Crystal Cores 8 yards
distanceTable[10] = 32321 -- Sparrowhawk Net 10 yards
distanceTable[15] = 33069 -- Sturdy Rope 15 yards
distanceTable[20] = 10645 -- Gnomish Death Ray 20 yards
distanceTable[25] = 31463 -- Zezzak's Shard 25 yards
distanceTable[30] = 34191 -- Handful of Snowflakes 30 yards
distanceTable[35] = 18904 -- Zorbin's Ultra-Shrinker 35 yards
distanceTable[40] = 28767 -- The Decapitator 40 yards
distanceTable[45] = 23836 -- Goblin Rocket Launcher 45 yards
distanceTable[50] = 116139 -- Haunting Memento 50 yards, possible alternative with 6.2: Drained Blood Crystal
-- 55 yards
distanceTable[60] = 37887 -- Seeds of Nature's Wrath 60 yards
-- 65 yards
distanceTable[70] = 41265 -- Eyesore Blaster 70 yards
-- 75 yards
distanceTable[80] = 35278 -- Reinforced Net 80 yards
-- 85 yards
-- 90 yards
-- 95 yards
distanceTable[100] = 33119 -- Malister's Frost Wand 100 yards

local function buildUnitIDTable(str1, maxNum, str2)
	local tbl = {}
	for i = 1, maxNum do
		tbl[i] = str1..tostring(i)..(str2 or "")
	end
	return tbl
end
local bossTable = buildUnitIDTable("boss", 5)
local raidTable = buildUnitIDTable("raid", 40, "target")
local raidPetTable = buildUnitIDTable("raid", 40, "pettarget")
local partyTable = buildUnitIDTable("party", 5, "target")
local partyPetTable = buildUnitIDTable("party", 5, "pettarget")
local arenaTable = buildUnitIDTable("arena", 5)
local arenaPetTable = buildUnitIDTable("arena", 5, "pet")


---------------
-- Functions --
---------------

-- forces an update of displays
function CS:Update()
	self:SendMessage("CONSPICUOUS_SPIRITS_UPDATE", orbs, timers)
end

-- resets all data
function CS:ResetCount()
	targets = {}
	SATimeCorrection = {}
	timers = {}
	distanceCache = {}
	self:CancelAllTimers()
	self:Update()
end

-- set specific SATimeCorrection for a GUID
function CS:SetSATimeCorrection(GUID, seconds)
	SATimeCorrection[GUID] = seconds
end

do
	local function calculateTravelTime(unitID)
		local minDistance
		local maxDistance

		for i = 0, 100 do
			local distanceItem = distanceTable[i]
			if ItemHasRange(distanceItem) then
				if IsItemInRange(distanceItem, unitID) then
					maxDistance = i
					if maxDistance <= 3 then
						minDistance = 0
					end
				else
					minDistance = i
				end
			end
			if maxDistance and minDistance then break end
		end
		
		if not maxDistance or not minDistance then  -- distance > 100 yd, first range check, or something went wrong
			return -1
		else
			return (minDistance + maxDistance) / 2 / SAVelocity
		end			
	end

	local function iterateUnitIDs(tbl, GUID)
		for i = 1, #tbl do
			local unitID = tbl[i]
			if UnitGUID(unitID) == GUID then
				return calculateTravelTime(unitID)
			end
		end
	end
	
	local function cacheTravelTime(self, travelTime, GUID)
		-- target too far away
		if travelTime == -1 then
			if distanceCache[GUID] then
				distanceCache[GUID] = nil
				self:Update()
			end
			return nil
		end
		
		-- cache travel time
		if travelTime then
			if distanceCache[GUID] then
				distanceCache[GUID].travelTime = travelTime
				distanceCache[GUID].timeStamp = GetTime()
			else
				-- making the distinction so displays get immediately updated when target moves into range
				distanceCache[GUID] = {}
				distanceCache[GUID].travelTime = travelTime
				distanceCache[GUID].timeStamp = GetTime()
				self:Update()
			end
		end

		return travelTime
	end

	local function getTravelTimeByGUID(self, GUID)
		local travelTime
		
		if UnitGUID("target") == GUID then
			travelTime = calculateTravelTime("target")
			
		elseif UnitGUID("mouseover") == GUID then
			travelTime = calculateTravelTime("mouseover")
			
		elseif UnitGUID("focus") == GUID then
			travelTime = calculateTravelTime("focus")
			
		elseif UnitGUID("pettarget") == GUID then
			travelTime = calculateTravelTime("pettarget")
			
		else
			if UnitExists("boss1") then
				travelTime = iterateUnitIDs(bossTable, GUID)
			end
			
			if not travelTime then
				if IsInRaid() then
					travelTime = iterateUnitIDs(raidTable, GUID)
					if not travelTime then
						travelTime = iterateUnitIDs(raidPetTable, GUID)
					end
				else
					if IsInGroup() then
						travelTime = iterateUnitIDs(partyTable, GUID)
						if not travelTime then
							travelTime = iterateUnitIDs(partyPetTable, GUID)
						end
					end
					if not travelTime and IsActiveBattlefieldArena() then
						travelTime = iterateUnitIDs(arenaTable, GUID)
						if not travelTime then
							travelTime = iterateUnitIDs(arenaPetTable, GUID)
						end
					end
				end
			end
		end
		
		return cacheTravelTime(self, travelTime, GUID)
	end

	local function getTravelTime(self, GUID, forced)
		local travelTime
		local isCached
		local distanceCache_GUID = distanceCache[GUID]
		
		if not distanceCache_GUID then
			travelTime = getTravelTimeByGUID(self, GUID)
		else
			local delta = GetTime() - distanceCache_GUID.timeStamp
			if forced or (delta > cacheMaxTime) then
				travelTime = getTravelTimeByGUID(self, GUID)
				if not travelTime then
					travelTime = distanceCache_GUID.travelTime
					isCached = true
				end
			else
				travelTime = distanceCache_GUID.travelTime
				isCached = true
			end
		end
		
		if not travelTime then
			return nil
		else
			SATimeCorrection[GUID] = SATimeCorrection[GUID] or initialSATimeCorrection  -- initially accounting for extra travel time due to hitbox size (estimated)
			return travelTime + SATimeCorrection[GUID], isCached
		end
	end

	do
		local function aggressiveCachingByUnitID(self, unitID, timeStamp)
			if not UnitCanAttack("player", unitID) then return end
			
			local GUID = UnitGUID(unitID)
			
			if distanceCache[GUID] and timeStamp - distanceCache[GUID].timeStamp < aggressiveCachingInterval then return end
			cacheTravelTime(self, calculateTravelTime(unitID), GUID)
		end
		
		local function aggressiveCachingIteration(self, tbl, timeStamp)
			for i = 1, #tbl do
				aggressiveCachingByUnitID(self, tbl[i], timeStamp)
			end
		end
		
		function CS:AggressiveCaching()
			local timeStamp = GetTime()
			
			aggressiveCachingByUnitID(self, "target", timeStamp)
			aggressiveCachingByUnitID(self, "mouseover", timeStamp)
			aggressiveCachingByUnitID(self, "focus", timeStamp)
			aggressiveCachingByUnitID(self, "pettarget", timeStamp)
			if UnitExists("boss1") then
				aggressiveCachingIteration(self, bossTable, timeStamp)
			end
			if IsInRaid() then
				aggressiveCachingIteration(self, raidTable, timeStamp)
				aggressiveCachingIteration(self, raidPetTable, timeStamp)
			elseif IsInGroup() then
				aggressiveCachingIteration(self, partyTable, timeStamp)
				aggressiveCachingIteration(self, partyPetTable, timeStamp)
			end
		end
		
		function CS:UNIT_TARGET(_, unitID)
			aggressiveCachingByUnitID(self, unitID.."target", GetTime())
		end
		
		function CS:UPDATE_MOUSEOVER_UNIT()
			aggressiveCachingByUnitID(self, "mouseover", GetTime())
		end
	end
	
	local function popGUID(GUID)
		if targets[GUID] then
			return tableremove(targets[GUID], 1)
		else
			return false
		end
	end
	
	local function popTimer(timerID)
		for k, v in pairs(timers) do
			if v == timerID then
				tableremove(timers, k)
				break
			end
		end
	end
	
	local function removeTimer(self, timerID)
		popTimer(timerID)
		self:CancelTimer(timerID)
	end
	
	function CS:RemoveTimer_timed(GUID)
		local timerID = popGUID(GUID)
		popTimer(timerID)  -- check this for false? (actually never throws an error)
		self:Update()
	end
	
	do
		local function insertTimerID(tbl, timerID)
			local tblCount = #tbl
			if tblCount == 0 then
				tbl[1] = timerID
				return
			end
			for i = 1, tblCount do
				if timerID.impactTime < tbl[i].impactTime then
					tableinsert(tbl, i, timerID)
					return
				end
			end
			tbl[tblCount+1] = timerID
		end
	
		function CS:addGUID(GUID)
			local travelTime, isCached = getTravelTime(self, GUID, true)
			if not travelTime then return end  -- target too far away, abort timer creation
			targets[GUID] = targets[GUID] or {}
			
			local timerID = self:ScheduleTimer("RemoveTimer_timed", travelTime + SAGraceTime, GUID)
			timerID.isCached = isCached
			timerID.impactTime = GetTime() + travelTime  -- can't use timeStamp instead of GetTime() because of different time reference
			timerID.IsGUIDInRange = function()
				return distanceCache[GUID]
			end
			
			insertTimerID(targets[GUID], timerID)
			insertTimerID(timers, timerID)
		end
	end
	
	do
		local function removeGUID(self, GUID)
			if not targets[GUID] then return end
			for _, timerID in pairs(targets[GUID]) do
				removeTimer(self, timerID)
			end
			targets[GUID] = nil
			distanceCache[GUID] = nil
			SATimeCorrection[GUID] = nil
		end
		
		-- resets SAs, etc. for specified GUID
		-- originally designed for encounter fixes
		function CS:RemoveGUID(GUID)
			removeGUID(self, GUID)
			self:Update()
		end
		
		-- resets all tracked SAs, etc.
		-- originally designed for encounter fixes
		function CS:RemoveAllGUIDs()
			for GUID, _ in pairs(targets) do
				removeGUID(self, GUID)
			end
			self:Update()
		end
	end
	
	do
		local function hideGUID(GUID)
			distanceCache[GUID] = nil
		end
		
		-- hides SAs, etc. for specified GUID
		-- originally designed for encounter fixes
		function CS:HideGUID(GUID)
			hideGUID(GUID)
			self:Update()
		end
		
		-- hides SAs for specified GUID 
		-- originally designed for encounter fixes
		function CS:HideAllGUIDs()
			for GUID, _ in pairs(targets) do
				hideGUID(GUID)
			end
			self:Update()
		end
	end
	
	function CS:COMBAT_LOG_EVENT_UNFILTERED(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID, _, _, _, _, _, _, _, _, _, _, _, _, multistrike)
		
		if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL" then
		
			self:RemoveGUID(destGUID)
			
			
		elseif sourceGUID == playerGUID then
		
			-- Shadowy Apparition cast
			if spellID == 147193 and destName ~= nil then  -- SAs without a target won't generate orbs
				self:addGUID(destGUID)
				self:Update()
			
			-- catch all Shadowy Apparition hit events
			elseif spellID == 148859 and not multistrike then
				local timerID = popGUID(destGUID)
				if timerID then
					local currentTime = GetTime()
					local additionalTime = timerID.impactTime - currentTime
					SATimeCorrection[destGUID] = SATimeCorrection[destGUID] - additionalTime / 2
					if SATimeCorrection[destGUID] < 0 then SATimeCorrection[destGUID] = 0 end
					
					--@debug@
					--print(SATimeCorrection[destGUID])
					--@end-debug@
					
					removeTimer(self, timerID)
					-- correct other timers
					if targets[destGUID] and additionalTime > 0.1 then
						for _, timerID in pairs(targets[destGUID]) do
							timerID.impactTime = timerID.impactTime - additionalTime
						end
					end
					-- to avoid jittery counter
					if event == "SPELL_DAMAGE" and orbs < 5 then
						-- the assumption is that any of these events fire before/at the moment of the respective UNIT_POWER
						orbs = orbs + 1
						self:UNIT_POWER("UNIT_POWER", "player", "SHADOW_ORBS")  -- fail safe in case the corresponding UNIT_POWER fires wonkily
					end
					-- update cached distances if over cacheMaxTime (fallback for regular scanning)
					if distanceCache[destGUID] and currentTime > distanceCache[destGUID].timeStamp + cacheMaxTime then
						distanceCache[destGUID].travelTime = distanceCache[destGUID].travelTime - timerID.impactTime + currentTime
						distanceCache[destGUID].timeStamp = currentTime
					end
				end
				self:Update()
				
			-- Shadowy Word: Pain tick
			elseif spellID == 589 and not multistrike and (event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_DAMAGE") then
				getTravelTime(self, destGUID)  -- adds GUID to distance table
				
			end
		end
	end
end

do
	local aggressiveCachingTimer
	local updateTimer
	
	function CS:PLAYER_REGEN_DISABLED()
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		orbs = UnitPower("player", 13)
		
		if self.db.aggressiveCaching then
			if not aggressiveCachingTimer or self:TimeLeft(aggressiveCachingTimer) == 0 then
				aggressiveCachingTimer = self:ScheduleRepeatingTimer("AggressiveCaching", aggressiveCachingInterval)
			end
			self:RegisterEvent("UNIT_TARGET")
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
		end
		
		if not self.locked then
			self:Lock()
		end
	end
end

function CS:PLAYER_REGEN_ENABLED()  -- player left combat or died
	orbs = UnitPower("player", 13)
	
	if not self.db.calculateOutOfCombat then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:ResetCount()
	elseif UnitIsDead("player") then
		self:ResetCount()
	else
		self:Update()
	end
	
	self:UnregisterEvent("UNIT_TARGET")
	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
end

do
	local delay = 0.01
	
	local function delayOrbs()
		orbs = UnitPower("player", 13)
		CS:Update()
	end
	
	function CS:UNIT_POWER(_, unitID, power)
		if not (unitID == "player" and power == "SHADOW_ORBS") then return end
		C_TimerAfter(delay, delayOrbs)  -- needs to be delayed so it fires after the SA events, otherwise everything will assume the SA is still in flight
	end
end

function CS:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
	orbs = UnitPower("player", 13)
	self:ResetCount()
end

do
	local function isShadow()
		return GetSpecialization() == 3
	end

	local function isASSpecced()
		local _, _, _, ASSpecced = GetTalentInfo(7, 3, GetActiveSpecGroup())
		return ASSpecced
	end

	function CS:TalentsCheck()
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")  -- does this lead to issues when changing talents when SAs are in flight with out-of-combat-calculation?
		warningSound = function() end
		
		if isShadow() then
			orbs = UnitPower("player", 13)
			self:Build()
			self:RegisterEvent("UNIT_POWER")
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			
			local EF = self:GetModule("EncounterFixes")
			
			if isASSpecced() then
				self:RegisterEvent("PLAYER_REGEN_DISABLED")
				self:RegisterEvent("PLAYER_REGEN_ENABLED")
				if not EF:IsEnabled() then EF:Enable() end
				self:Update()
			
			else
				self:UnregisterEvent("PLAYER_REGEN_DISABLED")
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
				self:ResetCount()
				if EF:IsEnabled() then EF:Disable() end
			
			end
		else
			self:UnregisterEvent("UNIT_POWER")
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			
		end
	end

	function CS:Build()
		self:ApplySettings()
		
		aggressiveCachingInterval = self.db.aggressiveCachingInterval
		
		if UnitAffectingCombat("player") then
			if isShadow() and isASSpecced() 
				then self:PLAYER_REGEN_DISABLED() 
			end
		
		elseif self.locked then
			self:PLAYER_REGEN_ENABLED()

		end
	end
end