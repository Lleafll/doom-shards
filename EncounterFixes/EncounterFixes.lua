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
local tostring = tostring
local UnitExists = UnitExists
local UnitGUID = UnitGUID


---------------
-- Variables --
---------------
local encounterFixesTable


---------------
-- Functions --
---------------
function EF:RegisterEncounter(encounterID, callback)
	encounterFixesTable[encounterID] = callback
end

function EF:GetNPCID(GUID)
	return GUID:sub(-16, -12)
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

function EF:UnregisterEvents()
	self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("PLAYER_ALIVE")
end

function EF:OnEnable()
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END", "UnregisterEvents")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UnregisterEvents")  -- fail safe if player hearths out or something…
end

function EF:OnDisable()
	self:UnregisterEvent("ENCOUNTER_START")
	self:UnregisterEvent("ENCOUNTER_END")
end