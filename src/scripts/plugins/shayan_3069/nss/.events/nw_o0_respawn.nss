//::///////////////////////////////////////////////
//:: Generic On Pressed Respawn Button
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// * June 1: moved RestoreEffects into plot include
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   November
//:://////////////////////////////////////////////
#include "nw_i0_plot"
#include "sha_subr_methds"

// * Applies an XP and GP penalty
// * to the player respawning
void ApplyPenalty(object oDead)
{
    int nXP = GetXP(oDead);
    int nPenalty = 50 * GetHitDice(oDead);
    int nHD = GetHitDice(oDead);
    // * You can not lose a level with this respawning
    int nMin = ((nHD * (nHD - 1)) / 2) * 1000;

    int nNewXP = nXP - nPenalty;
    if (nNewXP < nMin)
       nNewXP = nMin;
    SetXP(oDead, nNewXP);
    int nGoldToTake =    FloatToInt(0.10 * GetGold(oDead));
    // * a cap of 10 000gp taken from you
    if (nGoldToTake > 10000)
    {
        nGoldToTake = 10000;
    }
    AssignCommand(oDead, TakeGoldFromCreature(nGoldToTake, oDead, TRUE));
    DelayCommand(4.0, FloatingTextStrRefOnCreature(58299, oDead, FALSE));
    DelayCommand(4.8, FloatingTextStrRefOnCreature(58300, oDead, FALSE));

}

void main()
{
    object oRespawner = GetLastRespawnButtonPresser();
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectResurrection(),oRespawner);
    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectHeal(GetMaxHitPoints(oRespawner)), oRespawner);
    RemoveEffects(oRespawner);

//Shayan's Subrace Engine Code
    SubraceOnPlayerRespawn();
//End Shayan's Subrace Engine Code.

    //* Return PC to temple
    string sDestTag =  "NW_DEATH_TEMPLE";
    string sArea = GetTag(GetArea(oRespawner));
    if (GetIsObjectValid(GetObjectByTag(sDestTag)))
    {

        if (sDestTag == "NW_DEATH_TEMPLE")
        {
            object oPriest = GetObjectByTag("NW_DEATH_CLERIC");
            AssignCommand(oPriest, DelayCommand(2.1, PlayVoiceChat(VOICE_CHAT_TALKTOME, oPriest)));
            SetLocalLocation(oRespawner, "NW_L_I_DIED_HERE", GetLocation(GetLastRespawnButtonPresser()));
            SetLocalInt(oRespawner, "NW_L_I_DIED", 1);
            SetLocalObject(oPriest, "NW_L_LASTDIED", GetLastRespawnButtonPresser());
            // * April 2002: Moved penalty here, only when going back to the death temple
            ApplyPenalty(oRespawner);
        }
        object oSpawnPoint = GetObjectByTag(sDestTag);
        AssignCommand(oRespawner,JumpToLocation(GetLocation(oSpawnPoint)));
        // * mak
    }
    else
    {
        // * do nothing, just 'res where you are.
    }
 }
