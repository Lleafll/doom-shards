local _, class = UnitClass("player")
if class ~= "PRIEST" then return end


-- Embedding and libraries and stuff
local CS = LibStub("AceAddon-3.0"):NewAddon("Conspicuous Spirits", "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Functions
-- frame factory for all display modules' parent frames
function CS:CreateParentFrame(name, moduleName)
	local frame = CreateFrame("frame", name, UIParent)
	frame:SetFrameStrata("LOW")
	frame:SetMovable(true)
	frame.texture = frame:CreateTexture(nil, "BACKGROUND")
	frame.texture:SetAllPoints(frame)
	frame.texture:SetTexture(0.38, 0.23, 0.51, 0.7)
	frame.texture:Hide()
	
	function frame:Unlock()
		self:Show()
		self.texture:Show()
		
		do  -- change size of frame texture to include all children when unlocked
			
			local function getEdges(frm)
				local posX, posY = frm:GetCenter()
				local height, width = frm:GetHeight(), frm:GetWidth()
				return posX-width/2, posX+width/2, posY-height/2, posY+height/2
			end
			
			self.texture:SetHeight(0)
			self.texture:SetWidth(0)
			local children = {self:GetChildren()}  -- any possibility to recycle?
			for _, child in ipairs(children) do
				if child:IsShown() then
					local left, right, bottom, top = getEdges(self.texture)
					local childLeft, childRight, childBottom, childTop = getEdges(child)
					
					left = childLeft < left and childLeft or left
					right = childRight > right and childRight or right
					bottom = childBottom < bottom and childBottom or bottom
					top = childTop > top and childTop or top
					
					self.texture:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
					self.texture:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", right, top)
				end
			end
			local posX, posY = self:GetCenter()
			local texPosX, texPosY = self.texture:GetCenter()
			local texWidth, texHeight = self.texture:GetWidth(), self.texture:GetHeight()
			self.texture:ClearAllPoints()
			self.texture:SetPoint("CENTER", texPosX - posX, texPosY - posY)
			self.texture:SetHeight(texHeight + 4)
			self.texture:SetWidth(texWidth + 4)
		end
		
		local function dragStop(self)
			self:StopMovingOrSizing()
			local _, _, _, posX, posY = self:GetPoint()
			CS.db[moduleName].posX = posX
			CS.db[moduleName].posY = posY
		end
		
		self:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:AddLine("Conspicuous Spirits", 0.38, 0.23, 0.51, 1, 1, 1)
			GameTooltip:AddLine(L["dragFrameTooltip"], 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end)
		
		self:SetScript("OnLeave", function(s)
			GameTooltip:Hide()
		end)
		
		self:SetScript("OnMouseDown", function(self, button)
			if button == "RightButton" then
				dragStop(self)  -- in case user right clicks while dragging the frame
				CS:Lock()
				CS:Build()
			elseif button == "LeftButton" then
				self:StartMoving()
			end
		end)
		
		self:SetScript("OnMouseUp", function(self, button)
			dragStop(self)
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
	self:Build()
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
	self:TalentsCheck()  -- build displays if Shadow and AS specced
	self:Build()
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			if module.Lock then module:Lock() end
			if module.frame then module.frame:Lock() end
		end
	end
end

function CS:ApplySettings()
	self:ResetUpdateInterval()
	
	self:GetModule("complex"):Enable()
	
	for name, module in self:IterateModules() do
		if self.db[name] and self.db[name].enable then
			module:Enable()
			if module.Build then module:Build() end
		else
			module:Disable()
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