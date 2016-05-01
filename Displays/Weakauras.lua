local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end

local WA = DS:NewModule("weakauras", "AceEvent-3.0")


--------------
-- Upvalues --
--------------
local WeakAurasScanEvents


---------------
-- Variables --
---------------
local weakauras = {}


---------------
-- Functions --
---------------
function WA:CONSPICUOUS_SPIRITS_UPDATE() end

local function WeakAurasLoaded()
	WeakAurasScanEvents = WeakAuras.ScanEvents
	function WA:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
		local count = #timers
		weakauras.count = count
		weakauras.orbs = orbs
		weakauras.timers = timers
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
	-- old, going to be deprecated
	weakauras.count = 0
	weakauras.orbs = UnitPower("player", 13)
	weakauras.timers = {}
	
	-- new & better to reduce littering of global namespace
	DS.weakauras = weakauras
end

function WA:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function WA:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end