local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local WA = CS:NewModule("weakauras", "AceEvent-3.0")


--------------
-- Upvalues --
--------------
local WeakAurasScanEvents


---------------
-- Variables --
---------------
local conspicuous_spirits_wa


---------------
-- Functions --
---------------
function WA:CONSPICUOUS_SPIRITS_UPDATE() end

local function WeakAurasLoaded()
	WeakAurasScanEvents = WeakAuras.ScanEvents
	function WA:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
		local count = #timers
		conspicuous_spirits_wa.count = count
		conspicuous_spirits_wa.orbs = orbs
		conspicuous_spirits_wa.timers = timers
		WeakAurasScanEvents("WA_AUSPICIOUS_SPIRITS", count, orbs)
	end
end

-- optionalDeps produces bugs with some addons
if IsAddOnLoaded("WeakAuras") then
	WeakAurasLoaded()
else
	WA:RegisterEvent("ADDON_LOADED", function(_, name)
		if name == "WeakAuras" then WeakAurasLoaded() end
	end)
end

function WA:OnInitialize()
	if not _G.conspicuous_spirits_wa then _G.conspicuous_spirits_wa = {} end
	
	-- old, going to be deprecated
	conspicuous_spirits_wa = _G.conspicuous_spirits_wa
	conspicuous_spirits_wa.count = 0
	conspicuous_spirits_wa.orbs = UnitPower("player", 13)
	conspicuous_spirits_wa.timers = {}
	
	-- new & better to reduce littering of global namespace
	CS.weakauras = conspicuous_spirits_wa
end

function WA:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function WA:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end