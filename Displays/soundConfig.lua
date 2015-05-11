-- Get Addon Object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Droplet", "Interface\\addons\\ConspicuousSpirits\\Media\\CSDroplet.mp3")


-- Options
CS:AddDisplayOptions("sound",
	{
		order = 6,
		type = "group",
		name = L["Sound"],
		cmdHidden = true,
		args = {
			sound = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
				desc = L["Play Warning Sound when about to cap Shadow Orbs."],
				get = function()
					return CS.db.sound
				end,
				set = function(info, val)
					CS.db.sound = val
				end
			},
			file = {
				order = 2,
				type = "select",
				dialogControl = "LSM30_Sound",
				name = "",
				desc = L["File to play."],
				values = LSM:HashTable("sound"),
				get = function()
					return CS.db.soundHandle
				end,
				set = function(_, key)
					CS.db.soundHandle = key
				end
			},
			width = {
				order = 3,
				type = "range",
				name = L["Interval"],
				desc = L["Time between warning sounds"],
				min = 0.1,
				max = 10,
				step = 0.1,
				get = function()
					return CS.db.soundInterval
				end,
				set = function(info, val)
					CS.db.soundInterval = val
					CS:Build()
				end
			}
		}
	},
	{
	}
)

-- legacy options :/
CS.defaultSettings.global.sound = false
CS.defaultSettings.global.soundHandle = "Droplet"
CS.defaultSettings.global.soundInterval = 2