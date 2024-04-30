// :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
// :::::::::::::::::::::::::: Extension: SWand :::::::::::::::::::::::::::::::::
// ::::::::::::Contact: http://p2.forumforfree.com/shayan.html::::::::::::::::::
// ::::
// :::: Written by: DM_Moon
// ::
// :: Description: Subrace Conversation used in SSE's SWand system.
// ::
#include "sha_subr_methds"

//::--------------------------------------------------------------------------::
//-------------------------- SWAND USER CONSTANTS ------------------------------
//::::::::---------------------------------------------------------:::::::::::::

//  Enable Debugging for SWand.
//  In Single Player Modules, the PC will be able to use SWand as if he was a DM.
//  Otherwise it can be used to produce more verbose output.
//  (Note, during Multiplayer, the host *may* be able to use SWand as if he was a
//      DM.)
const int SWAND_DEBUG = TRUE;

//  Determine how much info should be displayed about the players.
//  1  [or 0x1] - Display Login
//  2  [or 0x2] - Display CD-key
//  4  [or 0x4] - Display IP
//  8  [or 0x8] - Display Location (Area)
//  15 [or 0xf] - All of the above.
//  Can be mixed (e.g. 9 [or 0x9] will give both Login and area and 12 [or 0xc] will give IP and location)
const int SWAND_PLAYER_INFO = 0x9;

// :: This constant allows you to restrict the DMs ability to receive information from
// :: Leto. Depending on the value you can choose to restrict more or less information:
// ::  0 = No Information at all.
// ::  1 = Server PassWord is hidden. (Portal)
// ::  2 = No Restrictions.
const int SWAND_RESTRICT_LETO = 2;


// :: SWand Choosers can be set to  allow a low level player to obtain a subrace
// :: under the following conditions:
// :: A) You explictly in the script state it.
// :: B) They do not already have a (valid) SSE subrace.
// :: C) Their level is equal or lower than the value of this constant
// ::
//
// :: You can disable this options by either disallowing each chooser you make from doing it
// :: OR by setting this constant to FALSE.
//
// :: Since some Servers give starting XP to new players, SWand will NOT calculate the level from XP
// :: Therefore a Level 1 character with 3000 XP (enough to level to level 3) will be considered a level 1!
// :: SSE will consider such a character for a level 3.
//
// :: Set this to the highest level allowed for players to change their subrace.
// :: OR to FALSE to disable players all together from gaining subraces from choosers.
const int SWAND_LOW_LEVEL_SUBRACE_CHANGE = 1;

/*******************************************************************************
*************************** SWAND ENGINE CONSTANTS *****************************
*******************************************************************************/

const string SWAND_VERSION = "1.05";

// Engine const for the Wand
const string SWAND_PREFIX = "SWAND_";
const string SWAND_TARGET = "TARGETED_OBJECT";
const string SWAND_SPECIAL_START = "SPEC_CONVO_EVENT";
const string SWAND_CHANGE_SUBRACE = "SWAND_SUBRACE_CHANGE";
const string SWAND_LETO_TEST = "LETO";
const string SWAND_SPECIAL_USERS = "SPECIAL_USER";
const string SWAND_CONVO_STATUS = "STATUS";

//Custom Token number.
int SWAND_START_CUSTOM_TOKEN = 8110;

const int SWAND_PLAYER_INFO_LOGIN = 0x1;
const int SWAND_PLAYER_INFO_CD_KEY = 0x2;
const int SWAND_PLAYER_INFO_IP = 0x4;
const int SWAND_PLAYER_INFO_LOCATION = 0x8;

const int SWAND_LETO_NOT_ENABLED = -2;
const int SWAND_LETO_NOT_DETECTED = -1;
const int SWAND_LETO_UNTESTED = 0;
const int SWAND_LETO_DETECTED = 1;

//Conversation Consts
const int CONV_START = 1;
const int CONV_SELECT_NEW_TARGET = 2;
const int CONV_LIST_OBJECTS = 3;

const int CONV_LIST_RACES = 4;
const int CONV_READ_RACE = 5;

const int CONV_CACHED_OBJECT_LIST = 11;
const int CONV_REASON = 12;
const int CONV_WORK_TARGET = 14;
const int CONV_MATCH = 15;
const int CONV_TEST_LETO = 16;
const int CONV_CONFIRM_SUBRACE_CHANGE = 17;

const int CONV_DO_FUNCTION = 0x80000000;
const int CONV_REMOVE_PARAM = 0x000000FF;

