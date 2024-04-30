//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::::::::File Name: sha_misc_funcs :::::::::::::::::::::::::::::
//:::::::::::::::::::::::::: Include script ::::::::::::::::::::::::::::::::::::
//
// :: * Miscellaneous functions created and or copied by Shayan ;)
// :: Added to by: DM_Moon

#include "sha_subr_consts"


void DebugS(string Text);
void DebugHex(int Hex, string Pre="", string Sur="");
void DebugHex(int Hex, string Pre="", string Sur="")
{
DebugS(Pre + " " + IntToHexString(Hex) + " " + Sur);
}

void DebugI(int Int, string Pre="", string Sur="");
void DebugI(int Int, string Pre="", string Sur="")
{
DebugS(Pre + " " + IntToString(Int) + " " + Sur);
}

void DebugS(string Text)
{
SendMessageToPC(GetFirstPC(), "[DEBUG]: " + Text);
}

//Calculate level by experience points to avoid exploitation.
int GetPlayerLevel(object oPC);

//returns the highest value of these two.
int Max(int Num1, int Num2);


//Colours a string with sColour. Will add the <c> and the </c> part, so sColour
//should NOT contain these. Use COLOUR_* constants.
string ColourString(string sText, string sColour=COLOUR_GREEN);

//Converts oItem into a HexDecimal (Flags) for sorting.
int GetItemType(object oItem);

//Test if oItem Matches iType.
//
//  Use:
//  ITEM_TYPE_*
//You can test against multiple types by the follow method
// Using:
// ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_RANGED_THROWING | ITEM_TYPE_AMMO
// will test if oItem is either a Melee, Ranged/Throwing Weapon or is Ammo.
//
// Using:
// ~(ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_RANGED_THROWING | ITEM_TYPE_AMMO)
// will test if oItem is all BUT a Melee, Ranged/Throwing Weapon or is Ammo.
//
//
// Note: Due to limitations of NWScript iType defaults to 0xFFFFFFFF. But in truth it defaults to: ITEM_TYPE_ALL.
//
//
// Note the following sample code:
//
// object oItem = GetFirstItemInInventory();
// int iType = ITEM_TYPE_FULL_ARMOR_SET | ITEM_TYPE_JEWLERY;
// if(SHA_TestItemAgainstType(oItem, iType) ) //Remember that anything but 0 is causes if to return TRUE
//     {
//     SpeakString("oItem is either an Armor, Helm, Shield or a piece of Jewlery");
//     }
//     else SpeakString("oItem was NOT an Armor, Helm, Shield or a piece of Jewlery");
//
// usage A (if bBoolean is FALSE)
//
// returns all the ITEM_TYPE_* which applies.
// returns ITEM_TYPE_NONE_BIOWARE_ITEM if oItem does not match any records but IS a Valid Item.
// returns FALSE ( ITEM_TYPE_INVALID ) if no ITEM_TYPE_* Applies or if oItem is not a Valid Item.
//
// usage B (if bBoolean is TRUE)
//
// returns TRUE if oItem matches iType (in part or fully)
// returns ITEM_TYPE_NONE_BIOWARE_ITEM if oItem does not match any records but IS a Valid Item.
// returns FALSE ( ITEM_TYPE_INVALID ) if no ITEM_TYPE_* Applies or if oItem is not a Valid Item.
int SHA_TestItemAgainstType(object oItem, int iType=0xFFFFFFFF, int bBoolean=FALSE);


//Works like SHA_TestItemAgainstType except this tests a previously aqquired ItemHex rather than an item
// Note: Due to limitations of NWScript iAgainst defaults to 0xFFFFFFFF. But in truth it defaults to: ITEM_TYPE_ALL.
int SHA_TestItemHexAgainstType(int iTypeToTest, int iAgainst=0xFFFFFFFF, int bBoolean=FALSE);

effect SHA_GetEffectFromID(int EffectID, int Value1, int Value2);

//Pretty obvious what these do... :P

int SHA_GetIsWeaponLarge(object oWeapon);
int SHA_GetIsWeaponTiny(object oWeapon);
int SHA_GetIsSimpleWeapon(object oWeapon);
int SHA_GetIsExoticWeapon(object oWeapon);
int SHA_GetIsMartialWeapon(object oWeapon);
int SHA_GetIsRangedWeapon(object oWeapon);
int SHA_GetIsMeleeWeapon(object oWeapon);

//Capitalizes the first letter, and puts the rest into lower cases.
//if you feed in: sHayaN
//returns: Shayan.
string CapitalizeString(string sString);

//From NWN Lexicon
//http://www.nwnlexicon.com/compiled/function.getitemacvalue.html
int GetArmorType(object oItem);



string ColourString(string sText, string sColour=COLOUR_GREEN)
{
return "<c"+sColour+">" +sText + "</c>";
}


string CapitalizeString(string sString)
{
   return GetStringUpperCase(GetStringLeft(sString, 1)) + GetStringLowerCase(GetStringRight(sString, GetStringLength(sString) - 1));

}

int Max(int Num1, int Num2)
{
   if(Num1 >= Num2)
   { return Num1; }
   return Num2;
}

int SHA_GetIsMeleeWeapon(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_MELEE, TRUE);
}

int SHA_GetIsRangedWeapon(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_RANGED, TRUE);
}

int SHA_GetIsMartialWeapon(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_PROF_MARTIAL, TRUE);
}

int SHA_GetIsExoticWeapon(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_PROF_EXOTIC, TRUE);
}

int SHA_GetIsSimpleWeapon(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_PROF_SIMPLE, TRUE);
}

