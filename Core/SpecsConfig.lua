local DS = LibStub("AceAddon-3.0"):GetAddon("Doom Shards", true)
if not DS then return end


---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("DoomShards")


--------------
-- Upvalues --
--------------
local exp = exp
local GetActiveSpecGroup = GetActiveSpecGroup
local GetHaste = GetHaste
local GetTime = GetTime
local GetInventoryItemID = GetInventoryItemID
local GetSpellCritChance = GetSpellCritChance
local GetSpecialization = GetSpecialization
local GetSpellInfo = GetSpellInfo
local GetTalentInfo = GetTalentInfo
local IsEquippedItem = IsEquippedItem
local math_exp = math.exp
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
local buildHastedIntervalFunc = DS.BuildHastedIntervalFunc


-----------
-- Specs --
-----------
-- Dummy Spec (used for Test Mode)
DS:AddSpecSettings(-1,
  {
  },
  {
    [-1] = {
      duration = 10,
      tickLength = 10,
      resourceChance = 1,
    }
  },
  {
    referenceSpell = 5782  -- Fear (a spell every warlock spec has)
  }
)

-- Affliction
do
  -- Parameters for calculating Soul Shard proc chances from Agony
  local agonyChanceParametersStart = {
    [1] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.985923, 1.699051, -0.000165},
      [4] = {1.219053, 0.975556, -0.014669},
      [5] = {1.484172, 0.578398, -0.085888},
      [6] = {2.086914, 0.314034, -0.330391},
      [7] = {192.639138, 0.002557, -95.578910},
      [8] = {262.512766, 0.001597, -130.474710},
      [9] = {203.987032, 0.001587, -101.202790},
    },
    [2] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.783161, 2.068688, -0.001795},
      [4] = {1.008100, 1.244726, -0.007541},
      [5] = {1.172464, 0.753739, -0.039958},
      [6] = {1.412528, 0.531817, -0.087239},
      [7] = {1.913336, 0.287440, -0.316658},
      [8] = {82.271193, 0.005205, -40.470632},
      [9] = {224.594053, 0.001613, -111.600591},
    },
    [3] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.649231, 2.202345, -0.002346},
      [4] = {0.847562, 1.332772, -0.005263},
      [5] = {1.002733, 0.834009, -0.026758},
      [6] = {1.229840, 0.547236, -0.083474},
      [7] = {1.640880, 0.315178, -0.257107},
      [8] = {3.818380, 0.109703, -1.313413},
      [9] = {201.230154, 0.001766, -99.989091},
    },
    [4] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.596134, 2.361049, -0.001529},
      [4] = {0.756916, 1.398795, -0.004219},
      [5] = {0.899439, 0.893471, -0.019022},
      [6] = {1.083680, 0.596073, -0.058576},
      [7] = {1.407497, 0.346549, -0.194176},
      [8] = {2.354677, 0.171407, -0.632861},
      [9] = {183.191646, 0.001859, -91.021403},
    },
    [5] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.524192, 2.401449, -0.001575},
      [4] = {0.682177, 1.431708, -0.003724},
      [5] = {0.819778, 0.924455, -0.015950},
      [6] = {1.005155, 0.582756, -0.065787},
      [7] = {1.327492, 0.341802, -0.197195},
      [8] = {2.369650, 0.160893, -0.681553},
      [9] = {154.303533, 0.002109, -76.617586},
    }
  }

  local agonyChanceParameters = {
    [1] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.985923, 1.699051, -0.000165},
      [4] = {1.219053, 0.975556, -0.014669},
      [5] = {1.484172, 0.578398, -0.085888},
      [6] = {2.086914, 0.314034, -0.330391},
      [7] = {192.639138, 0.002557, -95.578910},
      [8] = {262.512766, 0.001597, -130.474710},
      [9] = {203.987032, 0.001587, -101.202790},
    },
    [2] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.783161, 2.068688, -0.001795},
      [4] = {1.008100, 1.244726, -0.007541},
      [5] = {1.172464, 0.753739, -0.039958},
      [6] = {1.412528, 0.531817, -0.087239},
      [7] = {1.913336, 0.287440, -0.316658},
      [8] = {82.271193, 0.005205, -40.470632},
      [9] = {224.594053, 0.001613, -111.600591},
    },
    [3] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.649231, 2.202345, -0.002346},
      [4] = {0.847562, 1.332772, -0.005263},
      [5] = {1.002733, 0.834009, -0.026758},
      [6] = {1.229840, 0.547236, -0.083474},
      [7] = {1.640880, 0.315178, -0.257107},
      [8] = {3.818380, 0.109703, -1.313413},
      [9] = {201.230154, 0.001766, -99.989091},
    },
    [4] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.596134, 2.361049, -0.001529},
      [4] = {0.756916, 1.398795, -0.004219},
      [5] = {0.899439, 0.893471, -0.019022},
      [6] = {1.083680, 0.596073, -0.058576},
      [7] = {1.407497, 0.346549, -0.194176},
      [8] = {2.354677, 0.171407, -0.632861},
      [9] = {183.191646, 0.001859, -91.021403},
    },
    [5] = {
      [0] = {0, 0, 0},
      [1] = {0, 0, 0},
      [2] = {0, 0, 0},
      [3] = {0.524192, 2.401449, -0.001575},
      [4] = {0.682177, 1.431708, -0.003724},
      [5] = {0.819778, 0.924455, -0.015950},
      [6] = {1.005155, 0.582756, -0.065787},
      [7] = {1.327492, 0.341802, -0.197195},
      [8] = {2.369650, 0.160893, -0.681553},
      [9] = {154.303533, 0.002109, -76.617586},
    }
  }

  local ITERATION_MAX_TICKS = 9
  local ITERATION_MAX_TARGETS = 5

  -- Affliction specific item ids
  local FOTDS_ID = 124522  -- Fragment of the Dark Star
  local HOED_ID = 132394  -- Hood of Eternal Disdain
  local HOED_MOD = 1.2

  -- Track Agonies
  local targetFactor = 1
  local targetHistory = {}
  local ticksSinceShard = 0
  local agonyCounter
  local globalAppliedAgonies = {}
  local globalNextAgony

  local function setGlobalNextAgony()
    local globalNextAgonyTick
    local globalNextAgonyAura
    for aura in pairs(globalAppliedAgonies) do
      local nextTick = aura.nextTick
      if not globalNextAgonyTick or nextTick < globalNextAgonyTick then
        globalNextAgonyTick = nextTick
        globalNextAgonyAura = aura
      end
    end
    globalNextAgony = globalNextAgonyAura
  end

  local function calculateTargetFactor()
    local count = #targetHistory
    if count > 0 then
      local targetProduct = 1
      for _, v in pairs(targetHistory) do
        targetProduct = targetProduct * v
      end
      targetFactor = targetProduct ^ (1 / count)
    else
      targetFactor = 1
    end
  end

  local function resetAgony()
    ticksSinceShard = 0
    targetFactor = 1
    wipe(targetHistory)
  end

  local spellEnergizeFrame = CreateFrame("Frame")
  spellEnergizeFrame:Show()
  spellEnergizeFrame:SetScript("OnEvent", function(self, _, _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, spellID)
    if event == "SPELL_ENERGIZE" and spellID == 17941 and sourceGUID == UnitGUID("player") then
      resetAgony()
    end
  end)

  DS:AddSpecSettings(265,
    {
      [27243] = function()  -- Seed of Corruption  -- TODO: possibly cache and update on event
        local _, _, _, _, selected = GetTalentInfo(4, 2, GetActiveSpecGroup())
        return selected and -1 or 0
      end,
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
        displayChance = true,
        durationFunc = function(self)
          local duration = 18
          if IsEquippedItem(FOTDS_ID) then
            local ilink
            if GetInventoryItemID("player", 13) == FOTDS_ID then
              ilink = GetInventoryItemLink("player", 13)
            else
              ilink = GetInventoryItemLink("player", 14)
            end
            local _, _, _, ilvl = GetItemInfo(ilink)
            duration = -1.183E-4 * ilvl*ilvl + 0.141 * ilvl - 25.336  -- TODO: Move magic numbers
          end
          if IsEquippedItem(HOED_ID) then
            duration = duration / HOED_MOD
          end
          return duration
        end,
        tickLengthFunc = function()
          local tickLength = 2
          -- TODO: Insert FotDS here
          if IsEquippedItem(HOED_ID) then
            tickLength = tickLength / HOED_MOD
          end
          return tickLength / getHasteMod()
        end,
        resourceChanceFunc = function(self)
          local targetIndex = agonyCounter < ITERATION_MAX_TARGETS and agonyCounter or  ITERATION_MAX_TARGETS
          local tickIndex = ticksSinceShard < ITERATION_MAX_TICKS and ticksSinceShard or ITERATION_MAX_TICKS
          local chanceParameters = agonyChanceParameters[targetIndex][tickIndex]
          return chanceParameters[1] / (1 + math_exp(chanceParameters[2] * targetFactor)) + chanceParameters[3]
        end,
        refreshEvent = "SPELL_CAST_SUCCESS",
        IterateTick = function(self, timeStamp)
          local tick, resourceChance, isLastTick, hide
          if timeStamp then
            local expiration = self.expiration
            local iteratedTick = timeStamp + self.tickLength
            isLastTick = iteratedTick >= expiration
            tick = isLastTick and expiration or iteratedTick
            resourceChance = 0
            hide = true
          else
            isLastTick = self.nextTick >= self.expiration
            tick = isLastTick and self.expiration or self.nextTick
            if globalNextAgony == self then
              resourceChance = self.resourceChance
              hide = false
            else
              resourceChance = 0
              hide = true
            end
          end
          return tick, resourceChance, isLastTick, hide  -- Hide when resource chance is 0
        end,
        Refresh = function(self)
          self.expiration = DS.CalculateExpiration(self)  -- SPELL_CAST_SUCCESS triggers before aura is applied -> setExpiration can't be used
          self:OnRefresh()
        end,
        OnApply = function(self)
          if not agonyCounter then
            spellEnergizeFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
          end
          agonyCounter = (agonyCounter or 0) + 1
          globalAppliedAgonies[self] = true
          setGlobalNextAgony()
        end,
        OnTick = function(self)
          targetHistory[#targetHistory + 1] = agonyCounter
          ticksSinceShard = ticksSinceShard + 1
          calculateTargetFactor()
          setGlobalNextAgony()
        end,
        OnRemove = function(self)
          if globalAppliedAgonies[self] then
            globalAppliedAgonies[self] = nil
            agonyCounter = agonyCounter - 1
            if agonyCounter <= 0 then
              agonyCounter = nil
              spellEnergizeFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
              resetAgony()
            end
            setGlobalNextAgony()
          end
        end
      },
      [30108] = {  -- Unstable Affliction
        durationFunc = buildHastedIntervalFunc(8),
        pandemic = 0,
        tickLengthFunc = buildHastedIntervalFunc(8),
        resourceChance = 1,
        hasInitialTick = false,
        IterateTick = function(self, timeStamp)
          if timeStamp then
            local expiration = self.expiration
            local iteratedTick = timeStamp + self.tickLength
            local isLastTick = iteratedTick >= expiration
            local resourceChance = (expiration - self.nextTick) / self.duration
            return isLastTick and expiration or iteratedTick, resourceChance, isLastTick
          else
            local isLastTick = self.nextTick >= self.expiration
            return isLastTick and self.expiration or self.nextTick, self.resourceChance, isLastTick
          end
        end,
        OnRefresh = function(self)
          self:Tick()
        end,
      },
    },
    {
      referenceTime = 2  -- 2 ticks of Drain Life
    }
  )
