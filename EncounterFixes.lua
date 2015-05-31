-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local EF = CS:NewModule("EncounterFixes", "AceEvent-3.0")


-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Upvalues
local C_TimerAfter = C_Timer.After
local tostring = tostring
local UnitExists = UnitExists
local UnitGUID = UnitGUID


-- Variables
local boss1GUID
local boss2GUID
local boss3GUID
local boss4GUID
local boss5GUID
local boss1Name
local boss2Name
local boss3Name
local boss4Name
local boss5Name


-- Functions
local function getNPCID(GUID)
	return GUID:sub(-16, -12)
end

local function removeAfter(seconds, GUID)
	C_TimerAfter(seconds, function()
		CS:RemoveGUID(GUID)
	end)
end

local function hideAfter(seconds, GUID)
	C_TimerAfter(seconds, function()
		CS:HideGUID(GUID)
	end)
end

local function checkForOverkill(_, _, event, _, _, _, _, _, destGUID, destName, _, _, ...)
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
	
	if encounterID == 1778 then  -- Hellfire Assault
		-- untested
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			for i = 1, 4 do
				local unitID = "boss"..tostring(i)
				local GUID = UnitGUID(unitID)
				if not GUID then return end
				local NPCID = getNPCID(GUID)
				if NPCID == "94515" then  -- Siegemaster Mar'tak
					if i == 1 then
						boss1GUID = GUID
					elseif i == 2 then
						boss2GUID = GUID
					elseif i == 3 then
						boss3GUID = GUID
					elseif i == 4 then
						boss4GUID = GUID
					end
					self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
					self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function(_, unitID)
						-- we need to check for all initial boss unit IDs since order isn't fixed (seems do denpend on which mob gets pulled first)
						if boss1GUID and unitID == "boss1" then
							CS:RemoveGUID(boss1GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							--@alpha@
							print("Conspicuous Spirits Alpha Debug: Siegemaster Mar'tak left combat")
							--@end-alpha@
							
						elseif boss2GUID and unitID == "boss2" then
							CS:RemoveGUID(boss2GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							--@alpha@
							print("Conspicuous Spirits Alpha Debug: Siegemaster Mar'tak left combat")
							--@end-alpha@
							
						elseif boss3GUID and unitID == "boss3" then
							CS:RemoveGUID(boss3GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							--@alpha@
							print("Conspicuous Spirits Alpha Debug: Siegemaster Mar'tak left combat")
							--@end-alpha@
							
						elseif boss4GUID and unitID == "boss4" then
							CS:RemoveGUID(boss4GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							--@alpha@
							print("Conspicuous Spirits Alpha Debug: Siegemaster Mar'tak left combat")
							--@end-alpha@
							
						end
					end)
				end
			end
		end)
		
		
	elseif encounterID == 1783 then  -- Gorefiend
		-- fix for Gorefiend's massive hitbox
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			if UnitExists("boss1") then 
				CS:SetSATimeCorrection(UnitGUID("boss1"), 4)
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				-- in case player dies and gets resurrected
				self:RegisterEvent("PLAYER_ALIVE", function()
					CS:SetSATimeCorrection(UnitGUID("boss1"), 4)
				end)
			end
		end)
		-- Missing: Shadowy Construct leaving stomach after SA spawn won't generate orbs (not critical since it should be weeded out by range check)
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			-- entering/leaving stomach
			if spellID == 181295 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Digest
				CS:HideAllGUIDs()
				
				-- untested
				-- Enraged Spirit
			elseif spellID == 182557 and event == "SPELL_CAST_SUCCESS" then  -- Slam
				--@alpha@
				print("Conspicuous Spirits Alpha Debug: Removing Enraged Spirit in three seconds")
				--@end-alpha@
				hideAfter(3, sourceGUID)
				
			end
		end)
		
		
	elseif encounterID == 1786 then  -- Kilrogg
		-- player entering/leaving Vision of Death
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			if spellID == 181488 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Vision of Death
				CS:HideAllGUIDs()
			end
		end)
		
		
	elseif encounterID == 1794 then  -- Socrethar
		-- untested
		-- raid member entering Soulbound Construct making it friendly
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			boss1GUID = UnitGUID("boss1")
			if getNPCID(boss1GUID) == 90296 then  -- Soulbound Construct
				
				--@alpha@
				print("Conspicuous Spirits Alpha Debug: Soulbound Construct engaged")
				--@end-alpha@
				
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("UNIT_ENTERED_VEHICLE", function()  -- not sure if this event fires correctly
				
					--@alpha@
					print("Conspicuous Spirits Alpha Debug: UNIT_ENTERED_VEHICLE fired")
					--@end-alpha@
					
					self:HideGUID(boss1GUID)
				end)
			end
		end)
		-- untested
		-- Crystalline Fel Prisons don't fire death events
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", checkForOverkill)
		
		
	elseif encounterID == 1799 then  -- Archimonde
		-- untested
		-- search for overkill since there isn't always a death event for the Doomfire Spirits
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", checkForOverkill)
		-- untested
		-- Entering/leaving Twisting Nether
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			if spellID == 186952 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Nether Banish when inside Nether (does it only affect tanks?)
				--@alpha@
				print("Conspicuous Spirits Alpha Debug: Entered/left Twisting Nether")
				--@end-alpha@
				CS:HideAllGUIDs()
			end
		end)
		
		
	elseif encounterID == 1689 then  -- Flamebender
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			if spellID == 181089 then  -- "Encounter Event" (when wolves vanish)
				CS:RemoveGUID(sourceGUID)
			end
		end)
		
		
	elseif encounterID == 1690 then  -- Blast Furnace
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			if spellID == 605 and event == "SPELL_CAST_SUCCESS" then  -- Dominate Mind
				CS:RemoveGUID(destGUID)  -- possibly replace with HideGUID
			end
		end)
		
		
	elseif encounterID == 1693 then  -- Hans'gar and Franzok
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			boss1GUID = UnitGUID("boss1")
			boss2GUID = UnitGUID("boss2")
			if boss2GUID and boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function()
					if not UnitExists("boss1") then
						CS:RemoveGUID(boss1GUID)
					
					elseif not UnitExists("boss2") then
						CS:RemoveGUID(boss2GUID)
					
					end
				end)
			end
		end)
		
		
	elseif encounterID == 1694 then  -- Beastlord Darmac
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			-- check when Beastlord becomes untargetable due to mounting up
			boss1GUID = UnitGUID("boss1")
			if boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function()
					if not UnitExists("boss1") then
						CS:RemoveGUID(boss1GUID)  -- possibly replace with HideGUID
					end
				end)
			end
		end)
		-- search for overkill since there isn't always a death event for the spears
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", checkForOverkill)
		
		
	elseif encounterID == 1695 then  -- Iron Maidens
		-- might not be needed anymore with new range check
		boss1Name = EJ_GetSectionInfo(10033)  -- Marak
		boss2Name = EJ_GetSectionInfo(10030)  -- Sorka
		boss3Name = EJ_GetSectionInfo(10025)  -- Ga'ran
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			for i = 1, 3 do
				local unitID = "boss"..tostring(i)
				local GUID = UnitGUID(unitID)
				if not GUID then break end
				local NPCID = getNPCID(GUID)
				if NPCID == "77477" then  -- Marak
					boss1GUID = GUID
				elseif NPCID == "77231" then  -- Sorka
					boss2GUID = GUID
				elseif NPCID == "77557" then  -- Ga'ran
					boss3GUID = GUID
				end
			end
			if boss3GUID and boss2GUID and boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", function(_, message, sender)
					if message:find(L["IronMaidensShipMessage"]) then
						if sender == boss1Name then
							removeAfter(3, boss1GUID)  -- possibly replace with hideAfter
							
						elseif sender == boss2Name then
							removeAfter(3, boss2GUID)  -- possibly replace with hideAfter
							
						elseif sender == boss3Name then
							removeAfter(3, boss3GUID)  -- possibly replace with hideAfter
							
						end
					end
				end)
			end
		end)
	end
	
end

function EF:ENCOUNTER_END()
	boss1GUID = nil
	boss2GUID = nil
	boss3GUID = nil
	boss4GUID = nil
	boss5GUID = nil
	boss1Name = nil
	boss2Name = nil
	boss3Name = nil
	boss4Name = nil
	boss5Name = nil
	self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
end

function EF:OnEnable()
	self:RegisterEvent("ENCOUNTER_START")
	self:RegisterEvent("ENCOUNTER_END")
end

function EF:OnDisable()
	self:UnregisterEvent("ENCOUNTER_START")
	self:UnregisterEvent("ENCOUNTER_END")
end