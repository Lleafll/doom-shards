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
	local function tickLength()
		return base / getHasteMod()
	end
	return tickLength
end


----------------------------------
-- Spell and Aura Lookup Tables --
----------------------------------
local specSettings = {}
DS.specSettings = specSettings

local trackedAurasMetaTable = {}
trackedAurasMetaTable.__index = function(tbl, k)
	local func = rawget(tbl, k.."Func")
	return func and func() or nil
end

local auraMetaTable = {}  -- Aura prototypes

local function tickMethod(self, timeStamp)
	self.nextTick = timeStamp + self.tickLength
end

local function refreshMethod(self, timeStamp)
	self.expiration = mathmin(self.expiration + self.duration, timeStamp + self.duration + self.pandemic)
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
		v.pandemic = (v.pandemic) or (0.3 * v.duration)
		v.Tick = v.Tick or tickMethod
		v.Refresh = v.Refresh or refreshMethod
		
		auraMetaTable[specID][k] = {__index = v}
	end
end

function DS:BuildAura(spellID, GUID)
	local aura = {}
	setmetatable(aura, auraMetaTable[self.specializationID][spellID])
	aura.expiration = GetTime() + aura.duration
	aura:Tick()  -- TODO: replace with intialization, possibly via methamethods
	return aura
end


---------------
-- Add Specs --
---------------
-- Affliction
DS:AddSpecSettings(265,
	{
		[27243] = function()  -- Seed of Corruption  -- TODO: possibly cache and update on event
			return (GetTalentInfo(4, 2, GetActiveSpecGroup()) and DS.resource > 0) and -1 or 0
		end,
		[196098] = 5,  -- Soul Harvest
		[157757] = -1,  -- Summon Doomguard
		[688] = -1,  -- Summon Imp
		[157898] = -1,  -- Summon Infernal
		[691] = -1,  -- Summon Felhunter
		[712] = -1,  -- Summon Succubus
		[697] = -1,  -- Summon Voidwalker
		[30108] = -1  -- Unstable Affliction
	},
	{
		[980] = {  -- Agony
			duration = 24,
			tickLengthFunc = buildHastedIntervalFunc(2)
		}
	}
)

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
		[196098] = 5,  -- Soul Harvest
		[157757] = -1,  -- Summon Doomguard
		[688] = -1,  -- Summon Imp
		[157898] = -1,  -- Summon Infernal
		[691] = -1,  -- Summon Felhunter
		[712] = -1,  -- Summon Succubus
		[697] = -1,  -- Summon Voidwalker
	},
	{
		[603] = {
			durationFunc = buildHastedIntervalFunc(20),
			pandemicFunc = buildHastedIntervalFunc(6),
			tickLengthFunc = buildHastedIntervalFunc(20),
		}
	}
)

-- Destruction
DS:AddSpecSettings(267,
	{
		[116858] = -2,  -- Chaos Bolt
		[5740] = -3,  -- Rain of Fire
		[196098] = 5,  -- Soul Harvest
		[157757] = -1,  -- Summon Doomguard
		[688] = -1,  -- Summon Imp
		[157898] = -1,  -- Summon Infernal
		[691] = -1,  -- Summon Felhunter
		[712] = -1,  -- Summon Succubus
		[697] = -1,  -- Summon Voidwalker
	},
	{
		[157736] = {
			duration = 15,
			tickLengthFunc = buildHastedIntervalFunc(3)
		}
	}
)