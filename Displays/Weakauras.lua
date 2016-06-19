--@alpha@


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
function DS:GetAuraInfo(spellID, unitGUID)
  if self.auras[unitGUID] and self.auras[unitGUID][spellID] then
    local aura = self.auras[unitGUID][spellID]
    return aura.name, aura.id, aura.duration, aura.tickLength, aura.pandemic, aura.expiration
  end
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


--@end-alpha@