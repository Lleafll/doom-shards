----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-------------------
-- Create module --
-------------------
local EF = CS:NewModule("EncounterFixes", "AceEvent-3.0")


------------------
-- Localization --
------------------
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


--------------
-- Upvalues --
--------------
local C_TimerAfter = C_Timer.After
local tonumber = tonumber
local UnitExists = UnitExists
local UnitGUID = UnitGUID


---------------
-- Variables --
---------------
local encounterFixesTable = {}


---------------
-- Functions --
---------------
function EF:RegisterEncounter(encounterID, callback)
	encounterFixesTable[encounterID] = callback
end

function EF:GetNPCID(GUID)
	return tonumber(GUID:sub(-16, -12))
end

function EF:RemoveAfter(seconds, GUID)
	C_TimerAfter(seconds, function()
		CS:RemoveGUID(GUID)
	end)
end

function EF:HideAfter(seconds, GUID)
	C_TimerAfter(seconds, function()
		CS:HideGUID(GUID)
	end)
end

function EF:CheckForOverkill(_, _, event, _, _, _, _, _, destGUID, destName, _, _, ...)
	if event == "SWING_DAMAGE" then
		_, overkill = ...
		if overkill > 0 then
			CS:RemoveGUID(destGUID)
		end
		
	elseif event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
		_, _, _, _, overkill = ...
		if overkill > 0 then
			CS:RemoveGUID(destGUID)
		end
		
	end
end

function EF:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, raidSize)
	if encounterFixesTable[encounterID] then encounterFixesTable[encounterID]() end
end

function EF:RegisterEvents()
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END", "UnregisterEvents")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UnregisterEvents")  -- fail safe if player hearths out or something…
end

function EF:UnregisterEvents()
	self:UnregisterAllEvents()  -- is this hacky? it's convenient…
	self:RegisterEvents()
end

function EF:OnEnable()
	self:RegisterEvents()
end

function EF:OnDisable()
	self:UnregisterAllEvents()
end