-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


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

function CS:encounterFix(...) end

function CS:hellfireAssaultFix(_, unitID)
	if boss1GUID and unitID == "boss1" then
		self:removeGUID(boss1GUID)
		self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		
	elseif boss2GUID and unitID == "boss2" then
		self:removeGUID(boss2GUID)
		self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		
	elseif boss3GUID and unitID == "boss3" then
		self:removeGUID(boss3GUID)
		self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		
	elseif boss4GUID and unitID == "boss4" then
		self:removeGUID(boss4GUID)
		self:UnregisterEvent("UNIT_TARGETABLE_CHANGED")
		
	end
end

function CS:beastlordFix()
	if not UnitExists("boss1") then
		self:removeGUID(boss1GUID)
	end
end

local function blastFurnaceFix(self, event, sourceGUID, destGUID, spellID)
	if spellID == 605 and event == "SPELL_CAST_SUCCESS" then
		self:removeGUID(destGUID)
	end
end

function CS:hansgarAndFranzokFix()
	if not UnitExists("boss1") then
		self:removeGUID(boss1GUID)
	
	elseif not UnitExists("boss2") then
		self:removeGUID(boss2GUID)
	
	end
end

local function flamebenderFix(self, event, sourceGUID, destGUID, spellID)
	if spellID == 181089 then
		self:removeGUID(sourceGUID)
	end
end

local function ironMaidensTimer(GUID)
	C_TimerAfter(3, function()
		CS:removeGUID(GUID)
	end)
end

function CS:ironMaidensFix(_, message, sender)
	if message:find(L["IronMaidensShipMessage"]) then
		if sender == boss1Name then
			ironMaidensTimer(boss1GUID)
			
		elseif sender == boss2Name then
			ironMaidensTimer(boss2GUID)
			
		elseif sender == boss3Name then
			ironMaidensTimer(boss3GUID)
			
		end
	end
end

--[[
-- debug
function CS:alysrazorFix(_, message, sender)

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
end
]]--

function CS:ENCOUNTER_START(_, encounterID, encounterName, difficultyID, raidSize)
	
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
					self:RegisterEvent("UNIT_TARGETABLE_CHANGED", "hellfireAssaultFix")
				end
			end
		end)
		
		
	elseif encounterID == 1689 then  -- Flamebender
		self.encounterFix = flamebenderFix
		
		
	elseif encounterID == 1690 then  -- Blast Furnace
		self.encounterFix = blastFurnaceFix
		
		
	elseif encounterID == 1693 then  -- Hans'gar and Franzok
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			boss1GUID = UnitGUID("boss1")
			boss2GUID = UnitGUID("boss2")
			if boss2GUID and boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
			end
		end)
		self:RegisterEvent("UNIT_TARGETABLE_CHANGED", "hansgarAndFranzokFix")
		
		
	elseif encounterID == 1694 then  -- Beastlord Darmac
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", function()
			boss1GUID = UnitGUID("boss1")
			if boss1GUID then
				self:UnregisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
				self:RegisterEvent("UNIT_TARGETABLE_CHANGED", "beastlordFix")
			end
		end)
		
		
	elseif encounterID == 1695 then  -- Iron Maidens
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
			end
		end)
		boss1Name = EJ_GetSectionInfo(10033)  -- Marak
		boss2Name = EJ_GetSectionInfo(10030)  -- Sorka
		boss3Name = EJ_GetSectionInfo(10025)  -- Ga'ran
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "ironMaidensFix")
		
		
		--[[
		-- debug
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
		self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "alysrazorFix")
		]]--
		
	end
	
end

function CS:ENCOUNTER_END()
	self.encounterFix = function() end
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