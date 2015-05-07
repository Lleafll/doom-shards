--@debug@

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


-- Variables
local db
local height
local width
local backdrop = {
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
		local orbFrame = orbFrames[i]
		if orbs >= i then
			orbFrame:SetXScale(1)
			orbFrame:Show()
		else
			local timerID = timers[k]
			if timerID then
				currentTime = currentTime or GetTime()
				local remaining = mathmax(0, timerID.impactTime - currentTime)
				orbFrame:SetXScale(1 - remaining / 10)
				orbFrame:Show()
				k = k + 1
			else
				orbFrame:Hide()
			end
		end
	end
end

local function SetXScale(self, scale)
	self:SetWidth(width * scale)
end

local function createFrames()
	local orientation = db.orientation
	local growthDirection = db.growthDirection
	local flags = db.fontFlags
	local stringXOffset = db.stringXOffset
	local stringYOffset = db.stringYOffset
	
	if growthDirection == "Reversed" then
		stringXOffset = -1 * stringXOffset
	end
	
	local function createOrbFrame(numeration)
		local frame = orbFrames[numeration] or CreateFrame("frame", nil, timerFrame)
		frame:ClearAllPoints()
		if orientation == "Vertical" then
			local displacement = (height + db.spacing) * (numeration - 1)
			frame:SetHeight(height)
			frame:SetWidth(width)
			if growthDirection == "Reversed" then
				frame:SetPoint("TOPRIGHT", 0, -displacement)
			else
				frame:SetPoint("BOTTOMRIGHT", 0, displacement)
			end
		else
			local displacement = (width + db.spacing) * (numeration - 1)
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
		
		frame.SetXScale = SetXScale
		
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
	orbFrames[6]:SetBackdropColor(c2r, c2b, c2g, c2a)  -- dummy frame to anchor overflow bar to
end

local function ShowChildren()
	for i = 1, 5 do
		orbFrames[i]:SetXScale(1)
		orbFrames[i]:Show()
	end
end

local function HideChildren()
	for i = 1, 6 do
		orbFrames[i]:Hide()
	end
	RegisterStateDriver(timerFrame, "visibility", "")
end

CS.displayBuilders["Integrated"] = function(self)
	db = self.db.complex
	
	height = db.orientation == "Vertical" and db.width or db.height
	width = db.orientation == "Vertical" and db.height or db.width

	timerFrame:SetHeight(db.orientation == "Vertical" and (5 * height + 4 * db.spacing) or (height + 25))
	timerFrame:SetWidth(db.orientation == "Vertical" and (width + 25) or (5 * width + 4 * db.spacing))
	
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	if timerFrame.lock then
		RegisterStateDriver(timerFrame, "visibility", db.visibilityConditionals)
	end
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = ShowChildren
	timerFrame.HideChildren = HideChildren
	
	self.needsFrequentUpdates = true
end

--@end-debug@