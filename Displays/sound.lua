-- Get addon Object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local SO = CS:NewModule("warningSound", "AceEvent-3.0")  -- can't use sound since it's a legacy option :/


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Upvalues
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile


-- Variables
local lastTime = 0
local soundFile
local soundInterval


-- Functions
function SO:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
	if GetTime() - lastTime >= soundInterval then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile(soundFile, "Master")
			lastTime = GetTime()
		end
	end
end

function SO:PLAYER_REGEN_DISABLED()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function SO:PLAYER_REGEN_ENABLED()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function SO:OnEnable()
	soundFile = LSM:Fetch("sound", CS.db.warningSound.soundHandle)
	soundInterval = CS.db.warningSound.soundInterval
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	CS:SetUpdateInterval(0.1)
end

function SO:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end