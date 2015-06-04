--@debug@
------------------------------------------------------
-- Get addon object and encounter fix module object --
------------------------------------------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end
local EF = CS:GetModule("EncounterFixes")


---------------------
-- Encounter fixes --
---------------------

-- Alysrazor
EF:RegisterEncounter(1206, function()
	print("Alysrazor engaged")
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED",  "CheckForOverkill")
end)
--@end-debug@