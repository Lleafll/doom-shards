local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and Libraries and stuff
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits")
LibStub("AceEvent-3.0"):Embed(CS)
LibStub("AceTimer-3.0"):Embed(CS)
LibStub("AceConsole-3.0"):Embed(CS)


-- Upvalues
local UnitAffectingCombat, print, InterfaceOptionsFrame_OpenToCategory = UnitAffectingCombat, print, InterfaceOptionsFrame_OpenToCategory


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
		GameTooltip:AddLine("Left mouse button to drag.", 1, 1, 1, 1, 1, 1)
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
	timerFrame.lock = false
	print("Conspicuous Spirits unlocked!")
end

function timerFrame:Lock()
	timerFrame.texture:Hide()
	timerFrame:EnableMouse(false)
	timerFrame:SetScript("OnEnter", nil)
	timerFrame:SetScript("OnLeave", nil)
	timerFrame:SetScript("OnMouseDown", nil)
	timerFrame:SetScript("OnMouseUp", nil)
	if not timerFrame.lock then print("Conspicuous Spirits locked!") end
	timerFrame.lock = true
end


-- Options
local optionsTable = {
	type = "group",
	name = "Conspicuous Spirits",
	args = {
		config = {
			order = 0,
			type = "execute",
			name = "Open Configuration Window",
			guiHidden = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory("Conspicuous Spirits")
				InterfaceOptionsFrame_OpenToCategory("Conspicuous Spirits")  -- calling twice because bugs suck
			end
		},
		display = {
			order = 1,
			type = "group",
			name = "Display",
			inline = true,
			args = {
				scale = {
					order = 2,
					type = "range",
					name = "Scale",
					desc = "Set Frame Scale",
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
				display = {
					order = 1,
					type = "select",
					style = "dropdown",
					name = "Choose Display Type",
					cmdHidden  = true,
					values = {
						["Complex"] = "Complex",
						["Simple"] = "Simple",
						["WeakAuras"] = "WeakAuras"
					},
					get = function()
						return CS.db.display
					end,
					set = function(info, val)
						CS.db.display = val
						CS:Initialize()
						if val == "WeakAuras" then timerFrame:Lock() end
					end
				}
			}
		},
		complex = {
			order = 2,
			type = "group",
			name = "Complex Display",
			hidden = function()
				if CS.db then
					return not (CS.db.display == "Complex")
				else
					return false
				end
			end,
			cmdHidden  = true,
			inline = true,
			args = {
				height = {
					order = 1,
					type = "range",
					name = "Height",
					desc = "Set Shadow Orb Height",
					min = 0,
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
					name = "Width",
					desc = "Set Shadow Orb Width",
					min = 0,
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
					name = "Spacing",
					desc = "Set Shadow Orb Spacing",
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
				color1 = {
					order = 4,
					type = "color",
					name = "Color 1",
					desc = "Set Color 1",
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
					name = "Color 2",
					desc = "Set Color 2",
					get = function()
						local r, b, g, a = CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a
						return r, b, g, a
					end,
					set = function(info, r, b, g, a)
						CS.db.complex.color2.r, CS.db.complex.color2.b, CS.db.complex.color2.g, CS.db.complex.color2.a = r, b, g, a
						CS:Initialize()
					end
				},
				outofcombat = {
					order = 6,
					type = "toggle",
					name = "Show Orbs out of combat",
					desc = "Will show Shadow Orbs frame even when not in combat.",
					get = function()
						return CS.db.outofcombat
					end,
					set = function(info, val)
						CS.db.outofcombat = val
						if val then
							if CS.db.display == "Complex" then timerFrame:Show() end
							print("CS now shows out of combat.")
						else
							if CS.db.display == "Complex" and not UnitAffectingCombat("player") then timerFrame:Hide() end
							print("CS hidden out of combat.")
						end
					end
				}
			}
		},
		simple = {
			order = 2,
			type = "group",
			name = "Simple Display",
			hidden = function()
				if CS.db then
					return not (CS.db.display == "Simple")
				else
					return false
				end
			end,
			cmdHidden  = true,
			inline = true,
			args = {
				height = {
					order = 1,
					type = "range",
					name = "Height",
					desc = "Set Frame Height",
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
					order = 2,
					type = "range",
					name = "Width",
					desc = "Set Frame Width",
					min = 0,
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
					order = 3,
					type = "range",
					name = "Spacing",
					desc = "Set Number Spacing",
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
				color1 = {
					order = 4,
					type = "color",
					name = "Color 1",
					desc = "Set Color 1",
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
					order = 5,
					type = "color",
					name = "Color 2",
					desc = "Set Color 2",
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
					order = 6,
					type = "color",
					name = "Color 3",
					desc = "Set Color 3",
					get = function()
						local r, b, g, a = CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a
						return r, b, g, a
					end,
					set = function(info, r, b, g, a)
						CS.db.simple.color3.r, CS.db.simple.color3.b, CS.db.simple.color3.g, CS.db.simple.color3.a = r, b, g, a
						CS:Initialize()
					end
				},
				fontSize = {
					order = 7,
					type = "range",
					name = "Font Size",
					desc = "Set Font Size",
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
				}
			}
		},
		weakauras = {
			order = 4,
			type = "group",
			name = "WeakAuras String",
			hidden = function()
				if CS.db then
					return not (CS.db.display == "WeakAuras")
				else
					return false
				end
			end,
			cmdHidden  = true,
			inline = true,
			args = {
				weakauras = {
					order = 1,
					type = "input",
					name = "",
					desc = "WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import.",
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
			name = "Position",
			inline = true,
			args = {
				lock = {
					order = 1,
					type = "execute",
					name = "Toggle Lock",
					desc = "Shows the frame and toggles it for repositioning.",
					func = function()
						if UnitAffectingCombat("player") then return end
						if CS.db.display == "WeakAuras" then
							print("Not possible to unlock in WeakAuras mode!")
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
					name = "Reset Position",
					cmdHidden  = true,
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
			name = "Sound",
			inline = true,
			args = {
				sound = {
					order = 6,
					type = "toggle",
					name = "Warning Sound",
					desc = "Play Warning Sound when about to cap Shadow Orbs.",
					get = function()
						return CS.db.sound
					end,
					set = function(info, val)
						CS.db.sound = val
						if val then
							PlaySoundFile("Interface\\addons\\ConspicuousSpirits\\Media\\CSDroplet.mp3", "Master")
						end
					end
				}
			}
		},
		reset = {
			order = 7,
			type = "group",
			name = "Reset",
			cmdHidden  = true,
			inline = true,
			args = {
				reset = {
					order = 1,
					type = "execute",
					name = "Reset to Defaults",
					confirm = true,
					func = function()
						CS:ResetDB()
						print("Conspicuous Spirits reset!")
						CS:getDB()
						CS:Initialize()
					end
				}
			}
		}
	}
}
LibStub("AceConfig-3.0"):RegisterOptionsTable("Conspicuous Spirits", optionsTable, {"cs", "csp", "conspicuousspirits"})
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Conspicuous Spirits")


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
			color2 = {r=0.51, b=0.00, g=0.24, a=1.00}
		},
		simple = {
			height = 33,
			width = 65,
			spacing = 20,
			color1 = {r=0.53, b=0.53, g=0.53, a=1.00},  -- lowest threshold color
			color2 = {r=0.38, b=0.23, g=0.51, a=1.00},  -- middle threshold color
			color3 = {r=0.51, b=0.00, g=0.24, a=1.00},  -- highest threshold color
			fontSize = 15
		},
		outofcombat = true,
		display = "Complex",
		sound = false
	}
}

function CS:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
end