local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end

local WA = DS:NewModule("weakauras", "AceEvent-3.0")


--------------
-- Upvalues --
--------------
local WeakAurasScanEvents


---------------
-- Functions --
---------------
function WA:DOOM_SHARDS_UPDATE() end

local function WeakAurasLoaded()
	WeakAurasScanEvents = WeakAuras.ScanEvents
	function WA:DOOM_SHARDS_UPDATE(_, resource, timers)
		WeakAurasScanEvents("DOOM_SHARDS_UPDATE")
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
	
end

function WA:OnEnable()
	self:RegisterMessage("DOOM_SHARDS_UPDATE")
end

function WA:OnDisable()
	self:UnregisterMessage("DOOM_SHARDS_UPDATE")
end