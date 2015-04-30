local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and Libraries and stuff
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits")
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")
LibStub("AceEvent-3.0"):Embed(CS)
LibStub("AceTimer-3.0"):Embed(CS)
LibStub("AceConsole-3.0"):Embed(CS)
local ACD = LibStub("AceConfigDialog-3.0")


-- Upvalues
local print = print
local UnitAffectingCombat = UnitAffectingCombat 


-- Frames
CS.frame = CreateFrame("frame", "CSFrame", UIParent)
local timerFrame = CS.frame
timerFrame:SetFrameStrata("MEDIUM")
timerFrame:SetMovable(true)
timerFrame.lock = true
timerFrame.texture = timerFrame:CreateTexture(nil, "LOW")
timerFrame.texture:SetAllPoints(timerFrame)
timerFrame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
timerFrame.texture:Hide()

function timerFrame:ShowChildren() end
function timerFrame:HideChildren() end

function timerFrame:Unlock()
	timerFrame:Show()
	timerFrame:ShowChildren()
	timerFrame.texture:Show()
	timerFrame:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Conspicuous Spirits", 0.38, 0.23, 0.51, 1, 1, 1)
		GameTooltip:AddLine(L["Left mouse button to drag."], 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	timerFrame:SetScript("OnLeave", function(s) GameTooltip:Hide() end)
	timerFrame:SetScript("OnMouseDown", timerFrame.StartMoving)
	timerFrame:SetScript("OnMouseUp", function(self, button)
			self:StopMovingOrSizing()
			local _, _, _, posX, posY = self:GetPoint()
			CS.db.posX = posX
			CS.db.posY = posY
		end
	)
	RegisterStateDriver(timerFrame, "visibility", "")
	print(L["Conspicuous Spirits unlocked!"])
	timerFrame.lock = false
end

function timerFrame:Lock()
	timerFrame.texture:Hide()
	timerFrame:EnableMouse(false)
	timerFrame:SetScript("OnEnter", nil)
	timerFrame:SetScript("OnLeave", nil)
	timerFrame:SetScript("OnMouseDown", nil)
	timerFrame:SetScript("OnMouseUp", nil)
	CS:applySettings()
	if CS.db.display == "Complex" then
		RegisterStateDriver(timerFrame, CS.db.complex.visibilityConditionals)
	end
	if not timerFrame.lock then print(L["Conspicuous Spirits locked!"]) end
	timerFrame.lock = true
end


-- Options
local optionsTable = {
	type = "group",
	name = "Conspicuous Spirits",
	childGroups = "tab",
	args = {
		general = {
			order = 1,
			type = "group",
			name = L["General"],
			cmdHidden = true,
			inline = true,
			args = {
				scale = {
					order = 1,
					type = "range",
					name = L["Scale"],
					desc = L["Set Frame Scale"],
					min = 0,
					max = 3,
					step = 0.01,
					get = function()
						return timerFrame:GetScale()
					end,
					set = function(info, val)
						CS.db.scale = val
						timerFrame:SetScale(val)
					end
				},
				aggressiveCaching = {
					order = 3,
					type = "toggle",
					name = L["Aggressive Caching"],
					desc = L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."],
					get = function()
						return CS.db.aggressiveCaching
					end,
					set = function(_, val)
						CS.db.aggressiveCaching = val
					end
				},
				aggressiveCachingInterval = {
					order = 4,
					type = "range",
					name = L["Aggressive Caching Interval"],
					desc = L["Scanning interval when Aggressive Caching is enabled"],
					min = 0.2,
					max = 3,
					step = 0.1,
					get = function()
						return CS.db.aggressiveCachingInterval
					end,
					set = function(_, val)
						CS.db.aggressiveCachingInterval = val
					end
				},
				spacer = {
					order = 2.5,
					type = "description",
					name = ""
				},
				reset = {
					order = 2,
					type = "execute",
					name = L["Reset to Defaults"],
					confirm = true,
					func = function()
						CS:ResetDB()
						print(L["Conspicuous Spirits reset!"])
						CS:getDB()
						CS:Initialize()
					end
				}
			}
		},
		complex = {
			order = 2,
			type = "group",
			name = L["Complex Display"],
			cmdHidden  = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function()
						return CS.db.display == "Complex"
					end,
					set = function(info, val)
						if val then CS.db.display = "Complex" end
						CS:Initialize()
					end
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
							},
							get = function()
								return CS.db.complex.orientation
							end,
							set = function(info, val)
								CS.db.complex.orientation = val
								CS:Initialize()
							end
						},
						direction = {
							order = 2,
							type = "select",
							name = L["Growth direction"],
							desc = L["Order in which the Shadow Orbs get filled in"],
							values = {
								["Regular"] = L["Regular"],
								["Reversed"] = L["Reversed"]
							},
							get = function()
								return CS.db.complex.growthDirection
							end,
							set = function(info, val)
								CS.db.complex.growthDirection = val
								CS:Initialize()
							end
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
							name = L["Height"],
							desc = L["Set Shadow Orb Height"],
							min = 1,
							max = 100,
							step = 1,
							get = function()
								return CS.db.complex.height
							end,
							set = function(info, val)
								CS.db.complex.height = val
								CS:Initialize()
							end
						},
						width = {
							order = 2,
							type = "range",
							name = L["Width"],
							desc = L["Set Shadow Orb Width"],
							min = 1,
							max = 100,
							step = 1,
							get = function()
								return CS.db.complex.width
							end,
							set = function(info, val)
								CS.db.complex.width = val
								CS:Initialize()
							end
						},
						spacing = {
							order = 3,
							type = "range",
							name = L["Spacing"],
							desc = L["Set Shadow Orb Spacing"],
							min = 0,
							max = 100,
							step = 1,
							get = function()
								return CS.db.complex.spacing
							end,
							set = function(info, val)
								CS.db.complex.spacing = val
								CS:Initialize()
							end
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
							get = function()
								local r, b, g, a = CS.db.complex.color1.r, CS.db.complex.color1.b, CS.db.complex.color1.g, CS.db.complex.color1.a
								return r, b, g, a
							end,
							set = function(info, r, b, g, a)
								CS.db.complex.color1.r, CS.db.complex.color1.b, CS.db.complex.color1.g, CS.db.complex.color1.a = r, b, g, a
								CS:Initialize()
							end
						},
						color2 = {
							order = 5,
							type = "color",
							name = L["Color 2"],
							desc = L["Set Color 2"],
							get = function()
								local r, b, g, a = CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a
								return r, b, g, a
							end,
							set = function(info, r, b, g, a)
								CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a = r, b, g, a
								CS:Initialize()
							end
						},
						spacer2 = {
							order = 5.5,
							type="description",
							name=""
						},
						visibility = {
							order = 6,
							type = "input",
							name = L["Visibility"],
							desc = L["Regulate display visibility with macro conditionals"],
							width = "full",
							get = function()
								return CS.db.complex.visibilityConditionals
							end,
							set = function(info, val)
								CS.db.complex.visibilityConditionals = val
								CS:Initialize()
							end
						}
					},
				},
				text = {
					order = 4,
					type = "group",
					name = L["Text"],
					inline = true,
					args = {
						fontName = {
							order = 7,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							desc = L["Select font for the Complex display"],
							values = LSM:HashTable("font"),
							get = function()
								return CS.db.complex.fontName
							end,
							set = function(_,key)
								CS.db.complex.fontName = key
								CS:Initialize()
							end
						},
						fontSize = {
							order = 8,
							type = "range",
							name = L["Font Size"],
							desc = L["Set Font Size"],
							min = 1,
							max = 32,
							step = 1,
							get = function()
								return CS.db.complex.fontSize
							end,
							set = function(info, val)
								CS.db.complex.fontSize = val
								CS:Initialize()
							end
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
							},
							get = function()
								return CS.db.complex.fontFlags
							end,
							set = function(info, val)
								CS.db.complex.fontFlags = val
								CS:Initialize()
							end
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
								CS:Initialize()
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
								return CS.db.complex.stringXOffset
							end,
							set = function(info, val)
								CS.db.complex.stringXOffset = val
								CS:Initialize()
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
								return CS.db.complex.stringYOffset
							end,
							set = function(info, val)
								CS.db.complex.stringYOffset = val
								CS:Initialize()
							end
						}
					}
				}
			}
		},
		simple = {
			order = 3,
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
				spacer0 = {
					order = 1.5,
					type="description",
					name=""
				},
				height = {
					order = 2,
					type = "range",
					name = L["Height"],
					desc = L["Set Frame Height"],
					min = 0,
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
					min = 1,
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
					get = function()
						local r, b, g, a = CS.db.simple.color1.r, CS.db.simple.color1.b, CS.db.simple.color1.g, CS.db.simple.color1.a
						return r, b, g, a
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
					get = function()
						local r, b, g, a = CS.db.simple.color2.r, CS.db.simple.color2.b, CS.db.simple.color2.g, CS.db.simple.color2.a
						return r, b, g, a
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
					get = function()
						local r, b, g, a = CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a
						return r, b, g, a
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
				fontName = {
					order = 8,
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
					order = 9,
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
					order = 10,
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
					order = 11,
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
				},
			}
		},
		weakauras = {
			order = 4,
			type = "group",
			name = L["WeakAuras Interface"],
			cmdHidden  = true,
			args = {
				enable = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					get = function()
						return CS.db.display == "WeakAuras"
					end,
					set = function(info, val)
						if val then
							CS.db.display = "WeakAuras"
							timerFrame:HideChildren()
							timerFrame:Lock()
						end
						CS:Initialize()
					end
				},
				weakaurasString = {
					order = 2,
					type = "input",
					name = L["WeakAuras Import String"],
					desc = L["WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import."],
					width = "full",
					get = function()
						return CS.weakaurasString
					end
				}
			}
		},
		position = {
			order = 5,
			type = "group",
			name = L["Position"],
			inline = true,
			args = {
				lock = {
					order = 1,
					type = "execute",
					name = L["Toggle Lock"],
					desc = L["Shows the frame and toggles it for repositioning."],
					func = function()
						if UnitAffectingCombat("player") then return end
						if CS.db.display == "WeakAuras" then
							print(L["Not possible to unlock in WeakAuras mode!"])
							return
						end
						if not timerFrame.lock then
							timerFrame:Lock()
							CS:Initialize()
						else
							timerFrame:Unlock()
						end
					end
				},
				reset = {
					order = 2,
					type = "execute",
					name = L["Reset Position"],
					cmdHidden = true,
					confirm  = true,
					func = function()
						CS.db.posX = 0
						CS.db.posY = 0
						timerFrame:SetPoint("CENTER", 0, 0)
					end
				}
			}
		},
		sound = {
			order = 6,
			type = "group",
			name = L["Sound"],
			cmdHidden = true,
			args = {
				sound = {
					order = 1,
					type = "toggle",
					name = L["Enable"],
					desc = L["Play Warning Sound when about to cap Shadow Orbs."],
					get = function()
						return CS.db.sound
					end,
					set = function(info, val)
						CS.db.sound = val
					end
				},
				file = {
					order = 2,
					type = "select",
					dialogControl = "LSM30_Sound",
					name = "",
					desc = L["File to play."],
					values = LSM:HashTable("sound"),
					get = function()
						return CS.db.soundHandle
					end,
					set = function(_, key)
						CS.db.soundHandle = key
					end
				},
				width = {
					order = 3,
					type = "range",
					name = L["Interval"],
					desc = L["Time between warning sounds"],
					min = 0.1,
					max = 10,
					step = 0.1,
					get = function()
						return CS.db.soundInterval
					end,
					set = function(info, val)
						CS.db.soundInterval = val
						CS:Initialize()
					end
				},
			}
		}
	}
}
LibStub("AceConfig-3.0"):RegisterOptionsTable("Conspicuous Spirits", optionsTable)
ACD:AddToBlizOptions("Conspicuous Spirits")
ACD:SetDefaultSize("Conspicuous Spirits", 700, 810)
function CS:openOptions()
	ACD:Open("Conspicuous Spirits")
