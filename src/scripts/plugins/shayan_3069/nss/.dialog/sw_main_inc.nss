// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
// :::::::::::::::::::::::::: Extension: SWand :::::::::::::::::::::::::::::::::
// ::::::::::::Contact: http://p2.forumforfree.com/shayan.html::::::::::::::::::
// ::::
// :::: Written by: DM_Moon
// ::
// :: Description: Subrace Conversation used in SSE's SWand system.
// ::
#include "sw_proto_inc"

void swandScriptInit()
{
sw_gl_Permission=GetUserPermissionsForSWand(oMySpeaker, SWAND_PERMISSION_GET_PERMISSION, FALSE);
sw_gl_Status=GetConversationStatus(oMySpeaker);
}

void SetupSpecialSWandUser(string Key, int Permissions=SWAND_PERMISSION_DM)
{
SetSSEInt(SWAND_PREFIX + SWAND_SPECIAL_USERS + Key, Permissions);
}

int GetSpecialSWandUserPermissionsByKey(string Key)
{
return GetSSEInt(SWAND_PREFIX + SWAND_SPECIAL_USERS + Key);
}

int GetSpecialSWandUserPermissions()
{
return GetSpecialSWandUserPermissionsByKey(GetPCPublicCDKey(oMySpeaker));
}

void SetConversationStatus(object Player, int Status)
{
sw_gl_Status=Status;
SetLocalInt(Player, SWAND_PREFIX + SWAND_CONVO_STATUS, Status);
}

int GetConversationStatus(object Player)
{
return GetLocalInt(Player, SWAND_PREFIX + SWAND_CONVO_STATUS);
}

void ResetConversationStatus(object Player)
{
sw_gl_Status=0;
DeleteLocalInt(Player, SWAND_PREFIX + SWAND_CONVO_STATUS);
}

string GetAbilityScoreName(int Ability, int ShortName=FALSE)
{
string s="";
switch(Ability)
    {
    case ABILITY_STRENGTH:
        s = ShortName?"STR":"Strength";
        break;
    case ABILITY_DEXTERITY:
        s = ShortName?"DEX":"Dexterity";
        break;
    case ABILITY_CONSTITUTION:
        s = ShortName?"CON":"Constitution";
        break;
    case ABILITY_INTELLIGENCE:
        s = ShortName?"INT":"Intelligence";
        break;
    case ABILITY_WISDOM:
        s = ShortName?"WIS":"Wisdom";
        break;
    case ABILITY_CHARISMA:
        s = ShortName?"CHA":"Charisma";
        break;
    }

return s;
}

string IntToColourString(int iInt, string sPrefix="", string sSurfix="", int AddSymbol=3, int AdjustZero=0, string sColourNegative=COLOUR_RED, string sColourPositive=COLOUR_GREEN, string sColourZero=COLOUR_WHITE)
{
string sReturn="", sColour="", sValue=IntToString(iInt);
if(iInt<0)
    {
    sValue = GetSubString(sValue, 1, GetStringLength(sValue)-1);
    }
if( iInt > AdjustZero)
    {
    sColour = sColourPositive;
    if(AddSymbol&1) sPrefix += "+";
    }
  else if( iInt < AdjustZero)
    {
    sColour = sColourNegative;
    if( (AddSymbol&2) ) sPrefix += "-";
    }
  else
    {
    sColour = sColourZero;
    }

sReturn = ColourString(sPrefix + sValue + sSurfix, sColour);
return sReturn;
}

int RoundOffToNearestInt(float fNum)
{
    int WholeNum = FloatToInt(fNum);
    if((fNum - WholeNum) > 0.5)
    {
       return ++WholeNum;
    }
    else
    {
      return WholeNum;
    }
}

string GetNameOfLocationOnObject(object oObject)
{
    string sReturn = "LOCATION: ";
    if(GetObjectType(oObject) == OBJECT_TYPE_ITEM)
    {
        sReturn += ColourString(GetName(GetItemPossessor(oObject) ), COLOUR_YELLOW);
    }
    else
    {
        object oArea = GetArea(oObject);
        if(GetIsObjectValid(oArea) )
            sReturn += ColourString(GetName(oArea), COLOUR_YELLOW);
        else
            sReturn = ColourString("IN TRANSIT", COLOUR_YELLOW);
    }
    return sReturn;
}



string GetInfoCurrentTarget(object oTarget)
{
string sReturn;
if(!GetIsObjectValid(oTarget)) return "No Target";

    sReturn = "NAME: " + ColourString(GetName(oTarget));
    if(SWAND_PLAYER_INFO&SWAND_PLAYER_INFO_LOGIN)
        sReturn+= "\nLOGIN: " + ColourString(GetPCPlayerName(oTarget), COLOUR_LRED);
    if(SWAND_PLAYER_INFO&SWAND_PLAYER_INFO_CD_KEY)
        sReturn+= "\nCD-KEY: " + ColourString(GetPCPublicCDKey(oTarget), COLOUR_LPURPLE);
    if(SWAND_PLAYER_INFO&SWAND_PLAYER_INFO_IP)
        sReturn+= "\nIP: " + ColourString(GetPCIPAddress(oTarget), COLOUR_LTEAL);
    if(SWAND_PLAYER_INFO&SWAND_PLAYER_INFO_LOCATION)
        sReturn+="\n"+GetNameOfLocationOnObject(oTarget);

return sReturn;
}




string GenerateColorDisplayMessage(int MessageType=0, string Message="")
{
string sReturn;
/*switch(MessageType)
    {
    case MESSAGE_TYPE_DEBUG:
        sReturn = ColourString("[DEBUG]: ", COLOUR_BLUE) + Message;
        break;
    case MESSAGE_TYPE_ERROR:
        sReturn = ColourString("[ERROR]: ", COLOUR_RED) + Message;
        break;
    case MESSAGE_TYPE_SUCCESS:
        sReturn = ColourString("[SUCCESS]: ", COLOUR_PURPLE) + Message;
        break;
    case MESSAGE_TYPE_WARNING:
        sReturn = ColourString("[WARNING]: ", COLOUR_RED) + Message;
        break;
    case MESSAGE_TYPE_ATTENTION:
        sReturn = ColourString("[ATTENTION]: ") + Message;
        break;
    case MESSAGE_TYPE_GRANTED:
        sReturn = ColourString("[GRANTED]: ", COLOUR_PURPLE) + Message;
        break;
    case MESSAGE_TYPE_DENIED:
        sReturn = ColourString("[DENIED]: ", COLOUR_RED) + Message;
        break;
    case MESSAGE_TYPE_LOG_FILE:
        sReturn = ColourString("[ADDED TO LOG]: ", COLOUR_BLUE) + Message;
        break;
    }*/
return Message;
}

string ClassIntToString(int iClass)
{
string sReturn = "";

switch(iClass)
    {
    case CLASS_TYPE_ARCANE_ARCHER: sReturn = "Arcane Archer"; break;
    case CLASS_TYPE_ASSASSIN: sReturn = "Assasin"; break;
    case CLASS_TYPE_BARBARIAN: sReturn = "Barbarian"; break;
    case CLASS_TYPE_BARD: sReturn = "Bard"; break;
    case CLASS_TYPE_BLACKGUARD: sReturn = "Blackguard"; break;
    case CLASS_TYPE_CLERIC: sReturn = "Cleric"; break;
    case CLASS_TYPE_DIVINE_CHAMPION: sReturn = "Champion of Torm"; break;
    case CLASS_TYPE_DRAGON_DISCIPLE: sReturn = "Red Dragon Disciple"; break;
    case CLASS_TYPE_DRUID: sReturn = "Druid"; break;
    case CLASS_TYPE_DWARVEN_DEFENDER: sReturn = "Dwarven Defender"; break;
    case CLASS_TYPE_FIGHTER: sReturn = "Fighter"; break;
    case CLASS_TYPE_HARPER: sReturn = "Harper Scout"; break;
    case CLASS_TYPE_MONK: sReturn = "Monk"; break;
    case CLASS_TYPE_PALADIN: sReturn = "Paladin"; break;
    case CLASS_TYPE_PALE_MASTER: sReturn = "Pale Master"; break;
    case CLASS_TYPE_RANGER: sReturn = "Ranger"; break;
    case CLASS_TYPE_ROGUE: sReturn = "Rogue"; break;
    case CLASS_TYPE_SHADOWDANCER: sReturn = "Shadow Dancer"; break;
    case CLASS_TYPE_SHIFTER: sReturn = "Shifter"; break;
    case CLASS_TYPE_SORCERER: sReturn = "Sorcerer(ess)"; break;
    case CLASS_TYPE_WEAPON_MASTER: sReturn = "Weapon Master"; break;
    case CLASS_TYPE_WIZARD: sReturn = "Wizard"; break;

    //NPC Classes
    case CLASS_TYPE_ABERRATION: sReturn += "Aberration"; break;
    case CLASS_TYPE_ANIMAL: sReturn += "Animal"; break;
    case CLASS_TYPE_BEAST: sReturn += "Beast"; break;
    case CLASS_TYPE_COMMONER: sReturn += "Commoner"; break;
    case CLASS_TYPE_CONSTRUCT: sReturn += "Construct"; break;
    case CLASS_TYPE_DRAGON: sReturn += "Dragon"; break;
    case CLASS_TYPE_ELEMENTAL: sReturn += "Elemental"; break;
    case CLASS_TYPE_FEY: sReturn += "Fey"; break;
    case CLASS_TYPE_GIANT: sReturn += "Giant"; break;
    case CLASS_TYPE_HUMANOID: sReturn += "Humaniod"; break;
    case CLASS_TYPE_MAGICAL_BEAST: sReturn += "Magical Beast"; break;
    case CLASS_TYPE_MONSTROUS: sReturn += "Monstrous"; break;
    case CLASS_TYPE_OOZE: sReturn += "Ooze"; break;
    case CLASS_TYPE_OUTSIDER: sReturn += "Outsider"; break;
    case CLASS_TYPE_UNDEAD: sReturn += "Undead"; break;
    case CLASS_TYPE_VERMIN: sReturn += "Vermin"; break;

    //Special/Unknown Class
    case CLASS_TYPE_INVALID: break;
    default: sReturn = "Unknown valid Class"; break;
    }

return sReturn;
}

string GetClassAndLevel(int iPos, object o)
{
int ClassType = GetClassByPosition(iPos, o);
if( (iPos < 1) || (4 < iPos) || (!GetIsObjectValid(o)) || (ClassType==CLASS_TYPE_INVALID) ) return "";
string Return = "";

if(iPos > 1) {Return = " / ";}
Return += ClassIntToString(ClassType) + " (" + IntToString(GetLevelByClass(ClassType, o)) + ")";
return Return;
}

int GetUserPermissionsForSWand(object oPC, int Permissions=SWAND_PERMISSION_DM, int IsBetterAllowed=TRUE)
{
string Key = GetPCPublicCDKey(oPC);
int SpecialUser=GetSpecialSWandUserPermissionsByKey(Key);
int Return;
if(!SpecialUser)
    {
    if(GetIsDM(oPC) || GetIsDMPossessed(oPC) ||
             (SWAND_DEBUG && (GetPCPublicCDKey(oPC)!=GetPCPublicCDKey(oPC, TRUE)) ) )
        Return=SWAND_PERMISSION_DM;
    else
        Return=SWAND_PERMISSION_PLAYER;
    }
else
    Return = SpecialUser;

if(Permissions != SWAND_PERMISSION_GET_PERMISSION)
    {
    Return = (Permissions == Return) || (IsBetterAllowed && (Return >= Permissions) );
    }
return Return;
}

void SendServerWideMessage(string sMessage, int MessageReceiver=SWAND_MESSAGE_RECEIVER_PC_AND_DM, int Important=FALSE)
{
//Stop the proccess if we are minimalistic and it is not important.
if(MINIMALISE_SUBRACE_MESSAGES_TO_PC && !Important) return;
sMessage = SUBRACE_ENGINE + sMessage;
int BetterAllowed=FALSE;
if(MessageReceiver == SWAND_MESSAGE_RECEIVER_PC_AND_DM)
    {
    BetterAllowed=TRUE;
    MessageReceiver = SWAND_PERMISSION_PLAYER;
    }

object oPC = GetFirstPC();
while(GetIsObjectValid(oPC))
    {
    //This trick only work because the SWAND_MESSAGE_RECEIVER_* and the SWAND_PERMISSION_* are "compatiable" (identical)
    if(GetUserPermissionsForSWand(oPC, MessageReceiver, BetterAllowed) )
        {
        SendMessageToPC(oPC, sMessage);
        }
    oPC = GetNextPC();
    }
}

void SaveCharacter(int Single=FALSE, object oPlayer=OBJECT_INVALID)
{
switch(Single)
    {
    case FALSE:
        SendServerWideMessage("Your character has been saved.", SWAND_MESSAGE_RECEIVER_PC_ONLY);
        ExportAllCharacters();
        break;
    case 2:
        SHA_SendSubraceMessageToPC(oPlayer, "Character Save complete", FALSE);
    case TRUE:
        ExportSingleCharacter(oPlayer);
        break;
    }
}


string LETO_GetBicPath_Wand(object oPC)
{
    string PlayerName = GetLocalString(oPC, "SUBR_PlayerName");
    string BicFolderPath = "";
    if(!USE_LOCAL_VAULT_CHARACTERS)
    {
         BicFolderPath = NWNPATH+"servervault/" + PlayerName + "/";
    }
    else
    {
         BicFolderPath = NWNPATH+"localvault/";
    }

    return BicFolderPath;
}

