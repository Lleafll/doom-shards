local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end


---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


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
local tonumber = tonumber
local UnitBuff = UnitBuff
local UnitGUID = UnitGUID


-------------
-- Utility --
-------------
local getHasteMod = DS.GetHasteMod
local buildHastedIntervalFunc = DS.buildHastedIntervalFunc


-----------
-- Specs --
-----------
-- Affliction
do
  local baseAverageAccumulatorIncrease = 0.16
  local baseAverageAccumulatorResetValue = 0.5
  
  DS.agonyAccumulator = baseAverageAccumulatorResetValue
  DS.globalNextAgonyTick = {}
  DS.globalAppliedAgonies = {}
  local spellEnergizeFrame = CreateFrame("Frame")
  spellEnergizeFrame:Show()
  spellEnergizeFrame:SetScript("OnEvent", function(self, _, _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
    if event == "SPELL_ENERGIZE" and spellID == 17941 and sourceGUID == UnitGUID("player") and DS.agonyAccumulator then
      DS.agonyAccumulator = baseAverageAccumulatorResetValue - DS.globalNextAgonyTick.aura.resourceChance  -- SPELL_ENERGIZE fire before respective SPELL_DAMAGE from Agony
    end
  end)
  
  local function setGlobalNextAgonyTick()
    local globalNextAgonyTick
    local globalNextTickAura
    for aura in pairs(DS.globalAppliedAgonies) do
      local nextTick = aura.nextTick
      if not globalNextAgonyTick or nextTick < globalNextAgonyTick then
        globalNextAgonyTick = nextTick
        globalNextTickAura = aura
      end
    end
    DS.globalNextAgonyTick.tick = globalNextTick
    DS.globalNextAgonyTick.aura = globalNextTickAura
  end
  
  DS:AddSpecSettings(265,
    {
      [27243] = function()  -- Seed of Corruption  -- TODO: possibly cache and update on event
        local _, _, _, _, selected = GetTalentInfo(4, 2, GetActiveSpecGroup())
        return selected and -1 or 0
      end,
      [196098] = 5,  -- Soul Harvest
      [18540] = -1,  -- Summon Doomguard
      [688] = -1,  -- Summon Imp
      [1122] = -1,  -- Summon Infernal
      [691] = -1,  -- Summon Felhunter
      [712] = -1,  -- Summon Succubus
      [697] = -1,  -- Summon Voidwalker
      [30108] = -1  -- Unstable Affliction
    },
    {
      [980] = {  -- Agony
        duration = 18,
        tickLengthFunc = buildHastedIntervalFunc(2),
        resourceChanceFunc = function(self)
          return (baseAverageAccumulatorIncrease / sqrt(DS.agonyCounter)) / baseAverageAccumulatorResetValue
        end,
        IterateTick = function(self, timeStamp)
          if timeStamp then
            local expiration = self.expiration
            local iteratedTick = timeStamp + self.tickLength
            local isLastTick = iteratedTick >= expiration
            return isLastTick and expiration or iteratedTick, self.resourceChance, isLastTick
          else
            local nextTick = self.nextTick
            local resourceChance = (DS.globalNextAgonyTick.aura == self) and (DS.agonyAccumulator) or (self.resourceChance)
            return nextTick, resourceChance, nextTick >= self.expiration
          end
        end,
        OnApply = function(self, timeStamp)
          if not DS.agonyCounter then
            spellEnergizeFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
          end
          DS.agonyCounter = (DS.agonyCounter or 0) + 1
          DS.globalAppliedAgonies[self] = true
          setGlobalNextAgonyTick()
        end,
        OnTick = function(self, timeStamp)
          DS.agonyAccumulator = DS.agonyAccumulator + self.resourceChance
          setGlobalNextAgonyTick()
        end,
        OnRemove = function(self)
          if DS.globalAppliedAgonies[self] then
            DS.globalAppliedAgonies[self] = nil
            DS.agonyCounter = DS.agonyCounter - 1
            if DS.agonyCounter <= 0 then
              DS.agonyCounter = nil
              spellEnergizeFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            end
            setGlobalNextAgonyTick()
          end
        end
      }
    }
  )
end

-- Demonology
local demonicCallingString = GetSpellInfo(205146)
DS:AddSpecSettings(266,
  {
    [104316] = function()  -- Call Dreadstalkers  -- TODO: possibly cache and update on event
      local generates = -2
      if UnitBuff("player", demonicCallingString) then
        generates = generates + 2
      end
      if IsEquippedItem(132393) then  -- Recurrent Ritual
        generates = generates + 2
      end
      return generates
    end,
    [157695] = 1,  -- Demonbolt
    [105174] = -4,  -- Hand of Gul'dan
    [686] = 1,  -- Shadow Bolt
    [196098] = 5,  -- Soul Harvest
    [18540] = -1,  -- Summon Doomguard
    [688] = -1,  -- Summon Imp
    [1122] = -1,  -- Summon Infernal
    [30146] = -1,  -- Summon Felguard
    [691] = -1,  -- Summon Felhunter
    [712] = -1,  -- Summon Succubus
    [697] = -1,  -- Summon Voidwalker
  },
  {
    [603] = {  -- Doom
      durationFunc = buildHastedIntervalFunc(20),
      pandemicFunc = buildHastedIntervalFunc(6),
      tickLengthFunc = buildHastedIntervalFunc(20),
      resourceChance = 1,
      IterateTick = function(self, timeStamp)
        if timeStamp then
          local expiration = self.expiration
          local iteratedTick = timeStamp + self.tickLength
          local isLastTick = iteratedTick >= expiration
          local resourceChance = (expiration - self.nextTick) / self.duration
          return isLastTick and expiration or iteratedTick, self.resourceChance, isLastTick
        else
          local nextTick = self.nextTick
          return nextTick, self.resourceChance, nextTick >= self.expiration
        end
      end
    }
  }
)

-- Destruction
DS:AddSpecSettings(267,
  {
    [116858] = -2,  -- Chaos Bolt
    [5740] = -3,  -- Rain of Fire
    [196098] = 5,  -- Soul Harvest
    [18540] = -1,  -- Summon Doomguard
    [688] = -1,  -- Summon Imp
    [1122] = -1,  -- Summon Infernal
    [691] = -1,  -- Summon Felhunter
    [712] = -1,  -- Summon Succubus
    [697] = -1,  -- Summon Voidwalker
  },
  {
    --[[[348] = {  -- Immolate  -- ID 157736 for DoT
      duration = 15,
      tickLengthFunc = buildHastedIntervalFunc(3),
      resourceChanceFunc = function(self)  -- TODO: Implement artifact traits (Burning Hunger)
        return (1 + GetSpellCritChance()/100) * 0.15
      end
    },]]--
    [17877] = {   -- Shadowburn
      duration = 5,
      pandemic = 0,
      tickLength = 5,
      resourceChance = 1,
      IterateTick = function(self, timeStamp)
        if timeStamp then
          return self.nextTick, self.resourceChance, true
        else
          return self.nextTick, self.resourceChance, false
        end
      end,
      Refresh = function(self, timeStamp)
        self:Tick(timeStamp)
      end
    }
  }
)


------------
-- Config --
------------
local function specializationsOptions()
  return {
    order = 3,
    type = "group",
    name = L["Specializations"],
    childGroups = "select",
    cmdHidden  = true,
    get = function(info)
      local optionName = tonumber(info[#info]) or info[#info]  -- To avoid converting to numbers in event code later on
      return DS.db.specializations[optionName]
    end,
    set = function(info, value)
      local optionName = tonumber(info[#info]) or info[#info]
      DS.db.specializations[optionName] = value;
      DS:Build()
    end,
    args = {
      headerAffliction = {
        order = 1,
        name = L["Affliction"],
        type = "header"
      },
      ["980"] = {
        order = 2,
        name = L["Track Agony"],
        type = "toggle"
      },
      headerDemonology = {
        order = 10,
        name = L["Demonology"],
        type = "header"
      },
      ["603"] = {
        order = 11,
        name = L["Track Doom"],
        type = "toggle"
      },
      headerDestruction = {
        order = 20,
        name = L["Destruction"],
        type = "header"
      },
      ["17877"] = {
        order = 21,
        name = L["Track Shadowburn"],
        type = "toggle"
      },
    }
  }
end

local defaultSettings = {
  profile = {
    [980] = true,
    [603] = true,
    [17877] = true,
  }
}

DS:AddDisplayOptions("specializations", specializationsOptions, defaultSettings)