end
CS:RegisterChatCommand("cs", "openOptions")
CS:RegisterChatCommand("csp", "openOptions")
CS:RegisterChatCommand("conspicuousspirits", "openOptions")


CS.defaultSettings = {
	global = {
		posX = 0,
		posY = 0,
		scale = 1,
		complex = {
			height = 8,
			width = 32,
			spacing = 1,
			color1 = {r=0.38, b=0.23, g=0.51, a=1.00},
			color2 = {r=0.51, b=0.00, g=0.24, a=1.00},
			fontSize = 15,
			fontName = "Fritz Quadrata TT",
			fontFlags = "Shadow",
			fontColor = {r=1, b=1, g=1, a=1},
			stringXOffset = 0,
			stringYOffset = 0,
			visibilityConditionals = "[harm] [combat] show; hide",
			orientation = "Horizontal",
			growthDirection = "Regular"
		},
		simple = {
			height = 33,
			width = 65,
			spacing = 20,
			color1 = {r=0.53, b=0.53, g=0.53, a=1.00},  -- lowest threshold color
			color2 = {r=0.38, b=0.23, g=0.51, a=1.00},  -- middle threshold color
			color3 = {r=0.51, b=0.00, g=0.24, a=1.00},  -- highest threshold color
			fontSize = 15,
			fontName = "Fritz Quadrata TT",
			fontFlags = "Shadow",
			fontColor = {r=1, b=1, g=1, a=1}
		},
		display = "Complex",
		sound = false,
		soundHandle = "Droplet",
		soundInterval = 2,
		aggressiveCaching = false,
		aggressiveCachingInterval = 1
	}
}