void swand_CleanCache()
{
int i=0;
int iCache = GetLocalInt(oMySpeaker, "swand_object_cache")+1;
for(;i < iCache; i++)
    {
     DeleteLocalObject(oMySpeaker, "swand_object_cache" + IntToString(i));
    }

DeleteLocalInt(oMySpeaker, "swand_object_cache");
}


void swand_EndConversation()
{
swandScriptInit();
int nCount;

switch(sw_gl_Status)
    {
    //If aborting, the status will not be updated, thus a status running will be abort.
    case SWAND_CONVO_RUNNING:
    case SWAND_CONVO_ABORT:
        {
        //Handle Conversation Aborted event
        swand_CleanCache();
        DeleteLocalObject(oMySpeaker, SWAND_PREFIX + SWAND_TARGET);
        DeleteSSEInt(SWAND_PREFIX + SWAND_LETO_TEST);
        ResetConversationStatus(oMySpeaker);
        break;
        }
    case SWAND_CONVO_CLOSE:
        {
        //Handle Conversation Closed event
        swand_CleanCache();
        DeleteLocalObject(oMySpeaker, SWAND_PREFIX + SWAND_TARGET);
        DeleteSSEInt(SWAND_PREFIX + SWAND_LETO_TEST);
        ResetConversationStatus(oMySpeaker);
        break;
        }
    case SWAND_CONVO_UPDATE:
        {
        break;
        }
    }
for(nCount = 0; nCount <= 9; nCount++)
    {
    swand_RemoveChoice(nCount);
    }

DeleteLocalInt(oMySpeaker, "subrace_dm_wand_pos");
DeleteSSEInt(SWAND_PREFIX + SWAND_LETO_TEST);
}


void swand_BuildCache()
{

int nCount = 1;
object oObject = GetFirstPC();
while(GetIsObjectValid(oObject))
    {
    if(!GetIsDM(oObject))
        {
         SetLocalObject(oMySpeaker, "swand_object_cache" + IntToString(nCount), oObject);
         nCount++;
        }
    oObject = GetNextPC();

    }
nCount--;
SetLocalInt(oMySpeaker, "swand_object_cache", nCount);

}


int SWandLetoTest(int ForceTest=FALSE)
{
int Leto = GetSSEInt(SWAND_PREFIX + SWAND_LETO_TEST);
if(Leto == SWAND_LETO_UNTESTED || ForceTest)
    {
    if(!ENABLE_LETO)
        {
        if(ForceTest) //Force means "Force". Ignore ENABLE_LETO setting. (though do not store it)
            {
            return LetoPingPong()?SWAND_LETO_DETECTED:SWAND_LETO_NOT_DETECTED;
            }
        return SWAND_LETO_NOT_ENABLED;
        }
    Leto = LetoPingPong()?SWAND_LETO_DETECTED:SWAND_LETO_NOT_DETECTED;
    SetSSEInt(SWAND_PREFIX + SWAND_LETO_TEST, Leto);
    }
return Leto;
}

void Reset()
{
string sModule = GetModuleName();
if(sModule == "")
    {
    SHA_SendSubraceMessageToPC(oMySpeaker, GenerateColorDisplayMessage(0/*MESSAGE_TYPE_ERROR*/, "No Valid Module Name could be retrieved, Module Reset Cancelled"), TRUE);
    return;
    }
SHA_SendSubraceMessageToPC(oMySpeaker, GenerateColorDisplayMessage(0/*MESSAGE_TYPE_SUCCESS*/, "The Module: " +sModule+" will load shortly."), TRUE);
DelayCommand(5.0, SendServerWideMessage(GenerateColorDisplayMessage(0/*MESSAGE_TYPE_ATTENTION*/, "The Server will reset shortly."), SWAND_MESSAGE_RECEIVER_PC_AND_DM, TRUE));
DelayCommand(9.50, SaveCharacter() );
DelayCommand(10.0, StartNewModule(sModule));
}

int ShutdownSSE()
{
   SendServerWideMessage("SSE has been shutdown.", SWAND_MESSAGE_RECEIVER_DM_ONLY, TRUE);
   object oPC = GetFirstPC();
   int ID;
   while(GetIsObjectValid(oPC))
   {
     if(ID = GetPlayerSubraceID(oPC))
     {
         SHA_SendSubraceMessageToPC(oPC, "Subrace Engine has been switched off in the Module! Your "+SUBRACE_WHEN_NOUN +" abilities will not function until it is turned back on.", TRUE);
         DeleteLocalInt(oPC, SUBRACE_INFO_LOADED_ON_PC);
         DeleteLocalInt(oPC, SUBRACE_IN_SPELL_DARKNESS);
         string SubraceStorage = GetSubraceStorageLocationByID(ID);

         int IsLightSens = GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_LIGHT_SENSITIVE, SUBRACE_BASE_INFORMATION_FLAGS);
         int IsUndergSens = GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_UNDERGROUND_SENSITIVE, SUBRACE_BASE_INFORMATION_FLAGS);
         if(IsLightSens)
         {
            DeleteLocalInt(oPC,"SB_LGHT_DMGED");
         }
         if(IsUndergSens)
         {
             DeleteLocalInt(oPC,"SB_DARK_DMGED");
         }
         ApplyPermanentSubraceSpellResistance(ID, oPC);
         int HasDiffStats = GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_STAT_MODIFIERS, FLAG1);
         if(HasDiffStats)
         {
            DeleteLocalInt(oPC, SUBRACE_STATS_STATUS);
            ClearSubraceTemporaryStats(oPC);
         }
         ClearSubraceEffects(oPC);
         ChangeToPCDefaultAppearance(oPC);
         DelayCommand(3.0, SearchAndDestroySkinsAndClaws(oPC));
     }
     oPC = GetNextPC();
  }
  return TRUE;
}
int StartSSE()
{
   SendServerWideMessage("SSE has been started.", SWAND_MESSAGE_RECEIVER_DM_ONLY, TRUE );
   object oPC = GetFirstPC();
   while(!GetIsObjectValid(oPC) )
   {
     SHA_SendSubraceMessageToPC(oPC, "Shayan's Subrace Engine has been switched on in the Module! Your " + SUBRACE_WHEN_NOUN +" functionalities will now resume.", TRUE);
     DelayCommand(1.0,  ReapplySubraceAbilities(oPC) );
     oPC = GetNextPC();
  }
  return TRUE;
}
int GetAlignmentCodeByFlagNumber(int iNumber)
{
int iAlign=iNumber;
switch(iNumber)
    {
    case 0: iAlign = ALIGNMENT_GOOD; break;
    case 1: iAlign = ALIGNMENT_NEUTRAL; break;
    case 2: iAlign = ALIGNMENT_EVIL; break;

    case 3: iAlign = ALIGNMENT_LAWFUL; break;
    case 4: iAlign = ALIGNMENT_NEUTRAL; break;
    case 5: iAlign = ALIGNMENT_CHAOTIC; break;

    }
return iAlign;
}


int GetRaceCodeByFlagNumber(int iNumber)
{
int iRace=iNumber;
switch(iNumber)
    {
    case 0: iRace = RACIAL_TYPE_DWARF; break;
    case 1: iRace = RACIAL_TYPE_ELF; break;
    case 2: iRace = RACIAL_TYPE_GNOME; break;
    case 3: iRace = RACIAL_TYPE_HALFELF; break;
    case 4: iRace = RACIAL_TYPE_HALFLING; break;
    case 5: iRace = RACIAL_TYPE_HALFORC; break;
    case 6: iRace = RACIAL_TYPE_HUMAN; break;
    }

return iRace;
}

int GetPrestigeClassCodeByFlagNumber(int iNumber)
{
int iClass=iNumber;
switch(iNumber)
    {
    case 0: iClass = CLASS_TYPE_ARCANE_ARCHER; break;
    case 1: iClass = CLASS_TYPE_ASSASSIN; break;
    case 2: iClass = CLASS_TYPE_BLACKGUARD; break;
    case 3: iClass = CLASS_TYPE_DIVINE_CHAMPION; break;
    case 4: iClass = CLASS_TYPE_DRAGON_DISCIPLE; break;
    case 5: iClass = CLASS_TYPE_DWARVEN_DEFENDER; break;
    case 6: iClass = CLASS_TYPE_PALEMASTER; break;
    case 7: iClass = CLASS_TYPE_SHADOWDANCER; break;
    case 8: iClass = CLASS_TYPE_SHIFTER; break;
    case 9: iClass = CLASS_TYPE_WEAPON_MASTER; break;
    case 10: iClass = CLASS_TYPE_HARPER; break;
    }

return iClass;
}

string GetClearenceColour(object oTarget, int iReq, int iParam, int iCode=0, int iSubCode=0)
{
string sReturn = COLOUR_PURPLE;
int iReturn=0;
switch(iCode)
    {
        case 0:
            iReturn = 1<<( (iParam<<1) | ( (GetRacialType(oTarget)==iReq)?4:0) );
            break;
        case 1:
            if(iSubCode < 3)
                {
                iReturn = 1<<( (iParam<<1) | ( (GetAlignmentGoodEvil(oTarget)==iReq)?4:0) );
                }
              else
                {
                iReturn = 1<<( (iParam<<1) | ( (GetAlignmentLawChaos(oTarget)==iReq)?4:0) );
                }
            break;
        case 2:
            iReturn = (iReq && (!iParam) )?0x00000002:0x00000040;
            break;
    }

switch(iReturn)
    {
    //Did not meet and nor should it be met.
    case 0x00000001:
        sReturn = COLOUR_DARK; break;
    //Should meet but did not meet.
    case 0x00000002:
        sReturn = COLOUR_RED; break;
    //Did not meet but is not neccesary.
    case 0x00000004:
        sReturn = COLOUR_YELLOW; break;
    //Met, but was not a requirement
    case 0x00000010:
        sReturn = COLOUR_BLUE; break;
    //Met Requirement.
    case 0x00000040:
        sReturn = COLOUR_GREEN; break;
    }

return sReturn;
}

string ClassFlagToString(int iFlag)
{
   string sRet = "";
   if(iFlag & FLAG2)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_BARBARIAN);

    if(iFlag & FLAG3)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_BARD);

    if(iFlag & FLAG4)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_CLERIC);

    if(iFlag & FLAG5)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_DRUID);

    if(iFlag & FLAG6)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_FIGHTER);

    if(iFlag & FLAG7)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_MONK);

    if(iFlag & FLAG8)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_PALADIN);

    if(iFlag & FLAG9)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_RANGER);

    if(iFlag & FLAG10)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_ROGUE);

    if(iFlag & FLAG11)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_SORCERER);

    if(iFlag & FLAG12)
        sRet += "\n-" + ClassIntToString(CLASS_TYPE_WIZARD);

    return sRet;
}

string GetAlignmentByFlagNumber(int iNumber)
{
string sAlign;
switch(GetAlignmentCodeByFlagNumber(iNumber) )
    {
    case ALIGNMENT_GOOD: sAlign = "Good"; break;
    case ALIGNMENT_NEUTRAL: sAlign = "Neutral"; break;
    case ALIGNMENT_EVIL: sAlign = "Evil"; break;
    case ALIGNMENT_LAWFUL: sAlign = "Lawful"; break;
    case ALIGNMENT_CHAOTIC: sAlign = "Chaos"; break;
    default: sAlign = "ERROR - INVALID INPUT: " + IntToString(iNumber); break;
    }

return sAlign;
}


string GetRaceByFlagNumber(int iNumber)
{
string sRace;
switch(GetRaceCodeByFlagNumber(iNumber) )
    {
    case RACIAL_TYPE_HUMAN: sRace = "Human"; break;
    case RACIAL_TYPE_HALFORC: sRace = "Half-Orc"; break;
    case RACIAL_TYPE_HALFELF: sRace = "Half-Elf"; break;
    case RACIAL_TYPE_GNOME: sRace = "Gnome"; break;
    case RACIAL_TYPE_HALFLING: sRace = "Halfling"; break;
    case RACIAL_TYPE_ELF: sRace = "Elf"; break;
    case RACIAL_TYPE_DWARF: sRace = "Dwarf"; break;
    default: sRace = "ERROR - INVALID INPUT: " + IntToString(iNumber); break;
    }

return sRace;
}


string GetAreaTypeByFlagNumber(int iNumber)
{
string sAreaCode="";
switch(iNumber)
    {
        case 4:
            sAreaCode = "Interior Areas"; break;
        case 5:
            sAreaCode = "Exterior Areas"; break;
        case 6:
            sAreaCode = "Artificial Areas"; break;
        case 7:
            sAreaCode = "Natural Areas"; break;
        case 8:
            sAreaCode = "Above-ground Areas"; break;
        case 9:
            sAreaCode = "Underground Areas"; break;
        default:
            sAreaCode = "Invalid Area Code: " + IntToString(iNumber); break;


    }
return sAreaCode;
}

object GetMyTarget()
{
    return GetLocalObject(oMySpeaker, SWAND_PREFIX + SWAND_TARGET);
}

void SetMyTarget(object oTarget)
{
    SetLocalObject(oMySpeaker, SWAND_PREFIX + SWAND_TARGET, oTarget );
}

