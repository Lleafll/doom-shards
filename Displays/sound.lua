-- Get addon Object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local SO = CS:NewModule("sound")


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
function SO:CONSPICUOUS_SPIRITS_UPDATE(orbs, timers)
	if GetTime() - lastTime >= soundInterval then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile(soundFile, "Master")
			lastTime = GetTime()
		end
	end
end

CS.displayBuilders["Sound"] = function(self)
	soundFile = LSM:Fetch("sound", self.db.soundHandle)
	soundInterval = self.db.soundInterval
	
	self:SetUpdateInterval(0.1)
end

function SO:PLAYER_REGEN_DISABLED()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function SO:PLAYER_REGEN_ENABLED()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function SO:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end

function SO:OnDisable()
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end