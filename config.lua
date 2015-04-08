local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and Libraries and stuff
local ASTimer = LibStub("AceAddon-3.0"):NewAddon("AS Timer")
LibStub("AceEvent-3.0"):Embed(ASTimer)
LibStub("AceTimer-3.0"):Embed(ASTimer)
LibStub("AceConsole-3.0"):Embed(ASTimer)


-- Upvalues
local UnitAffectingCombat, print, InterfaceOptionsFrame_OpenToCategory = UnitAffectingCombat, print, InterfaceOptionsFrame_OpenToCategory


-- Frames
ASTimer.frame = CreateFrame("frame", "ASTimerFrame", UIParent)
local timerFrame = ASTimer.frame
timerFrame:SetFrameStrata("MEDIUM")
timerFrame:SetMovable(true)
timerFrame.lock = true
timerFrame.texture = timerFrame:CreateTexture(nil, "BACKGROUND")
timerFrame.texture:SetAllPoints(timerFrame)
timerFrame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
timerFrame.texture:Hide()

function timerFrame:HideChildren() end

function timerFrame:Unlock()
	timerFrame:Show()
	timerFrame.texture:Show()
	timerFrame:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Auspicious Spirits Timer", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:AddLine("Left mouse button to drag.", 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	timerFrame:SetScript("OnLeave", function(s) GameTooltip:Hide() end)
	timerFrame:SetScript("OnMouseDown", timerFrame.StartMoving)
	timerFrame:SetScript("OnMouseUp", function(self, button)
			self:StopMovingOrSizing()
			local _, _, _, posX, posY = self:GetPoint()
			ASTimer.db.posX = posX
			ASTimer.db.posY = posY
		end
	)
	timerFrame.lock = false
	print("AS Timer unlocked!")
end

function timerFrame:Lock()
	timerFrame.texture:Hide()
	timerFrame:EnableMouse(false)
	timerFrame:SetScript("OnEnter", nil)
	timerFrame:SetScript("OnLeave", nil)
	timerFrame:SetScript("OnMouseDown", nil)
	timerFrame:SetScript("OnMouseUp", nil)
	if not timerFrame.lock then print("AS Timer locked!") end
	timerFrame.lock = true
end


-- Options
local optionsTable = {
	type = "group",
	name = "Auspicious Spirits Timer",
	args = {
		config = {
			order = 0,
			type = "execute",
			name = "Open Configuration Window",
			guiHidden = true,
			func = function()
				InterfaceOptionsFrame_OpenToCategory("Auspicious Spirits Timer")
				InterfaceOptionsFrame_OpenToCategory("Auspicious Spirits Timer")  -- calling twice because bugs suck
			end
		},
		display = {
			order = 1,
			type = "group",
			name = "Display",
			inline = true,
			args = {
				lock = {
					order = 4,
					type = "execute",
					name = "Toggle Lock",
					desc = "Shows the frame and toggles it for repositioning.",
					func = function()
						if UnitAffectingCombat("player") then return end
						if not timerFrame.lock then
							if not (ASTimer.db.display == "Complex") or not ASTimer.db.outofcombat then
								timerFrame:Hide()
							end
							timerFrame:Lock()
						else
							timerFrame:Unlock()
						end
					end
				},
				reset = {
					order = 5,
					type = "execute",
					name = "Reset Position",
					desc = "Reset Frame Position.",
					confirm  = true,
					func = function()
						local posX = ASTimer.defaultSettings.global.posX
						local posY = ASTimer.defaultSettings.global.posY
						ASTimer.db.posX = posX
						ASTimer.db.posY = posY
						timerFrame:SetPoint("CENTER", posX, posY)
					end
				},
				scale = {
					order = 2,
					type = "range",
					name = "Set Scale",
					desc = "Set Frame Scale",
					min = 0,
					max = 3,
					step = 0.01,
					get = function()
						return timerFrame:GetScale()
					end,
					set = function(info, val)
						ASTimer.db.scale = val
						timerFrame:SetScale(val)
					end
				},
				outofcombat = {
					order = 3,
					type = "toggle",
					name = "Show Orbs out of combat",
					desc = "Will show Shadow Orbs frame even when not in combat. Only applies to the \"Complex\" display.",
					get = function()
						return ASTimer.db.outofcombat
					end,
					set = function(info, val)
						ASTimer.db.outofcombat = val
						if val then
							if ASTimer.db.display == "Complex" then timerFrame:Show() end
							print("ASTimer now shows out of combat.")
						else
							if ASTimer.db.display == "Complex" and not UnitAffectingCombat("player") then timerFrame:Hide() end
							print("ASTimer hidden out of combat.")
						end
					end
				},
				display = {
					order = 1,
					type = "select",
					style = "dropdown",
					name = "Choose Display Type",
					values = {
						["Complex"] = "Complex",
						["Simple"] = "Simple",
						["Weakauras"] = "Weakauras"
					},
					get = function()
						return ASTimer.db.display
					end,
					set = function(info, val)
						ASTimer.db.display = val
						ASTimer:OnInitialize()
						print("AS Timer is now in "..val.." mode.")
					end
				}
			}
		},
		weakauras = {
			order = 2,
			type = "group",
			name = "Weakauras String",
			hidden = function()
				if ASTimer.db then
					return not (ASTimer.db.display == "Weakauras")
				else
					return false
				end
			end,
			inline = true,
			args = {
				weakauras = {
					order = 1,
					type = "input",
					name = "",
					desc = "Weakauras String to use when \"Weakauras\" Display is selected. Copy & paste into WeakAuras to import.",
					width = "full",
					get = function()
						return ASTimer.weakaurasString
					end
				}
			}
		},
		sound = {
			order = 3,
			type = "group",
			name = "Sound",
			inline = true,
			args = {
				sound = {
					order = 6,
					type = "toggle",
					name = "Warning Sound",
					desc = "Play Warning Sound when about to cap Shadow Orbs. Does not work in \"WeakAuras\" mode.",
					get = function()
						return ASTimer.db.sound
					end,
					set = function(info, val)
						ASTimer.db.sound = val
						if val then
							PlaySoundFile("Interface\\addons\\AS_Timer\\Media\\ASTimerDroplet.mp3", "Master")
						end
					end
				}
			}
		}
	}
}
LibStub("AceConfig-3.0"):RegisterOptionsTable("Auspicious Spirits Timer", optionsTable, {"ast", "astimer", "auspiciousspiritstimer"})
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Auspicious Spirits Timer")

ASTimer.defaultSettings = {
	global = {
		posX = 0,
		posY = 0,
		scale = 1,
		outofcombat = true,
		display = "Complex",
		sound = false
	}
}

function ASTimer:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
end