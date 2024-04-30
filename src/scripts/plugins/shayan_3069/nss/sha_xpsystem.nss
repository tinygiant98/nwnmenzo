// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
// ::::::::::::::::::::::::Shayan's XP distribution System::::::::::::::::::::::
// ::::::::::::::::::::::::::::::::::Version 1.0::::::::::::::::::::::::::::::::
// :::::::::::::::::::::::::Contact: mail_shayan@yahoo.com::::::::::::::::::::::
// ::::
// :::: Written by: Shayan (Based on a few XP scripts from NWVault)
// ::::              Thanks to Rude for the idea for World of Rhun XP system :)
// :::: Contact: mail_shayan@yhaoo.com                                         :
// ::
// :: Description: This is an XP distribution System. It is made with extreme precision
// ::              to mirror Bioware's XP rate. It can use either Bioware's XP distribution system
// ::              or one that encourages partying. It also takes into account subrace ECL
// ::              and favored classes.
// ::

#include "sha_subr_methds"

// ::DEFINERS
float SHA_GetXP(float CR, float AvgPartyLevel);

object DeadMonster = OBJECT_SELF;

int SHA_GetECL(object oPC)
{
  int iLevel = GetPlayerLevel(oPC);
  if(iLevel > MAXIMUM_PLAYER_LEVEL)
  {
     iLevel = MAXIMUM_PLAYER_LEVEL;
  }
  string Subrace = GetSubRace(oPC);
  if(Subrace == "")
  { return iLevel; }
  else
  {  iLevel += GetECL(oPC); }

  if(iLevel < 0)
  {
     iLevel = 0;
  }
  return iLevel;
}


float SHA_CalculateXPModifier(int PartySize, int NumberOfNPCs)
{
    float fModifier;
    if(USE_BIOWARE_STANDARD_XP_SYSTEM)
    {
      fModifier = 1.0/IntToFloat(PartySize);
    }
    else if(PartySize == 1)
    {
        fModifier = 1.0;
    }
    else if(PartySize > 1)
    {
       fModifier = XP_MODIFIER_FOR_PARTY_OF_TWO + (IntToFloat(PartySize - 2)*XP_MODIFIER_BONUS_PER_PARTY_MEMBER);
       if(fModifier > XP_MAXIMUM_MODIFER_VALUE)
       {
          fModifier = XP_MAXIMUM_MODIFER_VALUE;
       }
    }
    else
    {
       // ::PC's summon or familar killed the monster, and the PC was not near by.
       fModifier = 0.0;
    }

    // ::For NPCs.
    if(NumberOfNPCs >= 1)
    {
       fModifier = fModifier - (XP_MODIFIER_FOR_NPC*IntToFloat(NumberOfNPCs));
    }
    return fModifier;
}