string PrintSubraceSpecialRestrictions(string SubraceStorage)
{
  SubraceStorage = SubraceStorage +"_"+SUBRACE_SPECIAL_RESTRICTION;
  int Count = GetSSEInt(SubraceStorage);
  string Test;
  int i=1;
  int Type, TestValue;
  string Varname, Database,Output="Special Restrictions\n\n";
  int ReturnValue=TRUE;

for( ; (i<=Count) && ReturnValue ; i++)
    {
    Test=SubraceStorage+IntToString(i);
    Type=GetSSEInt(Test);
    Varname=GetLocalString(oStorer, Test + SUBRACE_SPECIAL_RESTRICTION_VARNAME);
    Database=GetLocalString(oStorer, Test + SUBRACE_SPECIAL_RESTRICTION_DATABASE);
    Output += "\nRestriction " + IntToString(i);

    switch(Type & SUBRACE_SPECIAL_RESTRICTION_TYPE_ALL)
        {
        case SUBRACE_SPECIAL_RESTRICTION_TYPE_DATABASE:
            if(Database=="") Database = SUBRACE_DATABASE;
            Output += "\n In Database: " + Database +
                      "\n the Variable: " + Varname;
            break;
        case SUBRACE_SPECIAL_RESTRICTION_TYPE_ITEM:
            Output += "\n Item (tag): " + Varname;
            break;
        case SUBRACE_SPECIAL_RESTRICTION_TYPE_LOCAL_VAR:
            {
            Output = "\n Local Variable: " + Varname;
            if(!GetIsObjectValid(GetObjectByTag(Database)))
                {
                Output = "\n on Object (tag): " + Database;
                }
            else
                {
                if(Database == "")
                    {
                    Output = "\n On Player: ";
                    }
                else
                    {
                    Output = "\n On Possessed Item (tag): " + Database;
                    }
                }
            break;
            }
        }
     if(Type)
        {
        Output += "\n must exist!";
        }
     else
        {
        Output += "\n must " + ColourString("not", COLOUR_RED) + " exist!";
        }
    }

return Output;
}

string OutputSubraceInformation(int ID)
{
     string SubraceStorage = GetSubraceStorageLocationByID(ID);
     string sReturn = ColourString(GetSubraceNameByID(ID), COLOUR_GREEN_SSE);


     if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_UNDEAD, SUBRACE_BASE_INFORMATION_FLAGS))
     {
       sReturn += ColourString(" [Undead]", COLOUR_PURPLE);
     }

    int i=0;
    int iTemp = GetSSEInt(SubraceStorage + "_ALIAS");
    if( (SSE_TREAT_ALIAS_AS_SUBRACE & 2) && iTemp)
        {
        sReturn += "\nAlias: ";
        for( i=1 ; i<=iTemp ; i++ )
            {
            sReturn += " " + ColourString(
                GetLocalString(oStorer, SubraceStorage + "_ALIAS_" + IntToString(i) )
                    , COLOUR_LTEAL) + " ";
            }
        i=0;
        }

     iTemp = GetSSEInt(SubraceStorage + "_" + SUBRACE_GENDER_RES);
     if(iTemp)
     {
//3.0.6.7
       sReturn += "\nGender Requirements: " + ColourString(" Male ", ((iTemp & FLAG2)?COLOUR_RED:COLOUR_GREEN_SSE)) + ColourString(" Female ", ((iTemp & FLAG1)?COLOUR_RED:COLOUR_GREEN_SSE));
     }
     sReturn += "\nRace Restriction:";

     iTemp = GetSSEInt(SubraceStorage + "_" + SUBRACE_BASE_RACE) & SUBRACE_BASE_RACE_FLAGS;
     if( !iTemp  )
        {
        sReturn += ColourString(" No Restrictions", COLOUR_GREEN_SSE);
        }
      else
        {
         for( ; i < 7; i++)
            {
            if( (iTemp>>i) & FLAG1)
                {
                sReturn += " " + ColourString(GetRaceByFlagNumber(i), COLOUR_GREEN_SSE);
                }

            }
        }

     //Shayan, don't look, it is about to become UGLY! (for you :P )
     //iTemp and i are two integers, which are constantly changed rather than using
     //a new integer each time.

     iTemp = (GetSSEInt(SubraceStorage + "_" + SUBRACE_ALIGNMENT_RESTRICTION)>>1) & SMALLGROUP1;
     if( !iTemp  )
        {
        sReturn += "\nAlignment Restriction:" + ColourString(" No Restrictions", COLOUR_GREEN_SSE);
        }
      else
        {
         for( i=0 ; i < 6; i++)
            {
            switch(i)
                {
                case 0:
                    sReturn += "\n - Good/Evil:"; break;
                case 1:
                case 2:
                case 4:
                case 5:
                    sReturn += ","; break;
                case 3:
                    sReturn += ColourString(" (*)", COLOUR_LYELLOW)+"\n - Law/Chaos:"; break;
                }
                sReturn += " " + ColourString(GetAlignmentByFlagNumber(i), ((iTemp>>i) & FLAG1?COLOUR_GREEN_SSE:COLOUR_RED) );
                if(i==5) sReturn += ColourString(" (*)", COLOUR_LYELLOW);
            }
        }
    if(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION, FLAG1))
       {
             //Check if we meet Class Req.
            sReturn += "\nClass Restriction: ";
            sReturn += ClassFlagToString(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION));
       }
    if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_PRESTIGIOUS_SUBRACE, SUBRACE_BASE_INFORMATION_FLAGS))
    {
       sReturn += "\n" + ColourString("Prestigious subrace", COLOUR_LTEAL);
    }
    iTemp = GetLocalGroupFlagValue(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_ECL);
    if(iTemp)
    {
       sReturn += "\n" + "ECL: " + IntToColourString( iTemp );
    }


return sReturn;
}

string OutputFullSubraceInformation(int ID, int Page=0)
{

     //See OutputSubraceInformation for comments
     string SubraceStorage = GetSubraceStorageLocationByID(ID);
     string SubraceName = GetSubraceNameByID(ID);
     string sReturn = CapitalizeString(SUBRACE_WHEN_NOUN )+ " name: " + ColourString(SubraceName, COLOUR_GREEN_SSE );
     string sTemp="";
     int iTemp=0, i=0;

switch(Page)
    {
    case PARAMS_PAGE_0:
    i=0;
    iTemp = GetSSEInt(SubraceStorage + "_ALIAS");
    if( (SSE_TREAT_ALIAS_AS_SUBRACE & 2) && iTemp)
        {
        sReturn += "\nAlias: ";
        for( i=1 ; i<=iTemp ; i++ )
            {
            sReturn += " " + ColourString(
                GetLocalString(oStorer, SubraceStorage + "_ALIAS_" + IntToString(i) )
                    , COLOUR_LTEAL) + " ";
            }
        i=0;
        }

         sReturn += "\n\n**** "+GetStringUpperCase(SUBRACE_WHEN_NOUN)+" RESTRICTIONS ****\n\n";
         if(GetSSEInt(SubraceStorage + "_" + SUBRACE_GENDER_RES) > 0)
         {
           int iGen = GetSSEInt(SubraceStorage + "_" + SUBRACE_GENDER_RES);
           sReturn += "\nGender Requirements: " + ColourString(" Male ", ((iTemp & FLAG2)?COLOUR_GREEN_SSE:COLOUR_RED)) + ColourString(" Female ", ((iTemp & FLAG1)?COLOUR_GREEN_SSE:COLOUR_RED));

         }
         sReturn += "\nRacial:";

         iTemp = GetSSEInt(SubraceStorage + "_" + SUBRACE_BASE_RACE) & SUBRACE_BASE_RACE_FLAGS;
         i=0;
         if( !iTemp  )
            {
            sReturn += ColourString(" No Restrictions", COLOUR_GREEN_SSE);
            }
          else
            {
             for( ; i < 7; i++)
                {
                if( (iTemp>>i) & FLAG1)
                    {
                    sReturn += " " + ColourString(GetRaceByFlagNumber(i), COLOUR_GREEN_SSE);
                    }

                }
            }

         iTemp = (GetSSEInt(SubraceStorage + "_" + SUBRACE_ALIGNMENT_RESTRICTION)>>1) & SMALLGROUP1;
         if( !iTemp  )
            {
            sReturn += "\nAlignment:" + ColourString(" No Restrictions", COLOUR_GREEN_SSE);
            }
          else
            {
             for( i=0 ; i < 6; i++)
                {
                switch(i)
                    {
                    case 0:
                        sReturn += "\n - Good/Evil:"; break;
                    case 1:
                    case 2:
                    case 4:
                    case 5:
                        sReturn += ","; break;
                    case 3:
                        sReturn += ColourString(" (*)", COLOUR_LYELLOW)+"\n - Law/Chaos:"; break;
                    }
                    sReturn += " " + ColourString(GetAlignmentByFlagNumber(i), ((iTemp>>i) & FLAG1?COLOUR_GREEN_SSE:COLOUR_RED) );
                    if(i==5) sReturn += ColourString(" (*)", COLOUR_LYELLOW);
                }
            }
        if(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION, FLAG1))
           {
                sReturn += "\nClass Restriction: ";
                sReturn += ClassFlagToString(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION));
           }
        if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_PRESTIGIOUS_SUBRACE, SUBRACE_BASE_INFORMATION_FLAGS))
        {
           sReturn += "\n" + ColourString("Prestigious subrace", COLOUR_LTEAL) +
           "\nRequires " + IntToString(GetSSEInt(SubraceStorage + "_" + SUBRACE_PRESTIGIOUS_CLASS_RESTRICTION_MINIMUM_LEVELS) ) +
            " levels of either:";

           iTemp = GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_PRESTIGIOUS_CLASS_RESTRICTION,
                        MEDIUMGROUP1|TINYGROUP3);

            i=2;
            int iClass;
            for( ; i < 4; i++)
            {
                iClass = GetClassByPosition(i, GetMyTarget() );
    //                if(PrestigeClassToFlags(iClass ) & FLAG1)
                    {
                    sReturn += "" + ClassIntToString(iClass);
                    }
            }
        }
        iTemp = GetLocalGroupFlagValue(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_ECL);
        if(iTemp)
        {
           sReturn += "\n" + "ECL: " + IntToColourString( iTemp );
        }
        if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_UNDEAD, SUBRACE_BASE_INFORMATION_FLAGS))
        {
          sReturn += ColourString(" [Undead]\n", COLOUR_PURPLE);
        }

        sReturn += "\n\n**** "+GetStringUpperCase(SUBRACE_WHEN_NOUN)+ " STATS ****\n\n";

        iTemp = GetSSEInt(SubraceStorage + "_" + SUBRACE_FAVORED_CLASS);
        if(iTemp)
        {
           sReturn += "*Favored Classs:\n";
           int MaleFavoredClass = GetLocalGroupFlagValue(oStorer, SubraceStorage + "_" + SUBRACE_FAVORED_CLASS, SUBRACE_FAVORED_CLASS_MALE_FLAG);
           int FemaleFavoredClass = GetLocalGroupFlagValue(oStorer, SubraceStorage + "_" + SUBRACE_FAVORED_CLASS, SUBRACE_FAVORED_CLASS_FEMALE_FLAG);
           if(FemaleFavoredClass != MaleFavoredClass)
               sReturn += " - Male: " + ColourString(ClassIntToString(MaleFavoredClass - 1), COLOUR_LBLUE) +
                    "\n - Female: " + ColourString(ClassIntToString(FemaleFavoredClass - 1),COLOUR_LRED) + "\n\n";
             else
               sReturn += " - " + ColourString(ClassIntToString(MaleFavoredClass - 1), COLOUR_GREEN_SSE) + "\n\n";
        }


        iTemp = GetSSEInt(SubraceStorage + "_" + DAMAGE_AMOUNT_IN_LIGHT);
        if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_LIGHT_SENSITIVE, SUBRACE_BASE_INFORMATION_FLAGS))
        {
           sReturn +=  ColourString("*Light Sensitive", COLOUR_YELLOW) + "\n";
        }
        if(iTemp)
        {
            sReturn +=  ColourString( ((iTemp > 0)?
                                "*Takes " + ColourString(IntToString(iTemp), COLOUR_LRED) + " damage "
                                :
                                "*regenerates " + ColourString(IntToString(abs(iTemp)), COLOUR_GREEN_SSE) + " hitpoints ") +
                                "in sunlight"
                                , COLOUR_YELLOW) + "\n";
        }


        if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_UNDERGROUND_SENSITIVE, SUBRACE_BASE_INFORMATION_FLAGS))
        {
           sReturn +=  ColourString("*Underground Sensitive", COLOUR_LRED) + "\n";
        }
        iTemp = GetSSEInt(SubraceStorage + "_" + DAMAGE_AMOUNT_IN_UNDERGROUND);
        if(iTemp)
        {
            sReturn +=  ColourString( ((iTemp > 0)?
                                "*Takes " + ColourString(IntToString(iTemp), COLOUR_LRED) + " damage "
                                :
                                "*regenerates " + ColourString(IntToString(abs(iTemp)), COLOUR_GREEN_SSE) + " hitpoints ") +
                                "in underground areas"
                                , COLOUR_YELLOW) + "\n";
        }

        i=0;
        while(i <=MAXIMUM_PLAYER_LEVEL)
        {
            if( GetSSEInt(SubraceStorage + "_" + IntToString(i) + "_" + APPEARANCE_CHANGE) )
            {
               sReturn += CapitalizeString(SUBRACE_WHEN_NOUN) +" appearence alteration at level " + IntToString(i) + "\n";
            }
            i++;

         }

        sReturn += "\n"+ColourString("(*)", COLOUR_LYELLOW)+ " - Only one Req. in this line is needed to be of this subrace.";

        break;
    case PARAMS_PAGE_4:
        sReturn += PrintSubraceItemRestrictions(SubraceStorage);
        break;
    case PARAMS_PAGE_5:
        sReturn += PrintSubraceSpecialRestrictions(SubraceStorage);
        break;
    default:
        sReturn += PrintSubraceStatModification(SubraceStorage, Page);
        break;
    }

    return sReturn;
}