int SHA_GetIsWeaponTiny(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_SIZE_TINY, TRUE);
}

int SHA_GetIsWeaponLarge(object oWeapon)
{
return SHA_TestItemAgainstType(oWeapon, ITEM_TYPE_WEAPON_SIZE_LARGE, TRUE);
}

int GetArmorType(object oItem)
{
    // Make sure the item is valid and is an armor.
    if (GetBaseItemType(oItem) != BASE_ITEM_ARMOR)
        return -1;

    // Get the identified flag for safe keeping.
    int bIdentified = GetIdentified(oItem);
    SetIdentified(oItem,FALSE);

    int nType = -1;
    switch (GetGoldPieceValue(oItem))
    {
        case    1: nType = 0; break; // None
        case    5: nType = 1; break; // Padded
        case   10: nType = 2; break; // Leather
        case   15: nType = 3; break; // Studded Leather / Hide
        case  100: nType = 4; break; // Chain Shirt / Scale Mail
        case  150: nType = 5; break; // Chainmail / Breastplate
        case  200: nType = 6; break; // Splint Mail / Banded Mail
        case  600: nType = 7; break; // Half-Plate
        case 1500: nType = 8; break; // Full Plate
    }
    // Restore the identified flag, and return armor type.
    SetIdentified(oItem,bIdentified);
    return nType;
}

int GetArmorTypeHex(object oItem)
{
int iAC = GetArmorType(oItem);
int iReturn = ITEM_TYPE_INVALID;
switch(iAC)
    {
    case 0:
        iReturn = ITEM_TYPE_ARMOR_TYPE_CLOTH; break;
    case 1:
        iReturn = ITEM_TYPE_ARMOR_AC_1; break;
    case 2:
        iReturn = ITEM_TYPE_ARMOR_AC_2; break;
    case 3:
        iReturn = ITEM_TYPE_ARMOR_AC_3; break;
    case 4:
        iReturn = ITEM_TYPE_ARMOR_AC_4; break;
    case 5:
        iReturn = ITEM_TYPE_ARMOR_AC_5; break;
    case 6:
        iReturn = ITEM_TYPE_ARMOR_AC_6; break;
    case 7:
        iReturn = ITEM_TYPE_ARMOR_AC_7; break;
    case 8:
        iReturn = ITEM_TYPE_ARMOR_AC_8; break;
    }

return iReturn;
}

int GetItemType(object oItem)
{
    int iReturn;
    switch(GetBaseItemType(oItem))
    {
    //DEFINE JEWLERY
        case BASE_ITEM_AMULET:
        case BASE_ITEM_RING:
            iReturn = ITEM_TYPE_JEWLERY; break;


    //DEFINE MELEE WEAPONS

    //      (Tiny - Simple)
        case BASE_ITEM_DAGGER:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;

    //      (Tiny - Exotic)
        case BASE_ITEM_KUKRI:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_WEAPON_PROF_EXOTIC; break;

    //      (Small - Simple)
        case BASE_ITEM_LANCE_SSE:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_MOONONASTICK_SSE:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_TRUMPET_SSE:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;

    //      (Small - Martial)
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_HANDAXE:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Small - Exotic)
        case BASE_ITEM_KAMA:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_EXOTIC; break;

    //      (Medium - Simple)
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_CLUB:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;

    //      (Medium - Martial)
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_WARHAMMER:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Medium - Exotic)
        case BASE_ITEM_DWARVENWARAXE:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_WHIP:

        case BASE_ITEM_BASTARDSWORD:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_WEAPON_PROF_EXOTIC; break;

    //      (Large - Simple)
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SHORTSPEAR:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;

    //      (Large - Martial)
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_TRIDENT:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Large - Exotic)
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_TWOBLADEDSWORD:
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_WEAPON_PROF_EXOTIC; break;


    //DEFINE RANGED AND THROWING WEAPONS
    //      (Tiny - Simple)
    //      NONE


    //      (Tiny - Exotic)
        case BASE_ITEM_SHURIKEN:
            iReturn = ITEM_TYPE_WEAPON_RANGED_THROW | ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_WEAPON_PROF_EXOTIC; break;

    //      (Small - Simple - Throw)
        case BASE_ITEM_DART:
            iReturn = ITEM_TYPE_WEAPON_RANGED_THROW | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;
    //      (Small - Simple - Launcher)
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_SLING:
            iReturn = ITEM_TYPE_WEAPON_RANGED_LAUNCHER | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_SIMPLE; break;

    //      (Small - Martial)
        case BASE_ITEM_THROWINGAXE:
            iReturn = ITEM_TYPE_WEAPON_RANGED_THROW | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Medium - Martial)
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_HEAVYCROSSBOW:
            iReturn = ITEM_TYPE_WEAPON_RANGED_LAUNCHER | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Large - Simple)
    //      NONE


    //      (Large - Martial)
        case BASE_ITEM_LONGBOW:
            iReturn = ITEM_TYPE_WEAPON_RANGED_LAUNCHER | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_WEAPON_PROF_MARTIAL; break;

    //      (Large - Exotic)
    //      NONE


    /* End of Standard Weapons */





    //DEFINE ARMOR (Responds to both Armors (incl shield and helm) in general and to Armor)
        case BASE_ITEM_ARMOR:
            iReturn = GetArmorTypeHex(oItem) ; break;

    //DEFINE HELM (Responds to both Armors (incl shield and helm) in general and to Helmet)
        case BASE_ITEM_HELMET:
             iReturn = ITEM_TYPE_HELM; break;

    //DEFINE SHIELD (Responds to both Armors (incl shield and helm) in general and to Shields)
        case BASE_ITEM_LARGESHIELD:
            iReturn = ITEM_TYPE_SHIELD_LARGE; break;
        case BASE_ITEM_SMALLSHIELD:
            iReturn = ITEM_TYPE_SHIELD_SMALL; break;
        case BASE_ITEM_TOWERSHIELD:
            iReturn = ITEM_TYPE_SHIELD_TOWER; break;

    //DEFINE "MISC CLOTHING" (None armor, none Jewlery, etc.)
        case BASE_ITEM_BELT:
        case BASE_ITEM_BOOTS:
        case BASE_ITEM_BRACER:
        case BASE_ITEM_CLOAK:
            iReturn = ITEM_TYPE_MISC_CLOTHING; break;

    //DEFINE AMMO - commented out ... Are they really worth it?
