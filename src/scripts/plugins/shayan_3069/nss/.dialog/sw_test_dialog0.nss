// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
// :::::::::::::::::::::::::: Extension: SWand :::::::::::::::::::::::::::::::::
// ::::::::::::Contact: http://p2.forumforfree.com/shayan.html::::::::::::::::::
// ::::
// :::: Written by: DM_Moon
// ::
// :: Description: Subrace Conversation used in SSE's SWand system.
// ::
#include "sw_main_inc"
int StartingConditional()
{
    swandScriptInit();
    int nMyNum = 0;
    SetLocalInt(oMySpeaker, "subrace_dm_wand_pos", nMyNum);

    //Check whether this conversation has been started already, start it if not.
    if(!sw_gl_Status)
    {
          SetConversationStatus(oMySpeaker, SWAND_CONVO_RUNNING);
          swand_StartConversation();

    }
    string sMyString = GetLocalString(oMySpeaker, "swand_dialog" + IntToString(nMyNum));

    if(sw_gl_Status==SWAND_CONVO_CLOSE || sMyString == "") //No abort check, since abort is instant.
    {
        //Doing this to prevent abort event on running, when there is no string.
        SetConversationStatus(oMySpeaker, SWAND_CONVO_CLOSE);
        return FALSE;
    }
    else
    {
        SetCustomToken(SWAND_START_CUSTOM_TOKEN + nMyNum, sMyString);
        return TRUE;
    }
}
