local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end

local WA = DS:NewModule("weakauras", "AceEvent-3.0")


--------------
-- Upvalues --
--------------
local assert = assert
local type = type
local WeakAurasScanEvents


---------
-- API --
---------
function DS:GetDoomInfo(arg)
	local type_arg = type(arg)
	assert(type_arg == "number" or type_arg == "string", "Argument to GetDoomInfo() must be a number or GUID")
	local GUID = type(arg) == "number" and self.timers[arg] or arg
	return GUID, self.nextTick[GUID], self.duration[GUID]
end

function DS:GetNumDoomTargets()
	return #self.timers
end


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