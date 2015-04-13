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
local print = print
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
local timers = {}  -- ordered table of all timer IDs
local distanceCache = {}
local distanceCache_GUID
local timerID

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

local SAVelocity = 5.5  -- estimated
local maxToleratedTime = 10  -- maximum time before Shadowy Apparition gets purged if it should not have hit in the meantime
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
	
	return travelTime + 0.5  -- accounting for extra 0.5 sec travel time due to hitbox size (estimated)
end

local function addGUID(timeStamp, GUID)
	targets[GUID] = targets[GUID] or {}
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
	
local function removeGUID(GUID)
	for _, timerID in pairs(targets[GUID]) do
		removeTimer(timerID)
	end
	targets[GUID] = nil
	distanceCache[GUID] = nil
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
	timers = {}
	distanceCache = {}
	CS:CancelAllTimers()
end

function CS:COMBAT_LOG_EVENT_UNFILTERED(_, ...)
	local timeStamp, event, _, sourceGUID, _, _, _, destGUID,_, _, _, spellId, _, _, _, _, _, _, _, _, _, _, _, _, multistrike = ...
        
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "SPELL_INSTAKILL" then
		if destGUID == UnitGUID("player") then
			orbs = UnitPower("player", 13)
			resetCount()
			self:update()
			return
			
		elseif targets[destGUID] then
			removeGUID(destGUID)
			self:update()
			return
			
		end
		
		
	elseif sourceGUID == UnitGUID("player")  then
		-- Shadowy Apparition cast
		if spellId == 147193 then
			if UnitAffectingCombat("player") then
				addGUID(timeStamp, destGUID)
				self:update()
			end
			return
			
		-- catch all Shadowy Apparition hit events
		elseif spellId == 148859 and not multistrike then
			timerID = popGUID(destGUID)
			if timerID then removeTimer(timerID) end
			self:update()
			return
		
		-- Shadowy Word: Pain tick
		elseif spellId == 589 and not multistrike and (event == "SPELL_PERIODIC_DAMAGE" or event == "SPELL_DAMAGE") then
			if UnitAffectingCombat("player") then
				getTravelTime(timeStamp, destGUID)  -- adds GUID to distance table
			end
			return
			
		end
		
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

local unitPowerCallback = function()
	if UnitAffectingCombat("player") or (CS.db.display == "Complex" and CS.db.outofcombat) then
		orbs = UnitPower("player", 13)
		CS:update()
	end
end

function CS:UNIT_POWER(_, unitID, power)
	if not (unitID == "player" and power == "SHADOW_ORBS") then return end
	C_TimerAfter(0.01, unitPowerCallback)  -- needs to be delayed so it fires after the SA events, otherwise everything will assume the SA is still in flight
end

function CS:PLAYER_ENTERING_WORLD()
	orbs = UnitPower("player", 13)
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
	
	if self.db.display == "Complex" then
		self:initializeComplex()
	elseif self.db.display == "Simple" then
		self:initializeSimple()
	elseif self.db.display == "WeakAuras" then
		self:initializeWeakAuras(timers)
	end
	self:initializeSound()
	self:applySettings()
		
	if UnitAffectingCombat("player") then
		self:PLAYER_REGEN_DISABLED()
	elseif timerFrame.lock then
		self:PLAYER_REGEN_ENABLED()
	else
		timerFrame:ShowChildren()
	end
end

function CS:OnInitialize()
	self:getDB()
	self:Initialize()
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_POWER")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "talentsChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end