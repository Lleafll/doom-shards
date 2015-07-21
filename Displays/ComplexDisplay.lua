local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local CD = CS:NewModule("complex", "AceEvent-3.0")
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
local CDFrame = CS:CreateParentFrame("CS Complex Display", "complex")
CD.frame = CDFrame
CDFrame:Hide()
local orbFrames = {}
local fontStringParent
local SATimers = {}
local statusbars = {}
local CDOnUpdateFrame = CreateFrame("frame", nil, UIParent)
CDOnUpdateFrame:Hide()


---------------
-- Variables --
---------------
local db
local orbCappedEnable
local orbs
local remainingTimeThreshold
local statusbarCount
local statusbarEnable
local statusbarMaxTime
local statusbarRefresh
local textEnable
local timers
local visibilityConditionals = ""
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
-- Functions --
---------------
local function update()
	for i = 1, statusbarCount do
		if orbs >= i then
			local orbFrame = orbFrames[i]
			if orbCappedEnable then
				if (orbs == 5) and (not orbFrame.orbCapColored) then
					orbFrame:SetOrbCapColor()
				elseif (orbs ~= 5) and (orbFrame.orbCapColored) then
					orbFrame:SetOriginalColor()
				end
			end
			orbFrame:Show()
			if textEnable then SATimers[i]:Hide() end
			statusbars[i]:Hide()
			
		else
			orbFrames[i]:Hide()
		end
	end
	
	local k = orbs + 1
	local t = 1
	local timerID = timers[t]
	while timerID and k <= statusbarCount do
		if timerID.IsGUIDInRange() then
			if textEnable then SATimers[k]:SetTimer(timerID) end
			if statusbarEnable then statusbars[k]:SetTimer(timerID) end
			k = k + 1
		end
		t = t + 1
		timerID = timers[t]
	end
	
	for m = k, statusbarCount do
		if textEnable then SATimers[m]:Hide() end
		statusbars[m]:Hide()
	end
end

function CD:CONSPICUOUS_SPIRITS_UPDATE(_, updatedOrbs, updatedTimers)
	orbs = updatedOrbs
	timers = updatedTimers
	update()
end

local function SATimerOnUpdate(SATimer, elapsed)
	SATimer.elapsed = SATimer.elapsed + elapsed
	SATimer.remaining = SATimer.remaining - elapsed
	if SATimer.elapsed > 0.1 then
		if SATimer.remaining < remainingTimeThreshold then
			SATimer.fontString:SetText(stringformat("%.1f", SATimer.remaining < 0 and 0 or SATimer.remaining))
		else
			SATimer.fontString:SetText(stringformat("%.0f", SATimer.remaining))
		end
	end
end

local function statusbarOnUpdate(statusbar, elapsed)
	statusbar.remaining = statusbar.remaining - elapsed
	statusbar.elapsed = statusbar.elapsed + elapsed
	if statusbar.elapsed > statusbarRefresh then
		statusbar.statusbar:SetValue(statusbarMaxTime - (statusbar.remaining < 0 and 0 or statusbar.remaining))  -- check for < 0 necessary?
	end
end


----------------
-- Visibility --
----------------
function CD:CONSPICUOUS_SPIRITS_SPEC(isShadow)
	if isShadow then 
		CDOnUpdateFrame:Show()
		CDOnUpdateFrame:RegisterEvents()
	else
		CDOnUpdateFrame:Hide()
		CDOnUpdateFrame:UnregisterEvents()
	end
end

