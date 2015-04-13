-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
local GetTime = GetTime
local stringformat = string.format


-- Frames
local timerFrame = CS.frame
local timerTextShort
local timerTextLong


-- Variables
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions


-- Functions
local function refreshDisplay(orbs, timers)
	local currentTime
	local short = 0
	local long = 0
	for i = 1, #timers do
		timerID = timers[i]
		if timerID then
			currentTime = currentTime or GetTime()
			local remaining = timerID.impactTime - currentTime
			if remaining < remainingThreshold then
				short = short + 1
			else
				long = long + 1
			end
		else
			break
		end
	end
	timerTextShort:SetText(short)
	timerTextLong:SetText(long)
	
	if orbs >= 3 and short + long > 0 and ((short + orbs >= 5) or (short + long + orbs >= 6)) then
		timerFrame:Show()
		timerFrame:SetBackdropColor(CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a)
	elseif short > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(CS.db.simple.color2.r, CS.db.simple.color2.b, CS.db.simple.color2.g, CS.db.simple.color2.a)
	elseif long > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a)
	else
		timerFrame:Hide()
	end
end

local function createFrames()
	local spacing = CS.db.simple.spacing / 2
	
	timerFrame:SetBackdrop({
		bgFile="Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
		tile=true,
		tileSize=5,
		edgeSize= 1
	})
	timerFrame:SetBackdropColor(CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a)
	timerFrame:SetBackdropBorderColor(0, 0, 0, 1)
	
	local function setTimerText(fontstring)
		fontstring:Show()
		fontstring:SetFont("Fonts\\FRIZQT__.TTF", CS.db.simple.fontSize)
		fontstring:SetTextColor(1, 1, 1, 1)
		fontstring:SetShadowOffset(1, -1)
		fontstring:SetShadowColor(0, 0, 0, 1)
		fontstring:SetText("0")
	end
	
	if not timerTextShort then timerTextShort = timerFrame:CreateFontString(nil, "OVERLAY") end
	timerTextShort:SetPoint("CENTER", -spacing, 0)
	setTimerText(timerTextShort)
	
	if not timerTextLong then timerTextLong = timerFrame:CreateFontString(nil, "OVERLAY") end
	timerTextLong:SetPoint("CENTER", spacing, 0)
	setTimerText(timerTextLong)
end

local function HideChildren()
	timerFrame:SetBackdropColor(1, 1, 1, 0)
	timerFrame:SetBackdropBorderColor(0, 0, 0, 0)
	timerTextShort:Hide()
	timerTextLong:Hide()
end

function CS:initializeSimple()
	timerFrame:SetHeight(self.db.simple.height)
	timerFrame:SetWidth(self.db.simple.width)
	createFrames()
	function CS:refreshDisplay(orbs, timers) refreshDisplay(orbs, timers) end
	function timerFrame:ShowChildren() end
	function timerFrame:HideChildren() HideChildren() end
end