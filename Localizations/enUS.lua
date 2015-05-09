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
--@localization(locale="enUS", format="lua_additive_table", same-key-is-true=true)@

--@do-not-package@

L["Aggressive Caching"] = "Aggressive Caching"
L["Aggressive Caching Interval"] = "Aggressive Caching Interval"
L["Anticipated Orbs"] = "Anticipated Orbs"
L["Background Color"] = "Background Color"
L["Border Color"] = "Border Color"
L["Can not change visibility options in combat."] = "Can not change visibility options in combat."
L["Change color of all Shadow Orbs when reaching five Shadow Orbs"] = true
L["Color"] = "Color"
L["Color 1"] = "Color 1"
L["Color 2"] = "Color 2"
L["Color 3"] = "Color 3"
L["Color When Orb Capped"] = true
L["Color of the sixth indicator when overcapping with Shadowy Apparitions"] = "Color of the sixth indicator when overcapping with Shadowy Apparitions"
L["Complex Display"] = "Complex Display"
L["Conspicuous Spirits locked!"] = "|cFF613B82Conspicuous Spirits|r locked!"
L["Conspicuous Spirits reset!"] = "|cFF613B82Conspicuous Spirits|r reset!"
L["Conspicuous Spirits unlocked!"] = "|cFF613B82Conspicuous Spirits|r unlocked!"
L["Documentation"] = "Documentation"
L["dragFrameTooltip"] = [=[Left mouse button to drag.
Right mouse button to lock.
Mouse wheel and shift + mouse wheel for fine adjustment.]=]
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
L["Interval"] = "Interval"
L["IronMaidensShipMessage"] = "prepares to man the Dreadnaught's Main Cannon!"
L["Keep calculating distances and anticipated Orbs when leaving combat."] = "Keep calculating distances and anticipated Orbs when leaving combat."
L["Layout"] = "Layout"
L["Maximum remaining Shadowy Apparition flight time shown on the indicators"] = "Maximum remaining Shadowy Apparition flight time shown on the indicators"
L["Maximum Time"] = "Maximum Time"
L["MONOCHROMEOUTLINE"] = "MONOCHROMEOUTLINE"
L["None"] = "None"
L["Not possible to unlock in WeakAuras mode!"] = "Not possible to unlock in WeakAuras mode!"
L["Orb Cap Color Change"] = true
L["Orbs"] = "Orbs"
L["Order in which the Shadow Orbs get filled in"] = "Order in which the Shadow Orbs get filled in"
L["Orientation"] = "Orientation"
L["OUTLINE"] = "OUTLINE"
L["Out-of-Combat Calculation"] = "Out-of-Combat Calculation"
L["\"Overcap Orb\" Color"] = "\"Overcap Orb\" Color"
L["Play Warning Sound when about to cap Shadow Orbs."] = "Play Warning Sound when about to cap Shadow Orbs."
L["Position"] = "Position"
L["Regular"] = "Regular"
L["Regulate display visibility with macro conditionals"] = "Regulate display visibility with macro conditionals"
L["Reset Position"] = "Reset Position"
L["Reset to Defaults"] = "Reset to Defaults"
L["Reversed"] = "Reversed"
L["Reverse Direction"] = "Reverse Direction"
L["Scale"] = "Scale"
L["Scanning interval when Aggressive Caching is enabled"] = "Scanning interval when Aggressive Caching is enabled"
L["Select font for the Complex display"] = "Select font for the Complex display"
L["Select font for the Simple display"] = "Select font for the Simple display"
L["Set Color 1"] = "Set Color 1"
L["Set Color 2"] = "Set Color 2"
L["Set Color 3"] = "Set Color 3"
L["Set Display border color"] = "Set Display border color"
L["Set Display orientation"] = "Set Display orientation"
L["Set Font Color"] = "Set Font Color"
L["Set Font Flags"] = "Set Font Flags"
L["Set Font Size"] = "Set Font Size"
L["Set Frame Height"] = "Set Frame Height"
L["Set Frame Scale"] = "Set Frame Scale"
L["Set Frame Width"] = "Set Frame Width"
L["Set Number Spacing"] = "Set Number Spacing"
L["Set Shadow Orb border color"] = "Set Shadow Orb border color"
L["Set Shadow Orb Height"] = "Set Shadow Orb Height"
L["Set Shadow Orb Spacing"] = "Set Shadow Orb Spacing"
L["Set Shadow Orb Width"] = "Set Shadow Orb Width"
L["Set texture used for the background"] = "Set texture used for the background"
L["Set texture used for the Shadow Orbs"] = "Set texture used for the Shadow Orbs"
L["Shadow"] = "Shadow"
L["Show Orbs out of combat"] = "Show Orbs out of combat"
L["Shows the frame and toggles it for repositioning."] = "Shows the frame and toggles it for repositioning."
L["Simple Display"] = "Simple Display"
L["Sound"] = "Sound"
L["Spacing"] = "Spacing"
L["Text"] = "Text"
L["Texture"] = "Texture"
L["THICKOUTLINE"] = "THICKOUTLINE"
L["Time between warning sounds"] = "Time between warning sounds"
L["Toggle Lock"] = "Toggle Lock"
L["Version"] = true
L["Vertical"] = "Vertical"
L["Visibility"] = "Visibility"
L["WeakAurasDocumentation"] = [=[WA_AUSPICIOUS_SPIRITS(event, count, orbs)
  event - event name (string)
  count - Shadowy Apparition currently in flight (number)
  orbs - player's Shadow Orbs (number) 

Properties conspicuous_spirits_wa:
  count - Shadowy Apparitions currently in flight (number)
  orbs - player's Shadow Orbs (number)
  timers - chronologically ordered table of AceTimer timer objects corresponding to the Shadowy Apparitions (table)

New property AceTimer object:
  impactTime - estimated point in time for the Shadowy Apparition impact (timestamp)]=]
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

--@end-do-not-package@