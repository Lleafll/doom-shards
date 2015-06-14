local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end

local L = LibStub("AceLocale-3.0"):GetLocale("ConspicuousSpirits")


-------------
-- Options --
-------------
local function optionsTable()
	return {
		type = "group",
		name = "Conspicuous Spirits",
		childGroups = "tab",
		get = function(info) return CS.db[info[#info]] end,
		set = function(info, value) CS.db[info[#info]] = value; CS:Build() end,
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
						step = 0.01
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
						order = 3.5,
						type = "description",
						name = ""
					},
					aggressiveCaching = {
						order = 4,
						type = "toggle",
						name = L["Aggressive Caching"],
						desc = L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."]
					},
					aggressiveCachingInterval = {
						order = 5,
						type = "range",
						name = L["Aggressive Caching Interval"],
						desc = L["Scanning interval when Aggressive Caching is enabled"],
						min = 0.2,
						max = 3,
						step = 0.1
					},
					calculateOutOfCombat = {
						order = 6,
						type = "toggle",
						name = L["Out-of-Combat Calculation"],
						desc = L["Keep calculating distances and anticipated Orbs when leaving combat."]
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
							if not CS.locked then
								CS:Lock()
							else
								CS:Unlock()
							end
						end
					},
					reset = {
						order = 3,
						type = "execute",
						name = L["Reset Position"],
						cmdHidden = true,
						confirm  = true,
						func = function() 
							for name, module in CS:IterateModules() do
								if CS.db[name] then
									if CS.db[name].posX then CS.db[name].posX = 0 end
									if CS.db[name].posY then CS.db[name].posY = 0 end
								end
							end
							CS:Build()
						end
					},
					testMode = {
						order = 3,
						type = "execute",
						name = L["Test Mode"],
						func = function()
							if not UnitAffectingCombat("player") then
								CS:TestMode() 
							end
						end
					}
				}
			}
		}
	}
end

CS.defaultSettings = {
	global = {
		scale = 1,
		aggressiveCaching = true,
		aggressiveCachingInterval = 0.5,
		calculateOutOfCombat = false,
		debug = false,
		debugSA = false
	}
}

do
	local moduleOptions = {}
	
	function CS:AddDisplayOptions(displayName, displayOptions, displayDefaults)
		moduleOptions[displayName] = displayOptions
		self.defaultSettings.global[displayName] = displayDefaults
	end
	
	
	local function createOptions()
		local optionsTable = optionsTable()
		
		local iterator = 2
		for displayName, displayOptions in pairs(moduleOptions) do
			optionsTable.args[displayName] = displayOptions()
			optionsTable.args[displayName].order = 2
			iterator = iterator + 1
		end
		
		return optionsTable
	end

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Conspicuous Spirits", createOptions)
end

local ACD = LibStub("AceConfigDialog-3.0")
ACD:AddToBlizOptions("Conspicuous Spirits")
ACD:SetDefaultSize("Conspicuous Spirits", 700, 750)

function CS:HandleChatCommand(command)
	local suffix = string.match(command, "(%w+)")

	if suffix then
		if suffix == "toggle" or suffix == "lock" or (suffix == "unlock" and self.locked) then
			if self.locked then
				self:Unlock()
			else
				self:Lock()
			end
			
		elseif suffix == "debug" then
			self.db.debug = not self.db.debug
			if self.db.debug then
				print("|cFF814eaaConspicuous Spirits|r: debugging enabled")
			else
				print("|cFF814eaaConspicuous Spirits|r: debugging disabled")
			end
			return
			
		elseif suffix == "debugSA" then
			self.db.debugSA = not self.db.debugSA
			if self.db.debugSA then
				print("|cFF814eaaConspicuous Spirits|r: debugging SATimers enabled")
			else
				print("|cFF814eaaConspicuous Spirits|r: debugging SATimers disabled")
			end
			return
			
		end
	end
	
	if ACD.OpenFrames[addons] then
		ACD:Close("Conspicuous Spirits")
	else
		ACD:Open("Conspicuous Spirits")
	end
end

CS:RegisterChatCommand("cs", "HandleChatCommand")
CS:RegisterChatCommand("csp", "HandleChatCommand")
CS:RegisterChatCommand("conspicuousspirits", "HandleChatCommand")