end

-- Demonology
do
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
        hasInitialTick = false,
        IterateTick = function(self, timeStamp)
          if timeStamp then
            local expiration = self.expiration
            local iteratedTick = timeStamp + self.tickLength
            local isLastTick = iteratedTick >= expiration
            local resourceChance = ((isLastTick and expiration or iteratedTick) - timeStamp) / self.duration
            return isLastTick and expiration or iteratedTick, resourceChance, isLastTick, resourceChance < 1 and DS.db.consolidateTicks
          else
            local isLastTick = self.nextTick >= self.expiration
            return isLastTick and self.expiration or self.nextTick, self.resourceChance, isLastTick, resourceChance < 1 and DS.db.consolidateTicks
          end
        end
      }
    },
    {
      referenceSpell = 686  -- Shadow Bolt
    }
  )
end

-- Destruction
DS:AddSpecSettings(267,
  {
    [116858] = -2,  -- Chaos Bolt
    [5740] = -3,  -- Rain of Fire
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
      OnRefresh = function(self)
        self:Tick()
      end
    }
  },
  {
    referenceSpell = 29722  -- Incinerate
  }
)


-------------
-- Options --
-------------
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
      ["30108"] = {
        order = 3,
        name = L["Track Unstable Affliction"],
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
    [30108] = true,
    [603] = true,
    [17877] = true,
  }
}

DS:AddDisplayOptions("specializations", specializationsOptions, defaultSettings)
