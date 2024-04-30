// -----------------------------------------------------------------------------
//    File: subrace_l_plugin.nss
//  System: Shayan's subrace system (library)
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "util_i_chat"

void subrace_OnModuleLoad()
{

}

void subrace_OnPlayerChat()
{

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

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD, "subrace_OnModuleLoad");
        RegisterEventScript(oPlugin, CHAT_PREFIX + "!subrace", "subrace_OnPlayerChat");

        int n;
        RegiseterLibraryScript("subrace_OnModuleLoad", n++);
        RegisterLibraryScript("subrace_OnPlayerChat", n++);
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
        } break;

        default: Error("[subrace_l_plugin] " + sScript + " (" + IntToString(nEntry) + ") not found in library resources");
    }
}
