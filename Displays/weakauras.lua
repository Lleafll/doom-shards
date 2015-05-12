if not IsAddOnLoaded("WeakAuras") then return end


-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local WA = CS:NewModule("weakauras", "AceEvent-3.0")


-- Upvalues
WeakAurasScanEvents = WeakAuras.ScanEvents


-- Variables
local conspicuous_spirits_wa


-- Functions
function WA:CONSPICUOUS_SPIRITS_UPDATE(self, orbs, timers)
	local count = #timers
	conspicuous_spirits_wa.count = count
	conspicuous_spirits_wa.orbs = orbs
	conspicuous_spirits_wa.timers = timers
	WeakAurasScanEvents("WA_AUSPICIOUS_SPIRITS", count, orbs)
end

function WA:OnInitialize()
	if not _G.conspicuous_spirits_wa then _G.conspicuous_spirits_wa = {} end
	conspicuous_spirits_wa = _G.conspicuous_spirits_wa
	conspicuous_spirits_wa.count = 0
	conspicuous_spirits_wa.orbs = UnitPower("player", 13)
	conspicuous_spirits_wa.timers = {}
end

function WA:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function WA:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end