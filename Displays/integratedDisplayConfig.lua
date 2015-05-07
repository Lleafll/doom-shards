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
		},
		color = {
			order = 2,
			type = "color",
			name = L["Color 1"],
			desc = L["Set Color 1"],
			hasAlpha = true,
			get = function()
				local r, b, g, a = CS.db.integrated.color.r, CS.db.integrated.color.b, CS.db.integrated.color.g, CS.db.integrated.color.a
				return r, b, g, a
			end,
			set = function(info, r, b, g, a)
				CS.db.integrated.color.r, CS.db.integrated.color.b, CS.db.integrated.color.g, CS.db.integrated.color.a = r, b, g, a
				CS:Initialize()
			end
		},
	}
}

CS.defaultSettings.global.integrated = {
	color = {r=0.53, b=0.53, g=0.53, a=1.00}
}
--@end-debug@