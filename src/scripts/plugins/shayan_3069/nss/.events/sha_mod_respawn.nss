#include "sha_subr_methds"
void main()
{
    object oPC = GetLastPlayerDied();

    // will jump to NW_DEATH_TEMPLE
    //ExecuteScript("nw_o0_respawn",oPC);

    // if no NW_DEATH_TEMPLE then try waypoints
    if (USE_SSE_DEATH_RESPAWN == TRUE)
    {
        if (GetIsObjectValid(GetWaypointByTag("NW_DEATH_TEMPLE")) == FALSE)
        {
            object oDeath = GetSubraceDeathWaypoint(oPC);
            if (GetIsObjectValid(oDeath))
                {
                    Subrace_MoveToDeathLocation(oPC);
                }
            else // no subrace death waypoint, so subrace or module start
                {
                    if (USE_SSE_DEATH_DEFAULT_TO_SUBRACE_START == TRUE)
                    { // use subrace start waypoint if possible
                        object oStart = GetSubraceStartWaypoint(oPC);
                        if (GetIsObjectValid(oStart))
                        {
                            string subrace = GetSubraceNameByAlias(GetSubRace(oPC));
                            Subrace_MoveToStartLocation(oPC, subrace);
                        }
                        else
                        {
                            AssignCommand(oPC, JumpToLocation(GetStartingLocation()));
                        }
                    }
                    else // jump to the module start
                    {
                        AssignCommand(oPC, JumpToLocation(GetStartingLocation()));
                    }
                }
        }
    }
}
