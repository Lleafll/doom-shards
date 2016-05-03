-- Debugging
local debug = false
--@debug@
--GAME_LOCALE = "koKR"
--debug = true
--@end-debug@


-- Libraries
local L = LibStub("AceLocale-3.0"):NewLocale("DoomShards", "enUS", true, debug)
if not L then return end


-- Translations
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="none")@

--@do-not-package@

L["Add. HoG Shards"] = true
L["Additional Doom Indicators"] = true
L["Always show borders"] = true
L["Anchor"] =  true
L["Animations"] = true
L["Background Color"] = true
L["Bar Color"] = true
L["Border Color"] = true
L["Borders"] = true
L["Cancelled Test Mode"] = "|cFF814eaaDoom Shards|r: Cancelled Test Mode!"
L["Change color of all Shards when reaching cap"] = true
L["Color of additional indicators for overcapping with Doom ticks"] = true
L["Color Shard 1"] = true
L["Color Shard 2"] = true
L["Color Shard 3"] = true
L["Color Shard 4"] = true
L["Color Shard 5"] = true
L["Color the text will change to if doom will tick before next possible Hand of Gul'dan cast."] = "Color the text will change to if Doom will tick before end of the next possible Hand of Gul'dan cast."
L["Color When Shard Capped"] = true
L["Colors"] = true
L["Dimensions"] = true
L["Direction"] = true
L["Display"] = true
L["Doom Shards locked!"] = "|cFF814eaaDoom Shards|r locked!"
L["Doom Shards reset!"] = "|cFF814eaaDoom Shards|r reset!"
L["Doom Shards unlocked!"] = "|cFF814eaaDoom Shards|r unlocked!"
L["Doom Tick Indicator Bars"] = true
L["Documentation"] = true
L["dragFrameTooltip"] = [=[|cFFcc0060Left mouse button|r to drag.
|cFFcc0060Right mouse button|r to lock.
|cFFcc0060Mouse wheel|r and |cFFcc0060shift + mouse wheel|r for fine adjustment.]=]
L["Enable"] = true
L["Enable bars for incoming Doom ticks"] = true
L["File to play."] = true
L["Fill indicator from right to left"] = "Fill indicator from right to left."
L["Flash on Shard Gain"] = true
L["Font"] = true
L["Font Color"] = true
L["Font Color for Hand of Gul'dan Prediction"] = true
L["Font Flags"] = true
L["Font Size"] = true
L["Functionality"] = true
L["General"] = true
L["Growth direction"] = true
L["Height"] = true
L["Horizontal"] = true
L["Include Doom tick indicator in Hand of Gul'dan casts. (Demonology only)"] = true
L["Indicate Shard Building"] = true
L["Indicate Shard Spending"] = true
L["Instance Type"] = true
L["Interval"] = true
L["MONOCHROMEOUTLINE"] = true
L["None"] = true
L["Offset"] = true
L["Order in which Shards get filled in"] = true
L["Orientation"] = true
L["OUTLINE"] = true
L["\"Overcap Shards\" Color"] = true
L["Overcapping"] = true
L["Play Warning Sound when about to cap."] = true
L["Position"] = true
L["Regular"] = true
L["Regulate display visibility with macro conditionals"] = [=[
Regulate display visibility with macro conditionals
show - show display
hide - hide display
fade - fade out display
]=]
L["Reset Position"] = true
L["Reset to Defaults"] = true
L["Reversed"] = true
L["Reverse Direction"] = true
L["Scale"] = true
L["Shadow"] = true
L["Shard Colors"] = true
L["Shard Gain Color"] = true
L["Shard Cap Color Change"] = "Cap Color Change"
L["Shard Spend Color"] = true
L["Show prediction for gaining shards through casts"] = true
L["Show prediction for spending shards through casts"] = true
L["Shows the frame and toggles it for repositioning."] = true
L["Soul Shard Bars"] = true
L["Sound"] = true
L["Spacing"] = true
L["Starting Test Mode"] = "|cFF814eaaDoom Shards|r: Starting Test Mode"
L["Test Mode"] = true
L["Text"] = true
L["Texture"] = true
L["Textures"] = true
L["THICKOUTLINE"] = true
L["Threshold when text begins showing first decimal place"] = "Threshold when text begins showing first decimal place."
L["Time between warning sounds"] = true
L["Time Threshold"] = true
L["Toggle Lock"] = true
L["Use Texture for Shards"] = true
L["Version"] = true
L["Vertical"] = true
L["Visibility"] = true
L["Visibility Conditionals"] = true
L["WeakAurasDocumentation"] = [=[WeakAuras event to listen to: DOOM_SHARDS_UPDATE

Relevant properties of global object DoomShards:
  timeStamp - time of last update (number)
  resource - current amount of Soul Shards (number)
  timers - chronologically ordered table of GUIDs with Doom (table)
  nextTick - time of next Doom tick for every GUID (table)
  duration - total Doom duration for every GUID (table)
  energized - refunded Soul Shards for latest update (number)
  generating - number of Soul Shards which are generated (positive) or spent (negative) with current spell cast (number)
  nextCast - time when current cast will finish or nil if not currently casting (number)]=]
L["WeakAuras Example Strings"] = true
L["WeakAuras Import String 1"] = true
L["WeakAuras Import String 2"] = true
L["WeakAuras Interface"] = true
L["WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import."] = true
L["Width"] = true
L["X Offset"] = true
L["Y Offset"] = true
L["No Instance"] = true
L["Scenario"] = true
L["Dungeon"] = true
L["Raid"] = true
L["Arena"] = true
L["Battleground"] = true
L["Fade Duration"] = true
L["Positioning"] = true
L["X Position"] = true
L["Y Position"] = true
L["Anchor Point"] = true
L["Anchor Frame"] = true
L["Will change to UIParent when manually dragging frame."] = true

--@end-do-not-package@