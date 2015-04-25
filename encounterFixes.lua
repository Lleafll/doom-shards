-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Localization
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Variables
local boss1GUID
local boss2GUID
local boss3GUID
local boss1Name
local boss2Name
local boss3Name


-- Functions
CS:encounterFix = function() end

local function hansgarAndFranzokFix()
	if not UnitExists("boss1") then
	
		-- debug
		print("Boss 1 jumps away")
		
		if targets[boss1GUID] then
			CS:removeGUID(boss1GUID)
			CS:update()
		end
	
	elseif not UnitExists("boss2") then
	
		-- debug
		print("Boss 2 jumps away")
		
		if targets[boss2GUID] then
			CS:removeGUID(boss2GUID)
			CS:update()
		end
	
	end
end

local function flamebenderFix(event, sourceGUID, destGUID, spellID)
	if spellID == 181089 and targets[sourceGUID] then
		CS:removeGUID(sourceGUID)
		CS:update()
	end
end

local function ironMaidensTimer(GUID)
	C_TimerAfter(3, function()
		if targets[GUID] then
			CS:removeGUID(GUID)
			CS:update()
		end
	end)
end

local function ironMaidensFix(message, sender)
	if message:find(L["IronMaidensShipMessage"]) then
		if sender == boss1Name then
		
			-- debug
			print(boss1Name.." auf's Schiff")
			
			ironMaidensTimer(boss1GUID)
			
		elseif sender == boss2Name then
		
			-- debug
			print(boss2Name.." auf's Schiff")
			
			ironMaidensTimer(boss2GUID)
			
		elseif sender == boss3Name then
		
			-- debug
			print(boss2Name.." auf's Schiff")
		
			ironMaidensTimer(boss3GUID)
			
		end
	end
end

function CS:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, raidSize)
	print("Encounter ID: "..tostring(encounterID))
	if encounterID == 1689 then
		self.encounterFix = flamebenderFix
		
	elseif encounterID == 1693 then
		boss1GUID = UnitGUID("boss1")
		boss2GUID = UnitGUID("boss2")
		self:RegisterEvent("UNIT_TARGETABLE_CHANGED", "hansgarAndFranzokFix")
		
	elseif encounterID == 1695 then
		for i = 1,3 do
			local unitID = "boss"..tostring(i)
			local GUID = UnitGUID(unitID)
			local NPCID = GUID:sub(-16, -12)
			if NPCID == 77477 then  -- Marak
				boss1GUID = GUID
			elseif NPCID == 77231 then  -- Sorka
				boss2GUID = GUID
			elseif NPCID == 77557 then  -- Ga'ran
				boss3GUID = GUID
			end
		end
		boss1Name = EJ_GetSectionInfo(10033)  -- Marak
		boss2Name = EJ_GetSectionInfo(10030)  -- Sorka
		boss3Name = EJ_GetSectionInfo(10025)  -- Ga'ran
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "ironMaidensFix")
		
	elseif encounterID == Beastlord then
		self.encounterFix = beastlordFix
		
	end
end

function CS:ENCOUNTER_END()
	self:encounterFix = function() end
	boss1GUID = nil
	boss2GUID = nil
	boss3GUID = nil
	boss1Name = nil
	boss2Name = nil
	boss3Name = nil
	self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
	self:UnregisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
end