//MENU const
const int MENU_NEXT = 0x00000001;
const int MENU_PREV = 0x00000002;

//PARAM/FUNCTION const
const int FUNCTION_DO_RESET = 0x00010000;
const int FUNCTION_BUILD_CACHE = 0x00020000;
const int FUNCTION_CACHE_2_TARGET = 0x00040000;
const int FUNCTION_CHANGE_SUBRACE = 0x00080000;
const int FUNCTION_DO_DISABLE_ENGINE = 0x00100000;
const int FUNCTION_DO_SHUTDOWN_ENGINE =0x00200000;
const int FUNCTION_RELOAD_SUBRACE = 0x00400000;
const int FUNCTION_SAVE_CHARACTER = 0x00800000;
const int FUNCTION_SEND_TO_SUBRACE_START_LOCATION = 0x01000000;
const int FUNCTION_OPEN_SCHOOSER = 0x02000000;

const int FUNCTION_LIST_SUBRACE_BASE_RACES = 1;
const int FUNCTION_LIST_SUBRACE_MATCH_TARGET = 2;
const int FUNCTION_LIST_SUBRACE_ALL = 0;

const int PARAMS_PAGE_0 = 0x00000000;
const int PARAMS_PAGE_1 = 0x10000000;
const int PARAMS_PAGE_2 = 0x20000000;
const int PARAMS_PAGE_3 = 0x30000000;
const int PARAMS_PAGE_4 = 0x40000000;
const int PARAMS_PAGE_5 = 0x50000000;
const int PARAMS_PAGE_FILTER_OUT = 0x0FFFFFFF;


const int SWAND_MESSAGE_RECEIVER_PC_ONLY = 0x1;
const int SWAND_MESSAGE_RECEIVER_DM_ONLY = 0x2;
const int SWAND_MESSAGE_RECEIVER_PC_AND_DM = 0x3;


const int SWAND_PERMISSION_PLAYER = 1;
const int SWAND_PERMISSION_DM = 2;
const int SWAND_PERMISSION_ADMIN = 3;
const int SWAND_PERMISSION_GET_PERMISSION = 0;

const int SWAND_CHOOSER_IS_CHOOSER = 0x00000001;
const int SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_TAKE_SUBRACE = 0x00000002;
const int SWAND_CHOOSER_ALLOW_SUBRACELESS_TO_PORT_TO_START_LOCATION = 0x00000004;
const int SWAND_CHOOSER_PORT_TO_SUBRACE_START_LOCATION_END_SUBRACE_MODIFICATION = 0x00000008;
const int SWAND_CHOOSER_START_LOCATION_PORTAL = 0x00000010;

const string SWAND_CHOOSER_SETTINGS = "CHOOSER";

const string SWAND_CHOOSER_START = "SPEC_START";
const string SWAND_CHOOSER_START_ONE_TIME = "SPEC_START_ONE_TIME";
const string SWAND_CHOOSER_PARAM = "SPEC_START_PARAM";
const string SWAND_CHOOSER_PARAM_ONE_TIME = "SPEC_START_PARAM_ONE_TIME";
const string SWAND_CHOOSER_FUNC = "SPEC_START_FUNC";
const string SWAND_CHOOSER_FUNC_ONE_TIME = "SPEC_START_FUNC_ONE_TIME";

const int SWAND_CONVO_RUNNING=1;
const int SWAND_CONVO_ABORT=4;
const int SWAND_CONVO_CLOSE=2;
const int SWAND_CONVO_UPDATE=3;