float SHA_GetXP(float CR, float AvgPartyLevel)
{
   // ::Party Level is less than 8 (Special and rather weird distribution)
   if(AvgPartyLevel < 8.0)
   {
       float XP;
       // ::Made up some values for Player level < 1. (Incase of a negative ECL)
       if(AvgPartyLevel < 1.0)
       {
          if(CR < 1.0)
           {
               XP = 3.0;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 6.0;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 10.6;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 16.4;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 28.2;
           }
           else if(CR >= 5.0)
           {
               XP = 32.0;
           }
       }
       else if(AvgPartyLevel >= 1.0 && AvgPartyLevel < 2.0)
       {
           if(CR < 1.0)
           {
               XP = 2.0;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 5.0;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 9.6;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 14.4;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 25.2;
           }
           else if(CR >= 5.0)
           {
               XP = 30.0;
           }
       }
       else if(AvgPartyLevel >= 2.0 && AvgPartyLevel < 3.0)
       {
           if(CR < 1.0)
           {
               XP = 1.8;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 4.8;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 9.0;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 13.7;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 19.2;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 31.5;
           }
           else if(CR >= 6.0)
           {
               XP = 40.0;
           }
       }
       else if(AvgPartyLevel >= 3.0 && AvgPartyLevel < 4.0)
       {
           if(CR < 1.0)
           {
               XP = 1.7;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 4.2;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 7.5;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 12.0;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 17.7;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 24.0;
           }
           else if(CR >= 6.0 && CR < 7.0)
           {
               XP = 37.8;
           }
           else if(CR >= 7.0)
           {
               XP = 50.0;
           }
       }
       else if(AvgPartyLevel >= 4.0 && AvgPartyLevel < 5.0)
       {
           if(CR < 1.0)
           {
               XP = 0.68;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 2.6;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 4.2;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 6.28;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 10.48;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 15.2;
           }
           else if(CR >= 6.0 && CR < 7.0)
           {
               XP = 20.2;
           }
           else if(CR >= 7.0 && CR < 8.0)
           {
               XP = 30.88;
           }
           else if(CR >= 8.0)
           {
              XP = 38.48;
           }
       }
       else if(AvgPartyLevel >= 5.0 && AvgPartyLevel < 6.0)
       {
           if(CR < 1.0)
           {
               XP = 0.68;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 2.28;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 3.28;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 5.28;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 7.68;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 12.6;
           }
           else if(CR >= 6.0 && CR < 7.0)
           {
               XP = 18.08;
           }
           else if(CR >= 7.0 && CR < 8.0)
           {
               XP = 23.48;
           }
           else if(CR >= 8.0 && CR < 9.0)
           {
              XP = 35.28;
           }
           else if(CR > 9.0)
           {
              XP = 42.0;
           }
       }
       else if(AvgPartyLevel >= 6.0 && AvgPartyLevel < 7.0)
       {
           if(CR < 1.0)
           {
               XP = 0.68;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 1.88;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 2.8;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 4.0;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 6.28;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 9.08;
           }
           else if(CR >= 6.0 && CR < 7.0)
           {
               XP = 14.68;
           }
           else if(CR >= 7.0 && CR < 8.0)
           {
               XP = 20.0;
           }
           else if(CR >= 8.0 && CR < 9.0)
           {
              XP = 26.88;
           }
           else if(CR >= 9.0 && CR < 10.0)
           {
              XP = 39.68;
           }
           else if(CR >= 10.0)
           {
              XP = 49.0;
           }
       }
       else if(AvgPartyLevel >= 7.0)
       {
           if(CR < 1.0)
           {
               XP = 0.68;
           }
           else if(CR >= 1.0 && CR < 2.0)
           {
               XP = 1.68;
           }
           else if(CR >= 2.0 && CR < 3.0)
           {
               XP = 2.28;
           }
           else if(CR >= 3.0 && CR < 4.0)
           {
               XP = 3.28;
           }
           else if(CR >= 4.0 && CR < 5.0)
           {
               XP = 4.68;
           }
           else if(CR >= 5.0 && CR < 6.0)
           {
               XP = 7.4;
           }
           else if(CR >= 6.0 && CR < 7.0)
           {
               XP = 10.48;
           }
           else if(CR >= 7.0 && CR < 8.0)
           {
               XP = 16.80;
           }
           else if(CR >= 8.0 && CR < 9.0)
           {
              XP = 23.68;
           }
           else if(CR >= 9.0 && CR < 10.0)
           {
              XP = 28.0;
           }
           else if(CR >= 10.0 && CR < 11.0)
           {
              XP = 44.08;
           }
           else
           {
              XP = 56.0;
           }
       }
       return XP;
   }
   else
   {
       float AdjustedCR = CR - AvgPartyLevel;
       float RewardXP = BASE_XP;
       if(AdjustedCR >= 0.0)
       {
           if(AdjustedCR >= 8.0)
           {
              RewardXP += XP_LEVEL8;
           }
           else if(AdjustedCR < 8.0 && AdjustedCR >= 7.0)
           {
               RewardXP += XP_LEVEL7;
           }
           else if(AdjustedCR < 7.0 && AdjustedCR >= 6.0)
           {
               RewardXP += XP_LEVEL6;
           }
           else if(AdjustedCR < 6.0 && AdjustedCR >= 5.0)
           {
               RewardXP += XP_LEVEL5;
           }
           else if(AdjustedCR < 5.0 && AdjustedCR >= 4.0)
           {
               RewardXP += XP_LEVEL4;
           }
           else if(AdjustedCR < 4.0 && AdjustedCR >= 3.0)
           {
                RewardXP += XP_LEVEL3;
           }
           else if(AdjustedCR < 3.0 && AdjustedCR >= 2.0)
           {
                RewardXP += XP_LEVEL2;
           }
           else if(AdjustedCR < 2.0 && AdjustedCR >= 0.5)
           {
                 RewardXP += XP_LEVEL1;
           }
           else if(AdjustedCR < 0.5 && AdjustedCR >= 0.0)
           {
               // ::Nothing, just base XP. The Monster is of a challenging level.
           }
       }
       else
       {
           if(AdjustedCR <= -9.0)
           {
               RewardXP = 0.4;
           }
           else if(AdjustedCR > -9.0 && AdjustedCR <= -8.0)
           {
               RewardXP += XP_LEVEL_8;
           }
           else if(AdjustedCR > -8.0 && AdjustedCR <= -7.0)
           {
               RewardXP += XP_LEVEL_7;
           }
           else if(AdjustedCR > -7.0 && AdjustedCR <= -6.0)
           {
               RewardXP += XP_LEVEL_6;
           }
           else if(AdjustedCR > -6.0 && AdjustedCR <= -5.0)
           {
               RewardXP += XP_LEVEL_5;
           }
           else if(AdjustedCR > -5.0 && AdjustedCR <= -4.0)
           {
               RewardXP += XP_LEVEL_4;
           }
           else if(AdjustedCR > -4.0 && AdjustedCR <= -3.0)
           {
                RewardXP += XP_LEVEL_4;
           }
           else if(AdjustedCR > -3.0 && AdjustedCR <= -2.0)
           {
                RewardXP += XP_LEVEL_3;
           }
           else if(AdjustedCR > -2.0 && AdjustedCR <= -1.0)
           {
                 RewardXP += XP_LEVEL_2;
           }
           else if(AdjustedCR > -1.0 && AdjustedCR < -0.5)
           {
                 RewardXP += XP_LEVEL_1;
           }
           else if(AdjustedCR > -0.5 && AdjustedCR < 0.0)
           {
               // ::base XP. The Monster is of a challenging level.
           }
       }
     return RewardXP;
   }
}


