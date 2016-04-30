local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


--------------
-- Upvalues --
--------------
local C_TimerAfter = C_Timer.After
local GetSpellDescription = GetSpellDescription
local GetTime = GetTime
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsItemInRange = IsItemInRange
local ItemHasRange = ItemHasRange
local mathmin = math.min
local pairs = pairs
local select = select
local stringmatch = string.match
local tableinsert = table.insert  -- only used sparingly
local tableremove = table.remove
local tonumber = tonumber
local UnitCanAttack = UnitCanAttack
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
local SAGraceTime = 3  -- maximum additional wait time before SA timer gets purged if it should not have hit in the meantime
local cacheMaxTime = 1  -- seconds in which the cache does not get refreshed

local orbs = 0
local timers = {}  -- ordered table of all timer IDs
local nextTick = {}
local durations = {}


---------------
-- Functions --
---------------

-- forces an update of displays
--[[ DS:Update()
	self:SendMessage("CONSPICUOUS_SPIRITS_UPDATE", orbs, timers)
end]]--
function DS:Update(timeStamp)
	self:SendMessage("CONSPICUOUS_SPIRITS_UPDATE",
		timeStamp,
		orbs,
		timers,
		nextTick,
		durations
	)
	--self:TargetChanged()
end

-- resets all data
function DS:ResetCount()
	timers = {}
	self:Update(GetTime())
end

-- set specific SATimeCorrection for a GUID
do
	function DS:GetDoomDuration()
		return tonumber(stringmatch(GetSpellDescription(603), "%d%d%.%d"))  -- Possibly replace with something more sensible in the future
	end
	
	--[[DS:TargetChanged = function()
		local GUID = self.UnitGUID("target")
		self.ScanEvents("WARLOCK_DOOM", self:GetDoomDuration(), nextTick[GUID], durations[GUID])
	end]]--
	
	function DS:Add(GUID, timeStamp, tick)
		durations[GUID] = tick
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
		durations[GUID] = nil
		nextTick[GUID] = nil
		self:Update(GetTime())
	end

	function DS:Refresh(GUID)
		local timeStamp = GetTime()
		local duration = self:GetDoomDuration()
		durations[GUID] = timeStamp + duration + mathmin(nextTick[GUID]-timeStamp, 0.3*duration)
		--self:TargetChanged()
	end

	function DS:Tick(GUID)
		for k, v in pairs(timers) do
			if v == GUID then
				tableremove(timers, k)
				local duration = durations[GUID]
				if duration > nextTick[GUID] then
					self:Add(GUID, GetTime(), duration)
				end
				return
			end
		end
	end
	
	function DS:COMBAT_LOG_EVENT_UNFILTERED(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, ...)
		if sourceGUID == playerGUID then
			local spellID = ...
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
					if orbs < maxResource then
						orbs = orbs + 1
						self:UNIT_POWER_FREQUENT("UNIT_POWER_FREQUENT", "player", "SHADOW_ORBS")  -- fail safe in case the corresponding UNIT_POWER_FREQUENT fires wonkily
					end
				end
			end
			
		end
		
		if event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "PARTY_KILL" or event == "SPELL_INSTAKILL" then
			self:Remove(destGUID)
		
		-- Check for overkill because in some cases events don't fire when mobs die
		elseif event == "SWING_DAMAGE" then
			local _, overkill = ...
			if overkill > 0 then
				self:Remove(destGUID)
			end
			
		elseif event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
			local _, _, _, _, overkill = ...
			if overkill > 0 then
				self:Remove(destGUID)
			end
			
		end
	end
end

do	
	function DS:PLAYER_REGEN_DISABLED()
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		orbs = UnitPower("player", unitPowerId)
		
		if not self.locked then
			self:Lock()
		end
		if self.testMode then
			self:EndTestMode()
		end
	end

	function DS:PLAYER_REGEN_ENABLED()  -- player left combat or died
		orbs = UnitPower("player", unitPowerId)
		self:EndTestMode()
		
		if not self.db.calculateOutOfCombat then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:ResetCount()
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			
		elseif UnitIsDead("player") then
			self:ResetCount()
			
		else
			self:Update()
			
		end
	end
end

do
	local delay = 0.01
	
	local function delayOrbs()
		orbs = UnitPower("player", unitPowerId)
		DS:Update()
	end
	
	function DS:UNIT_POWER_FREQUENT(_, unitID, power)
		if not (unitID == "player" and power == unitPowerType) then return end
		C_TimerAfter(delay, delayOrbs)  -- needs to be delayed so it fires after the SA events, otherwise everything will assume the SA is still in flight
	end
end

function DS:PLAYER_ENTERING_WORLD()
	playerGUID = UnitGUID("player")
	orbs = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
	self:ResetCount()
end


-----------------------
-- Handling Settings --
-----------------------
do
	local function isShadow()
		return GetSpecialization() == 2
	end
	
	function DS:TalentsCheck()
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")  -- does this lead to issues when changing talents when SAs are in flight with out-of-combat-calculation?
		warningSound = function() end
		
		if isShadow() then
			orbs = UnitPower("player", unitPowerId)
			self:RegisterEvent("UNIT_POWER_FREQUENT")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:SendMessage("CONSPICUOUS_SPIRITS_SPEC", true)
			
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT")
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:ResetCount()
			self:SendMessage("CONSPICUOUS_SPIRITS_SPEC", false)
			
		end
		
		self:Build()
		self:Update()
	end

	function DS:Build()
		self:EndTestMode()
		self:ApplySettings()
		
		if UnitAffectingCombat("player") then
			if isShadow()
				then self:PLAYER_REGEN_DISABLED() 
			end
		
		elseif self.locked and not self.testMode then
			self:PLAYER_REGEN_ENABLED()

		end
		
	end
end


---------------
-- Test Mode --
---------------
do
	local SAInterval = 6
	local SATravelTime = 8
	local orbTicker
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
			
			orbTicker = C_Timer.NewTicker(0.5, function()
				if orbs > 4 then
					orbs = 0
				else
					orbs = orbs + 1
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
			if orbTicker then
				orbTicker:Cancel()
				orbTicker = nil
			end
			if SATicker then
				SATicker:Cancel()
				SATicker = nil
			end
			self:ResetCount()
			orbs = UnitPower("player", 13)
			self.testMode = false
			self:Lock()
			if not UnitAffectingCombat("player") then
				self:PLAYER_REGEN_ENABLED()
			end
			print(L["Cancelled Test Mode"])
		end
	end
end