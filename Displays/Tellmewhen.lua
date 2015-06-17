local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local TW = CS:NewModule("tellmewhen", "AceEvent-3.0")

--------------
-- Upvalues --
--------------
local TMWCNDTEnv
local CStellmewhen


---------------
-- Functions --
---------------
function TW:CONSPICUOUS_SPIRITS_UPDATE() end

local function TellMeWhenLoaded()
	TMWCNDTEnv = TMW.CNDT.Env
	
	TMWCNDTEnv.ConspicuousSpiritsOrbs = UnitPower("player", 13)
	TMWCNDTEnv.ConspicuousSpiritsCount = 0
	TMWCNDTEnv.ConspicuousSpiritsTimers = {}
	
	CS.tellmewhen = {}
	CS.tellmewhen.orbs = UnitPower("player", 13)
	CS.tellmewhen.count = 0
	CS.tellmewhen.timers = {}
	CStellmewhen = CS.tellmewhen
	
	function TW:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
		local count = #timers
		
		TMWCNDTEnv.ConspicuousSpiritsOrbs = orbs
		TMWCNDTEnv.ConspicuousSpiritsCount = count
		TMWCNDTEnv.ConspicuousSpiritsTimers = timers
		
		CStellmewhen.orbs = orbs
		CStellmewhen.count = count
		CStellmewhen.timers = timers
	end
end

-- optionalDeps produces bugs with some addons
if IsAddOnLoaded("TellMeWhen") then
	TellMeWhenLoaded()
else
	TW:RegisterEvent("ADDON_LOADED", function(_, name)
		if name == "TellMeWhen" then TellMeWhenLoaded() end
	end)
end

function TW:OnEnable()
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end

function TW:OnDisable()
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end