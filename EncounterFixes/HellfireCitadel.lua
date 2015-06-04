------------------------------------------------------
-- Get addon object and encounter fix module object --
------------------------------------------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end
local EF = CS:GetModule("EncounterFixes")


---------------------
-- Encounter fixes --
---------------------

-- Hellfire Assault
EF:RegisterEncounter(1778, function()
	-- untested
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		-- we need to check for all initial boss unit IDs since order isn't fixed (seems do depend on which mob gets pulled first)
		for i = 1, 4 do
			local unitID = "boss"..tostring(i)
			local GUID = UnitGUID(unitID)
			if not GUID then return end
			if EF:GetNPCID(GUID) == 94515 then  -- Siegemaster Mar'tak
				EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				EF:RegisterEvent("UNIT_TARGETABLE_CHANGED", function(_, unitID)
					if UnitGUID(unitID) == GUID then
						CS:RemoveGUID(GUID)
						EF:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
						--@alpha@
						print("Conspicuous Spirits Alpha Debug: Siegemaster Mar'tak left combat")
						--@end-alpha@
					end
				end)
			end
		end
	end)
end)

-- Gorefiend
EF:RegisterEncounter(1783, function()
	-- fix for Gorefiend's massive hitbox
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		if UnitExists("boss1") then 
			CS:SetSATimeCorrection(UnitGUID("boss1"), 4)
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			-- in case player dies and gets resurrected
			EF:RegisterEvent("PLAYER_ALIVE", function()
				CS:SetSATimeCorrection(UnitGUID("boss1"), 4)
			end)
		end
	end)
	-- Missing: Shadowy Construct leaving stomach after SA spawn won't generate orbs (not critical since it should be weeded out by range check)
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		-- entering/leaving stomach
		if spellID == 181295 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Digest
			CS:HideAllGUIDs()
			
			-- Enraged Spirit
		elseif spellID == 182557 and event == "SPELL_CAST_SUCCESS" then  -- Slam
			EF:HideAfter(5, sourceGUID)
			
		end
	end)
end)

-- Kilrogg
EF:RegisterEncounter(1786, function()
	-- player entering/leaving Vision of Death
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 181488 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Vision of Death
			CS:HideAllGUIDs()
		end
	end)
end)

-- Socrethar
EF:RegisterEncounter(1794, function()
	-- untested
	-- raid member entering Soulbound Construct making it friendly
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		local GUID = UnitGUID("boss1")
		if EF:GetNPCID(GUID) == 90296 then  -- Soulbound Construct
			
			--@alpha@
			print("Conspicuous Spirits Alpha Debug: Soulbound Construct engaged")
			--@end-alpha@
			
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			EF:RegisterEvent("UNIT_ENTERED_VEHICLE", function()  -- not sure if this event fires correctly
			
				--@alpha@
				print("Conspicuous Spirits Alpha Debug: UNIT_ENTERED_VEHICLE fired")
				--@end-alpha@
				
				EF:HideGUID(GUID)
			end)
		end
	end)
	-- untested
	-- Crystalline Fel Prisons don't fire death events
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED",  "CheckForOverkill")
end)

-- Hellfire High Council
EF:RegisterEncounter(1798, function()
	-- untested
	-- search for overkill since there isn't always a death event for Blademaster Jubei'thos' Mirror Images
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED",  "CheckForOverkill")
end)

-- Archimonde
EF:RegisterEncounter(1799, function()
	-- untested
	-- search for overkill since there isn't always a death event for the Doomfire Spirits
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED",  "CheckForOverkill")
	-- untested
	-- Entering/leaving Twisting Nether
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 186952 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Nether Banish when inside Nether (does it only affect tanks?)
			--@alpha@
			print("Conspicuous Spirits Alpha Debug: Entered/left Twisting Nether")
			--@end-alpha@
			CS:HideAllGUIDs()
		end
	end)
end)