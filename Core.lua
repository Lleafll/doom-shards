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


---------------
-- Variables --
---------------
local generating = 0
local nextCast
local resource = 0
local auras = {}
local resourceGeneration
local trackedAuras


---------------
-- Functions --
---------------
function DS:Update(timeStamp)
	self.timeStamp = timeStamp or GetTime()
	self.resource = resource
	self.auras = auras
	self.generating = generating
	self.nextCast = nextCast
	
	self:SendMessage("DOOM_SHARDS_UPDATE")
end

-- resets all data
function DS:ResetCount()
	auras = {}
	self:Update()
end

function DS:Apply(GUID, spellID)
	local aura = self:BuildAura(spellID)
	auras[GUID] = auras[GUID] or {}
	auras[GUID][spellID] = aura
	self:Update()
end

function DS:Remove(GUID, spellID)
	local auras_GUID = auras[GUID]
	if auras_GUID then
		aura_GUID[spellID]:OnRemove()
		auras_GUID[spellID] = nil
		self:Update()
	end
end

function DS:Refresh(GUID, spellID)
	local timeStamp = GetTime()
	auras[GUID][spellID]:Refresh(timeStamp)
	self:Update(timeStamp)
end

function DS:Tick(GUID, spellID)
	if auras[GUID] and auras[GUID][spellID] then
		local timeStamp = GetTime()
		local aura = auras[GUID][spellID]
		aura:Tick(timeStamp)
		aura:OnTick(timeStamp)
		self:Update(timeStamp)
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
		if trackedAuras[spellID] and sourceGUID == playerGUID then
			if event == "SPELL_CAST_SUCCESS" then  -- "SPELL_AURA_REFRESH" won't fire for Agony
				if auras[destGUID] and auras[destGUID][spellID] then
					self:Refresh(destGUID, spellID)
				else
					self:Apply(destGUID, spellID)
				end				
			elseif event == "SPELL_AURA_REMOVED" then
				self:Remove(destGUID, spellID)
			elseif event == "SPELL_PERIODIC_DAMAGE" then
				self:Tick(destGUID, spellID)
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
local function cleanUp()
	local timeStamp = GetTime() - 3
	for GUID, tbl in pairs(auras) do
		for spellID, aura in pairs(tbl) do
			if aura.expiration < timeStamp then
				DS:Remove(GUID, spellID)
				DS:Update()
			end
		end
	end
	C_TimerAfter(2, cleanUp)
end
DS.CleanUp = cleanUp
cleanUp()


-----------------------
-- Handling Settings --
-----------------------
do
	do
		DS.specializationID = nil --GetSpecializationInfo(GetSpecialization())
		function DS:SpecializationsCheck()
			local newSpecID = GetSpecializationInfo(GetSpecialization())
			if newSpecID and newSpecID ~= self.specializationID then
				self.specializationID = newSpecID
				self:Build()
				self:Update()
			end
		end
	end

	function DS:Build()
		self:EndTestMode()
		self:ApplySettings()
		
		resource = UnitPower("player", unitPowerId)
		
		local specSettings = DS.specSettings[DS.specializationID]
		resourceGeneration = specSettings.resourceGeneration
		trackedAuras = specSettings.trackedAuras
		
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