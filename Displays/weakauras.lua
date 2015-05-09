if not IsAddOnLoaded("WeakAuras") then return end


-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
WeakAurasScanEvents = WeakAuras.ScanEvents


-- Frames
local timerFrame = CS.frame


-- Variables
local conspicuous_spirits_wa


-- Functions
local function refreshDisplay(self, orbs, timers)
	local count = #timers
	conspicuous_spirits_wa.count = count
	conspicuous_spirits_wa.orbs = orbs
	conspicuous_spirits_wa.timers = timers
	WeakAurasScanEvents("WA_AUSPICIOUS_SPIRITS", count, orbs)
end

CS.displayBuilders["WeakAuras"] = function(self)
	timerFrame:SetWidth(0)
	timerFrame:SetHeight(0)
	
	if not _G.conspicuous_spirits_wa then _G.conspicuous_spirits_wa = {} end
	conspicuous_spirits_wa = _G.conspicuous_spirits_wa
	conspicuous_spirits_wa.count = 0
	conspicuous_spirits_wa.orbs = UnitPower("player", 13)
	conspicuous_spirits_wa.timers = {}
	conspicuous_spirits_wa.TimeLeft = self.TimeLeft
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = function() end
	timerFrame.HideChildren = function() end
end