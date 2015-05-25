-- Get addon object
local CS = LibStub("AceAddon-3.0"):GetAddon("Conspicuous Spirits", true)
if not CS then return end


-- Create module
local TE = CS:NewModule("Template", "AceEvent-3.0")  -- needs to have the same name as the options table in TemplateConfig.lua


-- Frames
local TEFrame = CS:CreateParentFrame("CS Template Display", "Template")  -- this frame is used for locking/unlocking; skip this if your display isn't build on frames 
TE.frame = TEFrame


-- Variables
local db


-- Functions
function TE:CONSPICUOUS_SPIRITS_UPDATE(_, orbs, timers)
	-- basically required
	-- make dynamic changes to the display here
	-- gets updated every time the number of orbs or timers changes
	-- you can also set an automatic update interval in Build
end

function TE:Unlock()
	-- optional
	-- show and hide additional frames so module is presentable in its unlocked state
	-- parent frame toggles automatically
end

function TE:Lock()
	-- optional
	-- return all frames to their default state
	-- parent frame toggles automatically
end

function TE:Build()
	-- optional
	-- use this to build frames and set values
	-- gets fired when module is initially build and every time user changes settings
	-- make sure you're recycling frames
	
	CS:SetUpdateInterval(0.1)  -- optional; only use this if you need frequent updates (e.g. if you're displaying timers); set interval in seconds
end

function TE:OnInitialize()
	-- optional
	-- fires when module is initialized
	db = CS.db.Template  -- module settings have the same as the module
end

function TE:OnEnable()
	-- required
	-- fires when module gets enabled
	self:RegisterMessage("CONSPICUOUS_SPIRITS_UPDATE")  -- register for updates from Conspicuous Spirits
end

function TE:OnDisable()
	-- required
	-- fires when module gets disabled
	self:UnregisterMessage("CONSPICUOUS_SPIRITS_UPDATE")
end