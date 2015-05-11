-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-- Options
do
	local optionsTable = {
		type = "group",
		name = "Conspicuous Spirits",
		childGroups = "tab",
		args = {
			header2 = {
				order = 0,
				type = "header",
				name = L["Version"].." @project-version@"
			},
			general = {
				order = 1,
				type = "group",
				name = L["General"],
				cmdHidden = true,
				inline = true,
				args = {
					scale = {
						order = 1,
						type = "range",
						name = L["Scale"],
						desc = L["Set Frame Scale"],
						min = 0,
						max = 3,
						step = 0.01,
						get = function()
							return CS.db.scale
						end,
						set = function(info, val)
							CS.db.scale = val
							CS:Build()
						end
					},
					reset = {
						order = 2,
						type = "execute",
						name = L["Reset to Defaults"],
						confirm = true,
						func = function()
							CS:ResetDB()
							print(L["Conspicuous Spirits reset!"])
							--CS:getDB()
							CS:Build()
						end
					},
					spacer = {
						order = 2.5,
						type = "description",
						name = ""
					},
					aggressiveCaching = {
						order = 3,
						type = "toggle",
						name = L["Aggressive Caching"],
						desc = L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."],
						get = function()
							return CS.db.aggressiveCaching
						end,
						set = function(_, val)
							CS.db.aggressiveCaching = val
						end
					},
					aggressiveCachingInterval = {
						order = 4,
						type = "range",
						name = L["Aggressive Caching Interval"],
						desc = L["Scanning interval when Aggressive Caching is enabled"],
						min = 0.2,
						max = 3,
						step = 0.1,
						get = function()
							return CS.db.aggressiveCachingInterval
						end,
						set = function(_, val)
							CS.db.aggressiveCachingInterval = val
						end
					},
					calculateOutOfCombat = {
						order = 5,
						type = "toggle",
						name = L["Out-of-Combat Calculation"],
						desc = L["Keep calculating distances and anticipated Orbs when leaving combat."],
						get = function()
							return CS.db.calculateOutOfCombat
						end,
						set = function(_, val)
							if CS.db.calculateOutOfCombat then
								CS:Build()
							elseif not UnitAffectingCombat("player") then
								CS:PLAYER_REGEN_ENABLED()
							end
							CS.db.calculateOutOfCombat = val
						end
					}
				}
			},
			position = {
				order = 5,
				type = "group",
				name = L["Position"],
				inline = true,
				args = {
					lock = {
						order = 1,
						type = "execute",
						name = L["Toggle Lock"],
						desc = L["Shows the frame and toggles it for repositioning."],
						func = function()
							if UnitAffectingCombat("player") then return end
							if CS.db.display == "WeakAuras" then
								print(L["Not possible to unlock in WeakAuras mode!"])
								return
							end
							if not CS.locked then
								CS:Lock()
								CS:Build()
							else
								CS:Unlock()
							end
						end
					},
					reset = {
						order = 2,
						type = "execute",
						name = L["Reset Position"],
						cmdHidden = true,
						confirm  = true,
						func = function()
							CS.db.posX = 0
							CS.db.posY = 0
							CS:Build()
						end
					}
				}
			}
		}
	}

	local CS.defaultSettings = {
		global = {
			posX = 0,
			posY = 0,
			scale = 1,
			display = "Complex",
			aggressiveCaching = false,
			aggressiveCachingInterval = 1,
			calculateOutOfCombat = false
		}
	}

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Conspicuous Spirits", optionsTable)
	local ACD = LibStub("AceConfigDialog-3.0")
	ACD:AddToBlizOptions("Conspicuous Spirits")
	ACD:SetDefaultSize("Conspicuous Spirits", 700, 750)

	function CS:HandleChatCommand(command)
		local subcmd = string.match(cmd, "(%w+)")

		if subcmd and (subcmd == "toggle" or (subcmd == "lock" and not self.locked) or (subcmd == "unlock" and self.locked)) then
			if self.locked then
				self:Unlock()
			else
				self:Lock()
			end
		end
		
		ACD:Open("Conspicuous Spirits")
	end

	CS:RegisterChatCommand("cs", "HandleChatCommand")
	CS:RegisterChatCommand("csp", "HandleChatCommand")
	CS:RegisterChatCommand("conspicuousspirits", "HandleChatCommand")
end

do
	local orderIterator = 2
	function CS:AddDisplayOptions(displayName, displayOptions, displayDefaults)
		optionsTable.args[displayName] = displayOptions
		optionsTable.args[displayName].order = orderIterator
		orderIterator = orderIterator + 1
		
		CS.defaultSettings.global.[displayName] = displayDefaults
	end
end