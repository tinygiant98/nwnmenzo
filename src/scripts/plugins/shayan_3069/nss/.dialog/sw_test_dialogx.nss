// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
// ::::::::::Extension: Moon's Subrace Selection Converstion for SSE :::::::::::
// ::::::::::::Contact: http://p2.forumforfree.com/shayan.html::::::::::::::::::
// ::::
// :::: Written by: DM_Moon
// ::
// :: Description: Subrace Conversation used in SSE's Wand system.
// ::
#include "sw_main_inc"
int StartingConditional()
{
   object oMySpeaker = GetLastSpeaker();

   //This starts with 0 for token 8111
   int nMyNum = GetLocalInt(oMySpeaker, "subrace_dm_wand_pos");
   nMyNum++;
   SetLocalInt(oMySpeaker, "subrace_dm_wand_pos", nMyNum);

   string sMyString = GetLocalString(oMySpeaker, "swand_dialog" + IntToString(nMyNum));



   if(sMyString == "")
   {
      return FALSE;
   }
   else
   {
      SetCustomToken(SWAND_START_CUSTOM_TOKEN + nMyNum, sMyString);
      return TRUE;
   }
}
