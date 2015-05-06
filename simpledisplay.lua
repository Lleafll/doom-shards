-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")


-- Module
CS.displayBuilders["Simple"] = "initializeSimple"


-- Options
CS.optionsTable.args.simple = {
	order = 4,
	type = "group",
	name = L["Simple Display"],
	cmdHidden  = true,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function()
				return CS.db.display == "Simple"
			end,
			set = function(info, val)
				if val then CS.db.display = "Simple" end
				CS:Initialize()
			end
		},
		frame = {
			order = 2,
			type = "group",
			name = L["Frame"],
			inline = true,
			args = {
				height = {
					order = 2,
					type = "range",
					name = L["Height"],
					desc = L["Set Frame Height"],
					min = 1,
					max = 300,
					step = 1,
					get = function()
						return CS.db.simple.height
					end,
					set = function(info, val)
						CS.db.simple.height = val
						CS:Initialize()
					end
				},
				width = {
					order = 3,
					type = "range",
					name = L["Width"],
					desc = L["Set Frame Width"],
					min = 1,
					max = 300,
					step = 1,
					get = function()
						return CS.db.simple.width
					end,
					set = function(info, val)
						CS.db.simple.width = val
						CS:Initialize()
					end
				},
				spacing = {
					order = 4,
					type = "range",
					name = L["Spacing"],
					desc = L["Set Number Spacing"],
					min = 0,
					max = 100,
					step = 1,
					get = function()
						return CS.db.simple.spacing
					end,
					set = function(info, val)
						CS.db.simple.spacing = val
						CS:Initialize()
					end
				},
				spacer = {
					order = 4.5,
					type="description",
					name=""
				},
				color1 = {
					order = 5,
					type = "color",
					name = L["Color 1"],
					desc = L["Set Color 1"],
					hasAlpha = true,
					get = function()
						return CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a = r, b, g, a
						CS:Initialize()
					end
				},
				color2 = {
					order = 6,
					type = "color",
					name = L["Color 2"],
					desc = L["Set Color 2"],
					hasAlpha = true,
					get = function()
						return CS.db.simple.color2.r, CS.db.simple.color2.b, CS.db.simple.color2.g, CS.db.simple.color2.a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.color2.r, CS.db.simple.color2.b, CS.db.simple.color2.g, CS.db.simple.color2.a = r, b, g, a
						CS:Initialize()
					end
				},
				color3 = {
					order = 7,
					type = "color",
					name = L["Color 3"],
					desc = L["Set Color 3"],
					hasAlpha = true,
					get = function()
						return CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a = r, b, g, a
						CS:Initialize()
					end
				},
				spacer2 = {
					order = 7.5,
					type="description",
					name=""
				},
				textureHandle = {
					order = 8,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = L["Texture"],
					desc = L["Set texture used for the background"],
					values = LSM:HashTable("statusbar"),
					get = function()
						return CS.db.simple.textureHandle
					end,
					set = function(_, key)
						CS.db.simple.textureHandle = key
						CS:Initialize()
					end
				},
				borderColor = {
					order = 9,
					type = "color",
					name = L["Border Color"],
					desc = L["Set Display border color"],
					hasAlpha = true,
					get = function()
						return CS.db.simple.borderColor.r, CS.db.simple.borderColor.b, CS.db.simple.borderColor.g, CS.db.simple.borderColor.a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.borderColor.r, CS.db.simple.borderColor.b, CS.db.simple.borderColor.g, CS.db.simple.borderColor.a = r, b, g, a
						CS:Initialize()
					end
				},
				spacer3 = {
					order = 9.5,
					type="description",
					name=""
				}
			}
		},
		text = {
			order = 3,
			type = "group",
			name = L["Text"],
			inline = true,
			args = {
				fontName = {
					order = 10,
					type = "select",
					dialogControl = "LSM30_Font",
					name = L["Font"],
					desc = L["Select font for the Simple display"],
					values = LSM:HashTable("font"),
					get = function()
						return CS.db.simple.fontName
					end,
					set = function(_, val)
						CS.db.simple.fontName = val
						CS:Initialize()
					end
				},
				fontSize = {
					order = 11,
					type = "range",
					name = L["Font Size"],
					desc = L["Set Font Size"],
					min = 1,
					max = 32,
					step = 1,
					get = function()
						return CS.db.simple.fontSize
					end,
					set = function(info, val)
						CS.db.simple.fontSize = val
						CS:Initialize()
					end
				},
				fontFlags = {
					order = 12,
					type = "select",
					style = "dropdown",
					name = L["Font Flags"],
					desc = L["Font Flags"],
					values = {
						["None"] = L["None"],
						["Shadow"] = L["Shadow"],
						["OUTLINE"] = L["OUTLINE"],
						["THICKOUTLINE"] = L["THICKOUTLINE"],
						["MONOCHROMEOUTLINE"] = L["MONOCHROMEOUTLINE"]
					},
					get = function()
						return CS.db.simple.fontFlags
					end,
					set = function(info, val)
						CS.db.simple.fontFlags = val
						CS:Initialize()
					end
				},
				color = {
					order = 13,
					type = "color",
					name = L["Font Color"],
					desc = L["Set Font Color"],
					get = function()
						return CS.db.simple.fontColor.r, CS.db.simple.fontColor.b, CS.db.simple.fontColor.g, CS.db.simple.fontColor.a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.fontColor.r, CS.db.simple.fontColor.b, CS.db.simple.fontColor.g, CS.db.simple.fontColor.a = r, b, g, a
						CS:Initialize()
					end
				}
			}
		}
	}
}