//Conversation Header.
int swand_conv_Start_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_Start_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ListObjects(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ListRaces(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ReadRaces_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ReadRaces_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_WorkWithTarget(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_Match_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_Match_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_LetoTest(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ConfirmSubraceChange_DM(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);
int swand_conv_ConfirmSubraceChange_PC(int nCurrent, int nChoice, int iParams = 0, int iFunction = 0);

//The Speaker (DM, PC whatever) The NPC (if any) is OBJECT_SELF
object oMySpeaker = GetPCSpeaker();

//swand global Status var
int sw_gl_Status=0;
//swand global Status Permission var
int sw_gl_Permission=0;

//returns the current selected target.
object GetMyTarget();

int GetConversationStatus(object Player);
void SetConversationStatus(object Player, int Status);
void ResetConversationStatus(object Player);

//Sets the current target to oTarget.
void SetMyTarget(object oTarget);

//returns Character Name, Login and Location (by Area) on oTarget. (Use on PC)
string GetInfoCurrentTarget(object oTarget);

//Ports a player to his/her starting location
//If his/her subrace does not have a starting location or the player is subraceless
//  The chooser's default "start location" will be used (Chooser = OBJECT_SELF)
//  If no such could be found the player will appear at the starting location of the module.
void SWandSendPlayerToSubraceStartLocation(object Player, string Subrace);

void SendServerWideMessage(string sMessage, int MessageReceiver=SWAND_MESSAGE_RECEIVER_PC_AND_DM, int Important=FALSE);

//Used to determine the permissions of oPC.
//Returns TRUE if oPC has the required Permissions.
//if Permissions is SWAND_PERMISSION_GET_PERMISSION, then this will return the
//  user's highest permission (e.g. SWAND_PERMISSION_DM for DMs)
//IsBetterAllowed determines if a better permission than required is acceptable.
int GetUserPermissionsForSWand(object oPC, int Permissions=SWAND_PERMISSION_DM, int IsBetterAllowed=TRUE);

int GetSWandChooserSettings(object Chooser=OBJECT_SELF);

//input an ABILITY_* const to get its name in a string
//if ShortName is TRUE, then it will (e.g.) return "STR" rather than "Strength"
string GetAbilityScoreName(int Ability, int ShortName=FALSE);


//Prints the name of the Movement speed.
//returns "" if speed is FALSE (PC speed) or if no speed could be found with that ID.
string movementspeed(int iSpeed);

//Will print the item restrictions based on the subrace tag.
string PrintSubraceItemRestrictions(string SubraceStorage);

//FloatToInt just gets rid of the decimal places.. and doesnt actually round up or down.
//IE: FloatToInt(2.67) returns 2
//This function will rightfully return 3.
int RoundOffToNearestInt(float fNum);

//Remove/Clean up Conversation choice
void swand_RemoveChoice(int Choice);

//Create a Conversation choice/line
// Choice 0 is the NPC line.
void swand_BuildChoice(int Choice, string Text, int Conversation, int Function=0, int Params=0, int MenuOptions=0);

//Use this on an NPC you wish to make a Subrace Chooser. (preferabily as a part of OnSpawn)
//This function allows you to modulate the chooser's behaviour.
//
//  WaypointTagForTheSubraceless is the tag of the waypoint to port players with no subrace too.
//      In case a given subrace does not have a "StartLocation", it will be treated as "Subraceless"
//      If no valid waypoint can be found, it will send them to the Start location of the module.
//
//  AllowSubracelessPlayersToTakeASubrace will - if TRUE - allow players without a VALID SSE subrace
//      to take a subrace REGARDLESS of SWAND_RESTRICT_SUBRACE_MODIFICATION settings.
//      This is allowed for players with Level (not XP enough to level) equal or less than SWAND_LOW_LEVEL_SUBRACE_CHANGE
//
//  AllowSubracelessPlayersPortToStart will (if enabled) allow players to say "I do not wish a subrace" and
//      then let SWand's Chooser port them to the Subraceless Start location. (depends on AllowSubracelessPlayers
//          or CanBeUsedSubraceStartLocationPortal)
//
//if TRUE PortOnSubraceModification will make players that changes or removes their subrace, port to their new start location.
//
//  CanBeUsedSubraceStartLocationPortal will allow players to use this NPC as a mean to jump to (their subrace) start location (free of charge).
//
//NOTE: If you want players to use SChoosers from items (like DMs can use SWand) set their permissions up by setting Chooser to GetModule()
//  IT IS NOT ADVICED TO SET CanBeUsedSubraceStartLocationPortal TO TRUE IN SUCH CASES!
void SetSWandChooserSettings(string WaypointTagForTheSubraceless="", int AllowSubracelessPlayersToTakeASubrace=TRUE, int AllowSubracelessPlayersPortToStart=TRUE, int CanBeUsedSubraceStartLocationPortal=FALSE, int PortOnSubraceModification=TRUE, object Chooser=OBJECT_SELF);

//Internal Data-to-print translation.
string ClassFlagToString(int iFlag);
//Internal Data-to-print translation.
string GetAlignmentByFlagNumber(int iNumber);
//Internal Data-to-print translation.
string GetRaceByFlagNumber(int iNumber);
//Internal Data-to-print translation.
string GetAreaTypeByFlagNumber(int iNumber);

//Internal colour chooser for GetTestMatch
string GetClearenceColour(object oTarget, int iReq, int iParam, int iCode=0, int iSubCode=0);

//Returns the SWand Chooser's Settings.
//Verbose will cause it to print the waypoint tag and test if it exists.
//PrintNonChooserMessage will cause it to return "This is not a Subrace Chooser!" rather than "" if the object is not a chooser.
string PrintSWandChooserSettings(int Verbose=FALSE, int PRMessage=FALSE, object Chooser=OBJECT_SELF);

//Test if Player is allowed to change (not remove) subrace.
int swand_PlayerIsAllowedToChangeSubrace(object Player);

int swand_ChooserSettings = GetSWandChooserSettings(GetIsPC(OBJECT_SELF)?GetModule():OBJECT_SELF);

//Saves either all or just a given character.
//Single=FALSE -> Saves all characters w. feedback message (None-important Serverwide)
//Single=TRUE  -> Silently Saves the character (oPlayer).
//Single=2     -> Saves oPlayer with a none-important subrace message.
void SaveCharacter(int Single=FALSE, object oPlayer=OBJECT_INVALID);

//Returns the level of o in the Class position of iPos (1 - 3 )
string GetClassAndLevel(int iPos, object o);

//Standard Message handling
//returns the string with the given Prefix:
//MessageType uses the MESSAGE_TYPE_* constants.
string GenerateColorDisplayMessage(int MessageType=0, string Message="");

//Put in RangeMin and RangeMax
int FeatStuff(object oTarget, int RangeMin, int RangeMax);

//returns a little information about the given subrace.
//used for listing subraces.
//For Dialog
string OutputSubraceInformation(int ID);

//returns all information about the given subrace.
//For Dialog
string OutputFullSubraceInformation(int ID, int Page=0);

//returns the req. of subraces coloured by whether or not oTarget
//fulfills them.
//For Dialog
string GetTestMatch(object oTarget, int ID);

//Used to auto-convert the temp. stat modifications into a string.
string TempModTypeToString(float TempStat, int ModifierType);

//Used inside OutputFullSubraceInformation to print all the Stat Modifications.
string PrintSubraceStatModification(string SubraceStorage, int Page);

//SWand's function to test if Leto is responding
//ForceTest forces SWand to call LetoPingPong() and thus update the information.
//  NB: This will make SWand bypass the ENABLE_LETO settings and report if LetoScript is responding.
//  In cases where Leto is Disabled, SWandLetoTest will NOT store the information from LetoScript.
int SWandLetoTest(int ForceTest=FALSE);

//Unlike LETO_GetBicPath, which writes a "LetoScript", this function simply prints the
//  expected LetoPath for a PC.
string LETO_GetBicPath_Wand(object oPC);


//Used by the dodialog scripts to handle the selected choice.
void DoDialogChoice(int nChoice);

//Called on end of conversation to clean up variables.
void swand_EndConversation();

int GetChooserStartParameter(object Chooser=OBJECT_SELF);
int GetChooserStartMenu(object Chooser=OBJECT_SELF);
int GetChooserStartFunction(object Chooser=OBJECT_SELF);
int GetLocalOneTimeInt(object oObject, string sVarName);
void SetChooserStartMenu(int Conversation, int SpecialParameter=FALSE, int SpecialFunction=FALSE, int OneTime=FALSE, object Chooser=OBJECT_SELF);


//Setup a user to get special permissions by his CD-key. Call in OnModuleLoad.
//The CD-key can be obtained by using SWand on the player
//(assuming SWAND_PLAYER_INFO is setup up to that)
void SetupSpecialSWandUser(string Key, int Permissions=SWAND_PERMISSION_DM);

//returns the permissions set for the CD-key
//returns FALSE if no special permissions have been set.
int GetSpecialSWandUserPermissionsByKey(string Key);

//returns the permissions set for the current User (oMySpeaker)
//returns FALSE if no special permissions have been set.
int GetSpecialSWandUserPermissions();

//Turns iInt into a string which is coloured with the selected colours based on its value.
//sPrefix and sSurfix will be added in front and in the back of the integer and will be coloured as well.
//Note, remember to include spaces in sPrefix or sSurfix if you do not want them "sticked" into the number.
//AddSymbol will (if TRUE) cause Positive numbers to be prefixed with "+". 2 will add a minus in front of a adjusted negative. 3 will have both.
//  The symbol will be added between the Prefix and the integer value.
//note, uses ColourString
//AdjustZero can be used to "move" the zero point, so the colours will be decided after the adjustment.
string IntToColourString(int iInt, string sPrefix="", string sSurfix="", int AddSymbol=3, int AdjustZero=0, string sColourNegative=COLOUR_RED, string sColourPositive=COLOUR_GREEN, string sColourZero=COLOUR_WHITE);
