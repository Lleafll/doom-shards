-- Get addon object
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
local fontStringParent
local SATimers = {}
local statusbars = {}


-- Variables
local db
local textEnable
local statusbarEnable
local fontPath
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local statusbarMaxTime
local backdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1
}
local statusbarBackdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1,
	insets = { left = 1, right = 1, top = 1, bottom = 1}
}


-- Functions
local function refreshDisplay(self, orbs, timers)
	local k = 1
	for i = 1, 6 do
		if orbs >= i then
			orbFrames[i]:Show()
			SATimers[i]:Hide()
			statusbars[i]:Hide()
		else
			orbFrames[i]:Hide()
			local timerID = timers[k]
			if timerID then
				SATimers[i]:Show()
				statusbars[i]:Show()
				local remaining = mathmax(0, timerID.impactTime - GetTime())
				if textEnable then
					if remaining < remainingThreshold then
						SATimers[i]:SetText(stringformat("%.1f", remaining))
					else
						SATimers[i]:SetText(stringformat("%.0f", remaining))
					end
				end
				if statusbarEnable then
					statusbars[i].statusbar:SetValue(statusbarMaxTime - remaining)
				end
				k = k + 1
			else
				SATimers[i]:Hide()
				statusbars[i]:Hide()
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
	local stringXOffset = db.stringXOffset
	local stringYOffset = db.stringYOffset
	
	if growthDirection == "Reversed" then
		stringXOffset = -1 * stringXOffset
	end
	
	local function createOrbFrame(numeration)
		local frame = orbFrames[numeration] or CreateFrame("frame", nil, timerFrame)
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
		
		frame:SetBackdrop(backdrop)
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
	
	local c1r, c1b, c1g, c1a = db.color1.r, db.color1.b, db.color1.g, db.color1.a 
	local c2r, c2b, c2g, c2a = db.color2.r, db.color2.b, db.color2.g, db.color2.a 
	orbFrames[1]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[2]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[3]:SetBackdropColor(c1r, c1b, c1g, c1a)
	orbFrames[4]:SetBackdropColor(c2r, c2b, c2g, c2a)
	orbFrames[5]:SetBackdropColor(c2r, c2b, c2g, c2a)
	orbFrames[6]:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to
	
	if textEnable then
		fontStringParent = fontStringParent or CreateFrame("frame", nil, timerFrame)
		fontStringParent:SetAllPoints()
		fontStringParent:SetFrameStrata("MEDIUM")
		fontStringParent:Show()
		local function createTimerFontString(referenceFrame, numeration)
			local fontString = SATimers[numeration] or fontStringParent:CreateFontString(nil, "OVERLAY")
			fontString:ClearAllPoints()
			if orientation == "Vertical" then
				fontString:SetPoint("RIGHT", referenceFrame, "LEFT", -stringYOffset - 1, stringXOffset)
			else
				fontString:SetPoint("BOTTOM", referenceFrame, "TOP", stringXOffset, stringYOffset + 1)
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
	end
	
	if statusbarEnable then
		local function createStatusBars(referenceFrame, numeration)
			local frame
			local statusbar
			if statusbars[numeration] then
				frame = statusbars[numeration]
				statusbar = frame.statusbar
			else
				frame = CreateFrame("Frame", nil, timerFrame)
				statusbar = CreateFrame("StatusBar", nil, frame)
				frame.statusbar = statusbar
			end
			frame:SetAllPoints(referenceFrame)
			frame:SetBackdrop(backdrop)
			frame:SetBackdropColor(db.statusbarColorBackground.r, db.statusbarColorBackground.b, db.statusbarColorBackground.g, db.statusbarColorBackground.a)
			frame:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
			
			statusbar:SetPoint("TOPLEFT", 1 , -1)  -- to properly display border
			statusbar:SetPoint("BOTTOMRIGHT", -1 , 1)
			statusbar:SetStatusBarTexture((db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle))
			statusbar:SetStatusBarColor(db.statusbarColor.r, db.statusbarColor.b, db.statusbarColor.g, db.statusbarColor.a)
			statusbar:SetMinMaxValues(0, statusbarMaxTime)
			statusbar:SetOrientation(orientation == "Vertical" and "VERTICAL" or "HORIZONTAL")
			statusbar:SetReverseFill(db.statusbarReverse)
			
			frame:Hide()		
			return frame
		end
		for i = 1, 6 do
			statusbars[i] = createStatusBars(orbFrames[i], i)
		end
		local c1r, c1b, c1g, c1a = db.statusbarColorBackground.r, db.statusbarColorBackground.b, db.statusbarColorBackground.g, db.statusbarColorBackground.a 
		local c2r, c2b, c2g, c2a = db.statusbarColorOverflow.r, db.statusbarColorOverflow.b, db.statusbarColorOverflow.g, db.statusbarColorOverflow.a 
		statusbars[1]:SetBackdropColor(c1r, c1b, c1g, c1a)
		statusbars[2]:SetBackdropColor(c1r, c1b, c1g, c1a)
		statusbars[3]:SetBackdropColor(c1r, c1b, c1g, c1a)
		statusbars[4]:SetBackdropColor(c1r, c1b, c1g, c1a)
		statusbars[5]:SetBackdropColor(c1r, c1b, c1g, c1a)
		statusbars[6]:SetBackdropColor(c2r, c2b, c2g, c2a)
	end
end

local function ShowChildren()
	for i = 1, 5 do
		orbFrames[i]:Show()
		if textEnable then SATimers[i]:Show() end
	end
	if textEnable then SATimers[6]:Show() end
end

local function HideChildren()
	for i = 1, 6 do
		orbFrames[i]:Hide()
		SATimers[i]:Hide()
		statusbars[i]:Hide()
	end
	if not UnitAffectingCombat("player") then RegisterStateDriver(timerFrame, "visibility", "") end
end

CS.displayBuilders["Complex"] = function(self)
	db = self.db.complex
	
	statusbarMaxTime = db.maxTime
	textEnable = db.textEnable
	statusbarEnable = db.statusbarEnable
	
	local height = db.height + 25
	local width = 5 * db.width + 4 * db.spacing

	timerFrame:SetHeight(db.orientation == "Vertical" and width or height)
	timerFrame:SetWidth(db.orientation == "Vertical" and height or width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	local bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	backdrop.bgFile = bgFile
	statusbarBackdrop.bgFile = bgFile
	
	createFrames()
	if timerFrame.lock and not UnitAffectingCombat("player") then
		RegisterStateDriver(timerFrame, "visibility", db.visibilityConditionals)
	end
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = ShowChildren
	timerFrame.HideChildren = HideChildren
	
	if db.textEnable then self:SetUpdateInterval(0.1) end
	if db.statusbarEnable then self:SetUpdateInterval(statusbarMaxTime / db.width) end
end