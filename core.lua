-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
local C_TimerAfter = C_Timer.After
local GetTime = GetTime
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


-- Frames
local timerFrame = CS.frame


-- Variables
local orbs = 0
local targets = {}  -- used to attribute timer IDs to mobs
local SATimeCorrection = {}  -- converging additional travel time due to hit box size
local timers = {}  -- ordered table of all timer IDs
local distanceCache = {}
local distanceCache_GUID
local timerID
local playerGUID
local aggressiveCachingInterval

local distanceTable = {}  -- from HaloPro (ultimately from LibRangeCheck it seems)
distanceTable[5] = 37727 -- Ruby Acorn 5 yards
distanceTable[8] = 34368 -- Attuned Crystal Cores 8 yards
distanceTable[10] = 32321 -- Sparrowhawk Net 10 yards
distanceTable[15] = 33069 -- Sturdy Rope 15 yards
distanceTable[20] = 10645 -- Gnomish Death Ray 20 yards
distanceTable[25] = 31463 -- Zezzak's Shard 25 yards
distanceTable[30] = 34191 -- Handful of Snowflakes 30 yards
distanceTable[35] = 18904 -- Zorbin's Ultra-Shrinker 35 yards
distanceTable[40] = 28767 -- The Decapitator 40 yards
distanceTable[45] = 23836 -- Goblin Rocket Launcher 45 yards
distanceTable[60] = 37887 -- Seeds of Nature's Wrath 60 yards
distanceTable[80] = 35278 -- Reinforced Net 80 yards

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

local SAVelocity = 6  -- estimated
local SAGraceTime = 3  -- maximum additional wait time before SA timer gets purged if it should not have hit in the meantime
local cacheMaxTime = 1  -- seconds in which the cache does not get refreshed


-- Functions
local function calculateTravelTime(unitID)
	local minDistance
	local maxDistance

	for i = 0, 80 do
		local distanceItem = distanceTable[i]
		if ItemHasRange(distanceItem) then
			if IsItemInRange(distanceItem, unitID) then
				maxDistance = i
				if maxDistance <= 5 then
					minDistance = 0
					maxDistance = 5
				end
			else
				minDistance = i
			end
		end
		if maxDistance and minDistance then break end
		
	end
	
	if (not maxDistance) or (not maxDistance) or (minDistance >= 60) then
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

local function cacheTravelTime(travelTime, GUID)
	-- target too far away
	if travelTime == -1 then
		distanceCache[GUID] = nil
		return nil
	end
	
	-- cache travel time
	if travelTime then
		distanceCache[GUID] = distanceCache[GUID] or {}
		distanceCache[GUID].travelTime = travelTime
		distanceCache[GUID].timeStamp = GetTime()
	end

	return travelTime
end

local function getTravelTimeByGUID(GUID)
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
			elseif IsInGroup() then
				travelTime = iterateUnitIDs(partyTable, GUID)
				if not travelTime then
					travelTime = iterateUnitIDs(partyPetTable, GUID)
				end
			end
		end
	end
	
	return cacheTravelTime(travelTime, GUID)
end

local function getTravelTime(GUID, forced)
	local travelTime
	distanceCache_GUID = distanceCache[GUID]
	
	if not distanceCache_GUID then
		travelTime = getTravelTimeByGUID(GUID)
	else
		local delta = GetTime() - distanceCache_GUID.timeStamp
		if forced or (delta > cacheMaxTime) then
			travelTime = getTravelTimeByGUID(GUID) or distanceCache_GUID.travelTime
		else
			travelTime = distanceCache_GUID.travelTime
		end
	end
	
	if not travelTime then
		return nil
	else
		SATimeCorrection[GUID] = SATimeCorrection[GUID] or 1  -- initially accounting for extra travel time due to hitbox size (estimated)
		return travelTime + SATimeCorrection[GUID] or 1
	end
end

local function aggressiveCachingByUnitID(unitID, timeStamp)
	if not UnitCanAttack("player", unitID) then return end
	
	local GUID = UnitGUID(unitID)
	
	if distanceCache[GUID] and timeStamp - distanceCache[GUID].timeStamp < aggressiveCachingInterval then return end
	cacheTravelTime(calculateTravelTime(unitID), GUID)
