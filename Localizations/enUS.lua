-- Debugging
local debug = false
--@debug@
--GAME_LOCALE = "koKR"
--debug = true
--@end-debug@


-- Libraries
local L = LibStub("AceLocale-3.0"):NewLocale("ConspicuousSpirits", "enUS", true, debug)
if not L then return end


-- Translations
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true, handle-subnamespaces="none")@

--@do-not-package@

L["Aggressive Caching"] = "Aggressive Caching"
L["Aggressive Caching Interval"] = "Aggressive Caching Interval"
L["Anticipated Orbs"] = "Anticipated Orbs"
L["Background Color"] = "Background Color"
L["Border Color"] = "Border Color"
L["Cached distances might be unreliable when you or the mobs move a lot"] = "Cached distances might be unreliable when you or the mobs move a lot"
L["Cancelled Test Mode"] = "|cFF814eaaConspicuous Spirits|r: Cancelled Test Mode!"
L["Can not change visibility options in combat."] = "Can not change visibility options in combat."
L["Change color of all Shadow Orbs when reaching five Shadow Orbs"] = "Change color of all Shadow Orbs when reaching five Shadow Orbs"
L["Color"] = "Color"
L["Color 1"] = "Color 1"
L["Color 2"] = "Color 2"
L["Color 3"] = "Color 3"
L["Color for Cache Value"] = "Color for Cache Value"
L["Color of the sixth indicator when overcapping with Shadowy Apparitions"] = "Color of the sixth indicator when overcapping with Shadowy Apparitions"
L["Color Text On Using Cached Value"] = "Color Text On Using Cached Value"
L["Color When Orb Capped"] = "Color When Orb Capped"
L["Complex Display"] = "Complex Display"
L["Conspicuous Spirits locked!"] = "|cFF814eaaConspicuous Spirits|r locked!"
L["Conspicuous Spirits reset!"] = "|cFF814eaaConspicuous Spirits|r reset!"
L["Conspicuous Spirits unlocked!"] = "|cFF814eaaConspicuous Spirits|r unlocked!"
L["Documentation"] = "Documentation"
L["dragFrameTooltip"] = [=[|cFFcc0060Left mouse button|r to drag.
|cFFcc0060Right mouse button|r to lock.
|cFFcc0060Mouse wheel|r and |cFFcc0060shift + mouse wheel|r for fine adjustment.]=]
L["Enable"] = "Enable"
L["Enable display of bars for anticipated Shadow Orbs in the Shadow Orbs' positions"] = "Enable display of bars for anticipated Shadow Orbs in the Shadow Orbs' positions"
L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."] = "Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."
L["File to play."] = "File to play."
L["Fill indicator from right to left"] = "Fill indicator from right to left"
L["Font"] = "Font"
L["Font Color"] = "Font Color"
L["Font Flags"] = "Font Flags"
L["Font Size"] = "Font Size"
L["Frame"] = "Frame"
L["General"] = "General"
L["Growth direction"] = "Growth direction"
L["Height"] = "Height"
L["Horizontal"] = "Horizontal"
L["Instance Type"] = true
L["Interval"] = "Interval"
L["Keep calculating distances and anticipated Orbs when leaving combat."] = "Keep calculating distances and anticipated Orbs when leaving combat."
L["Layout"] = "Layout"
L["Maximum remaining Shadowy Apparition flight time shown on the indicators"] = "Maximum remaining Shadowy Apparition flight time shown on the indicators"
L["Maximum Time"] = "Maximum Time"
L["MONOCHROMEOUTLINE"] = "MONOCHROMEOUTLINE"
L["None"] = "None"
L["Not possible to unlock in WeakAuras mode!"] = "Not possible to unlock in WeakAuras mode!"
L["Orb Cap Color Change"] = "Orb Cap Color Change"
L["Orbs"] = "Orbs"
L["Order in which the Shadow Orbs get filled in"] = "Order in which the Shadow Orbs get filled in"
L["Orientation"] = "Orientation"
L["OUTLINE"] = "OUTLINE"
L["Out-of-Combat Calculation"] = "Out-of-Combat Calculation"
L["\"Overcap Orb\" Color"] = "\"Overcap Orb\" Color"
L["Play Warning Sound when about to cap Shadow Orbs."] = "Play Warning Sound when about to cap Shadow Orbs."
L["Position"] = "Position"
L["Regular"] = "Regular"
L["Regulate display visibility with macro conditionals"] = [=[
Regulate display visibility with macro conditionals
show - show display
hide - hide display
fade - fade out display
]=]
L["Reset Position"] = "Reset Position"
L["Reset to Defaults"] = "Reset to Defaults"
L["Reversed"] = "Reversed"
L["Reverse Direction"] = "Reverse Direction"
L["Scale"] = "Scale"
L["Scanning interval when Aggressive Caching is enabled"] = "Scanning interval when Aggressive Caching is enabled"
L["Set Number Spacing"] = "Set Number Spacing"
L["Set texture used for the background"] = "Set texture used for the background"
L["Shadow"] = "Shadow"
L["Show Orbs out of combat"] = "Show Orbs out of combat"
L["Shows the frame and toggles it for repositioning."] = "Shows the frame and toggles it for repositioning."
L["Simple Display"] = "Simple Display"
L["Sound"] = "Sound"
L["Spacing"] = "Spacing"
L["Starting Test Mode"] = "|cFF814eaaConspicuous Spirits|r: Starting Test Mode"
L["Test Mode"] = "Test Mode"
L["Text"] = "Text"
L["Texture"] = "Texture"
L["THICKOUTLINE"] = "THICKOUTLINE"
L["Threshold when text begins showing first decimal place"] = "Threshold when text begins showing first decimal place"
L["Time between warning sounds"] = "Time between warning sounds"
L["Time Threshold"] = "Time Threshold"
L["Toggle Lock"] = "Toggle Lock"
L["Version"] = "Version"
L["Vertical"] = "Vertical"
L["Visibility"] = "Visibility"
L["WeakAurasDocumentation"] = [=[WA_AUSPICIOUS_SPIRITS(event, count, orbs)
  event - event name (string)
  count - Shadowy Apparition currently in flight (number)
  orbs - player's Shadow Orbs (number) 

Properties conspicuous_spirits_wa:
  count - Shadowy Apparitions currently in flight (number)
  orbs - player's Shadow Orbs (number)
  timers - chronologically ordered table of AceTimer objects corresponding to the automatic cleanup of the Shadowy Apparitions (table)

New properties AceTimer object:
  impactTime - estimated point in time for the Shadowy Apparition impact (timestamp)
  isCached - whether timer is based on cached distance value (boolean)

New method AceTimer object:
  IsGUIDInRange - whether the target is within 100 yards of the player (boolean)]=]
L["WeakAuras Example Strings"] = "WeakAuras Example Strings"
L["WeakAuras Import String 1"] = "WeakAuras Import String 1"
L["WeakAuras Import String 2"] = "WeakAuras Import String 2"
L["WeakAuras Interface"] = "WeakAuras Interface"
L["WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import."] = "WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import."
L["Width"] = "Width"
L["Will show Shadow Orbs frame even when not in combat."] = "Will show Shadow Orbs frame even when not in combat."
L["X Offset"] = "X Offset"
L["X offset for the Shadowy Apparition indicator bars"] = "X offset for the Shadowy Apparition indicator bars"
L["X offset for the Shadowy Apparition time text"] = "X offset for the Shadowy Apparition time text"
L["Y Offset"] = "Y Offset"
L["Y offset for the Shadowy Apparition indicator bars"] = "Y offset for the Shadowy Apparition indicator bars"
L["Y offset for the Shadowy Apparition time text"] = "Y offset for the Shadowy Apparition time text"
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
L["Number of Overcap Orbs"] = true

L["Always show borders"] = true
L["Show borders even when orb isn't shown"] = true
--@end-do-not-package@