local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end

local CD = DS:NewModule("display", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


--------------
-- Upvalues --
--------------
local GetTime = GetTime
local mathmax = math.max
local stringformat = string.format


------------
-- Frames --
------------
local CDFrame = DS:CreateParentFrame("Doom Shards Display", "display")
CD.frame = CDFrame
CDFrame:Hide()
local resourceFrames = {}
local fontStringParent
local SATimers = {}
local statusbars = {}
local CDOnUpdateFrame = CreateFrame("frame", nil, UIParent)
CDOnUpdateFrame:Hide()


---------------
-- Constants --
---------------
local maxResource = 5
local backdrop = {
	bgFile = nil,
	edgeFile = nil,
	tile = false,
	edgeSize = 0
}
local statusbarBackdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1
}
local borderBackdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize = 1
}


---------------
-- Variables --
---------------
local db
local durations
local energizedShards
local nextTick
local resourceCappedEnable
local resource
local remainingTimeThreshold
local resourceFromCurrentCast
local resourceGainPrediction
local resourceSpendIncludeHoG
local resourceSpendPrediction
local resourceGeneration
local nextCast
local statusbarCount
local statusbarEnable
local statusbarRefresh
local textEnable
local timers
local timeStamp
local visibilityConditionals = ""


---------------
-- Functions --
---------------
do
	function CD:GetHoGCastingTime()  -- TODO: Cache to possibly improve performance
		_, _, _, castingTime = GetSpellInfo(105174)
		return (nextCast and (nextCast - GetTime()) or 0) + castingTime / 1000
	end
end

local function update()
	-- Shards
	local energizeThreshold = resource - energizedShards
	local spendThreshold = resource + ((resourceSpendPrediction and resourceGeneration < 0) and resourceGeneration or 0)
	for i = 1, statusbarCount do
		local resourceFrame = resourceFrames[i]
		if resource >= i then
			if i > spendThreshold then
				if not resourceFrame.spendColored then
					resourceFrame:SetSpendColor()
				end
			elseif resourceCappedEnable and (resource == maxResource) then
				if not resourceFrame.capColored then
					resourceFrame:SetCapColor()
				end
			elseif not resourceCappedEnable or (resource ~= maxResource) then
				if resourceFrame.capColored or resourceFrame.gainColored or resourceFrame.spendColored then
					resourceFrame:SetOriginalColor()
				end
			end
			resourceFrame:Show()
			if (i > energizeThreshold and resourceFrame.active) or (resourceFrame.active == false) then  -- TODO: pretty hacky  -- Explicitly don't check for nil
				resourceFrame.smoke:Show()
				resourceFrame.smoke.flasher:Play()
				resourceFrame.active = true
			end
			if resourceFrame.active == nil then  -- TODO: replace with more efficient solution?
				resourceFrame.active = true
			end
			if textEnable then
				SATimers[i]:Hide()
			end
			statusbars[i]:Hide()
			
		else
			resourceFrame:Hide()
			resourceFrame.active = false
			
		end
	end
	
	-- Show shard spending for doom prediction in timeframe of currently cast spender
	if resourceSpendIncludeHoG and nextCast and resource + resourceGeneration < 0 then
		additionalResources = - resource - resourceGeneration
		for t = 1, additionalResources do
			local GUID = timers[t]
			if GUID then
				local tick = nextTick[GUID]
				if tick < nextCast then
					local resourceFrame = resourceFrames[resource + t]
					resourceFrame:Show()
					resourceFrame:SetSpendColor()
				else
					break
				end
			end
		end
	end
	
	-- Doom prediction
	local k = resource + 1
	local t = 1
	local GUID = timers[t]
	local generatedResource = resourceGeneration > 0 and resourceGeneration
	local castEnd = (resourceGainPrediction and generatedResource) and nextCast or nil
	while (GUID or castEnd) and k <= statusbarCount do
		local tick = nextTick[GUID]
		if GUID and (not castEnd or (castEnd and tick < castEnd)) then
			if textEnable then
				local SATimer = SATimers[k]
				SATimer:Show()
				SATimer:SetTimer(tick)
			end
			if statusbarEnable then
				local statusbar = statusbars[k]
				statusbar:SetTimer(tick)
				if statusbar.gainColored then
					statusbar:SetOriginalColor()
				end
			end
			t = t + 1
			GUID = timers[t]
		else
			if textEnable then
				SATimers[k]:Hide()
			end
			if statusbarEnable then
				statusbars[k]:Hide()
			end
			local resourceFrame = resourceFrames[k]
			resourceFrame:Show()
			resourceFrame:SetGainColor()
			generatedResource = generatedResource - 1
			if generatedResource <= 0 then  -- Should never be lower than 0
				castEnd = nil
			end
		end
		
		k = k + 1
	end
	
	for m = k, statusbarCount do
		if textEnable then 
			SATimers[m]:Hide()
		end
		statusbars[m]:Hide()
	end
