local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Get Addon object
local ASTimer = LibStub("AceAddon-3.0"):GetAddon("AS Timer")


-- Upvalues
local stringformat = string.format


-- Frames
local timerFrame = ASTimer.frame
local timerText


-- Variables
local timerID
local maxToleratedTime = 10
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local color1 = {r=0.53, b=0.53, g=0.53, a=1.00}  -- lowest threshold color
local color2 = {r=0.38, b=0.23, g=0.51, a=1.00}  -- middle threshold color
local color3 = {r=0.51, b=0.00, g=0.24, a=1.00}  -- highest threshold color


-- Functions
local function refreshDisplay(orbs, timers)
	local short = 0
	local long = 0
	for i = 1, #timers do
		timerID = timers[i]
		if timerID then
			local timeLeft = ASTimer:TimeLeft(timerID)
			if timeLeft > 0 then
				local travelTime = timerID.travelTime
				local remaining = timeLeft - maxToleratedTime + travelTime
				if remaining < remainingThreshold then
					short = short + 1
				else
					long = long + 1
				end
			end
		else
			break
		end
	end
	local text = stringformat("%s  %s", short, long)
	timerText:SetText(text)
	
	if orbs >= 3 and short + long > 0 and ((short + orbs >= 5) or (short + long + orbs >= 6)) then
		timerFrame:Show()
		timerFrame:SetBackdropColor(color3.r, color3.b, color3.g, color3.a)
	elseif short > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(color2.r, color2.b, color2.g, color2.a)
	elseif long > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(color1.r, color1.b, color1.g, color1.a)
	else
		timerFrame:Hide()
	end
end

local function createFrames()
	timerFrame:SetBackdrop({
		bgFile="Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
		tile=true,
		tileSize=5,
		edgeSize= 1
	})
	timerFrame:SetBackdropColor(0.53, 0.53, 0.53)
	timerFrame:SetBackdropBorderColor(0, 0, 0, 1)

	if not timerText then timerText = timerFrame:CreateFontString(nil, "OVERLAY") end
	timerText:Show()
	timerText:SetFont("Fonts\\FRIZQT__.TTF", 15)
	timerText:SetTextColor(1, 1, 1, 1)
	timerText:SetShadowOffset(1, -1)
	timerText:SetShadowColor(0, 0, 0, 1)
	timerText:SetPoint("CENTER")
	timerText:SetText("0  0")
end

local function HideChildren()
	timerFrame:SetBackdropColor(1, 1, 1, 0)
	timerFrame:SetBackdropBorderColor(0, 0, 0, 0)
	timerText:Hide()
end

function ASTimer:initializeSimple()
	timerFrame:SetWidth(65)
	timerFrame:SetHeight(33)
	createFrames()
	function ASTimer:refreshDisplay(orbs, timers) refreshDisplay(orbs, timers) end
	function timerFrame:HideChildren() HideChildren() end
end