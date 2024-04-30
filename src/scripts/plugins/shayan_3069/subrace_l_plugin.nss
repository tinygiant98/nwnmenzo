// -----------------------------------------------------------------------------
//    File: subrace_l_plugin.nss
//  System: Shayan's subrace system (library)
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "util_i_chat"

#include "sha_subr_methds"
#include "x2_inc_intweapon"


void subrace_OnModuleLoad()
{

}

void subrace_OnClientEnter()
{
    SubraceOnClientEnter();
}

void subrace_OnClientLeave()
{
    SubraceOnClientLeave();
}

void subrace_OnActivateItem()
{
    SubraceOnItemActivated();
}

void subrace_OnPlayerLevelup()
{
    SubraceOnPlayerLevelUp();
}

void subrace_OnPlayerEquip()
{
    if (!GetHasEffect(EFFECT_TYPE_POLYMORPH, GetPCItemLastEquippedBy()))
        return;

    SubraceOnPlayerEquipItem();
}

void subrace_OnPlayerRespawn()
{
    SubraceOnPlayerRespawn();
}

void subrace_OnPlayerChat()
{

}

// Tag-based script for sha_respawn.utp (sha_death.nss)
void sha_respawn()
{
    if (GetCurrentlyRunningEvent(FALSE) == EVENT_SCRIPT_PLACEABLE_ON_USED)
        Subrace_MoveToDeathLocation(GetLastUsedBy());
}

// Tag-based script for plc_sha_portal.utp (sha_enter.nss)
void plc_sha_portal()
{
    if (GetCurrentlyRunningEvent(FALSE) == EVENT_SCRIPT_PLACEABLE_ON_USED)
        Subrace_MoveToStartLocation(oPC, GetSubraceNameByAlias(GetSubRace(GetLastUsedBy())));
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("subrace"))
    {
        object oPlugin = CreatePlugin("subrace");
        SetName(oPlugin, "[Plugin] Subrace Management System");
        SetDescription(oPlugin,
            "Implements Shayan's Subrace System.");
        SetDebugPrefix(HexColorString("[Subrace]", COLOR_PINK), oPlugin);

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "subrace_OnModuleLoad", EVENT_PRIORITY_FIRST);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "x3_mod_def_load,x2_mod_def_load", 9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "sha_on_modload", 6.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT, "sha_on_mod_hbeat", 1.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_HEARTBEAT, "sha_clock", 8.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN, "sha_mod_respawn", 4.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_RESPAWN, "subrace_OnPlayerRespawn", 3.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "subrace_OnClientEnter", 9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_LEAVE, "subrace_OnClientLeave", 9.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_ACTIVATE_ITEM, "subrace_OnActivateItem", 5.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_LEVEL_UP, "subrace_OnPlayerLevelup", 5.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_EQUIP_ITEM, "subrace_OnPlayerEquip", 5.0);
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_SPELLHOOK, "sha_spellhooks", 9.0);

        RegisterEventScript(oPlugin, CHAT_PREFIX + "!subrace", "subrace_OnPlayerChat");

        int n;
        RegiseterLibraryScript("subrace_OnModuleLoad", n++);
        RegisterLibraryScript("subrace_OnPlayerChat", n++);
        RegisterLibraryScript("subrace_OnClientEnter", n++);
        RegisterLibraryScript("subrace_OnClientLeave", n++);
        RegisterLibraryScript("subrace_OnActivateItem", n++);
        RegisterLibraryScript("subrace_OnPlayerLevelup", n++);
        RegisterLibraryScript("subrace_OnPlayerEquip", n++);
        RegisterLibraryScript("subrace_OnPlayerRespawn", n++);

        n = 100;
        RegisterLibraryScript("sha_respawn", n++);
        RegisterLibraryScript("plc_sha_portal", n++);
    }
}

void OnLibraryScript(string sScript, int nEntry)
{
    int n = nEntry / 100 * 100;
    switch (n)
    {
        case 0:
        {
            if      (nEntry == n++) subrace_OnModuleLoad();
            else if (nEntry == n++) subrace_OnPlayerChat();
            else if (nEntry == n++) subrace_OnClientEnter();
            else if (nEntry == n++) subrace_OnClientLeave();
            else if (nEntry == n++) subrace_OnActivateItem();
            else if (nEntry == n++) subrace_OnPlayerLevelup();
            else if (nEntry == n++) subrace_OnPlayerEquip();
            else if (nEntry == n++) subrace_OnPlayerRespawn();
        } break;

        case 100:
        {
            if      (nEntry == n++) sha_respawn();
            else if (nEntry == n++) plc_sha_portal();
        } break;

        default: Error("[subrace_l_plugin] " + sScript + " (" + IntToString(nEntry) + ") not found in library resources");
    }
}
