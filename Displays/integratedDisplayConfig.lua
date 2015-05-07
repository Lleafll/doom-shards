--@debug@

-- Get Addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")


-- Options
CS.optionsTable.args.integrated = {
	order = 3,
	type = "group",
	name = L["Integrated Display"],
	cmdHidden  = true,
	args = {
		enable = {
			order = 1,
			type = "toggle",
			name = L["Enable"],
			get = function()
				return CS.db.display == "Integrated"
			end,
			set = function(info, val)
				if val then CS.db.display = "Integrated" end
				CS:Initialize()
			end
		}
	}
}

CS.defaultSettings.global.integrated = {
	
}
--@end-debug@