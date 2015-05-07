--@debug@

-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Module
CS.displayBuilders["Integrated"] = "initializeIntegrated"


-- Options
CS.optionsTable.args.integrated = {
	order = 3,
	type = "group",
	name = L["Integrated Display"],
	cmdHidden  = true,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function()
				return CS.db.display == "Integrated"
			end,
			set = function(info, val)
				if val then CS.db.display = "Integrated" end
				CS:Initialize()
			end
		}
	}
}

CS.defaultSettings.global.integrated = {
	
}


-- Upvalues
local GetTime = GetTime
local mathmax = math.max
local stringformat = string.format


-- Frames
local timerFrame = CS.frame
local orbFrames = {}
local animations = {}


-- Variables
local db
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
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
		if orbs >= i then
			orbFrames[i]:Show()
			animations[i]:Stop()
		else
			timerID = timers[k]
			local animation = animations[i]
			if timerID then
				orbFrames[i]:Show()
				currentTime = currentTime or GetTime()
				local remaining = mathmax(0, timerID.impactTime - currentTime)
				animation:SetFromScale(1 - remaining / 10, 1)
				animation:SetDuration(remaining)
				animation:Play()
				k = k + 1
			else
				orbFrames[i]:Hide()
				animation:Stop()
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

	local function createAnimationBars(referenceFrame, numeration)
		local animation = animations[numeration] or referenceFrame:CreateAnimationGroup():CreateAnimation("Scale")
		animation:SetOrigin("LEFT", 0, 0)
		animation:SetSmoothing("NONE")  -- necessary?
		animation:SetFromScale(0, 1)
		animation:SetToScale(1, 1)
		return animation
	end
	for i = 1, 6 do
		animations[i] = createTimerFontString(orbFrames[i], i)
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
		orbFrames[i]:Show()
		animations[i]:Hide()
	end
	animations[6]:Show()
end

local function HideChildren()
	for i = 1, 6 do
		orbFrames[i]:Hide()
		animations[i]:Hide()
	end
	RegisterStateDriver(timerFrame, "visibility", "")
end

function CS:initializeIntegrated()
	db = self.db.complex
	local height = db.height + 25
	local width = 5 * db.width + 4 * db.spacing

	timerFrame:SetHeight(db.orientation == "Vertical" and width or height)
	timerFrame:SetWidth(db.orientation == "Vertical" and height or width)
	
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	if timerFrame.lock then
		RegisterStateDriver(timerFrame, "visibility", db.visibilityConditionals)
	end
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = ShowChildren
	timerFrame.HideChildren = HideChildren
	
	self.needsFrequentUpdates = false
end

--@end-debug@