do
	-- can't use RegisterStateDriver because Restricted Environment doesn't allow for animations
	local currentState = "hide"
	
	function CDOnUpdateFrame:EvaluateConditionals()
		local state = SecureCmdOptionParse(visibilityConditionals)
		--if not CDFrame.fader then return end
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
	
	if GetSpecialization() == 3 then CDOnUpdateFrame:RegisterEvents() end
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
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	statusbarBackdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	local CDFrameHeight = db.height + 25
	local CDFrameWidth = statusbarCount * db.width + (statusbarCount - 1) * db.spacing
	CDFrame:ClearAllPoints()
	CDFrame:SetPoint(db.anchor, _G[db.anchorFrame], db.posX, db.posY)
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
			
			if numeration <= 5 then
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
			
			local c1r, c1b, c1g, c1a = db.color1.r, db.color1.b, db.color1.g, db.color1.a 
			local c2r, c2b, c2g, c2a = db.color2.r, db.color2.b, db.color2.g, db.color2.a 
			if numeration <= 3 then
				function frame:SetOriginalColor()
					self:SetBackdropColor(c1r, c1b, c1g, c1a)
					self.orbCapColored = false
				end
				frame:SetOriginalColor()
			elseif numeration <= 5 then
				function frame:SetOriginalColor()
					self:SetBackdropColor(c2r, c2b, c2g, c2a)
					self.orbCapColored = false
				end
				frame:SetOriginalColor()
			else
				frame:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to
			end
			
			local c3r, c3b, c3g, c3a = db.orbCappedColor.r, db.orbCappedColor.b, db.orbCappedColor.g, db.orbCappedColor.a
			function frame:SetOrbCapColor()
				self:SetBackdropColor(c3r, c3b, c3g, c3a)
				self.orbCapColored = true
			end
			
			return frame
		end
		for i = 1, statusbarCount do
			orbFrames[i] = createOrbFrame(i)
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
			end
			
			local c2r, c2b, c2g, c2a = db.fontColorCache.r, db.fontColorCache.b, db.fontColorCache.g, db.fontColorCache.a
			function fontString:SetCacheColor()
				self:SetTextColor(c2r, c2b, c2g, c2a)
			end
			
			parentFrame.elapsed = 0
			parentFrame.remaining = 0
			function parentFrame:SetTimer(timerID)
				
				--@debug@
				--print(timerID)
				--@end-debug@
			
				self.remaining = timerID.impactTime - GetTime()
				self.elapsed = 1
				if fontColorCacheEnable then
					if timerID.isCached then
						fontString:SetCacheColor()
					elseif not timerID.isCached then
						fontString:SetOriginalColor()
					end
				end
				self:Show()
			end
			parentFrame:SetScript("OnUpdate", SATimerOnUpdate)  -- only triggers when frame is shown
			
			fontString:SetText("0.0")
			fontString:SetOriginalColor()
			fontString:Show()
			return parentFrame
		end
		for i = 1, statusbarCount do
			SATimers[i] = createTimerFontString(orbFrames[i], i)
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
			statusbar:SetStatusBarTexture((db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle))
			statusbar:SetStatusBarColor(db.statusbarColor.r, db.statusbarColor.b, db.statusbarColor.g, db.statusbarColor.a)
			statusbar:SetMinMaxValues(0, statusbarMaxTime)
			statusbar:SetOrientation(orientation == "Vertical" and "VERTICAL" or "HORIZONTAL")
			statusbar:SetReverseFill(db.statusbarReverse)
			
			frame.remaining = 0
			frame.elapsed = 0
			function frame:SetTimer(timerID)
				self.elapsed = 1
				self.remaining = timerID.impactTime - GetTime()
				self:Show()
			end
			frame:SetScript("OnUpdate", statusbarOnUpdate)  -- only triggers when frame is shown
			
			frame:Show()		
			return frame
		end
		for i = 1, statusbarCount do
			statusbars[i] = createStatusBars(orbFrames[i], i)
		end
		local c1r, c1b, c1g, c1a = db.statusbarColorBackground.r, db.statusbarColorBackground.b, db.statusbarColorBackground.g, db.statusbarColorBackground.a
		local c2r, c2b, c2g, c2a = db.statusbarColorOverflow.r, db.statusbarColorOverflow.b, db.statusbarColorOverflow.g, db.statusbarColorOverflow.a
		for i = 1, statusbarCount do
			if i <= 5 then
				statusbars[i]:SetBackdropColor(c1r, c1b, c1g, c1a)
			else
				statusbars[i]:SetBackdropColor(c2r, c2b, c2g, c2a)
			end
		end
		if #statusbars > statusbarCount then
			for i = statusbarCount + 1, #statusbars do
				statusbars[i]:Hide()
			end
		end
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
	CDFrame.fader.fadeOut:SetChange(-1)
	CDFrame.fader.fadeOut:SetSmoothing("IN")
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
			statusbars[i].statusbar:SetValue(statusbarMaxTime / 2)
			statusbars[i]:Show()
		end
		
		if i == statusbarCount then break end
		
		orbFrames[i]:Show()
	end
end

function CD:Lock()
	CDFrame.fader:Stop()  -- necessary?
	CDOnUpdateFrame:RegisterEvents()
end

function CD:Build()
	statusbarMaxTime = db.maxTime
	textEnable = db.textEnable
	remainingTimeThreshold = db.remainingTimeThreshold
	fontColorCacheEnable = db.fontColorCacheEnable
	statusbarEnable = db.statusbarEnable
	orbCappedEnable = db.orbCappedEnable
	visibilityConditionals = db.visibilityConditionals or ""
	
	statusbarCount = 5 + db.statusbarCount
	statusbarRefresh = statusbarMaxTime / db.width / CS.db.scale
	
	buildFrames()
	if not CDFrame.fader then
		buildFader()
	end
	CDFrame.fader.fadeOut:SetDuration(db.fadeOutDuration)
	if CS.locked and GetSpecialization() == 3 then CDOnUpdateFrame:Show() end
end

function CD:OnInitialize()
	db = CS.db.complex
end

function CD:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	self:RegisterMessage("CONSPICUOUS_SPIRITS_SPEC")
end

function CD:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_SPEC")
	CDOnUpdateFrame:Hide()
end