CS.defaultSettings.global.simple = {
	height = 33,
	width = 65,
	spacing = 20,
	color1 = {r=0.53, b=0.53, g=0.53, a=1.00},  -- lowest threshold color
	color2 = {r=0.38, b=0.23, g=0.51, a=1.00},  -- middle threshold color
	color3 = {r=0.51, b=0.00, g=0.24, a=1.00},  -- highest threshold color
	fontSize = 15,
	fontName = "Fritz Quadrata TT",
	fontFlags = "Shadow",
	fontColor = {r=1, b=1, g=1, a=1},
	textureHandle = "Empty",
	borderColor = {r=0, b=0, g=0, a=1}
}


-- Upvalues
local GetTime = GetTime


-- Frames
local timerFrame = CS.frame
local timerTextShort
local timerTextLong


-- Variables
local db
local fontPath
local timerID
local remainingThreshold = 2 -- threshold between short and long Shadowy Apparitions
local backdrop = {
	bgFile = nil,
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = false,
	edgeSize= 1
}


-- Functions
local function refreshDisplay(self, orbs, timers)
	local currentTime
	local short = 0
	local long = 0
	for i = 1, #timers do
		timerID = timers[i]
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
		timerFrame:Show()
		timerFrame:SetBackdropColor(db.color3.r, db.color3.b, db.color3.g, db.color3.a)
	elseif short > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(db.color2.r, db.color2.b, db.color2.g, db.color2.a)
	elseif long > 0 then
		timerFrame:Show()
		timerFrame:SetBackdropColor(db.color1.r, db.color1.b, db.color1.g, db.color1.a)
	else
		timerFrame:Hide()
	end
end

local function createFrames()
	local spacing = db.spacing / 2
	
	timerFrame:SetBackdrop(backdrop)
	timerFrame:SetBackdropColor(db.color1.r, db.color1.b, db.color1.g, db.color1.a)
	timerFrame:SetBackdropBorderColor(db.borderColor.r, db.borderColor.b, db.borderColor.g, db.borderColor.a)
	
	local function setTimerText(fontstring)
		local flags = db.fontFlags
		fontstring:Show()
		fontstring:SetFont(fontPath, db.fontSize, (flags == "MONOCHROMEOUTLINE" or flags == "OUTLINE" or flags == "THICKOUTLINE") and flags or nil)
		fontstring:SetTextColor(db.fontColor.r, db.fontColor.b, db.fontColor.g, db.fontColor.a)
		fontstring:SetShadowOffset(1, -1)
		fontstring:SetShadowColor(0, 0, 0, flags == "Shadow" and 1 or 0)
		fontstring:SetText("0")
	end
	
	if not timerTextShort then timerTextShort = timerFrame:CreateFontString(nil, "OVERLAY") end
	timerTextShort:SetPoint("CENTER", -spacing, 0)
	setTimerText(timerTextShort)
	
	if not timerTextLong then timerTextLong = timerFrame:CreateFontString(nil, "OVERLAY") end
	timerTextLong:SetPoint("CENTER", spacing, 0)
	setTimerText(timerTextLong)
end

local function HideChildren()
	timerFrame:SetBackdropColor(1, 1, 1, 0)
	timerFrame:SetBackdropBorderColor(0, 0, 0, 0)
	timerTextShort:Hide()
	timerTextLong:Hide()
end

function CS:initializeSimple()
	db = self.db.simple

	timerFrame:SetHeight(db.height)
	timerFrame:SetWidth(db.width)
	
	fontPath = LSM:Fetch("font", db.fontName)
	backdrop.bgFile = (db.textureHandle == "Empty") and "Interface\\ChatFrame\\ChatFrameBackground" or LSM:Fetch("statusbar", db.textureHandle)
	
	createFrames()
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = function() end
	timerFrame.HideChildren = HideChildren
	
	self.needsFrequentUpdates = true
end