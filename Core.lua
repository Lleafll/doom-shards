local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


--------------
-- Upvalues --
--------------
local C_TimerAfter = C_Timer.After
local GetActiveSpecGroup = GetActiveSpecGroup
local GetHaste = GetHaste
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellDescription = GetSpellDescription
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local gsub = gsub
local IsEquippedItem = IsEquippedItem
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsItemInRange = IsItemInRange
local ItemHasRange = ItemHasRange
local mathmin = math.min
local pairs = pairs
local select = select
local stringmatch = string.match
local strsplit = strsplit
local tableinsert = table.insert  -- only used sparingly
local tableremove = table.remove
local tonumber = tonumber
local type = type
local UnitBuff = UnitBuff
local UnitCanAttack = UnitCanAttack
local UnitCastingInfo = UnitCastingInfo
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitPower = UnitPower


---------------
-- Constants --
---------------
local maxResource = 5
local playerGUID
local unitPowerType = "SOUL_SHARDS"
local unitPowerId = SPELL_POWER_SOUL_SHARDS
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION


---------------
-- Variables --
---------------
local generating = 0
local nextCast
local duration = {}
local nextTick = {}
local resource = 0
local timers = {}
local dots = {}


-------------
-- Utility --
-------------
local function getHasteMod()
	return 1 + GetHaste() / 100
end
DS.GetHasteMod = getHasteMod


-------------------
-- Lookup Tables --
-------------------
-- Resource Generation
local resourceGeneration = {
	-- General
	[196098] = 5,  -- Soul Harvest
	[157757] = -1,  -- Summon Doomguard
	[688] = -1,  -- Summon Imp
	[157898] = -1,  -- Summon Infernal
	[691] = -1,  -- Summon Felhunter
	[712] = -1,  -- Summon Succubus
	[697] = -1,  -- Summon Voidwalker
	
	-- Affliction
	[30108] = -1,  -- Unstable Affliction
	
	-- Demonology
	[157695] = 1,  -- Demonbolt
	[105174] = -4,  -- Hand of Gul'dan
	[686] = 1,  -- Shadow Bolt
	[30146] = -1,  -- Summon Felguard
	
	-- Destruction
	[116858] = -2,  -- Chaos Bolt
	[5740] = -3,  -- Rain of Fire
}
DS.resourceGeneration = resourceGeneration
-- Affliction/Seed of Corruption/Sow the Seeds
resourceGeneration[27243] = function()  -- TODO: possibly cache and update on event
	return (GetSpecialization() == SPEC_WARLOCK_AFFLICTION and GetTalentInfo(4, 2, GetActiveSpecGroup()) and resource > 0) and -1 or 0
end
-- Demonology/Call Dreadstalkers/Demonic Calling
do
	local demonicCallingString = GetSpellInfo(205146)
	resourceGeneration[104316] = function()  -- TODO: possibly cache and update on event
		local generates = -2
		if UnitBuff("player", demonicCallingString) then
			generates = generates + 2
		end
		if IsEquippedItem(132393) then  -- Recurrent Ritual
			generates = generates + 2
		end
		return generates
	end
end
-- Tracked DoTs
local trackedDots = {}
DS.trackedDots = trackedDots
local function buildTickLength(baseTickLength)
	local function tickLength()
		return baseTickLength / getHasteMod()
	end
	return tickLength
end
trackedDots[980] = {
	name = "Agony",
	id = 980,
	duration = function() return 24 end,
	pandemic = function() return 7.2 end,
	tickLength = buildTickLength(2)
}
trackedDots[603] = {
	name = "Doom",
	id = 603,
	duration = buildTickLength(20),
	pandemic = buildTickLength(20),
	tickLength = buildTickLength(20),
}
trackedDots[157736] = {
	name = "Immolate",
	id = 157736,
	duration = function() return 15 end,
	pandemic = function() return 4.5 end,
	tickLength = buildTickLength(3)
}


---------------
-- Functions --
---------------
function DS:Update(timeStamp)
	self.timeStamp = timeStamp or GetTime()
	self.resource = resource
	self.timers = timers
	self.nextTick = nextTick
	self.duration = duration
	self.generating = generating
	self.nextCast = nextCast
	self.dots = dots
	
	self:SendMessage("DOOM_SHARDS_UPDATE")