string GetTestMatch(object oTarget, int ID)
{
     //See OutputSubraceInformation for comments
     string SubraceStorage = GetSubraceStorageLocationByID(ID);
     string sReturn = CapitalizeString( SUBRACE_WHEN_NOUN ) + " name: " + ColourString(GetSubraceNameByID(ID), COLOUR_GREEN_SSE );
     if(GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_UNDEAD, SUBRACE_BASE_INFORMATION_FLAGS))
     {
       sReturn += ColourString(" [Undead]", COLOUR_PURPLE);
     }
     if(GetSSEInt(SubraceStorage + "_" + SUBRACE_GENDER_RES) > 0)
     {
       int iGen = GetSSEInt(SubraceStorage + "_" + SUBRACE_GENDER_RES);
       int Result;
       switch(GetGender(oTarget))
        {
            case GENDER_MALE:
                Result = !(iGen & FLAG2);
                break;
            case GENDER_FEMALE:
                Result = !(iGen & FLAG1);
                break;
        }

       sReturn += "\nGender Requirements: " + ColourString((Result?"Passed":"Failed"),(Result)?COLOUR_GREEN_SSE:COLOUR_RED);
     }
     sReturn += "\nRace Restriction:";

     int iTemp = GetSSEInt(SubraceStorage + "_" + SUBRACE_BASE_RACE) & SUBRACE_BASE_RACE_FLAGS;
     int i=0;
     if( !iTemp  )
        {
        sReturn += ColourString(" None", COLOUR_GREEN_SSE);
        }
      else
        {
         for( ; i < 7; i++)
            {

            sReturn += " " + ColourString(GetRaceByFlagNumber(i),
                            GetClearenceColour(oTarget, GetRaceCodeByFlagNumber(i), ((iTemp>>i) & FLAG1), 0, i) );


            }
        }
     iTemp = (GetSSEInt(SubraceStorage + "_" + SUBRACE_ALIGNMENT_RESTRICTION)>>1) & SMALLGROUP1;
      if( !iTemp  )
      {
        sReturn += "\nAlignment restriction:" + ColourString(" None", COLOUR_GREEN_SSE );
      }
      else
      {
         for( i=0 ; i < 6; i++)
            {
            switch(i)
                {
                case 0:
                    sReturn += "\n - Good/Evil:"; break;
                case 1:
                case 2:
                case 4:
                case 5:
                    sReturn += ","; break;
                case 3:
                    sReturn += "\n - Law/Chaos:"; break;
                }
                 sReturn += " " + ColourString(GetAlignmentByFlagNumber(i), GetClearenceColour(oTarget, GetAlignmentCodeByFlagNumber(i), (iTemp>>i)&FLAG1, 1, i));

            }
        }
       if(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION, FLAG1))
       {
             //Check if we meet Class Req.
            int iRes = CheckIfPCMeetsClassCriteria(oTarget,SubraceStorage);
            sReturn += "\nClass Restriction: " + ColourString((iRes?"Passed":"Failed"), iRes?COLOUR_GREEN_SSE:COLOUR_RED);
            sReturn +="\nCan only be one of:\n" + ClassFlagToString(GetLocalFlag(oStorer, SubraceStorage + "_" + SUBRACE_CLASS_RESTRICTION));
       }
       iTemp = GetLocalGroupFlag(oStorer, SubraceStorage + "_" + SUBRACE_BASE_INFORMATION, SUBRACE_BASE_INFORMATION_PRESTIGIOUS_SUBRACE, SUBRACE_BASE_INFORMATION_FLAGS)?1:0;
       sReturn += "\n\n* " + ColourString("Prestigious subrace",
                GetClearenceColour(oTarget, iTemp, CheckIfPCMeetsPrestigiousClassCriteria(oTarget, SubraceStorage), 2));

          i=0;
          iTemp = CheckIfPCGetsAnyErrorsWithSubraceTest(oTarget, ID);
          while(iTemp )
            {
            i += iTemp&FLAG1;
            iTemp>>=1;
            }
       sReturn += (i?"\n\nThe Engine has detected " + IntToString(i) + ((i==1)?" mismatch.":" mismatches."):"\n\nAcceptable "+ SUBRACE_WHEN_NOUN + " for " + GetName(GetMyTarget() ) );

    return sReturn;
}

void SWandSendPlayerToSubraceStartLocation(object Player, string subrace)
{
string SubraceStorage = GetSubraceStorageLocation(subrace);
string Waypoint;
location lStart;
object WP;

AssignCommand(Player, ClearAllActions());

if(subrace != "")
    {
    Waypoint = GetLocalString(oStorer, SubraceStorage + "_" + SUBRACE_START_LOCATION);
    if(GetIsObjectValid(GetWaypointByTag(Waypoint)))
        {
        //let SSE take it from here.
        Subrace_MoveToStartLocation(Player, subrace);
        return;
        }
    }
Waypoint = GetLocalString(OBJECT_SELF, SWAND_PREFIX + SWAND_CHOOSER_SETTINGS);
WP = GetWaypointByTag(Waypoint);
if( (Waypoint != "") && GetIsObjectValid(WP) )
    {
    lStart= GetLocation(WP);
    SHA_SendSubraceMessageToPC(Player, "Porting to you to your Start location.");
    }
  else
    {
    //Non-valid waypoint...
    lStart = GetStartingLocation();
    SHA_SendSubraceMessageToPC(Player, "Porting to you to the Start location of the Module.");
    }

DelayCommand(0.5, AssignCommand(Player, JumpToLocation(lStart)));
}

void ChangeSubrace(object oTarget, int iSubrace)
{
    if(GetLocalInt(oTarget, SWAND_PREFIX + SWAND_CHANGE_SUBRACE) )
    {
        SHA_SendSubraceMessageToPC(oMySpeaker, "Attempt to change " + GetName(oTarget) + "'s "+ SUBRACE_WHEN_NOUN + " failed. Change Already in progress", TRUE);
        return;
    }
    DeleteSubraceInfoOnPC(oTarget, TRUE);

    string subrace = GetSubraceNameByID(iSubrace);//GetLocalString(oStorer, MODULE_SUBRACE_NUMBER + IntToString(iSubrace));

    if(iSubrace != -1)
    {
        ApplySubrace(oTarget, subrace);
        DelayCommand(16.0, SHA_SendSubraceMessageToPC(oMySpeaker, GetName(oTarget) + "'s " + SUBRACE_WHEN_NOUN + " purge is complete.!", TRUE));
        DelayCommand(16.0, DeleteLocalInt(oTarget, SWAND_PREFIX + SWAND_CHANGE_SUBRACE) );
    }
    else
    {
        DelayCommand(2.5, SHA_SendSubraceMessageToPC(oTarget, "Your " + SUBRACE_WHEN_NOUN + " has been removed.", TRUE));
        DelayCommand(6.0, SHA_SendSubraceMessageToPC(oMySpeaker, GetName(oTarget) + "'s "+SUBRACE_WHEN_NOUN +" switch is complete.!", TRUE));
        DelayCommand(6.0, DeleteLocalInt(oTarget, SWAND_PREFIX + SWAND_CHANGE_SUBRACE) );
    }
if( (swand_ChooserSettings & SWAND_CHOOSER_IS_CHOOSER) && (swand_ChooserSettings & SWAND_CHOOSER_PORT_TO_SUBRACE_START_LOCATION_END_SUBRACE_MODIFICATION) )
    {
    SWandSendPlayerToSubraceStartLocation(oTarget, subrace);
    }

}



string TempModTypeToString(float TempStat, int ModifierType)
{
string sReturn="Error Invalid Modifier Type";
switch(ModifierType)
    {
    case 0:
        sReturn="0";
        break;
    case SUBRACE_STAT_MODIFIER_TYPE_PERCENTAGE:
        sReturn = IntToColourString(RoundOffToNearestInt(TempStat*100), "", "%");
        break;
    case SUBRACE_STAT_MODIFIER_TYPE_POINTS:
        sReturn = IntToColourString(FloatToInt(TempStat));
        break;
    }
return sReturn;
}

string movementspeed(int iSpeed)
{
string sReturn ="";
switch(iSpeed)
    {
    case MOVEMENT_SPEED_PC:
    //Shut up on PC Speed since it is 0 and will appear even if no speed change was requested.
    //    sReturn += "\n    - Movement Speed: 'PC-speed'";
        break;
    case MOVEMENT_SPEED_VERY_SLOW:
        sReturn += "Movement Speed: Very Slow";
        break;
    case MOVEMENT_SPEED_SLOW:
        sReturn += "Movement Speed: Slow";
        break;
    case MOVEMENT_SPEED_NORMAL:
        sReturn += "Movement Speed: Normal";
        break;
    case MOVEMENT_SPEED_FAST:
        sReturn += "Movement Speed: Fast";
        break;
    case MOVEMENT_SPEED_VERY_FAST:
        sReturn += "Movement Speed: Very Fast";
        break;
    case MOVEMENT_SPEED_DMSPEED:
        sReturn += "Movement Speed: 'DM-Speed'";
        break;
    case MOVEMENT_SPEED_DEFAULT:
        sReturn += "Movement Speed: 'Default'";
        break;
    case MOVEMENT_SPEED_IMMOBILE:
        sReturn += "Movement Speed: Immobile";
        break;
    case MOVEMENT_SPEED_CURRENT:
        sReturn += "Movement Speed: 'Current Speed'";
        break;
    }
return sReturn;
}

string PrintSubraceStatModification(string SubraceStorage, int Page)
{

//TIME_DAY, TIME_NIGHT, TIME_BOTH.
//SUBRACE_STAT_MODIFIER_TYPE_PERCENTAGE,

int iTime = GetSSEInt(SubraceStorage + "_" + SUBRACE_STAT_MODIFIERS)&0x00000003;
int iTypeDay = GetSSEInt(SubraceStorage  + IntToString(TIME_DAY) + "_" + SUBRACE_STAT_MODIFIER_TYPE);
int iTypeNight = GetSSEInt(SubraceStorage  + IntToString(TIME_NIGHT) + "_" + SUBRACE_STAT_MODIFIER_TYPE);
string sMidsep = /*(iTime&TIME_BOTH)?*/" - "/*:""*/;
int i=0, iLevel=0, iBaseStat, iSet;
float fStatDay, fStatNight;
string sReturn="\n\n**** "+GetStringUpperCase(SUBRACE_WHEN_NOUN) +" STATS ****\n\n";
switch(Page)
    {
    case PARAMS_PAGE_1:
        if(iTime == 0)
            {
            sReturn += "No Temp. Modified Stats.";
            }
          else
            {
            sReturn += "Temp. Modified Stats.:\nDay       -     Night";
            for( ; i < 6 ; i++)
                {
                fStatDay = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_DAY) + "_" + GetSubraceStatStorageName(i, FALSE)) ;
                fStatNight = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_NIGHT) + "_" + GetSubraceStatStorageName(i, FALSE));

                sReturn += "\n" + GetAbilityScoreName(i, TRUE) + ": " +(i==3?"  ":"")+ TempModTypeToString(fStatDay, iTypeDay) + sMidsep + GetAbilityScoreName(i, TRUE) + ": " +
                            (i==3?"  ":"") + TempModTypeToString(fStatNight, iTypeNight);
                }
                fStatDay = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_DAY) + "_" + SUBRACE_STAT_AB_MODIFIER);
                fStatNight = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_NIGHT) + "_" + SUBRACE_STAT_AB_MODIFIER);


                fStatDay = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_DAY) + "_" + SUBRACE_STAT_AC_MODIFIER);
                fStatNight = GetLocalFloat(oStorer, SubraceStorage + IntToString(TIME_NIGHT) + "_" + SUBRACE_STAT_AC_MODIFIER);

                sReturn += "\nAB: " + TempModTypeToString(fStatDay, iTypeDay)+" "+sMidsep+"AB: " + TempModTypeToString(fStatNight, iTypeNight);
                sReturn += "\nAC: " + TempModTypeToString(fStatDay, iTypeDay)+" "+sMidsep+"AC: " + TempModTypeToString(fStatNight, iTypeNight);
            }
            break;
    case PARAMS_PAGE_2:
        sReturn += "Base Modified Stats (Leto)";
        for( ; iLevel <=MAXIMUM_PLAYER_LEVEL ; iLevel++)
            {
            sMidsep = SubraceStorage + "_" + IntToString(iLevel);
            if(GetSSEInt( sMidsep + "_"+ SUBRACE_HAS_BASE_STAT_MODIFIERS))
                {
                iSet = GetSSEInt(sMidsep + "_" + SUBRACE_BASE_STAT_MODIFIERS_REPLACE);
                if(iSet)
                    {
                    sReturn += "\n\nBaseStat are at level " + IntToString(iLevel) + " set to:";
                    }
                  else
                    {
                    sReturn += "\n\nBaseStat are at level " + IntToString(iLevel) + " altered with:";
                    }
                for(i=0 ; i < 6 ; i++)
                    {
                    iBaseStat = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(i, TRUE));
                    if(iBaseStat)
                        {
                        sReturn += "\n    - " + GetAbilityScoreName(i, TRUE) + ": " + (i==3?"  ":"") + IntToColourString(iBaseStat, "", "", !iSet);
                        }
                    }
                }
            }
            iSet = GetSSEInt(sMidsep + "_" + SUBRACE_BASE_STAT_SPD_MODIFIER);
            if(iSet)
                {
                sReturn += "\n    - " + movementspeed(iSet);
                }
        break;
    case PARAMS_PAGE_3:
        sReturn += "Estimation of stats (Currently Leto only) with this " + SUBRACE_WHEN_NOUN +".";
        object oObject = GetMyTarget();
        int iStr = GetAbilityScore(oObject, ABILITY_STRENGTH, TRUE);
        int iDex = GetAbilityScore(oObject, ABILITY_DEXTERITY, TRUE);
        int iCon = GetAbilityScore(oObject, ABILITY_CONSTITUTION, TRUE);
        int iInt = GetAbilityScore(oObject, ABILITY_INTELLIGENCE, TRUE);
        int iWis = GetAbilityScore(oObject, ABILITY_WISDOM, TRUE);
        int iCha = GetAbilityScore(oObject, ABILITY_CHARISMA, TRUE);
        int iBaseStr = GetAbilityScore(oObject, ABILITY_STRENGTH, TRUE);
        int iBaseDex = GetAbilityScore(oObject, ABILITY_DEXTERITY, TRUE);
        int iBaseCon = GetAbilityScore(oObject, ABILITY_CONSTITUTION, TRUE);
        int iBaseInt = GetAbilityScore(oObject, ABILITY_INTELLIGENCE, TRUE);
        int iBaseWis = GetAbilityScore(oObject, ABILITY_WISDOM, TRUE);
        int iBaseCha = GetAbilityScore(oObject, ABILITY_CHARISMA, TRUE);
        for( ; iLevel <=MAXIMUM_PLAYER_LEVEL ; iLevel++)
            {
            sMidsep = SubraceStorage + "_" + IntToString(iLevel);
            if(GetSSEInt( sMidsep + "_"+ SUBRACE_HAS_BASE_STAT_MODIFIERS))
                {
                sReturn += "\n\nAt level " + IntToString(iLevel) + ":";
                if(GetSSEInt(sMidsep + "_" + SUBRACE_BASE_STAT_MODIFIERS_REPLACE))
                    {
                    iStr = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_STRENGTH, TRUE));
                    iDex = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_DEXTERITY, TRUE));
                    iCon = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_CONSTITUTION, TRUE));
                    iInt = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_INTELLIGENCE, TRUE));
                    iWis = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_WISDOM, TRUE));
                    iCha = GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_CHARISMA, TRUE));
                    }
                  else
                    {
                    iStr += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_STRENGTH, TRUE));
                    iDex += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_DEXTERITY, TRUE));
                    iCon += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_CONSTITUTION, TRUE));
                    iInt += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_INTELLIGENCE, TRUE));
                    iWis += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_WISDOM, TRUE));
                    iCha += GetSSEInt(sMidsep + "_" + GetSubraceStatStorageName(ABILITY_CHARISMA, TRUE));
                    }
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_STRENGTH, TRUE) + ": " + IntToColourString(iStr, "", "", 0, iBaseStr);
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_DEXTERITY, TRUE) + ": " + IntToColourString(iDex, "", "", 0, iBaseDex);
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_CONSTITUTION, TRUE) + ": " + IntToColourString(iCon, "", "", 0, iBaseCon);
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_INTELLIGENCE, TRUE) + ":   " + IntToColourString(iInt, "", "", 0, iBaseInt);
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_WISDOM, TRUE) + ": " + IntToColourString(iWis, "", "", 0, iBaseWis);
                sReturn += "\n    - " + GetAbilityScoreName(ABILITY_CHARISMA, TRUE) + ": " + IntToColourString(iCha, "", "", 0, iBaseCha);
                iSet = GetSSEInt(sMidsep + "_" + SUBRACE_BASE_STAT_SPD_MODIFIER);
                if(iSet)
                    {
                    sReturn += "\n    - " + movementspeed(iSet);
                    }

                }

            }
        break;
    }
