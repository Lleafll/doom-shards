local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Get Addon object
local ASTimer = LibStub("AceAddon-3.0"):GetAddon("AS Timer")


-- Upvalues
local GetTime, PlaySoundFile = GetTime, PlaySoundFile


-- Variables
local lastTime = GetTime()


-- Functions
function ASTimer:warningSound(orbs, timers)
	if GetTime() - lastTime >= 2 then
		if orbs >= 3 and orbs + (#timers or 0) >= 5 then
			PlaySoundFile("Interface\\addons\\AS_Timer\\Media\\ASTimerDroplet.mp3", "Master")
			lastTime = GetTime()
		end
	end
end