CS.weakaurasString = "dKeGnbakuPofQKvrQaVsOGzbP6wKQ2LqPFPIcdds6yOOLju9mvkttQQRjK2gPsFdv04eIohQG1PIIAEKkK7bPyFQOuhefQfIcEikexuQInQsvFufLmsvuKojc1kHyMQO6McfANQs)uQsdfsPLsQONkzQO0vfk6RKkOXIk0zvj6TOqQ5Qs4UOqYEv(RkmykhMKfRI8yenzu1LPAZsLpRkgnK40I8AsfQzRQUnPSBb)wkdhblhQNJ00jUUO2Uq47iKXRsLZRsA(QOi2p4XCSRuJDYk6Q4XYmwuJnUEMCQ)PV7koen6kTv8R4h7kS)KAb2Re8vp4wMWkQ)7qBlfKvm0llBVX459Cp7k)ocQaVZpgwfYAS40ZJJP7L5Qe)kgPfOesK5wMcwriHtcfmDiJx9Bk(XUkt9dYVIsxj4SVcRi9XUsl)L0yNmzfFQRlrM)Y1XUsl)L0yNmzLO(Eqg7kT8xsJDYKv423h7kT8xsJDYKvKFfLo2v0u457RqRojUNIDYKjRih7Ezo2vy)j1cSxj4Re)ojJ9v31Bxh1L9QxxDJn6kY2VHh7EzU71LZizgjhygh1Br1Ld6gPURtF0(7n(UpYB30fvo7RlQ9VfjNC2NZ1PpA09EB33x34CgpoNrgnE)BrJQB01Pp6T92FVmNSs87Km2xrCqCCNI0VqXZ3c0lyKwGsirMBzAriHtc9Iy05tQl6fFIgR8OwP45tsQfu)dbNEECmDS7L5yxj40ZJJh7Qm1p6AyTXWkA(KhHhKk31LUB1bJW4I9OyzSozx11WA7L5kpcpiRkrfi9Z4(gw7myCgRwrZN8i8GGwS3LUBvH2Eo)8v5qswr4RU64vzQFKdjzmSkh8i8GSsLL2k5kbFfvusMUImtLM2bkjEFLK0C(jRYbbNEEC8yx11WA7L5KjtwL4x1l(eymxj40ZJJh7k5kbFfvusMUIqJihF0i4yL0WRoB0Skt9dcnIC8yyLhHhKvfkk(grG1l(eDfzMknTdus8(kjP58Ri0iYXRyUkh8i8GSsLL2Qm1pYHKmgMSIOeVGYEVfFviRXItppoMU34RqXtpOi7nYv4MOeFNw9Bk(XUkt9JGhHJ3PvI67bzSR0YFjn2jtwrj4KJDfnfE((EVnzfFQRlrM)Y1XUsl)L0yNmzfwr6JDLw(lPXozYQm1pOeCYXWkC77JDLw(lPXozYkYVIsh7kAk889vOvNe3tXUsl)L0yxHwDsCpf7yyYKvzQFq(vu6yyYQR921rDzV67ZHyJozVXh7kS)KAb2Re8vIFNKX(QR921rDz3RxxoORUrrL5noJu34m73V)603NZv31Bxh1LDV((CYSpNm73VphI8wKOgjNRtFFoxj(Dsg7RioioUtr6xO45Bb6fmslqjKiZTmTiKWjHErm68j1f9IprJvEuRu88jj1cQ)HGtppoMo29YCSReC65XXJDvM6hDnS2yyfnFYJWdsL76s3T6GryCXEuSmwNSR6AyT9YCLhHhKvLOcK(zCFdRDgmoJvRO5tEeEqql27s3TQqBpNF(QCijRi8vxD8Qm1pYHKmgwLdEeEqwPYsBLCLGVIkkjtxrMPst7aLeVVssAo)Kv5GGtppoESR6AyT9YCYKjReC65XXJDLCLGVIkkjtxrOrKJpAeCSsA4vNnAwLP(bHgroEmSYJWdYQcffFJiW6fFIUImtLM2bkjEFLK0C(veAe54vXxLP(roKKXWQCWJWdYkvwAtwL4x1l(eyXxruIxqzV3IVkK1yXPNhht3B8vO4PhuK9g5kCtuIVtR(nf)yxLP(rWJWX70kr99Gm2vA5VKg7KjROeCYXUIMcpFFV3MSIp11LiZF56yxPL)sAStMScRi9XUsl)L0yNmzvM6huco5yyfU99XUsl)L0yNmzf5xrPJDfnfE((k0QtI7PyxPL)sASRqRojUNIDmmzYQm1pi)kkDmmzfz73WJDVm396YzKmJKdmJJ6TO6YbDJu31PpA)9gF3h5TB6IkN91f1(3IKto7Z560hn6EVT77RBCoJhNZiJgV)TOr1n660h92E7VxMtMS3BJDfz73WJDVm396YzKmJKdmJJ6TO6YbDJu31PpA)9gF3h5TB6IkN91f1(3IKto7Z560hn6EVT77RBCoJhNZiJgV)TOr1n660h92E7VxMtwDT3UoQl7E96YbD1nkQmVXzK6gNz)(9xN((CUc7pPwG9kbFL43jzSV6UE76OUSx9OgB0vIFNKX(kIdIJ7uK(fkE(wGEbJ0cucjYCltlcjCsOxeJoFsDrV4t0yLh1kfpFssTG6Fi40ZJJPJDVmh7kbNEEC8yxLP(rxdRngwrZN8i8Gu5UU0DRoyegxShflJ1j7QUgwBVmx5r4bzvjQaPFg33WANbJZy1kA(KhHhe0I9U0DRk02Z5NVkhsYkcF1vhVkt9JCijJHv5GhHhKvQS0wjxj4ROIsY0vKzQ00oqjX7RKKMZpzvoi40ZJJh7QUgwBVmNmzYQe)QEXNa72kbNEEC8yxjxj4ROIsY0veAe54JgbhRKgE1zJMvzQFqOrKJhdR8i8GSQqrX3icSEXNORiZuPPDGsI3xjjnNFfHgroE1Tv5GhHhKvQS0wLP(roKKXWKvHSglo984y6EJVIOeVGYEVfFfkE6bfzVrUc3eL470QFtXp2vzQFe8iC8oTsuFpiJDLw(lPXozYkkbNCSROPWZ337TjR4tDDjY8xUo2vA5VKg7KjRWksFSR0YFjn2jtwLP(bLGtogwHBFFSR0YFjn2jtwr(vu6yxrtHNVVcT6K4Ek2vA5VKg7k0QtI7PyhdtMSkt9dYVIshdtMS3(JDf2FsTa7vc(kXVtYyF11E76OUS71Rlh0v3OOY8gNrQBCM973FD67Z5Q76TRJ6YEVfp2ORe)ojJ9veheh3Pi9lu88Ta9cgPfOesK5wMwes4KqVigD(K6IEXNOXkpQvkE(KKAb1)qWPNhhth7Ezo2vco9844XUkt9JUgwBmSIMp5r4bPYDDP7wDWimUypkwgRt2vDnS2EzUYJWdYQsubs)mUVH1odgNXQv08jpcpiOf7DP7wvOTNZpFvoKKve(QRoEvM6h5qsgdRYbpcpiRuzPTsUsWxrfLKPRiZuPPDGsI3xjjnNFYQCqWPNhhp2vDnS2EzozYKvco9844XUsUsWxrfLKPRi0iYXhncowjn8QZgnRYu)GqJihpgw5r4bzvHIIVrey9IprxrMPst7aLeVVssAo)kcnIC8Q(RYu)ihsYyyvo4r4bzLklTjRs8R6fFcS(RikXlOS3BXxfYAS40ZJJP7n(ku80dkYEJCfUjkX3Pv)MIFSRYu)i4r44DALO(Eqg7kT8xsJDYKvuco5yxrtHNVV3BtwXN66sK5VCDSR0YFjn2jtwHvK(yxPL)sAStMSkt9dkbNCmSc3((yxPL)sAStMSI8RO0XUIMcpFFfA1jX9uSR0YFjn2vOvNe3tXogMmzvM6hKFfLogMSIS9B4XUxM7((6gNZ4X5mYOX7FlAuDJUo9rVT347f19EB3hzFo58MU9rf1(91notM6Uo9rJU3(7L5Kj7n6yxDxVDDux2991fvoWKzFuJmsoCJ5TBXxN((6U6AVDDux2961Ld6QBuuzEJZi1noZ(97Vo995Cf2FsTa7vc(kXVtYyFfz73WJDVm3991noNXJZzKrJ3)w0O6gDD6JEBVX3lQ792UpY(CY5nD7JkQ97RBCMm1DD6JgDV93lZjRe)ojJ9veheh3Pi9lu88Ta9cgPfOesK5wMwes4KqVigD(K6IEXNOXkpQvkE(KKAb1)qWPNhhth7Ezo2vco9844XUkt9JUgwBmSIMp5r4bPYDDP7wDWimUypkwgRt2vDnS2EzUYJWdYQsubs)mUVH1odgNXQv08jpcpiOf7DP7wvOTNZpFvoKKve(QRoEvM6h5qsgdRYbpcpiRuzPTsUsWxrfLKPRiZuPPDGsI3xjjnNFYQCqWPNhhp2vDnS2EzozYKvco9844XUsUsWxrfLKPRi0iYXhncowjn8QZgnRYu)GqJihpgw5r4bzvHIIVrey9IprxrMPst7aLeVVssAo)kcnIC8QORYu)ihsYyyvo4r4bzLklTjRs8R6fFcSORcznwC65XX09gFfrjEbL9El(ku80dkYEJCfUjkX3Pv)MIFSRYu)i4r44DALO(Eqg7kT8xsJDYKvuco5yxrtHNVV3BtwXN66sK5VCDSR0YFjn2jtwHvK(yxPL)sAStMSkt9dkbNCmSc3((yxPL)sAStMSI8RO0XUIMcpFFfA1jX9uSR0YFjn2vOvNe3tXogMmzvM6hKFfLogMmzV6o2v31Bxh1L9QxxDJn6QCqWPNhhp2vKzQ00wPxpyKyxjopyNUc25Fx1PVhSZRWC3tm5cqaKUCGusTa3CbiGbgyGHDjJdGj4SdiEGhqaeabqaeabqaKjRW(tQfyVsWxj(Dsg7RU2Bxh1L9QpoNXgDvIFfJlWyUkfsYbztJW3fNFVmxj(Dsg7RioioUtr6xO45Bb6fmslqjKiZTmTiKWjHErm68j1f9IprJvEuRiB)gES7L5UVpN6gzuMCgpA8OOYboCR)60h92EJV77ZPUrgLjNXJgpkQCGd36Vo9rVT3B7((CQBKrzYz8OXJIkh4WT(RtF0B7T)EzozLkK0usQfg7knvkm2vKTFdRZ9YCfLu9972lQRiB)gMH9YCfz73WN1EzUkt9dbRc0Vs8XWk5kbFfzMknTvKTFdZ49YCLGvb6xj(95a5kSlzCam96bJe7kX5b70vWo)7Qo99GDEfM7EIjxacG0LdKsQf4MaU9GDkfDWOIclCeDWOIclxIoy8(xuCeDW49VOUKlabmWadSuhyHMagrQdffmbfpag2LmoagvuyHJOdgvuy5sWIbW4MaU9GDkfmDay8(xuxYfyEGhqadmWa73ivFWKKMJjMhm0agrQdfnwjP5ykJMjJcqadmWal1bMK0CmX8GjO4babmWadmWadmW(ns1hmSRPsHu4bm0aMK0CmX8XM0iOif2KMdMEWolxytAo3CbiGbgyGbgyGbgbC7b7ukyObmnLGsSAPa3mrhmMGPhmSRPsHu4bSZamMOYfGagyGbgyGbgyyxY4ayurHfoIoyurHLlblgaJBc42d2PuW0bGX7FrDjxacyGbgy(N6GbiGbgyGbgyGbg2LmoagvuyHJOdgvuy5sW0dw84acyGbgyEGhq8apGaiacGaiROKQVFDVOUs9jGIAVOU66E1ZmYv3TxuxjyvG(vIZELGVImtLM2k(mwjPwyftuxrjvF)(CGCf2LmoawxoqkPwGBc42d2Pu0bJkkSWr0bJkkSCj6GrjvFNJOdgLu99l5cqadmWal1bwOjGrK6qrbtqXdGHDjJdGXeDWycMh4beWadmW(ns1hmjP5yI5bdnGrK6qrJvsAoMYOzYOaeWadmW(ns1hmjP5N7DcyObmIuhk6rhwP5Nz2KMFU3jCljnhtmpxacyGbgyPoWKKMJp37eWGZe0agQGjO4babmWadmWadmWWUKXbWOIclCeDWOIclxciGbgyG5FQdgGagyGbgyGbgyyxY4ayus135i6GrjvF)sabmWadmpWdiEGhqaeabqaeabqwHBIs89I6Qm1pOKQVVtROKQVZELGVImtLM2KjRu88jj1cQ)HGtppoMo2jRikXlOS3BXxfYAS40ZJJP7L5kbNEEC8yxLP(bHgroEmSkt9JCijJHvKzQ00oqjX7RiZuPPTsUsWxrMPstBfHgroEfZveAe54JgbhRKgELoALhHhKvfkk(grG1l(eDfzMknTd5kbFLhHhKv5GhHhKvQS0wrMPstBLE9GrIDL48GD6kyN)DvN(EWoVcZDpXKlabq6Ybsj1cCFGoyKTCqqhSg(eLlabmWadmSlzCaSg(efmDeymbtf4bJ7g(efSyamYwoiGD2ObmMCbiEGFfjkoPoELhHhKvEeEqOR0Hm(GXXSqlXmcX9gZ6OqlX6Ky2AYku80dkYEJCfUjkX3Pv)MIFSRYu)i4r44DALO(Eqg7kAk8899gN5kT8xsJDYKvKFfLo2v0u457RqRojUNIDLw(lPXUcT6K4Ek2XWKjRYu)quFpiJHvzQFq(vu6yyfwr6JDLw(lPXozYkC77JDLw(lPXozYQm1pOeCYXWkkbNCSROPWZ337TjRYu)GSPDsjJHv8PUUez(lxh7kT8xsJDYKjt2lNJDvoi40ZJJh7kYmvAAR0RhmsSReNhStxb78VR603d25vyU7jMCbiasxoqkPwGBUaeWadmWWUKXbWeC2bepWdiacGaiacGaiaYKvy)j1cSxj4Re)ojJ9vx7TRJ6YE1hNZyJUsWPNhhp2vzQFqOrKJhdRiZuPPDGsI3xrMPstBLCLGVImtLM2kcnIC8rJGJvsdVshTYJWdYQcffFJiW6fFIUkt9JCijJHvKzQ00oKRe8vEeEqwLdEeEqwPYsBfzMknTv61dgj2vIZd2PRGD(3vD67b78km39etUaeaPlhiLulW9b6Gr2YbbDWA4tuUaeWadmWWUKXbWA4tuW0rGfhmvGhmUB4tuWIbWiB5Ga2zJgWIZfG4bEabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaKvKO4K64vEeEqwrOrKJxfFLhHhe6kDiJpyCml0smJqCVXSok0sSojMTMSkfsYbztJW3fNFVmxj(Dsg7RioioUtr6xO45Bb6fmslqjKiZTmTiKWjHErm68j1f9IprJvEuRUR3UoQl7E995KzFoz2VFFoe5TirnsoxN((CUsfsAkj1cJDLMkfg7kY2VH15EzUIpJvsQfwXe1vKTFdZ49YCfz73WN1EzUkt9dbRc0Vs8XWk5kbFfzMknTvKTFdZWEzUsWQa9Re)(CGCf2LmoaME9GrIDL48GD6kyN)DvN(EWoVcZDpXKlabq6Ybsj1cCta3EWoLIoyurHfoIoyurHLlrhmE)lkoIoy8(xuxYfGagyGbwQdSqtaJi1HIcMGIhad7sghaJkkSWr0bJkkSCjyXayCta3EWoLcMoamE)lQl5cmpWdiGbgyG9BKQpyssZXeZdgAaJi1HIgRK0CmLrhxprQdfn2g(eLrbiGbgyG9BKQpyssZp37eWqdyePou0yztA(5ENWTK0CmX8CbiGbgyGL6atsAoMyEWeu8aGagyGbgyGbgy)gP6dg21uPqk8agAatsAoMy(ytAeuKcBsZbtpyNLlSjnNBUaeWadmWadmWaJaU9GDkfm0aMMsqjwTuGBMOdgtW0dg21uPqk8a2zagtu5cqadmWadmWadmSlzCamQOWchrhmQOWYLGfdGXnbC7b7uky6aW49VOUKlabmWadm)tDWaeWadmWadmWad7sghaJkkSWr0bJkkSCjy6blECabmWadmpWdiEGFfLu99R7f1vQpbuu7f1vus13VBVOU66E1ZmYv3TxuxjyvG(vIZELGVImtLM2kkP673NdKRWUKXbW6Ybsj1cCta3EWoLIoyurHfoIoyurHLlrhmkP67CeDWOKQVFjxacyGbgyPoWcnbmIuhkkyckEamSlzCamMOdgtW8apGagyGb2VrQ(GjjnhtmpyObmIuhkASssZXugDC9ePou0yB4tugfGagyGb2VrQ(Gjjn)CVtadnGrK6qrp6Wkn)mZM08Z9oHBjP5yI55cqadmWal1bMK0C85ENagCMGgWqfmbfpaiGbgyGbgyGbg2LmoagvuyHJOdgvuy5sabmWadm)tDWaeWadmWadmWad7sghaJsQ(ohrhmkP67xciGbgyG5bEaXd8acGaiacGaiaYkCtuIVxuxLP(bLu99DAfLu9D2Re8vKzQ00MmzLINpjPwq9peC65XX0XozfrjEbL9El(QqwJfNEECmDVmxL4xX4cS4RqXtpOi7nYv4MOeFNw9Bk(XUkt9JGhHJ3PvI67bzSROPWZ33BCMR0YFjn2jtwr(vu6yxrtHNVVcT6K4Ek2vA5VKg7k0QtI7PyhdtMSkt9dr99GmgwLP(b5xrPJHvyfPp2vA5VKg7KjRWTVp2vA5VKg7KjRYu)GsWjhdROeCYXUIMcpFFV3MSkt9dYM2jLmgwXN66sK5VCDSR0YFjn2jtMSIS9B4XUxM7((CQBKrzYz8OXJIkh4WT(RtF0B7n(UVpN6gzuMCgpA8OOYboCR)60h92EVT77ZPUrgLjNXJgpkQCGd36Vo9rVT3(7L5Kj7nYXU6UE76OUSx9OgB0v5GGtppoESRiZuPPTsVEWiXUsCEWoDfSZ)UQtFpyNxH5UNyYfGaiD5aPKAbU5cqadmWad7sghatWzhq8apGaiacGaiacGaitwH9NulWELGVs87Km2xr2(n8y3lZDFFo1nYOm5mE04rrLdC4w)1Pp6T9gF33NtDJmktoJhnEuu5ahU1FD6JEBV32995u3iJYKZ4rJhfvoWHB9xN(O32B)9YCYQe)kgxGDBvkKKdYMgHVlo)EzUs87Km2xrCqCCNI0VqXZ3c0lyKwGsirMBzAriHtc9Iy05tQl6fFIgR8OwPcjnLKAHXUstLcJDLGvb6xjo7vc(kYmvAAROKQVF3ErDfz73WmSxMRiB)g(S2lZvzQFiyvG(vIpgwjxj4RiZuPPTIS9BygVxMReSkq)kXVphixHDjJdGPxpyKyxjopyNUc25Fx1PVhSZRWC3tm5cqaKUCGusTa3eWThStPOdgvuyHJOdgvuy5s0bJ3)IIJOdgV)f1LCbiGbgyGL6al0eWisDOOGjO4bWWUKXbWOIclCeDWOIclxcwmag3eWThStPGPdaJ3)I6sUaZd8acyGbgy)gP6dMK0CmX8GHgWisDOOXkjnhtz030tK6qrJTHprzuacyGbgy)gP6dMK08Z9obm0agrQdfnw2KMFU3jCljnhtmpxacyGbgyPoWKKMJjMhmbfpaiGbgyGbgyGb2VrQ(GHDnvkKcpGHgWKKMJjMp2KgbfPWM0CW0d2z5cBsZ5MlabmWadmWadmWiGBpyNsbdnGPPeuIvlf4Mj6GXem9GHDnvkKcpGDgGXevUaeWadmWadmWad7sghaJkkSWr0bJkkSCjyXayCta3EWoLcMoamE)lQl5cqadmWaZ)uhmabmWadmWadmWWUKXbWOIclCeDWOIclxcMEWIhhqadmWaZd8aIh4xrjvF)6ErDL6taf1ErDfFgRKulSIjQRUUx9mJC1D7f1vKTFdRZ9YCfLu997ZbYvyxY4ayD5aPKAbUjGBpyNsrhmQOWchrhmQOWYLOdgLu9DoIoyus13VKlabmWadSuhyHMagrQdffmbfpag2Lmoagt0bJjyEGhqadmWa73ivFWKKMJjMhm0agrQdfnwjP5ykJ(MEIuhkASn8jkJcqadmWa73ivFWKKMFU3jGHgWisDOOhDyLMFMztA(5ENWTK0CmX8CbiGbgyGL6atsAo(CVtadotqdyOcMGIhaeWadmWadmWad7sghadv0bdvabmWadm)tDWaeWadmWadmWad7sghaJj6GXeqadmWaZd8aIh4beabqaeabqaKv4MOeFVOUkt9dkP6770kkP67Sxj4RiZuPPnzYkIs8ck79w8vkE(KKAb1)qWPNhhth7KvHSglo984y6EzUsWPNhhp2vzQFqOrKJhdRYu)ihsYyyfzMknTdus8(kYmvAARKRe8vKzQ00wrOrKJxDBfHgro(OrWXkPHxPJw5r4bzfJGIsalgDkv94RiZuPPDixj4R8i8GSkh8i8GSsLL2kYmvAAR0RhmsSReNhStxb78VR603d25vyU7jMCbiasxoqkPwG7d0bJSLdc6G1WNOCbiGbgyGHDjJdG1WNOGPJa7gyQapyC3WNOGfdGr2YbbSZgnGDJlaXd8acGaiacGaiacGaiacGaiacGaiacGaiacGaiacGaiacGaiacGaiRirXj1XR8i8GSYJWdcDLoKXhmoMfAjMriU3ywhfAjwNeZwtwHINEqr2BKRWnrj(oT63u8JDvM6hbpchVtRe13dYyxrtHNVV34mxPL)sAStMSI8RO0XUIMcpFFfA1jX9uSR0YFjn2vOvNe3tXogMmzvM6hI67bzmSkt9dYVIshdRWksFSR0YFjn2jtwHBFFSR0YFjn2jtwLP(bLGtogwrj4KJDfnfE((EVnzvM6hKnTtkzmSIp11LiZF56yxPL)sAStMmz11E76OUSx9X5m2Ot2lhg7kY2VHh7EzU77ZPUrgLjNXJgpkQCGd36Vo9rVT347((CQBKrzYz8OXJIkh4WT(RtF0B792UVpN6gzuMCgpA8OOYboCR)60h92E7VxMtwDT3UoQl7vFCoJn6kS)KAb2Re8vIFNKX(kbNEEC8yxLP(bHgroEmSImtLM2bkjEFfzMknTvYvc(kYmvAARi0iYXhncowjn8kD0kpcpiRkuu8nIaRx8j6Qm1pYHKmgwrMPst7qUsWx5r4bzvo4r4bzLklTvKzQ00wPxpyKyxjopyNUc25Fx1PVhSZRWC3tm5cqaKUCGusTa3hOdgzlhe0bRHpr5cqadmWad7sghaRHprbthbwFWubEW4UHprblgaJSLdcyNnAaRpxaIh4beabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqwrIItQJx5r4bzfHgroEv)vEeEqOR0Hm(GXXSqlXmcX9gZ6OqlX6Ky2AYQuijhKnncFxC(9YCLIusTaDSR6sHefLXUIVDqMPstBNMmzL43jzSVI4G44ofPFHINVfOxWiTaLqIm3Y0IqcNe6fXOZNux0l(enw5rT6UE76OUS3BXJn6kviPPKulm2vAQuySROKQVFFoqUc7sghaRlhiLulWnbC7b7uk6Grffw4i6GrffwUeDWOKQVZr0bJsQ((LCbiGbgyGL6al0eWisDOOGjO4bWWUKXbWyIoymbZd8acyGbgy)gP6dMK0CmX8GHgWisDOOXkjnhtz091tK6qrJTHprzuacyGbgy)gP6dMK08Z9obm0agrQdf9OdR08ZmBsZp37eULKMJjMNlabmWadSuhyssZXN7DcyWzcAadvWeu8aGagyGbgyGbgyyxY4ayOIoyOciGbgyG5FQdgGagyGbgyGbgyyxY4aymrhmMacyGbgyEGhq8apGaiacGaiacGSkt9dkP6770kY2VHzyVmxr2(n8zTxMRYu)qWQa9ReFmSIsQ(o7vc(kYmvAAReSkq)kXzVsWxrMPstBfbStDzL6taffAZFQVsWQa9Re)(CGCf2LmoaME9GrIDL48GD6kyN)DvN(EWoVcZDpXKlabq6Ybsj1cCta3EWoLIoyurHfoIoyurHLlrhmE)lkoIoy8(xuxYfGagyGbwQdSqtaJi1HIcMGIhad7sghaJkkSWr0bJkkSCjyXayCta3EWoLcMoamE)lQl5cmpWdiGbgyG9BKQpyssZXeZdgAaJi1HIgRK0CmLr3xprQdfn2g(eLrbiGbgyG9BKQpyssZp37eWqdyePou0yztA(5ENWTK0CmX8CbiGbgyGL6atsAoMyEWeu8aGagyGbgyGbgy)gP6dg21uPqk8agAatsAoMy(ytAeuKcBsZbtpyNLlSjnNBUaeWadmWadmWaJaU9GDkfm0aMMsqjwTuGBMOdgtW0dg21uPqk8a2zagtu5cqadmWadmWadmSlzCamQOWchrhmQOWYLGfdGXnbC7b7uky6aW49VOUKlabmWadm)tDWaeWadmWadmWad7sghaJkkSWr0bJkkSCjy6blECabmWadmpWdiEGFfLu99R7f1vQpbuu7f1vus13VBVOU66E1ZmYv3Txuxr2(nmJ3lZvYvc(kYmvAARWnrj(ErDfFgRKulSIjQRiB)gwN7L5KjRu88jj1cQ)HGtppoMo2jRikXlOS3BXxfYAS40ZJJP7L5Qe)kgxG1FfkE6bfzVrUc3eL470QFtXp2vzQFe8iC8oTsuFpiJDfnfE((EJZCLw(lPXozYkYVIsh7kAk889vOvNe3tXUsl)L0yxHwDsCpf7yyYKvzQFiQVhKXWQm1pi)kkDmScRi9XUsl)L0yNmzfU99XUsl)L0yNmzvM6huco5yyfLGto2v0u457792KvzQFq20oPKXWk(uxxIm)LRJDLw(lPXozYKv5GGtppoESRiZuPPTsVEWiXUsCEWoDfSZ)UQtFpyNxH5UNyYfGaiD5aPKAbU5cqadmWad7sghatWzhq8apGaiacGaiaYKj7LjQJDvoi40ZJJh7kYmvAAR0RhmsSReNhStxb78VR603d25vyU7jMCbiasxoqkPwGBUaeWadmWWUKXbWeC2bepWdiacGaiacGaiaYKvy)j1cSxj4Re)ojJ9v31Bxh1L9QB0yJUsWPNhhp2vzQFqOrKJhdRiZuPPDGsI3xrMPstBLCLGVImtLM2kcnIC8rJGJvsdVshTYJWdYQcffFJiW6fFIUkt9JCijJHvKzQ00oKRe8vEeEqwLdEeEqwPYsBfzMknTv61dgj2vIZd2PRGD(3vD67b78km39etUaeaPlhiLulW9b6Gr2YbbDWA4tuUaeWadmWWUKXbWA4tuW0rGffmvGhmUB4tuWIbWiB5Ga2zJgWIYfG4bEabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaeabqaKvKO4K64vEeEqwrOrKJxfDLhHhe6kDiJpyCml0smJqCVXSok0sSojMTMSkfsYbztJW3fNFVmxPiLulqh7kQOWYyxrB5a)bjkQqW)RIrfvC8kAlh4xrCqCCNI0VGX889gOxOdDLoMXzSIErm68j1fvlh4PxW6Ae(od()FMMF8yBppR4Bh0woWVttMSs87Km2xrCqCCNI0VqXZ3c0lyKwGsirMBzAriHtc9Iy05tQl6fFIgR8Owr2(n8y3lZDFFo1nYOm5mE04rrLdC4w)1Pp6T9gF33NtDJmktoJhnEuu5ahU1FD6JEBV32995u3iJYKZ4rJhfvoWHB9xN(O32B)9YCYkviPPKulm2vAQuySReSkq)kXzVsWxrMPstBfLu9972lQRiB)gMH9YCfz73WN1EzUkt9dbRc0Vs8XWk5kbFfzMknTvKTFdZ49YCLGvb6xj(95a5kSlzCam96bJe7kX5b70vWo)7Qo99GDEfM7EIjxacG0LdKsQf4MaU9GDkfDWOIclCeDWOIclxIoy8(xuCeDW49VOUKlabmWadSuhyHMagrQdffmbfpag2LmoagvuyHJOdgvuy5sWIbW4MaU9GDkfmDay8(xuxYfyEGhqadmWa73ivFWKKMJjMhm0agrQdfnwjP5ykJoQEIuhkASn8jkJcqadmWa73ivFWKKMFU3jGHgWisDOOXYM08Z9oHBjP5yI55cqadmWal1bMK0CmX8GjO4babmWadmWadmW(ns1hmSRPsHu4bm0aMK0CmX8XM0iOif2KMdMEWolxytAo3CbiGbgyGbgyGbgbC7b7ukyObmnLGsSAPa3mrhmMGPhmSRPsHu4bSZamMOYfGagyGbgyGbgyyxY4ayurHfoIoyurHLlblgaJBc42d2PuW0bGX7FrDjxacyGbgy(N6GbiGbgyGbgyGbg2LmoagvuyHJOdgvuy5sW0dw84acyGbgyEGhq8a)kkP67x3lQRuFcOO2lQR4ZyLKAHvmrD119QNzKRUBVOUIS9ByDUxMROKQVFFoqUc7sghaRlhiLulWnbC7b7uk6Grffw4i6GrffwUeDWOKQVZr0bJsQ((LCbiGbgyGL6al0eWisDOOGjO4bWWUKXbWyIoymbZd8acyGbgy)gP6dMK0CmX8GHgWisDOOXkjnhtz0r1tK6qrJTHprzuacyGbgy)gP6dMK08Z9obm0agrQdf9OdR08ZmBsZp37eULKMJjMNlabmWadSuhyssZXN7DcyWzcAadvWeu8aGagyGbgyGbgyyxY4ayOIoyOciGbgyG5FQdgGagyGbgyGbgyyxY4aymrhmMacyGbgyEGhq8apGaiacGaiRWnrj(ErDvM6hus133Pvus13zVsWxrMPstBYKveL4fu27T4Ru88jj1cQ)HGtppoMo2jRcznwC65XX09YCvIFfJlWIUcfp9GIS3ixHBIs8DA1VP4h7Qm1pcEeoENwjQVhKXUIMcpFFVXzUsl)L0yNmzf5xrPJDfnfE((k0QtI7PyxPL)sASRqRojUNIDmmzYQm1pe13dYyyvM6hKFfLogwHvK(yxPL)sAStMSc3((yxPL)sAStMSkt9dkbNCmSIsWjh7kAk8899EBYQm1piBANuYyyfFQRlrM)Y1XUsl)L0yNmzYQR921rDzV6JZzSrNSxMmh7Q76TRJ6YE5qKXgDvoi40ZJJh7kYmvAAR0RhmsSReNhStxb78VR603d25vyU7jMCbiasxoqkPwGBUaeWadmWWUKXbWeC2bepWdiacGaiacGaiaYKvy)j1cSxj4Re)ojJ9vKTFdp29YC33x34CgpoNrgnE)BrJQB01Pp6T9gFVOU3B7(i7ZjN30TpQO2VVUXzYu31PpA092FVmNSkfsYbztJW3fNFVmxPiLulqh7kQOWYyxX3oOTCGFNwrB5a)kIdIJ7uK(fmMNV3a9cDOR0XmoJv0lIrNpPUOA5ap9cwxJW3zW))Z08JhB75zfTLd8hKOOcb)VkgvuXXtMSs87Km2xrCqCCNI0VqXZ3c0lyKwGsirMBzAriHtc9Iy05tQl6fFIgR8OwP45tsQfu)dbNEECmDStwL4xX4cSOXWkviPPKulm2vAQuySReSkq)kXzVsWxrMPstBfLu9972lQRiB)gMH9YCfz73WN1EzUkt9dbRc0Vs8XWk5kbFfzMknTvKTFdZ49YCLGvb6xj(95a5kSlzCam96bJe7kX5b70vWo)7Qo99GDEfM7EIjxacG0LdKsQf4MaU9GDkfDWOIclCeDWOIclxIoy8(xuCeDW49VOUKlabmWadSuhyHMagrQdffmbfpag2LmoagvuyHJOdgvuy5sWIbW4MaU9GDkfmDay8(xuxYfyEGhqadmWa73ivFWKKMJjMhm0agrQdfnwjP5ykJwx9ePou0yB4tugfGagyGb2VrQ(Gjjn)CVtadnGrK6qrJLnP5N7Dc3ssZXeZZfGagyGbwQdmjP5yI5btqXdacyGbgyGbgyG9BKQpyyxtLcPWdyObmjP5yI5JnPrqrkSjnhm9GDwUWM0CU5cqadmWadmWadmc42d2PuWqdyAkbLy1sbUzIoymbtpyyxtLcPWdyNbymrLlabmWadmWadmWWUKXbWOIclCeDWOIclxcwmag3eWThStPGPdaJ3)I6sUaeWadmW8p1bdqadmWadmWadmSlzCamQOWchrhmQOWYLGPhS4XbeWadmW8apG4b(vus13VUxuxP(eqrTxuxXNXkj1cRyI6QR7vpZixD3ErDfz73W6CVmxrjvF)(CGCf2LmoawxoqkPwGBc42d2Pu0bJkkSWr0bJkkSCj6GrjvFNJOdgLu99l5cqadmWal1bwOjGrK6qrbtqXdGHDjJdGXeDWycMh4beWadmW(ns1hmjP5yI5bdnGrK6qrJvsAoMYO1vprQdfn2g(eLrbiGbgyG9BKQpyssZp37eWqdyePou0JoSsZpZSjn)CVt4wsAoMyEUaeWadmWsDGjjnhFU3jGbNjObmubtqXdacyGbgyGbgyGHDjJdGHk6GHkGagyGbM)PoyacyGbgyGbgyGHDjJdGXeDWyciGbgyG5bEaXd8acGaiacGaiaYkCtuIVxuxLP(bLu99DAfLu9D2Re8vKzQ00MmzLGtppoESRYu)GqJihpgwjxj4RiZuPPTIqJihF0i4yL0WR0rRiZuPPDixj4R8i8GSYJWdYQcffFJiW6fFIUkh8i8GSsLL2kcnIC8QORiZuPPTsVEWiXUsCEWoDfSZ)UQtFpyNxH5UNyYfGaiD5aPKAbUpqhmYwoiOdwdFIYfGagyGbg2LmoawdFIcwmagzlheWoB0aMUaIh4xLP(roKKXWksuCsD8kpcpiR8i8GqxPdz8bJJzHwIzeI7nM1rHwI1jXS1kYmvAAhOK49vKzQ00MSIOeVGYEVfFviRXItppoMUxMRqXtpOi7nYv4MOeFNw9Bk(XUkt9JGhHJ3PvI67bzSROPWZ33BCMR0YFjn2jtwrj4KJDfnfE((EVnzvM6hI67bzmSIp11LiZF56yxPL)sAStMScRi9XUsl)L0yNmzf5xrPJDfnfE((k0QtI7PyxPL)sASRqRojUNIDmmzYQm1pOeCYXWQm1pi)kkDmSkt9dYM2jLmgwHBFFSR0YFjn2jtMS6AVDDux2R(4CgB0j7Lz8XUIprj8vxz97KvRYbbNEEC8yxrMPstBLE9GrIDL48GD6kyN)DvN(EWoVcZDpXKlabq6Ybsj1cCZfGagyGbg2LmoaMGZoG4bEabqaeabqaKjRuKsQfOJDfvuyzSR4Bh0woWpgwrB5a)kIdIJ7uK(fmMNV3a9cDOR0XmoJv0lIrNpPUOA5ap9cwxJW3zW))Z08JhB75zfTLd8hKOOcb)VkgvuXXtMSc7pPwG9kbFL43jReC65XXJDLCLGVImtLM2k(mwjPwyfQRiZuPPTsVEWiXUsCEWoDfSZ)UQtFpyNxH5UNyYfGaiD5aPKAbUpqhmYwoiOdwdFIYfGagyGbwQdSqtaJi1HIcMGIhad7sghaZd8acyGbgyPoWcnbmIuhk6bTLd8hssZbRHb7SCHnP5CZfy6bJi1HIEqB5a)HK0CWoBWIdMGIhaeWadmWadmWaJi1HIEqB5a)HK0CWqdyNLlSjnNBUaeWadmWadmWad7sghaRHprb7SrZnWubEWiB5GawmawdFIc2zJgWIciGbgyG5bEaXd8acGaiacGaiacGaiacGaiacGaiacGaiacGaiacGaiR8i8GqxPdz8bJJzHwIzeI7nM1rHwI1jXS1ksuCsD8kpcpiRiZuPPDixj4R8i8GSImtLM2bkjEFLK0C(jRikXlOS77hf1BrYzuu7hNz)iVfn(60hn(Qe)kgxGvTCGFviRXItppoMUxMRqXtpOi7((rr9wKCgf1(Xz2pYBrJVo9rJV63u8JDvM6hbpchVtRe13dYyxrtHNVV34mxPL)sAStMSI8RO0XUIMcpFFfA1jX9uStwLP(HO(EqgdR4tDDjY8xUo2vA5VKg7KjRWksFSR0YFjn2jtwHBFFSR0YFjn2jtwLP(bLGtogwLP(b5xrPJHvzQFq20oPKXWkkbNCSROPWZ337TjtMmzve7Lz)4mNSb"

function CS:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
	
	if self.db.display == "Complex" then
		self:initializeComplex()
	elseif self.db.display == "Simple" then
		self:initializeSimple()
	elseif self.db.display == "WeakAuras" then
		self:initializeWeakAuras()
	end
end