end

local function aggressiveCachingIteration(tbl, timeStamp)
	for i = 1, #tbl do
		aggressiveCachingByUnitID(tbl[i], timeStamp)
	end
end

function CS:aggressiveCaching()
	local timeStamp = GetTime()  -- sadly no milliseconds :/

	aggressiveCachingByUnitID("target", timeStamp)
	aggressiveCachingByUnitID("mouseover", timeStamp)
	aggressiveCachingByUnitID("focus", timeStamp)
	aggressiveCachingByUnitID("pettarget", timeStamp)
	if UnitExists("boss1") then
		aggressiveCachingIteration(bossTable, timeStamp)
	end
	if IsInRaid() then
		aggressiveCachingIteration(raidTable, timeStamp)
		aggressiveCachingIteration(raidPetTable, timeStamp)
	elseif IsInGroup() then
		aggressiveCachingIteration(partyTable, timeStamp)
		aggressiveCachingIteration(partyPetTable, timeStamp)
	end
	
	cacheTravelTime(travelTime)
end

local function addGUID(GUID)
	local cancelTime
	local travelTime = getTravelTime(GUID, true)
	if not travelTime then return end  -- target too far away, abort timer creation

	targets[GUID] = targets[GUID] or {}
	timerID = CS:ScheduleTimer("removeTimer_timed", travelTime + SAGraceTime, GUID)
	timerID.impactTime = GetTime() + travelTime  -- can't use timeStamp instead of GetTime() because of different time reference
	targets[GUID][#targets[GUID]+1] = timerID
	
	local timersCount = #timers
	if timersCount == 0 then
		timers[1] = timerID
		return
	end
	for i = 1, timersCount do
		if timerID.impactTime < timers[i].impactTime then
			tableinsert(timers, i, timerID)
			return
		end
	end
	timers[timersCount+1] = timerID
end

local function popTimer(timerID)
	for k, v in pairs(timers) do
		if v == timerID then
			tableremove(timers, k)
			break
		end
	end
end

local function removeTimer(timerID)
	popTimer(timerID)
	CS:CancelTimer(timerID)
end

local function warningSound()
end

function CS:update()
	self:refreshDisplay(orbs, timers)
	if self.db.sound then warningSound(orbs, timers) end
end
	
function CS:removeGUID(GUID)
	if not targets[GUID] then return end
	for _, timerID in pairs(targets[GUID]) do
		removeTimer(timerID)
	end
	targets[GUID] = nil
	distanceCache[GUID] = nil
	SATimeCorrection[GUID] = nil
	self:update()
end

function CS:removeAllGUIDs()  -- used by some encounter fixes
	for GUID, _ in pairs(targets[GUID]) do
		self:removeGUID(GUID)
	end
end

local function popGUID(GUID)
	if targets[GUID] then
		return tableremove(targets[GUID], 1)
	else
		return false
	end
end

function CS:removeTimer_timed(GUID)
	timerID = popGUID(GUID)
	popTimer(timerID)
	self:update()
end
        
local function resetCount()
	targets = {}
	SATimeCorrection = {}
	timers = {}
	distanceCache = {}
	CS:CancelAllTimers()
end

function CS:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	local timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID, _, _, _, _, _, _, _, _, _, _, _, _, multistrike = ...
        
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL" then
	
		self:removeGUID(destGUID)
		
		
	elseif sourceGUID == playerGUID then
	
		-- Shadowy Apparition cast
		if spellID == 147193 and destName ~= nil then  -- SAs without a target won't generate orbs
			addGUID(destGUID)
			self:update()
		
		-- catch all Auspicious Spirits and Shadowy Apparition hit events
		elseif spellID == 155271 or spellID == 148859 and not multistrike then
			timerID = popGUID(destGUID)
			local currentTime = GetTime()
			if timerID then
				local additionalTime = timerID.impactTime - currentTime
				SATimeCorrection[destGUID] = SATimeCorrection[destGUID] - additionalTime / 2
				removeTimer(timerID)
				-- correct other timers
				if targets[GUID] and additionalTime > 0.2 then
					for _, timerID in pairs(targets[GUID]) do
						timerID.impactTime = timerID.impactTime - additionalTime
					end
				end
				-- to avoid jittery counter
				if (spellID == 155271 and (event == "SPELL_CAST_SUCCESS" or event == "SPELL_ENERGIZE") or spellID == 148859 and event == "SPELL_DAMAGE") and orbs < 5 then
					-- the assumption is that any of these events fire before the respective UNIT_POWER
					orbs = orbs + 1
				end
			end
			if distanceCache[GUID] and currentTime > distanceCache[GUID].timeStamp + cacheMaxTime then  -- update cached distances if over cacheMaxTime
				distanceCache[GUID] = distanceCache[GUID] or {}
				distanceCache[GUID].travelTime = timerID.impactTime - GetTime() - SATimeCorrection[destGUID]
				distanceCache[GUID].timeStamp = currentTime
			end
			self:update()
			
		-- Shadowy Word: Pain tick
		elseif spellID == 589 and not multistrike and (event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_DAMAGE") then
			getTravelTime(destGUID)  -- adds GUID to distance table
			
		end
		
	else
		self:encounterFix(event, sourceGUID, destGUID, spellID)
		
	end
end

function CS:PLAYER_DEAD()
	resetCount()
	orbs = UnitPower("player", 13)
	self:update()
end

function CS:PLAYER_REGEN_DISABLED()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	orbs = UnitPower("player", 13)
	
	if self.UpdateInterval then
		self:ScheduleRepeatingTimer("update", self.UpdateInterval)
		if UnitAffectingCombat("player") then
			function warningSound(orbs, timers) self:warningSound(orbs, timers) end
		end
	end
	
	if self.db.aggressiveCaching then
		self:ScheduleRepeatingTimer("aggressiveCaching", aggressiveCachingInterval)
	end
		
	if not timerFrame.lock then
		timerFrame:Lock()
	end
end

function CS:PLAYER_REGEN_ENABLED()
	if not timerFrame.lock or not self.db.calculateOutOfCombat then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		resetCount()
	end
	warningSound = function(orbs, timers) end
	self:update()
end

local function delayOrbs()
	orbs = UnitPower("player", 13)
	CS:update()
end

function CS:UNIT_POWER(_, unitID, power)
	if not (unitID == "player" and power == "SHADOW_ORBS") then return end
	C_TimerAfter(0.01, delayOrbs)  -- needs to be delayed so it fires after the SA events, otherwise everything will assume the SA is still in flight
end

function CS:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
	orbs = UnitPower("player", 13)
	resetCount()
	self:update()
end

-- make a better implementation later
--function CS:PLAYER_STARTED_MOVING()  -- maybe also add PLAYER_STOPPED_MOVING?
--	SATimeCorrection = {}  -- maybe recycle table?
--end

local function isASSpecced()
	local specialization = GetSpecialization()
	local _, _, _, ASSpecced = GetTalentInfo(7, 3, GetActiveSpecGroup())
	return specialization and specialization == 3 and ASSpecced
end

function CS:talentsCheck()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	warningSound = function() end
	
	if isASSpecced() then
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		--self:RegisterEvent("PLAYER_STARTED_MOVING")  -- make a better implementation later
		self:Initialize()
	else
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		--self:UnregisterEvent("PLAYER_STARTED_MOVING")  -- make a better implementation later
		resetCount()
	end
	self:update()
end

function CS:getDB()
	local CSDB = LibStub("AceDB-3.0"):New("ConspicuousSpiritsDB", self.defaultSettings, true)
	self.db = CSDB.global
	function self:ResetDB() CSDB:ResetDB() end
end

function CS:Initialize()
	--self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	timerFrame:HideChildren()
	
	self:applySettings()
	
	if UnitAffectingCombat("player") then
		if isASSpecced() then self:PLAYER_REGEN_DISABLED() end
	elseif timerFrame.lock then
		self:PLAYER_REGEN_ENABLED()
	else
		timerFrame:ShowChildren()
	end
	
	aggressiveCachingInterval = self.db.aggressiveCachingInterval
	
	-- TODO: Add encounter fixes when logging in and already in-combat
end

function CS:OnInitialize()
	self:getDB()
	self:Initialize()
	
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_POWER")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "talentsCheck")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	--self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
	self:RegisterEvent("PLAYER_DEAD")
end