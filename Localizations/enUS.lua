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

L["Aggressive Caching"] = true
L["Aggressive Caching Interval"] = true
L["Border Color"] = true
L["Color 1"] = true
L["Color 2"] = true
L["Color 3"] = true
L["Complex Display"] = true
L["Conspicuous Spirits locked!"] = true
L["Conspicuous Spirits reset!"] = true
L["Conspicuous Spirits unlocked!"] = true
L["Documentation"] = true
L["Enable"] = true
L["Enables frequent distance scanning of all available targets. Will increase CPU usage slightly and is only going to increase accuracy in situations with many fast-moving mobs."] = true
L["File to play."] = true
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
L["WeakAurasDocumentation"] = "WA_AUSPICIOUS_SPIRITS(event, count, orbs)\n  event - event name (string)\n  count - Shadowy Apparition currently in flight (number)\n  orbs - player's Shadow Orbs (number) \n\nProperties wa_as:\n  count - Shadowy Apparitions currently in flight (number)\n  orbs - player's Shadow Orbs (number)\n  timers - chronologically ordered table of AceTimer timer objects (table)"
L["Width"] = true
L["Will show Shadow Orbs frame even when not in combat."] = true
L["X Offset"] = true
L["X offset for the Shadowy Apparition time text"] = true
L["Y Offset"] = true
L["Y offset for the Shadowy Apparition time text"] = true

--@end-do-not-package@