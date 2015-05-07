if not IsAddOnLoaded("WeakAuras") then return end


-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Upvalues
WeakAurasScanEvents = WeakAuras.ScanEvents


-- Frames
local timerFrame = CS.frame


-- Variables
local wa_as


-- Functions
local function refreshDisplay(self, orbs, timers)
	local count = #timers
	wa_as.count = count
	wa_as.orbs = orbs
	wa_as.timers = timers
	WeakAurasScanEvents("WA_AUSPICIOUS_SPIRITS", count, orbs)
end

CS.displayBuilders["WeakAuras"] = function(self)
	timerFrame:SetWidth(0)
	timerFrame:SetHeight(0)
	
	if not _G.wa_as then _G.wa_as = {} end
	wa_as = _G.wa_as
	wa_as.count = 0
	wa_as.orbs = UnitPower("player", 13)
	wa_as.timers = {}
	wa_as.TimeLeft = self.TimeLeft
	self.refreshDisplay = refreshDisplay
	timerFrame.ShowChildren = function() end
	timerFrame.HideChildren = function() end
	
	self.needsFrequentUpdates = false
end