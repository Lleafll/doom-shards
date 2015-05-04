-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("statusbar", "Droplet", "Interface\\addons\\ConspicuousSpirits\\Media\\Orbs_noborder.tga")


-- Upvalues
local GetTime = GetTime
local mathmax = math.max
local stringformat = string.format


-- Frames
local timerFrame = CS.frame
local orbFrames = {}
local SATimers = {}


-- Variables
local db
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local frame
local fontPath
local fontString
local backdropTable = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1
}


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
	local orientation = db.orientation
	local growthDirection = db.growthDirection
	local height = db.height
	local width = db.width
	local flags = db.fontFlags
	
	local function createOrbFrame(numeration)
		frame = orbFrames[numeration] or CreateFrame("frame", nil, timerFrame)
		frame:ClearAllPoints()
		local displacement = (width + db.spacing) * (numeration - 1)
		if orientation == "Vertical" then
			frame:SetHeight(width)
			frame:SetWidth(height)
			if growthDirection == "Reversed" then
				frame:SetPoint("TOPRIGHT", 0, -displacement)
			else
				frame:SetPoint("BOTTOMRIGHT", 0, displacement)
			end
		else
			frame:SetHeight(height)
			frame:SetWidth(width)
			if growthDirection == "Reversed" then
				frame:SetPoint("BOTTOMRIGHT", -displacement, 0)
			else
				frame:SetPoint("BOTTOMLEFT", displacement, 0)
			end
		end
		
		frame:SetBackdrop(backdropTable)
		frame:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
		if numeration < 6 then
			frame:Show()
		else
			frame:Hide()
		end
		return frame
	end
	for i = 1, 6 do
		orbFrames[i] = createOrbFrame(i)
	end

	local function createTimerFontString(referenceFrame, numeration)
		fontString = SATimers[numeration] or timerFrame:CreateFontString(nil, "OVERLAY")
		fontString:ClearAllPoints()
		if orientation == "Vertical" then
			fontString:SetPoint("RIGHT", referenceFrame, "LEFT", db.stringYOffset - 1, db.stringXOffset)
		else
			fontString:SetPoint("BOTTOM", referenceFrame, "TOP", db.stringXOffset, db.stringYOffset + 1)
		end
		fontString:SetFont(fontPath, db.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
		fontString:SetTextColor(db.fontColor.r, db.fontColor.b, db.fontColor.g, db.fontColor.a)
		fontString:SetShadowOffset(1, -1)
		fontString:SetShadowColor(0, 0, 0, db.fontFlags == "Shadow" and 1 or 0)
		fontString:Show()
		fontString:SetText("0.0")
		
		return fontString
	end
	for i = 1, 6 do
		SATimers[i] = createTimerFontString(orbFrames[i], i)
	end
	
	local c1r, c1b, c1g, c1a = db.color1.r, db.color1.b, db.color1.g, db.color1.a 
	local c2r, c2b, c2g, c2a = db.color2.r, db.color2.b, db.color2.g, db.color2.a 
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
	db = self.db.complex
	local height = db.height + 25
	local width = 5 * db.width + 4 * db.spacing

	timerFrame:SetHeight(db.orientation == "Vertical" and width or height)
	timerFrame:SetWidth(db.orientation == "Vertical" and height or width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	backdropTable.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	if timerFrame.lock then
		RegisterStateDriver(timerFrame, "visibility", db.visibilityConditionals)
	end
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = ShowChildren
	timerFrame.HideChildren = HideChildren
end