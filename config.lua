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


-- Variables
CS.displayBuilders = {}


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
	print(L["Conspicuous Spirits unlocked!"])
	timerFrame.lock = false
	CS:PLAYER_REGEN_ENABLED()
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
end

function timerFrame:Lock()
	if not timerFrame.lock then print(L["Conspicuous Spirits locked!"]) end
	timerFrame.lock = true
	if CS.db.calculateOutOfCombat then CS:PLAYER_REGEN_DISABLED() end
	timerFrame.texture:Hide()
	timerFrame:EnableMouse(false)
	timerFrame:SetScript("OnEnter", nil)
	timerFrame:SetScript("OnLeave", nil)
	timerFrame:SetScript("OnMouseDown", nil)
	timerFrame:SetScript("OnMouseUp", nil)
	CS:applySettings()
	if CS.db.display == "Complex" then RegisterStateDriver(timerFrame, CS.db.complex.visibilityConditionals) end
end


-- Options
CS.optionsTable = {
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
				},
				spacer = {
					order = 2.5,
					type = "description",
					name = ""
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
				calculateOutOfCombat = {
					order = 5,
					type = "toggle",
					name = L["Out-of-Combat Calculation"],
					desc = L["Keep calculating distances and anticipated Orbs when leaving combat."],
					get = function()
						return CS.db.calculateOutOfCombat
					end,
					set = function(_, val)
						if CS.db.calculateOutOfCombat then
							CS:Initialize()
						elseif not UnitAffectingCombat("player") then
							CS:PLAYER_REGEN_ENABLED()
						end
						CS.db.calculateOutOfCombat = val
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
		}
	}
}
LibStub("AceConfig-3.0"):RegisterOptionsTable("Conspicuous Spirits", CS.optionsTable)
ACD:AddToBlizOptions("Conspicuous Spirits")
ACD:SetDefaultSize("Conspicuous Spirits", 700, 750)
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
		display = "Complex",
		aggressiveCaching = false,
		aggressiveCachingInterval = 1,
		calculateOutOfCombat = false
	}
}

function CS:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
	
	if self.displayBuilders[self.db.display] then self[self.displayBuilders[self.db.display]] end  -- display builder functions
	if self.db.sound then self:initializeSound() end
end