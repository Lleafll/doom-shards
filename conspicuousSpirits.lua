local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and libraries and stuff
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits")
LibStub("AceEvent-3.0"):Embed(CS)
LibStub("AceTimer-3.0"):Embed(CS)
LibStub("AceConsole-3.0"):Embed(CS)
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Functions
-- frame factory for all display modules' parent frames
function CS:CreateParentFrame(name)
	local frame = CreateFrame("frame", name, UIParent)
	frame:SetFrameStrata("LOW")
	frame:SetMovable(true)
	frame.texture = timerFrame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetAllPoints(timerFrame)
	frame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
	frame.texture:Hide()
	
	function frame:Unlock()
		self:Show()
		self.texture:Show()
		local function dragStop(self)
			self:StopMovingOrSizing()
			local _, _, _, posX, posY = self:GetPoint()
			CS.db.posX = posX
			CS.db.posY = posY
		end
		self:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("Conspicuous Spirits", 0.38, 0.23, 0.51, 1, 1, 1)
			GameTooltip:AddLine(L["dragFrameTooltip"], 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end)
		self:SetScript("OnLeave", function(s) GameTooltip:Hide() end)
		self:SetScript("OnMouseDown", function(self, button)
			if button == "RightButton" then
				dragStop(self)  -- in case user right clicks while dragging the frame
				self:Lock()
				CS:Build()
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
	end

	function frame:Lock()
		self.texture:Hide()
		self:EnableMouse(false)
		self:SetScript("OnEnter", nil)
		self:SetScript("OnLeave", nil)
		self:SetScript("OnMouseDown", nil)
		self:SetScript("OnMouseUp", nil)
		self:SetScript("OnMouseWheel", nil)
	end
	
	return frame
end

function CS:Unlock()
	print(L["Conspicuous Spirits unlocked!"])
	self.locked = false
	self:Disable()
	
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			if module.Unlock then module:Unlock() end
			if module.frame then module.frame:Unlock() end
		end
	end
end

function CS:Lock()
	if not self.locked then print(L["Conspicuous Spirits locked!"]) end
	self.locked = true
	--if CS.db.calculateOutOfCombat then CS:PLAYER_REGEN_DISABLED() end
	--CS:ApplySettings()
	self:TalentsCheck()  -- build displays if Shadow and AS specced  -- replaces two lines above
	
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			if module.Lock then module:Lock() end
			if module.frame then module.frame:Lock() end
		end
	end
end

-- sets the minimum needed update interval reported by all displays
function CS:SetupdateInterval(interval)
	if interval and (not self.updateInterval or interval < self.updateInterval) then
		self.updateInterval = interval
	end
end

function CS:ApplySettings()
	self.updateInterval = nil
	
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			module:Enable()
		elseif module:IsEnabled()
			module:Disable()
		end
	end
end