sReturn += "\n\n";
return sReturn;
}

string GenerateRestrictionsDisplay(int Restrictions)
{
string sReturn;
string sColourOn="", sColourOff="";
int Test=0;
if(!Restrictions)
    {
    return sReturn + ColourString("None", COLOUR_GREEN);
    }

sReturn +="\n";

if(Restrictions&ITEM_TYPE_REQ_ALL)
    {
    sReturn +="Items must fit in ALL restrictions";
    }
  else
    {
    sReturn +="Items must fit in just one of restrictions";
    }


sColourOn= COLOUR_RED;
sColourOff = COLOUR_GREEN;

sReturn +="\n\nWeapon restrictions:\nTypes:";

Test = Restrictions&ITEM_TYPE_WEAPON;
if( (Test==ITEM_TYPE_WEAPON) || (!Test) )
    {
    sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
    }
  else
    {
    sReturn += "\n - ";
    sReturn += ColourString("Melee", (Test&ITEM_TYPE_WEAPON_MELEE?sColourOn:sColourOff));
    sReturn += "\n - ";
    sReturn += ColourString("Ranged [Throwing].", (Test&ITEM_TYPE_WEAPON_RANGED_THROW?sColourOn:sColourOff));
    sReturn += "\n - ";
    sReturn += ColourString("Ranged [Launchers].", (Test&ITEM_TYPE_WEAPON_RANGED_LAUNCHER?sColourOn:sColourOff));
    }

Test = Restrictions&ITEM_TYPE_WEAPON_SIZE_ANY;
sReturn += "\nSize";
if( (Test==ITEM_TYPE_WEAPON_SIZE_ANY) || (!Test) )
    {
    sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
    }
  else
    {
    sReturn += "\n - " + ColourString("Tiny", (Test&ITEM_TYPE_WEAPON_SIZE_TINY?sColourOn:sColourOff));
    sReturn += "\n - " + ColourString("Small", (Test&ITEM_TYPE_WEAPON_SIZE_SMALL?sColourOn:sColourOff));
    sReturn += "\n - " + ColourString("Medium", (Test&ITEM_TYPE_WEAPON_SIZE_MEDIUM?sColourOn:sColourOff));
    sReturn += "\n - " + ColourString("Large", (Test&ITEM_TYPE_WEAPON_SIZE_LARGE?sColourOn:sColourOff));
    }
sReturn +="\nProf:";

Test = Restrictions&ITEM_TYPE_WEAPON_PROF_ANY;
if( (Test==ITEM_TYPE_WEAPON_PROF_ANY) || (!Test) )
    {
    sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
    }
  else
    {
    sReturn += "\n - " + ColourString("Simple", (Test&ITEM_TYPE_WEAPON_PROF_SIMPLE?sColourOn:sColourOff));
    sReturn += "\n - " + ColourString("Martial", (Test&ITEM_TYPE_WEAPON_PROF_MARTIAL?sColourOn:sColourOff));
    sReturn += "\n - " + ColourString("Exotic", (Test&ITEM_TYPE_WEAPON_PROF_EXOTIC?sColourOn:sColourOff));
    }


sReturn +="\n\n";
Test = Restrictions&ITEM_TYPE_FULL_ARMOR_SET;
if( (Test==ITEM_TYPE_FULL_ARMOR_SET) || (!Test) )
    {
    sReturn +="Armor/Shield/Helm Restrictions:";
    sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
    }
  else
    {
    sReturn +="Armor Restrictions:";
    Test = Restrictions&ITEM_TYPE_ARMOR;
    if( (Test==ITEM_TYPE_ARMOR) || (!Test) )
        {
        sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
        }
      else
        {
        sReturn += "\n - " + ColourString(" Cloth", (Restrictions&ITEM_TYPE_ARMOR_TYPE_CLOTH?sColourOn:sColourOff));
        if( (!Test) || ((Test&ITEM_TYPE_ARMOR_TYPE_LIGHT)==ITEM_TYPE_ARMOR_TYPE_LIGHT) )
            {
            sReturn += "\n - " + ColourString(" Light", (Test?sColourOn:sColourOff));
            }
          else
            {
            sReturn += "\n - Light: ";
            sReturn += ColourString("1", (Restrictions&ITEM_TYPE_ARMOR_AC_1?sColourOn:sColourOff));
            sReturn += ", ";
            sReturn += ColourString("2", (Restrictions&ITEM_TYPE_ARMOR_AC_2?sColourOn:sColourOff));
            sReturn += ", ";
            sReturn += ColourString("3", (Restrictions&ITEM_TYPE_ARMOR_AC_3?sColourOn:sColourOff));
            sReturn += " AC";
            }
        if( (!Test) || ((Test&ITEM_TYPE_ARMOR_TYPE_MEDIUM)==ITEM_TYPE_ARMOR_TYPE_MEDIUM)  )
            {
            sReturn += "\n - " + ColourString(" Medium", (Test?sColourOn:sColourOff));
            }
          else
            {
            sReturn += "\n - Medium: ";
            sReturn += ColourString("4", (Restrictions&ITEM_TYPE_ARMOR_AC_4?sColourOn:sColourOff));
            sReturn += ", ";
            sReturn += ColourString("5", (Restrictions&ITEM_TYPE_ARMOR_AC_5?sColourOn:sColourOff));
            sReturn += ", ";
            sReturn += ColourString("6", (Restrictions&ITEM_TYPE_ARMOR_AC_6?sColourOn:sColourOff));
            sReturn += " AC";
            }
        if( (!Test) || ((Test&ITEM_TYPE_ARMOR_TYPE_HEAVY)==ITEM_TYPE_ARMOR_TYPE_HEAVY) )
            {
            sReturn += "\n - " + ColourString(" Heavy", (Test?sColourOn:sColourOff));
            }
          else
            {
            sReturn += "\n - Heavy: ";
            sReturn += ColourString("7", (Restrictions&ITEM_TYPE_ARMOR_AC_7?sColourOn:sColourOff));
            sReturn += ", ";
            sReturn += ColourString("8", (Restrictions&ITEM_TYPE_ARMOR_AC_8?sColourOn:sColourOff));
            sReturn += " AC";
            }
        }
    sReturn+= "\n - " + ColourString("Helm", (Restrictions&ITEM_TYPE_HELM?sColourOn:sColourOff));

    sReturn +="\n\nShield Restrictions:";
    Test = Restrictions&ITEM_TYPE_SHIELD_ANY;
    if( (Test==ITEM_TYPE_SHIELD_ANY) || (!Test) )
        {
        sReturn += ColourString(" All", (Test?sColourOn:sColourOff));
        }
      else
        {
        sReturn += "\n - " + ColourString("Small", (Restrictions&ITEM_TYPE_SHIELD_SMALL?sColourOn:sColourOff));
        sReturn += "\n - " + ColourString("Large", (Restrictions&ITEM_TYPE_SHIELD_LARGE?sColourOn:sColourOff));
        sReturn += "\n - " + ColourString("Tower", (Restrictions&ITEM_TYPE_SHIELD_TOWER?sColourOn:sColourOff));
        }
    }

sReturn +="\n\nOther Restrictions:";
sReturn += "\n - " + ColourString("Jewlery", (Restrictions&ITEM_TYPE_JEWLERY?sColourOn:sColourOff));
sReturn += "\n - " + ColourString("Misc. Clothing", (Restrictions&ITEM_TYPE_MISC_CLOTHING?sColourOn:sColourOff));

return sReturn;
}

string PrintSubraceItemRestrictions(string SubraceStorage)
{
string sReturn = "\n\nItem restrictions:";
string sRestrictionInfo = SubraceStorage + "_" + SUBRACE_ITEM_RESTRICTION + "_";

int r_Day = GetSSEInt(sRestrictionInfo + IntToString(TIME_DAY));
int r_Night = GetSSEInt(sRestrictionInfo + IntToString(TIME_NIGHT));
int r_Normal = GetSSEInt(sRestrictionInfo + IntToString(TIME_SPECIAL_APPEARANCE_NORMAL));
int r_Morph =  GetSSEInt(sRestrictionInfo + IntToString(TIME_SPECIAL_APPEARANCE_SUBRACE));


if(r_Morph && r_Normal)
    {
    sReturn += " Form-based\n\n";
    sReturn += "Special Form: " + GenerateRestrictionsDisplay(r_Morph);
    sReturn += "\n\nNormal Form: " + GenerateRestrictionsDisplay(r_Normal);
    }
else if( (r_Morph || r_Normal) && (r_Day || r_Night) )
    {
    sReturn += " Time & Form-based\n\n";
    sReturn += "Special Form: " + GenerateRestrictionsDisplay(r_Morph);
    sReturn += "\n\nNormal Form: " + GenerateRestrictionsDisplay(r_Normal);
    sReturn += "\n\nDay Time: " + GenerateRestrictionsDisplay(r_Day);
    sReturn += "\n\nNight Time: " + GenerateRestrictionsDisplay(r_Night);
    }
else
    {
    sReturn += " Time-based\n\n";
    sReturn += "Day Time: " + GenerateRestrictionsDisplay(r_Day);
    sReturn += "\n\nNight Time: " + GenerateRestrictionsDisplay(r_Night);
    }

return sReturn;
}

int GetSWandChooserSettings(object Chooser=OBJECT_SELF)
{
return GetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_SETTINGS);
}

int swand_PlayerIsAllowedToChangeSubrace(object Player)
{
return( (! GetPlayerSubraceID(Player) ) &&
    (SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_TAKE_SUBRACE & swand_ChooserSettings ) &&
    (GetHitDice(Player)<= SWAND_LOW_LEVEL_SUBRACE_CHANGE) );
}

