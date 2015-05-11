-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")


-- Options
CS:AddDisplayOptions("complex",
	{
		order = 2,
		type = "group",
		name = L["Complex Display"],
		cmdHidden  = true,
		get = function(info) return CS.db.complex[info[#info]] end,
		set = function(info, value) CS.db.complex[info[#info]] = value; CS:Build() end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			},
			layout = {
				order = 2,
				type = "group",
				name = L["Layout"],
				inline = true,
				args = {
					orientation = {
						order = 1,
						type = "select",
						style = "dropdown",
						name = L["Orientation"],
						desc = L["Set Display orientation"],
						values = {
							["Horizontal"] = L["Horizontal"],
							["Vertical"] = L["Vertical"]
						}
					},
					growthDirection = {
						order = 2,
						type = "select",
						name = L["Growth direction"],
						desc = L["Order in which the Shadow Orbs get filled in"],
						values = {
							["Regular"] = L["Regular"],
							["Reversed"] = L["Reversed"]
						}
					}
				}
			},
			orbs = {
				order = 3,
				type = "group",
				name = L["Orbs"],
				inline = true,
				args = {
					height = {
						order = 1,
						type = "range",
						name = function() if CS.db.complex.orientation == "Vertical" then return L["Width"] else return L["Height"] end end,
						desc = function() if CS.db.complex.orientation == "Vertical" then return L["Set Shadow Orb Width"] else return L["Set Shadow Orb Height"] end end,
						min = 1,
						max = 100,
						step = 1
					},
					width = {
						order = 2,
						type = "range",
						name = function() if CS.db.complex.orientation == "Vertical" then return L["Height"] else return L["Width"] end end,
						desc = function() if CS.db.complex.orientation == "Vertical" then return L["Set Shadow Orb Height"] else return L["Set Shadow Orb Width"] end end,
						min = 1,
						max = 100,
						step = 1
					},
					spacing = {
						order = 3,
						type = "range",
						name = L["Spacing"],
						desc = L["Set Shadow Orb Spacing"],
						min = 0,
						max = 100,
						step = 1
					},
					spacer = {
						order = 3.5,
						type="description",
						name=""
					},
					color1 = {
						order = 4,
						type = "color",
						name = L["Color 1"],
						desc = L["Set Color 1"],
						hasAlpha = true,
						get = function()
							local r, b, g, a = CS.db.complex.color1.r, CS.db.complex.color1.b, CS.db.complex.color1.g, CS.db.complex.color1.a
							return r, b, g, a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.color1.r, CS.db.complex.color1.b, CS.db.complex.color1.g, CS.db.complex.color1.a = r, b, g, a
							CS:Build()
						end
					},
					color2 = {
						order = 5,
						type = "color",
						name = L["Color 2"],
						desc = L["Set Color 2"],
						hasAlpha = true,
						get = function()
							local r, b, g, a = CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a
							return r, b, g, a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a = r, b, g, a
							CS:Build()
						end
					},
					spacer2 = {
						order = 5.5,
						type="description",
						name=""
					},
					orbCappedEnable = {
						order = 6,
						type = "toggle",
						name = L["Orb Cap Color Change"],
						desc = L["Change color of all Shadow Orbs when reaching five Shadow Orbs"]
					},
					orbCappedColor = {
						order = 7,
						type = "color",
						name = L["Color When Orb Capped"],
						hasAlpha = true,
						get = function()
							return CS.db.complex.orbCappedColor.r, CS.db.complex.orbCappedColor.b, CS.db.complex.orbCappedColor.g, CS.db.complex.orbCappedColor.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.orbCappedColor.r, CS.db.complex.orbCappedColor.b, CS.db.complex.orbCappedColor.g, CS.db.complex.orbCappedColor.a = r, b, g, a
							CS:Build()
						end
					},
					spacer3 = {
						order = 8.5,
						type="description",
						name=""
					},
					textureHandle = {
						order = 9,
						type = "select",
						dialogControl = "LSM30_Statusbar",
						name = L["Texture"],
						desc = L["Set texture used for the Shadow Orbs"],
						values = LSM:HashTable("statusbar")
					},
					borderColor = {
						order = 10,
						type = "color",
						name = L["Border Color"],
						desc = L["Set Shadow Orb border color"],
						hasAlpha = true,
						get = function()
							return CS.db.complex.borderColor.r, CS.db.complex.borderColor.b, CS.db.complex.borderColor.g, CS.db.complex.borderColor.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.borderColor.r, CS.db.complex.borderColor.b, CS.db.complex.borderColor.g, CS.db.complex.borderColor.a = r, b, g, a
							CS:Build()
						end
					},
					spacer4 = {
						order = 11.5,
						type="description",
						name=""
					},
					visibilityConditionals = {
						order = 12,
						type = "input",
						name = L["Visibility"],
						desc = L["Regulate display visibility with macro conditionals"],
						width = "full",
						set = function(info, val)
							if UnitAffectingCombat("player") then 
								print(L["Can not change visibility options in combat."])
								return
							end
							CS.db.complex.visibilityConditionals = val
							CS:Build()
						end
					}
				}
			},
			text = {
				order = 5,
				type = "group",
				name = L["Text"],
				inline = true,
				args = {
					textEnable = {
						order = 6,
						type = "toggle",
						name = L["Enable"]
					},
					fontName = {
						order = 7,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = L["Select font for the Complex display"],
						values = LSM:HashTable("font")
					},
					spacer0 = {
						order = 7.5,
						type="description",
						name=""
					},
					fontSize = {
						order = 8,
						type = "range",
						name = L["Font Size"],
						desc = L["Set Font Size"],
						min = 1,
						max = 32,
						step = 1
					},
					fontFlags = {
						order = 9,
						type = "select",
						style = "dropdown",
						name = L["Font Flags"],
						desc = L["Set Font Flags"],
						values = {
							["None"] = L["None"],
							["Shadow"] = L["Shadow"],
							["OUTLINE"] = L["OUTLINE"],
							["THICKOUTLINE"] = L["THICKOUTLINE"],
							["MONOCHROMEOUTLINE"] = L["MONOCHROMEOUTLINE"]
						}
					},
					color = {
						order = 10,
						type = "color",
						name = L["Font Color"],
						desc = L["Set Font Color"],
						get = function()
							return CS.db.complex.fontColor.r, CS.db.complex.fontColor.b, CS.db.complex.fontColor.g, CS.db.complex.fontColor.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.fontColor.r, CS.db.complex.fontColor.b, CS.db.complex.fontColor.g, CS.db.complex.fontColor.a = r, b, g, a
							CS:Build()
						end
					},
					spacer = {
						order = 10.5,
						type="description",
						name=""
					},
					stringXOffset = {
						order = 11,
						type = "range",
						name = L["X Offset"],
						desc = L["X offset for the Shadowy Apparition time text"],
						min = -1000,
						max = 1000,
						step = 1,
						get = function()
							local offset = CS.db.complex.orientation == "Vertical" and -CS.db.complex.stringYOffset or CS.db.complex.stringXOffset
							if (CS.db.complex.growthDirection == "Reversed") and (CS.db.complex.orientation ~= "Vertical") then offset = -offset end
							return offset
						end,
						set = function(info, val)
							if CS.db.complex.orientation == "Vertical" then
								CS.db.complex.stringYOffset = -val
							else
								if CS.db.complex.growthDirection == "Reversed" then val = -val end
								CS.db.complex.stringXOffset = val
							end
							CS:Build()
						end
					},
					stringYOffset = {
						order = 12,
						type = "range",
						name = L["Y Offset"],
						desc = L["Y offset for the Shadowy Apparition time text"],
						min = -1000,
						max = 1000,
						step = 1,
						get = function()
							local offset = CS.db.complex.orientation == "Vertical" and CS.db.complex.stringXOffset or CS.db.complex.stringYOffset
							if CS.db.complex.growthDirection == "Reversed" and CS.db.complex.orientation == "Vertical" then offset = -offset end
							return offset
						end,
						set = function(info, val)
							if CS.db.complex.orientation == "Vertical" then
								if CS.db.complex.growthDirection == "Reversed" and CS.db.complex.orientation == "Vertical" then val = -val end
								CS.db.complex.stringXOffset = val
							else
								CS.db.complex.stringYOffset = val
							end
							CS:Build()
						end
					}
				}
			},
			statusbar = {
				order = 4,
				type = "group",
				name = L["Anticipated Orbs"],
				inline = true,
				args = {
					statusbarEnable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable display of bars for anticipated Shadow Orbs in the Shadow Orbs' positions"]
					},
					statusbarReverse = {
						order = 3,
						type = "toggle",
						name = L["Reverse Direction"],
						desc = L["Fill indicator from right to left"]
					},
					maxTime = {
						order = 2,
						type = "range",
						name = L["Maximum Time"],
						desc = L["Maximum remaining Shadowy Apparition flight time shown on the indicators"],
						min = 0,
						max = 10,
						step = 0.1
					},
					spacer = {
						order = 3.5,
						type="description",
						name=""
					},
					color = {
						order = 4,
						type = "color",
						name = L["Color"],
						hasAlpha = true,
						get = function()
							return CS.db.complex.statusbarColor.r, CS.db.complex.statusbarColor.b, CS.db.complex.statusbarColor.g, CS.db.complex.statusbarColor.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.statusbarColor.r, CS.db.complex.statusbarColor.b, CS.db.complex.statusbarColor.g, CS.db.complex.statusbarColor.a = r, b, g, a
							CS:Build()
						end
					},
					colorBackground = {
						order = 5,
						type = "color",
						name = L["Background Color"],
						hasAlpha = true,
						get = function()
							return CS.db.complex.statusbarColorBackground.r, CS.db.complex.statusbarColorBackground.b, CS.db.complex.statusbarColorBackground.g, CS.db.complex.statusbarColorBackground.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.statusbarColorBackground.r, CS.db.complex.statusbarColorBackground.b, CS.db.complex.statusbarColorBackground.g, CS.db.complex.statusbarColorBackground.a = r, b, g, a
							CS:Build()
						end
					},
					colorOverflow = {
						order = 6,
						type = "color",
						name = L["\"Overcap Orb\" Color"],
						desc = L["Color of the sixth indicator when overcapping with Shadowy Apparitions"],
						hasAlpha = true,
						get = function()
							return CS.db.complex.statusbarColorOverflow.r, CS.db.complex.statusbarColorOverflow.b, CS.db.complex.statusbarColorOverflow.g, CS.db.complex.statusbarColorOverflow.a
						end,
						set = function(info, r, b, g, a)
							CS.db.complex.statusbarColorOverflow.r, CS.db.complex.statusbarColorOverflow.b, CS.db.complex.statusbarColorOverflow.g, CS.db.complex.statusbarColorOverflow.a = r, b, g, a
							CS:Build()
						end
					},
					spacer2 = {
						order = 6.5,
						type="description",
						name=""
					},
					xOffset = {
						order = 7,
						type = "range",
						name = L["X Offset"],
						desc = L["X offset for the Shadowy Apparition indicator bars"],
						min = -1000,
						max = 1000,
						step = 1,
						get = function()
							local offset = CS.db.complex.orientation == "Vertical" and -CS.db.complex.statusbarYOffset or CS.db.complex.statusbarXOffset
							if (CS.db.complex.growthDirection == "Reversed") and (CS.db.complex.orientation ~= "Vertical") then offset = -offset end
							return offset
						end,
						set = function(info, val)
							if CS.db.complex.orientation == "Vertical" then
								CS.db.complex.statusbarYOffset = -val
							else
								if CS.db.complex.growthDirection == "Reversed" then val = -val end
								CS.db.complex.statusbarXOffset = val
							end
							CS:Build()
						end
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y Offset"],
						desc = L["Y offset for the Shadowy Apparition time text"],
						min = -1000,
						max = 1000,
						step = 1,
						get = function()
							local offset = CS.db.complex.orientation == "Vertical" and CS.db.complex.statusbarXOffset or CS.db.complex.statusbarYOffset
							if CS.db.complex.growthDirection == "Reversed" and CS.db.complex.orientation == "Vertical" then offset = -offset end
							return offset
						end,
						set = function(info, val)
							if CS.db.complex.orientation == "Vertical" then
								if CS.db.complex.growthDirection == "Reversed" and CS.db.complex.orientation == "Vertical" then val = -val end
								CS.db.complex.statusbarXOffset = val
							else
								CS.db.complex.statusbarYOffset = val
							end
							CS:Build()
						end
					}
				}
			}
		}
	},
	{
		enable = true,
		posX = 0,
		posY = 0,
		height = 8,
		width = 32,
		spacing = 1,
		color1 = {r=0.38, b=0.23, g=0.51, a=1},
		color2 = {r=0.51, b=0.00, g=0.24, a=1},
		textEnable = true,
		fontSize = 15,
		fontName = "Friz Quadrata TT",
		fontFlags = "Shadow",
		fontColor = {r=1, b=1, g=1, a=1},
		stringXOffset = 0,
		stringYOffset = 0,
		visibilityConditionals = "[harm] [combat] show; hide",
		orientation = "Horizontal",
		growthDirection = "Regular",
		textureHandle = "Empty",
		borderColor = {r=0, b=0, g=0, a=1},
		statusbarEnable = true,
		statusbarColor = {r=0.33, b=0.33, g=0.33, a=0.5},
		statusbarColorBackground = {r=0.06, b=0.06, g=0.06, a=1},
		statusbarColorOverflow = {r=0.51, b=0.00, g=0.24, a=1},
		statusbarReverse = false,
		maxTime = 5,
		statusbarXOffset = 0,
		statusbarYOffset = 0,
		orbCappedEnable = false,
		orbCappedColor = {r=0.51, b=0.00, g=0.24, a=1},
	}
)