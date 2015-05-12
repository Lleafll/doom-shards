-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local CD = CS:NewModule("complex", "AceEvent-3.0")


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Upvalues
local GetTime = GetTime
local mathmax = math.max
local stringformat = string.format


-- Frames
local CDFrame = CS:CreateParentFrame("CS Complex Display", "complex")
CD.frame = CDFrame
local orbFrames = {}
local fontStringParent
local SATimers = {}
local statusbars = {}


-- Variables
local db
local textEnable
local statusbarEnable
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local statusbarMaxTime
local orbCappedEnable
local backdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1
}


-- Functions
function CD:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
	local k = 1
	for i = 1, 6 do
		if orbs >= i then
			local orbFrame = orbFrames[i]
			if orbCappedEnable and orbs == 5 then
				orbFrame:SetOrbCapColor()
			elseif orbFrame.orbCapColored then
				orbFrame:SetOriginalColor()
			end
			orbFrame:Show()
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

function CD:Unlock()
	if not UnitAffectingCombat("player") then RegisterStateDriver(CDFrame, "visibility", "") end
	
	for i = 1, 6 do
		if textEnable then
			SATimers[i]:Show()
		end
		if statusbarEnable and (db.statusbarXOffset ~= 0 or db.statusbarYOffset ~= 0) then
			statusbars[i].statusbar:SetValue(statusbarMaxTime / 2)
			statusbars[i]:Show()
		end
		
		if i == 6 then break end
		
		orbFrames[i]:Show()
	end
end

function CD:Lock()
	for i = 1, 6 do
		orbFrames[i]:Hide()
		if SATimers[i] then SATimers[i]:Hide() end
		if statusbars[i] then statusbars[i]:Hide() end
	end
	
	if not UnitAffectingCombat("player") then RegisterStateDriver(CDFrame, db.visibilityConditionals) end
end

local function buildFrames()
	local orientation = db.orientation
	local growthDirection = db.growthDirection
	local height = db.height
	local width = db.width
	local flags = db.fontFlags
	local stringXOffset = db.stringXOffset
	local stringYOffset = db.stringYOffset
	local statusbarXOffset = db.statusbarXOffset
	local statusbarYOffset = db.statusbarYOffset
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	local CDFrameHeight = db.height + 25
	local CDFrameWidth = 5 * db.width + 4 * db.spacing
	CDFrame:SetPoint("CENTER", db.posX, db.posY)
	CDFrame:SetScale(CS.db.scale)
	CDFrame:SetHeight(db.orientation == "Vertical" and CDFrameWidth or CDFrameHeight)
	CDFrame:SetWidth(db.orientation == "Vertical" and CDFrameHeight or CDFrameWidth)
	
	if growthDirection == "Reversed" then
		stringXOffset = -1 * stringXOffset
	end
	
	do
		local function createOrbFrame(numeration)
			local frame = orbFrames[numeration] or CreateFrame("frame", nil, CDFrame)
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
			
			local c1r, c1b, c1g, c1a = db.color1.r, db.color1.b, db.color1.g, db.color1.a 
			local c2r, c2b, c2g, c2a = db.color2.r, db.color2.b, db.color2.g, db.color2.a 
			if numeration < 4 then
				function frame:SetOriginalColor()
					self:SetBackdropColor(c1r, c1b, c1g, c1a)
				end
				frame:SetOriginalColor()
			elseif numeration < 6 then
				function frame:SetOriginalColor()
					self:SetBackdropColor(c2r, c2b, c2g, c2a)
					self.orbCapColored = false
				end
				frame:SetOriginalColor()
			else
				frame:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to
			end
			local c1r, c1b, c1, c1a = db.orbCappedColor.r, db.orbCappedColor.b, db.orbCappedColor.g, db.orbCappedColor.a
			function frame:SetOrbCapColor()
				self:SetBackdropColor(c1r, c1b, c1, c1a)
				self.orbCapColored = true
			end
			
			return frame
		end
		for i = 1, 6 do
			orbFrames[i] = createOrbFrame(i)
		end
	end
	
	if textEnable then
		fontStringParent = fontStringParent or CreateFrame("frame", nil, CDFrame)
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
			fontString:SetFont(LSM:Fetch("font", db.fontName), db.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
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
				frame = CreateFrame("Frame", nil, CDFrame)
				statusbar = CreateFrame("StatusBar", nil, frame)
				frame.statusbar = statusbar
			end
			frame:ClearAllPoints()
			if orientation == "Vertical" then
				frame:SetPoint("BOTTOMRIGHT", referenceFrame, -statusbarYOffset, statusbarXOffset)
				frame:SetPoint("TOPLEFT", referenceFrame, -statusbarYOffset, statusbarXOffset)
			else
				frame:SetPoint("BOTTOMRIGHT", referenceFrame, statusbarXOffset, statusbarYOffset)
				frame:SetPoint("TOPLEFT", referenceFrame, statusbarXOffset, statusbarYOffset)
			end
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

function CD:Build()
	statusbarMaxTime = db.maxTime
	textEnable = db.textEnable
	statusbarEnable = db.statusbarEnable
	orbCappedEnable = db.orbCappedEnable
	
	buildFrames()
	
	if CS.locked and not UnitAffectingCombat("player") then
		RegisterStateDriver(CDFrame, "visibility", db.visibilityConditionals)
	end
	if textEnable then CS:SetUpdateInterval(0.1) end
	if statusbarEnable then CS:SetUpdateInterval(statusbarMaxTime / db.width / CS.db.scale) end
end

function CD:OnInitialize()
	db = CS.db.complex
end

function CD:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function CD:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	CDFrame:Hide()
end