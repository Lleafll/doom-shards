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

L["\"Overcap Orb\" Color"] = true
L["Aggressive Caching"] = true
L["Aggressive Caching Interval"] = true
L["Anticipated Orbs"] = true
L["Background Color"] = true
L["Border Color"] = true
L["Can not change visibility options in combat."] = true
L["Color"] = true
L["Color 1"] = true
L["Color 2"] = true
L["Color 3"] = true
L["Color of the sixth indicator when overcapping with Shadowy Apparitions"] = true
L["Complex Display"] = true
L["Conspicuous Spirits locked!"] = true
L["Conspicuous Spirits reset!"] = true
L["Conspicuous Spirits unlocked!"] = true
L["Documentation"] = true
L["Enable"] = true
L["Enable display of bars for anticipated Shadow Orbs in the Shadow Orbs' positions"] = true
L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."] = true
L["File to play."] = true
L["Fill indicator from right to left"] = true
L["Font"] = true
L["Font Color"] = true
L["Font Flags"] = true
L["Font Size"] = true
L["Frame"] = true
L["General"] = true
L["Growth direction"] = true
L["Height"] = true
L["Horizontal"] = true
L["Interval"] = true
L["IronMaidensShipMessage"] = "prepares to man the Dreadnaught's Main Cannon!"
L["Keep calculating distances and anticipated Orbs when leaving combat."] = true
L["Layout"] = true
L["Left mouse button to drag."] = true
L["Maximum remaining Shadowy Apparition flight time shown on the indicators"] = true
L["Maximum Time"] = true
L["MONOCHROMEOUTLINE"] = true
L["None"] = true
L["Not possible to unlock in WeakAuras mode!"] = true
L["Orbs"] = true
L["Order in which the Shadow Orbs get filled in"] = true
L["Orientation"] = true
L["Out-of-Combat Calculation"] = true
L["OUTLINE"] = true
L["Play Warning Sound when about to cap Shadow Orbs."] = true
L["Position"] = true
L["Regular"] = true
L["Regulate display visibility with macro conditionals"] = true
L["Reset Position"] = true
L["Reset to Defaults"] = true
L["Reverse Direction"] = true
L["Reversed"] = true
L["Scale"] = true
L["Scanning interval when Aggressive Caching is enabled"] = true
L["Select font for the Complex display"] = true
L["Select font for the Simple display"] = true
L["Set Color 1"] = true
L["Set Color 2"] = true
L["Set Color 3"] = true
L["Set Display orientation"] = true
L["Set Display border color"] = true
L["Set Frame Scale"] = true
L["Set Font Color"] = true
L["Set Font Flags"] = true
L["Set Font Size"] = true
L["Set Frame Height"] = true
L["Set Frame Width"] = true
L["Set Number Spacing"] = true
L["Set Shadow Orb border color"] = true
L["Set Shadow Orb Height"] = true
L["Set Shadow Orb Spacing"] = true
L["Set Shadow Orb Width"] = true
L["Set texture used for the background"] = true
L["Set texture used for the Shadow Orbs"] = true
L["Shadow"] = true
L["Show Orbs out of combat"] = true
L["Shows the frame and toggles it for repositioning."] = true
L["Simple Display"] = true
L["Sound"] = true
L["Spacing"] = true
L["Text"] = true
L["Texture"] = true
L["THICKOUTLINE"] = true
L["Time between warning sounds"] = true
L["Toggle Lock"] = true
L["Vertical"] = true
L["Visibility"] = true
L["WeakAuras Import String 1"] = true
L["WeakAuras Import String 2"] = true
L["WeakAuras Interface"] = true
L["WeakAuras Example Strings"] = true
L["WeakAuras String to use when \"WeakAuras\" Display is selected. Copy & paste into WeakAuras to import."] = true
L["WeakAurasDocumentation"] = [=[WA_AUSPICIOUS_SPIRITS(event, count, orbs)
  event - event name (string)
  count - Shadowy Apparition currently in flight (number)
  orbs - player's Shadow Orbs (number) 

Properties wa_as:
  count - Shadowy Apparitions currently in flight (number)
  orbs - player's Shadow Orbs (number)
  timers - chronologically ordered table of AceTimer timer objects corresponding to the Shadowy Apparitions (table)

New property AceTimer object:
  impactTime - estimated point in time for the Shadowy Apparition impact (timestamp)]=]
L["Width"] = true
L["Will show Shadow Orbs frame even when not in combat."] = true
L["X Offset"] = true
L["X offset for the Shadowy Apparition indicator bars"] = true
L["X offset for the Shadowy Apparition time text"] = true
L["Y Offset"] = true
L["Y offset for the Shadowy Apparition time text"] = true
L["Y offset for the Shadowy Apparition indicator bars"] = true

--@end-do-not-package@