end

function CD:DOOM_SHARDS_UPDATE(_, ...)
	timeStamp = DS.timeStamp
	resource = DS.resource
	timers = DS.timers
	nextTick = DS.nextTick
	durations = DS.duration
	energizedShards = DS.energized
	resourceGeneration = DS.generating
	nextCast = DS.nextCast
	
	-- Debug
	print(resourceGeneration, nextCast)
	
	update()
end

local function SATimerOnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	self.remaining = self.remaining - elapsed
	if self.elapsed > 0.1 then
		local remaining = self.remaining
		if remaining < remainingTimeThreshold then
			self.fontString:SetText(stringformat("%.1f", remaining < 0 and 0 or remaining))
		else
			self.fontString:SetText(stringformat("%.0f", remaining))
		end
		if remaining < CD:GetHoGCastingTime() then
			if not self.fontString.hogColored then
				self.fontString:SetHoGColor()
			end
		else
			if self.fontString.hogColored then
				self.fontString:SetOriginalColor()
			end
		end
	end
end

local function statusbarOnUpdate(statusbar, elapsed)
	statusbar.remaining = statusbar.remaining - elapsed
	statusbar.elapsed = statusbar.elapsed + elapsed
	if statusbar.elapsed > statusbarRefresh then
		statusbar.statusbar:SetValue(statusbar.maxTime - (statusbar.remaining < 0 and 0 or statusbar.remaining))  -- check for < 0 necessary?
	end
end


----------------
-- Visibility --
----------------
do
	-- can't use RegisterStateDriver because Restricted Environment doesn't allow for animations
	local currentState = "hide"
	
	function CDOnUpdateFrame:EvaluateConditionals()
		local state = SecureCmdOptionParse(visibilityConditionals)
		if state ~= currentState then
			if state == "hide" then
				CDFrame.fader:Stop()
				CDFrame:Hide()
				currentState = "hide"
				
			elseif state == "fade" and currentState ~= "hide" then
				CDFrame.fader:Play()
				currentState = "hide"
				
			elseif state ~= "fade" then  -- show
				CDFrame.fader:Stop()
				CDFrame:Show()
				currentState = "show"
				
			end
		end
	end
	
	local ticker = 0
	CDOnUpdateFrame:SetScript("OnUpdate", function(self, elapsed)
		ticker = ticker + elapsed
		if ticker > 0.2 then
			self:EvaluateConditionals()			
			ticker = 0
		end
	end)
	
	CDOnUpdateFrame:SetScript("OnShow", function(self)
		currentState = nil
		self:EvaluateConditionals()
	end)
	
	CDOnUpdateFrame:SetScript("OnEvent", function(self)
		self:EvaluateConditionals()
	end)
	
	function CDOnUpdateFrame:RegisterEvents()
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
	end
	
	function CDOnUpdateFrame:UnregisterEvents()
		self:UnregisterAllEvents()
	end
end