void main()
{
   object oKiller = GetLastKiller();
   if(GetIsDM(oKiller))
   { return; }
   int PCPartySize = 0;
   int TotalLevel = 0;
   int NumberOfNPCs = 0;
   int HighestLevel = 0;
   // ::Count PCs and NPCs in party as well as the PCs' levels.
   object Member = GetFirstFactionMember(oKiller, FALSE);
   while(GetIsObjectValid(Member))
   {
       if((GetDistanceBetween(DeadMonster, Member) <= MAX_DISTANCE_BETWEEN_PC_AND_MONSTER)
           && (GetArea(Member) == GetArea(DeadMonster)) && !GetIsDead(Member))
       {
              if(GetIsPC(Member))
              {
                  PCPartySize++;
                  int level = SHA_GetECL(Member);
                  TotalLevel += level;
                  if(level > HighestLevel)
                  {
                      HighestLevel = level;
                  }
              }
              else
              {
                  NumberOfNPCs++;
              }
       }
       Member = GetNextFactionMember(oKiller, FALSE);
   }
   // ::Killed by familar. PC not in range.
   if(PCPartySize == 0)
   { return; }
   float AvgPartyLevel = IntToFloat(TotalLevel)/IntToFloat(PCPartySize);
   float LevelOfHighestMember = IntToFloat(HighestLevel);
   int GapExceeded = FALSE;
   if(AvgPartyLevel + MAXIMUM_LEVEL_GAP < LevelOfHighestMember)
   {
       AvgPartyLevel = LevelOfHighestMember;
       GapExceeded = TRUE;
   }
   float fCR = GetChallengeRating(OBJECT_SELF);
   float XP = SHA_GetXP(fCR, AvgPartyLevel);
   float XPModifier = SHA_CalculateXPModifier(PCPartySize, NumberOfNPCs);

   float RewardXP = XP_SLIDER_VALUE*XP*XPModifier;
   if(RewardXP <= 0.0)
   {
       // ::incase the user had set rediculous values...
       RewardXP = 0.0;
   }
   Member = GetFirstFactionMember(oKiller, TRUE);
   while(GetIsObjectValid(Member))
   {
       if((GetDistanceBetween(DeadMonster, Member) <= MAX_DISTANCE_BETWEEN_PC_AND_MONSTER)
           && (GetArea(Member) == GetArea(DeadMonster)) && !GetIsDead(Member))
       {
          if(GetIsPC(Member))
          {
             if(GapExceeded)
             {
                SendMessageToPC(Member, "XP rate is limited: Average party level and level of the highest level party member differ by more than " + IntToString(FloatToInt(MAXIMUM_LEVEL_GAP)));
             }
             // ::check for any adjustment in Subrace's favored classes.
             float iSubMod = GetSubraceXPModifier(Member);
             int iRewardXP = FloatToInt(RewardXP*iSubMod);
             if(XP_DEBUG)
             {
                SendMessageToPC(Member, "Creature CR: " + FloatToString(fCR) + ". /n Party size: " + IntToString(PCPartySize) + "./n NPCs or Familiars: " + IntToString(NumberOfNPCs) + "./n Average Party Level: " + FloatToString(AvgPartyLevel) + (GapExceeded?"./n Has party Exceeded Max Level Gap":""));
             }
             GiveXPToCreature(Member, iRewardXP);
          }
       }
       Member = GetNextFactionMember(oKiller, TRUE);
   }
}

