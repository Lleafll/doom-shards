local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


--------------
-- Upvalues --
--------------
local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecialization = GetSpecialization
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local IsEquippedItem = IsEquippedItem
local mathmin = math.min
local math_sqrt = math.sqrt
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local UnitBuff = UnitBuff


-------------
-- Utility --
-------------
local function getHasteMod()
	return 1 + GetHaste() / 100
end
DS.GetHasteMod = getHasteMod

local function buildHastedIntervalFunc(base)
	return function()
		return base / getHasteMod()
	end
end
DS.buildHastedIntervalFunc = buildHastedIntervalFunc


----------------------------------
-- Spell and Aura Lookup Tables --
----------------------------------
local specSettings = {}
DS.specSettings = specSettings

local trackedAurasMetaTable = {}
trackedAurasMetaTable.__index = function(tbl, k)
	local func = rawget(tbl, k.."Func")
	return func and func(tbl) or nil
end

local auraMetaTable = {}  -- Aura prototypes

local function pandemicFunc(self)
	return 0.3 * self.duration
end

local function tickMethod(self, timeStamp)
	self.nextTick = self:IterateTick(timeStamp)
end

local function refreshMethod(self, timeStamp)
	local belowPandemic = self.expiration + self.duration
	local overPandemic = timeStamp + self.duration + self.pandemic
	self.expiration = belowPandemic < overPandemic and belowPandemic or overPandemic
end

local function iterateTickMethod(self, timeStamp)
	if timeStamp then
		local expiration = self.expiration
		local iteratedTick = timeStamp + self.tickLength
		local isLastTick = iteratedTick >= expiration
		return isLastTick and expiration or iteratedTick, self.resourceChance, isLastTick
	else
		local nextTick = self.nextTick
		return nextTick, self.resourceChance, nextTick >= self.expiration
	end
end

function DS:AddSpecSettings(specID, resourceGeneration, trackedAuras)
	local settings = {}
	specSettings[specID] = settings
	settings.resourceGeneration = resourceGeneration
	settings.trackedAuras = trackedAuras
	
	auraMetaTable[specID] = {}
	for k, v in pairs(trackedAuras) do
		setmetatable(v, trackedAurasMetaTable)
		
		v.id = k
		v.name = GetSpellInfo(k)
		if not v.pandemic then
			v.pandemicFunc = v.pandemicFunc or pandemicFunc
		end
		v.resourceChance = v.resourceChance or 0
		v.Tick = v.Tick or tickMethod
		v.Refresh = v.Refresh or refreshMethod
		v.IterateTick = v.IterateTick or iterateTickMethod
		v.OnApply = v.OnApply or function() end
		v.OnTick = v.OnTick or function() end
		v.OnRemove = v.OnRemove or function() end
		
		auraMetaTable[specID][k] = {__index = v}
	end
end

function DS:BuildAura(spellID, GUID)
	local aura = {}
	setmetatable(aura, auraMetaTable[self.specializationID][spellID])
	
	-- TODO: replace with intialization, possibly via methamethods
	local timeStamp = GetTime()
	aura.expiration = timeStamp + aura.duration
	aura:Tick(timeStamp)
	
	aura:OnApply(timeStamp)
	
	return aura
end


