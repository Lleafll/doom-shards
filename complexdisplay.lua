local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits")


-- Upvalues
local stringformat = string.format


-- Frames
local timerFrame = CS.frame
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
				local timeLeft = CS:TimeLeft(timerID)
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
	local spacing = CS.db.complex.spacing
	local height = CS.db.complex.height
	local width = CS.db.complex.width
	local function createOrbFrame(number)
		frame = orbFrames[i] or CreateFrame("frame", nil, CSFrame)
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
		fontString = SATimers[i] or timerFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetPoint("BOTTOMLEFT", referenceFrame, "TOPLEFT", 0, 1)
		fontString:SetPoint("BOTTOMRIGHT", referenceFrame, "TOPRIGHT", 0, 1)
		fontString:SetFont("Fonts\\FRIZQT__.TTF", width / 2)
		fontString:SetTextColor(1, 1, 1, 1)
		fontString:SetShadowOffset(1, -1)
		fontString:SetShadowColor(0, 0, 0, 1)
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
end

function CS:initializeComplex()
	timerFrame:SetHeight(5 * self.db.complex.height)
	timerFrame:SetWidth(5 * self.db.complex.width + 4 * self.db.complex.spacing)
	createFrames()
	function CS:refreshDisplay(orbs, timers) refreshDisplay(orbs, timers) end
	function timerFrame:ShowChildren() ShowChildren() end
	function timerFrame:HideChildren() HideChildren() end
end