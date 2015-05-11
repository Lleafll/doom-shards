-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create Module
local SD = CS:NewModule("simple")


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Upvalues
local GetTime = GetTime


-- Frames
local SDFrame = CS:CreateParentFrame("CS Simple Display")
SD.frame = SDFrame
local timerTextShort
local timerTextLong


-- Variables
local db
local fontPath
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local backdrop = {  -- recycling table
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize= 1
}


-- Functions
function SD:CONSPICUOUS_SPIRITS_UPDATE(self, orbs, timers)
	local currentTime
	local short = 0
	local long = 0
	for i = 1, #timers do
		local timerID = timers[i]
		if timerID then
			currentTime = currentTime or GetTime()
			local remaining = timerID.impactTime - currentTime
			if remaining < remainingThreshold then
				short = short + 1
			else
				long = long + 1
			end
		else
			break
		end
	end
	timerTextShort:SetText(short)
	timerTextLong:SetText(long)
	
	if (orbs >= 3) and (short + long > 0) and ((short + orbs >= 5) or (short + long + orbs >= 6)) then
		SDFrame:Show()
		SDFrame:SetBackdropColor(db.color3.r, db.color3.b, db.color3.g, db.color3.a)
	elseif short > 0 then
		SDFrame:Show()
		SDFrame:SetBackdropColor(db.color2.r, db.color2.b, db.color2.g, db.color2.a)
	elseif long > 0 then
		SDFrame:Show()
		SDFrame:SetBackdropColor(db.color1.r, db.color1.b, db.color1.g, db.color1.a)
	else
		SDFrame:Hide()
	end
end

local function createFrames()
	local spacing = db.spacing / 2
	
	SDFrame:SetBackdrop(backdrop)
	SDFrame:SetBackdropColor(db.color1.r, db.color1.b, db.color1.g, db.color1.a)
	SDFrame:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
	
	local function setTimerText(fontstring)
		local flags = db.fontFlags
		fontstring:Show()
		fontstring:SetFont(fontPath, db.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
		fontstring:SetTextColor(db.fontColor.r, db.fontColor.b, db.fontColor.g, db.fontColor.a)
		fontstring:SetShadowOffset(1, -1)
		fontstring:SetShadowColor(0, 0, 0, flags == "Shadow" and 1 or 0)
		fontstring:SetText("0")
	end
	
	if not timerTextShort then timerTextShort = SDFrame:CreateFontString(nil, "OVERLAY") end
	timerTextShort:SetPoint("CENTER", -spacing, 0)
	setTimerText(timerTextShort)
	
	if not timerTextLong then timerTextLong = SDFrame:CreateFontString(nil, "OVERLAY") end
	timerTextLong:SetPoint("CENTER", spacing, 0)
	setTimerText(timerTextLong)
end

function SD:Unlock()
	SDFrame:Show()
end

function SD:Lock()
	SDFrame:Hide()
end

--[[
CS.displayBuilders["Simple"] = function(self)
	db = self.db.simple

	SDFrame:SetHeight(db.height)
	SDFrame:SetWidth(db.width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	self.refreshDisplay = refreshDisplay
	SDFrame.ShowChildren = function() end
	SDFrame.HideChildren = HideChildren
	
	self:SetUpdateInterval(0.1)
end
--]]

function SD:OnEnable()
	db = self.db.simple
	
	SDFrame:SetPoint("CENTER", CS.db.posX, CS.db.posY)
	SDFrame:SetScale(CS.db.scale)
	SDFrame:SetHeight(db.height)
	SDFrame:SetWidth(db.width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	self.refreshDisplay = refreshDisplay
	
	self:SetUpdateInterval(0.1)
	
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function SD:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
	SDFrame:Hide()
end