---------------
-- Add Specs --
---------------
-- Affliction
do
	local spellEnergizeFrame = CreateFrame()
	spellEnergizeFrame:SetScript("OnEvent", function(self, _, _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if event == "SPELL_ENERGIZE" and spellID == 980 and sourceGUID = UnitGUID("player") then
			DS.agonyChance = 0.5
		end
	end)
	
	DS:AddSpecSettings(265,
		{
			[27243] = function()  -- Seed of Corruption  -- TODO: possibly cache and update on event
				return (GetTalentInfo(4, 2, GetActiveSpecGroup()) and DS.resource > 0) and -1 or 0
			end,
			[196098] = 5,  -- Soul Harvest
			[18540] = -1,  -- Summon Doomguard
			[688] = -1,  -- Summon Imp
			[1122] = -1,  -- Summon Infernal
			[691] = -1,  -- Summon Felhunter
			[712] = -1,  -- Summon Succubus
			[697] = -1,  -- Summon Voidwalker
			[30108] = -1  -- Unstable Affliction
		},
		{
			[980] = {  -- Agony
				duration = 18,
				tickLengthFunc = buildHastedIntervalFunc(2),
				resourceChanceFunc = function(self)
					return DS.agonyChance 
				end,
				resourceChanceFunc = function(self)
					return 0.16 / math_sqrt(self.agonyCounter)
				end,
				IterateTick = function(self, timeStamp)
					if timeStamp then
						local expiration = self.expiration
						local iteratedTick = timeStamp + self.tickLength
						local procInterval =  -- =MOD(A5+CEILING(($B$3-0.5)/$C$1),$D$1)
						local isLastTick = iteratedTick >= expiration
						return isLastTick and expiration or iteratedTick, self.resourceChance, isLastTick
					else
						local nextTick = self.nextTick
						return nextTick, self.agonyChance, nextTick >= self.expiration
					end
				end,
				OnApply = function(self, timeStamp)
					if not DS.agonyChance then
						DS.agonyChance = DS.agonyChance or 0.5
						spellEnergizeFrame:RegisterEvent("COMBAT_LOG_UNFILTERED")
					end
					DS.agonyCounter = (DS.agonyCounter or 0) + 1
				end,
				OnTick = function(self, timeStamp)  -- TODO: check if tick or resource gain happens first, maybe store timeStamp for check if it's not consistent
					DS.agonyChance = DS.agonyChance + self.resourceChance
				end,
				OnRemove = function(self)
					DS.agonyCounter = DS.agonyCounter - 1
					if DS.agonyCounter <= 0 then
						DS.agonyChance = nil
						spellEnergizeFrame:UnregisterEvent("COMBAT_LOG_UNFILTERED")
					end
				end
			}
		}
	)
end

-- Demonology
local demonicCallingString = GetSpellInfo(205146)
DS:AddSpecSettings(266,
	{
		[104316] = function()  -- Call Dreadstalkers  -- TODO: possibly cache and update on event
			local generates = -2
			if UnitBuff("player", demonicCallingString) then
				generates = generates + 2
			end
			if IsEquippedItem(132393) then  -- Recurrent Ritual
				generates = generates + 2
			end
			return generates
		end,
		[157695] = 1,  -- Demonbolt
		[105174] = -4,  -- Hand of Gul'dan
		[686] = 1,  -- Shadow Bolt
		[196098] = 5,  -- Soul Harvest
		[18540] = -1,  -- Summon Doomguard
		[688] = -1,  -- Summon Imp
		[1122] = -1,  -- Summon Infernal
		[30146] = -1,  -- Summon Felguard
		[691] = -1,  -- Summon Felhunter
		[712] = -1,  -- Summon Succubus
		[697] = -1,  -- Summon Voidwalker
	},
	{
		[603] = {
			durationFunc = buildHastedIntervalFunc(20),
			pandemicFunc = buildHastedIntervalFunc(6),
			tickLengthFunc = buildHastedIntervalFunc(20),
			resourceChance = 1
			-- TODO: Add resource change depending on partial ticks here
		}
	}
)

-- Destruction
DS:AddSpecSettings(267,
	{
		[116858] = -2,  -- Chaos Bolt
		[5740] = -3,  -- Rain of Fire
		[196098] = 5,  -- Soul Harvest
		[18540] = -1,  -- Summon Doomguard
		[688] = -1,  -- Summon Imp
		[1122] = -1,  -- Summon Infernal
		[691] = -1,  -- Summon Felhunter
		[712] = -1,  -- Summon Succubus
		[697] = -1,  -- Summon Voidwalker
	},
	{
		[157736] = {
			duration = 15,
			tickLengthFunc = buildHastedIntervalFunc(3),
			resourceChance = 0.15  -- TODO: Change to crit modified chance function
		}
	}
)