----------------
-- Animations --
----------------
local function buildFader()
	CDFrame.fader = CDFrame:CreateAnimationGroup()
	CDFrame.fader:SetScript("OnFinished", function()
		CDFrame:SetAlpha(1)
		CDFrame:Hide()
	end)
	CDFrame.fader.fadeOut = CDFrame.fader:CreateAnimation("Alpha")
	CDFrame.fader.fadeOut:SetFromAlpha(1)
	CDFrame.fader.fadeOut:SetToAlpha(0)
	CDFrame.fader.fadeOut:SetSmoothing("IN")
end

local function buildFlasher(parentFrame)
	local smoke = parentFrame.smoke
	if not smoke then
		parentFrame.smoke = CreateFrame("frame", nil, parentFrame)
		smoke = parentFrame.smoke
		smoke:SetBackdrop(backdrop)
		smoke:SetBackdropColor(1, 1, 1, 1)
		smoke:SetAllPoints()
	end
	smoke:Hide()
	
	smoke.flasher = smoke:CreateAnimationGroup()
	smoke.flasher:SetScript("OnFinished", function()
		smoke:SetAlpha(0)
		smoke:Hide()
	end)
	
	smoke.flasher.start = smoke.flasher:CreateAnimation("Alpha")
	smoke.flasher.start:SetFromAlpha(0)
	smoke.flasher.start:SetToAlpha(0.5)
	smoke.flasher.start:SetDuration(0.2)
	smoke.flasher.start:SetOrder(1)
	
	smoke.flasher.out = smoke.flasher:CreateAnimation("Alpha")
	smoke.flasher.out:SetFromAlpha(0.5)
	smoke.flasher.out:SetToAlpha(0)
	smoke.flasher.out:SetDuration(0.3)
	smoke.flasher.out:SetOrder(2)
end


