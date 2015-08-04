local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local EF = CS:GetModule("EncounterFixes")


---------------------
-- Encounter fixes --
---------------------

-- Hellfire Assault
EF:RegisterEncounter(1778, function()
	local MartakGUID
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		-- we need to check for all initial boss unit IDs since order isn't fixed (seems to depend on which mob gets pulled first)
		if MartakGUID then
			for i = 1, 4 do
				local unitID = "boss"..tostring(i)
				if UnitGUID(unitID) == MartakGUID then return end
			end
			
			-- debug
			CS:Debug("Siegemaster Mar'tak leaving combat")
			
			CS:RemoveGUID(MartakGUID)
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
	EF:SetHitboxSize("boss1", 4)

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
	EF:SetHitboxSize("boss1", 4)
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
	EF:SetHitboxSize("boss1", 3.5)
end)

-- Socrethar
EF:RegisterEncounter(1794, function()
	-- raid member entering Soulbound Construct making it friendly
	EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
		local GUID = UnitGUID("boss1")
		if EF:GetNPCID(GUID) == 90296 then  -- Soulbound Construct
			
			-- untested
			-- Socrethar gets ejected
			EF:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, _, _, _, spellID)
				if spellID == 183023 then 
					CS:Debug("Eject Soul")
					CS:RemoveGUID(GUID)
				end
			end)
			
			-- untested
			-- Socrethar returning to construct
			EF:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
				local GUID = UnitGUID("boss2")
				if EF:GetNPCID(GUID) == 92330 then  -- Soul of Socrethar
					EF:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
					EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
						if spellID == 190466 and  event == "SPELL_AURA_REMOVED" then  -- Incomplete Binding
							CS:Debug("Soul Returning to Construct")
							CS:RemoveGUID(GUID)
						end
					end)
				end
			end)
			
		end
	end)
end)

-- Archimonde
EF:RegisterEncounter(1799, function()
	EF:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
		-- entering/leaving Twisting Nether
		if spellID == 186952 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Nether Banish when inside Nether			
			CS:HideAllGUIDs()
			
		-- untested
		-- Void Stars despawn after knocking players away without triggering death event
		elseif event == "SPELL_AURA_REMOVED" and (spellID == 189895 or spellID == 190806 or spellID == 190807 or spellID == 190808) then  -- Void Star Fixate, check if all spell IDs are actually used later
			CS:RemoveGUID(sourceGUID)
		
		end
	end)
end)

-- Xhul'horac
EF:RegisterEncounter(1800, function()
	EF:SetHitboxSize("boss1", 2.5)
end)