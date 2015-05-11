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
local boss1Name
local boss2Name
local boss3Name


-- Functions
local function getNPCID(GUID)
	return GUID:sub(-16, -12)
end

local function removeAfter(seconds, GUID)
	C_TimerAfter(seconds, function()
		CS:RemoveGUID(GUID)
	end)
end

function EF:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, raidSize)
	
	if encounterID == 1778 then  -- Hellfire Assault
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
						if boss1GUID and unitID == "boss1" then
							CS:RemoveGUID(boss1GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							
						elseif boss2GUID and unitID == "boss2" then
							CS:RemoveGUID(boss2GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							
						elseif boss3GUID and unitID == "boss3" then
							CS:RemoveGUID(boss3GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							
						elseif boss4GUID and unitID == "boss4" then
							CS:RemoveGUID(boss4GUID)
							self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
							
						end
					end)
				end
			end
		end)
		
		
	elseif encounterID == 1783 then  -- Gorefiend
		-- Missing: Shadowy Construct leaving stomach after SA spawn won't generate orbs
		-- https://www.warcraftlogs.com/reports/LhmF1T3xjdcPA9XJ#pins=0%24Separate%24%23244F4B%24any%24-1%240.0.0.Any%240.0.0.Any%24true%240.0.0.Any%24true%24155521%7C147193%7C148859%5E0%24Separate%24%23909049%24any%24-1%240.0.0.Any%240.0.0.Any%24true%2410446771.0.0.Priest%24true%24179864%5E0%24Separate%24%23a04D8A%24any%24-1%240.0.0.Any%240.0.0.Any%24true%2410446771.0.0.Priest%24true%24181295&view=events&type=resources&fight=22
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			-- entering/leaving stomach
			if spellID == 181295 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Digest
				CS:RemoveAllGUIDs()
				
				-- Enraged Spirit
			elseif spellID == 182557 and event == "SPELL_CAST_SUCCESS" then  -- Slam
				removeAfter(3, sourceGUID)
				
			end
		end)
		
		
	elseif encounterID == 1786 then  -- Kilrogg
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, timeStamp, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
			if spellID == 181488 and destGUID == UnitGUID("player") and (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED") then  -- Vision of Death
				CS:RemoveAllGUIDs()
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
				CS:RemoveGUID(destGUID)
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
			boss1GUID = UnitGUID("boss1")
			if boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("UNIT_TARGETABLE_CHANGED", function()
					if not UnitExists("boss1") then
						CS:RemoveGUID(boss1GUID)
					end
				end)
			end
		end)
		
		
	elseif encounterID == 1695 then  -- Iron Maidens
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
							removeAfter(3, boss1GUID)
							
						elseif sender == boss2Name then
							removeAfter(3, boss2GUID)
							
						elseif sender == boss3Name then
							removeAfter(3, boss3GUID)
							
						end
					end
				end)
			end
		end)
		
		
		--@debug@
	elseif encounterID == 1206 then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			for i = 1,1 do
				local unitID = "boss"..tostring(i)
				local GUID = UnitGUID(unitID)
				
				-- debug
				print("GUID: "..GUID)
				
				if not GUID then break end
				local NPCID = GUID:sub(-16, -12)
				
				-- debug
				print("NPCID: "..NPCID)
				
				if NPCID == "52530" then  -- Alysrazor
					boss1GUID = GUID
				end
			end
			if boss1GUID then
			
				-- debug
				print(boss1GUID)
				
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			end
		end)
		boss1Name = "Herald of the Burning End"
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", function(_, message, sender)

			-- debug
			print(sender, message)
			
			if message:find("begins casting") then
				if sender == boss1Name then
				
					-- debug
					print(boss1Name.." auf's Schiff")
					print(boss1GUID)
					
					C_TimerAfter(3, function()
						print("removed")
					end)
				end
			end
		end)
		--@end-debug@
		
	end
	
end

function EF:ENCOUNTER_END()
	boss1GUID = nil
	boss2GUID = nil
	boss3GUID = nil
	boss1Name = nil
	boss2Name = nil
	boss3Name = nil
	self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
end

function EF:OnEnable()
	self:RegisterEvent("ENCOUNTER_START")
end

function EF:OnDisable()
	self:RegisterEvent("ENCOUNTER_END")
end