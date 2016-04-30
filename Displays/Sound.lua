local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end

local WS = DS:NewModule("warningSound", "AceEvent-3.0")  -- can't use sound since it's a legacy option :/
local LSM = LibStub("LibSharedMedia-3.0")


--------------
-- Upvalues --
--------------
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile


------------
-- Frames --
------------
local WSFrame = DS:CreateParentFrame("DS Sound Display", "sound")  -- only used for OnUpdate
WSFrame:Hide()


---------------
-- Variables --
---------------
local db
local counter = 0
local isOverOrbThreshold  -- boolean to play sound
local soundFile
local soundInterval


--------------
-- API Call --
--------------
function DoomShards:SetSound(bool)
	if bool then
		if UnitAffectingCombat("player") then WSFrame:Show() end
	else
		WSFrame:Hide()
	end
end


---------------
-- Functions --
---------------
local function timersCount(timers)
	local count = 0
	for i = 1, #timers do
		count = count + (timers[i].IsGUIDInRange() and 1 or 0)
	end
	return count
end

do
	local previousOrbs = 0

	function WS:CONSPICUOUS_SPIRITS_UPDATE(_, updatedTimeStamp, updatedOrbs, updatedTimers, updatedNextTick, updatedDurations)
		-- reset sound timer when orbs were spent
		if updatedOrbs < previousOrbs then counter = 0 end
		previousOrbs = updatedOrbs
		
		isOverOrbThreshold = (updatedOrbs >= 3) and (updatedOrbs + timersCount(timers)) >= 5
	end
end

WSFrame:SetScript("OnUpdate", function(frame, elapsed)
	counter = counter - elapsed
	if counter <= 0 and isOverOrbThreshold then
		PlaySoundFile(soundFile, "Master")
		counter = soundInterval
	end
end)

function WS:PLAYER_REGEN_DISABLED()
	local _, instanceType = GetInstanceInfo()
	if instanceType == "party" and not IsInInstance() then instanceType = "none" end  -- fix for Garrisons
	if db.instances[instanceType] then WSFrame:Show() end
end

function WS:PLAYER_REGEN_ENABLED()
	WSFrame:Hide()
end

function WS:Build()
	soundFile = LSM:Fetch("sound", DS.db.warningSound.soundHandle)
	soundInterval = DS.db.warningSound.soundInterval
end

function WS:OnInitialize()
	db = DS.db.warningSound
end

function WS:OnEnable()
	if UnitAffectingCombat("player") then
		self:PLAYER_REGEN_DISABLED()
	end
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function WS:OnDisable()
	WSFrame:Hide()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end