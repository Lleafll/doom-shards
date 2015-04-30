-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Upvalues
local GetTime = GetTime
local mathmax = math.max
local stringformat = string.format


-- Frames
local timerFrame = CS.frame
local orbFrames = {}
local SATimers = {}


-- Variables
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local frame
local fontPath
local fontString


-- Functions
local function refreshDisplay(self, orbs, timers)
	local currentTime
	local k = 1
	for i = 1, 6 do
		if orbs >= i then
			orbFrames[i]:Show()
			SATimers[i]:Hide()
		else
			orbFrames[i]:Hide()
			timerID = timers[k]
			if timerID then
				SATimers[i]:Show()
				currentTime = currentTime or GetTime()
				local remaining = mathmax(0, timerID.impactTime - currentTime)
				if remaining < remainingThreshold then
					SATimers[i]:SetText(stringformat("%.1f", remaining))
				else
					SATimers[i]:SetText(stringformat("%.0f", remaining))
				end
				k = k + 1
			else
				SATimers[i]:Hide()
			end
		end
	end
end

local function createFrames()
	local spacing = CS.db.complex.spacing
	local height = CS.db.complex.height
	local width = CS.db.complex.width
	local function createOrbFrame(number)
		frame = orbFrames[number] or CreateFrame("frame", nil, timerFrame)
		frame:SetPoint("BOTTOMLEFT", (width + spacing) * (number - 1), 0)
		frame:SetHeight(height)
		frame:SetWidth(width)
		frame:SetBackdrop({
			bgFile="Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
			tile=true,
			tileSize=5,
			edgeSize= 1
		})
		frame:SetBackdropBorderColor(0, 0, 0, 1)
		if number < 6 then
			frame:Show()
		else
			frame:Hide()
		end
		return frame
	end
	for i = 1, 6 do
		orbFrames[i] = createOrbFrame(i)
	end

	local function createTimerFontString(referenceFrame, number)
		local flags = CS.db.complex.fontFlags
		fontString = SATimers[number] or timerFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetPoint("BOTTOM", referenceFrame, "TOP", CS.db.complex.stringXOffset, CS.db.complex.stringYOffset + 1)
		fontString:SetFont(fontPath, CS.db.complex.fontSize, flags == "MONOCHROMEOUTLINE" and "MONOCHROME, OUTLINE" or (flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or "")
		fontString:SetTextColor(CS.db.complex.fontColor.r, CS.db.complex.fontColor.b, CS.db.complex.fontColor.g, CS.db.complex.fontColor.a)
		fontString:SetShadowOffset(1, -1)
		fontString:SetShadowColor(0, 0, 0, CS.db.complex.fontFlags == "Shadow" and 1 or 0)
		fontString:Show()
		fontString:SetText("0.0")
		return fontString
	end
	for i = 1, 6 do
		SATimers[i] = createTimerFontString(orbFrames[i], i)
	end
	
	local c1r, c1b, c1g, c1a = CS.db.complex.color1.r, CS.db.complex.color1.b, CS.db.complex.color1.g, CS.db.complex.color1.a 
	local c2r, c2b, c2g, c2a = CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a 
	orbFrames[1]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[2]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[3]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[4]:SetBackdropColor(c2r, c2b, c2g, c2a)
	orbFrames[5]:SetBackdropColor(c2r, c2b, c2g, c2a)
	orbFrames[6]:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to
end

local function ShowChildren()
	for i = 1, 5 do
		orbFrames[i]:Show()
		SATimers[i]:Show()
	end
	SATimers[6]:Show()
end

local function HideChildren()
	for i = 1, 6 do
		orbFrames[i]:Hide()
		SATimers[i]:Hide()
	end
	RegisterStateDriver(timerFrame, "visibility", "")
end

function CS:initializeComplex()
	timerFrame:SetHeight(self.db.complex.height + 25)
	timerFrame:SetWidth(5 * self.db.complex.width + 4 * self.db.complex.spacing)
	fontPath = LSM:Fetch("font", CS.db.complex.fontName)
	createFrames()
	if timerFrame.lock then
		RegisterStateDriver(timerFrame, "visibility", CS.db.complex.visibilityConditionals)
	end
	CS.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = ShowChildren
	timerFrame.HideChildren = HideChildren
end