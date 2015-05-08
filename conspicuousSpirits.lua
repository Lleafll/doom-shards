local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and libraries and stuff
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits")
LibStub("AceEvent-3.0"):Embed(CS)
LibStub("AceTimer-3.0"):Embed(CS)
LibStub("AceConsole-3.0"):Embed(CS)
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Variables
CS.displayBuilders = {}


-- Frames
CS.frame = CreateFrame("frame", "CSFrame", UIParent)
local timerFrame = CS.frame
timerFrame:SetFrameStrata("LOW")
timerFrame:SetMovable(true)
timerFrame.lock = true
timerFrame.texture = timerFrame:CreateTexture(nil, "BACKGROUND")
timerFrame.texture:SetAllPoints(timerFrame)
timerFrame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
timerFrame.texture:Hide()


-- Functions
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
	if not UnitAffectingCombat("player") then RegisterStateDriver(timerFrame, "visibility", "") end
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
	if CS.db.display == "Complex" and not UnitAffectingCombat("player") then RegisterStateDriver(timerFrame, CS.db.complex.visibilityConditionals) end
end

function CS:SetUpdateInterval(interval)
	if interval and (not self.UpdateInterval or interval < self.UpdateInterval) then
		self.UpdateInterval = interval
	end
end

function CS:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
	
	CS.UpdateInterval = nil
	
	if self.displayBuilders[self.db.display] then self.displayBuilders[self.db.display](self) end  -- display builder functions
	if self.db.sound then self:initializeSound() end
end