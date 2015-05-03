-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Upvalues
local GetTime = GetTime


-- Frames
local timerFrame = CS.frame
local timerTextShort
local timerTextLong


-- Variables
local fontPath
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local backdropTable = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize= 1
}


-- Functions
local function refreshDisplay(self, orbs, timers)
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
	
	if (orbs >= 3) and (short + long > 0) and ((short + orbs >= 5) or (short + long + orbs >= 6)) then
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
	
	timerFrame:SetBackdrop(backdropTable)
	timerFrame:SetBackdropColor(CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a)
	timerFrame:SetBackdropBorderColor(0, 0, 0, CS.db.simple.textureBorder and 1 or 0)
	
	local function setTimerText(fontstring)
		local flags = CS.db.simple.fontFlags
		fontstring:Show()
		fontstring:SetFont(fontPath, CS.db.simple.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
		fontstring:SetTextColor(CS.db.simple.fontColor.r, CS.db.simple.fontColor.b, CS.db.simple.fontColor.g, CS.db.simple.fontColor.a)
		fontstring:SetShadowOffset(1, -1)
		fontstring:SetShadowColor(0, 0, 0, flags == "Shadow" and 1 or 0)
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
	local db = self.db.simple

	timerFrame:SetHeight(db.height)
	timerFrame:SetWidth(db.width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	backdropTable.bgfile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = function() end
	timerFrame.HideChildren = HideChildren
end