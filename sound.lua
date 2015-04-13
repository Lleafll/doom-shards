local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Libraries
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Droplet", "Interface\\addons\\ConspicuousSpirits\\Media\\CSDroplet.mp3")


-- Upvalues
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile


-- Variables
local lastTime = 0


-- Functions
function CS:warningSound(orbs, timers)
	if GetTime() - lastTime >= 2 then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile(CS.soundFile, "Master")
			lastTime = GetTime()
		end
	end
end

function CS:initializeSound()
	CS.soundFile = LSM:Fetch("sound", CS.db.soundHandle)
end