/*        case BASE_ITEM_ARROW:
        case BASE_ITEM_BOLT:
        case BASE_ITEM_BULLET:
            iReturn = ITEM_TYPE_WEAPON_RANGED_LAUNCHER; break;*/



    //TEMP/MISC ITEM LIST - SPECIAL CASES:

        case BASE_ITEM_GRENADE: //Is a "Thrown" Weapon, yet does not have any Prof related to it.
            iReturn = ITEM_TYPE_WEAPON_RANGED_THROW; break;
        case BASE_ITEM_GLOVES: //Is a Misc Clothing but also a Melee weapon ( for monks) No size or Prof. (Use Any Weapon Prof / Size to avoid it being filtered away by Size/Prof sorting)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_MISC_CLOTHING | ITEM_TYPE_WEAPON_PROF_ANY | ITEM_TYPE_WEAPON_SIZE_ANY; break;


        //CEP WEAPONS from the CEP2da v1.52

        //Unknown Size/Prof.
        case 303: //Sai - I failed to recall this one.
        case 314: //Fashionacc - (Fashion items deal 1d2 damage o.O flagged it as a weapon may be "overrated" but correct )
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Tiny - Simple - CEP)
        case 309: //Dagger (Assasin)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_SIMPLE | ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Tiny - Exotic - CEP)
        case 310: //Katar
        case 313: //Kukri (2)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_EXOTIC | ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Small - Simple - CEP)
        case 312: //Lightmace (2)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_SIMPLE | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Small - Martial - CEP)
        case 302: //lightpick
        case 308: //Sap
        case 322: //Goad
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_MARTIAL | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Small - Exotic - CEP)
        case 304: //Nunchaku
        case 323: //Wind Fire Wheel
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_EXOTIC | ITEM_TYPE_WEAPON_SIZE_SMALL | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Medium - Simple - CEP)
        case 317: //Heavymace
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_SIMPLE | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Medium - Martial - CEP)
        case 300: //Trident
        case 301: //Heavypick
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_MARTIAL | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Medium - Exotic - CEP)
        case 319: //Mercuryls (Mercurial Longsword)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_EXOTIC | ITEM_TYPE_WEAPON_SIZE_MEDIUM | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Large - Martial - CEP)
        case 305: //Falchion
        case 316: //Falchion
        case 318: //Maul
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_MARTIAL | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //      (Large - Exotic - CEP)
        case 320: //Mercurygs (Mercurial Greatsword)
        case 321: //Double Scimitar
        case 324: //Maug Double Sword  (assumed but not actually checked to large and Exotic)
            iReturn = ITEM_TYPE_WEAPON_MELEE | ITEM_TYPE_WEAPON_PROF_EXOTIC | ITEM_TYPE_WEAPON_SIZE_LARGE | ITEM_TYPE_NONE_BIOWARE_ITEM; break;

    //None of the above. ITEM_TYPE_INVALID is the same as FALSE
        default:
        //In case of a None registred (non-bioware) but valid Item
        if((ITEM_TYPE_INVALID == iReturn) && (GetObjectType(oItem) == OBJECT_TYPE_ITEM) )
            {
            iReturn = ITEM_TYPE_NONE_BIOWARE_ITEM;
            }
          else
            {
            iReturn = ITEM_TYPE_INVALID;
            }
          break;

      } /*END OF SWITCH*/


    return iReturn;
}

int SHA_TestItemAgainstType(object oItem, int iType=0xFFFFFFFF, int bBoolean=FALSE)
{
   return SHA_TestItemHexAgainstType(GetItemType(oItem), iType, bBoolean);
}

int SHA_TestItemHexAgainstType(int iTypeToTest, int iAgainst=0xFFFFFFFF, int bBoolean=FALSE)
{
    if(bBoolean) return (iTypeToTest & iAgainst)?1:0;

    return (iTypeToTest & iAgainst);
}

//Returns FALSE if iItemHex fulfills iReq.
//returns TRUE on Error or if iItemHex does NOT fulfill iReq.
int SHA_TestItemReq(int iItemHex, int iReq);
int SHA_TestItemReq(int iItemHex, int iReq)
{
    int iReturn = ITEM_TYPE_INVALID;
    if( iItemHex & ITEM_TYPE_WEAPON ) //Only Weapons have sizes and Prof to test against
    {
    //Find the Appropiate Sorting Pattern.
        if(iReq & ITEM_TYPE_REQ_ALL)
        {
          iReturn = SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON,TRUE) ||
                SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON_SIZE_ANY,TRUE) ||
                SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON_PROF_ANY ,TRUE);
        }
        else
        {
          iReturn = SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON,TRUE) &&
                SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON_SIZE_ANY,TRUE) &&
                SHA_TestItemHexAgainstType(iItemHex, iReq & ITEM_TYPE_WEAPON_PROF_ANY ,TRUE);
        }
    }
    else
    {
       iReturn = SHA_TestItemHexAgainstType(iItemHex, iReq, TRUE);
    }


    return iReturn;
}


