----------------------
-- Get addon object --
----------------------
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-------------
-- Options --
-------------
local function displayOptions()
	return -- AceConfig options table goes here
	-- http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
end

local defaultSettings = {
	-- values for default settings go here
}

CS:AddDisplayOptions("Template",  -- needs to have the same name as the module in Template.lua; this function makes sure that your settings tie into the Conspicuous Spirits settings
	displayOptions,
	defaultSettings
)