end

-- resets all data
function DS:ResetCount()
	timers = {}
	self:Update(GetTime())
end

function DS:Add(GUID, timeStamp, tick, dur, dot)
	nextTick[GUID] = tick
	duration[GUID] = dur
	local timerLength = #timers
	if timerLength == 0 then  -- might not be necessary if for-loop skips looping on empty tables (need to check)
		timers[1] = GUID
		dots[1] = dot
		self:Update(timeStamp)
		return
	end
	for k, v in pairs(timers) do
		if nextTick[v] > tick then
			tableinsert(timers, k, GUID)
			tableinsert(dots, k, dot)
			self:Update(timeStamp)
			return
		end
	end
	timerLength = timerLength + 1
	timers[timerLength] = GUID
	dots[timerLength] = dot
	self:Update(timeStamp)
end

function DS:Apply(GUID, dot)
	local timeStamp = GetTime()
	local tick = timeStamp + dot.tickLength()
	local duration = timeStamp + dot.duration()
	self:Add(GUID, timeStamp, tick, duration, dot)
end

function DS:Remove(GUID, dot)
	for k, v in pairs(timers) do
		if v == GUID then
			tableremove(timers, k)
			tableremove(dots, k)
			break
		end
	end
	duration[GUID] = nil
	nextTick[GUID] = nil
	self:Update()
end

function DS:Refresh(GUID, dot)
	local timeStamp = GetTime()
	duration[GUID] = timeStamp + dot.duration() + mathmin(duration[GUID]-timeStamp, dot.pandemic())
end

function DS:Tick(GUID, dot)
	for k, v in pairs(timers) do
		if v == GUID then
			tableremove(timers, k)
			tableremove(dots, k)
			local remaining = duration[GUID]
			if remaining > nextTick[GUID] then
				self:Add(GUID, GetTime(), mathmin(dot.tickLength(), remaining), remaining, dot)
			end
			return
		end
	end
end

do
	local function spellGUIDToID(GUID)
		local _, _, _, _, ID = strsplit("-", GUID)
		return tonumber(ID)
	end
	
	function DS:Cast(spellGUID)
		if spellGUID then
			local generation = resourceGeneration[spellGUIDToID(spellGUID)]
			if generation then
				if type(generation) == "function" then
					generation = generation()
				end
				generating = generation
				local _, _, _, _, startTime, endTime = UnitCastingInfo("player")
				nextCast = GetTime() + (endTime - startTime) / 1000
				self:Update()
			end
		elseif not UnitCastingInfo("player") then  -- Command Demon fires SPELL_CAST_SUCCEEDED 
			generating = 0
			nextCast = nil
			self:Update()
		end
	end
end


--------------------
-- Event Handling --
--------------------
function DS:COMBAT_LOG_EVENT_UNFILTERED(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, ...)
	if sourceGUID == playerGUID then
		local spellID, _, _, _, _ = ...
		local dot = trackedDots[spellID]
		if dot and sourceGUID == playerGUID then
			if event == "SPELL_AURA_APPLIED" then
				self:Apply(destGUID, dot)
			elseif event == "SPELL_AURA_REMOVED" then
				self:Remove(destGUID, dot)
			elseif event == "SPELL_AURA_REFRESH" then
				self:Refresh(destGUID, dot)
			elseif event == "SPELL_PERIODIC_DAMAGE" then
				self:Tick(destGUID, dot)
				if resource < maxResource then
					resource = resource + 1
					self:UNIT_POWER_FREQUENT("UNIT_POWER_FREQUENT", "player", "SOUL_SHARDS")  -- fail safe in case the corresponding UNIT_POWER_FREQUENT fires wonkily
				end
			end
		end
	end
	
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL" then
		self:Remove(destGUID)
	end
end

function DS:PLAYER_REGEN_DISABLED()		
	if not self.locked then
		self:Lock()
	end
	if self.testMode then
		self:EndTestMode()
	end
end

function DS:PLAYER_REGEN_ENABLED()  -- player left combat or died
	self:EndTestMode()
	if UnitIsDead("player") then
		self:ResetCount()
		
	else
		self:Update()
		
	end