effect SHA_GetEffectFromID(int EffectID, int Value1, int Value2)
{
   effect iEffect;
   switch(EffectID)
   {
      case EFFECT_TYPE_ARCANE_SPELL_FAILURE: iEffect = EffectSpellFailure(Value1, Value2); break;
      case EFFECT_TYPE_BLINDNESS: iEffect = EffectBlindness(); break;
      case EFFECT_TYPE_CHARMED: iEffect = EffectCharmed();break;
      case EFFECT_TYPE_CONCEALMENT: iEffect = EffectConcealment(Value1, Value2); break;
      case EFFECT_TYPE_CONFUSED: iEffect = EffectConfused(); break;
      case EFFECT_TYPE_CUTSCENEGHOST: iEffect = EffectCutsceneGhost(); break;
      case EFFECT_TYPE_HASTE: iEffect = EffectHaste(); break;
      case EFFECT_TYPE_IMMUNITY: iEffect = EffectImmunity(Value1); break;
      case EFFECT_TYPE_IMPROVEDINVISIBILITY: iEffect = EffectInvisibility(INVISIBILITY_TYPE_IMPROVED); break;
      case EFFECT_TYPE_INVISIBILITY: iEffect = EffectInvisibility(INVISIBILITY_TYPE_NORMAL); break;
      case EFFECT_TYPE_MISS_CHANCE: iEffect = EffectMissChance(Value1, Value2); break;
      case EFFECT_TYPE_MOVEMENT_SPEED_DECREASE: iEffect = EffectMovementSpeedDecrease(Value1); break;
      case EFFECT_TYPE_MOVEMENT_SPEED_INCREASE: iEffect = EffectMovementSpeedIncrease(Value2); break;
      case EFFECT_TYPE_POLYMORPH: iEffect = EffectPolymorph(Value1, Value2);   break;
      case EFFECT_TYPE_REGENERATE: iEffect = EffectRegenerate(Value1, IntToFloat(Value2)); break;
      case EFFECT_TYPE_SANCTUARY: iEffect = EffectSanctuary(Value1); break;
      case EFFECT_TYPE_SLOW: iEffect = EffectSlow();break;
      case EFFECT_TYPE_TEMPORARY_HITPOINTS: iEffect = EffectTemporaryHitpoints(Value1); break;
      case EFFECT_TYPE_TRUESEEING: iEffect = EffectTrueSeeing(); break;
      case EFFECT_TYPE_ULTRAVISION: EffectUltravision(); break;
      case EFFECT_TYPE_VISUALEFFECT: iEffect = EffectVisualEffect(Value1, Value2); break;
      case EFFECT_TYPE_DAMAGE_IMMUNITY_INCREASE: iEffect = EffectDamageImmunityIncrease(Value1, Value2); break;
      case EFFECT_TYPE_DAMAGE_IMMUNITY_DECREASE: iEffect = EffectDamageImmunityDecrease(Value1, Value2); break;
      default: iEffect; break;
  }
  return iEffect;
}


//Copied from the Bioware forums somewhere...
int GetPlayerLevel(object oPC)
{
   int XP = GetXP(oPC);
   return FloatToInt(0.02 * (sqrt(5.0f) * sqrt(XP + 125.0f) + 25.0f));
}


string GetSubraceStatStorageName(int Stat, int BaseStat=FALSE)
{
string Return="";
if(BaseStat)
    {
    switch(Stat)
        {
        case ABILITY_STRENGTH:
            Return = SUBRACE_BASE_STAT_STR_MODIFIER;
            break;
        case ABILITY_DEXTERITY:
            Return = SUBRACE_BASE_STAT_DEX_MODIFIER;
            break;
        case ABILITY_CONSTITUTION:
            Return = SUBRACE_BASE_STAT_CON_MODIFIER;
            break;
        case ABILITY_INTELLIGENCE:
            Return = SUBRACE_BASE_STAT_INT_MODIFIER;
            break;
        case ABILITY_WISDOM:
            Return = SUBRACE_BASE_STAT_WIS_MODIFIER;
            break;
        case ABILITY_CHARISMA:
            Return = SUBRACE_BASE_STAT_CHA_MODIFIER;
            break;
        }
    }
  else
    {
    switch(Stat)
        {
        case ABILITY_STRENGTH:
            Return = SUBRACE_STAT_STR_MODIFIER;
            break;
        case ABILITY_DEXTERITY:
            Return = SUBRACE_STAT_DEX_MODIFIER;
            break;
        case ABILITY_CONSTITUTION:
            Return = SUBRACE_STAT_CON_MODIFIER;
            break;
        case ABILITY_INTELLIGENCE:
            Return = SUBRACE_STAT_INT_MODIFIER;
            break;
        case ABILITY_WISDOM:
            Return = SUBRACE_STAT_WIS_MODIFIER;
            break;
        case ABILITY_CHARISMA:
            Return = SUBRACE_STAT_CHA_MODIFIER;
            break;
        }
    }
return Return;
}



// Flag Sets v1.1 by Axe  (Taken from NWVault) -Brilliant stuff!


//::////////////////////////
// Function Definitions
//:://///////////////////////


