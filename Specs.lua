local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end


--------------
-- Upvalues --
--------------
local GetActiveSpecGroup = GetActiveSpecGroup
local GetHaste = GetHaste
local GetSpellCritChance = GetSpellCritChance
local GetSpecialization = GetSpecialization
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local IsEquippedItem = IsEquippedItem
local sqrt = sqrt
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local UnitBuff = UnitBuff
local UnitGUID = UnitGUID


---------------
-- Constants --
---------------
local PANDEMIC_RANGE = 0.3


-------------
-- Utility --
-------------
local function getHasteMod()
  return 1 + GetHaste() / 100
end
DS.GetHasteMod = getHasteMod

local function buildHastedIntervalFunc(base)
  return function()
    return base / getHasteMod()
  end
end
DS.buildHastedIntervalFunc = buildHastedIntervalFunc


----------------------------------
-- Spell and Aura Lookup Tables --
----------------------------------
local specSettings = {}
DS.specSettings = specSettings

local trackedAurasMetaTable = {}
trackedAurasMetaTable.__index = function(tbl, k)
  local func = rawget(tbl, k.."Func")
  return func and func(tbl) or nil
end

local auraMetaTable = {}  -- Aura prototypes

local function pandemicFunc(self)
  return PANDEMIC_RANGE * self.duration
end

local function tickMethod(self, timeStamp)
  self.nextTick = timeStamp + self.tickLength
end

local function refreshMethod(self, timeStamp)
  local belowPandemic = self.expiration + self.duration
  local overPandemic = timeStamp + self.duration + self.pandemic
  self.expiration = belowPandemic < overPandemic and belowPandemic or overPandemic
end

local function iterateTickMethod(self, timeStamp)
  if timeStamp then
    local expiration = self.expiration
    local iteratedTick = timeStamp + self.tickLength
    local isLastTick = iteratedTick >= expiration
    return isLastTick and expiration or iteratedTick, self.resourceChance, isLastTick
  else
    local isLastTick = self.nextTick >= self.expiration
    return isLastTick and self.expiration or self.nextTick, self.resourceChance, isLastTick
  end
end

local dummyFunc = function()
end

function DS:AddSpecSettings(specID, resourceGeneration, trackedAuras)
  local settings = {}
  specSettings[specID] = settings
  settings.resourceGeneration = resourceGeneration
  settings.trackedAuras = trackedAuras
  
  auraMetaTable[specID] = {}
  for k, v in pairs(trackedAuras) do
    setmetatable(v, trackedAurasMetaTable)
    
    v.id = k
    v.name = GetSpellInfo(k)
    if not v.pandemic then
      v.pandemicFunc = v.pandemicFunc or pandemicFunc
    end
    
    v.Tick = v.Tick or tickMethod
    v.Refresh = v.Refresh or refreshMethod
    v.IterateTick = v.IterateTick or iterateTickMethod
    v.OnApply = v.OnApply or dummyFunc
    v.OnTick = v.OnTick or dummyFunc
    v.OnRemove = v.OnRemove or dummyFunc
    
    auraMetaTable[specID][k] = {__index = v}
  end
end

function DS:BuildAura(spellID, GUID)
  local aura = {}
  setmetatable(aura, auraMetaTable[self.specializationID][spellID])
  
  -- TODO: replace with intialization, possibly via methamethods
  local timeStamp = GetTime()
  aura.expiration = timeStamp + aura.duration
  
  aura:Tick(timeStamp)
  
  aura:OnApply(timeStamp)
  
  return aura
end