end

function DS:UNIT_POWER_FREQUENT(_, unitID, power)
	if not (unitID == "player" and power == unitPowerType) then return end
	resource = UnitPower("player", unitPowerId)
	DS:Update()
end

function DS:UNIT_SPELLCAST_INTERRUPTED(_, unitID, _, _, spellGUID)
	if unitID == "player"  then
		self:Cast(false)
	end
end

function DS:UNIT_SPELLCAST_START(_, unitID, _, _, spellGUID)
	if unitID == "player"  then
		self:Cast(spellGUID)
	end
end

function DS:UNIT_SPELLCAST_STOP(_, unitID, _, _, spellGUID)
	if unitID == "player"  then
		self:Cast(false)
	end
end

function DS:UNIT_SPELLCAST_SUCCEEDED(_, unitID, _, _, spellGUID)
	if unitID == "player"  then
		self:Cast(false)
	end
end

function DS:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
	resource = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	self:ResetCount()
end


--------------------
-- Cleanup Ticker --
--------------------
do
	local timeStamp
	local tick
	local function cleanUp()
		timeStamp = GetTime() - 3
		for i, GUID in pairs(timers) do
			tick = nextTick[GUID]
			if tick < timeStamp then
				DS:Tick(GUID)
				DS:Update()
			end
		end
		C_TimerAfter(2, cleanUp)
	end
	cleanUp()
end


-----------------------
-- Handling Settings --
-----------------------
do
	function DS:TalentsCheck()
		self:Build()
		self:Update()
	end

	function DS:Build()
		self:EndTestMode()
		self:ApplySettings()
		resource = UnitPower("player", unitPowerId)
		
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

		self:RegisterEvent("UNIT_POWER_FREQUENT")
		self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		self:RegisterEvent("UNIT_SPELLCAST_START")
		self:RegisterEvent("UNIT_SPELLCAST_STOP")
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		
		if UnitAffectingCombat("player") then
			self:PLAYER_REGEN_DISABLED() 
		
		elseif self.locked and not self.testMode then
			self:PLAYER_REGEN_ENABLED()

		end
		
	end
end


---------------
-- Test Mode --
---------------
do  -- TODO: Fix
	local testFrame = CreateFrame("frame")
	
	--DS:Add(GUID, timeStamp, tick)
	
	local resourceTicker
	local TestGUID = "Test Mode"
	
	local function SATickerFunc()
		local timeStamp = GetTime()
		local dur = DS:GetDoomDuration()
		DS:Add(TestGUID, timeStamp, timeStamp + dur)
		--timers[#timers].impactTime = timers[#timers].impactTime + SAGraceTime  -- fixes "0.0"-issue
		C_TimerAfter(dur + 0.2, function() DS:Remove("Test Mode") end)
	end
	
	function DS:TestMode()
		if self.testMode then
			self:EndTestMode()
		else
			if UnitAffectingCombat("player") then return end
			if not self.locked then self:Lock() end
			self:PLAYER_REGEN_DISABLED()

			for name, module in self:IterateModules() do
				if self.db[name] and self.db[name].enable then
					if module.frame then module.frame:Show() end
					--if module.Unlock then module:Unlock() end
				end
				self:Update()
			end
			
			resourceTicker = C_Timer.NewTicker(1, function()
				resource = resource < maxResource and resource + 1 or 0
				DS:Update()
			end)
			
			SATickerFunc()
			SATicker = C_Timer.NewTicker(self:GetDoomDuration()+1, SATickerFunc)
			
			self.testMode = true
			print(L["Starting Test Mode"])
		end
	end
	
	function DS:EndTestMode()
		if self.testMode then
			if resourceTicker then
				resourceTicker:Cancel()
				resourceTicker = nil
			end
			if SATicker then
				SATicker:Cancel()
				SATicker = nil
			end
			self:ResetCount()
			resource = UnitPower("player", unitPowerId)
			self.testMode = false
			self:Lock()
			if not UnitAffectingCombat("player") then
				self:PLAYER_REGEN_ENABLED()
			end
			print(L["Cancelled Test Mode"])
		end
	end
	
	testFrame:RegisterEvent("PLAYER_REGEN_DISABLED", DS.EndTestMode)
end