//:://///////////////////////
// int SetFlag( int iSet, int iFlag, int bOn = TRUE)
//    Turns a flag or set of flags on or off in a flagset variable.
//:://///////////////////////
// Parameters: int iSet  - the flagset variable.
//             int iFlag - the flags to set or clear.
//             int bOn   - turn flags on if TRUE, off if FALSE
//
// Returns: The value of the iSet flagset with the flag(s) specified in iFlag turned on or off
//          based on the value of bOn.
//:://///////////////////////
int SetFlag( int iSet, int iFlag, int bOn = TRUE);
int SetFlag( int iSet, int iFlag, int bOn = TRUE)
{ return (bOn ? (iSet | iFlag) : (iSet & ~iFlag)); }


//:://///////////////////////
// int ClearFlag( int iSet, int iFlag)
//    Clears a flag or set of flags in a flagset variable.
//:://///////////////////////
// Parameters: int iSet  - the flagset variable.
//             int iFlag - the flags to turn off.
//
// Returns: The value of the iSet flagset with the flag(s) specified in iFlag turned off.
//:://///////////////////////
int ClearFlag( int iSet, int iFlag);
int ClearFlag( int iSet, int iFlag)
{ return SetFlag( iSet, iFlag, FALSE); }


//:://///////////////////////
// int GetFlag( int iSet, int iFlag)
//    Returns the values of the flag(s) specified from the given flagset.
//:://///////////////////////
// Parameters: int iSet  - the flagset variable.
//             int iFlag - the flags to turn off.
//
// Returns: The value of the flag(s) requested in the iFlag parameter from the iSet flagset.
//:://///////////////////////
int GetFlag( int iSet, int iFlag);
int GetFlag( int iSet, int iFlag)
{ return (iSet & iFlag); }


//:://///////////////////////
// int GetIsFlagSet( int iSet, int iFlag, int bAny = TRUE)
//    Returns TRUE or FALSE if the flags specified in iFlag are turned on. The bAny parameter
//    is used to request an ANY or ALL test.
//:://///////////////////////
// Parameters: int iSet  - the flagset variable.
//             int iFlag - the flags to test.
//             int bAny  - TRUE means test for any of the flags being set.
//                         FALSE means test for all of the flags being set.
//
// Returns: TRUE if any or all of the flags specified in iFlag are turned on in the flagset variable.
//:://///////////////////////
int GetIsFlagSet( int iSet, int iFlag, int bAny = TRUE);
int GetIsFlagSet( int iSet, int iFlag, int bAny = TRUE)
{ if( iFlag == 0x00000000) return FALSE;
  return (bAny ? ((iSet & iFlag) != 0x00000000) : ((iSet & iFlag) == iFlag));
}


//:://///////////////////////
// int GetIsFlagClear( int iSet, int iFlag, int bAll = TRUE)
//    Returns TRUE or FALSE if the flags specified in iFlag are turned off. The bAll parameter
//    is used to request an ANY or ALL test.
//:://///////////////////////
// Parameters: int iSet  - the flagset variable.
//             int iFlag - the flags to test.
//             int bAll  - TRUE means test for all of the flags being clear.
//                         FALSE means test for any of the flags being clear.
//
// Returns: TRUE if any or all of the flags specified in iFlag are turned off in the flagset variable.
//:://///////////////////////
int GetIsFlagClear( int iSet, int iFlag, int bAll = TRUE);
int GetIsFlagClear( int iSet, int iFlag, int bAll = TRUE)
{ if( iFlag == 0x00000000) return FALSE;
  return !GetIsFlagSet( iSet, iFlag, !bAll);
}



//:://///////////////////////
// string FlagToString( int iSet)
//    Returns the specified flagset as a string of 1's and 0's in the form:
//    "XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX" where FLAG1 is on the far right and FLAG32 the far left.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//
// Returns: The converted flagset in the form "XXXX XXXX XXXX XXXX XXXX XXXX XXXX"
//:://///////////////////////
string FlagToString( int iSet);
string FlagToString( int iSet)
{ string sSet = "";
  int    iBit = -1;
  while( ++iBit < 32)
  { sSet += (((iSet & (0x80000000 >> iBit)) == 0x00000000) ? "0" : "1");
    if( (iBit % 4) == 3) sSet += ((iBit == 31) ? "" : " ");
  }
  return sSet;
}



//:://///////////////////////
// void SetLocalFlag( object oObject, string sVariable, int iFlag, int bOn = TRUE)
//    Sets a local flag variable on an object.
//:://///////////////////////
// Parameters: object oObject   - the object to have the local flagset attached.
//             string sVariable - the flagset name to set the flag in.
//             int    iFlag     - the flag(s) to set or clear.
//             int    bOn       - turn flags on if TRUE, off if FALSE
//
// Returns: None.
//:://///////////////////////
void SetLocalFlag( object oObject, string sVariable, int iFlag, int bOn = TRUE);
void SetLocalFlag( object oObject, string sVariable, int iFlag, int bOn = TRUE)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return;
  int iSet = GetLocalInt( oObject, sVariable);
  SetLocalInt( oObject, sVariable, SetFlag( iSet, iFlag, bOn));
}


//:://///////////////////////
// void ClearLocalFlag( object oObject, string sVariable, int iFlag)
//    Clears a local flag variable on an object.
//:://///////////////////////
// Parameters: object oObject   - the object to have the local flagset attached.
//             string sVariable - the flagset name to set the flag in.
//             int    iFlag     - the flag(s) to clear.
//
// Returns: None.
//:://///////////////////////
void ClearLocalFlag( object oObject, string sVariable, int iFlag);
void ClearLocalFlag( object oObject, string sVariable, int iFlag)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return;
  int iSet = GetLocalInt( oObject, sVariable);
  SetLocalInt( oObject, sVariable, ClearFlag( iSet, iFlag));
}


