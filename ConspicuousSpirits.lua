local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


---------------------------------------
-- Embedding and libraries and stuff --
---------------------------------------
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


---------------
-- Functions --
---------------
do
	local function dragStop(self, moduleName)
		self:StopMovingOrSizing()
		local _, _, _, posX, posY = self:GetPoint()
		CS.db[moduleName].posX = posX
		CS.db[moduleName].posY = posY
	end
	
	-- frame factory for all display modules' parent frames
	function CS:CreateParentFrame(name, moduleName)
		local frame = CreateFrame("frame", name, UIParent)
		frame:SetFrameStrata("LOW")
		frame:SetMovable(true)
		frame.texture = frame:CreateTexture(nil, "BACKGROUND")
		frame.texture:SetPoint("BOTTOMLEFT", -1, -1)
		frame.texture:SetPoint("TOPRIGHT", 1, 1)
		frame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
		frame.texture:Hide()
		
		function frame:Unlock()
			self:Show()
			self.texture:Show()
			
			self:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:AddLine("Conspicuous Spirits", 0.51, 0.31, 0.67, 1, 1, 1)
				GameTooltip:AddLine(L["dragFrameTooltip"], 1, 1, 1, 1, 1, 1)
				GameTooltip:Show()
			end)
			
			self:SetScript("OnLeave", function(s)
				GameTooltip:Hide()
			end)
			
			self:SetScript("OnMouseDown", function(self, button)
				if button == "RightButton" then
					dragStop(self, moduleName)  -- in case user right clicks while dragging the frame
					CS:Lock()
					CS:Build()
				elseif button == "LeftButton" then
					self:StartMoving()
				end
			end)
			
			self:SetScript("OnMouseUp", function(self, button)
				dragStop(self, moduleName)
			end)
			
			self:SetScript("OnMouseWheel", function(self, delta)
				if IsShiftKeyDown() then
					CS.db[moduleName].posX = CS.db[moduleName].posX + delta
				else
					CS.db[moduleName].posY = CS.db[moduleName].posY + delta
				end
				self:SetPoint("CENTER", CS.db[moduleName].posX, CS.db[moduleName].posY)
			end)
		end

		function frame:Lock()
			self.texture:Hide()
			self:EnableMouse(false)
			self:SetScript("OnUpdate", nil)
			self:SetScript("OnEnter", nil)
			self:SetScript("OnLeave", nil)
			self:SetScript("OnMouseDown", nil)
			self:SetScript("OnMouseUp", nil)
			self:SetScript("OnMouseWheel", nil)
		end
		
		return frame
	end
end

function CS:Unlock()
	print(L["Conspicuous Spirits unlocked!"])
	self.locked = false
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			if module.Unlock then module:Unlock() end
			if module.frame then module.frame:Unlock() end
		end
	end
	self:Build()
end

function CS:Lock()
	if not self.locked then print(L["Conspicuous Spirits locked!"]) end
	self.locked = true
	self:TalentsCheck()  -- build displays if Shadow and AS specced
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			if module.Lock then module:Lock() end
			if module.frame then module.frame:Lock() end
		end
	end
	self:Build()
end

function CS:ApplySettings()
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			module:Enable()
			if not CS.locked and module.frame then module.frame:Unlock() end
			if module.Build then module:Build() end
		else
			module:Disable()
			if module.frame then module.frame:Hide() end
		end
	end
end

function CS:OnInitialize()
	self.locked = true
	
	local CSDB = LibStub("AceDB-3.0"):New("ConspicuousSpiritsDB", self.defaultSettings, true)
	self.db = CSDB.global
	function self:ResetDB() CSDB:ResetDB() end
	
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "TalentsCheck")  -- will fire once for every talent tier after player is in-game and ultimately initialize events and displays if player is Shadow
end