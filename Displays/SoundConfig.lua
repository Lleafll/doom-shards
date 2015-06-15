----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


---------------
-- Libraries --
---------------
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Droplet", "Interface\\addons\\ConspicuousSpirits\\Media\\CSDroplet.mp3")


-------------
-- Options --
-------------
local function displayOptions()
	return {
		order = 6,
		type = "group",
		name = L["Sound"],
		cmdHidden = true,
		get = function(info) return CS.db.warningSound[info[#info]] end,
		set = function(info, value) CS.db.warningSound[info[#info]] = value; CS:Build() end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
				desc = L["Play Warning Sound when about to cap Shadow Orbs."]
			},
			soundHandle = {
				order = 2,
				type = "select",
				dialogControl = "LSM30_Sound",
				name = "",
				desc = L["File to play."],
				values = LSM:HashTable("sound")
			},
			soundInterval = {
				order = 3,
				type = "range",
				name = L["Interval"],
				desc = L["Time between warning sounds"],
				min = 0.1,
				max = 10,
				step = 0.1
			},
			spacer = {
				order = 3.5,
				type = "description",
				name = ""
			},
			instances = {
				order = 4,
				type = "multiselect",
				name = L["Instance Type"],
				get = function(info, key) return CS.db.warningSound[info[#info]][key] end,
				set = function(info, key, value) CS.db.warningSound[info[#info]][key] = value; CS:Build() end,
				values = {
					none = L["No Instance"],
					scenario = L["Scenario"],
					party = L["Dungeon"],
					raid = L["Raid"],
					arena = L["Arena"],
					pvp = L["Battleground"]
				}
			}
		}
	}
end

local defaultSettings = {
	enable = false,
	soundHandle = "Droplet",
	soundInterval = 2,
	instances = {
		arena = true,
		none = true,
		party = true,
		pvp = true,
		raid = true,
		scenario = true
	}
}

CS:AddDisplayOptions("warningSound", displayOptions, defaultSettings)