// -----------------------------------------------------------------------------
//    File: admin_l_plugin.nss
//  System: PW Admin/base event management (library script)
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "util_i_chat"

void admin_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    if (HasChatKey(oPC, "debug"))
    {
        int nLevel = GetChatKeyValueInt(oPC, "debug");
        SetLocalInt(GetModule(), "DEBUG_LEVEL", nLevel);

        nLevel = GetLocalInt(GetModule(), "DEBUG_LEVEL");
        SendChatResult("Debug level set to " + IntToString(nLevel), oPC, FLAG_INFO);

        return;
    }
    else if (HasChatKey(oPC, "log"))
    {
        string sLog = GetChatKeyValue(oPC, "log");
        if (sLog == "none")
            SetDebugLogging(DEBUG_LOG_NONE);
        else if (sLog == "file")
            SetDebugLogging(DEBUG_LOG_FILE);
        else if (sLog == "dm")
            SetDebugLogging(DEBUG_LOG_DM);
        else if (sLog == "pc")
            SetDebugLogging(DEBUG_LOG_PC);
        else if (sLog == "all")
            SetDebugLogging(DEBUG_LOG_ALL);
        else if (sLog == "max")
        {
            SetDebugLevel(DEBUG_LEVEL_DEBUG, GetModule());
            SetDebugLogging(DEBUG_LOG_ALL);
            SendChatResult("Max Debug/Log Levels set", oPC, FLAG_INFO);
        }

        return;
    }
    else if (HasChatKey(oPC, "quest"))
    {
        string sQuestTag = GetChatKeyValue(oPC, "quest");
        if (GetQuestExists(sQuestTag))
        {
            //if (GetIsQuestAssignable(oPC, sQuestTag))
                AssignQuest(oPC, sQuestTag);
        }
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("admin"))
    {
        object oPlugin = CreatePlugin("admin");
        SetName(oPlugin, "[Plugin] PW Administration");
        SetDescription(oPlugin,
            "This plugin controls all administrative functions for the pw.");
        SetDebugPrefix(HexColorString("[Admin]", COLOR_BLUE_SLATE_MEDIUM), oPlugin);

        // These are default bioware events in case other systems don't override them.
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_ACQUIRE_ITEM,         "x2_mod_def_aqu",   2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_ACTIVATE_ITEM,        "x2_mod_def_act",   2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER,         "x3_mod_def_enter", 2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,          "x2_mod_def_load",  2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DEATH,         "nw_o0_death",      EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_DYING,         "nw_o0_dying",      EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_EQUIP_ITEM,    "x2_mod_def_equ",   2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN,       "nw_o0_respawn",    2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_REST,          "x2_mod_def_rest",  EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM,  "x2_mod_def_unequ", 2.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_UNACQUIRE_ITEM,       "x2_mod_def_unaqu", 2.0);

        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_BLOCKED,            "nw_c2_defaulte",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_COMBAT_ROUND_END,   "nw_c2_default3",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_CONVERSATION,       "nw_c2_default4",   EVENT_PRIORITY_LAST);
        RegisterEventScritp(oPlugin, CREATURE_EVENT_ON_CONVERSATION,       "nw_g0_conversat",  EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DAMAGED,            "nw_c2_default6",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DEATH,              "nw_c2_default7",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_DISTURBED,          "nw_c2_default8",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_HEARTBEAT,          "nw_c2_default1",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_PERCEPTION,         "nw_c2_default2",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_PHYSICAL_ATTACKED,  "nw_c2_default5",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_RESTED,             "nw_c2_defaulta",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_SPAWN,              "nw_c2_default9",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_SPELL_CAST_AT,      "nw_c2_defaultb",   EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, CREATURE_EVENT_ON_USER_DEFINED,       "nw_c2_defaultd",   EVENT_PRIORITY_DEFAULT);

        RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_CONVERSATION,      "nw_g0_conversat",  EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, DOOR_EVENT_ON_CONVERSATION,           "nw_g0_conversat",  EVENT_PRIORITY_DEFAULT);

        RegisterEventScript(oPlugin, DOOR_EVENT_ON_AREA_TRANSITION_CLICK,  "nw_g0_transition", EVENT_PRIORITY_DEFAULT);
        RegisterEventScript(oPlugin, TRIGGER_EVENT_ON_CLICK,               "nw_g0_transition", EVENT_PRIORITY_DEFAULT);

        RegisterEventScript(oPlugin, CHAT_PREFIX + "!admin", "admin_OnPlayerChat");
        RegisterLibraryScript("admin_OnPlayerChat", 1);
    }
}

void OnLibraryScript(string sScript, int nEntry)
{
    if (nEntry == 1) admin_OnPlayerChat();

}