//:://///////////////////////
// int GetLocalFlag( object oObject, string sVariable, int iFlag = ALLFLAGS)
//    Returns the value of a local flag(s) from an object.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to retrieve the flag(s) from.
//             int    iFlag     - the flag(s) to be retrieved.
//
// Returns: The requested flag(s) is/are returned as a flagset.
//:://///////////////////////
int GetLocalFlag( object oObject, string sVariable, int iFlag = 0xFFFFFFFF);
int GetLocalFlag( object oObject, string sVariable, int iFlag = 0xFFFFFFFF)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return 0;
  int iSet = GetLocalInt( oObject, sVariable);
  return GetFlag( iSet, iFlag);
}


//:://///////////////////////
// int GetIsLocalFlagSet( object oObject, string sVariable, int iFlag = ALLFLAGS)
//    Returns TRUE if the flag(s) in the flagset named by sVariable on oObject are set.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to retrieve the flag(s) from.
//             int    iFlag     - the flag(s) to be retrieved.
//
// Returns: TRUE if all specified flags are set, FALSE otherwise.
//:://///////////////////////
int GetIsLocalFlagSet( object oObject, string sVariable, int iFlag = 0xFFFFFFFF);
int GetIsLocalFlagSet( object oObject, string sVariable, int iFlag = 0xFFFFFFFF)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return 0;
  int iSet = GetLocalInt( oObject, sVariable);
  return GetIsFlagSet( iSet, iFlag);
}


//:://///////////////////////
// int GetIsLocalFlagClear( object oObject, string sVariable, int iFlag = ALLFLAGS)
//    Returns TRUE if the flag(s) in the flagset named by sVariable on oObject is not set.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to retrieve the flag(s) from.
//             int    iFlag     - the flag(s) to be retrieved.
//
// Returns: TRUE if all specified flags are cleared, FALSE otherwise.
//:://///////////////////////
int GetIsLocalFlagClear( object oObject, string sVariable, int iFlag = 0xFFFFFFFF);
int GetIsLocalFlagClear( object oObject, string sVariable, int iFlag = 0xFFFFFFFF)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return 0;
  int iSet = GetLocalInt( oObject, sVariable);
  return GetIsFlagClear( iSet, iFlag);
}


//:://///////////////////////
// void DeleteLocalFlag( object oObject, string sVariable, int iFlag)
//    Removes the specified flag(s) from the given local flagset variable.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to delete the flag(s) from.
//             int    iFlag     - the flag(s) to be deleted.
//
// Returns: None.
//:://///////////////////////
void DeleteLocalFlag( object oObject, string sVariable, int iFlag = 0xFFFFFFFF);
void DeleteLocalFlag( object oObject, string sVariable, int iFlag = 0xFFFFFFFF)
{ if( !GetIsObjectValid( oObject) || (sVariable == "")) return;
  if( iFlag == 0xFFFFFFFF) DeleteLocalInt( oObject, sVariable);
  else SetLocalFlag( oObject, sVariable, iFlag, FALSE);
}




//:://///////////////////////
// int SetGroupFlag( int iSet, int iFlag, int iGroup, int bOn = TRUE)
//    Turns a flag or set of flags on or off in a flag group of a flagset variable.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iFlag  - the flags to set or clear.
//             int iGroup - the flag group to apply the changes to.
//             int bOn    - turn flags on if TRUE, off if FALSE
//
// Returns: The value of the iSet flagset with the flag(s) specified in iFlag turned on or off
//          based on the value of bOn in the flag group specified by iGroup.
//:://///////////////////////
int SetGroupFlag( int iSet, int iFlag, int iGroup, int bOn = TRUE);
int SetGroupFlag( int iSet, int iFlag, int iGroup, int bOn = TRUE)
{ if( (iFlag == NOFLAGS) || (iGroup == NOGROUPS)) return iSet;

  int iShift = 0;
  int iLimit = iGroup;
  while( (iLimit != 0x00000000) && GetIsFlagClear( iLimit, 0x00000001))
  { ++iShift;   iLimit >>= 1;   if( iLimit < 0) iLimit &= 0x7FFFFFFF; }
  return ((iLimit == NOFLAGS) ? iSet : SetFlag( iSet, ((iFlag & iLimit) << iShift), bOn));
}


//:://///////////////////////
// int SetGroupFlagValue( int iSet, int iValue, int iGroup)
//    Sets the group value for a group flag.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iValue - the value to set.
//             int iGroup - the flag group to apply the changes to.
//
// Returns: The iSet flagset with the value specified in iValue set as the group value for the
//          group specified by iGroup.
//:://///////////////////////
int SetGroupFlagValue( int iSet, int iValue, int iGroup);
int SetGroupFlagValue( int iSet, int iValue, int iGroup)
{ if( iGroup == 0x00000000) return iSet;
  return SetGroupFlag( SetGroupFlag( iSet, iValue, iGroup), ~iValue, iGroup, FALSE);
}


//:://///////////////////////
// int ClearGroupFlag( int iSet, int iFlag, int iGroup)
//    Turns a flag or set of flags off in a flag group of a flagset variable.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iFlag  - the flags to clear.
//             int iGroup - the flag group to apply the changes to.
//             int bOn    - turn flags on if TRUE, off if FALSE
//
// Returns: The value of the iSet flagset with the flag(s) specified in iFlag turned off in the
//          flag group specified by iGroup.
//:://///////////////////////
int ClearGroupFlag( int iSet, int iFlag, int iGroup);
int ClearGroupFlag( int iSet, int iFlag, int iGroup)
{ return SetGroupFlag( iSet, iFlag, iGroup, FALSE); }


