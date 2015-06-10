local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local EF = CS:GetModule("EncounterFixes")


---------------------
-- Encounter fixes --
---------------------

-- Hellfire Assault
EF:RegisterEncounter(1778, function()
	-- untested
	local MartakGUID
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		-- we need to check for all initial boss unit IDs since order isn't fixed (seems do depend on which mob gets pulled first)
		if MartakGUID then
			for i = 1, 4 do
				local unitID = "boss"..tostring(i)
				if UnitGUID(unitID) == MartakGUID then return end
			end
			
			-- debug
			CS:Debug("Siegemaster Mar'tak leaving combat")
			
			RemoveGUID(MartakGUID)
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		
		else
			for i = 1, 4 do
				local unitID = "boss"..tostring(i)
				local GUID = UnitGUID(unitID)
				if not GUID then return end
				local NPCID = EF:GetNPCID(GUID)
				if NPCID == 95068 or NPCID == 94515 or NPCID == 93023 then  -- Siegemaster Mar'tak; 93023 on 2015-06-05
				
					-- debug
					CS:Debug("Setting Siegemaster Mar'tak's GUID")
					
					MartakGUID = GUID
				end
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

-- Iron Reaver
EF:RegisterEncounter(1785, function()
	-- fix for Iron Reaver's hitbox
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		if UnitExists("boss1") then 
			local GUID = UnitGUID("boss1")
			CS:SetSATimeCorrection(GUID, 4)
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			-- in case player dies and gets resurrected
			EF:RegisterEvent("PLAYER_ALIVE", function()
				CS:SetSATimeCorrection(GUID, 4)
			end)
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

-- Kormrok
EF:RegisterEncounter(1787, function()
	-- hitbox fix
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		if UnitExists("boss1") then 
			local GUID = UnitGUID("boss1")
			CS:SetSATimeCorrection(GUID, 2.5)
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			-- in case player dies and gets resurrected
			EF:RegisterEvent("PLAYER_ALIVE", function()
				CS:SetSATimeCorrection(GUID, 2.5)
			end)
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
			
			-- debug
			CS:Debug("Soulbound Construct engaged")
			
			EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			EF:RegisterEvent("UNIT_ENTERED_VEHICLE", function()  -- not sure if this event fires correctly
			
				-- debug
				CS:Debug("UNIT_ENTERED_VEHICLE fired")
				
				EF:HideGUID(GUID)
			end)
		end
	end)
	-- untested
	-- Crystalline Fel Prisons don't fire death events
	EF:CheckForOverkill()
end)

-- Hellfire High Council
EF:RegisterEncounter(1798, function()
	-- untested
	-- search for overkill since there isn't always a death event for Blademaster Jubei'thos' Mirror Images
	EF:CheckForOverkill()
end)

-- Archimonde
EF:RegisterEncounter(1799, function()
	-- untested
	-- search for overkill since there isn't always a death event for the Doomfire Spirits
	EF:CheckForOverkill()
	-- untested
	-- Entering/leaving Twisting Nether
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		if spellID == 186952 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Nether Banish when inside Nether (does it only affect tanks?)
			
			-- debug
			CS:Debug("Conspicuous Spirits Alpha Debug: Entered/left Twisting Nether")
			
			CS:HideAllGUIDs()
		end
	end)
end)