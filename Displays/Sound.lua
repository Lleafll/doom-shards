----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-------------------
-- Create module --
-------------------
local WS = CS:NewModule("warningSound", "AceEvent-3.0")  -- can't use sound since it's a legacy option :/


---------------
-- Libraries --
---------------
local LSM = LibStub("LibSharedMedia-3.0")


--------------
-- Upvalues --
--------------
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile


------------
-- Frames --
------------
local WSFrame = CS:CreateParentFrame("CS Sound Display", "sound")  -- only used for OnUpdate
WSFrame:Hide()


---------------
-- Variables --
---------------
local counter = 0
local isOverOrbThreshold  -- boolean to play sound
local soundFile
local soundInterval


---------------
-- Functions --
---------------
function WS:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
	isOverOrbThreshold = orbs >= 3 and orbs + (#timers or 0) >= 5
end

WSFrame:SetScript("OnUpdate", function(frame, elapsed)
	counter = counter - elapsed
	if counter <= 0 and isOverOrbThreshold then
		PlaySoundFile(soundFile, "Master")
		counter = soundInterval
	end
end)

function WS:PLAYER_REGEN_DISABLED()
	WSFrame:Show()
end

function WS:PLAYER_REGEN_ENABLED()
	WSFrame:Hide()
end

function WS:Build()
	soundFile = LSM:Fetch("sound", CS.db.warningSound.soundHandle)
	soundInterval = CS.db.warningSound.soundInterval
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