#include "sha_subr_methds"

void main()
{
    object oPC = GetLastUsedBy();
    Subrace_MoveToStartLocation(oPC,GetSubraceNameByAlias(GetSubRace(oPC)));
}
