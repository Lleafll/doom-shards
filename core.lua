-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
local C_TimerAfter = C_Timer.After
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecialization = GetSpecialization
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsItemInRange = IsItemInRange
local ItemHasRange = ItemHasRange
local pairs = pairs
local tableinsert = table.insert
local tableremove = table.remove
local tostring = tostring
local UnitAffectingCombat = UnitAffectingCombat
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitPower = UnitPower


-- Frames
local timerFrame = CS.frame


-- Variables
local orbs = UnitPower("player", 13)
local targets = {}  -- used to attribute timer IDs to mobs
local additionalSATime = {}  -- converging additional travel time due to hit box size for all GUIDs
local timers = {}  -- ordered table of all timer IDs
local distanceCache = {}
local distanceCache_GUID
local timerID
local playerGUID = UnitGUID("player")

local distanceTable = {}
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
local maxToleratedTime = 10  -- maximum time before Shadowy Apparition gets purged if it should not have hit in the meantime
local cacheMaxTime = 1  -- seconds in which the cache does not get refreshed


-- Functions
local function getNPCID(GUID)
	return GUID:sub(-16, -12)
end

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
		if maxDistance and minDistance then break end  -- check maxDistance first since minDistance will almost always be != nil
	end
	
	return ((minDistance or 40) + (maxDistance or 40)) / 2 / SAVelocity
end

local function iterateUnitIDs(tbl, GUID)
	for i = 1, #tbl do
		local unitID = tbl[i]
		if UnitGUID(unitID) == GUID then
			return calculateTravelTime(unitID)
		end
	end
end

local function getTravelTimeByGUID(timeStamp, GUID)
	local travelTime = nil

	if UnitGUID("target") == GUID then
		travelTime = calculateTravelTime("target")
		
	elseif UnitGUID("mouseover") == GUID then
		travelTime = calculateTravelTime("mouseover")
		
	elseif UnitGUID("pettarget") == GUID then
		travelTime = calculateTravelTime("pettarget")
		
	elseif UnitExists("boss1") then
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
	
	if travelTime then
		distanceCache[GUID] = {}
		distanceCache[GUID].travelTime = travelTime
		distanceCache[GUID].timeStamp = timeStamp
	end

	return travelTime
end

local function getTravelTime(timeStamp, GUID, forced)
	distanceCache_GUID = distanceCache[GUID]

	if not distanceCache_GUID then
		travelTime = getTravelTimeByGUID(timeStamp, GUID) or (40 / SAVelocity)
	else
		local delta = timeStamp - distanceCache_GUID.timeStamp
		if forced or (delta > cacheMaxTime) then
			travelTime = getTravelTimeByGUID(timeStamp, GUID) or distanceCache_GUID.travelTime
		else
			travelTime = distanceCache_GUID.travelTime
		end
	end
	
	return travelTime + (additionalSATime[getNPCID(GUID)] or 1)
end

local function addGUID(timeStamp, GUID)
	targets[GUID] = targets[GUID] or {}
	local NPCID = getNPCID(GUID)
	additionalSATime[NPCID] = additionalSATime[NPCID] or 1  -- initially accounting for extra 0.8 sec travel time due to hitbox size (estimated)
	timerID = CS:ScheduleTimer("removeTimer_timed", maxToleratedTime, GUID)
	timerID.impactTime = GetTime() + getTravelTime(timeStamp, GUID, true)  -- can't use timeStamp instead of GetTime() because of different time reference
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
	self:update()
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
	additionalSATime = {}
	timers = {}
	distanceCache = {}
	CS:CancelAllTimers()
end



function CS:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	local timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID, _, _, _, _, _, _, _, _, _, _, _, _, multistrike = ...
        
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "SPELL_INSTAKILL" then
		if destGUID == playerGUID then
			orbs = UnitPower("player", 13)
			resetCount()
			self:update()
			
		else
			self:removeGUID(destGUID)
			
		end
		
		
	elseif sourceGUID == playerGUID then
	
		-- Shadowy Apparition cast
		if spellID == 147193 and destName ~= nil then  -- SAs without a targeet won't generate orbs
			if UnitAffectingCombat("player") then
				addGUID(timeStamp, destGUID)
				self:update()
			end
		
		-- catch all Shadowy Apparition hit events
		elseif spellID == 148859 and not multistrike then
			timerID = popGUID(destGUID)
			if timerID then
				local additionalTime = timerID.impactTime - GetTime()
				local NPCID = getNPCID(destGUID)
				additionalSATime[NPCID] = additionalSATime[NPCID] - additionalTime / 2
				
				-- debug
				--print(additionalTime, additionalSATime[NPCID])
				
				removeTimer(timerID)
			end
			self:update()
			
		-- Shadowy Word: Pain tick
		elseif spellID == 589 and not multistrike and (event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_DAMAGE") then
			if UnitAffectingCombat("player") then
				getTravelTime(timeStamp, destGUID)  -- adds GUID to distance table
			end
			
		end
		
	else
		self:encounterFix(event, sourceGUID, destGUID, spellID)
		
	end
end

function CS:PLAYER_REGEN_DISABLED()
	orbs = UnitPower("player", 13)
	if not (self.db.display == "WeakAuras") then
		if self.db.display == "Complex" then timerFrame:Show() end
		self:ScheduleRepeatingTimer("update", 0.1)
		function warningSound(orbs, timers) CS:warningSound(orbs, timers) end
	end
	timerFrame:Lock()
end

function CS:PLAYER_REGEN_ENABLED()
	resetCount()
	self:update()
	if not (CS.db.display == "Complex") or not CS.db.outofcombat then
		timerFrame:Hide()
	else
		timerFrame:Show()
	end
	function warningSound() end
end

function CS:UNIT_POWER(_, unitID, power)
	if not (unitID == "player" and power == "SHADOW_ORBS") then return end
	C_TimerAfter(0.01, function() -- needs to be delayed so it fires after the SA events, otherwise everything will assume the SA is still in flight
		if UnitAffectingCombat("player") or (CS.db.display == "Complex" and CS.db.outofcombat) then
			orbs = UnitPower("player", 13)
			CS:update()
		end
	end)
end

function CS:setOrbs()
	orbs = UnitPower("player", 13)
	self:update()
end

local function registerAllEvents()
	CS:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function unregisterAllEvents()
	CS:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function CS:talentsChanged()
	local specialization = GetSpecialization()
	local _, _, _, ASSpecced = GetTalentInfo(7, 3, GetActiveSpecGroup())
	if specialization and specialization == 3 and ASSpecced then
		registerAllEvents()
	else
		unregisterAllEvents()
	end
end

function CS:getDB()
	local CSDB = LibStub("AceDB-3.0"):New("ConspicuousSpiritsDB", self.defaultSettings, true)
	self.db = CSDB.global
	function self:ResetDB() CSDB:ResetDB() end
end

function CS:Initialize()
	timerFrame:HideChildren()
	
	self:initializeSound()
	self:applySettings()
		
	if UnitAffectingCombat("player") then
		self:PLAYER_REGEN_DISABLED()
	elseif timerFrame.lock then
		self:PLAYER_REGEN_ENABLED()
	else
		timerFrame:ShowChildren()
	end
	
	-- TODO: Add encounter fixes when logging in and already in-combat
end

function CS:OnInitialize()
	self:getDB()
	self:Initialize()
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_POWER")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "talentsChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "setOrbs")
	--self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "setOrbs")
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
end