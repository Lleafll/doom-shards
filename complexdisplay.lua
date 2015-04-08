local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Get Addon object
local ASTimer = LibStub("AceAddon-3.0"):GetAddon("AS Timer")


-- Upvalues
local stringformat = string.format


-- Frames
local timerFrame = ASTimer.frame
local orbFrames = {}
local SATimers = {}


-- Variables
local timerID
local maxToleratedTime = 10
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local frame
local fontString


-- Functions
local function refreshDisplay(orbs, timers)
	local k = 1
	for i = 1, 6 do
		if orbs >= i then
			orbFrames[i]:Show()
			SATimers[i]:Hide()
		else
			orbFrames[i]:Hide()
			timerID = timers[k]
			if timerID then
				local timeLeft = ASTimer:TimeLeft(timerID)
				if timeLeft > 0 then
					SATimers[i]:Show()
					local travelTime = timerID.travelTime
					local remaining = math.max(0, timeLeft - maxToleratedTime + travelTime)
					if remaining < remainingThreshold then
						SATimers[i]:SetText(stringformat("%.1f", remaining))
					else
						SATimers[i]:SetText(stringformat("%.0f", remaining))
					end
				else
					SATimers[i]:Hide()
				end
				k = k + 1
			else
				SATimers[i]:Hide()
			end
		end
	end
end

local function createFrames()
	if orbFrames[1] then return end  -- don't create frames if already initialized
	
	local function createOrbFrame(number)
		frame = CreateFrame("frame", nil, ASTimerFrame)
		frame:SetPoint("BOTTOMLEFT", 33 * (number - 1), 0)
		frame:SetWidth(32)
		frame:SetHeight(8)
		frame:SetBackdrop({
			bgFile="Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile="Interface\\ChatFrame\\ChatFrameBackground",
			tile=true,
			tileSize=5,
			edgeSize= 1
		})
		frame:SetBackdropBorderColor(0, 0, 0, 1)
		frame:Show()
		return frame
	end
	for i = 1, 6 do
		orbFrames[i] = createOrbFrame(i)
	end
	orbFrames[1]:SetBackdropColor(0.38, 0.23, 0.51, 1.00)
	orbFrames[2]:SetBackdropColor(0.38, 0.23, 0.51, 1.00)
	orbFrames[3]:SetBackdropColor(0.38, 0.23, 0.51, 1.00)
	orbFrames[4]:SetBackdropColor(0.51, 0.00, 0.24, 1.00)
	orbFrames[5]:SetBackdropColor(0.51, 0.00, 0.24, 1.00)
	orbFrames[6]:SetBackdropColor(0, 0, 0, 0)  -- dummy frame to anchor overflow fontstring to

	local function createTimerFontString(referenceFrame)
		fontString = timerFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetPoint("BOTTOMLEFT", referenceFrame, "TOPLEFT", 0, 1)
		fontString:SetPoint("BOTTOMRIGHT", referenceFrame, "TOPRIGHT", 0, 1)
		fontString:SetHeight(15)
		fontString:SetFont("Fonts\\FRIZQT__.TTF", 15)
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetShadowOffset(1, -1)
		fontString:SetShadowColor(0, 0, 0, 1)
		fontString:Show()
		fontString:SetText("0.0")
		return fontString
	end
	for i = 1, 6 do
		SATimers[i] = createTimerFontString(orbFrames[i])
	end
end

local function HideChildren()
	for i = 1, 6 do
		orbFrames[i]:Hide()
		SATimers[i]:Hide()
	end
end

function ASTimer:initializeComplex()
	timerFrame:SetWidth(164)
	timerFrame:SetHeight(40)
	createFrames()
	function ASTimer:refreshDisplay(orbs, timers) refreshDisplay(orbs, timers) end
	function timerFrame:HideChildren() HideChildren() end
end