-------------
-- Visuals --
-------------
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
	backdrop.bgFile = (not db.useTexture or db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	statusbarBackdrop.bgFile = (not db.useTexture or db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	local CDFrameHeight = db.height + 25
	local CDFrameWidth = statusbarCount * db.width + (statusbarCount - 1) * db.spacing
	CDFrame:ClearAllPoints()
	CDFrame:SetPoint(db.anchor, _G[db.anchorFrame], db.posX, db.posY)
	CDFrame:SetScale(DS.db.scale)
	CDFrame:SetHeight(db.orientation == "Vertical" and CDFrameWidth or CDFrameHeight)
	CDFrame:SetWidth(db.orientation == "Vertical" and CDFrameHeight or CDFrameWidth)
	
	if growthDirection == "Reversed" then
		stringXOffset = -1 * stringXOffset
	end
	
	do
		local function createResourceFrame(numeration)
			local frame = resourceFrames[numeration] or CreateFrame("frame", nil, CDFrame)
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
			
			if numeration <= maxResource then
				frame:Show()
				
				if not frame.border then
					frame.border = CreateFrame("frame")
				end
				if db.alwaysShowBorders then
					frame.border:SetParent(CDFrame)
				else
					frame.border:SetParent(frame)
				end
				frame.border:SetAllPoints(frame)
				frame.border:SetBackdrop(borderBackdrop)
				frame.border:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
			else
				frame:Hide()
			end
			
			if numeration <= maxResource then
				local color = db["color"..numeration]
				local cr, cb, cg, ca = color.r, color.b, color.g, color.a
				function frame:SetOriginalColor()
					self:SetBackdropColor(cr, cb, cg, ca)
					self.capColored = false
					self.gainColored = false
					self.spendColored = false
				end
				frame:SetOriginalColor()
			else
				frame:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to
			end
			
			local c3r, c3b, c3g, c3a = db.resourceCappedColor.r, db.resourceCappedColor.b, db.resourceCappedColor.g, db.resourceCappedColor.a
			function frame:SetCapColor()
				self:SetBackdropColor(c3r, c3b, c3g, c3a)
				self.capColored = true
				self.gainColored = false
				self.spendColored = false
			end
			
			local c4r, c4b, c4g, c4a = db.resourceSpendColor.r, db.resourceSpendColor.b, db.resourceSpendColor.g, db.resourceSpendColor.a
			function frame:SetSpendColor()
				self:SetBackdropColor(c4r, c4b, c4g, c4a)
				self.spendColored = true
				self.capColored = false
				self.gainColored = false
			end
			
			local c5r, c5b, c5g, c5a = db.resourceGainColor.r, db.resourceGainColor.b, db.resourceGainColor.g, db.resourceGainColor.a
			function frame:SetGainColor()
				self:SetBackdropColor(c5r, c5b, c5g, c5a)
				self.gainColored = true
				self.capColored = false
				self.spendColored = false
			end
			
			if db.gainFlash then
				buildFlasher(frame)
			end
			
			return frame
		end
		for i = 1, statusbarCount do
			resourceFrames[i] = createResourceFrame(i)
		end
	end
	
	if textEnable then
		local function createTimerFontString(referenceFrame, numeration)
			local parentFrame
			local fontString
			if not SATimers[numeration] then
				parentFrame = SATimers[numeration] or CreateFrame("frame", nil, CDFrame)
				parentFrame:SetFrameStrata("MEDIUM")
				parentFrame:Show()
				fontString = parentFrame:CreateFontString(nil, "OVERLAY")
				parentFrame.fontString = fontString
			else
				parentFrame = SATimers[numeration]
				fontString = parentFrame.fontString
			end
			
			fontString:ClearAllPoints()
			if orientation == "Vertical" then
				fontString:SetPoint("RIGHT", referenceFrame, "LEFT", -stringYOffset - 1, stringXOffset)
			else
				fontString:SetPoint("BOTTOM", referenceFrame, "TOP", stringXOffset, stringYOffset + 1)
			end
			fontString:SetFont(LSM:Fetch("font", db.fontName), db.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
			fontString:SetShadowOffset(1, -1)
			fontString:SetShadowColor(0, 0, 0, db.fontFlags == "Shadow" and 1 or 0)
			
			local c1r, c1b, c1g, c1a = db.fontColor.r, db.fontColor.b, db.fontColor.g, db.fontColor.a
			function fontString:SetOriginalColor()
				self:SetTextColor(c1r, c1b, c1g, c1a)
				self.hogColored = false
			end
			local c2r, c2b, c2g, c2a = db.fontColorHoGPrediction.r, db.fontColorHoGPrediction.b, db.fontColorHoGPrediction.g, db.fontColorHoGPrediction.a
			function fontString:SetHoGColor()
				self:SetTextColor(c2r, c2b, c2g, c2a)
				self.hogColored = true
			end
			
			parentFrame.elapsed = 0
			parentFrame.remaining = 0
			function parentFrame:SetTimer(tick)
				self.remaining = tick - GetTime()
				self.elapsed = 1
				self:Show()
			end
			parentFrame:SetScript("OnUpdate", SATimerOnUpdate)  -- only triggers when frame is shown
			
			fontString:SetText("0.0")
			fontString:SetOriginalColor()
			fontString:Show()
			return parentFrame
		end
		for i = 1, statusbarCount do
			SATimers[i] = createTimerFontString(resourceFrames[i], i)
			SATimers[i]:Show()
		end
		if #SATimers > statusbarCount then
			for i = statusbarCount + 1, #SATimers do
				SATimers[i]:Hide()
			end
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
			frame:SetBackdrop(statusbarBackdrop)
			frame:SetBackdropColor(db.statusbarColorBackground.r, db.statusbarColorBackground.b, db.statusbarColorBackground.g, db.statusbarColorBackground.a)
			frame:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
			
			statusbar:SetPoint("TOPLEFT", 1 , -1)  -- to properly display border
			statusbar:SetPoint("BOTTOMRIGHT", -1 , 1)
			statusbar:SetStatusBarTexture((not db.useTexture or db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle))
			statusbar:SetStatusBarColor(db.statusbarColor.r, db.statusbarColor.b, db.statusbarColor.g, db.statusbarColor.a)
			statusbar:SetMinMaxValues(0, 20)
			statusbar:SetOrientation(orientation == "Vertical" and "VERTICAL" or "HORIZONTAL")
			statusbar:SetReverseFill(db.statusbarReverse)
			
			frame.remaining = 0
			frame.elapsed = 0
			frame.maxTime = 20
			function frame:SetTimer(tick)
				self.elapsed = 1
				self.remaining = tick - GetTime()
				self.maxTime = DS:GetDoomDuration()
				self.statusbar:SetMinMaxValues(0, self.maxTime)
				self:Show()
			end
			frame:SetScript("OnUpdate", statusbarOnUpdate)  -- only triggers when frame is shown
			
			frame:Show()
			
			local c1r, c1b, c1g, c1a
			if numeration <= maxResource then
				c1r, c1b, c1g, c1a = db.statusbarColorBackground.r, db.statusbarColorBackground.b, db.statusbarColorBackground.g, db.statusbarColorBackground.a
			else
				c1r, c1b, c1g, c1a = db.statusbarColorOverflow.r, db.statusbarColorOverflow.b, db.statusbarColorOverflow.g, db.statusbarColorOverflow.a
			end
			
			function frame:SetOriginalColor()
				self:SetBackdropColor(c1r, c1b, c1g, c1a)
				self.gainColored = false
			end
			
			frame:SetOriginalColor()
			
			return frame
		end
		for i = 1, statusbarCount do
			statusbars[i] = createStatusBars(resourceFrames[i], i)
		end
		if #statusbars > statusbarCount then
			for i = statusbarCount + 1, #statusbars do
				statusbars[i]:Hide()
			end
		end
	end
end


------------------------------
-- Initialization and stuff --
------------------------------
function CD:Unlock()
	CDFrame.fader:Stop()
	CDOnUpdateFrame:Hide()
	CDOnUpdateFrame:UnregisterEvents()
	for i = 1, statusbarCount do
		if textEnable then
			SATimers[i]:Show()
		end
		if statusbarEnable and (db.statusbarXOffset ~= 0 or db.statusbarYOffset ~= 0) then
			statusbars[i].statusbar:SetValue(10)
			statusbars[i]:Show()
		end
		
		if i == statusbarCount then break end
		
		resourceFrames[i]:Show()
	end
end

function CD:Lock()
	CDFrame.fader:Stop()  -- necessary?
	CDOnUpdateFrame:RegisterEvents()
end

function CD:Build()
	resourceCappedEnable = db.resourceCappedEnable
	remainingTimeThreshold = db.remainingTimeThreshold
	resourceGainPrediction = db.resourceGainPrediction
	resourceSpendIncludeHoG = db.resourceSpendIncludeHoG
	resourceSpendPrediction = db.resourceSpendPrediction
	statusbarEnable = db.statusbarEnable
	textEnable = db.textEnable
	visibilityConditionals = db.visibilityConditionals or ""
	
	statusbarCount = 5 + db.statusbarCount
	statusbarRefresh = 20 / db.width / DS.db.scale
	
	buildFrames()
	if not CDFrame.fader then
		buildFader()
	end
	CDFrame.fader.fadeOut:SetDuration(db.fadeOutDuration)
	if DS.locked and GetSpecialization() == 3 then CDOnUpdateFrame:Show() end
end

function CD:OnInitialize()
	db = DS.db.display
end

function CD:OnEnable()
	self:RegisterMessage("DOOM_SHARDS_UPDATE")
	CDOnUpdateFrame:RegisterEvents()
end

function CD:OnDisable()
	self:UnregisterMessage("DOOM_SHARDS_UPDATE")
	CDOnUpdateFrame:Hide()
	CDOnUpdateFrame:UnregisterEvents()
end