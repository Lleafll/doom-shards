local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


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
	return (GetSpecialization() == SPEC_WARLOCK_AFFLICTION and GetTalentInfo(4, 2, GetActiveSpecGroup()) and DS.resource > 0) and -1 or 0
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