void SetSWandChooserSettings(string WaypointTagForTheSubraceless="", int AllowSubracelessPlayersToTakeASubrace=TRUE, int AllowSubracelessPlayersPortToStart=TRUE, int CanBeUsedSubraceStartLocationPortal=FALSE, int PortOnSubraceModification=TRUE, object Chooser=OBJECT_SELF)
{
int Settings = SWAND_CHOOSER_IS_CHOOSER | (AllowSubracelessPlayersToTakeASubrace?SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_TAKE_SUBRACE:0) | (PortOnSubraceModification?SWAND_CHOOSER_PORT_TO_SUBRACE_START_LOCATION_END_SUBRACE_MODIFICATION:0) |
                (AllowSubracelessPlayersPortToStart?SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_PORT_TO_START_LOCATION:0) | (CanBeUsedSubraceStartLocationPortal?SWAND_CHOOSER_START_LOCATION_PORTAL:0);

SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_SETTINGS, Settings);
if ( WaypointTagForTheSubraceless != "")
    {
    SetLocalString(Chooser, SWAND_PREFIX + SWAND_CHOOSER_SETTINGS, WaypointTagForTheSubraceless);
    }
}

string PrintSWandChooserSettings(int Verbose=FALSE, int PRMessage=FALSE, object Chooser=OBJECT_SELF)
{
Chooser = GetIsPC(OBJECT_SELF)?GetModule():OBJECT_SELF;
int Settings = GetSWandChooserSettings(Chooser);
string Message = "";
string Waypointtag;
object Waypoint = OBJECT_INVALID;
if(Settings & SWAND_CHOOSER_IS_CHOOSER)
    {
    Waypointtag = GetLocalString(Chooser, SWAND_PREFIX + SWAND_CHOOSER_SETTINGS);
    Message = "This Subrace Chooser:";
    if( (Settings & SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_TAKE_SUBRACE) && (SWAND_LOW_LEVEL_SUBRACE_CHANGE > 0) )
        {
        Message += "\n - allows "+SUBRACE_WHEN_NOUN+"less players below level " + IntToString(SWAND_LOW_LEVEL_SUBRACE_CHANGE + 1) + " to get a "+SUBRACE_WHEN_NOUN+".";
        }
    if(Settings & SWAND_CHOOSER_START_LOCATION_PORTAL)
        {
        Message += "\n - allows all players to be ported to their "+SUBRACE_WHEN_NOUN+"'s start location.";
        }
    else if(Settings & SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_PORT_TO_START_LOCATION)
        {
        Message += "\n - allows "+SUBRACE_WHEN_NOUN+"less players to be ported to their start location.";
        }
    if(Settings & SWAND_CHOOSER_PORT_TO_SUBRACE_START_LOCATION_END_SUBRACE_MODIFICATION)
        {
        Message += "\n - will port players, who obtains a "+SUBRACE_WHEN_NOUN+" from this chooser to their new start location.";
        }
    if(Verbose)
        {
        if(Waypointtag != "")
            {
            Message += "\nWaypoint tag for "+SUBRACE_WHEN_NOUN+"less players: " + ColourString(Waypointtag, COLOUR_LBLUE);
            Waypoint = GetWaypointByTag(Waypointtag);
            if(GetIsObjectValid(Waypoint))
                {
                Message += "\nPorting "+SUBRACE_WHEN_NOUN+"less players to the area: " + ColourString( GetName(GetArea(Waypoint)), COLOUR_LGREEN );
                }
              else
                {
                Message += "\nWaypoint was " + ColourString("not", COLOUR_RED) + " detected, please check the supplied tag. "+ CapitalizeString(SUBRACE_WHEN_NOUN) +"less players are ported to the start location of the Module";
                }
            }
          else
            {
            Message += "\nWaypoint tag not supplied, porting "+SUBRACE_WHEN_NOUN+"less players to the start location of the module.";
            }
        }
    }
return Message;
}


/*******************************************************************************
***********************   SWand Conversation Menus   ***************************
*******************************************************************************/



int swand_BuildConversationDialog(int nCurrent, int nChoice, int iConversation, int iParams, int iFunction=0)
{
switch(iConversation)
    {
    case CONV_START:
        if(sw_gl_Permission>=SWAND_PERMISSION_DM)
        return swand_conv_Start_DM(nCurrent, nChoice, iParams, iFunction);
        return swand_conv_Start_PC(nCurrent, nChoice, iParams, iFunction);
    case CONV_LIST_OBJECTS:
        return swand_conv_ListObjects(nCurrent, nChoice, iParams, iFunction);
    case CONV_LIST_RACES:
        return swand_conv_ListRaces(nCurrent, nChoice, iParams, iFunction);
    case CONV_READ_RACE:
        if(sw_gl_Permission>=SWAND_PERMISSION_DM)
        return swand_conv_ReadRaces_DM(nCurrent, nChoice, iParams, iFunction);
        return swand_conv_ReadRaces_PC(nCurrent, nChoice, iParams, iFunction);
    case CONV_WORK_TARGET:
        return swand_conv_WorkWithTarget(nCurrent, nChoice, iParams, iFunction);
    case CONV_MATCH:
        if(sw_gl_Permission>=SWAND_PERMISSION_DM)
        return swand_conv_Match_DM(nCurrent, nChoice, iParams, iFunction);
        return swand_conv_Match_PC(nCurrent, nChoice, iParams, iFunction);
    case CONV_TEST_LETO:
        return swand_conv_LetoTest(nCurrent, nChoice, iParams, iFunction);
    case CONV_CONFIRM_SUBRACE_CHANGE:
        if(sw_gl_Permission>=SWAND_PERMISSION_DM)
        return swand_conv_ConfirmSubraceChange_DM(nCurrent, nChoice, iParams, iFunction);
        return swand_conv_ConfirmSubraceChange_PC(nCurrent, nChoice, iParams, iFunction);
    }
    return FALSE;

}

void swand_BuildConversation(int iConversation, int iParams, int iFunction = 0, int iMenu=0)
{
   int iLast;
   int iTemp;
   int iChoice = 1;
   int iCurrent = 1;
   int iMatch;

   if(iMenu & MENU_PREV)
   {
      //Get the number choice to start with
      iCurrent = GetLocalInt(oMySpeaker, "swand_dialogprev");

      swand_BuildChoice(9, "More Options >>", iConversation, iFunction, iParams, MENU_NEXT);
      //Since we're going to the previous page, there will be a next
      SetLocalInt(oMySpeaker, "swand_dialognext", iCurrent);

      iChoice = 8;
      for(;iChoice >= 0; iChoice--)
      {
         int iTemp1 = iCurrent;
         int iTemp2 = iCurrent;
         iMatch = iTemp2;
         while((iCurrent == iMatch) && (iTemp2 > 0))
         {
            iTemp2--;
            iMatch = swand_BuildConversationDialog(iTemp2, iChoice, iConversation, iParams, iFunction);
         }

         if(iTemp2 <= 0)
         {
            //we went back too far for some reason, so make this choice blank
            swand_RemoveChoice(iChoice);
         }
         iLast = iTemp;
         iTemp = iTemp1;
         iTemp1 = iMatch;
         iCurrent = iMatch;
      }

      if(iMatch > 0)
      {
         swand_BuildChoice(1, "Previous Options <<", iConversation, iFunction, iParams, MENU_PREV);
         SetLocalInt(oMySpeaker, "swand_dialogprev", iLast);
      }

      //fill the NPC's dialog spot
      //(saved for last because the build process tromps on it)
      swand_BuildConversationDialog(0, 0, iConversation, iParams, iFunction);
   }
   else
   {
      //fill the NPC's dialog spot
      swand_BuildConversationDialog(0, 0, iConversation, iParams, iFunction);

      //A "next->" choice was selected
      if(iMenu & MENU_NEXT)
      {
         //get the number choice to start with
         iCurrent = GetLocalInt(oMySpeaker, "swand_dialognext");

         //set this as the number for the "previous" choice to use
         SetLocalInt(oMySpeaker, "swand_dialogprev", iCurrent);

         //Set the first dialog choice to be "previous"
         iChoice = 2;
         swand_BuildChoice(1, "Previous Options <<", iConversation, iFunction, iParams, MENU_PREV);
      }

      //Loop through to build the dialog list
      for(;iChoice <= 10; iChoice++)
      {
         iMatch = swand_BuildConversationDialog(iCurrent, iChoice, iConversation, iParams, iFunction);
         //nLast will be the value of the choice before the last one
         iLast = iTemp;
         iTemp = iMatch;
         if(iMatch > 0) { iCurrent = iMatch; }
         else if(iMatch == 0) { iLast = 0; }
         iCurrent++;
      }

      //If there were enough choices to fill 10 spots, make spot 9 a "next"
      if(iLast > 0)
      {
         swand_BuildChoice(9, "More Options >>", iConversation, iFunction, iParams, MENU_NEXT);
         SetLocalInt(oMySpeaker, "swand_dialognext", iLast);

      }
   }
}

int swand_conv_Start_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = 0;



   switch(nCurrent)
   {
      case 0:
         nCurrent = 0;
         sText =       "Welcome to Shayan's Subrace Engine's SWand." +
                       "\nEngine Version: " + ColourString(SUBRACE_ENGINE_VERSION, COLOUR_LBLUE) +
                       "\nWand Version: " + ColourString(SWAND_VERSION, COLOUR_LBLUE ) +
                       "\nStatus: " +
                (GetIsSSEDisabled()?ColourString("\nSSE is DISABLED MODULE WIDE!", COLOUR_RED):ColourString("\nSSE is ACTIVATED and functioning!", COLOUR_GREEN_SSE)) +
                (GetIsSSEDisabledInArea(GetArea(oMySpeaker))?ColourString("\nThe Engine is disabled in this Area", COLOUR_YELLOW):ColourString("\nThe Engine is enabled in this Area", COLOUR_GREEN_SSE)) +
                "\n\n" + PrintSWandChooserSettings(TRUE);

         iCall =       0;
         break;
      case 1:
         sText =       (GetIsObjectValid(GetMyTarget()))?"Work with my target: "+ ColourString(GetName(GetMyTarget()) ):"";
         iCall =       CONV_WORK_TARGET;
         break;
      case 2:
         sText =       "List players";
         iCall =       CONV_LIST_OBJECTS|CONV_DO_FUNCTION;
         iFunction =   FUNCTION_BUILD_CACHE;
         break;
      case 3:
         sText =       "List "+SUBRACE_WHEN_NOUN+"s";
         iCall =       CONV_LIST_RACES;
         iParams =     CONV_READ_RACE;
         iFunction =   0;
         break;
      case 4:
         sText =       (GetIsObjectValid(GetMyTarget()))?"Show me all "+SUBRACE_WHEN_NOUN+"s available to my target...":"";
         iCall =       CONV_LIST_RACES;
         iParams =     CONV_READ_RACE;
         iFunction =   1;
         break;
      case 5:
         if(SWAND_RESTRICT_LETO || (sw_gl_Permission==SWAND_PERMISSION_ADMIN) )
             {
             //Admins ignore restrictions
             sText =       "Check NWNX-Leto";
             iCall =       CONV_TEST_LETO;
             iParams =     0;
             }
         break;
      case 6:
         sText =       "Reset Server";
         iCall =       CONV_DO_FUNCTION;
         iFunction =   FUNCTION_DO_RESET;
         break;
      case 7:
         sText = (GetIsSSEDisabledInArea(GetArea(oMySpeaker))?ColourString("Enable"):ColourString("Disable", COLOUR_RED)) + " Shayan's Subrace Engine in this area";
         iCall =       CONV_DO_FUNCTION|CONV_START;//To update "case 0"
         iFunction =   FUNCTION_DO_DISABLE_ENGINE;
         break;
      case 8:
         sText = (GetIsSSEDisabled()?ColourString("START"):ColourString("STOP", COLOUR_RED)) + " Shayan's Subrace Engine in the Module.";
         iCall =       CONV_DO_FUNCTION|CONV_START;//To update "case 0"
         iFunction =   FUNCTION_DO_SHUTDOWN_ENGINE;
         break;
      case 9:
         sText = "Save all characters (Uses the ExportAllCharacters)";
         iCall =        CONV_DO_FUNCTION;
         iFunction =    FUNCTION_SAVE_CHARACTER;
         iParams =      0;
         break;
      case 10:
         sText = (GetIsObjectValid(GetMyTarget()))?"Open the SChooser Interface to "+ GetName(GetMyTarget()):"";
         iCall =        CONV_DO_FUNCTION;
         iFunction =    FUNCTION_OPEN_SCHOOSER;
         iParams =      0;
         break;
      default:
         nCurrent = 0;
         iFunction = 0;
         break;

   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iParams);

   return nCurrent;
}



int swand_conv_ListObjects(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = CONV_WORK_TARGET| CONV_DO_FUNCTION;

   object oObject;
   int nCache = GetLocalInt(oMySpeaker, "swand_object_cache");
   iFunction = FUNCTION_CACHE_2_TARGET;

   switch(nCurrent)
   {
      case 0:
         nCurrent = 0;
         sText =       "Which player do you wish to target?";
         iCall =       0;
         break;
      default:
         //Find the next object in the cache which is valid
         oObject = GetLocalObject(oMySpeaker, "swand_object_cache" + IntToString(nCurrent));
         while((! GetIsObjectValid(oObject)) && (nCurrent <= nCache))
         {
            nCurrent++;
            oObject = GetLocalObject(oMySpeaker, "swand_object_cache" + IntToString(nCurrent));
         }

         if(nCurrent > nCache)
         {
            //We've run out of cache, any other spots in this list should be
            //skipped
            nCurrent = 0;
            sText =       "";
            iCall =       0;
            iFunction =   0;
            iParams =     0;
         }
         else
         {
            //We found an Object, set up the list entry
            sText =       GetInfoCurrentTarget(oObject);
            iParams =     nCurrent;
         }
         break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iParams);

   return nCurrent;
}


