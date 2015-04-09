local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits")


-- Upvalues
local GetTime, PlaySoundFile = GetTime, PlaySoundFile


-- Variables
local lastTime = GetTime()


-- Functions
function CS:warningSound(orbs, timers)
	if GetTime() - lastTime >= 2 then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile("Interface\\addons\\ConspicuousSpirits\\Media\\CSDroplet.mp3", "Master")
			lastTime = GetTime()
		end
	end
end