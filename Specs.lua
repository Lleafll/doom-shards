local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end


--------------
-- Upvalues --
--------------
local GetActiveSpecGroup = GetActiveSpecGroup
local GetHaste = GetHaste
local GetSpecialization = GetSpecialization
local GetSpellCritChance = GetSpellCritChance
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local ipairs = ipairs
local IsEquippedItem = IsEquippedItem
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local pairs = pairs
local rawget = rawget
local rawset = rawset
local setmetatable = setmetatable
local sqrt = sqrt
local UnitBuff = UnitBuff
local UnitGUID = UnitGUID


---------------
-- Constants --
---------------
local MAX_BOSSES = 5
local MAX_NAMEPLATES_TO_CHECK = 20
local MAX_PARTY_SIZE = 5
local MAX_RAID_SIZE = 40
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
DS.BuildHastedIntervalFunc = buildHastedIntervalFunc

local function buildUnitIDTable(str1, maxNum, str2)
  local tbl = {}
  for i = 1, maxNum do
    tbl[i] = str1..tostring(i)..(str2 or "")
  end
  return tbl
end
DS.BuildUnitIDTable = buildUnitIDTable


-------------------
-- Lookup Tables --
-------------------
local bossTable = buildUnitIDTable("boss", MAX_BOSSES)
local nameplateTable = buildUnitIDTable("nameplate", MAX_NAMEPLATES_TO_CHECK)
local partyTable = buildUnitIDTable("party", MAX_PARTY_SIZE, "target")
local raidTable = buildUnitIDTable("raid", MAX_RAID_SIZE, "target")

local specSettings = {}
DS.specSettings = specSettings

local trackedAurasMetaTable = {}
trackedAurasMetaTable.__index = function(tbl, k)
  local func = rawget(tbl, k.."Func")
  return func and func(tbl) or nil
end

local auraMetaTable = {}  -- Aura prototypes


-------------------------------
-- Aura Methods and Handling --
-------------------------------
local dummyFunc = function()
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

local function pandemicFunc(self)
  return PANDEMIC_RANGE * self.duration
end

local function auraUnitDebuff(unit, auraName)
  local _, _, _, _, _, _, expires = UnitDebuff(unit, auraName, nil, "PLAYER")
  return expires
end

local function iterateUnitTable(aura, unitTable, GUID)
  for _, unit in ipairs(nameplateTable) do
    if UnitGUID(unit) == GUID then
      return auraUnitDebuff(unit, aura.name)
    end
  end
end

local function calculateExpiration(aura)
  local timestamp = GetTime()
  if aura.expiration then
    local belowPandemic = aura.expiration + aura.duration
    local overPandemic = timestamp + aura.duration + aura.pandemic
    return belowPandemic < overPandemic and belowPandemic or overPandemic
  else
    return timestamp + aura.duration
  end
end

local function setExpiration(aura)
  local GUID = aura.GUID
  
  local expires
  if UnitGUID("target") == GUID then  -- Implies UnitExists
    expires = auraUnitDebuff("target", aura.name)
  else
    expires = iterateUnitTable(aura, nameplateTable, GUID)
    if not expires then
      if IsInRaid() then
        expires = iterateUnitTable(aura, raidTable, GUID)
      elseif IsInGroup() then
        expires = iterateUnitTable(aura, partyTable, GUID)
      end
    end
  end
  
  aura.expiration = expires or calculateExpiration(aura)
end

local function applyMethod(self)
  setExpiration(self)
  self:OnApply()
  
  self:Tick()
end

local function refreshMethod(self)
  setExpiration(self)
  self:OnRefresh()
end

local function tickMethod(self)
  self.nextTick = GetTime() + self.tickLength
  self:OnTick()
end

function DS:AddSpecSettings(specID, resourceGeneration, trackedAuras)
  local settings = {}
  specSettings[specID] = settings
  settings.resourceGeneration = resourceGeneration
  settings.trackedAuras = trackedAuras
  
  auraMetaTable[specID] = {}
  for k, v in pairs(trackedAuras) do
    setmetatable(v, trackedAurasMetaTable)
    
    -- Properties
    v.id = k
    v.name = GetSpellInfo(k)
    if not v.pandemic then
      v.pandemicFunc = v.pandemicFunc or pandemicFunc
    end
    v.applyEvent = v.applyEvent or "SPELL_AURA_APPLIED"
    v.refreshEvent = v.refreshEvent or "SPELL_AURA_REFRESH"
    v.removeEvent = v.removeEvent or "SPELL_AURA_REMOVED"
    v.tickEvent = v.tickEvent or "SPELL_PERIODIC_DAMAGE"
    
    -- Methods
    v.Apply = v.Apply or applyMethod
    v.Tick = v.Tick or tickMethod
    v.Refresh = v.Refresh or refreshMethod
    v.IterateTick = v.IterateTick or iterateTickMethod
    v.OnApply = v.OnApply or dummyFunc
    v.OnTick = v.OnTick or dummyFunc
    v.OnRefresh = v.OnRefresh or dummyFunc
    v.OnRemove = v.OnRemove or dummyFunc
    
    auraMetaTable[specID][k] = {__index = v}
  end
end

function DS:BuildAura(spellID, GUID)
  local aura = {}
  setmetatable(aura, auraMetaTable[self.specializationID][spellID])
  aura.GUID = GUID
  
  return aura
end