//:://///////////////////////
// int GetGroupFlag( int iSet, int iFlag, int iGroup)
//    Returns the values of the flag(s) specified from the specified flag group of the given flagset.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iFlag  - the flags to return.
//             int iGroup - the flag group to get the flags from.
//
// Returns: The value of the flag(s) requested by the iFlag parameter from the flag group
//          specified in the iGroup parameter from the iSet flagset.
//:://///////////////////////
int GetGroupFlag( int iSet, int iFlag, int iGroup);
int GetGroupFlag( int iSet, int iFlag, int iGroup)
{ if( (iFlag == 0x00000000) || (iGroup == 0x00000000)) return 0x00000000;

  int iShift = 0;
  int iLimit = iGroup;
  while( (iLimit != 0x00000000) && GetIsFlagClear( iLimit, 0x00000001))
  { ++iShift;   iLimit >>= 1;   if( iLimit < 0) iLimit &= 0x7FFFFFFF; }
  int iGroupFlag = GetFlag( iSet, ((iFlag & iLimit) << iShift));
  if( (iGroupFlag < 0) && (iShift > 0))
  { iGroupFlag >>= 1;   iGroupFlag &= 0x7FFFFFFF;   --iShift; }
  return ((iLimit == 0x00000000) ? 0x00000000 : (iGroupFlag >> iShift));
}


//:://///////////////////////
// int GetGroupFlagValue( int iSet, int iGroup)
//    Returns the group value of the specified group in the iSet flagset.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iGroup - the flag group to get the value of.
//
// Returns: The group value of the group specified by iGroup from the iSet flagset.
//:://///////////////////////
int GetGroupFlagValue( int iSet, int iGroup);
int GetGroupFlagValue( int iSet, int iGroup)
{ if( iGroup == 0x00000000) return 0x00000000;
  return GetGroupFlag( iSet, 0xFFFFFFFF, iGroup);
}


//:://///////////////////////
// int GetIsGroupFlagSet( int iSet, int iFlag, int iGroup, int bAny = TRUE)
//    Returns TRUE or FALSE if the flags specified in iFlag are turned on in the flag group
//    specified by iGroup. The bAny parameter is used to request an ANY or ALL test.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iFlag  - the flags to test.
//             int iGroup - the flag group to get the flags from.
//             int bAny   - TRUE means test for any of the flags being set.
//                          FALSE means test for all of the flags being set.
//
// Returns: TRUE if any or all of the flags specified in iFlag are turned on in the specified
//          flag group of the given flagset variable.
//:://///////////////////////
int GetIsGroupFlagSet( int iSet, int iFlag, int iGroup, int bAny = TRUE);
int GetIsGroupFlagSet( int iSet, int iFlag, int iGroup, int bAny = TRUE)
{ if( (iFlag == 0x00000000) || (iGroup == 0x00000000)) return FALSE;

  int iShift = 0;
  int iLimit = iGroup;
  while( (iLimit != 0x00000000) && GetIsFlagClear( iLimit, 0x00000001))
  { ++iShift;   iLimit >>= 1;   if( iLimit < 0) iLimit &= 0x7FFFFFFF; }
  return ((iLimit == 0x00000000) ? FALSE : GetIsFlagSet( iSet, ((iFlag & iLimit) << iShift), bAny));
}


//:://///////////////////////
// int GetIsGroupFlagClear( int iSet, int iFlag, int iGroup, int bAll = TRUE)
//    Returns TRUE or FALSE if the flags specified in iFlag are turned off in the flag group
//    specified by iGroup. The bAll parameter is used to request an ANY or ALL test.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iFlag  - the flags to test.
//             int iGroup - the flag group to get the flags from.
//             int bAll   - TRUE means test for all of the flags being cleared.
//                          FALSE means test for any of the flags being cleared.
//
// Returns: TRUE if any or all of the flags specified in iFlag are turned off in the specified
//          flag group of the given flagset variable.
//:://///////////////////////
int GetIsGroupFlagClear( int iSet, int iFlag, int iGroup, int bAll = TRUE);
int GetIsGroupFlagClear( int iSet, int iFlag, int iGroup, int bAll = TRUE)
{ if( (iFlag == 0x00000000) || (iGroup == 0x00000000)) return FALSE;
  return !GetIsGroupFlagSet( iSet, iFlag, iGroup, !bAll);
}



//:://///////////////////////
// string GroupFlagToString( int iSet, int iGroup)
//    Returns the specified flag group from the given flagset as a string of 1's and 0's in the form:
//    "XXXX XXXX XXXX XXXX XXXX XXXX XXXX XXXX" where FLAG1 is on the far right and FLAG32 the far left.
//:://///////////////////////
// Parameters: int iSet   - the flagset variable.
//             int iGroup - the flag group to get the flags from.
//
// Returns: The converted flag group from the flagset in the form "XXXX XXXX XXXX XXXX XXXX XXXX XXXX"
//:://///////////////////////
string GroupFlagToString( int iSet, int iGroup);
string GroupFlagToString( int iSet, int iGroup)
{ if( iGroup == 0x00000000) return "0000 0000 0000 0000 0000 0000 0000 0000";
  iSet &= iGroup;
  while( (iGroup & 0x00000001) != 0x00000001)
  { iSet >>= 1;   iGroup >>= 1; }
  return FlagToString( iSet);
}

