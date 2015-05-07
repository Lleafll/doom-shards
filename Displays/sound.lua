-- Get Addon Object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


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
function CS:warningSound(orbs, timers)
	if GetTime() - lastTime >= soundInterval then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile(soundFile, "Master")
			lastTime = GetTime()
		end
	end
end

function CS:initializeSound()
	soundFile = LSM:Fetch("sound", self.db.soundHandle)
	soundInterval = self.db.soundInterval
	
	self.needsFrequentUpdates = true
end