int swand_conv_ListRaces(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = 0;
   int iCallParams = 0;
   int Done=TRUE;
   int iSubraceCount = GetSSEInt(MODULE_SUBRACE_COUNT);

   switch(nCurrent)
   {
      case 0:
         nCurrent = 0;
         sText =       "Which "+SUBRACE_WHEN_NOUN+" do you wish to select?";
         iCall =       0;
         break;
      default:
      if(nCurrent > iSubraceCount)
      {
            //We've run out of cache, any other spots in this list should be
            //skipped
            //nCurrent = 0;
            sText="";
            return 0;
       }
       else
         {
            object oTarget = GetMyTarget();
            switch(iFunction)
            {
                case 1:
                    while(sText == "" && nCurrent <= iSubraceCount)
                    {
                        if(CheckIfPCMeetsBaseRaceCriteria(oTarget, GetSubraceStorageLocationByID(nCurrent)) )
                        {
                            sText =  OutputSubraceInformation(nCurrent);
                            iCall =   iParams;
                            iCallParams = nCurrent;
                            Done=FALSE;
                            break;
                        }
                        nCurrent++;
                    }
                    break;
                case 2:
                    while(sText == "" && nCurrent <= iSubraceCount)
                    {
                        if(!CheckIfPCGetsAnyErrorsWithSubraceTest(oTarget, nCurrent))
                        {
                            sText =  OutputSubraceInformation(nCurrent);
                            iCall =   iParams;
                            iCallParams = nCurrent;
                            Done=FALSE;
                            break;
                        }
                        nCurrent++;
                    }
                    break;
                default:
                    sText =  OutputSubraceInformation(nCurrent);
                    iCall =   iParams;
                    iCallParams = nCurrent;
                    Done=FALSE;
                    break;
                }
         }
         break;
    if(Done)
        {
        sText="";
        iCall=0;
        iCallParams = nCurrent;
        }
   }



   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);

   return nCurrent;
}

int swand_conv_ReadRaces_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = 0;
   int iCallParams = iParams & PARAMS_PAGE_FILTER_OUT;


   switch(nCurrent)
   {
      case 0:
         sText =       OutputFullSubraceInformation(iParams & PARAMS_PAGE_FILTER_OUT,
                                                    iParams &~PARAMS_PAGE_FILTER_OUT);
         iCall =       0;
         break;
      case 1:
         sText =       (GetIsObjectValid(GetMyTarget()))?
                        "Work with my target: "+ ColourString(GetName(GetMyTarget()) ):"";
         iCall =       CONV_MATCH;
         break;
      case 2:
         sText =       "Show Base information";
         iCall =       CONV_READ_RACE;
         break;
      case 3:
         sText =       "Show Temp. Stat information";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_1;
         break;
      case 4:
         sText =       "Show Base Stat information (Leto)";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_2;
         break;
      case 5:
         sText =       (GetIsObjectValid(GetMyTarget())?
                        "Estimate "+ ColourString(GetName(GetMyTarget()))+"'s stats with this "+SUBRACE_WHEN_NOUN:"");
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_3;
         break;
      case 6:
         sText =       "Show the "+SUBRACE_WHEN_NOUN+"'s item restrictions";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_4;
         break;
      case 7:
         sText =       "Show the "+SUBRACE_WHEN_NOUN+"'s special restrictions";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_5;
         break;
      case 8:
         sText =       "Back to "+SUBRACE_WHEN_NOUN+" list";
         iCall =       CONV_LIST_RACES;
         iCallParams = CONV_READ_RACE;
         break;
      case 9:
         sText =       "Back to Main Menu";
         iCall =       CONV_START;
         break;
      default:
            nCurrent = 0;
         break;

   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);

   return nCurrent;
}

int swand_conv_WorkWithTarget(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iCallParams = 0;
   int iFunction =0;


   switch(nCurrent)
   {
      case 0:
          sText = GetInfoCurrentTarget(GetMyTarget() );
          break;
      case 1:
          sText = "Give player a new "+SUBRACE_WHEN_NOUN+". This will remove the old "+SUBRACE_WHEN_NOUN+".";
          iCall = CONV_LIST_RACES;
          iCallParams = CONV_MATCH;
          break;
      case 2:
          sText = "Purge player's "+SUBRACE_WHEN_NOUN;
          iCall = CONV_CONFIRM_SUBRACE_CHANGE;
          iCallParams = -1;
          break;
      case 3:

          break;
      case 7:
          sText = "Search for a new player to work with.";
         iCall =     CONV_LIST_OBJECTS|CONV_DO_FUNCTION;
         iFunction = FUNCTION_BUILD_CACHE;
          break;
      case 8:
          sText =     ColourString("Back to Main Menu");
          iCall =     CONV_START;
          break;
      default:
            nCurrent = 0;
            break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);

   return nCurrent;
}

int swand_conv_Match_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iCallParams = iParams;


   switch(nCurrent)
   {
      case 0:
          sText = GetTestMatch(GetMyTarget(), iParams );
          break;
      case 1:
          sText = "Change "+SUBRACE_WHEN_NOUN;
          iCall = CONV_CONFIRM_SUBRACE_CHANGE;
          break;

      case 7:
          sText = "Select a different "+SUBRACE_WHEN_NOUN;
          iCall = CONV_LIST_RACES;
          iCallParams = CONV_MATCH;
          break;
      case 8:
          sText =     ColourString("Back to Main Menu");
          iCall =     CONV_START;
          break;
      default:
            nCurrent = 0;
            break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);
   return nCurrent;
}

int swand_conv_LetoTest(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iFunction = SWandLetoTest(iParams & 0x80000000);
   iParams &= 0x7FFFFFFF;
   object oTarget;
   string sFilename;
   string sLoc;

switch(nCurrent)
{
    case 0:
        switch(iParams)
        {
        case 0x00000000:
            sText = "SWand Leto Test Menu: " + (iParams & 0x80000000?"Test is Forced!\n":"\n");
            switch(iFunction)
                {
                case SWAND_LETO_DETECTED:
                    sText += "LetoScript detected!";
                    SetLocalString(oStorer, "SUBR_PlayerName", "[Login]");
                    sText += "\n\nServervault Path: " + LETO_GetBicPath_Wand(oStorer);
                    DeleteLocalString(oStorer, "SUBR_PlayerName");
                    break;
                case SWAND_LETO_NOT_DETECTED:
                    sText += "SWand was unable to detect LetoScript";
                    break;
                case SWAND_LETO_NOT_ENABLED:
                    sText += "SSE was not compiled with Leto Enabled, therefore no test was made.";
                    sText += "\n\nTo enable Leto, open sha_subr_consts " +
                             "and change the ENABLE_LETO constant to TRUE";
                    break;
                default:
                    //This cannot not possibly happen, but if it does, at least they can report it.
                    sText += "Error...? SWandLetoTest returned unexpected value.\n"+
                             "See the manual's Contact Page for support.";
                    break;

                }
          break;
        case 0x00000001:
            if( SWandLetoTest()==SWAND_LETO_DETECTED ) //Retest incase the initial test was bypassing SSE ENABLE_LETO
                {
                sText = "Leto Information:"+
                    "\n\n" +(LETO_ACTIVATE_PORTAL?
                        "Use Portal: Yes\nIP: "
                        + LETO_PORTAL_IP_ADDRESS
                        + "\nPassword: "
                        + (( (SWAND_RESTRICT_LETO-1)
                            || (sw_gl_Permission==SWAND_PERMISSION_ADMIN) )
                            ?LETO_PORTAL_SERVER_PASSWORD:
                            "********") +
                        "\nWaypoint Tag: " + LETO_PORTAL_WAYPOINT + "\nKeep PC In Place: " + (LETO_PORTAL_KEEP_CHARACTER_IN_THE_SAME_PLACE?
                        "Yes":"No")
                        :
                        "Use Portal: No\nDo Auto-Booting: " + (LETO_AUTOMATICALLY_BOOT?"Yes":"No")
                        + "\nBoot Delay: " + IntToString(LETO_AUTOMATIC_PORTAL_DELAY) + " seconds"
                        );
                oTarget = GetMyTarget();
                if(GetIsObjectValid(oTarget) && !GetIsDM(oTarget) && GetIsPC(oTarget) )
                    {
                    sText += "\n\nPath: " + LETO_GetBicPath_Wand(oTarget);
                    sText += "\nFilename: " + GetLocalString(oTarget, "SUBR_FileName");
                    sText += "\nNB: the filename may not be accurate, check the Leto boards for issues about 'FindNewestBic' or filename issues in general";
                    }
                  else
                    {
                    SetLocalString(oStorer, "SUBR_PlayerName", "[Login]");
                    sText += "\n\nPath: " + LETO_GetBicPath_Wand(oStorer);
                    DeleteLocalString(oStorer, "SUBR_PlayerName");
                    sText += "\nFileName: N/A";
                    sText += "\nPlease select a non-DM Player Character for a filename estimation";
                    }
                }
              else
                {
                sText = "'Off-line' Leto Information:"+
                    "\n\n" +(LETO_ACTIVATE_PORTAL?
                        "Use Portal: Yes\nIP: " + LETO_PORTAL_IP_ADDRESS + "\nPassword: " + ((SWAND_RESTRICT_LETO-1)?LETO_PORTAL_SERVER_PASSWORD:"********") +
                        "\nWaypoint Tag: " + LETO_PORTAL_WAYPOINT + "\nKeep PC In Place: " + (LETO_PORTAL_KEEP_CHARACTER_IN_THE_SAME_PLACE?
                        "Yes":"No")
                        :
                        "Use Portal: No\nDo Auto-Booting: " + (LETO_AUTOMATICALLY_BOOT?"Yes":"No")
                        + "\nBoot Delay: " + IntToString(LETO_AUTOMATIC_PORTAL_DELAY) + " seconds"
                        );
                }
            break;
        }
        break;
    case 1:
        switch(iParams)
            {
            case 0x00000000:
                switch(iFunction)
                    {
                    case SWAND_LETO_NOT_ENABLED:
                        sText = "Bypass restrictions and force SWand to attempt to detect Leto.";
                        iCall = CONV_TEST_LETO;
                        iParams = 0x80000000;
                        break;
                    }
                break;
            }
        break;

    case 2:
        switch(iParams)
            {
            case 0x00000000:
                if(!(iParams &0x80000000))
                    {
                    sText = "Display Leto-information (This might be the 'Off-line' information, if SSE is not compiled with Leto enabled)";
                    }
                  else if(iFunction==SWAND_LETO_DETECTED)
                    {
                    sText = "Display Leto-information";
                    }
                  else
                    {
                    sText = "Display 'Off-line' Leto-information";
                    }
                iCall = CONV_TEST_LETO;
                iParams = 0x00000001;
                break;
            }
        break;
    case 8:
        sText =     ColourString("Back to Main Menu");
        iCall =       CONV_START;
        iParams = 0;
        iFunction = 0;
        break;
    default:
        nCurrent = 0;
        iFunction = 0;
        iParams = 0;
        break;
    }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iParams);

    return nCurrent;
}

int swand_conv_ConfirmSubraceChange_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iCallParams = iParams;

   switch(nCurrent)
   {
      case 0:
          if(!GetLocalInt(GetMyTarget(), SWAND_CHANGE_SUBRACE))
          {
              sText = "You are about to "+ ( (iParams!=-1)?
                            ColourString("change ", COLOUR_YELLOW) + ColourString(GetName(GetMyTarget())) + "'s "+SUBRACE_WHEN_NOUN+" to " + ColourString(CapitalizeString( GetLocalString(oStorer, MODULE_SUBRACE_NUMBER + IntToString(iParams)) ), COLOUR_LBLUE )
                            :
                            ColourString("remove ", COLOUR_RED)+ ColourString(GetName(GetMyTarget())) + "'s "+SUBRACE_WHEN_NOUN);
          }
          else
          {
               sText = GetName(GetMyTarget()) + "'s "+SUBRACE_WHEN_NOUN+" has been changed.";
          }
          break;
      case 1:
          if(!GetLocalInt(GetMyTarget(), SWAND_CHANGE_SUBRACE))
          {
              sText = "Proceed with the change.";
              iCall = CONV_DO_FUNCTION;
              iFunction = FUNCTION_CHANGE_SUBRACE;
          }
          else
          {
              nCurrent = 0;
          }
          break;
      case 7:
          sText = "Select a different "+SUBRACE_WHEN_NOUN;
          iCall = CONV_LIST_RACES;
          iCallParams = CONV_MATCH;
          break;
      case 8:
          sText =     ColourString("Back to Main Menu");
          iCall =     CONV_START;
          break;
      default:
            nCurrent = 0;
            break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);
   return nCurrent;
}