//:://///////////////////////
// void SetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup, int bOn = TRUE)
//    Sets a local group flag variable on an object.
//:://///////////////////////
// Parameters: object oObject   - the object to have the local flagset attached.
//             string sVariable - the flagset name to set the flag in.
//             int    iFlag     - the flag(s) to set or clear.
//             int    iGroup    - the group to set or clear the flags in.
//             int    bOn       - turn flags on if TRUE, off if FALSE
//
// Returns: None.
//:://///////////////////////
void SetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup, int bOn = TRUE);
void SetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup, int bOn = TRUE)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return;
  int iSet = GetLocalInt( oObject, sVariable);
  SetLocalInt( oObject, sVariable, SetGroupFlag( iSet, iFlag, iGroup, bOn));
}


//:://///////////////////////
// void ClearLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
//    Clears a local group flag variable on an object.
//:://///////////////////////
// Parameters: object oObject   - the object to have the local flagset attached.
//             string sVariable - the flagset name to set the flag in.
//             int    iFlag     - the flag(s) to clear.
//             int    iGroup    - the group to set or clear the flags in.
//
// Returns: None.
//:://///////////////////////
void ClearLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup);
void ClearLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return;
  int iSet = GetLocalInt( oObject, sVariable);
  SetLocalInt( oObject, sVariable, ClearGroupFlag( iSet, iFlag, iGroup));
}


//:://///////////////////////
// void SetLocalGroupFlagValue( object oObject, string sVariable, int iFlag, int iGroup)
//    Sets a local group flag variable on an object as a value.
//:://///////////////////////
// Parameters: object oObject   - the object to have the local flagset attached.
//             string sVariable - the flagset name to set the flag in.
//             int    iValue    - the value to set.
//             int    iGroup    - the group to set the value in.
//
// Returns: None.
//:://///////////////////////
void SetLocalGroupFlagValue( object oObject, string sVariable, int iValue, int iGroup);
void SetLocalGroupFlagValue( object oObject, string sVariable, int iValue, int iGroup)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return;
  int iSet = GetLocalInt( oObject, sVariable);
  SetLocalInt( oObject, sVariable, SetGroupFlagValue( iSet, iValue, iGroup));
}


//:://///////////////////////
// int GetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
//    Returns the value(s) of a local group flag(s) from an object.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to retrieve the flag(s) from.
//             int    iFlag     - the flag(s) to be retrieved.
//             int    iGroup    - the group to get the flags from.
//
// Returns: The requested group flag(s) is/are returned as a flagset group.
//:://///////////////////////
int GetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup);
int GetLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return 0;
  int iSet = GetLocalInt( oObject, sVariable);
  return GetGroupFlag( iSet, iFlag, iGroup);
}


//:://///////////////////////
// int GetLocalGroupFlagValue( object oObject, string sVariable, int iGroup)
//    Returns the value of a local group flag number from an object.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to retrieve the value from.
//             int    iGroup    - the group to get the value from.
//
// Returns: The requested group's value is returned as a number.
//:://///////////////////////
int GetLocalGroupFlagValue( object oObject, string sVariable, int iGroup);
int GetLocalGroupFlagValue( object oObject, string sVariable, int iGroup)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return 0;
  int iSet = GetLocalInt( oObject, sVariable);
  return GetGroupFlagValue( iSet, iGroup);
}


//:://///////////////////////
// void DeleteLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
//    Removes the specified flag(s) from the specified group of the given local flagset variable.
//:://///////////////////////
// Parameters: object oObject   - the object that has the local flagset attached.
//             string sVariable - the flagset name to delete the flag(s) from.
//             int    iFlag     - the flag(s) to be deleted.
//             int    iGroup    - the group to delete the flags from.
//
// Returns: None.
//:://///////////////////////
void DeleteLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup);
void DeleteLocalGroupFlag( object oObject, string sVariable, int iFlag, int iGroup)
{ if( !GetIsObjectValid( oObject) || (sVariable == "") || (iGroup == 0x00000000)) return;
  if( (iFlag == 0xFFFFFFFF) && (iGroup == 0xFFFFFFFF)) DeleteLocalInt( oObject, sVariable);
  else ClearLocalGroupFlag( oObject, sVariable, iFlag, iGroup);
}

//:://///////////////////////
// int HexToInt( string sHex)
//    Converts a hexidecimal number represented in a string to an integer.
//:://///////////////////////
// Parameters: string sHex - the hex number to convert. The string cannot be longer than 8
//                           characters unless the first two letters are '0x' (or '0X', in that
//                           case the string can be 10 characters long. It can be shorter than
//                           8 letters. Only numbers and letters 'a'-'f' and 'A'-'F' are allowed.
//                           If any of these rules is violated the function considers it an
//                           invalid hex number and returns the value 0.
//
// Returns: Integer value of the converted hex string or 0 if the input string is not a hex number.
//:://///////////////////////
int HexToInt( string sHex);
int HexToInt( string sHex)
{ sHex = GetStringLowerCase( sHex);
  if( GetStringLeft( sHex, 2) == "0x")
    sHex = GetStringRight( sHex, GetStringLength( sHex) -2);
  if( (sHex == "") || (GetStringLength( sHex) > 8)) return 0;

  string sConvert = "0123456789abcdef";
  int iValue = 0;
  int iMult  = 1;
  while( sHex != "")
  { int iDigit = FindSubString( sConvert, GetStringRight( sHex, 1));
    if( iDigit < 0) return 0;
    iValue += iMult *iDigit;
    iMult  *= 16;
    sHex    = GetStringLeft( sHex, GetStringLength( sHex) -1);
  }
  return iValue;
}
//void main() {}
