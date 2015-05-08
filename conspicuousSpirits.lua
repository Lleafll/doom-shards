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
	self.lock = false
	CS:PLAYER_REGEN_ENABLED()
	self:Show()
	self:ShowChildren()
	self.texture:Show()
	self:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine("Conspicuous Spirits", 0.38, 0.23, 0.51, 1, 1, 1)
		GameTooltip:AddLine(L["dragFrameTooltip"], 1, 1, 1, 1, 1, 1)
		GameTooltip:Show()
	end)
	self:SetScript("OnLeave", function(s) GameTooltip:Hide() end)
	local function dragStop(self)
		self:StopMovingOrSizing()
		local _, _, _, posX, posY = self:GetPoint()
		CS.db.posX = posX
		CS.db.posY = posY
	end
	self:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			dragStop(self)  -- in case user right clicks while dragging the frame
			self:Lock()
			CS:Initialize()
		else
			self:StartMoving()
		end
	end)
	self:SetScript("OnMouseUp", function(self, button)
		dragStop(self)
	end)
	self:SetScript("OnMouseWheel", function(self, delta)
		if IsShiftKeyDown() then
			CS.db.posX = CS.db.posX + delta
		else
			CS.db.posY = CS.db.posY + delta
		end
		self:SetPoint("CENTER", CS.db.posX, CS.db.posY)
	end)
	if not UnitAffectingCombat("player") then RegisterStateDriver(self, "visibility", "") end
end

function timerFrame:Lock()
	if not self.lock then print(L["Conspicuous Spirits locked!"]) end
	self.lock = true
	if CS.db.calculateOutOfCombat then CS:PLAYER_REGEN_DISABLED() end
	self.texture:Hide()
	self:EnableMouse(false)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnMouseWheel", nil)
	CS:applySettings()
	if CS.db.display == "Complex" and not UnitAffectingCombat("player") then RegisterStateDriver(self, CS.db.complex.visibilityConditionals) end
end

function CS:SetUpdateInterval(interval)
	if interval and (not self.UpdateInterval or interval < self.UpdateInterval) then
		self.UpdateInterval = interval
	end
end

function CS:applySettings()
	timerFrame:SetPoint("CENTER", self.db.posX, self.db.posY)
	timerFrame:SetScale(self.db.scale)
	
	self.UpdateInterval = nil
	
	if self.displayBuilders[self.db.display] then self.displayBuilders[self.db.display](self) end  -- display builder functions
	if self.db.sound then self:initializeSound() end
end