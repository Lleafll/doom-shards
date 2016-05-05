local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


--------------
-- Upvalues --
--------------
local C_TimerAfter = C_Timer.After
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellDescription = GetSpellDescription
local GetTalentInfo = GetTalentInfo
local GetTime = GetTime
local gsub = gsub
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
local maxResource = 5  -- TODO: work with API call or global variable
local playerGUID
local unitPowerType = "SOUL_SHARDS"
local unitPowerId = SPELL_POWER_SOUL_SHARDS
local SPEC_WARLOCK_AFFLICTION = SPEC_WARLOCK_AFFLICTION


-------------------
-- Lookup Tables --
-------------------
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
-- Affliction/Seed of Corruption/Sow the Seeds
resourceGeneration[27243] = function()  -- TODO: possibly cache and update on event
	return (GetSpecialization() == SPEC_WARLOCK_AFFLICTION and GetTalentInfo(4, 2, GetActiveSpecGroup()) and resource > 0) and -1 or 0
end
-- Demonology/Call Dreadstalkers/Demonic Calling
do
	local demonicCallingString = GetSpellInfo(205146)
	resourceGeneration[104316] = function()  -- TODO: possibly cache and update on event
		return UnitBuff("player", demonicCallingString) and 0 or 1
	end
end


---------------
-- Variables --
---------------
local generating = 0
local nextCast
local duration = {}
local nextTick = {}
local resource = 0
local timers = {}  -- ordered table of all timer IDs


---------------
-- Functions --
---------------
function DS:Update(timeStamp)
	if not timeStamp then
		timeStamp = GetTime()
	end
	
	self.timeStamp = timeStamp
	self.resource = resource
	self.timers = timers
	self.nextTick = nextTick
	self.duration = duration
	self.generating = generating
	self.nextCast = nextCast
	
	self:SendMessage("DOOM_SHARDS_UPDATE")
	
	--self:TargetChanged()
	
	energized = 0
end

-- resets all data
function DS:ResetCount()  -- TODO: revamp
	timers = {}
	self:Update(GetTime())
end

-- set specific SATimeCorrection for a GUID
function DS:GetDoomDuration()
	local doomDuration = tonumber(stringmatch(GetSpellDescription(603), "%d%d%.%d"))  -- Possibly replace with something more sensible in the future
	return doomDuration
end

--[[DS:TargetChanged = function()
	local GUID = self.UnitGUID("target")
	self.ScanEvents("WARLOCK_DOOM", self:GetDoomDuration(), nextTick[GUID], duration[GUID])
end]]--

function DS:Add(GUID, timeStamp, tick)
	duration[GUID] = tick
	nextTick[GUID] = tick
	if #timers == 0 then  -- might not be necessary if for-loop skips looping on empty tables (need to check)
		timers[1] = GUID
		self:Update(timeStamp)
		return
	end
	for k, v in pairs(timers) do
		if nextTick[v] > tick then
			tableinsert(timers, k, GUID)
			self:Update(timeStamp)
			return
		end
	end
	timers[#timers+1] = GUID
	self:Update(timeStamp)
end

function DS:Apply(GUID)
	local timeStamp = GetTime()
	local tick = timeStamp + self:GetDoomDuration()
	self:Add(GUID, timeStamp, tick)
end

function DS:Remove(GUID)
	for k, v in pairs(timers) do
		if v == GUID then
			tableremove(timers, k)
			break
		end
	end
	duration[GUID] = nil
	nextTick[GUID] = nil
	self:Update()
end

function DS:Refresh(GUID)
	local timeStamp = GetTime()
	local doomDuration = self:GetDoomDuration()
	duration[GUID] = timeStamp + doomDuration + mathmin(nextTick[GUID]-timeStamp, 0.3*doomDuration)
	--self:TargetChanged()
end

function DS:Tick(GUID)
	for k, v in pairs(timers) do
		if v == GUID then
			tableremove(timers, k)
			local maxDuration = duration[GUID]
			if maxDuration > nextTick[GUID] then
				self:Add(GUID, GetTime(), maxDuration)
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

function DS:COMBAT_LOG_EVENT_UNFILTERED(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, ...)
	if sourceGUID == playerGUID then
		local spellID, _, _, energizeAmount, energizeType = ...
		-- Doom
		if spellID == 603 and sourceGUID == playerGUID then
			if event == "SPELL_AURA_APPLIED" then
				self:Apply(destGUID)
			elseif event == "SPELL_AURA_REMOVED" then
				self:Remove(destGUID)
			elseif event == "SPELL_AURA_REFRESH" then
				self:Refresh(destGUID)
			elseif event == "SPELL_PERIODIC_DAMAGE" then
				self:Tick(destGUID)
				if resource < maxResource then
					resource = resource + 1
					self:UNIT_POWER_FREQUENT("UNIT_POWER_FREQUENT", "player", "SOUL_SHARDS")  -- fail safe in case the corresponding UNIT_POWER_FREQUENT fires wonkily
				end
			end
		end
	end
	
	if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL" then
		self:Remove(destGUID)
	
	-- Check for overkill because in some cases events don't fire when mobs die
	--[[elseif event == "SWING_DAMAGE" then
		local _, overkill = ...
		if overkill > 0 then
			self:Remove(destGUID)
		end
		
	elseif event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
		local _, _, _, _, overkill = ...
		if overkill > 0 then
			self:Remove(destGUID)
		end]]--
		
	end
end

function DS:PLAYER_REGEN_DISABLED()  -- TODO: possibly add shard countdown when player leaves combat
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
	UnitPower("player", unitPowerId)
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
	local SAGraceTime = 3  -- maximum additional wait time before SA timer gets purged if it should not have hit in the meantime
	local SAInterval = 6
	local SATravelTime = 8
	local resourceTicker
	local TestGUID = "Test Mode"
	
	local function SATickerFunc()
		distanceCache[TestGUID].timeStamp = GetTime()
		DS:AddGUID(TestGUID)
		timers[#timers].impactTime = timers[#timers].impactTime + SAGraceTime  -- fixes "0.0"-issue
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
					if module.Unlock then module:Unlock() end
				end
				self:Update()
			end
			
			resourceTicker = C_Timer.NewTicker(0.5, function()
				if resource > 4 then
					resource = 0
				else
					resource = resource + 1
				end
				DS:Update()
			end)
			
			distanceCache[TestGUID] = {}
			distanceCache[TestGUID].travelTime = SATravelTime
			distanceCache[TestGUID].timeStamp = GetTime()
			
			SATickerFunc()
			SATicker = C_Timer.NewTicker(SAInterval, SATickerFunc)
			
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
			resource = UnitPower("player", 13)
			self.testMode = false
			self:Lock()
			if not UnitAffectingCombat("player") then
				self:PLAYER_REGEN_ENABLED()
			end
			print(L["Cancelled Test Mode"])
		end
	end
end