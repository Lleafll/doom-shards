-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")


-- Options
CS:AddDisplayOptions("simple",
	{
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
					CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
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
							CS:Build()
						end
					}
				}
			}
		}
	},
	{
		height = 33,
		width = 65,
		spacing = 20,
		color1 = {r=0.53, b=0.53, g=0.53, a=1.00},  -- lowest threshold color
		color2 = {r=0.38, b=0.23, g=0.51, a=1.00},  -- middle threshold color
		color3 = {r=0.51, b=0.00, g=0.24, a=1.00},  -- highest threshold color
		fontSize = 15,
		fontName = "Friz Quadrata TT",
		fontFlags = "Shadow",
		fontColor = {r=1, b=1, g=1, a=1},
		textureHandle = "Empty",
		borderColor = {r=0, b=0, g=0, a=1}
	}
)