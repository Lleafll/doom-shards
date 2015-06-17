----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-------------
-- Options --
-------------
local function displayOptions()
	return {
		type = "group",
		name = L["TellMeWhen Interface"],
		cmdHidden  = true,
		get = function(info) return CS.db.tellmewhen[info[#info]] end,
		set = function(info, value) CS.db.tellmewhen[info[#info]] = value; CS:Build() end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"]
			}
		}
	}
end

local defaultSettings = {
	enable = false
}

CS:AddDisplayOptions("tellmewhen", displayOptions, defaultSettings)