int swand_conv_Start_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = 0;




   switch(nCurrent)
   {
      case 0:
         nCurrent = 0;
         sText =       "Welcome to SChooser for Shayan's Subrace Engine." +
                       "\nEngine Version: " + ColourString(SUBRACE_ENGINE_VERSION, COLOUR_LBLUE) +
                       "\nWand Version: " + ColourString(SWAND_VERSION, COLOUR_LBLUE ) +
                       "\n\n" + PrintSWandChooserSettings(FALSE, TRUE);
         iCall =       0;
         break;
      case 1:
         if(swand_PlayerIsAllowedToChangeSubrace(oMySpeaker ) )
            {
             sText =       "Apply a new "+SUBRACE_WHEN_NOUN+"...";
              iCall = CONV_LIST_RACES;
              iParams = CONV_MATCH;
            }
         break;
      case 2:
         sText =       "Show me all "+SUBRACE_WHEN_NOUN+"s, to which my character meets all requirements...";
         iCall =       CONV_LIST_RACES;
         iParams =     CONV_READ_RACE;
         iFunction =   2;
         break;
      case 3:
         sText =       "Show me all "+SUBRACE_WHEN_NOUN+"s, which has the same base race as my character.";
         iCall =       CONV_LIST_RACES;
         iParams =     CONV_READ_RACE;
         iFunction =   1;
         break;
      case 4:
         sText =       "Show me all "+SUBRACE_WHEN_NOUN+"s...";
         iCall =       CONV_LIST_RACES;
         iParams =     CONV_READ_RACE;
         iFunction =   0;
         break;
      case 5:
         sText =       "Reload my "+SUBRACE_WHEN_NOUN+". (May fix misc. such as wrong appearence)";
         iCall =       CONV_DO_FUNCTION;
         iFunction =   FUNCTION_RELOAD_SUBRACE;
         break;
      case 6:
         sText =        "Save my character.";
         iCall =        CONV_DO_FUNCTION;
         iFunction =    FUNCTION_SAVE_CHARACTER;
         iParams =      2;
         break;
      case 7:
        if( ( swand_PlayerIsAllowedToChangeSubrace(oMySpeaker) && (SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_PORT_TO_START_LOCATION & swand_ChooserSettings)) )
            {
            sText = "I do not wish a "+SUBRACE_WHEN_NOUN+", please port me to the start location for "+SUBRACE_WHEN_NOUN+"less players";
            iCall = CONV_DO_FUNCTION;
            iFunction = FUNCTION_SEND_TO_SUBRACE_START_LOCATION;
            }
        break;
      case 8:
        if(SWAND_CHOOSER_START_LOCATION_PORTAL & swand_ChooserSettings )
            {
            sText = "Send me to my start location.";
            iCall = CONV_DO_FUNCTION;
            iFunction = FUNCTION_SEND_TO_SUBRACE_START_LOCATION;
            }
        break;
      default:
         nCurrent = 0;
         iFunction = 0;
         break;

   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iParams);

   return nCurrent;
}


int swand_conv_ReadRaces_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{
   string sText = "";
   int iCall = 0;
   int iCallParams = iParams&PARAMS_PAGE_FILTER_OUT;


   switch(nCurrent)
   {
      case 0:
         iCall =       0;
         sText =       OutputFullSubraceInformation(iParams & PARAMS_PAGE_FILTER_OUT,
                                                    iParams &~PARAMS_PAGE_FILTER_OUT);
         break;
      case 1:
      if(swand_PlayerIsAllowedToChangeSubrace(oMySpeaker) )
        {
         sText =       "I want this to be my new "+SUBRACE_WHEN_NOUN+".";
         iCall =       CONV_MATCH;
        }
         break;
      case 3:
         sText =       "Show Temp. Stat information";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_1;
         break;
      case 4:
         sText =       "Show Base Stat information (Leto)";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_2;
         break;
      case 5:
         sText =       "Estimate my stats with this "+SUBRACE_WHEN_NOUN;
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_3;
         break;
      case 6:
         sText =       "Show the "+SUBRACE_WHEN_NOUN+"'s item restrictions";
         iCall =       CONV_READ_RACE;
         iCallParams |=PARAMS_PAGE_4;
         break;
      case 7:
         sText =       "Back to "+SUBRACE_WHEN_NOUN+" list";
         iCall =       CONV_LIST_RACES;
         iCallParams = CONV_READ_RACE;
         break;
      case 8:
         sText =       ColourString("Back to Main Menu");
         iCall =       CONV_START;
         break;
      default:
            nCurrent = 0;
         break;

   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);

   return nCurrent;
}

int swand_conv_Match_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iCallParams = iParams;

   switch(nCurrent)
   {
      case 0:
          sText = GetTestMatch(oMySpeaker, iParams );
          break;
      case 1:
          iFunction = CheckIfPCGetsAnyErrorsWithSubraceTest(oMySpeaker, iParams);
            if(!iFunction)
                {
                sText = "I wish to obtain this "+SUBRACE_WHEN_NOUN+".";
                iCall = CONV_CONFIRM_SUBRACE_CHANGE;
                }
              else
                {
                  iCall=0;
                  while(iFunction )
                    {
                    iCall += iFunction&FLAG1;
                    iFunction>>=1;
                    }
                sText = "There " + ((iCall!=1)?"were "+ IntToString(iCall) + " mismatches":"was a mismatch") + "."+
                "\nYou cannot change into this "+SUBRACE_WHEN_NOUN+", if you do not meet the requirements for it.";
                iCall=0;
                }
          iFunction = 0;
          break;

      case 7:
          sText = "Select a different "+SUBRACE_WHEN_NOUN;
          iCall = CONV_LIST_RACES;
          iCallParams = CONV_MATCH;
          break;
      case 8:
          sText =     ColourString("Back to Main Menu");
          iCall =     CONV_START;
          break;
      default:
            nCurrent = 0;
            break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);
   return nCurrent;
}

int swand_conv_ConfirmSubraceChange_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0)
{

   string sText = "";
   int iCall = 0;
   int iCallParams = iParams;


   switch(nCurrent)
   {
      case 0:
          if(!GetLocalInt(GetMyTarget(), SWAND_PREFIX + SWAND_CHANGE_SUBRACE))
          {
              sText = "You are about to "+ ( (iParams!=-1)?
                            ColourString("change ", COLOUR_YELLOW) + ColourString("your") + " "+SUBRACE_WHEN_NOUN+" to " + ColourString(CapitalizeString( GetLocalString(oStorer, MODULE_SUBRACE_NUMBER + IntToString(iParams)) ), COLOUR_LBLUE )
                            :
                            ColourString("remove ", COLOUR_RED)+ ColourString("your") + " "+SUBRACE_WHEN_NOUN);
                            SetMyTarget(oMySpeaker);
          }
          else
          {
               sText = "Your "+SUBRACE_WHEN_NOUN+" has been changed.";
          }
          break;
      case 1:
          if(!GetLocalInt(GetMyTarget(), SWAND_PREFIX + SWAND_CHANGE_SUBRACE))
          {
              sText = "Proceed with the change.";
              iCall = CONV_DO_FUNCTION;
              iFunction = FUNCTION_CHANGE_SUBRACE;
          }
          else
          {
              nCurrent = 0;
          }
          break;
      case 7:
          sText = "Select a different "+SUBRACE_WHEN_NOUN;
          iCall = CONV_LIST_RACES;
          iCallParams = CONV_MATCH;
          break;
      case 8:
          sText =     ColourString("Back to Main Menu");
          iCall =     CONV_START;
          break;
      default:
            nCurrent = 0;
            break;
   }

   swand_BuildChoice(nChoice, sText, iCall, iFunction, iCallParams);
   return nCurrent;
}

void SetChooserStartMenu(int Conversation, int SpecialParameter=FALSE, int SpecialFunction=FALSE, int OneTime=FALSE, object Chooser=OBJECT_SELF)
{
if(OneTime)
    {
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_START_ONE_TIME, Conversation);
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_PARAM_ONE_TIME, SpecialParameter);
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_FUNC_ONE_TIME, SpecialFunction);
    }
  else
    {
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_START, Conversation);
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_PARAM, SpecialParameter);
    SetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_FUNC, SpecialFunction);
    }
}

int GetLocalOneTimeInt(object oObject, string sVarName)
{
int Value = GetLocalInt(oObject, sVarName);
if(Value)
    {
    DeleteLocalInt(oObject, sVarName);
    }
return Value;
}
int GetChooserStartMenu(object Chooser=OBJECT_SELF)
{
int Value = GetLocalOneTimeInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_START_ONE_TIME);
if(!Value)
    {
    Value = GetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_START);
    }
return Value;
}

int GetChooserStartFunction(object Chooser=OBJECT_SELF)
{
int Value = GetLocalOneTimeInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_FUNC_ONE_TIME);
if(!Value)
    {
    Value = GetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_FUNC);
    }
return Value;
}

int GetChooserStartParameter(object Chooser=OBJECT_SELF)
{
int Value = GetLocalOneTimeInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_PARAM_ONE_TIME);
if(!Value)
    {
    Value = GetLocalInt(Chooser, SWAND_PREFIX + SWAND_CHOOSER_PARAM);
    }
return Value;
}

void swand_StartConversation()
{
   if(! GetIsObjectValid(oMySpeaker))
   {
      return;
   }
   object oTarget = GetItemActivatedTarget();
   object Chooser = GetIsPC(OBJECT_SELF)?GetModule():OBJECT_SELF;
   if(!GetUserPermissionsForSWand(oMySpeaker))
   {
   SetMyTarget(oMySpeaker);
   }
   else if( GetIsPC( oTarget ) && !GetIsDM(oTarget) )
   {
        SetMyTarget(oTarget);
   }
   int iConv = GetChooserStartMenu(Chooser);
   if(!iConv) iConv = CONV_START;
   swand_BuildConversation(iConv, GetChooserStartParameter(Chooser), GetChooserStartFunction(Chooser));
}


void swand_RemoveChoice(int Choice)
{
string sChoice=IntToString(Choice);
DeleteLocalString(oMySpeaker, "swand_dialog" + sChoice);
DeleteLocalInt(oMySpeaker, "swand_call" + sChoice);
DeleteLocalInt(oMySpeaker, "swand_params" + sChoice);
DeleteLocalInt(oMySpeaker, "swand_function" + sChoice);
DeleteLocalInt(oMySpeaker, "swand_menu" + sChoice);
}

void swand_BuildChoice(int Choice, string Text, int Conversation, int Function=0, int Params=0, int MenuOptions=0)
{
string sChoice=IntToString(Choice);
SetLocalString(oMySpeaker, "swand_dialog"+sChoice, Text);
SetLocalInt(oMySpeaker, "swand_call"+sChoice, Conversation);
SetLocalInt(oMySpeaker, "swand_function"+sChoice, Function);
SetLocalInt(oMySpeaker, "swand_params"+sChoice, Params);
SetLocalInt(oMySpeaker, "swand_menu"+sChoice, MenuOptions);
}

void swand_DoDialogChoice(int nChoice)
{
   swandScriptInit();
   int iCall = GetLocalInt(oMySpeaker, "swand_call" + IntToString(nChoice));
   int iFunction = GetLocalInt(oMySpeaker, "swand_function"+IntToString(nChoice));
   int iCallParams = GetLocalInt(oMySpeaker, "swand_params"+IntToString(nChoice));

   int iMenu = GetLocalInt(oMySpeaker, "swand_menu"+IntToString(nChoice) );
   ActionPauseConversation();
   int i;
   object oTarget;
    if(iCall & CONV_DO_FUNCTION)
        {
        iCall &= ~CONV_DO_FUNCTION;
        switch(iFunction)
            {
            case FUNCTION_DO_RESET:
                Reset();
                break;
            case FUNCTION_BUILD_CACHE:
                swand_BuildCache();
                break;
            case FUNCTION_CACHE_2_TARGET:
                SetMyTarget(GetLocalObject(oMySpeaker,
                                "swand_object_cache" +
                                IntToString( iCallParams )
                                ) );
                DelayCommand(1.0, swand_CleanCache());
                break;
            case FUNCTION_OPEN_SCHOOSER:
                oTarget = GetMyTarget();
                if(!GetIsInCombat(oTarget) && GetCommandable(oTarget))
                    {
                    SHA_SendSubraceMessageToPC(oTarget, "Bringing up the SChooser interface!");
                    DelayCommand(1.0, AssignCommand(oTarget, ClearAllActions()));
                    DelayCommand(1.0, AssignCommand(oTarget, ActionStartConversation(oTarget, "swand", FALSE, FALSE) ));
                    SHA_SendSubraceMessageToPC(oMySpeaker, "No errors detected, bringing up SChooser.");
                    }
                  else
                    {
                    SHA_SendSubraceMessageToPC(oMySpeaker, "Failed, " + GetName(oTarget) + " is unable to start a conversation");
                    }
                break;
            case FUNCTION_CHANGE_SUBRACE:
                SHA_SendSubraceMessageToPC(oMySpeaker, "Switching the player's "+SUBRACE_WHEN_NOUN+"... please wait.");
                ChangeSubrace(GetMyTarget(), iCallParams);
                iCall = CONV_START;
                break;
            case FUNCTION_DO_DISABLE_ENGINE:
                i = !GetIsSSEDisabledInArea(GetArea(oMySpeaker));
                SetLocalInt(GetArea(oMySpeaker), "DISABLE_SUBRACE_ENGINE", i);
                break;
            case FUNCTION_DO_SHUTDOWN_ENGINE:
                i = !GetIsSSEDisabled();
                SetLocalInt(GetModule(), "SHUTDOWN_SSE", i);
                i?ShutdownSSE():StartSSE();
                SHA_SendSubraceMessageToPC(oMySpeaker, "Switching the SSE " + (i?"Off":"On") + ".");
                break;
            case FUNCTION_SAVE_CHARACTER:
                SaveCharacter(iCallParams, GetMyTarget() );
                break;
            case FUNCTION_RELOAD_SUBRACE:
                ReapplySubraceAbilities(GetMyTarget() );
                break;
            case FUNCTION_SEND_TO_SUBRACE_START_LOCATION:
                oTarget = GetMyTarget();
                if( (!GetIsObjectValid(oTarget)) && (!GetIsDM(oMySpeaker)) )
                    {
                    oTarget = oMySpeaker;
                    }
                SWandSendPlayerToSubraceStartLocation(oTarget, GetSubRace(oTarget));
                break;
            }
        }


    swand_BuildConversation( iCall & CONV_REMOVE_PARAM , iCallParams, iFunction, iMenu);
    ActionResumeConversation();

}

