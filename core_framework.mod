MOD V1.0        D   �   �      |   n                                                                                                                           _test               �  chat_c_config      �  chat_i_main        �  chat_l_plugin      �  core_c_config      �  core_i_constants   �  core_i_framework   �  demo_l_plugin      �  dlg_c_dialogs      �  dlg_e_abort     	   �  dlg_e_dialogs   
   �  dlg_e_end          �  dlg_i_dialogs      �  dlg_l_demo         �  dlg_l_plugin       �  dlg_l_tokens       �  hook_nwn           �  hook_spellhook     �  hook_timerhook     �  pqj_i_main         �  pqj_l_plugin       �  target_l_plugin    �  util_c_color       �  util_c_debug       �  util_c_strftime    �  util_c_targeting   �  util_c_unittest    �  util_c_variables   �  util_i_argstack    �  util_i_color       �  util_i_constants   �  util_i_csvlists    �  util_i_datapoint    �  util_i_debug    !   �  util_i_libraries"   �  util_i_library  #   �  util_i_lists    $   �  util_i_matching %   �  util_i_math     &   �  util_i_nss      '   �  util_i_sqlite   (   �  util_i_strftime )   �  util_i_strings  *   �  util_i_targeting+   �  util_i_timers   ,   �  util_i_times    -   �  util_i_unittest .   �  util_i_variables/   �  util_i_varlists 0   �  startingarea    1   �  module          2   �  startingarea    3   �  bw_defaultevents4   �  dlg_demo_poet   5   �  dlg_convnozoom  6   �  dlg_convzoom    7   �  creaturepalcus  8   �  doorpalcus      9   �  encounterpalcus :   �  itempalcus      ;   �  placeablepalcus <   �  soundpalcus     =   �  storepalcus     >   �  triggerpalcus   ?   �  waypointpalcus  @   �  repute          A   �  startingarea    B   �  module          C      	  �  �
  G  @  �  T�  �  %�  U5  z�  N:  �- ��  ��   � �  � �  < v  � �  N" O�  �� SL  �I �   �j �+  b� �s  
 �  � 3  � t  ], \  �2 	  �; �)  �e `  u �  �� g  � �  ��   µ �:  O� �-  , �#  �A z6  _x �  D� 2  [� �I  W
 N  � �  �% n  < �  �M �!   o 9  Y� �  pH �=  I� ��  � �J  �[ џ  �� �3  ^/	 �� �
 �p �;  	  �D �  �K �4  �� �  !� �  � �.  �� �.  L� �  
 �  � �  �   �! ,  �& �  �) �  ~+ l  �. �  �0 a  38 8  k: v  #include "pqj_i_main"
#include "core_i_framework"

void main()
{
    object oPC = GetLastUsedBy();
    int nState = pqj_GetQuestState("test", oPC);
    if (nState > 1)
        pqj_RemoveJournalQuestEntry("test", oPC);
    else
        pqj_AddJournalQuestEntry("test", nState + 1, oPC);

    int nTimer = CreateTimer(oPC, "TestTimer", 6.0f, 4);
    StartTimer(nTimer);
    DelayCommand(12.0, StopTimer(nTimer));
    DelayCommand(24.0, KillTimer(nTimer));
}
// -----------------------------------------------------------------------------
//    File: chat_c_config.nss
//  System: Chat Command System
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// This file contains user-definable toggles and settings for the chat command
// system.
// -----------------------------------------------------------------------------

// Delimiters must be single characters; multiple consecutive delimiters will be
// ignored. If a delimiter is passed that is greater than one character, the
// first character will be used.
const string CHAT_DELIMITER = " ";

// This string contains characters used to designate a chat command. If a chat
// message uses one of these characters as its first character, it will be
// treated as a command. Do not use "-", "=", ":", any characters in
// CHAT_GROUPS below, or any normal alphanumeric characters.
const string CHAT_DESIGNATORS = "!@#$%^&*;,./?`~|\\";

// This string contains pairs of characters used to group words into a single
// parameter. Grouping characters must be paired and, if necessary, escaped.
// Unpaired grouping characters will result in grouping functions being lost and
// error provided in log. Do not use "-", "=", ":", any characters in
// CHAT_COMMAND_DESIGNATORS above, or any normal alphanumeric characters.
const string CHAT_GROUPS = "``{}[]()<>";

// To keep grouping symbols as part of the returned data, set this to FALSE.
const int REMOVE_GROUPING_SYMBOLS = TRUE;

// To force logging of all chat commands, set this to TRUE.
const int LOG_ALL_CHAT_COMMANDS = TRUE;

// To force logging of all chat command results that are not errors, set this to
// TRUE.
const int LOG_ALL_CHAT_RESULTS = TRUE;
// -----------------------------------------------------------------------------
//    File: chat_i_main.nss
//  System: Chat Command System (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------
// This file holds functions and constants used by the Chat Command System. Do
// not edit this file directly. All user-configurable settings are in
// chat_c_config.
// ----- Description -----------------------------------------------------------
// NWN allows players to chat on several channels. Using nwscript, builders can
// intercept these chat messages and perform several functions. This utility
// allows builders to intercept chat messages that are similar to command line
// inputs and parse those messages down to the argument level.
//
// The parsed output will include:
// - The entire original chat line as recieved through GetPCChatMessage()
//   (whitespace trimmed)
// - The command designator (the first character, which usually denotes a
//   special function)
// - The command (the character group attached to the command designator)
// - All long and short non-paired options (--force, -q, etc.)
// - All key:value pairs (--force:true, -q:no, etc.)
//
// ----- Usage -----------------------------------------------------------------
// - The following letters and words are used by the chat system for specific
//   functions and should not be used as option or key names in your chat
//   command scripts.
//   - l|log - message routing
//   - d|dm|dms - message routing
//   - p|party - message routing
//   - target - targeting specific object with command
//
// - This system uses comma-delimited lists, so commas are not allowed in any
//   position in the chat line except the first position (command designator).
//   Commas will be stripped from the chat line when sent through the tokenizer.
//
// - Command designator characters are limited to those characters passed to
//   ParseCommandLine in the sGroup argument. Generally, command designators
//   should be limited to !@#$%^&*;.,/?`~|\. Some characters must be escaped
//   such a `\\`, so including the backslash would look like !@#$%^&*;.,/?`~|\\.
//   See the grouped character note for additional character possibilities.
//
// - The delimiter between tokens must be only one character and defaults to a
//   single space. The system handles multiple consecutive delimiters by
//   ignoring them. The delimiter can be passed to ParseCommandLine through the
//   sDelimiter argument.
//
// - Characters can be grouped with paired grouping symbols such as "", {}, [],
//   <>. These pairs can be passed to ParseCommandLine in the sGroups argument.
//   Grouping symbols must be passed in pairs and certain characters must be
//   escaped, such as \"\" to send two double quotes. The default is \"\"{}[]<>,
//   This allows any characters within groups designated by these characters to
//   be treated as a single token. So, "this is a string" is passed as a single
//   token instead of four different tokens, same as [this is a group], {this is
//   a group} and <this is a group>. If you remove any grouping characters,
//   those characters become available for use as command designators. DMFI uses
//   [ as a command, so if you change the grouping characters to \"\"{}<>, [ and
//   ] become available as command designators. Technically, any two characters
//   can be sent as grouping symbols, but you will run into issues if you use
//   standard alphabetic characters.
//
// - You can opt to return grouped characters with the grouping symbols still
//   attached. For example, if a user enters [one two three], by default, the
//   system will return `one two three` as a single token, however, if you pass
//   the argument nRemoveGroups = FALSE, the system will return `[one two
//   three]` instead.
//
// - Long options should start with "--". The characters following a "--" will
//   be treated as a single option whether one their own (--force) or as part of
//   a pair (--force:false).
//
// - Short options should start with "-". The characters following a "-" will be
//   treated as individual options unless they are part of a part. -kwtuv is
//   equivalent to -k -w -t -u -v, while -k:true will result in one pair set and
//   -kwtuv:true will result in one pair set with key kwtuv.
//
// - Case is never changed in parsing the chat line to prevent errors in NWN,
//   which is almost always case-sensitive
//
// - Pairs can use either : or = to separate key from value. --key:jabra is
//   equivalent to --key=jabra
//
// - Options and keys can be checked against multiple phrases. For example, if
//   you want to allow the user to use i|int|integer when entering and option or
//   key-value pair, you can check for any of these cases with:
//       HasChatOption("i,int,integer") or
//       HasChatKey("i,int,integer")
//   And you can retrive the value of a key value pair the same way:
//       GetChatKeyValue("i,int,integer");
//
// ----- Examples --------------------------------------------------------------
// The following usage examples assume defaults as set in chat_c_config. A
// common use-case would be to allow specific command designators for dms and
// others for players. To accomplish this, set the most common use-case as the
// default and, when a different use-case is required, pass the appropriate
// character string
//
// Example:  Default Usage
//     if (ParseCommandLine(oPC, sChat))
//         ...
//
// Example:  Usage with special designators
//     if (GetIsDM(oPC))
//     {
//         if (ParseCommandLine(oPC, sChat, CHAT_DESIGNATORS + "%^"))
//             ...
//     }
//
// Usage Examples (not checked for compilation errors):
//
// Chat Line -> <designator><command> [options]
// Example   -> !get [options]
// Result -> Routing function
//
// void main()
// {
//     object oPC = GetPCChatSpeaker();
//     string sChat = GetPCChatMessage();
//
//     if (ParseCommandLine(oPC, sChat))
//     {
//         string sDesignator = GetChatDesignator(oPC);
//         string sCommand = GetChatCommand(oPC);
//
//         if (sDesignator == "!")
//         {
//             if (VerifyChatTarget(oPC))  // used as preparatory function for
//             all !-associated command
//             {
//                 if (sCommand == "get")
//                     chat_get(oPC);  // or ExecuteScript("scriptname", oPC);
//                 else if (sCommand == "go"")
//                     chat_go(oPC);
//                 else if (sCommand == "say")
//                     chat_say(oPC);
//                 else if (sCommand == ...)
//                     ...
//                 else
//                     Error("Could not find command '" + sCommand + "'");
//             }
//         }
//     }
// }
//
// Chat Line -> !get x2_duergar02 commoner_001 -k
// Result -> Gets object with designated tags and either gets it or destroys it
//
// void chat_get(object oPC)
// {
//     object o;
//     string sArgument;
//     int n, nCount = CountChatArguments(oPC);
//
//     for (n = 0; n < nCount; n++)
//     {
//         sArgument = GetChatArgument(oPC, n);
//         o = GetObjectByTag(sArgument);
//
//         if (GetIsObjectValid(o))
//         {
//             if (HasChatOption(oPC, "k"))
//                 DestroyObject(o);
//             else
//                 AssignCommand(o, ActionJumpToObject(oPC))
//         }
//     }
// }
//
// Chat Line -> !go StartArea --object:info_sign
// Result -> Send player to the info_sign object in area StartArea
//
// void chat_go(object oPC)
// {
//     object o, oPC = GetPCChatSpeaker();
//
//     string sArea = GetChatArgument(oPC);
//     object oArea = GetObjectByTag(sArea);
//     if (GetIsObjectValid(oArea))
//     {
//         object o = GetFirstObjectInArea(oArea);
//         string sTag = GetChatKeyValue(oPC, "object");
//         if (sTag != "")
//         {
//             object oDest = GetNearestObjectByTag(sTag, o, 1);
//             if (GetIsObjectValid(oDest))
//                 AssignCommand(oPC, ActionJumpToObject(oDest));
//             else
//                 AssignCommand(oPC, ActionJumpToObject(o));
//         }
//     }
//     else
//         Error("Could not find area with tag '" + sArea + "'");
// }
//
// Chat Line -> !say x2_duergar02 --line:"This is what I want to say" --whisper
// Result -> Object with tag x2_duergar02 speaks "This is what I want to say"
//
// void chat_say(object oPC)
// {
//     int nVolume = TALKVOLUME_TALK;
//
//     object o = GetObjectByTag(GetChatArgument(oPC));
//     if (GetIsObjectValid(o))
//     {
//         if (HasChatOption(oPC, "whisper"))
//             nVolume = TALKVOLUME_WHISPER;
//
//         AssignCommand(o, ActionSpeakString(GetChatOption(oPC, "line"),
//         nVolume));
//     }
// }
//
// ----- Sending Feedback To The User ------------------------------------------
// SendChatResult() has been added to allow direct feedback to the user and any
// other pre-defined destination. Feedback will be routed based on three
// criteria:
// - PC enters --[d|dm|dms], --[p|party], or --[l|log] into the command line
// - Admin opts to enable automatically chat command and result logging
// - Scripter opts to send results of specific commands to pc, dms, party and/or
//   log
//
// SendChatResult() accepts four parameters:
// - sMessage (required) -> message to be sent. It should not contain any
//   prefixes or headers, but should be formatted as it will be shown, included
//   string coloring
// - oPC (required) -> the PC that send the chat.
// - nFlag (optional) -> bitmasked integer that will add a prefix for special
//   feedback. Currently only implemented as single options, so | is not usable.
//   - CHAT_FLAG_ERROR -> Adds a red [Error] prefix
//   - CHAT_FLAG_HELP -> Adds an orange [Help] prefix
//   - CHAT_FLAG_INFO -> Adds a cyan [Info] prefix
//   Note: Using any nFlag will cause the returned message to go only to the PC
//   and any other recipients specified by nRecipients or by chat options are
//   ignored
// - nRecipients (optional) -> bitmasked integer that determines which objects
//   will recieve the message.
//   - CHAT_PC -> Only the chatting PC
//   - CHAT_DMS -> All DMS
//   - CHAT_PARTY -> All party members of the chatting PC
//   - CHAT_LOG -> The message will be sent to the server log with a timestamp
//   Note: The above values allow a scripter to always send messages to
//   specified locations and will be in addition to any message routing options
//   in the chat command line
//
// Examples:
//
// Selecting Specific Routing:
//     Command line -> !script <scriptname> [--target:<tag>] --log
//
//     In this command, the user has opted to send the result of the command to
//     himself and the server log. To allow this behavior as written, use a line
//     similar to this:
//
//         SendChatResult("Running script " + sScript, oPC);
//
//     If you want to ensure all DMs are aware of any script behind run through
//     the command system, use this:
//
//         SendChatResult("Running script " + sScript, oPC, FALSE, CHAT_DMS);
//
//     This will result in the message being send to the PC (automatic), the log
//     (optioned by the PC) and all DMs (as flagged by the scripter).
//
// Adding Prefix Flags:
//     If the operation resulted in an error, you can inform the PC and provide
//     help. Using prefix flags will result in only the PC receiving the
//     message, even if the pc or scripter opted for additional message routing.
//     This is meant to prevent spamming DMs, party memebers and the log when
//     the user makes a mistake in the command line.
//
//     To send an error message:
//
//         SendChatResult("Could not run script", oPC, CHAT_FLAG_ERROR);
//
//     To send help with your command:
//
//         SendChatResult(GetScriptHelp(), oPC, CHAT_FLAG_HELP);
//
//     To send random information:
//
//         SendChatResult("Here's some info!", oPC, CHAT_FLAG_INFO)
// -----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_datapoint"
#include "util_i_debug"
#include "util_i_varlists"
#include "chat_c_config"

// Used by calling scripts for various functions
const string CHAT_PREFIX = "CHAT_";

// Used by Tokenizer to return errors
const string TOKEN_INVALID = "TOKEN_INVALID";

// Variables names for saving chat struct to dataobject
const string CHAT_LINE = "CHAT_LINE";
const string CHAT_DESIGNATOR = "CHAT_DESIGNATOR";
const string CHAT_COMMAND = "CHAT_COMMAND";
const string CHAT_ARGUMENTS = "CHAT_ARGUMENTS";
const string CHAT_OPTIONS = "CHAT_OPTIONS";
const string CHAT_PAIRS = "CHAT_PAIRS";
const string CHAT_PREDICATE = "CHAT_PREDICATE";     // 1.0.1
const string CHAT_TOKENS = "CHAT_TOKENS";           // 1.0.1

// Bitwise integers for chat struct components
const int CHAT_ARGUMENT = 0x01;
const int CHAT_OPTION   = 0x02;
const int CHAT_PAIR     = 0x04;

const int CHAT_PC = 0x00;
const int CHAT_DMS = 0x01;
const int CHAT_PARTY = 0x02;
const int CHAT_LOG = 0x04;

const int CHAT_FLAG_NONE = 0x00;
const int CHAT_FLAG_ERROR = 0x01;
const int CHAT_FLAG_HELP = 0x02;
const int CHAT_FLAG_INFO = 0x04;

const int CHAT_TARGET_REVERT = 0x01;
const int CHAT_TARGET_NO_REVERT = 0x02;

struct COMMAND_LINE
{
    string chatLine;
    string cmdChar;
    string cmd;
    string options;
    string pairs;
    string args;
    string predicate;   // 1.0.1
    string tokens;      // 1.0.1
};

// -----------------------------------------------------------------------------
//                          Public Function Prototypes
// -----------------------------------------------------------------------------

// ---< RemoveCharacters >---
// Removes individual sChar characters from sSource. sChar is not a string, but
// a sequence of characters and are analyzed independently. Returns sSource with
// all characters from sChar removed.
string RemoveCharacters(string sSource, string sChar = " ");

// ---< Tokenize >---
// Tokenizes sLine based on sDelimiter. Groups defined by sGroups are kept
// together and if nRemoveGroups, the grouping symbols will be removed from the
// returned value. Tokens are returned as a comma-delimited string, so commas
// are not allowed in any part of the string, including grouped characters.
// Returns TOKEN_INVALID if it can't tokenize sLine. Defaults set in the
// configuration settings above can be overriden on a per-call basis by passing
// the appropriate arguments into this function.
string Tokenize(string sLine, string sDelimiter = CHAT_DELIMITER, string sGroups = CHAT_GROUPS, int nRemoveGroups = REMOVE_GROUPING_SYMBOLS);

// ---< ParseCommandLine >---
// Parses chat line sLine, keeps character groups together as defined by sGroup
// symbols, removes character grouping symbols if nRemoveGroups = TRUE, and
// allows user to pass a specified single-character sDelimiter. Returns TRUE if
// parsing was successful. Passing Defaults set in the configuration settings
// above can be overriden on a per-call basis by passing the appropriate
// arguments into this function.
int ParseCommandLine(object oPC = OBJECT_INVALID, string sLine = "", string sDesignators = CHAT_DESIGNATORS,
                     string sGroups = CHAT_GROUPS, int nRemoveGroups = TRUE, string sDelimiter = CHAT_DELIMITER);

// ---< GetKey >---
// Given a key[:|=]value sPair, returns the key portion.
string GetKey(string sPair);

// ---< GetValue >---
// Given a key[:|=]value pair, returns the value portion.
string GetValue(string sPair);

// ---< FindKey >---
// Given a comma-delimited list of key[:|=] pairs and desired key sKey, returns
// the base 0 index of sKey within the series. If the key does not exist in the
// series, returns -1.
int FindKey(string sPairs, string sKey);

// ---< HasParsedChatCommand >---
// Given a PC object, returns whether a parsed chat command exists.
int HasParsedChatCommand(object oPC);

// ---< GetChat[Line|Designator|Command] >---
// Given a PC object, returns the chat line|designator|command, if they exist in
// the most recent parsed command line.
string GetChatLine(object oPC);
string GetChatDesignator(object oPC);
string GetChatCommand(object oPC);

// ---< CountChat[Arguments|Options|Pairs] >---
// Given a PC object, returns the total number of arguments, options, or pairs
// in the most recent parsed command line.
int CountChatArguments(object oPC);
int CountChatOptions(object oPC);
int CountChatPairs(object oPC);

// ---< HasChat[Argument|Option|Key] >---
// Given a PC object and desired argument|option|key, returns whether that
// argument or key exists in the most recent parsed command line.
int HasChatArgument(object oPC, string sKey);
int HasChatOption(object oPC, string sKey);
int HasChatKey(object oPC, string sKey);

// ---< FindChat[Argument|Option|Key] >---
// Given a PC object and desired argument|option|key, returns the index of that
// argument within the series of arguments. If the argument does not exist,
// returns -1.
int FindChatArgument(object oPC, string sKey);
int FindChatOption(object oPC, string sKey);
int FindChatKey(object oPC, string sKey);

// ---< GetChat[Argument|Option|Pair|Key|Value] >---
// Given a PC object and index, returns the argument|option|pair|key|value at
// that index
string GetChatArgument(object oPC, int nIndex = 0);
string GetChatOption(object oPC, int nIndex = 0);
string GetChatPair(object oPC, int nIndex = 0);
string GetChatKey(object oPC, int nIndex = 0);
string GetChatValue(object oPC, int nIndex = 0);

// ---< GetChat[Arguments|Options|Pairs] >---
// Give a PC object, returns the entire series of arguments|options|pairs
// associated with the most recent parsed command line, if they exist.
string GetChatArguments(object oPC);
string GetChatOptions(object oPC);
string GetChatPairs(object oPC);

// ---< GetChatKeyValue[Int|Float] >---
// Given a PC object and desired key, returns the value associated with that key
// as a string, int or float, if the value exists. Error values for ints return
// 0, and for floats 0.0.
string GetChatKeyValue(object oPC, string sKey);
int GetChatKeyValueInt(object oPC, string sKey);
float GetChatKeyValueFloat(object oPC, string sKey);

// ---< SendChatResultTo >--
// Dispatches chat command results message to destination specified by bitmasked
// nRecipients or as desired by command line input (--dm|party|log|...).
// - sMessage -> message to be passed. String coloring should be accomplished
//   before calling this function
// - oPC -> object of the PC initiating the chat command
// - nFlag -> bitmasked integer that determines a specified prefix for the
//   message:
//   - CHAT_FLAG_ERROR -> prefixes the message with [Error]
//   - CHAT_FLAG_HELP -> prefixes the message with [Help]
//   - CHAT_FLAG_INFO -> prefixes the message with [Info]
// - nRecipients -> bitmasked integers that determines the destination of
//   sMessage
//   - CHAT_DMS -> sends message to all DMs
//   - CHAT_PARTY -> sends message to all party members
//   - CHAT_LOG -> sends message to the server log
// Note: if any value is passed in nFlag, sMessage will ONLY be routed to oPC
void SendChatResult(string sMessage, object oPC, int nFlag = FALSE, int nRecipients = CHAT_PC);

// ---< GetChatTarget >---
// The PC can transfer the requested action by passing a key-value pair with the
// key "target" and the value <tag> of the target object. This function will
// return that value, if it exists. oDefault can be passed as the default object
// if the target is not found.
//
// This function will behave as follows:
// - Chat does not have target pair -> oPC is returned
// - Chat has target pair and target is valid -> target object is returned
// - Chat has target pair and target is invalid:
//   - nRevert == CHAT_TARGET_NO_REVERT -> OBJECT_INVALID is returned
//   - nRevert == CHAT_TARGET_REVERT -> oPC or oDefault (if passed) returned
object GetChatTarget(object oPC, int nRevert = CHAT_TARGET_NO_REVERT, object oDefault = OBJECT_INVALID);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// private - requires util_i_csvlists
string _AddKeyValue(string sPairs, string sAdd)
{
    string sResult, sKey, sNewKey, sPair;
    int n, nIndex, nFound, nCount = CountList(sPairs);

    if ((nIndex = FindSubString(sAdd, ":")) == -1)
        nIndex = FindSubString(sAdd, "=");

    sNewKey = GetSubString(sAdd, 0, nIndex);

    if (!nCount)
        return sAdd;

    for (n = 0; n < nCount; n++)
    {
        sPair = GetListItem(sPairs, n);
        if ((nIndex = FindSubString(sPair, ":")) == -1)
            nIndex = FindSubString(sPair, "=");

        sKey = GetSubString(sPair, 0, nIndex);
        if (sNewKey == sKey)
        {
            sResult = AddListItem(sResult, sAdd);
            nFound = TRUE;
        }
        else
            sResult = AddListItem(sResult, sPair);
    }

    if (!nFound)
        sResult = AddListItem(sResult, sAdd);

    return sResult;
}

// private - requires util_i_strings
int _GetPrecision(string sValue)
{
    sValue = TrimStringRight(sValue, "f");

    int n = FindSubString(sValue, ".", 0);
    if (n > -1)
    {
        if (n == GetStringLength(sValue) - 1)
            n = 1;
        else
            n = GetStringLength(sValue) - n - 1;

        return n;
    }

    return 1;
}

// private - requires util_i_datapoint
object GetChatItem(object oPC)
{
    object CHAT = GetDatapoint("CHAT_DATA");
    string sPC = RemoveCharacters(GetName(oPC));

    object oChat = GetDataItem(CHAT, sPC);

    if (!GetIsObjectValid(oChat))
        oChat = CreateDataItem(CHAT, sPC);

    return oChat;
}

// private - requires util_i_datapoint
void DestroyChatItem(object oPC)
{
    object CHAT = GetDatapoint("CHAT_DATA");
    string sPC = RemoveCharacters(GetName(oPC));
    object oChat = GetDataItem(CHAT, sPC);

    if (GetIsObjectValid(oChat))
        DestroyObject(oChat);
}

// private
void _SaveParsedChatLine(object oPC, struct COMMAND_LINE cl)
{
    object oChat = GetChatItem(oPC);

    SetLocalString(oChat, CHAT_LINE, cl.chatLine);
    SetLocalString(oChat, CHAT_DESIGNATOR, cl.cmdChar);
    SetLocalString(oChat, CHAT_COMMAND, cl.cmd);
    SetLocalString(oChat, CHAT_OPTIONS, cl.options);
    SetLocalString(oChat, CHAT_PAIRS, cl.pairs);
    SetLocalString(oChat, CHAT_ARGUMENTS, cl.args);
    SetLocalString(oChat, CHAT_PREDICATE, cl.predicate);    // 1.0.1
    SetLocalString(oChat, CHAT_TOKENS, cl.tokens);          // 1.0.1
}

// private
struct COMMAND_LINE _GetParsedChatLine(object oPC)
{
    object oChat = GetChatItem(oPC);

    struct COMMAND_LINE cl;
    cl.chatLine = GetLocalString(oChat, CHAT_LINE);
    cl.cmdChar = GetLocalString(oChat, CHAT_DESIGNATOR);
    cl.cmd = GetLocalString(oChat, CHAT_COMMAND);
    cl.options = GetLocalString(oChat, CHAT_OPTIONS);
    cl.pairs = GetLocalString(oChat, CHAT_PAIRS);
    cl.args = GetLocalString(oChat, CHAT_ARGUMENTS);
    cl.predicate = GetLocalString(oChat, CHAT_PREDICATE);   // 1.0.1
    cl.tokens = GetLocalString(oChat, CHAT_TOKENS);         // 1.0.1

    return cl;
}

// private - requires util_i_csvlists
int _CountChatComponent(object oPC, int nComponents)
{
    int nResult;
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENT)
        nResult += CountList(cl.args);

    if (nComponents & CHAT_OPTION)
        nResult += CountList(cl.options);

    if (nComponents & CHAT_PAIR)
        nResult += CountList(cl.pairs);

    return nResult;
}

// private - requires util_i_csvlists, util_i_strings
int _FindChatComponent(object oPC, int nComponents, string sKey)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    sKey = TrimStringLeft(sKey, "-");

    if (nComponents & CHAT_ARGUMENT)
        return FindListItem(cl.args, sKey);

    if (nComponents & CHAT_OPTION)
        return FindListItem(cl.options, sKey);

    if (nComponents & CHAT_PAIR)
        return FindKey(cl.pairs, sKey);

    return -1;
}

// private - requires util_i_csvlists
string _GetChatComponent(object oPC, int nComponents, int nIndex = 0)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENT)
        return GetListItem(cl.args, nIndex);

    if (nComponents & CHAT_OPTION)
        return GetListItem(cl.options, nIndex);

    if (nComponents & CHAT_PAIR)
        return GetListItem(cl.pairs, nIndex);

    return "";
}

// private
string _GetChatComponents(object oPC, int nComponents)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    if (nComponents & CHAT_ARGUMENT)
        return cl.args;

    if (nComponents & CHAT_OPTION)
        return cl.options;

    if (nComponents & CHAT_PAIR)
        return cl.pairs;

    return "";
}

// requires util_i_debug
string RemoveCharacters(string sSource, string sChar = " ")
{
    if (sSource == "" || sChar == "")
        return sSource;

    int n, nSource = GetStringLength(sSource);
    int nChar = GetStringLength(sChar);
    string c, sResult = "";

    for (n = 0; n < nSource; n++)
    {
        c = GetSubString(sSource, n, 1);
        if (FindSubString(sChar, c) == -1)
            sResult += c;
    }

    Debug("RemoveCharacters:" +
          "\n  String received -> " + sSource +
          "\n  String returned -> " + sResult);

    return sResult;
}

// requires util_i_strings, util_i_csvlists, util_i_debug
string Tokenize(string sLine, string sDelimiter = CHAT_DELIMITER, string sGroups = CHAT_GROUPS,
                int nRemoveGroups = REMOVE_GROUPING_SYMBOLS)
{
    int n, nGroup, nOpen, nCount;
    string c, sClose, sToken, sResult, sOriginal = sLine;
    sLine = TrimString(sLine);

    // We're doing atomic analysis, so sDelimiter can only be one character
    if (GetStringLength(sDelimiter) != 1)
    {
        Error("Tokenize: passed sDelimiter must be one character in length" +
              "\n  sDelimiter -> '" + sDelimiter + "'" +
              "\n  length     -> " + IntToString(GetStringLength(sDelimiter)));
        return TOKEN_INVALID;
    }

    // If only one token, return it
    if (FindSubString(sLine, sDelimiter, 0) == -1)
        return sLine;

    // Commas not allowed
    sLine = RemoveCharacters(sLine, ",");

    nCount = GetStringLength(sLine);
    for (n = 0; n < nCount; n++)
    {
        // Analyze by character
        c = GetSubString(sLine, n, 1);

        if (nGroup && c == sClose)
        {
            // Handle group closures, add character if keeping group identifiers
            if (!nRemoveGroups)
                sToken += c;

            nGroup = FALSE;
        }
        else if ((nOpen = FindSubString(sGroups, c, 0)) > -1)
        {
            // Add special handling for grouped characters
            nGroup = TRUE;
            sClose = GetSubString(sGroups, nOpen + 1, 1);

            // If there is no closing character, throw
            if (FindSubString(sLine, sClose, n + 1) == -1)
            {
                Error("Tokenize: group opened without a closure" +
                      "\n  sLine -> " + sOriginal +
                      "\n  Group Opening Character -> " + GetSubString(sGroups, nOpen, 1) +
                      "\n  Position of Unmatched Grouping -> " + IntToString(n) + " (Character #" + IntToString(n + 1) + ")");
                return TOKEN_INVALID;
            }

            // Add character if keeping group identifiers
            if (!nRemoveGroups)
                sToken += c;
        }
        else if (c == sDelimiter && !nGroup)
        {
            // Handle multiple delimiters
            if (GetSubString(sLine, n - 1, 1) != sDelimiter)
            {
                // Add/reset the token when we find a delimiter
                sResult = AddListItem(sResult, sToken);
                sToken = "";
            }
        }
        else
            // No special handling
            sToken += c;

        // If we're at the end of the command line, add the last token
        if (n == nCount - 1)
            sResult = AddListItem(sResult, sToken);
    }

    Debug("Tokenize:" +
          "\n  Chat received -> " + sOriginal +
          "\n  Tokens returned -> " + (GetStringLength(sResult) ? sResult : TOKEN_INVALID));

    return (GetStringLength(sResult) ? sResult : TOKEN_INVALID);
}

// requires util_i_debug, util_i_strings, util_i_csvlists
int ParseCommandLine(object oPC = OBJECT_INVALID, string sLine = "", string sDesignators = CHAT_DESIGNATORS,
                     string sGroups = CHAT_GROUPS, int nRemoveGroups = TRUE, string sDelimiter = CHAT_DELIMITER)
{
    // Check for valid inputs
    int nLen;
    string sDebug, sError, sMessage;
    if ((nLen = GetStringLength(sDelimiter)) != 1)
    {
        sMessage = "sDelimiter limited to one character; received " + IntToString(nLen) + ".";
        if (nLen > 0)
            sDelimiter = GetStringLeft(sDelimiter, 1);
        else
            sDelimiter = " ";

        sDebug += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }

    if (!GetStringLength(sGroups))
    {
        sMessage = "Grouping symbols not received; grouped tokens will not be returned.";
        sDebug += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }

    if (GetStringLength(sGroups) % 2)
    {
        sMessage = "Grouping symbols must be paired; received at least one unpaired symbol: " + sGroups +
                   "Character grouping has been disabled for this parsing attempt.";
        sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        sGroups = "";
    }

    if (oPC == OBJECT_INVALID)
    {
        oPC = GetPCChatSpeaker();
        if (!GetIsObjectValid(oPC))
        {
            sMessage = "Unable to determine appropriate target; invalid object " +
                       "received as oPC and GetPCChatSpeaker() returned invalid object.";
            sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        }
    }

    if (sLine == "")
    {
        sLine = GetPCChatMessage();
        if (sLine == "")
        {
            sMessage = "Unable to determine parsing string; empty string " +
                       "received and GetPCChatMessage() returned empty string.";
            sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
        }
    }
    else
        sLine = TrimString(sLine);

    if (!GetStringLength(sDesignators))
    {
        sMessage = "Chat designators not received; unable to parse.";
        sError += (GetStringLength(sError) ? "\n " : "") + sMessage;
    }
    else
        if (FindSubString(sDesignators, GetStringLeft(sLine, 1)) == -1)
            return FALSE;

    if (GetStringLength(sDebug))
        Debug("ParseCommandLine info:\n  " + sDebug);

    if (GetStringLength(sError))
    {
        Error("ParseCommandLine errors:\n  " + sError);
        return FALSE;
    }

    // Do the actual work
    string c, sShortOpts, sToken, sTokens = Tokenize(sLine, sDelimiter, sGroups, nRemoveGroups);
    string sOriginal = sLine;
    int n, nPrefix, nCount = CountList(sTokens);
    struct COMMAND_LINE cl;

    if (!nCount || sTokens == TOKEN_INVALID)
    {
        // No tokens received, send the error and return INVALID
        Error("ParseCommandLine: unable to create COMMAND_LINE struct; no tokens received" +
                "\n  sLine   -> " + sLine +
                "\n  sTokens -> " + sTokens);
        return FALSE;
    }

    sToken = GetListItem(sTokens);
    if (GetStringLength(sToken) > 0)
    {
        cl.chatLine = sOriginal;
        cl.cmdChar = GetStringLeft(sOriginal, 1);
    }

    if (GetStringLength(sToken) > 1)
        cl.cmd = GetSubString(sToken, 1, GetStringLength(sToken));

    sTokens = DeleteListItem(sTokens);
    nCount = CountList(sTokens);

    for (n = 0; n < nCount; n++)
    {
        sToken = GetListItem(sTokens, n);
        if (GetStringLeft(sToken, 2) == "--")
            nPrefix = 2;
        else if (GetStringLeft(sToken, 1) == "-")
        {
            if (FindSubString(sToken, ":") == -1 && FindSubString(sToken, "=") == -1)
            {
                int l, len = GetStringLength(sToken);
                for (l = 1; l < len; l++)
                    sShortOpts = AddListItem(sShortOpts, GetSubString(sToken, l, 1));
            }
            nPrefix = 1;
        }
        else
            nPrefix = 0;

        if (!nPrefix)
            cl.args = AddListItem(cl.args, sToken);
        else if (FindSubString(sToken, ":") != -1 || FindSubString(sToken, "=") != -1)
            cl.pairs = _AddKeyValue(cl.pairs, GetSubString(sToken, nPrefix, GetStringLength(sToken)));
        else
        {
            if (sShortOpts == "")
                cl.options = AddListItem(cl.options, GetSubString(sToken, nPrefix, GetStringLength(sToken)));
            else
                cl.options = MergeLists(cl.options, sShortOpts, TRUE);
        }

        sShortOpts = "";
    }

    // 1.0.1
    sTokens = MergeLists(cl.options, cl.pairs);
    sTokens = MergeLists(sTokens, cl.args);
    cl.tokens = sTokens;
    cl.predicate = TrimString(GetStringRight(cl.chatLine, 
                              GetStringLength(cl.chatLine) - 
                                GetStringLength(cl.cmdChar) -
                                GetStringLength(cl.cmd)));

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        Debug("ParseCommandLine:" +
              "\n  Chat received -> " + sLine +
              "\n  Struct returned:" +
              "\n    Chat Line         -> " + (GetStringLength(cl.chatLine) ? cl.chatLine : "<none>") +
              "\n    Command Character -> " + (GetStringLength(cl.cmdChar) ? cl.cmdChar : "<none>") +
              "\n    Command           -> " + (GetStringLength(cl.cmd) ? cl.cmd : "<none>") +
              "\n    Options           -> " + (GetStringLength(cl.options) ? cl.options : "<none>") +
              "\n    Pairs             -> " + (GetStringLength(cl.pairs) ? cl.pairs : "<none>") +
              "\n    Arguments         -> " + (GetStringLength(cl.args) ? cl.args : "<none>"));

    if (LOG_ALL_CHAT_COMMANDS)
        WriteTimestampedLogEntry("\n" +
                                 "Automatic Log Entry: Chat Command" +
                                 "\n  PC -> " + GetName(oPC) + " in " + GetName(GetArea(oPC)) +
                                 "\n  Line -> " + cl.chatLine);

    _SaveParsedChatLine(oPC, cl);
    return GetStringLength(cl.cmdChar);
}

string GetKey(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, 0, nIndex);
}

string GetValue(string sPair)
{
    int nIndex;

    if ((nIndex = FindSubString(sPair, ":")) == -1)
        nIndex = FindSubString(sPair, "=");

    if (nIndex == -1)
        return sPair;
    else
        return GetSubString(sPair, ++nIndex, GetStringLength(sPair));
}

int FindKey(string sPairs, string sKey)
{
    int n, nCount = CountList(sPairs);
    string sPair;

    for (n = 0; n < nCount; n++)
    {
        sPair = GetListItem(sPairs, n);
        if (sKey == GetKey(sPair))
            return n;
    }

    return -1;
}

// 1.0.1
string GetChatPredicate(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.predicate;
}

// 1.0.1
string GetChatTokens(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.tokens;
}

int HasParsedChatCommand(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmdChar != "";
}

string GetChatLine(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.chatLine;
}

string GetChatDesignator(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmdChar;
}

string GetChatCommand(object oPC)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);
    return cl.cmd;
}

int CountChatArguments(object oPC)
{
    return _CountChatComponent(oPC, CHAT_ARGUMENT);
}

int CountChatOptions(object oPC)
{
    return _CountChatComponent(oPC, CHAT_OPTION);
}

int CountChatPairs(object oPC)
{
    return _CountChatComponent(oPC, CHAT_PAIR);
}

int HasChatArgument(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_ARGUMENT, sKey) > -1;
}

int HasChatOption(object oPC, string sKeys)
{
    string sKey;
    int n, nCount = CountList(sKeys);
    for (n = 0; n < nCount; n++)
    {
        sKey = GetListItem(sKeys, n);
        if (_FindChatComponent(oPC, CHAT_OPTION, sKey) > -1)
            return TRUE;
    }

    return FALSE;
}

int HasChatKey(object oPC, string sKeys)
{
    string sKey;
    int n, nCount = CountList(sKeys);
    for (n = 0; n < nCount; n++)
    {
        sKey = GetListItem(sKeys, n);
        if (_FindChatComponent(oPC, CHAT_PAIR, sKey) > -1)
            return TRUE;
    }

    return FALSE;
}

int FindChatArgument(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_ARGUMENT, sKey);
}

int FindChatOption(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_OPTION, sKey);
}

int FindChatKey(object oPC, string sKey)
{
    return _FindChatComponent(oPC, CHAT_PAIR, sKey);
}

string GetChatArgument(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_ARGUMENT, nIndex);
}

string GetChatOption(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_OPTION, nIndex);
}

string GetChatPair(object oPC, int nIndex = 0)
{
    return _GetChatComponent(oPC, CHAT_PAIR, nIndex);
}

string GetChatKey(object oPC, int nIndex = 0)
{
    return GetKey(_GetChatComponent(oPC, CHAT_PAIR, nIndex));
}

string GetChatValue(object oPC, int nIndex = 0)
{
    return GetValue(_GetChatComponent(oPC, CHAT_PAIR, nIndex));
}

string GetChatArguments(object oPC)
{
    return _GetChatComponents(oPC, CHAT_ARGUMENT);
}

string GetChatOptions(object oPC)
{
    return _GetChatComponents(oPC, CHAT_OPTION);
}

string GetChatPairs(object oPC)
{
    return _GetChatComponents(oPC, CHAT_PAIR);
}

string GetChatKeyValue(object oPC, string sKeys)
{
    struct COMMAND_LINE cl = _GetParsedChatLine(oPC);

    string sKey, sValue;
    int n, nCount = CountList(sKeys);
    for (n = 0; n < nCount; n++)
    {
        sKey = GetListItem(sKeys, n);
        sValue = GetValue(GetListItem(cl.pairs, FindKey(cl.pairs, TrimString(sKey, "-"))));
        if (sValue != "")
            return sValue;
    }

    return "";
}

int GetChatKeyValueInt(object oPC, string sKey)
{
    return StringToInt(GetChatKeyValue(oPC, sKey));
}

float GetChatKeyValueFloat(object oPC, string sKey)
{
    string sValue = GetChatKeyValue(oPC, sKey);
    return StringToFloat(sValue);
}

void SendChatResult(string sMessage, object oPC, int nFlag = FALSE, int nRecipients = CHAT_PC)
{
    string sPrefix;

    if (nFlag & CHAT_FLAG_ERROR)
        sPrefix = HexColorString("[Error] ", COLOR_RED);
    else if (nFlag & CHAT_FLAG_HELP)
        sPrefix = HexColorString("[Help] ", COLOR_ORANGE);
    else if (nFlag & CHAT_FLAG_INFO)
        sPrefix = HexColorString("[Info] ", COLOR_CYAN);

    SendMessageToPC(oPC, (nFlag ? sPrefix : "") + sMessage);

    if (nFlag)
        return;

    if (nRecipients & CHAT_DMS || HasChatOption(oPC, "d,dm,dms"))
    {
        SendMessageToAllDMs(HexColorString("[Chat command system message]" +
                            "\n[Source -> " + GetName(oPC) + " in " + GetName(GetArea(oPC)), COLOR_GRAY_LIGHT) +
                            "\n\n" + sMessage +
                            HexColorString("\n[End chat command message]", COLOR_GRAY_LIGHT));
    }

    if (nRecipients & CHAT_PARTY || HasChatOption(oPC, "p,party"))
    {
        object oParty = GetFirstFactionMember(oPC);
        while (GetIsObjectValid(oParty))
        {
            if (oParty != oPC)
                SendMessageToPC(oParty, HexColorString("[Chat command system message]" +
                                        "\n[Source -> " + GetName(oPC) + " in " + GetName(GetArea(oPC)), COLOR_GRAY_LIGHT) +
                                        "\n\n" + sMessage +
                                        HexColorString("\n[End chat command message]", COLOR_GRAY_LIGHT));

            oParty = GetNextFactionMember(oPC);
        }
    }

    if (nRecipients & CHAT_LOG || LOG_ALL_CHAT_RESULTS || HasChatOption(oPC, "l,log"))
        WriteTimestampedLogEntry("\n" +
                                 (LOG_ALL_CHAT_RESULTS ? "Automatic " : "User Directed ") + "Log Entry: Chat Command Results" +
                                 "\n  PC -> " + GetName(oPC) + " in " + GetName(GetArea(oPC)) +
                                 "\n  Command -> " + GetChatLine(oPC) +
                                 "\n  Result -> " + sMessage);
}

object GetChatTarget(object oPC, int nRevert = CHAT_TARGET_NO_REVERT, object oDefault = OBJECT_INVALID)
{
    object oTarget;
    if (oDefault == OBJECT_INVALID)
        oDefault = oPC;

    if (HasChatKey(oPC, "target"))
    {
        oTarget = GetObjectByTag(GetChatKeyValue(oPC, "target"));
        if (!GetIsObjectValid(oTarget))
        {
            if (nRevert & CHAT_TARGET_REVERT)
            {
                SendChatResult("Cannot find object passed by user; reverting to default" +
                            "\n  Tag received -> " + GetChatKeyValue(oPC, "target"), oPC, CHAT_FLAG_ERROR);
                oTarget = oDefault;
            }
            else
                oTarget = OBJECT_INVALID;
        }
    }
    else
        oTarget = oDefault;

    if (oTarget == OBJECT_INVALID)
        SendChatResult("Unable to determine chat target or target is invalid", oPC, CHAT_FLAG_ERROR);
    else
        SendChatResult("Chat target is " + (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)), oPC, CHAT_FLAG_INFO);

    return oTarget;
}
// -----------------------------------------------------------------------------
//    File: chat_l_plugin.nss
//  System: Chat Command System (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Edward A. Burke (tinygiant) <af.hog.pilot@gmail.com>
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "chat_i_main"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                                 OnPlayerChat
// -----------------------------------------------------------------------------

void chat_OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();
    string sMessage = GetPCChatMessage();

    if (ParseCommandLine(oPC, sMessage))
    {
        SetPCChatMessage();
        string sDesignator = GetChatDesignator(oPC);
        string sCommand = GetChatCommand(oPC);

        int nState = RunEvent(CHAT_PREFIX + sDesignator, oPC);
        if (!(nState & EVENT_STATE_DENIED))
            RunEvent(CHAT_PREFIX + sDesignator + sCommand, oPC);
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("chat"))
    {
        object oPlugin = CreatePlugin("chat");
        SetName(oPlugin, "[Plugin] Chat Command System");
        SetDescription(oPlugin,
            "Allows players and DMs to run commands via the chat bar");
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_CHAT,
            "chat_OnPlayerChat", EVENT_PRIORITY_FIRST);
    }

    RegisterLibraryScript("chat_OnPlayerChat", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: chat_OnPlayerChat(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
/// ----------------------------------------------------------------------------
/// @file   core_c_config.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Core Framework configuration settings.
/// @details
/// This script contains user-definable toggles and settings for the Core
/// Framework. This script is freely editable by the mod builder. All below
/// constants may be overridden, but do not alter the names of the constants.
///
/// Remember: any changes to this file will not be reflected in the module
/// unless you recompile all scripts in which this file is included (however
/// remotely).
///
/// ## Acknowledgment
/// The scripts contained in this package are adapted from those included in
/// Edward Beck's HCR2 and EPOlson's Common Scripting Framework.
/// -----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                   Debugging
// -----------------------------------------------------------------------------

/// This is a maskable setting that controls where debug messages are logged.
/// Any listed destinations will have debug messages sent to them. You can
/// specify multiple levels using | (e.g., DEBUG_LOG_FILE | DEBUG_LOG_DM).
///
/// Possible values:
/// - DEBUG_LOG_NONE: all logging is disabled
/// - DEBUG_LOG_FILE: debug messages are written to the log file
/// - DEBUG_LOG_DM: debug messages are sent to all online DMs
/// - DEBUG_LOG_PC: debug messages are sent to the first online PC
/// - DEBUG_LOG_ALL: debug messages are sent to the log files, DMs, and first PC
int DEBUG_LOGGING = DEBUG_LOG_ALL;

/// This is the level of debug messages to generate. This can be overriden to
/// debug specific objects or events (see below).
///
/// You can override this level on all events using SetDebugLevel(), or on a
/// specific event using SetEventDebugLevel(). These functions can set the level
/// for all objects or for a specific object.
///
/// Alternatively, you can set the value on a specific object in the toolset:
/// - To set the debug level for all events, add a local int named DEBUG_LEVEL
/// - To set the debug level for a single event, add a local int named
///   DEBUG_LEVEL_* and a local int named DEBUG_EVENT_*, where * is the name of
///   the event as defined in core_i_constants.nss.
/// - The value of either of these settings should be a value from 1-5
///   representing one of the DEBUG_LEVEL_* constants below.
///
/// The value that is used is determined as follows:
/// 1. If set, the object-specific debug level for the current event is used.
/// 2. If set, the global debug level for the current event is used. Otherwise...
/// 3. The higher of the global or the object-specific debug level is used.
///
/// This priority system is intended to allow you to reduce the amount of debug
/// calls from verbose events such as heartbeats or OnCreaturePerception, which
/// can make it hard to scan for useful information.
///
/// Possible values:
/// - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
/// - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
/// - DEBUG_LEVEL_WARNING: indicates unexpected behavior may occur
/// - DEBUG_LEVEL_NOTICE: information to track the flow of functions
/// - DEBUG_LEVEL_DEBUG: data dumps used for debugging
const int DEFAULT_DEBUG_LEVEL = DEBUG_LEVEL_ERROR;

/// This controls the level of debug messages to generate on heartbeat events.
/// This can be used to prevent the excessive generation of debug messages that
/// may clutter the log. You may override this on an event-by-event basis using
/// SetEventDebugLevel().
///
/// Possible values:
/// - DEBUG_LEVEL_NONE: use the object or module default level
/// - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
/// - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
/// - DEBUG_LEVEL_WARNING: indicates unexpected behavior may occur
/// - DEBUG_LEVEL_NOTICE: information to track the flow of functions
/// - DEBUG_LEVEL_DEBUG: data dumps used for debugging
const int HEARTBEAT_DEBUG_LEVEL = DEBUG_LEVEL_ERROR;

/// This is the level of debug messages to generate when OnCreaturePerception
/// fires. This can be used to prevent the excessive generation of debug
/// messages that may clutter the log. You may override this on an
/// object-by-object basis using SetEventDebugLevel().
///
/// Possible values:
/// - DEBUG_LEVEL_NONE: use the object or module default level
/// - DEBUG_LEVEL_CRITICAL: errors severe enough to stop the script
/// - DEBUG_LEVEL_ERROR: indicates the script malfunctioned in some way
/// - DEBUG_LEVEL_WARNING: indicates unexpected behavior may occur
/// - DEBUG_LEVEL_NOTICE: information to track the flow of functions
/// - DEBUG_LEVEL_DEBUG: data dumps used for debugging
const int PERCEPTION_DEBUG_LEVEL = DEBUG_LEVEL_ERROR;

/// This is the level of debug messages to generate when the framework is
/// initializing. To prevent excessive logging during initialization, set this
/// to a lower level than DEFAULT_DEBUG_LEVEL above.  Once framework
/// initialization is complete, module debug level will revert to
/// DEFAULT_DEBUG_LEVEL
const int INITIALIZATION_DEBUG_LEVEL = DEBUG_LEVEL_DEBUG;

// -----------------------------------------------------------------------------
//                         Library and Plugin Management
// -----------------------------------------------------------------------------

/// This is a comma-separated list of glob patterns matching libraries that
/// should be automatically loaded when the Core Framework is initialized. The
/// libraries will be loaded in the order of the pattern they matched. Multiple
/// libraries matching the same pattern will be loaded in alphabetical order.
///
/// The following glob syntax is supported:
/// - `*`: match zero or more characters
/// - `?`: match a single character
/// - `[abc]`: match any of a, b, or c
/// - `[a-z]`: match any character from a-z
/// Other text is matched literally, so using exact script names is okay.
const string INSTALLED_LIBRARIES = "*_l_plugin";

/// This is a comma-separated list of plugins that should be activated when the
/// Core Framework is initialized.
const string INSTALLED_PLUGINS = "bw_defaultevents, core_demo, dlg, pqj, chat";

// -----------------------------------------------------------------------------
//                               Event Management
// -----------------------------------------------------------------------------

/// These settings control the order in which event hook-ins run. Event hook-ins
/// get sorted by their priority: a floating point number between 0.0 and 10.0.
/// While you can specify a priority for a hook in the same variable that calls
/// it, you can set a default priority here to avoid having to repeatedly set
/// priorities.
///
/// Event hook-ins are sorted into global and local types:
/// - Global event hook-ins are defined by an installed plugin. They are called
///   whenever a particular event is triggered.
/// - Local event hook-ins are defined on a particular object, such as a
///   creature or placeable, or on the area or persistent object (such as a
///   trigger or AoE) the object is in.
/// By default, local scripts have priority over global scripts. You can change
/// this for all scripts here or set the priorities of scripts in the object
/// variables on a case-by-case basis.

/// This is the default priority for global event hook-in scripts (i.e., on a
/// plugin object) that do not have a priority explicitly set.  It can be a
/// value from 0.0 - 10.0 (where a higher priority = earlier run time). If you
/// set this to a negative number, hook-in scripts with no explicit priority will
/// not run (not recommended).
/// Default value: 5.0
const float GLOBAL_EVENT_PRIORITY = 5.0;

/// This is the default priority for local event hook-in scripts (i.e., set on
/// an object besides a plugin) that do not have a priority explicitly assigned.
/// This can be a value from 0.0 - 10.0 (where a higher priority = earlier run
/// time). If you set this to a negative number, local hook-in scripts with no
/// explicit priority will not run (not recommended). It is recommended that you
/// set this higher than the value of GLOBAL_EVENT_PRIORITY. This ensures local
/// event scripts will run before most globally defined scripts.
/// Default value: 7.0
const float LOCAL_EVENT_PRIORITY = 7.0;

/// This controls whether the Core handles tag-based scripting on its own. If
/// this is TRUE, tag-based scripts will be called as library scripts rather
/// than stand-alone scripts, allowing you to greatly reduce the number of
/// tag-based scripts in the module. If you have traditional tag-based scripts,
/// those will continue to work. The only reason you might want to turn this off
/// is to completely disable tag-based scripting or to use a plugin to call the
/// desired scripts (e.g., make a plugin for the BioWare X2 functions, which
/// handle tag-based scripting on their own).
/// Default value: TRUE
const int ENABLE_TAGBASED_SCRIPTS = TRUE;

/// If TRUE, this will cause all event handlers for the module to be set to
/// "hook_nwn" when the Core Framework is initialized. Any existing event
/// scripts will be set as local event scripts and will still fire when the
/// event is triggered.
const int AUTO_HOOK_MODULE_EVENTS = TRUE;

/// If TRUE, this will cause all event handlers for all areas in the module to
/// be set to "hook_nwn" when the Core Framework is initialized. Any existing
/// event scripts will be set as local event scripts and will still fire when
/// the event is triggered.
/// @note You can skip auto-hooking an individual area by setting a local int
///     named `SKIP_AUTO_HOOK` to TRUE on it.
/// @note Areas spawned by script after the Core Framework is initialized will
///     not have the handlers set.
const int AUTO_HOOK_AREA_EVENTS = TRUE;

/// This controls whether the OnHeartbeat event is hooked when automatically
/// hooking area events during initialization. Has no effect if
/// AUTO_HOOK_AREA_EVENTS is FALSE.
const int AUTO_HOOK_AREA_HEARTBEAT_EVENT = FALSE;

/// This is a bitmasked value matching object types that should have their event
/// handlers changed to "hook_nwn" when the Core Framework is initialized. Any
/// existing event scripts will be set as local event scripts and will still
/// fire when the event is triggered. You can add multiple types using the `|`
/// operator (e.g., OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE). To hook all
/// eligible objects, set this to OBJECT_TYPE_ALL. To disable hooking for all
/// objects, set this to 0.
/// @note You can skip auto-hooking an individual object by setting a local int
///     named `SKIP_AUTO_HOOK` to TRUE on it.
/// @note Objects spawned by script after the Core Framework is initialized will
///     not have the handlers set.
int AUTO_HOOK_OBJECT_EVENTS = OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE;

/// This controls whether the OnHeartbeat event is hooked when automatically
/// hooking objects during initialization. It is a bitmasked value matching the
/// types that should have their heartbeat events hooked. To enable heartbeat
/// hooking for all eligible objects, set this to OBJECT_TYPE_ALL. To disable
/// heartbeat hooking for all objects, set this to 0.
int AUTO_HOOK_OBJECT_HEARTBEAT_EVENT = 0;

/// If TRUE, this will cause all of a PC's event scripts to be set to "hook_nwn"
/// OnClientEnter. Existing event scripts (usually "default") are not preserved.
const int AUTO_HOOK_PC_EVENTS = TRUE;

/// This controls whether the OnHeartbeat event is hooked when automatically
/// hooking PC events OnClientEnter. If AUTO_HOOK_PC_EVENTS is FALSE, this will
/// have no effect.
const int AUTO_HOOK_PC_HEARTBEAT_EVENT = FALSE;

// -----------------------------------------------------------------------------
//                                 Custom Events
// -----------------------------------------------------------------------------

/// This toggles whether to allow the OnHour event. If this is TRUE, the OnHour
/// event will execute each time the hour changes.
const int ENABLE_ON_HOUR_EVENT = TRUE;

/// This toggles whether the OnAreaEmpty event runs. If this is TRUE, the
/// OnAreaEmpty event will run on an area ON_AREA_EMPTY_EVENT_DELAY seconds
/// after the last PC exists the area. This is a good event for area cleanup
/// scripts.
const int ENABLE_ON_AREA_EMPTY_EVENT = TRUE;

/// This is the number of seconds after an area is emptied of players to run the
/// OnAreaEmpty scripts for that area.
/// Default value: 180.0 (3 real-life minutes)
const float ON_AREA_EMPTY_EVENT_DELAY = 180.0;

// -----------------------------------------------------------------------------
//                                 Miscellaneous
// -----------------------------------------------------------------------------

/// This is the script that will run before the framework initializes the first
/// time. An empty string means no script will run.
const string ON_MODULE_PRELOAD = "";

/// When using AOE hook scripts, NPCs can be added to the AOE roster for easier
/// access during scripting. To only allow PC objects on the AOE rosters, set
/// this to FALSE.
const int INCLUDE_NPC_IN_AOE_ROSTER = TRUE;

/// This is the welcome message that will be sent to all players and DMs that
/// log into the module.
const string WELCOME_MESSAGE = "Welcome to the Core Framework.";
/// ----------------------------------------------------------------------------
/// @file   core_i_constants.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Constants commonly used throughout the Core and associated systems.
/// ----------------------------------------------------------------------------

#include "util_i_datapoint"

// -----------------------------------------------------------------------------
//                                  Blueprints
// -----------------------------------------------------------------------------

// Data structures
const string CORE_EVENTS  = "Core Events";
const string CORE_PLUGINS = "Core Plugins";

// Script names
const string CORE_HOOK_NWN    = "hook_nwn";
const string CORE_HOOK_NWNX   = "hook_nwnx";
const string CORE_HOOK_SPELLS = "hook_spellhook";
const string CORE_HOOK_TIMERS = "hook_timerhook";

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

// If these objects do not exist, they will be initialized OnModuleLoad.
object PLUGINS = GetDatapoint(CORE_PLUGINS);
object EVENTS  = GetDatapoint(CORE_EVENTS);

// -----------------------------------------------------------------------------
//                              Framework Variables
// -----------------------------------------------------------------------------

const string CORE_INITIALIZED = "CORE_INITIALIZED";

// Set on an object to prevent auto-hooking during Core initialization.
const string SKIP_AUTO_HOOK   = "SKIP_AUTO_HOOK";

// ----- Plugin Management -----------------------------------------------------

// Local variable names used for plugin objects.
const string PLUGIN_ID          = "*ID";
const string PLUGIN_LIBRARIES   = "*Libraries";
const string PLUGIN_STATUS      = "*Status";

// Acceptable values for the plugin's activation status.
const int PLUGIN_STATUS_MISSING = -1;
const int PLUGIN_STATUS_OFF     =  0;
const int PLUGIN_STATUS_ON      =  1;

// The last plugin to run
const string PLUGIN_LAST = "PLUGIN_LAST";

// ----- Event Management ------------------------------------------------------

// Used to distinguish `EVENT_SCRIPT_*` constants
const int EVENT_TYPE_MODULE        =  3;
const int EVENT_TYPE_AREA          =  4;
const int EVENT_TYPE_CREATURE      =  5;
const int EVENT_TYPE_TRIGGER       =  7;
const int EVENT_TYPE_PLACEABLE     =  9;
const int EVENT_TYPE_DOOR          = 10;
const int EVENT_TYPE_AREAOFEFFECT  = 11;
const int EVENT_TYPE_ENCOUNTER     = 13;
const int EVENT_TYPE_STORE         = 14;

const string EVENT_NAME             = "EVENT_NAME";             // Name of the event the script should run on.
const string EVENT_SOURCE           = "EVENT_SOURCE";           // List of sources for location hooks
const string EVENT_PLUGIN           = "EVENT_PLUGIN";           // List of plugins installed
const string EVENT_CURRENT_PLUGIN   = "EVENT_CURRENT_PLUGIN";   // Name of the plugin owning the current event script
const string EVENT_SOURCE_BLACKLIST = "EVENT_SOURCE_BLACKLIST"; // List of blacklisted plugins or objects
const string EVENT_TRIGGERED        = "EVENT_TRIGGERED";        // The object triggering the event
const string EVENT_LAST             = "EVENT_LAST";             // The last event to run
const string EVENT_DEBUG            = "EVENT_DEBUG";            // The event's debug level

const string EVENT_STATE            = "EVENT_STATE";    // State of the event queue
const int    EVENT_STATE_OK         = 0x00;             // normal (default)
const int    EVENT_STATE_ABORT      = 0x01;             // stops further event queue processing
const int    EVENT_STATE_DENIED     = 0x02;             // request denied

const string EVENT_PRIORITY         = "EVENT_PRIORITY"; // List of event script priorities
const float  EVENT_PRIORITY_FIRST   =   9999.0;         // The script is always first
const float  EVENT_PRIORITY_LAST    =  -9999.0;         // The script is always last
const float  EVENT_PRIORITY_ONLY    =  11111.0;         // The script will be the only one to execute
const float  EVENT_PRIORITY_DEFAULT = -11111.0;         // The script will only execute if no other scripts do

// ----- Timer Management ------------------------------------------------------

const string TIMER_ON_AREA_EMPTY = "TIMER_ON_AREA_EMPTY";   // Timer variable name for OnAreaExit Timer

// ----- Player Management -----------------------------------------------------

const string PC_CD_KEY         = "PC_CD_KEY";
const string PC_PLAYER_NAME    = "PC_PLAYER_NAME";
const string PLAYER_ROSTER     = "PLAYER_ROSTER";
const string DM_ROSTER         = "DM_ROSTER";
const string LOGIN_BOOT        = "LOGIN_BOOT";
const string LOGIN_DEATH       = "LOGIN_DEATH";
const string AREA_ROSTER       = "AREA_ROSTER";
const string AOE_ROSTER        = "AOE_ROSTER";
const string IS_PC             = "IS_PC";
const string IS_DM             = "IS_DM";

// ----- Miscellaneous ---------------------------------------------------------

const string CURRENT_HOUR = "CURRENT_HOUR";

// -----------------------------------------------------------------------------
//                                  Event Names
// -----------------------------------------------------------------------------

// ----- Module Events ---------------------------------------------------------

const string MODULE_EVENT_ON_ACQUIRE_ITEM             = "OnAcquireItem";
const string MODULE_EVENT_ON_ACTIVATE_ITEM            = "OnActivateItem";
const string MODULE_EVENT_ON_CLIENT_ENTER             = "OnClientEnter";
const string MODULE_EVENT_ON_CLIENT_LEAVE             = "OnClientLeave";
const string MODULE_EVENT_ON_CUTSCENE_ABORT           = "OnCutSceneAbort";
const string MODULE_EVENT_ON_HEARTBEAT                = "OnHeartbeat";
const string MODULE_EVENT_ON_MODULE_LOAD              = "OnModuleLoad";
const string MODULE_EVENT_ON_MODULE_START             = "OnModuleStart";
const string MODULE_EVENT_ON_NUI                      = "OnNUI";
const string MODULE_EVENT_ON_PLAYER_CHAT              = "OnPlayerChat";
const string MODULE_EVENT_ON_PLAYER_DEATH             = "OnPlayerDeath";
const string MODULE_EVENT_ON_PLAYER_DYING             = "OnPlayerDying";
const string MODULE_EVENT_ON_PLAYER_EQUIP_ITEM        = "OnPlayerEquipItem";
const string MODULE_EVENT_ON_PLAYER_GUI               = "OnPlayerGUI";
const string MODULE_EVENT_ON_PLAYER_LEVEL_UP          = "OnPlayerLevelUp";
const string MODULE_EVENT_ON_PLAYER_RESPAWN           = "OnPlayerReSpawn";
const string MODULE_EVENT_ON_PLAYER_REST              = "OnPlayerRest";
const string MODULE_EVENT_ON_PLAYER_REST_STARTED      = "OnPlayerRestStarted";
const string MODULE_EVENT_ON_PLAYER_REST_CANCELLED    = "OnPlayerRestCancelled";
const string MODULE_EVENT_ON_PLAYER_REST_FINISHED     = "OnPlayerRestFinished";
const string MODULE_EVENT_ON_PLAYER_TARGET            = "OnPlayerTarget";
const string MODULE_EVENT_ON_PLAYER_TILE_ACTION       = "OnPlayerTileAction";
const string MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM      = "OnPlayerUnEquipItem";
const string MODULE_EVENT_ON_UNACQUIRE_ITEM           = "OnUnAcquireItem";
const string MODULE_EVENT_ON_USER_DEFINED             = "OnUserDefined";

// These are pseudo-events called by the Core Framework
const string MODULE_EVENT_ON_SPELLHOOK                = "OnSpellhook";
const string MODULE_EVENT_ON_HOUR                     = "OnHour";

// ----- Area Events -----------------------------------------------------------

const string AREA_EVENT_ON_ENTER                      = "OnAreaEnter";
const string AREA_EVENT_ON_EXIT                       = "OnAreaExit";
const string AREA_EVENT_ON_HEARTBEAT                  = "OnAreaHeartbeat";
const string AREA_EVENT_ON_USER_DEFINED               = "OnAreaUserDefined";

// These are pseudo-events called by the Core Framework
const string AREA_EVENT_ON_EMPTY                      = "OnAreaEmpty";

// ----- Area of Effect Events -------------------------------------------------

const string AOE_EVENT_ON_ENTER                       = "OnAoEEnter";
const string AOE_EVENT_ON_EXIT                        = "OnAoEExit";
const string AOE_EVENT_ON_HEARTBEAT                   = "OnAoEHeartbeat";
const string AOE_EVENT_ON_USER_DEFINED                = "OnAoEUserDefined";

// These are pseudo-events called by the Core Framework
const string AOE_EVENT_ON_EMPTY                       = "OnAoEEmpty";

// ----- Creature Events -------------------------------------------------------

const string CREATURE_EVENT_ON_BLOCKED                = "OnCreatureBlocked";
const string CREATURE_EVENT_ON_COMBAT_ROUND_END       = "OnCreatureCombatRoundEnd";
const string CREATURE_EVENT_ON_CONVERSATION           = "OnCreatureConversation";
const string CREATURE_EVENT_ON_DAMAGED                = "OnCreatureDamaged";
const string CREATURE_EVENT_ON_DEATH                  = "OnCreatureDeath";
const string CREATURE_EVENT_ON_DISTURBED              = "OnCreatureDisturbed";
const string CREATURE_EVENT_ON_HEARTBEAT              = "OnCreatureHeartbeat";
const string CREATURE_EVENT_ON_PERCEPTION             = "OnCreaturePerception";
const string CREATURE_EVENT_ON_PHYSICAL_ATTACKED      = "OnCreaturePhysicalAttacked";
const string CREATURE_EVENT_ON_RESTED                 = "OnCreatureRested";
const string CREATURE_EVENT_ON_SPAWN                  = "OnCreatureSpawn";
const string CREATURE_EVENT_ON_SPELL_CAST_AT          = "OnCreatureSpellCastAt";
const string CREATURE_EVENT_ON_USER_DEFINED           = "OnCreatureUserDefined";

// PC versions of the above. All work except for OnPCRested and OnPCSpawn. See
// https://nwnlexicon.com/index.php?title=SetEventScript#Remarks for details.
const string PC_EVENT_ON_BLOCKED                      = "OnPCBlocked";
const string PC_EVENT_ON_COMBAT_ROUND_END             = "OnPCCombatRoundEnd";
const string PC_EVENT_ON_CONVERSATION                 = "OnPCConversation";
const string PC_EVENT_ON_DAMAGED                      = "OnPCDamaged";
const string PC_EVENT_ON_DEATH                        = "OnPCDeath";
const string PC_EVENT_ON_DISTURBED                    = "OnPCDisturbed";
const string PC_EVENT_ON_HEARTBEAT                    = "OnPCHeartbeat";
const string PC_EVENT_ON_PERCEPTION                   = "OnPCPerception";
const string PC_EVENT_ON_PHYSICAL_ATTACKED            = "OnPCPhysicalAttacked";
const string PC_EVENT_ON_RESTED                       = "OnPCRested";
const string PC_EVENT_ON_SPAWN                        = "OnPCSpawn";
const string PC_EVENT_ON_SPELL_CAST_AT                = "OnPCSpellCastAt";
const string PC_EVENT_ON_USER_DEFINED                 = "OnPCUserDefined";

// ----- Door Events -----------------------------------------------------------

const string DOOR_EVENT_ON_AREA_TRANSITION_CLICK      = "OnDoorAreaTransitionClick";
const string DOOR_EVENT_ON_CLOSE                      = "OnDoorClose";
const string DOOR_EVENT_ON_CONVERSATION               = "OnDoorConversation";
const string DOOR_EVENT_ON_DAMAGED                    = "OnDoorDamaged";
const string DOOR_EVENT_ON_DEATH                      = "OnDoorDeath";
const string DOOR_EVENT_ON_FAIL_TO_OPEN               = "OnDoorFailToOpen";
const string DOOR_EVENT_ON_HEARTBEAT                  = "OnDoorHeartbeat";
const string DOOR_EVENT_ON_LOCK                       = "OnDoorLock";
const string DOOR_EVENT_ON_OPEN                       = "OnDoorOpen";
const string DOOR_EVENT_ON_PHYSICAL_ATTACKED          = "OnDoorPhysicalAttacked";
const string DOOR_EVENT_ON_SPELL_CAST_AT              = "OnDoorSpellCastAt";
const string DOOR_EVENT_ON_UNLOCK                     = "OnDoorUnLock";
const string DOOR_EVENT_ON_USER_DEFINED               = "OnDoorUserDefined";

// ----- Encounter Events ------------------------------------------------------

const string ENCOUNTER_EVENT_ON_ENTER                 = "OnEncounterEnter";
const string ENCOUNTER_EVENT_ON_EXHAUSTED             = "OnEncounterExhausted";
const string ENCOUNTER_EVENT_ON_EXIT                  = "OnEncounterExit";
const string ENCOUNTER_EVENT_ON_HEARTBEAT             = "OnEncounterHeartbeat";
const string ENCOUNTER_EVENT_ON_USER_DEFINED          = "OnEncounterUserDefined";

// ----- Placeable Events ------------------------------------------------------

const string PLACEABLE_EVENT_ON_CLICK                 = "OnPlaceableClick";
const string PLACEABLE_EVENT_ON_CLOSE                 = "OnPlaceableClose";
const string PLACEABLE_EVENT_ON_CONVERSATION          = "OnPlaceableConversation";
const string PLACEABLE_EVENT_ON_DAMAGED               = "OnPlaceableDamaged";
const string PLACEABLE_EVENT_ON_DEATH                 = "OnPlaceableDeath";
const string PLACEABLE_EVENT_ON_DISTURBED             = "OnPlaceableDisturbed";
const string PLACEABLE_EVENT_ON_HEARTBEAT             = "OnPlaceableHeartbeat";
const string PLACEABLE_EVENT_ON_LOCK                  = "OnPlaceableLock";
const string PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED     = "OnPlaceablePhysicalAttacked";
const string PLACEABLE_EVENT_ON_OPEN                  = "OnPlaceableOpen";
const string PLACEABLE_EVENT_ON_SPELL_CAST_AT         = "OnPlaceableSpellCastAt";
const string PLACEABLE_EVENT_ON_UNLOCK                = "OnPlaceableUnLock";
const string PLACEABLE_EVENT_ON_USED                  = "OnPlaceableUsed";
const string PLACEABLE_EVENT_ON_USER_DEFINED          = "OnPlaceableUserDefined";

// ----- Store Events ----------------------------------------------------------

const string STORE_EVENT_ON_OPEN                      = "OnStoreOpen";
const string STORE_EVENT_ON_CLOSE                     = "OnStoreClose";

// ----- Trap Events -----------------------------------------------------------

const string TRAP_EVENT_ON_DISARM                     = "OnTrapDisarm";
const string TRAP_EVENT_ON_TRIGGERED                  = "OnTrapTriggered";

// ----- Trigger Events --------------------------------------------------------

const string TRIGGER_EVENT_ON_CLICK                   = "OnTriggerClick";
const string TRIGGER_EVENT_ON_ENTER                   = "OnTriggerEnter";
const string TRIGGER_EVENT_ON_EXIT                    = "OnTriggerExit";
const string TRIGGER_EVENT_ON_HEARTBEAT               = "OnTriggerHeartbeat";
const string TRIGGER_EVENT_ON_USER_DEFINED            = "OnTriggerUserDefined";

// ----- Plugin Events ---------------------------------------------------------

// These are pseudo-events called by the Core Framework.
const string PLUGIN_EVENT_ON_ACTIVATE                 = "OnPluginActivate";
const string PLUGIN_EVENT_ON_DEACTIVATE               = "OnPluginDeactivate";
/// ----------------------------------------------------------------------------
/// @file   core_i_framework.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Main include for the Core Framework.
/// ----------------------------------------------------------------------------

#include "util_i_libraries"
#include "util_i_timers"
#include "core_i_constants"
#include "core_c_config"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Run initial setup for the Core Framework.
/// @note This is a system function that need not be used by the builder.
void InitializeCoreFramework();

/// @brief Add a local source of event scripts to an object.
/// @details When an event is triggered on oTarget, all sources added with this
///     function will be checked for scripts for that event. For example,
///     running `AddScriptSource(GetEnteringObject())` OnAreaEnter and adding an
///     OnPlayerDeath script to the area will cause players in the area to run
///     that OnPlayerDeath script if they die in the area.
/// @param oTarget The object that will receive oSource as a source of scripts.
/// @param oSource The object that will serve as a source of scripts.
void AddScriptSource(object oTarget, object oSource = OBJECT_SELF);

/// @brief Remove a source of local scripts for an object.
/// @param oTarget The object to remove the local event source from.
/// @param oSource The object to remove as a local event source.
void RemoveScriptSource(object oTarget, object oSource = OBJECT_SELF);

/// @brief Get all script sources for an object.
/// @param oTarget The object to get script sources from.
/// @returns A query that will iterate over all script sources for the target.
///     You can loop over the sources using `SqlStep(q)` and get each individual
///     source with `StringToObject(SqlGetString(q, 0))`, where q is the return
///     value of this function.
sqlquery GetScriptSources(object oTarget);

/// @brief Blacklist an object as a local event source. The blacklisted object
///     will not be checked as for event scripts even if it is added to the
///     target's source list.
/// @param oSource A plugin object, area, trigger, encounter, AoE, or another
///     other object that may be set as a local script source on oTarget.
/// @param bBlacklist Blacklists oSource if TRUE, otherwise unblacklists.
/// @param oTarget The object that will blacklist oSource.
void SetSourceBlacklisted(object oSource, int bBlacklist = TRUE, object oTarget = OBJECT_SELF);

/// @brief Return whether an object has been blacklisted as a local event source
/// @param oSource A plugin object, area, trigger, encounter, AoE, or another
///     other object that may be set as a local script source on oTarget.
/// @param oTarget The object to check the blacklist of.
int GetSourceBlacklisted(object oSource, object oTarget = OBJECT_SELF);

/// @brief Get all script sources that an object has blacklisted.
/// @param oTarget The object to get the source blacklist from.
/// @returns A query that will iterate over all blacklisted script sources for
///     the target. You can loop over the blacklist using `SqlStep(q)` and get
///     each individual source with `StringToObject(SqlGetString(q, 0))` where q
///     is the return value of this function.
sqlquery GetSourceBlacklist(object oTarget);

/// @brief Return the name of the currently executing event.
string GetCurrentEvent();

/// @brief Set the current event. Pass before running a script if you want the
///     event name to be accessible with GetCurentEvent().
/// @param sEvent The name of the event. If "", will use the current event name.
void SetCurrentEvent(string sEvent = "");

/// @brief Return the object that triggered the currently executing event.
object GetEventTriggeredBy();

/// @brief Set the object triggering the current event. Pass before running a
///     script if you want the triggering object to be accessible with
///     GetEventTriggeredBy().
/// @param oObject The object triggering the event. If invalid, will use the
///     object triggering the current event.
void SetEventTriggeredBy(object oObject = OBJECT_INVALID);

/// @brief Return the debug level for an event.
/// @param sEvent The name of the event to check.
/// @param oTarget The object to check the debug level on. If invalid, will
///     check the global debug level for the event.
/// @returns A `DEBUG_LEVEL_*` constant or 0 if an event-specific debug level is
///     not set.
int GetEventDebugLevel(string sEvent, object oTarget = OBJECT_INVALID);

/// @brief Set the debug level for an event.
/// @param sEvent The name of the event to set the debug level for.
/// @param nLevel The debug level for the event.
/// @param oTarget The object to set the debug level on. If invalid, will set
///     the global debug level for the event.
void SetEventDebugLevel(string sEvent, int nLevel, object oTarget = OBJECT_INVALID);

/// @brief Clear the debug level set for an event.
/// @param sEvent The name of the event to clear the debug level for.
/// @param oTarget The object to clear the debug level on. If invalid, will
///     clear the global debug level for the event.
void DeleteEventDebugLevel(string sEvent, object oTarget = OBJECT_INVALID);

/// @brief Return the state of an event.
/// @param sEvent The name of an event. If "", will use the current event.
/// @returns A flagset consisting of:
///     - EVENT_STATE_OK: continue with queued scripts
///     - EVENT_STATE_ABORT: stop further queue processing
///     - EVENT_STATE_DENIED: request denied
int GetEventState(string sEvent = "");

/// @brief Set the state of an event.
/// @param sEvent The name of an event. If "", will use the current event.
/// @param nState A flagset consisting of:
///     - EVENT_STATE_OK: continue with queued scripts
///     - EVENT_STATE_ABORT: stop further queue processing
///     - EVENT_STATE_DENIED: request denied
void SetEventState(int nState, string sEvent = "");

/// @brief Clear the state of an event.
/// @param sEvent The name of an event. If "", will use the current event.
void ClearEventState(string sEvent = "");

/// @brief Register a script to an event on an object. Can be used to add event
///     scripts to plugins or other objects.
/// @param oTarget The object to attach the scripts to.
/// @param sEvent The name of the event the scripts will subscribe to.
/// @param sScripts A CSV list of library scripts to execute when sEvent fires.
/// @param fPriority the priority at which the scripts should be executed. If
///     -1.0, will use the configured global or local priority, depending on
///     whether oTarget is a plugin or other object.
void RegisterEventScript(object oTarget, string sEvent, string sScripts, float fPriority = -1.0);

/// @brief Run an event, causing all subscribed scripts to trigger.
/// @param sEvent The name of the event
/// @param oInit The object triggering the event (e.g, a PC OnClientEnter)
/// @param oSelf The object on which to run the event
/// @param bLocalOnly If TRUE, will skip scripts from plugins and other objects
/// @returns the state of the event; consists of bitmasked `EVENT_STATE_*`
///     constants representing how the event finished:
///     - EVENT_STATE_OK: all queued scripts executed successfully
///     - EVENT_STATE_ABORT: a script cancelled remaining scripts in the queue
///     - EVENT_STATE_DENIED: a script specified that the event should cancelled
int RunEvent(string sEvent, object oInit = OBJECT_INVALID, object oSelf = OBJECT_SELF, int bLocalOnly = FALSE);

/// @brief Run an item event (e.g., OnAcquireItem) first on the module, then
///     locally on the item. This allows oItem to specify its own scripts for
///     the event which get executed if the module-level event it not denied.
/// @param sEvent The name of the event
/// @param oItem The item
/// @param oPC The PC triggering the item event
/// @returns The accumulated `EVENT_STATUS_*` of the two events.
int RunItemEvent(string sEvent, object oItem, object oPC);

/// @brief Return the Core Framework event name corresponding to an event.
/// @param nEvent The `EVENT_SCRIPT_*` constant to convert.
string GetEventName(int nEvent);

/// @brief Set the Core Framework event hook script as an object event handler.
/// @param oObject The object to set the handler for.
/// @param nEvent The `EVENT_SCRIPT_*` constant matching the event.
/// @param bStoreOldEvent If TRUE, will include the existing handler as a local
///     script that will be run by the Core Framework event hook.
void HookObjectEvent(object oObject, int nEvent, int bStoreOldEvent = TRUE);

/// @brief Set the Core Framework event hook script as the handler for all of an
///     object's events.
/// @param oObject The object to set the handlers for.
/// @param bSkipHeartbeat Whether to skip setting the heartbeat script.
/// @param bStoreOldEvents If TRUE, will include the existing handlers as local
///     scripts that will be run by the Core Framework event hooks.
void HookObjectEvents(object oObject, int bSkipHeartbeat = TRUE, int bStoreOldEvents = TRUE);

// ----- Plugin Management -----------------------------------------------------

/// @brief Return a plugin's data object.
/// @param sPlugin The plugin's unique identifier in the database.
object GetPlugin(string sPlugin);

/// @brief Prepare a query that can be stepped to obtain the plugin_id of all
///     installed plugins, regardless of activation status.
sqlquery GetPlugins();

/// @brief Count number of installed plugins.
/// @returns 0 if no plugins are installed, otherwise the number of plugins
///     installed, regardless of activation status.
int CountPlugins();

/// @brief Create a plugin object and register it in the database.
/// @param sPlugin The plugin's unique identifier in the database.
/// @returns The created plugin object.
object CreatePlugin(string sPlugin);

/// @brief Return the status of a plugin.
/// @param oPlugin A plugin's data object.
/// @returns A `PLUGIN_STATUS_*` constant.
int GetPluginStatus(object oPlugin);

/// @brief Get whether a plugin has been registered and is valid.
/// @param sPlugin The plugin's unique identifier in the database.
/// @returns FALSE if the plugin has not been registered or if its data object
///     has gone missing. Otherwise, returns TRUE.
int GetIfPluginExists(string sPlugin);

/// @brief Get whether a plugin is active.
/// @param oPlugin A plugin's data object.
int GetIsPluginActivated(object oPlugin);

/// @brief Run a plugin's OnPluginActivate script and set its status to ON.
/// @param sPlugin The plugin's unique identifier in the database.
/// @param bForce If TRUE, will activate even if the plugin is already ON.
/// @returns Whether the activation was successful.
int ActivatePlugin(string sPlugin, int bForce = FALSE);

/// @brief Run a plugin's OnPluginDeactivate script and set its status to OFF.
/// @param sPlugin The plugin's unique identifier in the database.
/// @param bForce If TRUE, will deactivate even if the plugin is already OFF.
/// @returns Whether the deactivation was successful.
int DeactivatePlugin(string sPlugin, int bForce = FALSE);

/// @brief Return a plugin's unique identifier in the database.
/// @param oPlugin A plugin's data object.
/// @returns The plugin's ID, or "" if oPlugin is not registered to a plugin.
/// @note This is the inverse of `GetPlugin()`.
string GetPluginID(object oPlugin);

/// @brief Get if an object is a plugin's data object.
/// @param oObject An object to test.
/// @returns TRUE if oObject is registered to a plugin; FALSE otherwise.
int GetIsPlugin(object oObject);

/// @brief Get the plugin object associated with the currently executing script.
object GetCurrentPlugin();

/// @brief Set the plugin that is the source of the current event script. Pass
///     before running a script if you want the triggering object to be
///     accessible with GetCurrentPlugin().
/// @param oPlugin The plugin data object. If invalid, will use the current
///     plugin.
void SetCurrentPlugin(object oPlugin = OBJECT_INVALID);

// ----- Timer Management ------------------------------------------------------

/// @brief Return the ID of the timer executing the current script. Returns 0
///     if the script was not executed by a timer.
int GetCurrentTimer();

/// @brief Set the ID of the timer executing the current script. Use this
///     before executing a script if you want the timer ID to be accessible with
///     GetCurrentTimer().
/// @param nTimerID The ID of the timer. If 0, will use the current timer ID.
void SetCurrentTimer(int nTimerID = 0);

/// @brief Create a timer that fires an event on a target at regular intervals.
/// @details After a timer is created, you will need to start it to get it to
///     run. You cannot create a timer on an invalid target or with a
///     non-positive interval value.
/// @param oTarget The object the action will run on.
/// @param sEvent The name of the event to execute when the timer elapses.
/// @param fInterval The number of seconds between iterations.
/// @param nIterations the number of times the timer can elapse. 0 means no
///     limit. If nIterations is 0, fInterval must be greater than or equal to
///     6.0.
/// @param fJitter A random number of seconds between 0.0 and fJitter to add to
///     fInterval between executions. Leave at 0.0 for no jitter.
/// @returns the ID of the timer. Save this so it can be used to start, stop, or
///     kill the timer later.
int CreateEventTimer(object oTarget, string sEvent, float fInterval, int nIterations = 0, float fJitter = 0.0);

// ----- Miscellaneous ---------------------------------------------------------

/// @brief Return whether an object is a PC.
/// @param oObject The object to check.
/// @returns TRUE if the object is an actual PC (i.e., not a possessed familiar
///     or creature). Will work OnClientExit as well.
int GetIsPCObject(object oObject);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void InitializeCoreFramework()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, CORE_INITIALIZED))
        return;

    SetLocalInt(oModule, CORE_INITIALIZED, TRUE);

    if (ON_MODULE_PRELOAD != "")
        ExecuteScript(ON_MODULE_PRELOAD, oModule);

    if (AUTO_HOOK_MODULE_EVENTS)
        HookObjectEvents(oModule, FALSE);

    if (AUTO_HOOK_AREA_EVENTS || AUTO_HOOK_OBJECT_EVENTS)
    {
        object oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            if (AUTO_HOOK_AREA_EVENTS && !GetLocalInt(oArea, SKIP_AUTO_HOOK))
                HookObjectEvents(oArea, !AUTO_HOOK_AREA_HEARTBEAT_EVENT);

            if (AUTO_HOOK_OBJECT_EVENTS)
            {
                // Once .35 is released, we can use the nObjectFilter parameter.
                object oObject = GetFirstObjectInArea(oArea);
                while (GetIsObjectValid(oObject))
                {
                    int nType = GetObjectType(oObject);
                    if (AUTO_HOOK_OBJECT_EVENTS & nType && !GetLocalInt(oObject, SKIP_AUTO_HOOK))
                        HookObjectEvents(oObject, !(AUTO_HOOK_OBJECT_HEARTBEAT_EVENT & nType));
                    oObject = GetNextObjectInArea(oArea);
                }
            }

            oArea = GetNextArea();
        }
    }

    // Start debugging
    SetDebugLevel(INITIALIZATION_DEBUG_LEVEL, oModule);
    SetDebugLogging(DEBUG_LOGGING);
    SetDebugPrefix(HexColorString("[Module]",  COLOR_CYAN), oModule);
    SetDebugPrefix(HexColorString("[Events]",  COLOR_CYAN), EVENTS);
    SetDebugPrefix(HexColorString("[Plugins]", COLOR_CYAN), PLUGINS);

    // Set specific event debug levels
    if (HEARTBEAT_DEBUG_LEVEL)
    {
        SetEventDebugLevel(MODULE_EVENT_ON_HEARTBEAT,    HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(AREA_EVENT_ON_HEARTBEAT,      HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(AOE_EVENT_ON_HEARTBEAT,       HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(CREATURE_EVENT_ON_HEARTBEAT,  HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(PC_EVENT_ON_HEARTBEAT,        HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(DOOR_EVENT_ON_HEARTBEAT,      HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(ENCOUNTER_EVENT_ON_HEARTBEAT, HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(PLACEABLE_EVENT_ON_HEARTBEAT, HEARTBEAT_DEBUG_LEVEL);
        SetEventDebugLevel(TRIGGER_EVENT_ON_HEARTBEAT,   HEARTBEAT_DEBUG_LEVEL);
    }

    if (PERCEPTION_DEBUG_LEVEL)
    {
        SetEventDebugLevel(CREATURE_EVENT_ON_PERCEPTION, PERCEPTION_DEBUG_LEVEL);
        SetEventDebugLevel(PC_EVENT_ON_PERCEPTION,       PERCEPTION_DEBUG_LEVEL);
    }

    Debug("Initializing Core Framework...");
    Debug("Creating database tables...");

    SqlCreateTableModule("event_plugins",
        "plugin_id TEXT NOT NULL PRIMARY KEY, " +
        "object_id TEXT NOT NULL UNIQUE, " +
        "active BOOLEAN DEFAULT 0");

    SqlCreateTableModule("event_sources",
        "object_id TEXT NOT NULL, " +
        "source_id TEXT NOT NULL, " +
        "UNIQUE(object_id, source_id)");

    SqlCreateTableModule("event_scripts",
        "object_id TEXT NOT NULL, " +
        "event TEXT NOT NULL, " +
        "script TEXT NOT NULL, " +
        "priority REAL NOT NULL DEFAULT 5.0");

    SqlCreateTableModule("event_blacklists",
        "object_id TEXT NOT NULL, " +
        "source_id TEXT NOT NULL, " +
        "UNIQUE(object_id, source_id)");

    SqlExecModule("CREATE VIEW IF NOT EXISTS v_active_plugins AS " +
        "SELECT plugin_id, object_id FROM event_plugins WHERE active = 1;");

    SqlExecModule("CREATE VIEW IF NOT EXISTS v_active_scripts AS " +
        "SELECT plugin_id, object_id, event, script, priority " +
        "FROM event_scripts LEFT JOIN v_active_plugins USING(object_id);");

    Debug("Loading libraries...");
    LoadLibrariesByPattern(INSTALLED_LIBRARIES);

    Debug("Activating plugins...");
    {
        if (INSTALLED_PLUGINS == "" && CountPlugins() > 0)
        {
            sqlquery q = GetPlugins();
            while (SqlStep(q))
                ActivatePlugin(SqlGetString(q, 0));
        }
        else
        {
            int i, nCount = CountList(INSTALLED_PLUGINS);
            for (i = 0; i < nCount; i++)
                ActivatePlugin(GetListItem(INSTALLED_PLUGINS, i));
        }
    }

    Debug("Successfully initialized Core Framework");
    SetDebugLevel(DEFAULT_DEBUG_LEVEL, oModule);
}

// ----- Event Script Sources --------------------------------------------------

// These functions help to manage where objects source their event scripts from.

void AddScriptSource(object oTarget, object oSource = OBJECT_SELF)
{
    Debug("Adding script source " + GetDebugPrefix(oSource), DEBUG_LEVEL_DEBUG, oTarget);
    sqlquery q = SqlPrepareQueryModule("INSERT OR IGNORE INTO event_sources " +
        "(object_id, source_id) VALUES (@object_id, @source_id);");
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    SqlBindString(q, "@source_id", ObjectToString(oSource));
    SqlStep(q);
}

void RemoveScriptSource(object oTarget, object oSource = OBJECT_SELF)
{
    Debug("Removing script source " + GetDebugPrefix(oSource), DEBUG_LEVEL_DEBUG, oTarget);
    sqlquery q = SqlPrepareQueryModule("DELETE FROM event_sources WHERE " +
                    "object_id = @object_id AND source_id = @source_id;");
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    SqlBindString(q, "@source_id", ObjectToString(oSource));
    SqlStep(q);
}

sqlquery GetScriptSources(object oTarget)
{
    sqlquery q = SqlPrepareQueryModule("SELECT source_id FROM event_sources " +
        "WHERE object_id = @object_id;");
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    return q;
}

void SetSourceBlacklisted(object oSource, int bBlacklist = TRUE, object oTarget = OBJECT_SELF)
{
    Debug((bBlacklist ? "Blacklisting" : "Unblacklisting") + " script source " +
        GetDebugPrefix(oSource), DEBUG_LEVEL_DEBUG, oTarget);
    string sSql = bBlacklist ?
        "INSERT OR IGNORE INTO event_blacklists VALUES (@object_id, @source_id);" :
        "DELETE FROM event_blacklists WHERE object_id = @object_id AND source_id = @source_id;";
    sqlquery q = SqlPrepareQueryModule(sSql);
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    SqlBindString(q, "@source_id", ObjectToString(oSource));
    SqlStep(q);
}

int GetSourceBlacklisted(object oSource, object oTarget = OBJECT_SELF)
{
    sqlquery q = SqlPrepareQueryModule("SELECT COUNT(*) FROM event_blacklists " +
                    "WHERE object_id = @object_id AND source_id = @source_id;");
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    SqlBindString(q, "@source_id", ObjectToString(oSource));
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

sqlquery GetSourceBlacklist(object oTarget)
{
    sqlquery q = SqlPrepareQueryModule("SELECT source_id FROM event_blacklists " +
        "WHERE object_id = @object_id;");
    SqlBindString(q, "@object_id", ObjectToString(oTarget));
    return q;
}

// ----- Event Management ------------------------------------------------------

string GetCurrentEvent()
{
    return GetScriptParam(EVENT_LAST);
}

void SetCurrentEvent(string sEvent = "")
{
    SetScriptParam(EVENT_LAST, sEvent != "" ? sEvent : GetCurrentEvent());
}

object GetEventTriggeredBy()
{
    return StringToObject(GetScriptParam(EVENT_TRIGGERED));
}

void SetEventTriggeredBy(object oObject = OBJECT_INVALID)
{
    string sObject = GetIsObjectValid(oObject) ? ObjectToString(oObject) : GetScriptParam(EVENT_TRIGGERED);
    SetScriptParam(EVENT_TRIGGERED, sObject);
}

int GetEventDebugLevel(string sEvent, object oTarget = OBJECT_INVALID)
{
    int nLevel = GetLocalInt(oTarget, EVENT_DEBUG + sEvent);
    if (!nLevel)
        nLevel = GetLocalInt(EVENTS, EVENT_DEBUG + sEvent);

    return clamp(nLevel, DEBUG_LEVEL_NONE, DEBUG_LEVEL_DEBUG);
}

void SetEventDebugLevel(string sEvent, int nLevel, object oTarget = OBJECT_INVALID)
{
    if (!GetIsObjectValid(oTarget))
        oTarget = EVENTS;

    SetLocalInt(oTarget, EVENT_DEBUG + sEvent, nLevel);
}

void DeleteEventDebugLevel(string sEvent, object oTarget = OBJECT_INVALID)
{
    if (!GetIsObjectValid(oTarget))
        oTarget = EVENTS;

    DeleteLocalInt(oTarget, EVENT_DEBUG + sEvent);
}

int GetEventState(string sEvent = "")
{
    if (sEvent == "")
        sEvent = GetCurrentEvent();

    return GetLocalInt(EVENTS, EVENT_STATE + sEvent);
}

void SetEventState(int nState, string sEvent = "")
{
    if (sEvent == "")
        sEvent = GetCurrentEvent();
    nState = (GetLocalInt(EVENTS, EVENT_STATE + sEvent) | nState);
    SetLocalInt(EVENTS, EVENT_STATE + sEvent, nState);
}

void ClearEventState(string sEvent = "")
{
    if (sEvent == "")
        sEvent = GetCurrentEvent();
    DeleteLocalInt(EVENTS, EVENT_STATE + sEvent);
}

// Private function for RegisterEventScript().
string PriorityToString(float fPriority)
{
    if (fPriority == EVENT_PRIORITY_FIRST)   return "first";
    if (fPriority == EVENT_PRIORITY_LAST)    return "last";
    if (fPriority == EVENT_PRIORITY_ONLY)    return "only";
    if (fPriority == EVENT_PRIORITY_DEFAULT) return "default";

    return FloatToString(fPriority, 0, 1);
}

// Private function for RegisterEventScript().
float StringToPriority(string sPriority, float fDefaultPriority)
{
    if (sPriority == "first")   return EVENT_PRIORITY_FIRST;
    if (sPriority == "last")    return EVENT_PRIORITY_LAST;
    if (sPriority == "only")    return EVENT_PRIORITY_ONLY;
    if (sPriority == "default") return EVENT_PRIORITY_DEFAULT;

    float fPriority = StringToFloat(sPriority);
    if (fPriority == 0.0 && sPriority != "0.0")
        return fDefaultPriority;
    else
        return fPriority;
}

void RegisterEventScript(object oTarget, string sEvent, string sScripts, float fPriority = -1.0)
{
    if (fPriority == -1.0)
        fPriority = GetIsPlugin(oTarget) ? GLOBAL_EVENT_PRIORITY : LOCAL_EVENT_PRIORITY;

    string sTarget = ObjectToString(oTarget);
    string sPriority = PriorityToString(fPriority);

    if ((fPriority < 0.0 || fPriority > 10.0) &&
        (fPriority != EVENT_PRIORITY_FIRST && fPriority != EVENT_PRIORITY_LAST &&
         fPriority != EVENT_PRIORITY_ONLY  && fPriority != EVENT_PRIORITY_DEFAULT))
    {
        CriticalError("Could not register scripts: " +
            "\n    Source: " + sTarget +
            "\n    Event: " + sEvent +
            "\n    Scripts: " + sScripts +
            "\n    Priority: " + sPriority +
            "\n    Error: priority outside expected range", oTarget);
        return;
    }

    // Handle NWNX script registration.
    if (GetStringLeft(sEvent, 4) == "NWNX")
    {
        SetScriptParam(EVENT_NAME, sEvent);
        ExecuteScript(CORE_HOOK_NWNX);
    }

    int i, nCount = CountList(sScripts);
    for (i = 0; i < nCount; i++)
    {
        string sScript = GetListItem(sScripts, i);
        Debug("Registering event script :" +
            "\n    Source: " + sTarget +
            "\n    Event: " + sEvent +
            "\n    Script: " + sScript +
            "\n    Priority: " + sPriority, DEBUG_LEVEL_DEBUG, oTarget);

        sqlquery q = SqlPrepareQueryModule("INSERT INTO event_scripts " +
                        "(object_id, event, script, priority) VALUES " +
                        "(@object_id, @event, @script, @priority);");
        SqlBindString(q, "@object_id", sTarget);
        SqlBindString(q, "@event", sEvent);
        SqlBindString(q, "@script", sScript);
        SqlBindFloat(q, "@priority", fPriority);
        SqlStep(q);
    }
}

// Alias function for backward compatibility.
void RegisterEventScripts(object oTarget, string sEvent, string sScripts, float fPriority = -1.0)
{
    RegisterEventScript(oTarget, sEvent, sScripts, fPriority);
}

// Private function. Checks oTarget for a builder-specified event hook string
// for sEvent and expands it into a list of scripts and priorities on oTarget.
// An event hook string is a CSV list of scripts and priorities, each specified
// in the format X[:Y], where X is a library script and Y is the priority at
// which it should run (for example, MyOnModuleLoadScript:6.0).
// Parameters:
// - oTarget: The object to check for event hook strings. May be:
//   - a plugin object (for global hooks)
//   - an area, AoE, trigger, or encounter (for location hooks)
//   - any object (for local hooks)
// - sEvent: the event to check for hook strings
// - fDefaultPriority: the default priority for scripts with no explicitly
//   assigned priority.
void ExpandEventScripts(object oTarget, string sEvent, float fDefaultPriority)
{
    string sScripts = GetLocalString(oTarget, sEvent);
    if (sScripts == "")
        return;

    float fPriority;
    string sScript, sPriority;
    int i, nScripts = CountList(sScripts);

    for (i = 0; i < nScripts; i++)
    {
        sScript = GetListItem(sScripts, i);
        Debug("Expanding " + sEvent + " scripts: " + sScript, DEBUG_LEVEL_DEBUG, oTarget);

        sPriority = StringParse(sScript, ":", TRUE);
        if (sPriority != sScript)
            sScript = StringRemoveParsed(sScript, sPriority, ":", TRUE);

        fPriority = StringToPriority(sPriority, fDefaultPriority);
        RegisterEventScript(oTarget, sEvent, sScript, fPriority);
    }

    DeleteLocalString(oTarget, sEvent);
}

int RunEvent(string sEvent, object oInit = OBJECT_INVALID, object oSelf = OBJECT_SELF, int bLocalOnly = FALSE)
{
    // Which object initiated the event?
    if (!GetIsObjectValid(oInit))
        oInit = oSelf;

    // Ensure the Framework has been loaded. Can't do this OnModuleLoad because
    // some events fire before OnModuleLoad.
    InitializeCoreFramework();

    // Set the debugging level specific to this event, if it is defined. If an
    // event has a debug level set, we use that debug level, no matter what it
    // is. Otherwise, we use the object's debug level (or the module's debug
    // level if no level was set for the object).
    int nEventLevel = GetEventDebugLevel(sEvent, oSelf);
    if (nEventLevel)
        OverrideDebugLevel(nEventLevel);

    // Initialize event status
    ClearEventState(sEvent);

    Debug("Preparing to run event " + sEvent, DEBUG_LEVEL_DEBUG, oSelf);

    // Expand the target's own local event scripts
    ExpandEventScripts(oSelf, sEvent, LOCAL_EVENT_PRIORITY);

    if (!bLocalOnly)
    {
        // Expand plugin event scripts.
        sqlquery q = SqlPrepareQueryModule("SELECT object_id FROM event_plugins;");
        while(SqlStep(q))
        {
            object oPlugin = StringToObject(SqlGetString(q, 0));
            ExpandEventScripts(oPlugin, sEvent, GLOBAL_EVENT_PRIORITY);
        }

        // Expand local event scripts for each source
        q = SqlPrepareQueryModule("SELECT source_id FROM event_sources " +
                "WHERE object_id = @object_id;");

        // Creatures maintain their own list of script sources. All other objects
        // source their scripts from the object initiating the event.
        if (GetObjectType(oSelf) == OBJECT_TYPE_CREATURE)
            SqlBindString(q, "@object_id", ObjectToString(oSelf));
        else
            SqlBindString(q, "@object_id", ObjectToString(oInit));
        while (SqlStep(q))
        {
            object oSource = StringToObject(SqlGetString(q, 0));
            ExpandEventScripts(oSource, sEvent, LOCAL_EVENT_PRIORITY);
        }
    }

    string sInit = ObjectToString(oInit);
    string sName = GetName(oSelf);
    string sTimerID = GetScriptParam(TIMER_LAST);
    sqlquery q;

    int nState, nExecuted;

    if (bLocalOnly)
    {
        // Get scripts from the object itself only.
        q = SqlPrepareQueryModule(
            "SELECT plugin_id, object_id, script, priority FROM v_active_scripts " +
            "WHERE object_id = @object_id AND event = @event " +
            "ORDER BY priority DESC;");
    }
    else
    {
        // Get scripts from the object itself and from active plugins or sources
        // that were not blacklisted.
        q = SqlPrepareQueryModule("WITH " +
            "sources AS (SELECT source_id FROM event_sources WHERE object_id = @object_id), " +
            "blacklist AS (SELECT source_id FROM event_blacklists WHERE object_id = @object_id) " +
            "SELECT plugin_id, object_id, script, priority FROM v_active_scripts " +
            "WHERE event = @event AND (object_id = @object_id OR " +
            "((plugin_id IS NOT NULL OR object_id IN sources) AND " +
            "object_id NOT IN blacklist)) ORDER BY priority DESC;");
    }

    SqlBindString(q, "@object_id", ObjectToString(oSelf));
    SqlBindString(q, "@event", sEvent);

    while (SqlStep(q))
    {
        string sPlugin   = SqlGetString(q, 0);
        string sSource   = SqlGetString(q, 1);
        string sScript   = SqlGetString(q, 2);
        float  fPriority = SqlGetFloat (q, 3);

        // Scripts with "default" priority only run if no other scripts did.
        if (nExecuted++ && fPriority == EVENT_PRIORITY_DEFAULT)
            break;

        Debug("Executing event script " + sScript + " from " +
               GetDebugPrefix(StringToObject(sSource)) + " with a priority of " +
               PriorityToString(fPriority), DEBUG_LEVEL_DEBUG, oSelf);

        SetScriptParam(EVENT_LAST, sEvent);       // Current event
        SetScriptParam(EVENT_TRIGGERED, sInit);   // Triggering object
        SetScriptParam(TIMER_LAST, sTimerID);     // Timer ID
        if (sPlugin != "")
            SetScriptParam(PLUGIN_LAST, sSource); // Plugin object

        // Execute the script and return the saved data
        RunLibraryScript(sScript, oSelf);
        nState = GetEventState(sEvent);
        if (nState & EVENT_STATE_ABORT)
            break;

        // Scripts with "only" priority prevent other scripts from running.
        if (fPriority == EVENT_PRIORITY_ONLY)
            break;
    }

    // Cleanup
    if (nEventLevel)
        OverrideDebugLevel(FALSE);

    return nState;
}

int RunItemEvent(string sEvent, object oItem, object oPC)
{
    int nStatus = RunEvent(sEvent, oPC);
    if (!(nStatus & EVENT_STATE_DENIED))
        nStatus |= RunEvent(sEvent, oPC, oItem, TRUE);
    return nStatus;
}

string GetEventName(int nEvent)
{
    switch (nEvent / 1000)
    {
        case EVENT_TYPE_MODULE:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_MODULE_ON_HEARTBEAT:              return MODULE_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_MODULE_ON_USER_DEFINED_EVENT:     return MODULE_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_MODULE_ON_MODULE_LOAD:            return MODULE_EVENT_ON_MODULE_LOAD;
                case EVENT_SCRIPT_MODULE_ON_MODULE_START:           return MODULE_EVENT_ON_MODULE_START;
                case EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER:           return MODULE_EVENT_ON_CLIENT_ENTER;
                case EVENT_SCRIPT_MODULE_ON_CLIENT_EXIT:            return MODULE_EVENT_ON_CLIENT_LEAVE;
                case EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM:          return MODULE_EVENT_ON_ACTIVATE_ITEM;
                case EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM:           return MODULE_EVENT_ON_ACQUIRE_ITEM;
                case EVENT_SCRIPT_MODULE_ON_LOSE_ITEM:              return MODULE_EVENT_ON_UNACQUIRE_ITEM;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_DEATH:           return MODULE_EVENT_ON_PLAYER_DEATH;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_DYING:           return MODULE_EVENT_ON_PLAYER_DYING;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET:          return MODULE_EVENT_ON_PLAYER_TARGET;
                case EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED: return MODULE_EVENT_ON_PLAYER_RESPAWN;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_REST:            return MODULE_EVENT_ON_PLAYER_REST;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP:        return MODULE_EVENT_ON_PLAYER_LEVEL_UP;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_CANCEL_CUTSCENE: return MODULE_EVENT_ON_CUTSCENE_ABORT;
                case EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM:             return MODULE_EVENT_ON_PLAYER_EQUIP_ITEM;
                case EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM:           return MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_CHAT:            return MODULE_EVENT_ON_PLAYER_CHAT;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT:        return MODULE_EVENT_ON_PLAYER_GUI;
                case EVENT_SCRIPT_MODULE_ON_NUI_EVENT:              return MODULE_EVENT_ON_NUI;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_TILE_ACTION:     return MODULE_EVENT_ON_PLAYER_TILE_ACTION;
            } break;
        }
        case EVENT_TYPE_AREA:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_AREA_ON_HEARTBEAT:          return AREA_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT: return AREA_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_AREA_ON_ENTER:              return AREA_EVENT_ON_ENTER;
                case EVENT_SCRIPT_AREA_ON_EXIT:               return AREA_EVENT_ON_EXIT;
            } break;
        }
        case EVENT_TYPE_AREAOFEFFECT:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT:          return AOE_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_USER_DEFINED_EVENT: return AOE_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER:       return AOE_EVENT_ON_ENTER;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT:        return AOE_EVENT_ON_EXIT;
            } break;
        }
        case EVENT_TYPE_CREATURE:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:          return CREATURE_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_CREATURE_ON_NOTICE:             return CREATURE_EVENT_ON_PERCEPTION;
                case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:        return CREATURE_EVENT_ON_SPELL_CAST_AT;
                case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:     return CREATURE_EVENT_ON_PHYSICAL_ATTACKED;
                case EVENT_SCRIPT_CREATURE_ON_DAMAGED:            return CREATURE_EVENT_ON_DAMAGED;
                case EVENT_SCRIPT_CREATURE_ON_DISTURBED:          return CREATURE_EVENT_ON_DISTURBED;
                case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:    return CREATURE_EVENT_ON_COMBAT_ROUND_END;
                case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:           return CREATURE_EVENT_ON_CONVERSATION;
                case EVENT_SCRIPT_CREATURE_ON_SPAWN_IN:           return CREATURE_EVENT_ON_SPAWN;
                case EVENT_SCRIPT_CREATURE_ON_RESTED:             return CREATURE_EVENT_ON_RESTED;
                case EVENT_SCRIPT_CREATURE_ON_DEATH:              return CREATURE_EVENT_ON_DEATH;
                case EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT: return CREATURE_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:    return CREATURE_EVENT_ON_BLOCKED;
            } break;
        }
        case EVENT_TYPE_TRIGGER:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT:          return TRIGGER_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER:       return TRIGGER_EVENT_ON_ENTER;
                case EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT:        return TRIGGER_EVENT_ON_EXIT;
                case EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT: return TRIGGER_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED:      return TRAP_EVENT_ON_TRIGGERED;
                case EVENT_SCRIPT_TRIGGER_ON_DISARMED:           return TRAP_EVENT_ON_DISARM;
                case EVENT_SCRIPT_TRIGGER_ON_CLICKED:            return TRIGGER_EVENT_ON_CLICK;
            } break;
        }
        case EVENT_TYPE_PLACEABLE:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_PLACEABLE_ON_CLOSED:             return PLACEABLE_EVENT_ON_CLOSE;
                case EVENT_SCRIPT_PLACEABLE_ON_DAMAGED:            return PLACEABLE_EVENT_ON_DAMAGED;
                case EVENT_SCRIPT_PLACEABLE_ON_DEATH:              return PLACEABLE_EVENT_ON_DEATH;
                case EVENT_SCRIPT_PLACEABLE_ON_DISARM:             return TRAP_EVENT_ON_DISARM;
                case EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT:          return PLACEABLE_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED: return PLACEABLE_EVENT_ON_DISTURBED;
                case EVENT_SCRIPT_PLACEABLE_ON_LOCK:               return PLACEABLE_EVENT_ON_LOCK;
                case EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED:      return PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED;
                case EVENT_SCRIPT_PLACEABLE_ON_OPEN:               return PLACEABLE_EVENT_ON_OPEN;
                case EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT:        return PLACEABLE_EVENT_ON_SPELL_CAST_AT;
                case EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED:      return TRAP_EVENT_ON_TRIGGERED;
                case EVENT_SCRIPT_PLACEABLE_ON_UNLOCK:             return PLACEABLE_EVENT_ON_UNLOCK;
                case EVENT_SCRIPT_PLACEABLE_ON_USED:               return PLACEABLE_EVENT_ON_USED;
                case EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT: return PLACEABLE_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE:           return PLACEABLE_EVENT_ON_CONVERSATION;
                case EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK:         return PLACEABLE_EVENT_ON_CLICK;
            } break;
        }
        case EVENT_TYPE_DOOR:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_DOOR_ON_OPEN:           return DOOR_EVENT_ON_OPEN;
                case EVENT_SCRIPT_DOOR_ON_CLOSE:          return DOOR_EVENT_ON_CLOSE;
                case EVENT_SCRIPT_DOOR_ON_DAMAGE:         return DOOR_EVENT_ON_DAMAGED;
                case EVENT_SCRIPT_DOOR_ON_DEATH:          return DOOR_EVENT_ON_DEATH;
                case EVENT_SCRIPT_DOOR_ON_DISARM:         return TRAP_EVENT_ON_DISARM;
                case EVENT_SCRIPT_DOOR_ON_HEARTBEAT:      return DOOR_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_DOOR_ON_LOCK:           return DOOR_EVENT_ON_LOCK;
                case EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED: return DOOR_EVENT_ON_PHYSICAL_ATTACKED;
                case EVENT_SCRIPT_DOOR_ON_SPELLCASTAT:    return DOOR_EVENT_ON_SPELL_CAST_AT;
                case EVENT_SCRIPT_DOOR_ON_TRAPTRIGGERED:  return TRAP_EVENT_ON_TRIGGERED;
                case EVENT_SCRIPT_DOOR_ON_UNLOCK:         return DOOR_EVENT_ON_UNLOCK;
                case EVENT_SCRIPT_DOOR_ON_USERDEFINED:    return DOOR_EVENT_ON_USER_DEFINED;
                case EVENT_SCRIPT_DOOR_ON_CLICKED:        return DOOR_EVENT_ON_AREA_TRANSITION_CLICK;
                case EVENT_SCRIPT_DOOR_ON_DIALOGUE:       return DOOR_EVENT_ON_CONVERSATION;
                case EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN:   return DOOR_EVENT_ON_FAIL_TO_OPEN;
            } break;
        }
        case EVENT_TYPE_ENCOUNTER:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER:        return ENCOUNTER_EVENT_ON_ENTER;
                case EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_EXIT:         return ENCOUNTER_EVENT_ON_EXIT;
                case EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT:           return ENCOUNTER_EVENT_ON_HEARTBEAT;
                case EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED: return ENCOUNTER_EVENT_ON_EXHAUSTED;
                case EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT:  return ENCOUNTER_EVENT_ON_USER_DEFINED;
            } break;
        }
        case EVENT_TYPE_STORE:
        {
            switch (nEvent)
            {
                case EVENT_SCRIPT_STORE_ON_OPEN:  return STORE_EVENT_ON_OPEN;
                case EVENT_SCRIPT_STORE_ON_CLOSE: return STORE_EVENT_ON_CLOSE;
            } break;
        }
    }

    return "";
}

void HookObjectEvent(object oObject, int nEvent, int bStoreOldEvent = TRUE)
{
    string sScript = GetEventScript(oObject, nEvent);
    SetEventScript(oObject, nEvent, CORE_HOOK_NWN);
    if (!bStoreOldEvent || sScript == "" || sScript == CORE_HOOK_NWN)
        return;

    string sEvent = GetEventName(nEvent);
    if (GetIsPC(oObject) && GetStringLeft(sEvent, 10) == "OnCreature")
        sEvent = ReplaceSubString(sEvent, "OnPC", 0, 9);
    AddLocalListItem(oObject, sEvent, sScript);
}

void HookObjectEvents(object oObject, int bSkipHeartbeat = TRUE, int bStoreOldEvents = TRUE)
{
    int nEvent, nStart, nEnd, nSkip;
    if (oObject == GetModule())
    {
        nStart = EVENT_SCRIPT_MODULE_ON_HEARTBEAT;
        nEnd   = EVENT_SCRIPT_MODULE_ON_NUI_EVENT;
        if (bSkipHeartbeat)
            nStart++;
    }
    else if (oObject == GetArea(oObject))
    {
        nStart = EVENT_SCRIPT_AREA_ON_HEARTBEAT;
        nEnd   = EVENT_SCRIPT_AREA_ON_EXIT;
        if (bSkipHeartbeat)
            nStart++;
    }
    else
    {
        switch (GetObjectType(oObject))
        {
            case OBJECT_TYPE_CREATURE:
                nStart = EVENT_SCRIPT_CREATURE_ON_HEARTBEAT;
                nEnd   = EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR;
                if (bSkipHeartbeat)
                    nStart++;
                break;
            case OBJECT_TYPE_AREA_OF_EFFECT:
                nStart = EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT;
                nEnd   = EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT;
                if (bSkipHeartbeat)
                    nStart++;
                break;
            case OBJECT_TYPE_DOOR:
                nStart = EVENT_SCRIPT_DOOR_ON_OPEN;
                nEnd   = EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN;
                if (bSkipHeartbeat)
                    nSkip = EVENT_SCRIPT_DOOR_ON_HEARTBEAT;
                break;
            case OBJECT_TYPE_PLACEABLE:
                nStart = EVENT_SCRIPT_PLACEABLE_ON_CLOSED;
                nEnd   = EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK;
                if (bSkipHeartbeat)
                    nSkip = EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT;
                break;
            case OBJECT_TYPE_ENCOUNTER:
                nStart = EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER;
                nEnd   = EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT;
                if (bSkipHeartbeat)
                    nSkip = EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT;
                break;
            case OBJECT_TYPE_TRIGGER:
                nStart = EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT;
                nEnd   = EVENT_SCRIPT_TRIGGER_ON_CLICKED;
                if (bSkipHeartbeat)
                    nStart++;
                if (JsonPointer(ObjectToJson(oObject), "/LinkedTo/value") == JsonString(""))
                    nEnd--;
                break;
            case OBJECT_TYPE_STORE:
                nStart = EVENT_SCRIPT_STORE_ON_OPEN;
                nEnd   = EVENT_SCRIPT_STORE_ON_CLOSE;
                break;
            default:
                return;
        }
    }

    for (nEvent = nStart; nEvent <= nEnd; nEvent++)
    {
        if (nEvent != nSkip)
            HookObjectEvent(oObject, nEvent, bStoreOldEvents);
    }
}

// ----- Plugin Management -----------------------------------------------------

object GetPlugin(string sPlugin)
{
    if (sPlugin == "")
        return OBJECT_INVALID;

    sqlquery q = SqlPrepareQueryModule("SELECT object_id FROM event_plugins " +
                    "WHERE plugin_id = @plugin_id;");
    SqlBindString(q, "@plugin_id", sPlugin);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

sqlquery GetPlugins()
{
    return SqlPrepareQueryModule("SELECT plugin_id FROM event_plugins;");
}

int CountPlugins()
{
    sqlquery q = SqlPrepareQueryModule("SELECT COUNT(plugin_id) FROM event_plugins;");
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

object CreatePlugin(string sPlugin)
{
    if (sPlugin == "")
        return OBJECT_INVALID;

    Debug("Creating plugin " + sPlugin);

    // It's possible the builder has pre-created a plugin object with all
    // the necessary variables on it. Try to create it. If it's not valid,
    // we can generate one from scratch.
    object oPlugin = CreateItemOnObject(sPlugin, PLUGINS);
    if (GetIsObjectValid(oPlugin))
        SetDataItem(PLUGINS, sPlugin, oPlugin);
    else
    {
        oPlugin = CreateDataItem(PLUGINS, sPlugin);
        SetTag(oPlugin, sPlugin);
    }

    sqlquery q = SqlPrepareQueryModule("INSERT INTO event_plugins " +
                    "(plugin_id, object_id) VALUES (@plugin_id, @object_id);");
    SqlBindString(q, "@plugin_id", sPlugin);
    SqlBindString(q, "@object_id", ObjectToString(oPlugin));
    SqlStep(q);

    return SqlGetError(q) == "" ? oPlugin : OBJECT_INVALID;
}

int GetPluginStatus(object oPlugin)
{
    sqlquery q = SqlPrepareQueryModule("SELECT active FROM event_plugins " +
                    "WHERE object_id = @object_id;");
    SqlBindString(q, "@object_id", ObjectToString(oPlugin));
    return SqlStep(q) ? SqlGetInt(q, 0) : PLUGIN_STATUS_MISSING;
}

int GetIfPluginExists(string sPlugin)
{
    return GetIsObjectValid(GetPlugin(sPlugin));
}

int GetIsPluginActivated(object oPlugin)
{
    return GetPluginStatus(oPlugin) == PLUGIN_STATUS_ON;
}

int _ActivatePlugin(string sPlugin, int bActive, int bForce)
{
    object oPlugin = GetPlugin(sPlugin);
    if (!GetIsObjectValid(oPlugin))
        return FALSE;

    string sVerb = bActive ? "activate" : "deactivate";
    string sVerbed = sVerb + "d";

    int nStatus = GetPluginStatus(oPlugin);
    if (nStatus == PLUGIN_STATUS_MISSING)
    {
        Error("Cannot " + sVerb + " plugin: plugin missing", oPlugin);
        return FALSE;
    }

    if (bForce || nStatus != bActive)
    {
        // Run the activation/deactivation routine
        string sEvent = bActive ? PLUGIN_EVENT_ON_ACTIVATE : PLUGIN_EVENT_ON_DEACTIVATE;
        int nState = RunEvent(sEvent, OBJECT_INVALID, oPlugin, TRUE);
        if (nState & EVENT_STATE_DENIED)
        {
            Warning("Cannot " + sVerb + " plugin: denied", oPlugin);
            return FALSE;
        }

        sqlquery q = SqlPrepareQueryModule("UPDATE event_plugins SET " +
                        "active = @active WHERE object_id = @object_id;");
        SqlBindInt(q, "@active", bActive);
        SqlBindString(q, "@object_id", ObjectToString(oPlugin));
        SqlStep(q);

        Debug("Plugin " + sPlugin + " " + sVerbed, DEBUG_LEVEL_DEBUG, oPlugin);
        return TRUE;
    }

    Warning("Cannot " + sVerb + " plugin: already " + sVerbed, oPlugin);
    return FALSE;
}

int ActivatePlugin(string sPlugin, int bForce = FALSE)
{
    return _ActivatePlugin(sPlugin, TRUE, bForce);
}

int DeactivatePlugin(string sPlugin, int bForce = FALSE)
{
    return _ActivatePlugin(sPlugin, FALSE, bForce);
}

string GetPluginID(object oPlugin)
{
    sqlquery q = SqlPrepareQueryModule("SELECT plugin_id FROM event_plugins " +
                    "WHERE object_id = @object_id;");
    SqlBindString(q, "@object_id", ObjectToString(oPlugin));
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

int GetIsPlugin(object oObject)
{
    if (!GetIsObjectValid(oObject))
        return FALSE;
    return GetPluginID(oObject) != "";
}

object GetCurrentPlugin()
{
    return StringToObject(GetScriptParam(PLUGIN_LAST));
}

void SetCurrentPlugin(object oPlugin = OBJECT_INVALID)
{
    string sPlugin = GetIsObjectValid(oPlugin) ? ObjectToString(oPlugin) : GetScriptParam(PLUGIN_LAST);
    SetScriptParam(PLUGIN_LAST, sPlugin);
}

// ----- Timer Management ------------------------------------------------------

int GetCurrentTimer()
{
    return StringToInt(GetScriptParam(TIMER_LAST));
}

void SetCurrentTimer(int nTimerID = 0)
{
    string sTimerID = nTimerID ? IntToString(nTimerID) : GetScriptParam(TIMER_LAST);
    SetScriptParam(TIMER_LAST, sTimerID);
}

int CreateEventTimer(object oTarget, string sEvent, float fInterval, int nIterations = 0, float fJitter = 0.0)
{
    return CreateTimer(oTarget, sEvent, fInterval, nIterations, fJitter, CORE_HOOK_TIMERS);
}

// ----- Miscellaneous ---------------------------------------------------------

int GetIsPCObject(object oObject)
{
    string sObject = ObjectToString(oObject);
    return (GetStringLength(sObject) == 8 && GetStringLeft(sObject, 3) == "7ff");
}
// -----------------------------------------------------------------------------
//    File: demo_l_plugin.nss
//  System: Core Framework Demo (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library script contains scripts to hook in to Core Framework events.
// -----------------------------------------------------------------------------

#include "util_i_color"
#include "util_i_library"
#include "core_i_framework"
#include "chat_i_main"

// -----------------------------------------------------------------------------
//                                  VerifyEvent
// -----------------------------------------------------------------------------
// This is a simple script that sends a message to the PC triggering an event.
// It can be used to verify that an event is firing as expected.
// -----------------------------------------------------------------------------

void VerifyEvent(object oPC)
{
    SendMessageToPC(oPC, GetCurrentEvent() + " fired!");
}

// -----------------------------------------------------------------------------
//                                  PrintColors
// -----------------------------------------------------------------------------
// Prints a list of color strings for the calling PC. Used to test util_i_color.
// -----------------------------------------------------------------------------

void PrintColor(object oPC, string sColor, int nColor)
{
    SendMessageToPC(oPC, HexColorString(sColor + ": " + IntToHexString(nColor), nColor));
}

void PrintHexColor(object oPC, int nColor)
{
    string sText = "The quick brown fox jumps over the lazy dog";
    string sMessage = IntToHexString(nColor) + ": " + sText;
    SendMessageToPC(oPC, HexColorString(sMessage, nColor));
}

void PrintColors(object oPC)
{
    PrintColor(oPC, "Black", COLOR_BLACK);
    PrintColor(oPC, "Blue", COLOR_BLUE);
    PrintColor(oPC, "Dark Blue", COLOR_BLUE_DARK);
    PrintColor(oPC, "Light Blue", COLOR_BLUE_LIGHT);
    PrintColor(oPC, "Brown", COLOR_BROWN);
    PrintColor(oPC, "Light Brown", COLOR_BROWN_LIGHT);
    PrintColor(oPC, "Gold", COLOR_GOLD);
    PrintColor(oPC, "Gray", COLOR_GRAY);
    PrintColor(oPC, "Dark Gray", COLOR_GRAY_DARK);
    PrintColor(oPC, "Light Gray", COLOR_GRAY_LIGHT);
    PrintColor(oPC, "Green", COLOR_GREEN);
    PrintColor(oPC, "Dark Green", COLOR_GREEN_DARK);
    PrintColor(oPC, "Light Green", COLOR_GREEN_LIGHT);
    PrintColor(oPC, "Orange", COLOR_ORANGE);
    PrintColor(oPC, "Dark Orange", COLOR_ORANGE_DARK);
    PrintColor(oPC, "Light Orange", COLOR_ORANGE_LIGHT);
    PrintColor(oPC, "Red", COLOR_RED);
    PrintColor(oPC, "Dark Red", COLOR_RED_DARK);
    PrintColor(oPC, "Light Red", COLOR_RED_LIGHT);
    PrintColor(oPC, "Pink", COLOR_PINK);
    PrintColor(oPC, "Purple", COLOR_PURPLE);
    PrintColor(oPC, "Turquoise", COLOR_TURQUOISE);
    PrintColor(oPC, "Violet", COLOR_VIOLET);
    PrintColor(oPC, "Light Violet", COLOR_VIOLET_LIGHT);
    PrintColor(oPC, "Dark Violet", COLOR_VIOLET_DARK);
    PrintColor(oPC, "White", COLOR_WHITE);
    PrintColor(oPC, "Yellow", COLOR_YELLOW);
    PrintColor(oPC, "Dark Yellow", COLOR_YELLOW_DARK);
    PrintColor(oPC, "Light Yellow", COLOR_YELLOW_LIGHT);

    PrintHexColor(oPC, 0x0099fe);
    PrintHexColor(oPC, 0x3dc93d);

    struct HSV hsv = HexToHSV(0xff0000);
    PrintHexColor(oPC, HSVToHex(hsv));
    SendMessageToPC(oPC, "H: " + FloatToString(hsv.h) +
                        " S: " + FloatToString(hsv.s) +
                        " V: " + FloatToString(hsv.v));
    hsv.v /= 2.0;
    hsv.s = 0.0;
    PrintHexColor(oPC, HSVToHex(hsv));
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("core_demo"))
    {
        object oPlugin = CreatePlugin("core_demo");
        SetName(oPlugin, "[Plugin] Core Framework Demo");
        SetDescription(oPlugin,
            "This plugin provides some simple demos of the Core Framework.");
        SetDebugPrefix(GetName(oPlugin), oPlugin);

        RegisterEventScript(oPlugin, PLACEABLE_EVENT_ON_USED, "VerifyEvent");
        RegisterEventScript(oPlugin, "CHAT_!colors", "PrintColors");
        RegisterEventScript(oPlugin, "TestTimer", "VerifyEvent");
    }

    // This plugin is created from a blueprint
    if (!GetIfPluginExists("bw_defaultevents"))
    {
        object oPlugin = CreatePlugin("bw_defaultevents");
        SetDebugPrefix(GetName(oPlugin), oPlugin);
    }

    RegisterLibraryScript("VerifyEvent", 1);
    RegisterLibraryScript("PrintColors", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    object oPC = GetEventTriggeredBy();
    switch (nEntry)
    {
        case 1: VerifyEvent(oPC); break;
        case 2: PrintColors(oPC); break;
        default:
            CriticalError("Library function " + sScript + " not found");
    }
}
/// -----------------------------------------------------------------------------
/// @file   dlg_c_dialogs.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (configuation script)
/// -----------------------------------------------------------------------------
/// This is the main configuration script for the Dynamic Dialogs system. It
/// contains user-definable toggles and settings. You may alter the values of any
/// of the below constants, but do not change the names of the constants
/// themselves. This file is consumed by dlg_i_dialogs as an include directive.
/// -----------------------------------------------------------------------------

#include "util_i_color"

// ----- Automated Response Labels ---------------------------------------------

// All of these labels can be adjusted on a per-dialog or per-page basis using
// SetDialogLabel().

// This is the default label for the automated "Continue" response. This
// response is shown when the current page has been assigned continue text.
const string DLG_LABEL_CONTINUE = "[Continue]";

// This is the default label for the automated "End Dialog" response. This
// response is shown when EnableDialogNode(DLG_NODE_END) is called on the dialog
// or page.
const string DLG_LABEL_END = "[End Dialog]";

// This is the default label shown for the automated "Previous" response when
// the list of responses is too long to appear on one page.
const string DLG_LABEL_PREV = "[Previous]";

// This is the default label shown for the automated "Next" response when the
// list of responses is too long to appear on one page.
const string DLG_LABEL_NEXT = "[Next]";

// This is the default label shown for the automated "Back" button. This is
// shown when EnableDialogNode(DLG_NODE_BACK) is called on the dialog or page.
const string DLG_LABEL_BACK = "[Back]";

// ----- Colors ----------------------------------------------------------------

// The following are hex color codes used for automated responses. You can also
// use any of the COLOR_* constants included in util_i_color. If the value for
// one of these node types is negative, the default color (white for NPC text
// and light blue for PC responses) will be used instead. These settings can be
// adjusted on a per-dialog or per-page basis using SetDialogColor().
const int DLG_COLOR_CONTINUE = COLOR_BLUE_DODGER;
const int DLG_COLOR_END      = COLOR_RED;
const int DLG_COLOR_PREV     = COLOR_GREEN_LIME;
const int DLG_COLOR_NEXT     = COLOR_GREEN_LIME;
const int DLG_COLOR_BACK     = COLOR_YELLOW;

// This is the hex code used to color text enclosed in the <StartAction> tag.
const int DLG_COLOR_ACTION = COLOR_GREEN_LIME;

// This is the hex code used to color text enclosed in the <StartCheck> tag.
const int DLG_COLOR_CHECK = COLOR_RED;

// This is the hex code used to color text enclosed in the <StartHighlight> tag.
const int DLG_COLOR_HIGHLIGHT = COLOR_BLUE_DODGER;

// ----- Miscellaneous ---------------------------------------------------------

// The maximum number of non-automated responses that can be shown on a single
// page. If this is increased, additional nodes must be added to the dlg_conv*
// conversations; the total number of nodes must be DLG_MAX_RESPONSES + 5.
const int DLG_MAX_RESPONSES = 10;
/// -----------------------------------------------------------------------------
/// @file   dlg_dialogabort.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (event script)
/// -----------------------------------------------------------------------------
/// This script handles abnormal ends for dialogs. It should be placed in the
/// "Aborted" script slot in the Current File tab of the dynamic dialog template
/// conversation.
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"

void main()
{
    SendDialogEvent(DLG_EVENT_ABORT);
    DialogCleanup();
}

/// -----------------------------------------------------------------------------
/// @file   dlg_e_dialogs.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (event script)
/// -----------------------------------------------------------------------------
/// This script handles node-based events for dialogs.  This script should be
/// assigned to all of the script locations below.  In addition, set up script
/// parameters as follows:
///                                 Script Param:   Param Value:
///     "Text Appears When" Tab:
///         NPC Nodes               *Action         *Page     
///         PC Nodes                *Action         *Check 
///     "Actions Taken" Tab:        *Action         *Node
///                                 *Node           <node number>
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"

int StartingConditional()
{
    string sAction = GetScriptParam(DLG_ACTION);
    if (sAction == DLG_ACTION_CHECK)
    {
        int nNodes = GetLocalInt(DIALOG, DLG_NODES);
        int nNode  = GetLocalInt(DIALOG, DLG_NODE);
        string sText = GetLocalString(DIALOG, DLG_NODES + IntToString(nNode));

        SetLocalInt(DIALOG, DLG_NODE, nNode + 1);
        SetCustomToken(DLG_CUSTOM_TOKEN + nNode + 1, sText);
        return (nNode < nNodes);
    }   
    else if (sAction == DLG_ACTION_NODE)
    {
        int nNode = StringToInt(GetScriptParam(DLG_NODE));
        DoDialogNode(nNode);
    }
    else if (sAction == DLG_ACTION_PAGE)
    {
        int nState = GetDialogState();
        if (nState == DLG_STATE_ENDED)
            return FALSE;

        if (nState == DLG_STATE_INIT)
            InitializeDialog();

        if (!LoadDialogPage())
            return FALSE;

        LoadDialogNodes();
        return TRUE;
    }
    
    return FALSE;
}
/// -----------------------------------------------------------------------------
/// @file   dlg_dialogend.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (event script)
/// -----------------------------------------------------------------------------
/// This script handles normal ends for dialogs. It should be placed in the
/// "Normal" script slot in the Current File tab of the dynamic dialog template
/// conversation.
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"

void main()
{
    SendDialogEvent(DLG_EVENT_END);
    DialogCleanup();
}
/// -----------------------------------------------------------------------------
/// @file   dlg_i_dialogs.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (include script)
/// -----------------------------------------------------------------------------
/// This is the main include file for the Dynamic Dialogs system. It should not be
/// edited by the builder. Place all customization in dlg_c_dialogs instead.
/// -----------------------------------------------------------------------------
/// Acknowledgements:
/// This system is inspired by Acaos's HG Dialog system and Greyhawk0's
/// ZZ-Dialog, which is itself based on pspeed's Z-dialog.
/// -----------------------------------------------------------------------------
/// System Design:
/// A dialog is made up of pages (NPC text) and nodes (PC responses). Both pages
/// and nodes have text which is displayed to the player. Nodes also have a
/// target, a page that will be shown when the player clicks the node. By
/// default, all nodes added to a page will be shown, but they can be filtered
/// based on conditions (see below).
///
/// The system is event-driven, with the following events accessible from the
/// dialog script using GetDialogEvent():
///   - DLG_EVENT_INIT: Initial setup. Pages and nodes are added to map the
///     dialog.
///   - DLG_EVENT_PAGE: A page is shown to the PC. Text can be altered before
///     being shown, nodes can be filtered out using FilterDialogNodes(), and you
///     can even change the page being shown.
///   - DLG_EVENT_NODE: A node was clicked. The page and node are accessible
///     using GetDialogPage() and GetDialogNode(), respectively. You can set a
///     new target for the page if you do not want the one that was already
///     assigned to the node.
///   - DLG_EVENT_END: The dialog was ended normally (through an End Dialog node
///     or a page with no responses).
///   - DLG_EVENT_ABORT: The dialog was aborted by the player.
/// -----------------------------------------------------------------------------

#include "util_i_datapoint"
#include "util_i_debug"
#include "util_i_libraries"
#include "util_i_lists"
#include "dlg_c_dialogs"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DLG_SYSTEM = "Dynamic Dialogs System";
const string DLG_PREFIX = "Dynamic Dialog: ";

const string DLG_RESREF_ZOOM   = "dlg_convzoom";
const string DLG_RESREF_NOZOOM = "dlg_convnozoom";

// ----- VarNames --------------------------------------------------------------

const string DLG_DIALOG        = "*Dialog";
const string DLG_CURRENT_PAGE  = "*CurrentPage";
const string DLG_CURRENT_NODE  = "*CurrentNode";
const string DLG_INITIALIZED   = "*Initialized";
const string DLG_HAS           = "*Has";
const string DLG_NODE          = "*Node";
const string DLG_NODES         = "*Nodes";
const string DLG_TEXT          = "*Text";
const string DLG_DATA          = "*Data";
const string DLG_TARGET        = "*Target";
const string DLG_ENABLED       = "*Enabled";
const string DLG_COLOR         = "*Color";
const string DLG_CONTINUE      = "*Continue";
const string DLG_HISTORY       = "*History";
const string DLG_OFFSET        = "*Offset";
const string DLG_FILTER        = "*Filter";
const string DLG_FILTER_MAX    = "*FilterMax";
const string DLG_SPEAKER       = "*Speaker";
const string DLG_PRIVATE       = "*Private";
const string DLG_NO_ZOOM       = "*NoZoom";
const string DLG_NO_HELLO      = "*NoHello";
const string DLG_TOKEN         = "*Token";
const string DLG_TOKEN_CACHE   = "*TokenCache";
const string DLG_TOKEN_VALUES  = "*TokenValues";
const string DLG_ACTION        = "*Action";
const string DLG_ACTION_CHECK  = "*Check";
const string DLG_ACTION_NODE   = "*Node";
const string DLG_ACTION_PAGE   = "*Page";

// ----- Automated Node IDs ----------------------------------------------------

const int DLG_NODE_NONE     = -1;
const int DLG_NODE_CONTINUE = -2;
const int DLG_NODE_END      = -3;
const int DLG_NODE_PREV     = -4;
const int DLG_NODE_NEXT     = -5;
const int DLG_NODE_BACK     = -6;

// ----- Dialog States ---------------------------------------------------------

const string DLG_STATE = "*State";
const int    DLG_STATE_INIT    = 0; // Dialog is new and uninitialized
const int    DLG_STATE_RUNNING = 1; // Dialog is running normally
const int    DLG_STATE_ENDED   = 2; // Dialog has ended

// ----- Dialog Events ---------------------------------------------------------

const string DLG_EVENT = "*Event";
const int    DLG_EVENT_NONE  = 0x00;
const int    DLG_EVENT_INIT  = 0x01; // Dialog setup and initialization
const int    DLG_EVENT_PAGE  = 0x02; // Page choice and action
const int    DLG_EVENT_NODE  = 0x04; // Node selected action
const int    DLG_EVENT_END   = 0x08; // Dialog ended normally
const int    DLG_EVENT_ABORT = 0x10; // Dialog ended abnormally
const int    DLG_EVENT_ALL   = 0x1f;

const string DIALOG_EVENT_ON_INIT  = "OnDialogInit";
const string DIALOG_EVENT_ON_PAGE  = "OnDialogPage";
const string DIALOG_EVENT_ON_NODE  = "OnDialogNode";
const string DIALOG_EVENT_ON_END   = "OnDialogEnd";
const string DIALOG_EVENT_ON_ABORT = "OnDialogAbort";

// ----- Event Prioroties ------------------------------------------------------

const float DLG_PRIORITY_FIRST   = 10.0;
const float DLG_PRIORITY_DEFAULT =  5.0;
const float DLG_PRIORITY_LAST    =  0.0;

// ----- Event Script Processing -----------------------------------------------
const int DLG_SCRIPT_OK    = 0;
const int DLG_SCRIPT_ABORT = 1;

// ----- Custom Token Reservation ----------------------------------------------

const int DLG_CUSTOM_TOKEN = 20000;

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

object DIALOGS  = GetDatapoint(DLG_SYSTEM);
object DIALOG   = GetLocalObject(GetPCSpeaker(), DLG_SYSTEM);
object DLG_SELF = GetLocalObject(GetPCSpeaker(), DLG_SPEAKER);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Utility Functions -----------------------------------------------------

/// @brief Converts a DLG_EVENT_* constant to its string representation.
/// @param nEvent DLG_EVENT_* constant.
/// @returns DLG_EVENT_ON_* constant.
string DialogEventToString(int nEvent);

/// @brief Initiates a conversation.
/// @param oPC The player character to speak with.
/// @param oTarget The object (usually a creature) that oPC will speak with.
/// @param sDialog The library script to use for the conversation.  If blank,
///     the system will look for the string variable `*Dialog` on oTarget.
/// @param bPrivate If TRUE, prevents other players from hearing the conversation.
/// @param bNoHello If TRUE, prevents the "hello" voicechat from playing on dialog
///     start.
/// @param bNoZoom If TRUE, prevents zooming in towards oPC on dialog start.
/// @note If oTarget is not a creature or placeable, oPC will talk to themselves.
void StartDialog(object oPC, object oTarget = OBJECT_SELF, string sDialog = "", int bPrivate = FALSE, int bNoHello = FALSE, int bNoZoom = FALSE);

// ----- Dialog Setup ----------------------------------------------------------

/// @brief Returns whether sPage exists in the dialog.
/// @param sPage The page name to search for.
int HasDialogPage(string sPage);

/// @brief Adds a dialog page.
/// @param sPage The name of the page to add.  If sPage already exists, a new
///     page of a continuation chain is added.
/// @param sText The body text to add to sPage.
/// @param sData An arbitrary string used to store additional information.
/// @returns The name of the added page.
/// @warning Page names should not contain a `#` symbol.
string AddDialogPage(string sPage, string sText = "", string sData = "");

/// @brief Links a page to a target using a continue node.
/// @param sPage Page name to link to sTarget.
/// @param sTarget Page name to link to sPage.
/// @note This function is called automatically when adding multiple pages of
///     the same name with AddDialogPage(), but this function can be called
///     separately to end a continue chain.
void ContinueDialogPage(string sPage, string sTarget);

/// @brief Add a response node to a dialog page.
/// @param sPage Page to add the response node to.
/// @param sTarget Page to link to the dialog node.
/// @param sText Text to display on the dialog node.
/// @param sData An arbitrary string used to store additional information.
int AddDialogNode(string sPage, string sTarget, string sText, string sData = "");

/// @brief Returns the number of dialog nodes on a dialog page.
/// @param sPage Page name to count dialog nodes on.
int CountDialogNodes(string sPage);

/// @brief Copy a dialog node from one page to another.
/// @param sSource Page to copy a dialog node from.
/// @param nSource Index of dialog node to copy from.
/// @param sTarget Page to copy dialog node to.
/// @param nTarget Index of dialog node to copy to.
/// @returns Index of the copied node; -1 on error.
/// @note If nTarget = DLG_NODE_NONE, the copied node will be added to
///     the end of sTarget's dialog node list.
int CopyDialogNode(string sSource, int nSource, string sTarget, int nTarget = DLG_NODE_NONE);

/// @brief Copy all dialog nodes from one page to another.
/// @param sSource Page to copy dialog nodes from.
/// @param sTarget Page to copy dialog nodes to.
/// @returns sTarget's dialog node count after the copy operation.
int CopyDialogNodes(string sSource, string sTarget);

/// @brief Delete a dialog node.
/// @param sPage Page to delete dialog node from.
/// @param nNode Index of dialog node to delete.
/// @returns sPage's dialog node count after the delete operation.
int DeleteDialogNode(string sPage, int nNode);

/// @brief Delete all dialog nodes on a page.
/// @param sPage Page to delete all dialog nodes from.
void DeleteDialogNodes(string sPage);

/// @brief Hide specific dialog nodes from the conversation window.
/// @param nStart Index of dialog node to begin hiding from.
/// @param nEnd Index of dialog node to end hiding at.
/// @note Dialog nodes will be hidden on the currently displayed page.
/// @note If nEnd < 0, only the dialog node at nStart will be hidden.
void FilterDialogNodes(int nStart, int nEnd = -1);

// ----- Accessor Functions ----------------------------------------------------

/// @brief Returns the name of the current dialog.
string GetDialog();

/// @brief Determine the source of a page's dialog nodes.
/// @param sPage Page whose dialog node source is to be determined.
string GetDialogNodes(string sPage);

/// @brief Force a page to use dialog nodes from another page.
/// @param sPage Page whose dialog nodes will be overwritten.
/// @param sSource Page where dialog nodes will be sourced from.
/// @note If sSource = "", sPage will return to using its original dialog nodes.
void SetDialogNodes(string sPage, string sSource = "");

/// @brief Get the text from a specific dialog node.
/// @param sPage Page to search dialog nodes on.
/// @param nNode Index of dialog node to search.
/// @note If nNode = DLG_NODE_NONE, text from sPage will be retrieved.
string GetDialogText(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the text on a specific dialog node.
/// @param sText Dialog node text.
/// @param sPage Page to set dialog node text on.
/// @param nNode Index of dialog node to set text on.
/// @note If nNode = DLG_NODE_NONE, sPage's text will be set to sText.
void SetDialogText(string sText, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Get the dialog data from a dialog node.
/// @param sPage Page to retrieve dialog node data from.
/// @param nNode Index of dialog node to retrieve data from.
/// @note If nNode = DLG_NODE_NONE, data from sPage will be retrieved.
string GetDialogData(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the dialog data on a dialog node.
/// @param sData Data to set.
/// @param sPage Page to set dialog data on.
/// @param nNode Index of dialog node to set data on.
/// @note If nNode = DLG_NODE_NONE, sData will be set on sPage.
void SetDialogData(string sData, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Find the target of a dialog node.
/// @param sPage Page containing the dialog node to search for.
/// @param nNode Index of dialog node to search for.
/// @returns Page name of dialog node's target.
/// @note If nNode = DLG_NODE_NONE, sPage's target will be retrieved.
string GetDialogTarget(string sPage, int nNode = DLG_NODE_NONE);

/// @brief Set the target of a dialog node.
/// @param sTarget Page name of target to set on dialog node.
/// @param spage Page containing dialog node to set target on.
/// @param nNode Index of dialog node to set target on.
/// @note If nNode = DLG_NODE_NONE, sTarget will be set on sPage.
void SetDialogTarget(string sTarget, string sPage, int nNode = DLG_NODE_NONE);

/// @brief Get the state of the currently running dialog.
/// @returns DLG_STATE_* constant:
///     DLG_STATE_INIT: the dialog is new and uninitialized.
///     DLG_STATE_RUNNING: the dialog has been initialized or is in progress.
///     DLG_STATE_ENDED: the dialog has finished.
int GetDialogState();

/// @brief Set the state of the currently running dialog:
/// @param nState DLG_STATE_* constant:
///     DLG_STATE_INIT: the dialog is new and uninitialized.
///     DLG_STATE_RUNNING: the dialog has been initialized or is in progress.
///     DLG_STATE_ENDED: the dialog has finished.
void SetDialogState(int nState);

/// @brief Returns a comma-separated list of previously visited page names, in
///     reverse order of visitation.
string GetDialogHistory();

/// @brief Sets the currently running dialog's history.
/// @param sHistory A comma-separated list of previously visited pages, in reverse
///     order of visitation.
void SetDialogHistory(string sHistory);

/// @brief Clear the currently running dialog's history.
void ClearDialogHistory();

/// @brief Return the current dialog page.
string GetDialogPage();

/// @brief Return the current dialog page number.
/// @returns 1, if the current page is a parent page; the page number if the 
///     current page is a child page; 0, in case of error or page number cannot
///     be determined.
int GetDialogPageNumber();

/// @brief Return the page name of the current dialog page's parent.
/// @note If the current dialog page is not a child page, returns "".
string GetDialogPageParent();

/// @brief Set the current dialog page.
/// @param sPage Page to set as the current dialog page.
/// @param nPage Page number to set as the current dialog page, if sPage has
///     continuation/child pages.
void SetDialogPage(string sPage, int nPage = 1);

/// @brief Return the index of the last-selected dialog node.
/// @note Returns DLG_NODE_NONE if no node has been selected yet.
int GetDialogNode();

/// @brief Sets the index of the last-selected dialog node.
/// @param nNode Index of dialog node to set as last-selected.
/// @warning Using this function without understanding its repurcussions can
///     cause unexpected behavior.
void SetDialogNode(int nNode);

/// @brief Get the current dialog event.
/// @returns DLG_EVENT_* constant:
///     DLG_EVENT_INIT: dialog setup and initialization
///     DLG_EVENT_PAGE: page choice and action
///     DLG_EVENT_NODE: node selected action
///     DLG_EVENT_END: dialog ended normally
///     DLG_EVENT_ABORT: dialog ended abnormally
int GetDialogEvent();

/// @brief Alias for GetDialogText() for automated nodes.
/// @param nNode Index of dialog node to get text from.
/// @param sPage Page to search for nNode on.
/// @note If sPage = "", nNode's label for all pages will be returned.
string GetDialogLabel(int nNode, string sPage = "");

/// @brief Alias for SetDialogText() for automated nodes.
/// @param nNode Index of dialog node to set text on.
/// @param sLabel Text to set on dialog node.
/// @param sPage Page to set dialog text on.
/// @note If sPage = "", nNode's label for all pages will be set to sLabel.
void SetDialogLabel(int nNode, string sLabel, string sPage = "");

/// @brief Enable a dialog node.
/// @param nNode Index of dialog node to enable.
/// @param sPage Page to enable dialog node on.
/// @note If sPage = "", nNode will be enabled on all pages.
void EnableDialogNode(int nNode, string sPage = "");

/// @brief Disable a dialog node.
/// @param nNode Index of dialog node to disable.
/// @param sPage Page to disable dialog node on.
/// @note If sPage = "", nNode will be enabled on all pages.
void DisableDialogNode(int nNode, string sPage = "");

/// @brief Returns whether a dialog node is enabled.
/// @param nNode Index of dialog node to check.
/// @param sPage Page to check for enabled dialog node.
/// @note If sPage = "", will return whether nNode is enable for the dialog
///     in general.
int DialogNodeEnabled(int nNode, string sPage = "");

/// @brief Enable the automated end dialog node.
/// @param sLabel Text to set on the end dialog node.
/// @param sPage Page to set the enable the end dialog node on.
/// @note If sPage = "", end dialog node will be labeled and enabled on all
///     dialog pages.
/// @note This function is equivalent to calling:
///     EnableDialogNode(DLG_NODE_END, sPage);
///     SetDialogLabel(DLG_NODE_END, sLabel, sPage);
void EnableDialogEnd(string sLabel = DLG_LABEL_END, string sPage = "");

/// @brief Enable the automated back dialog node.
/// @param sLabel Text to set on the back dialog node.
/// @param sPage Page to set the enable the back dialog node on.
/// @note If sPage = "", back dialog node will be labeled and enabled on all
///     dialog pages.
/// @note This function is equivalent to calling:
///     EnableDialogNode(DLG_NODE_BACK, sPage);
///     SetDialogLabel(DLG_NODE_BACK, sLabel, sPage);
void EnableDialogBack(string sLabel = DLG_LABEL_BACK, string sPage = "");

/// @brief Returns the number of nodes before the first node displayed on the
///     dialog response list.
int GetDialogOffset();

/// @brief Set the index of the first dialog node to be shown on the dialog
///     response list.
/// @param nOffset Index of dialog node.
/// @note If nOffset > 0, the automated previous node will be displayed.
void SetDialogOffset(int nOffset);

/// @brief Returns the filter that controls the display of a node.
/// @param nPos Index of dialog node to check filter for.
int GetDialogFilter(int nPos = 0);

/// @brief Return the color constant used to color an automated dialog node.
/// @param nNode Index of automated dialog node.
/// @param sPage Page containing nNode.
/// @warning The nwn color code is returned, not a hex color.
string GetDialogColor(int nNode, string sPage = "");

/// @brief Set the hex color used to color an automated dialog node.
/// @param nNode Index of automated dialog node to color.
/// @param nColor Hex color used to color dialog nodes.
/// @param sPage Page containing nNode.
/// @note If sPage = "", nNode on every dialog page will be colored.
void SetDialogColor(int nNode, int nColor, string sPage = "");

// ----- Dialog Tokens ---------------------------------------------------------

/// @brief Returns the form of a token used with AddDialogToken(). If all
///     lowercase, the token can resolve to uppercase or lowercase, depending
///     on the value of sToken. Otherwise, the value will not have its case changed.
/// @param sToken String token to normalize.
/// @returns sToken with appropriate capitalization applied.
string NormalizeDialogToken(string sToken);

/// @brief Used in token evaluation scripts to set the value the token should resolve
///     to. If the value can be either lowercase or uppercase, always set the
///     uppercase version.
/// @param sValue Value to set dialog token to.
void SetDialogTokenValue(string sValue);

/// @brief Adds a token, which will be evaluated at displaytime by the library script
///     sEvalScript. If sToken is all lowercase, the token can be used in either
///     upper- or lowercase forms. Otherwise, the token is case-sensitive and must
///     match sToken. sValues is a CSV list of possible values that can be handed to
///     sEvalScript.
/// @param sToken Token to add to dialog token list.
/// @param sEvalScript Script or function that will be run to determine value of sToken.
/// @param sValues Comma-separated list of possible values that will be passed to
void AddDialogToken(string sToken, string sEvalScript = "", string sValues = "");

/// @brief Add all default dialog tokens.  This is called by the system during the
///     dialog init stage and need not be used by the builder.
void AddDialogTokens();

/// @brief Add a cached dialog token with a known value.
/// @param sToken Name of dialog token.
/// @param sValue Cached value of dialog token.
/// @note If a dialog token's value will generally not change, this function can
///     be used to hasten token resolution.
void AddCachedDialogToken(string sToken, string sValue);

/// @brief Returns a cached token value.
/// @param sToken Name of dialog token.
string GetCachedDialogToken(string sToken);

/// @brief Caches the value of a token so that the eval script does not have to run
///     every time the token is encountered. This cache lasts for the lifetime of the
///     dialog.
/// @param sToken Name of dialog token.
/// @param sValue Cached value of dialog token. 
void CacheDialogToken(string sToken, string sValue);

/// @brief Clears the cache for sToken, ensuring that the next time the token is
///     encountered, its eval script will run again.
/// @param sToken Name of dialog token.
void UnCacheDialogToken(string sToken);

/// @brief Runs the appropriate evaluation script for sToken using oPC as OBJECT_SELF.
///     Returns the token value. This is called by the system and need not be used by
///     the builder.
/// @param sToken Name of dialog token.
/// @param oPC Player object running current dialog.
string EvalDialogToken(string sToken, object oPC);

/// @brief Evaluates all tokens in sString and interpolates them. This is called by the
///     system and need not be used by the builder.
/// @param sString String containing tokens to be evaluated.
string EvalDialogTokens(string sString);

// ----- System Functions ------------------------------------------------------

/// @brief Returns the object holding cached dialog data.
/// @param sDialog Name of dialog.
object GetDialogCache(string sDialog);

/// @brief Registers a library script as handling particular events for a dialog.
/// @param sDialog Name of dialog to register events to.
/// @param sScript Name of dialog script to register.
/// @param nEvents Bitmasked list of DLG_EVENT_* constants to register.
/// @param fPriority Determines order in which scripts will be called.
/// @note fPriority is useful if there are multiple scripts that have been
//      registered for this event to this dialog. This is useful if you want to have
//      outside scripts add or handle new nodes and pages.
void RegisterDialogScript(string sDialog, string sScript = "", int nEvents = DLG_EVENT_ALL, float fPriority = DLG_PRIORITY_DEFAULT);

/// @brief Sorts all scripts registered to the current dialog by priority.
/// @param nEvent DLG_EVENT_* constant.
void SortDialogScripts(int nEvent);

/// @brief Calls all scripts registered to nEvent for the current dialog in order of
///     priority.
/// @param nEvent DLG_EVENT_* constant.
/// @note The called scripts can use LibraryReturn(DLG_SCRIPT_ABORT) to stop remaining
///     scripts from firing.
void SendDialogEvent(int nEvent);

/// @brief Creates a cache for the current dialog and send the DLG_EVENT_INIT event if
///     it was not already created, instantiates the cache for the current PC, and
///     sets the dialog state to DLG_STATE_RUNNING.
void InitializeDialog();

/// @brief Runs the DLG_EVENT_PAGE event for the current page and sets the page text.
/// @returns Whether a valid page was returned and the dialog should continue.
int LoadDialogPage();

/// @brief Evaluates which nodes should be shown to the PC and sets the appropriate
///     text.
void LoadDialogNodes();

/// @brief Sends the DLG_EVENT_NODE event for the node represented by a PC response.
/// @param nClicked Dialog node clicked by PC.
void DoDialogNode(int nClicked);

/// @brief Cleans up leftover dialog data when a conversation ends.
void DialogCleanup();

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Utility Functions -----------------------------------------------------

// Private function used below
string NodeToString(string sPage, int nNode = DLG_NODE_NONE)
{
    if (nNode == DLG_NODE_NONE)
        return sPage;

    return sPage + DLG_NODE + IntToString(nNode);
}

string DialogEventToString(int nEvent)
{
    switch (nEvent)
    {
        case DLG_EVENT_INIT:  return DIALOG_EVENT_ON_INIT;
        case DLG_EVENT_PAGE:  return DIALOG_EVENT_ON_PAGE;
        case DLG_EVENT_NODE:  return DIALOG_EVENT_ON_NODE;
        case DLG_EVENT_END:   return DIALOG_EVENT_ON_END;
        case DLG_EVENT_ABORT: return DIALOG_EVENT_ON_ABORT;
     }

     return "";
}

void StartDialog(object oPC, object oTarget = OBJECT_SELF, string sDialog = "", int bPrivate = FALSE, int bNoHello = FALSE, int bNoZoom = FALSE)
{
    if (sDialog != "")
        SetLocalString(oPC, DLG_DIALOG, sDialog);

    // Since dialog zoom is not exposed to scripting, we use two dialogs: one
    // that zooms and one that doesn't.
    string sResRef = (bNoZoom ? DLG_RESREF_NOZOOM : DLG_RESREF_ZOOM);

    // If the object is not a creature or placeable, we will have the PC talk
    // with himself.
    int nType = GetObjectType(oTarget);
    if (nType != OBJECT_TYPE_PLACEABLE && nType != OBJECT_TYPE_CREATURE)
    {
        // Set the NPC speaker on the PC so we can get the object the PC is
        // supposed to be speaking with.
        SetLocalObject(oPC, DLG_SPEAKER, oTarget);
        oTarget = oPC;
    }

    AssignCommand(oPC, ActionStartConversation(oTarget, sResRef, bPrivate, !bNoHello));
}

// ----- Dialog Setup ----------------------------------------------------------

int HasDialogPage(string sPage)
{
    if (sPage == "")
        return FALSE;

    return GetLocalInt(DIALOG, sPage + DLG_HAS);
}

string AddDialogPage(string sPage, string sText = "", string sData = "")
{
    if (HasDialogPage(sPage))
    {
        int nCount = GetLocalInt(DIALOG, sPage + DLG_CONTINUE);
        SetLocalInt(DIALOG, sPage + DLG_CONTINUE, ++nCount);

        string sParent = sPage;

        // Page -> Page#2 -> Page#3...
        if (nCount > 1)
            sParent += "#" + IntToString(nCount);

        sPage += "#" + IntToString(nCount + 1);
        EnableDialogNode(DLG_NODE_CONTINUE, sParent);
        SetDialogTarget(sPage, sParent, DLG_NODE_CONTINUE);
    }

    Debug("Adding dialog page " + sPage);
    SetLocalString(DIALOG, sPage + DLG_TEXT,  sText);
    SetLocalString(DIALOG, sPage + DLG_DATA,  sData);
    SetLocalString(DIALOG, sPage + DLG_NODES, sPage);
    SetLocalInt   (DIALOG, sPage + DLG_HAS,   TRUE);
    return sPage;
}

void ContinueDialogPage(string sPage, string sTarget)
{
    EnableDialogNode(DLG_NODE_CONTINUE, sPage);
    SetDialogTarget(sTarget, sPage, DLG_NODE_CONTINUE);
}

int AddDialogNode(string sPage, string sTarget, string sText, string sData = "")
{
    if (sPage == "")
        return DLG_NODE_NONE;

    int    nNode = GetLocalInt(DIALOG, sPage + DLG_NODES);
    string sNode = NodeToString(sPage, nNode);

    Debug("Adding dialog node " + sNode);
    SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
    SetLocalString(DIALOG, sNode + DLG_TARGET, sTarget);
    SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
    SetLocalInt   (DIALOG, sPage + DLG_NODES,  nNode + 1);
    return nNode;
}

int CountDialogNodes(string sPage)
{
    return GetLocalInt(DIALOG, sPage + DLG_NODES);
}

int CopyDialogNode(string sSource, int nSource, string sTarget, int nTarget = DLG_NODE_NONE)
{
    int nSourceCount = CountDialogNodes(sSource);
    int nTargetCount = CountDialogNodes(sTarget);

    if (nSource >= nSourceCount || nTarget >= nTargetCount)
        return DLG_NODE_NONE;

    if (nTarget == DLG_NODE_NONE)
    {
        nTarget = nTargetCount;
        SetLocalInt(DIALOG, sSource + DLG_NODES, ++nTargetCount);
    }

    string sText, sData, sDest;
    sSource = NodeToString(sSource, nSource);
    sTarget = NodeToString(sTarget, nTarget);
    sText = GetLocalString(DIALOG, sSource + DLG_TEXT);
    sData = GetLocalString(DIALOG, sSource + DLG_DATA);
    sDest = GetLocalString(DIALOG, sSource + DLG_TARGET);
    SetLocalString(DIALOG, sTarget + DLG_TEXT,   sText);
    SetLocalString(DIALOG, sTarget + DLG_DATA,   sData);
    SetLocalString(DIALOG, sTarget + DLG_TARGET, sDest);
    return nTarget;
}

int CopyDialogNodes(string sSource, string sTarget)
{
    int i;
    int nSource = CountDialogNodes(sSource);
    int nTarget = CountDialogNodes(sTarget);
    string sNode, sText, sData, sDest;

    for (i = 0; i < nSource; i++)
    {
        sNode = NodeToString(sSource, i);
        sText = GetLocalString(DIALOG, sNode + DLG_TEXT);
        sData = GetLocalString(DIALOG, sNode + DLG_DATA);
        sDest = GetLocalString(DIALOG, sNode + DLG_TARGET);

        sNode = NodeToString(sTarget, nTarget + i);
        SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
        SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
        SetLocalString(DIALOG, sNode + DLG_TARGET, sDest);
    }

    nTarget += i;
    SetLocalInt(DIALOG, sTarget + DLG_NODES, nTarget);
    return nTarget;
}

int DeleteDialogNode(string sPage, int nNode)
{
    int nNodes = CountDialogNodes(sPage);
    if (nNode < 0)
        return nNodes;

    string sNode, sText, sData, sDest;
    for (nNode; nNode < nNodes; nNode++)
    {
        sNode = NodeToString(sPage, nNode + 1);
        sText = GetLocalString(DIALOG, sNode + DLG_TEXT);
        sData = GetLocalString(DIALOG, sNode + DLG_DATA);
        sDest = GetLocalString(DIALOG, sNode + DLG_TARGET);

        sNode = NodeToString(sPage, nNode);
        SetLocalString(DIALOG, sNode + DLG_TEXT,   sText);
        SetLocalString(DIALOG, sNode + DLG_DATA,   sData);
        SetLocalString(DIALOG, sNode + DLG_TARGET, sDest);
    }

    SetLocalInt(DIALOG, sPage + DLG_NODES, --nNodes);
    return nNodes;
}

void DeleteDialogNodes(string sPage)
{
    string sNode;
    int i, nNodes = CountDialogNodes(sPage);
    for (i = 0; i < nNodes; i++)
    {
        sNode = NodeToString(sPage, i);
        DeleteLocalString(DIALOG, sNode + DLG_TEXT);
        DeleteLocalString(DIALOG, sNode + DLG_TARGET);
        DeleteLocalString(DIALOG, sNode + DLG_DATA);
    }

    DeleteLocalInt(DIALOG, sPage + DLG_NODES);
}

// Credits: this function was ripped straight from the HG dialog system.
// Nodes are chunked in blocks of 30. Then we set bit flags to note whether a
// node is to be filtered out. So the following would yield 0x17:
//     FilterDialogNodes(0, 2);
//     FilterDialogNodes(4);
void FilterDialogNodes(int nStart, int nEnd = -1)
{
    if (nStart < 0)
        return;

    if (nEnd < 0)
        nEnd = nStart;

    int nBlockStart = nStart / 30;
    int nBlockEnd   = nEnd / 30;

    int i, j, nBitStart, nBitEnd, nFilter;

    for (i = nBlockStart; i <= nBlockEnd; i++)
    {
        nFilter = GetLocalInt(DIALOG, DLG_FILTER + IntToString(i));

        if (i == nBlockStart)
            nBitStart = nStart % 30;
        else
            nBitStart = 0;

        if (i == nBlockEnd)
            nBitEnd = nEnd % 30;
        else
            nBitEnd = 29;

        for (j = nBitStart; j <= nBitEnd; j++)
            nFilter |= 1 << j;

        SetLocalInt(DIALOG, DLG_FILTER + IntToString(i), nFilter);
    }

    int nMax = GetLocalInt(DIALOG, DLG_FILTER_MAX);
    if (nMax <= nBlockEnd)
        SetLocalInt(DIALOG, DLG_FILTER_MAX, nBlockEnd + 1);
}

// ----- Accessor Functions ----------------------------------------------------

string GetDialog()
{
    return GetLocalString(DIALOG, DLG_DIALOG);
}

string GetDialogNodes(string sPage)
{
    return GetLocalString(DIALOG, sPage + DLG_NODES);
}

void SetDialogNodes(string sPage, string sSource = "")
{
    if (sSource == "")
        sSource = sPage;

    SetLocalString(DIALOG, sPage + DLG_NODES, sSource);
}

string GetDialogText(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT);
}

void SetDialogText(string sText, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT, sText);
}

string GetDialogData(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_DATA);
}

void SetDialogData(string sData, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_DATA, sData);
}

string GetDialogTarget(string sPage, int nNode = DLG_NODE_NONE)
{
    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TARGET);
}

void SetDialogTarget(string sTarget, string sPage, int nNode = DLG_NODE_NONE)
{
    SetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TARGET, sTarget);
}

int GetDialogState()
{
    return GetLocalInt(DIALOG, DLG_STATE);
}

void SetDialogState(int nState)
{
    SetLocalInt(DIALOG, DLG_STATE, nState);
}

string GetDialogHistory()
{
    return GetLocalString(DIALOG, DLG_HISTORY);
}

void SetDialogHistory(string sHistory)
{
    SetLocalString(DIALOG, DLG_HISTORY, sHistory);
}

void ClearDialogHistory()
{
    DeleteLocalString(DIALOG, DLG_HISTORY);
}

string GetDialogPage()
{
    return GetLocalString(DIALOG, DLG_CURRENT_PAGE);
}

int GetDialogPageNumber()
{
    string sPageNumber = JsonGetString(JsonArrayGet(RegExpMatch(".*#(\\d*)", GetDialogPage()), 1));
    return sPageNumber == "" ? 1 : StringToInt(sPageNumber);
}

string GetDialogPageParent()
{
    string sPage = GetDialogPage();
    string sName = JsonGetString(JsonArrayGet(RegExpMatch("^(.*)#\\d*", sPage), 1));
    return sName == "" ? sPage : sName;
}

void SetDialogPage(string sPage, int nPage = 1)
{
    string sHistory = GetLocalString(DIALOG, DLG_HISTORY);
    string sCurrent = GetLocalString(DIALOG, DLG_CURRENT_PAGE);

    if (sHistory == "" || sHistory == sCurrent)
        SetLocalString(DIALOG, DLG_HISTORY, sCurrent);
    else if (GetListItem(sHistory, 0) != sCurrent)
        SetLocalString(DIALOG, DLG_HISTORY, MergeLists(sCurrent, sHistory));

    if (nPage > 1)
        sPage += "#" + IntToString(nPage);

    SetLocalString(DIALOG, DLG_CURRENT_PAGE, sPage);
    SetLocalInt(DIALOG, DLG_CURRENT_PAGE, TRUE);
}

int GetDialogNode()
{
    return GetLocalInt(DIALOG, DLG_CURRENT_NODE);
}

void SetDialogNode(int nNode)
{
    SetLocalInt(DIALOG, DLG_CURRENT_NODE, nNode);
}

int GetDialogEvent()
{
    return GetLocalInt(DIALOG, DLG_EVENT);
}

string GetDialogLabel(int nNode, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return "";

    if (!GetLocalInt(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT))
        sPage = "";

    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_TEXT);
}

void SetDialogLabel(int nNode, string sLabel, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return;

    string sNode = NodeToString(sPage, nNode);
    SetLocalString(DIALOG, sNode + DLG_TEXT, sLabel);
    SetLocalInt   (DIALOG, sNode + DLG_TEXT, TRUE);
}

void EnableDialogNode(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    SetLocalInt(DIALOG, sNode + DLG_ENABLED, TRUE);
    SetLocalInt(DIALOG, sNode + DLG_HAS,     TRUE);
}

void DisableDialogNode(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    SetLocalInt(DIALOG, sNode + DLG_ENABLED, FALSE);
    SetLocalInt(DIALOG, sNode + DLG_HAS,     TRUE);
}

int DialogNodeEnabled(int nNode, string sPage = "")
{
    string sNode = NodeToString(sPage, nNode);
    if (!GetLocalInt(DIALOG, sNode + DLG_HAS))
        sNode = NodeToString("", nNode);

    return GetLocalInt(DIALOG, sNode + DLG_ENABLED);
}

void EnableDialogEnd(string sLabel = DLG_LABEL_END, string sPage = "")
{
    EnableDialogNode(DLG_NODE_END, sPage);
    SetDialogLabel(DLG_NODE_END, sLabel, sPage);
}

void EnableDialogBack(string sLabel = DLG_LABEL_BACK, string sPage = "")
{
    EnableDialogNode(DLG_NODE_BACK, sPage);
    SetDialogLabel(DLG_NODE_BACK, sLabel, sPage);
}

int GetDialogOffset()
{
    return GetLocalInt(DIALOG, DLG_OFFSET);
}

void SetDialogOffset(int nOffset)
{
    SetLocalInt(DIALOG, DLG_OFFSET, nOffset);
}

int GetDialogFilter(int nPos = 0)
{
    return GetLocalInt(DIALOG, DLG_FILTER + IntToString(nPos % 30));
}

string GetDialogColor(int nNode, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return "";

    if (!GetLocalInt(DIALOG, NodeToString(sPage, nNode) + DLG_COLOR))
        sPage = "";

    return GetLocalString(DIALOG, NodeToString(sPage, nNode) + DLG_COLOR);
}

void SetDialogColor(int nNode, int nColor, string sPage = "")
{
    if (nNode >= DLG_NODE_NONE)
        return;

    string sNode = NodeToString(sPage, nNode);
    string sColor = HexToColor(nColor);
    SetLocalString(DIALOG, sNode + DLG_COLOR, sColor);
    SetLocalInt   (DIALOG, sNode + DLG_COLOR, TRUE);
}

// ----- Dialog Tokens ---------------------------------------------------------

string NormalizeDialogToken(string sToken)
{
    if (GetLocalInt(DIALOG, DLG_TOKEN + "*" + sToken))
        return sToken;

    string sLower = GetStringLowerCase(sToken);
    if (sToken == sLower || !GetLocalInt(DIALOG, DLG_TOKEN + "*" + sLower))
        return "";

    return sLower;
}

void SetDialogTokenValue(string sValue)
{
    SetLocalString(GetPCSpeaker(), DLG_TOKEN, sValue);
}

void AddDialogToken(string sToken, string sEvalScript, string sValues = "")
{
    SetLocalInt   (DIALOG, DLG_TOKEN + "*" + sToken, TRUE);
    SetLocalString(DIALOG, DLG_TOKEN + "*" + sToken, sEvalScript);
    SetLocalString(DIALOG, DLG_TOKEN_VALUES + "*" + sToken, sValues);
}

void AddDialogTokens()
{
    if (!GetIsLibraryLoaded("dlg_l_tokens"))
        LoadLibrary("dlg_l_tokens");

    string sPrefix = "DialogToken_";
    AddDialogToken("alignment",       sPrefix + "Alignment");
    AddDialogToken("bitch/bastard",   sPrefix + "Gender", "Bastard, Bitch");
    AddDialogToken("boy/girl",        sPrefix + "Gender", "Boy, Girl");
    AddDialogToken("brother/sister",  sPrefix + "Gender", "Brother, Sister");
    AddDialogToken("class",           sPrefix + "Class");
    AddDialogToken("classes",         sPrefix + "Class");
    AddDialogToken("day/night",       sPrefix + "DayNight");
    AddDialogToken("Deity",           sPrefix + "Deity");
    AddDialogToken("FirstName",       sPrefix + "Name");
    AddDialogToken("FullName",        sPrefix + "Name");
    AddDialogToken("gameday",         sPrefix + "GameDate");
    AddDialogToken("gamedate",        sPrefix + "GameDate");
    AddDialogToken("gamehour",        sPrefix + "GameTime");
    AddDialogToken("gameminute",      sPrefix + "GameTime");
    AddDialogToken("gamemonth",       sPrefix + "GameDate");
    AddDialogToken("gamesecond",      sPrefix + "GameTime");
    AddDialogToken("gametime12",      sPrefix + "GameTime");
    AddDialogToken("gametime24",      sPrefix + "GameTime");
    AddDialogToken("gameyear",        sPrefix + "GameDate");
    AddDialogToken("good/evil",       sPrefix + "Alignment");
    AddDialogToken("he/she",          sPrefix + "Gender", "He, She");
    AddDialogToken("him/her",         sPrefix + "Gender", "Him, Her");
    AddDialogToken("his/her",         sPrefix + "Gender", "His, Her");
    AddDialogToken("his/hers",        sPrefix + "Gender", "His, Hers");
    AddDialogToken("lad/lass",        sPrefix + "Gender", "Lad, Lass");
    AddDialogToken("LastName",        sPrefix + "Name");
    AddDialogToken("lawful/chaotic",  sPrefix + "Alignment");
    AddDialogToken("law/chaos",       sPrefix + "Alignment");
    AddDialogToken("level",           sPrefix + "Level");
    AddDialogToken("lord/lady",       sPrefix + "Gender", "Lord, Lady");
    AddDialogToken("male/female",     sPrefix + "Gender", "Male, Female");
    AddDialogToken("man/woman",       sPrefix + "Gender", "Man, Woman");
    AddDialogToken("master/mistress", sPrefix + "Gender", "Master, Mistress");
    AddDialogToken("mister/missus",   sPrefix + "Gender", "Mister, Missus");
    AddDialogToken("PlayerName",      sPrefix + "PlayerName");
    AddDialogToken("quarterday",      sPrefix + "QuarterDay");
    AddDialogToken("race",            sPrefix + "Race");
    AddDialogToken("races",           sPrefix + "Race");
    AddDialogToken("racial",          sPrefix + "Race");
    AddDialogToken("sir/madam",       sPrefix + "Gender", "Sir, Madam");
    AddDialogToken("subrace",         sPrefix + "SubRace");
    AddDialogToken("StartAction",     sPrefix + "Token", HexToColor(DLG_COLOR_ACTION));
    AddDialogToken("StartCheck",      sPrefix + "Token", HexToColor(DLG_COLOR_CHECK));
    AddDialogToken("StartHighlight",  sPrefix + "Token", HexToColor(DLG_COLOR_HIGHLIGHT));
    AddDialogToken("/Start",          sPrefix + "Token", "</c>");
    AddDialogToken("token",           sPrefix + "Token", "<");
    AddDialogToken("/token",          sPrefix + "Token", ">");
}

void AddCachedDialogToken(string sToken, string sValue)
{
    AddDialogToken(sToken);
    CacheDialogToken(sToken, sValue);
}

string GetCachedDialogToken(string sToken)
{
    if (GetLocalInt(DIALOG, DLG_TOKEN_CACHE + "*" + sToken))
        return GetLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken);

    return "";
}

void CacheDialogToken(string sToken, string sValue)
{
    Debug("Caching value for token <" + sToken + ">: " + sValue);
    SetLocalInt   (DIALOG, DLG_TOKEN_CACHE + "*" + sToken, TRUE);
    SetLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken, sValue);
}

void UnCacheDialogToken(string sToken)
{
    Debug("Clearing cache for token <" + sToken + ">");
    DeleteLocalInt   (DIALOG, DLG_TOKEN_CACHE + "*" + sToken);
    DeleteLocalString(DIALOG, DLG_TOKEN_CACHE + "*" + sToken);
}

string EvalDialogToken(string sToken, object oPC)
{
    string sNormal = NormalizeDialogToken(sToken);

    // Ensure this is a valid token
    if (sNormal == "")
        return "<" + sToken + ">";

    // Check the cached token value. This saves us having to run a library
    // script to get a known result.
    string sCached = GetCachedDialogToken(sToken);
    if (sCached != "")
    {
        Debug("Using cached value for token <" + sToken + ">: " + sCached);
        return sCached;
    }

    string sScript = GetLocalString(DIALOG, DLG_TOKEN + "*" + sNormal);
    string sValues = GetLocalString(DIALOG, DLG_TOKEN_VALUES + "*" + sNormal);

    SetLocalString(oPC, DLG_TOKEN, sNormal);
    SetLocalString(oPC, DLG_TOKEN_VALUES, sValues);
    RunLibraryScript(sScript, oPC);

    string sEval = GetLocalString(oPC, DLG_TOKEN);

    // Token eval scripts should always yield the uppercase version of the
    // token. If the desired value is lowercase, we change it here.
    if (sToken == GetStringLowerCase(sToken))
        sEval = GetStringLowerCase(sEval);

    // If we are supposed to cache the results, do so. We have to check the PC
    // since the token script will not have access to the DIALOG object.
    if (GetLocalInt(oPC, DLG_TOKEN_CACHE))
    {
        CacheDialogToken(sToken, sEval);
        DeleteLocalInt(oPC, DLG_TOKEN_CACHE);
    }

    return sEval;
}

string EvalDialogTokens(string sString)
{
    object oPC = GetPCSpeaker();
    json jTokens = RegExpIterate("<(.*?)>", sString);
    if (jTokens == JSON_ARRAY)
        return sString;

    jTokens = JsonArrayTransform(jTokens, JSON_ARRAY_UNIQUE);
    
    json jEval = JSON_ARRAY;
    int n; for (n; n < JsonGetLength(jTokens); n++)
    {
        string sToken = JsonGetString(JsonArrayGet(JsonArrayGet(jTokens, n), 1));
        sString = RegExpReplace("<" + sToken + ">", sString, "^" + IntToString(n + 1));
        jEval = JsonArrayInsert(jEval, JsonString(EvalDialogToken(sToken, oPC)));
    }

    return SubstituteString(sString, jEval, "^");
}

// ----- System Functions ------------------------------------------------------

object GetDialogCache(string sDialog)
{
    object oCache = GetDataItem(DIALOGS, DLG_PREFIX + sDialog);
    if (!GetIsObjectValid(oCache))
        oCache = CreateDataItem(DIALOGS, DLG_PREFIX + sDialog);

    return oCache;
}

void RegisterDialogScript(string sDialog, string sScript = "", int nEvents = DLG_EVENT_ALL, float fPriority = DLG_PRIORITY_DEFAULT)
{
    if (fPriority < DLG_PRIORITY_LAST || fPriority > DLG_PRIORITY_FIRST)
        return;

    if (sScript == "")
        sScript = sDialog;

    string sEvent;
    object oCache = GetDialogCache(sDialog);
    int nEvent = DLG_EVENT_INIT;

    for (nEvent; nEvent < DLG_EVENT_ALL; nEvent <<= 1)
    {
        if (nEvents & nEvent)
        {
            sEvent = DialogEventToString(nEvent);
            Debug("Adding " + sScript + " to " + sDialog + "'s " + sEvent +
                  " event with a priority of " + FloatToString(fPriority, 2, 2));
            AddListString(oCache, sScript,   sEvent);
            AddListFloat (oCache, fPriority, sEvent);

            // Mark the event as unsorted
            SetLocalInt(oCache, sEvent, FALSE);
        }
    }
}

void SortDialogScripts(int nEvent)
{
    string sEvent = DialogEventToString(nEvent);
    json jPriority = GetFloatList(DIALOG, sEvent);
    if (jPriority == JsonArray())
        return;

    Debug("Sorting " + IntToString(JsonGetLength(jPriority)) + " scripts for " + sEvent);

    string sQuery = "SELECT json_group_array(id - 1) " +
                    "FROM (SELECT id, atom " +
                        "FROM json_each(json('" + JsonDump(jPriority) + "')) " +
                        "ORDER BY value);";
    sqlquery sql = SqlPrepareQueryObject(GetModule(), sQuery);
    SqlStep(sql);

    SetIntList(DIALOG, SqlGetJson(sql, 0), sEvent);
    SetLocalInt(DIALOG, sEvent, TRUE);
}

void SendDialogEvent(int nEvent)
{
    string sScript, sEvent = DialogEventToString(nEvent);

    if (!GetLocalInt(DIALOG, sEvent))
        SortDialogScripts(nEvent);

    int i, nIndex, nCount = CountIntList(DIALOG, sEvent);

    for (i = 0; i < nCount; i++)
    {
        nIndex  = GetListInt   (DIALOG, i,      sEvent);
        sScript = GetListString(DIALOG, nIndex, sEvent);

        SetLocalInt(DIALOG, DLG_EVENT, nEvent);
        Debug("Dialog event " + sEvent + " is running " + sScript);
        if (RunLibraryScript(sScript) & DLG_SCRIPT_ABORT)
        {
            Debug("Dialog event queue was cancelled by " + sScript);
            return;
        }
    }

    if (!nCount)
    {
        sScript = GetDialog();
        SetLocalInt(DIALOG, DLG_EVENT, nEvent);
        Debug("Dialog event " + sEvent + " is running " + sScript);
        RunLibraryScript(sScript);
    }
}

void InitializeDialog()
{
    object oPC = GetPCSpeaker();
    string sDialog = GetLocalString(oPC, DLG_DIALOG);

    if (sDialog == "")
    {
        sDialog = GetLocalString(OBJECT_SELF, DLG_DIALOG);
        if (sDialog == "")
            sDialog = GetTag(OBJECT_SELF);
    }

    DIALOG = GetDialogCache(sDialog);
    if (!GetLocalInt(DIALOG, DLG_INITIALIZED))
    {
        Debug("Initializing dialog " + sDialog);
        SetLocalString(DIALOG, DLG_DIALOG, sDialog);
        SetDialogLabel(DLG_NODE_CONTINUE, DLG_LABEL_CONTINUE);
        SetDialogLabel(DLG_NODE_PREV,     DLG_LABEL_PREV);
        SetDialogLabel(DLG_NODE_NEXT,     DLG_LABEL_NEXT);
        SetDialogLabel(DLG_NODE_BACK,     DLG_LABEL_BACK);
        SetDialogLabel(DLG_NODE_END,      DLG_LABEL_END);
        SetDialogColor(DLG_NODE_CONTINUE, DLG_COLOR_CONTINUE);
        SetDialogColor(DLG_NODE_PREV,     DLG_COLOR_PREV);
        SetDialogColor(DLG_NODE_NEXT,     DLG_COLOR_NEXT);
        SetDialogColor(DLG_NODE_BACK,     DLG_COLOR_BACK);
        SetDialogColor(DLG_NODE_END,      DLG_COLOR_END);
        AddDialogTokens();
        SetLocalObject(oPC, DLG_SYSTEM, DIALOG);
        SendDialogEvent(DLG_EVENT_INIT);
        SetLocalInt(DIALOG, DLG_INITIALIZED, TRUE);
    }
    else
        Debug("Dialog " + sDialog + " has already been initialized");

    if (GetIsObjectValid(oPC))
    {
        Debug("Instantiating dialog " + sDialog + " for " + GetName(oPC));
        DIALOG = CopyItem(DIALOG, DIALOGS, TRUE);
        SetLocalObject(oPC, DLG_SYSTEM, DIALOG);
        SetDialogState(DLG_STATE_RUNNING);
        SetDialogNode(DLG_NODE_NONE);

        if (!GetIsObjectValid(DLG_SELF))
            SetLocalObject(oPC, DLG_SPEAKER, OBJECT_SELF);
    }
}

int LoadDialogPage()
{
    // Do not reset if we got here from an automatic node
    if (GetDialogNode() > DLG_NODE_NONE)
        SetDialogOffset(0);

    int i, nFilters = GetLocalInt(DIALOG, DLG_FILTER_MAX);
    for (i = 0; i < nFilters; i++)
        DeleteLocalInt(DIALOG, DLG_FILTER + IntToString(i));

    DeleteLocalInt(DIALOG, DLG_FILTER_MAX);

    Debug("Initializing dialog page: " + GetDialogPage());
    SendDialogEvent(DLG_EVENT_PAGE);

    string sMessage;
    string sPage = GetDialogPage();
    if (!HasDialogPage(sPage))
        Warning(sMessage = "No dialog page found. Aborting...");
    else if (GetDialogState() == DLG_STATE_ENDED)
        Debug(sMessage = "Dialog ended by the event script. Aborting...");

    if (sMessage != "")
        return FALSE;

    string sText = GetDialogText(sPage);
    SetCustomToken(DLG_CUSTOM_TOKEN, EvalDialogTokens(sText));
    return TRUE;
}

// Private function for LoadDialogNodes(). Maps a response node to a target node
// and sets its text. When the response node is clicked, we will send the node
// event for the target node.
void MapDialogNode(int nNode, int nTarget, string sText, string sPage = "")
{
    string sNode = IntToString(nNode);
    int nMax = DLG_MAX_RESPONSES + 5;
    if (nNode < 0 || nNode > nMax)
    {
        Error("Attempted to set dialog response node " + sNode +
              " but max is " + IntToString(nMax));
        return;
    }

    sText = EvalDialogTokens(sText);

    if (nTarget < DLG_NODE_NONE)
    {
        string sColor = GetDialogColor(nTarget, sPage);
        sText = ColorString(sText, sColor);
    }

    Debug("Setting response node " + sNode + " -> " + IntToString(nTarget));
    SetLocalInt(DIALOG, DLG_NODES + sNode, nTarget);
    SetLocalString(DIALOG, DLG_NODES + sNode, sText);
}

void LoadDialogNodes()
{
    string sText, sTarget;
    string sPage = GetDialogPage();
    string sNodes = GetDialogNodes(sPage);
    int nNodes;

    // Check if we need to show a continue node. This always goes at the top.
    if (DialogNodeEnabled(DLG_NODE_CONTINUE, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_CONTINUE, sPage);
        MapDialogNode(nNodes++, DLG_NODE_CONTINUE, sText, sPage);
    }

    // The max number of responses does not include automatic nodes.
    int nMax = DLG_MAX_RESPONSES + nNodes;
    int i, nMod, nPos, bFilter;
    int nFilter = GetDialogFilter();
    int nCount = CountDialogNodes(sNodes);
    int nOffset = GetDialogOffset();

    // Check which nodes to show and set their tokens
    for (i = 0; i < nCount; i++)
    {
        nMod    = nPos % 30;
        sText   = GetDialogText(sNodes, i);
        sTarget = GetDialogTarget(sNodes, i);
        bFilter  = !(nFilter & (1 << nMod));

        Debug("Checking dialog node " + IntToString(i) +
              "\n  Target: " + sTarget +
              "\n  Text: " + sText +
              "\n  Display: " + (bFilter ? "yes" : "no"));

        if (bFilter && i >= nOffset)
        {
            // We check this here so we know if we need a "next" node.
            if (nNodes >= nMax)
                break;

            MapDialogNode(nNodes++, i, sText);
        }

        // Load the next filter chunk
        if (nMod == 29)
            nFilter = GetDialogFilter((i + 1) / 30);
        else
            nPos++;
    }

    // Check if we need automatic nodes
    if (i < nCount)
    {
        sText = GetDialogLabel(DLG_NODE_NEXT, sPage);
        MapDialogNode(nNodes++, DLG_NODE_NEXT, sText, sPage);
    }

    if (nOffset)
    {
        sText = GetDialogLabel(DLG_NODE_PREV, sPage);
        MapDialogNode(nNodes++, DLG_NODE_PREV, sText, sPage);
    }

    if (DialogNodeEnabled(DLG_NODE_BACK, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_BACK, sPage);
        MapDialogNode(nNodes++, DLG_NODE_BACK, sText, sPage);
    }

    if (DialogNodeEnabled(DLG_NODE_END, sPage))
    {
        sText = GetDialogLabel(DLG_NODE_END, sPage);
        MapDialogNode(nNodes++, DLG_NODE_END, sText, sPage);
    }

    SetLocalInt(DIALOG, DLG_NODES, nNodes);
    SetLocalInt(DIALOG, DLG_NODE, 0);
}

void DoDialogNode(int nClicked)
{
    int nNode = GetLocalInt(DIALOG, DLG_NODES + IntToString(nClicked));
    string sPage = GetDialogPage();
    string sNodes = GetDialogNodes(sPage);
    string sTarget = GetDialogTarget(sNodes, nNode);

    if (nNode == DLG_NODE_END)
    {
        SetDialogState(DLG_STATE_ENDED);
        return;
    }

    if (nNode == DLG_NODE_NEXT)
    {
        int nOffset = GetDialogOffset();
        SetDialogOffset(nOffset + DLG_MAX_RESPONSES);
        sTarget = sPage;
    }
    else if (nNode == DLG_NODE_PREV)
    {
        int nOffset = GetDialogOffset() - DLG_MAX_RESPONSES;
        SetDialogOffset((nOffset < 0 ? 0 : nOffset));
        sTarget = sPage;
    }
    else if (nNode == DLG_NODE_BACK && sTarget == "")
    {
        string sHistory = GetDialogHistory();
        string sLast = GetListItem(sHistory, 0);
        if (sLast != "")
        {
            sTarget = sLast;
            SetDialogHistory(DeleteListItem(sHistory, 0));
        }
    }

    SetLocalInt(DIALOG, DLG_CURRENT_PAGE, FALSE);
    SetDialogNode(nNode);
    SendDialogEvent(DLG_EVENT_NODE);

    // Check if the page change was already handled by the user.
    if (!GetLocalInt(DIALOG, DLG_CURRENT_PAGE))
        SetDialogPage(sTarget);
}

void DialogCleanup()
{
    object oPC = GetPCSpeaker();
    DeleteLocalString(oPC, DLG_DIALOG);
    DeleteLocalObject(oPC, DLG_SPEAKER);
    DestroyObject(DIALOG);
}
/// -----------------------------------------------------------------------------
/// @file   dlg_l_demo.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (library script)
/// -----------------------------------------------------------------------------
/// This library contains some example dialogs that show the features of the Core
/// Dialogs system. You can use it as a model for your own dialog libraries.
/// -----------------------------------------------------------------------------

#include "dlg_i_dialogs"
#include "util_i_library"

// -----------------------------------------------------------------------------
//                                  Poet Dialog
// -----------------------------------------------------------------------------
// This dialog shows how to use continue, back, and end nodes in a dialog.
// -----------------------------------------------------------------------------

const string POET_DIALOG       = "PoetDialog";
const string POET_DIALOG_INIT  = "PoetDialog_Init";
const string POET_DIALOG_PAGE  = "PoetDialog_Page";
const string POET_DIALOG_QUIT  = "PoetDialog_Quit";

const string POET_PAGE_MAIN = "Main Page";
const string POET_PAGE_INFO = "Continue Node Info";
const string POET_PAGE_POOR = "Not enough GP";
const string POET_PAGE_MARY = "Poem: Mary Had A Little Lamb";
const string POET_PAGE_SICK = "Poem: Sick";
const string POET_PAGE_END  = "Poem Finished";

void PoetDialog_Init()
{
    string sPage;

    // Main landing page
    SetDialogPage(POET_PAGE_MAIN);
    AddDialogPage(POET_PAGE_MAIN, "Would you like to hear a poem? 1GP per recital!");
    AddDialogNode(POET_PAGE_MAIN, POET_PAGE_INFO, "Who are you?");
    AddDialogNode(POET_PAGE_MAIN, POET_PAGE_MARY, "Mary Had A Little Lamb");
    AddDialogNode(POET_PAGE_MAIN, POET_PAGE_SICK, "Sick, by Shel Silverstein");
    AddDialogNode(POET_PAGE_MAIN, POET_PAGE_POOR, "I can't afford that.");
    EnableDialogEnd("Goodbye", POET_PAGE_MAIN);

    // PC asked "Who are you?"
    AddDialogPage(POET_PAGE_INFO,
        "I am demonstrating continued pages. Continued pages are used when " +
        "you want to have several pages of text with a continue button in " +
        "between.");
    AddDialogPage(POET_PAGE_INFO,
        "To continue a page, simply call the AddDialogPage() function using " +
        "the same page name. A child page will be created and a \"Continue\" " +
        "node will be added to the parent page. Do this as many times as is " +
        "necessary to add sufficient text.");
    AddDialogPage(POET_PAGE_INFO,
        "The child pages are full pages like any other. They can have their " +
        "own nodes, etc. The AddDialogPage() function returns the name of " +
        "the child page, so you can catch it and change things without " +
        "having to keep track of how many pages are in the chain.");
    AddDialogPage(POET_PAGE_INFO,
        "You can add automated nodes such as end or back responses. In this " +
        "example, I get mad and attack you if you interrupt my beautiful " +
        "poetry, so I suggest not doing that.");
    sPage = AddDialogPage(POET_PAGE_INFO,
        "You can also add \"Continue\" nodes to a page using the function " +
        "ContinueDialogPage(). This function links a page to an existing " +
        "page. It's useful for ending a chain of continued pages. In fact, " +
        "that's what links the \"Continue\" node below back to the main page.");
    ContinueDialogPage(sPage, POET_PAGE_MAIN);

    // PC does not have enough money to list to the chosen poem.
    AddDialogPage(POET_PAGE_POOR,
        "Oh, I'm sorry. It seems you don't have enough coin on you. I don't " +
        "recite poetry for free, you know.");
    AddDialogNode(POET_PAGE_POOR, POET_PAGE_INFO,
        "Can you tell me who you are instead?");
    EnableDialogEnd("Goodbye", POET_PAGE_POOR);

    // PC chose poem "Mary Had A Little Lamb"
    AddDialogPage(POET_PAGE_MARY,
            "Mary had a little lamb,\n" +
            "Little lamb,\nLittle lamb.\n" +
            "Mary had a little lamb.\n" +
            "Its fleece was white as snow.");
    sPage = AddDialogPage(POET_PAGE_MARY,
            "Everywhere that Mary went,\n" +
            "Mary went,\nMary went,\n" +
            "Everywhere that Mary went,\n" +
            "The lamb was sure to go.");
    EnableDialogEnd("I've had enough of this. Good day!", sPage);

    sPage = AddDialogPage(POET_PAGE_MARY,
            "It followed her to school one day,\n" +
            "School one day,\nSchool one day,\n" +
            "It followed her to school one day,\n" +
            "Which was against the rules.");
    EnableDialogEnd("Booooring! Learn to recite poetry!", sPage);

    sPage = AddDialogPage(POET_PAGE_MARY,
            "It made the children laugh and play,\n" +
            "Laugh and play,\nLaugh and play,\n" +
            "It made the children laugh and play,\n" +
            "To see a lamb at school.");
    EnableDialogEnd("Oh, gods! I thought it would never end!", sPage);
    ContinueDialogPage(sPage, POET_PAGE_END);

    // PC chose poem "Sick, by Shel Silverstein"
    AddDialogPage(POET_PAGE_SICK,
            "I cannot go to school today,\n" +
            "Said little Peggy Ann McKay.\n" +
            "I have the measles and the mumps,\n" +
            "A gash, a rash and purple bumps.");
    AddDialogPage(POET_PAGE_SICK,
            "My mouth is wet, my throat is dry,\n" +
            "I'm going blind in my right eye.\n" +
            "My tonsils are as big as rocks,\n" +
            "I've counted sixteen chicken pox\n" +
            "And there's one more--that's seventeen,\n" +
            "And don't you think my face looks green?");
    AddDialogPage(POET_PAGE_SICK,
            "My leg is cut--my eyes are blue--\n" +
            "It might be instamatic flu.\n" +
            "I cough and sneeze and gasp and choke,\n" +
            "I'm sure that my left leg is broke--\n" +
            "My hip hurts when I move my chin,\n" +
            " My belly button's caving in.");
    sPage = AddDialogPage(POET_PAGE_SICK,
            "My back is wrenched, my ankle's sprained,\n" +
            "My 'pendix pains each time it rains.\n" +
            "My nose is cold, my toes are numb.\n" +
            "I have a sliver in my thumb.\n" +
            "My neck is stiff, my voice is weak,\n" +
            "I hardly whisper when I speak.");
    EnableDialogEnd("I've had enough of this. Good day!", sPage);

    sPage = AddDialogPage(POET_PAGE_SICK,
            "My tongue is filling up my mouth,\n" +
            "I think my hair is falling out.\n" +
            "My elbow's bent, my spine ain't straight,\n" +
            "My temperature is one-o-eight.\n" +
            "My brain is shrunk, I cannot hear,\n" +
            "There is a hole inside my ear.");
    EnableDialogEnd("Booooring! Learn to recite poetry!", sPage);

    sPage = AddDialogPage(POET_PAGE_SICK,
            "I have a hangnail, and my heart is--what?\n" +
            "What's that? What's that you say?\n" +
            "You say today is... Saturday?\n" +
            "G'bye, I'm going out to play!");
    EnableDialogEnd("Oh, gods! I thought it would never end!", sPage);
    ContinueDialogPage(sPage, POET_PAGE_END);

    // Poem is finished
    AddDialogPage(POET_PAGE_END, "I hope you enjoyed it! Would you like to " +
        "hear another poem? Only 1GP per recital!");
    SetDialogNodes(POET_PAGE_END, POET_PAGE_MAIN);
    EnableDialogEnd("That's it for me, thanks.", POET_PAGE_END);
}

void PoetDialog_Page()
{
    string sPage = GetDialogPage();
    object oPC = GetPCSpeaker();
    int nGold = GetGold(oPC);

    if (sPage == POET_PAGE_MAIN || sPage == POET_PAGE_END)
    {
        // This only happens on the first run
        if (GetDialogNode() == DLG_NODE_NONE)
            ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING);

        if (nGold < 1)
            FilterDialogNodes(1, 2);
        else
            FilterDialogNodes(3);
    }
    else if (sPage == POET_PAGE_MARY || sPage == POET_PAGE_SICK)
    {
        if (nGold < 1)
            SetDialogPage(POET_PAGE_POOR);
        else
            TakeGoldFromCreature(1, oPC);
    }

    // We don't use history in this dialog, so don't store it up
    ClearDialogHistory();
}

void PoetDialog_Quit()
{
    string sPage = GetDialogPage();

    if (GetStringLeft(sPage, 5) == "Poem:")
    {
        object oPC = GetPCSpeaker();
        ActionSpeakString("You'll pay for that!");
        ActionDoCommand(SetIsTemporaryEnemy(oPC));
        ActionAttack(oPC);
    }
    else
    {
        ActionSpeakString("Perhaps another time, then? Good day!");
        ActionPlayAnimation(ANIMATION_FIREFORGET_GREETING);
    }
}

// -----------------------------------------------------------------------------
//                                 Anvil Dialog
// -----------------------------------------------------------------------------
// This dialog demonstrates dynamic node generation and automatic pagination.
// -----------------------------------------------------------------------------

const string ANVIL_DIALOG      = "AnvilDialog";
const string ANVIL_PAGE_MAIN   = "Main Page";
const string ANVIL_PAGE_ITEM   = "Item Chosen";
const string ANVIL_PAGE_ACTION = "Item Action";
const string ANVIL_ITEM        = "AnvilItem";

void AnvilDialog()
{
    switch (GetDialogEvent())
    {
        case DLG_EVENT_INIT:
        {
            AddDialogToken("Action");
            AddDialogToken("Item");

            EnableDialogEnd();
            SetDialogPage(ANVIL_PAGE_MAIN);
            AddDialogPage(ANVIL_PAGE_MAIN, "Select an item:");

            AddDialogPage(ANVIL_PAGE_ITEM, "What would you like to do with the <Item>?");
            AddDialogNode(ANVIL_PAGE_ITEM, ANVIL_PAGE_ACTION, "Clone it", "Copy");
            AddDialogNode(ANVIL_PAGE_ITEM, ANVIL_PAGE_ACTION, "Destroy it", "Destroy");
            EnableDialogNode(DLG_NODE_BACK, ANVIL_PAGE_ITEM);

            AddDialogPage(ANVIL_PAGE_ACTION, "<Action>ing <Item>");
            EnableDialogNode(DLG_NODE_BACK, ANVIL_PAGE_ACTION);
            SetDialogTarget(ANVIL_PAGE_MAIN, ANVIL_PAGE_ACTION, DLG_NODE_BACK);
        } break;

        case DLG_EVENT_PAGE:
        {
            object oPC = GetPCSpeaker();
            string sPage = GetDialogPage();
            int nNode = GetDialogNode();

            if (sPage == ANVIL_PAGE_MAIN)
            {
                DeleteDialogNodes(sPage);
                DeleteObjectList(DLG_SELF, ANVIL_ITEM);
                object oItem = GetFirstItemInInventory(oPC);

                while (GetIsObjectValid(oItem))
                {
                    AddDialogNode(sPage, ANVIL_PAGE_ITEM, GetName(oItem));
                    AddListObject(DLG_SELF, oItem, ANVIL_ITEM);
                    oItem = GetNextItemInInventory(oPC);
                }
            }
            else if (sPage == ANVIL_PAGE_ITEM)
            {
                object oItem = GetListObject(DLG_SELF, nNode, ANVIL_ITEM);
                SetLocalObject(DLG_SELF, ANVIL_ITEM, oItem);
                CacheDialogToken("Item", GetName(oItem));
            }
            else if (sPage == ANVIL_PAGE_ACTION)
            {
                int nNode = GetDialogNode();
                string sData = GetDialogData(ANVIL_PAGE_ITEM, nNode);
                object oItem = GetLocalObject(DLG_SELF, ANVIL_ITEM);
                CacheDialogToken("Action", sData);

                if (sData == "Copy")
                    CopyItem(oItem, oPC);
                else if (sData == "Destroy")
                    DestroyObject(oItem);
            }
        } break;
    }
}

// -----------------------------------------------------------------------------
//                                 Token Dialog
// -----------------------------------------------------------------------------
// This dialog demonstrates the use of dialog tokens.
// -----------------------------------------------------------------------------

const string TOKEN_DIALOG = "TokenDialog";
const string TOKEN_PAGE_MAIN = "Main Page";
const string TOKEN_PAGE_INFO = "Token Info";
const string TOKEN_PAGE_LIST = "Token List";

void TokenDialog()
{
    if (GetDialogEvent() != DLG_EVENT_INIT)
        return;

    EnableDialogEnd();
    SetDialogLabel(DLG_NODE_CONTINUE, "<StartAction>[Listen]</Start>");

    SetDialogPage(TOKEN_PAGE_MAIN);

    AddDialogPage(TOKEN_PAGE_MAIN,
        "Hello, <FirstName>. Isn't this a fine <quarterday>?");
    AddDialogNode(TOKEN_PAGE_MAIN, TOKEN_PAGE_INFO, "Who are you?");
    AddDialogNode(TOKEN_PAGE_MAIN, TOKEN_PAGE_LIST, "What tokens are available?");

    AddDialogPage(TOKEN_PAGE_INFO,
        "I'm demonstrating the use of dialog tokens. A token is a word or " +
        "choice in angle brackets such as <token>FullName</token>. Tokens " +
        "can be embedded directly into page or node text when initializing " +
        "the dialog and are evaluated at display time. This means you don't " +
        "need to know the value of the token to make the text work.");
    AddDialogPage(TOKEN_PAGE_INFO,
        "There are lots of tokens available, such as <token>class</token>, " +
        "<token>race</token>, and <token>level</token>.\n\n" +
        "That's how I can know you're a level <level> <racial> <class>.");
    AddDialogPage(TOKEN_PAGE_INFO,
        "You can also add your own tokens using AddDialogToken() in your " +
        "dialog's init script. This function takes three arguments:\n\n" +
        "- sToken: the token text (not including the brackets)\n" +
        "- sEvalScript: a library script that sets the token value\n" +
        "- sValues: an optional CSV list of possible values for the token");
    AddDialogPage(TOKEN_PAGE_INFO,
        "The library script referenced by sEvalScript can read the token " +
        "and possible values and then set the proper value for the token. " +
        "Refer to dlg_l_tokens.nss to see how this is done.");
    AddDialogPage(TOKEN_PAGE_INFO,
        "Some tokens can have uppercase and lowercase variants. When the " +
        "token is all lowercase, the value will be converted to lowercase; " +
        "otherwise the value will be used as is. For example:\n\n" +
        "<token>Class</token> -> <Class>\n" +
        "<token>class</token> -> <class>");
    AddDialogPage(TOKEN_PAGE_INFO,
        "Some tokens cannot be converted to lowercase; if there are any " +
        "uppercase characters in sToken, the text must be typed exactly and " +
        "its value will always be exact. For example:\n\n" +
        "<token>FullName</token> -> <FullName>\n" +
        "<token>fullname</token> -> <fullname>");
    string sPage = AddDialogPage(TOKEN_PAGE_INFO,
        "Tokens are specific to a dialog, so if you add your own tokens, you " +
        "don't have to worry about making them unique across all dialogs. " +
        "You could have a <token>value</token> token in two different " +
        "dialogs that are evaluated by different library scripts. This gives " +
        "you a lot of flexibility when designing dialogs.");
    EnableDialogNode(DLG_NODE_BACK, sPage);
    SetDialogTarget("Main Page", sPage, DLG_NODE_BACK);

    AddDialogPage(TOKEN_PAGE_LIST,
        "Gender tokens (case insensitive):\n\n" +
        "- <token>bitch/bastard</token> -> <bitch/bastard>\n" +
        "- <token>boy/girl</token> -> <boy/girl>\n" +
        "- <token>brother/sister</token> -> <brother/sister>\n" +
        "- <token>he/she</token> -> <he/she>\n" +
        "- <token>him/her</token> -> <him/her>\n" +
        "- <token>his/her</token> -> <his/her>\n" +
        "- <token>his/hers</token> -> <his/hers>\n" +
        "- <token>lad/lass</token> -> <lad/lass>\n" +
        "- <token>lord/lady</token> -> <lord/lady>\n" +
        "- <token>male/female</token> -> <male/female>\n" +
        "- <token>man/woman</token> -> <man/woman>\n" +
        "- <token>master/mistress</token> -> <master/mistress>\n" +
        "- <token>mister/missus</token> -> <mister/missus>\n" +
        "- <token>sir/madam</token> -> <sir/madam>");
    AddDialogPage(TOKEN_PAGE_LIST,
        "Alignment tokens (case insensitive):\n\n" +
        "- <token>alignment</token> -> <alignment>\n" +
        "- <token>good/evil</token> -> <good/evil>\n" +
        "- <token>law/chaos</token> -> <law/chaos>\n" +
        "- <token>lawful/chaotic</token> -> <lawful/chaotic>");
    AddDialogPage(TOKEN_PAGE_LIST,
        "Character tokens (case insensitive):\n\n" +
        "- <token>class</token> -> <class>\n" +
        "- <token>classes</token> -> <classes>\n" +
        "- <token>level</token> -> <level>\n" +
        "- <token>race</token> -> <race>\n" +
        "- <token>races</token> -> <races>\n" +
        "- <token>racial</token> -> <racial>\n" +
        "- <token>subrace</token> -> <subrace>\n\n" +
        "Character tokens (case sensitive):\n\n" +
        "- <token>Deity</token> -> <Deity>");
    AddDialogPage(TOKEN_PAGE_LIST,
        "Time tokens (case insensitive):\n\n" +
        "- <token>day/night</token> -> <day/night>\n" +
        "- <token>gameday</token> -> <gameday>\n" +
        "- <token>gamedate</token> -> <gamedate>\n" +
        "- <token>gamehour</token> -> <gamehour>\n" +
        "- <token>gameminute</token> -> <gameminute>\n" +
        "- <token>gamemonth</token> -> <gamemonth>\n" +
        "- <token>gamesecond</token> -> <gamesecond>\n" +
        "- <token>gametime12</token> -> <gametime12>\n" +
        "- <token>gametime24</token> -> <gametime24>\n" +
        "- <token>gameyear</token> -> <gameyear>\n" +
        "- <token>quarterday</token> -> <quarterday>");
    AddDialogPage(TOKEN_PAGE_LIST,
        "Name tokens (case sensitive):\n\n" +
        "- <token>FirstName</token> -> <FirstName>\n" +
        "- <token>FullName</token> -> <FullName>\n" +
        "- <token>LastName</token> -> <LastName>\n" +
        "- <token>PlayerName</token> -> <PlayerName>");
    sPage = AddDialogPage(TOKEN_PAGE_LIST,
        "Special tokens (case sensitive):\n\n" +
        "- <token>StartAction</token>foo<token>/Start</token> -> " +
            "<StartAction>foo</Start>\n" +
        "- <token>StartCheck</token>foo<token>/Start</token> -> " +
            "<StartCheck>foo</Start>\n" +
        "- <token>StartHighlight</token>foo<token>/Start</token> -> " +
            "<StartHighlight>foo</Start>\n\n" +
        "Special tokens (case insensitive):\n\n" +
        "- <token>token</token>foo<token>/token</token> -> <token>foo</token>");
    EnableDialogNode(DLG_NODE_BACK, sPage);
    SetDialogTarget("Main Page", sPage, DLG_NODE_BACK);
}


void OnLibraryLoad()
{
    RegisterLibraryScript(POET_DIALOG_INIT);
    RegisterLibraryScript(POET_DIALOG_PAGE);
    RegisterLibraryScript(POET_DIALOG_QUIT);

    RegisterDialogScript(POET_DIALOG, POET_DIALOG_INIT, DLG_EVENT_INIT);
    RegisterDialogScript(POET_DIALOG, POET_DIALOG_PAGE, DLG_EVENT_PAGE);
    RegisterDialogScript(POET_DIALOG, POET_DIALOG_QUIT, DLG_EVENT_END | DLG_EVENT_ABORT);

    RegisterLibraryScript(ANVIL_DIALOG);
    RegisterDialogScript (ANVIL_DIALOG);

    RegisterLibraryScript(TOKEN_DIALOG);
}

void OnLibraryScript(string sScript, int nEntry)
{
    if      (sScript == POET_DIALOG_PAGE) PoetDialog_Page();
    else if (sScript == POET_DIALOG_QUIT) PoetDialog_Quit();
    else if (sScript == POET_DIALOG_INIT) PoetDialog_Init();
    else if (sScript == ANVIL_DIALOG)     AnvilDialog();
    else if (sScript == TOKEN_DIALOG)     TokenDialog();
}
// -----------------------------------------------------------------------------
//    File: dlg_l_plugin.nss
//  System: Dynamic Dialogs (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library contains hook-in scripts for the Dynamic Dialogs plugin. If the
// Dynamic Dialogs plugin is activated, these scripts will fire on the
// appropriate events.
// -----------------------------------------------------------------------------

#include "core_i_framework"
#include "dlg_i_dialogs"
#include "util_i_color"
#include "util_i_library"

// -----------------------------------------------------------------------------
//                             Event Hook-In Scripts
// -----------------------------------------------------------------------------

// ----- WrapDialog ------------------------------------------------------------
// Starts a dialog between the calling object and the PC that triggered the
// event being executed. Only valid when being called by an event queue.
// ----- Variables -------------------------------------------------------------
// string "*Dialog":  The name of the dialog script (library or otherwise)
// int    "*Private": Whether the dialog should be hidden from other players.
// int    "*NoHello": Prevent the NPC from saying hello on dialog start
// int    "*NoZoom":  Prevent camera from zooming in on dialog start
// ----- Aliases ---------------------------------------------------------------

void WrapDialog(int bGhost = FALSE)
{
    // Get the PC that triggered the event. This information is pulled off the
    // event queue since we don't know which event is calling us.
    object oPC = GetEventTriggeredBy();

    if (!GetIsPC(oPC))
        return;

    string sDialog  = GetLocalString(OBJECT_SELF, DLG_DIALOG);
    int    bPrivate = GetLocalInt   (OBJECT_SELF, DLG_PRIVATE);
    int    bNoHello = GetLocalInt   (OBJECT_SELF, DLG_NO_HELLO);
    int    bNoZoom  = GetLocalInt   (OBJECT_SELF, DLG_NO_ZOOM);

    StartDialog(oPC, OBJECT_SELF, sDialog, bPrivate, bNoHello, bNoZoom);
}


// -----------------------------------------------------------------------------
//                             Plugin Control Dialog
// -----------------------------------------------------------------------------
// This dialog allows users to view and modify Core Framework Plugins.
// -----------------------------------------------------------------------------

const string PLUGIN_DIALOG      = "PluginControlDialog";
const string PLUGIN_PAGE        = "Plugin: ";
const string PLUGIN_PAGE_MAIN   = "Plugin List";
const string PLUGIN_PAGE_FAIL   = "Not Authorized";
const string PLUGIN_ACTIVATE    = "Activate Plugin";
const string PLUGIN_DEACTIVATE  = "Deactivate Plugin";

// Adds a dummy page for a plugin if it does not already exist
string AddPluginPage(string sPlugin)
{
    string sPage = PLUGIN_PAGE + sPlugin;
    if (!HasDialogPage(sPage))
    {
        AddDialogPage(sPage, "Plugin: <Plugin>\nStatus: <Status>\n\n<Description>", sPlugin);
        AddDialogNode(sPage, sPage, "Activate plugin",   PLUGIN_ACTIVATE);
        AddDialogNode(sPage, sPage, "Deactivate plugin", PLUGIN_DEACTIVATE);
        SetDialogTarget(PLUGIN_PAGE_MAIN, sPage, DLG_NODE_BACK);
    }

    return sPage;
}

string PluginStatusText(int nStatus)
{
    switch (nStatus)
    {
        case PLUGIN_STATUS_OFF:
            return HexColorString("[Inactive]", COLOR_GRAY);
        case PLUGIN_STATUS_ON:
            return HexColorString("[Active]", COLOR_GREEN);
        //case PLUGIN_STATUS_MISSING:
        //    return HexColorString("[Missing]", COLOR_RED);
    }

    return "";
}

void PluginControl_Init()
{
    EnableDialogNode(DLG_NODE_BACK);
    EnableDialogNode(DLG_NODE_END);

    AddDialogToken("Plugin");
    AddDialogToken("Status");
    AddDialogToken("Description");
    SetDialogPage(PLUGIN_PAGE_MAIN);
    AddDialogPage(PLUGIN_PAGE_MAIN,
        "This dialog allows you to manage the plugins in the Core Framework. " +
        "To manage a plugin, click its name below.\n\nThe following plugins " +
        "are installed:");
    SetDialogLabel(DLG_NODE_BACK, "[Refresh]", PLUGIN_PAGE_MAIN);

    string sPlugin, sPage;
    int i, nCount = CountStringList(PLUGINS);
    for (i; i < nCount; i++)
    {
        sPlugin = GetListString(PLUGINS, i);
        AddPluginPage(sPlugin);
    }

    AddDialogPage(PLUGIN_PAGE_FAIL, "Sorry, but only a DM can use this.");
    DisableDialogNode(DLG_NODE_BACK, PLUGIN_PAGE_FAIL);
}

void PluginControl_Page()
{
    object oPC = GetPCSpeaker();

    if (!GetIsDM(oPC))
    {
        SetDialogPage(PLUGIN_PAGE_FAIL);
        return;
    }

    string sPage = GetDialogPage();

    if (sPage == PLUGIN_PAGE_MAIN)
    {
        // Delete the old plugin list
        DeleteDialogNodes(PLUGIN_PAGE_MAIN);

        // Build the list of plugins
        object oPlugin;
        string sPlugin, sText, sTarget;
        int i, nStatus, nCount = CountObjectList(PLUGINS);

        for (i; i < nCount; i++)
        {
            oPlugin = GetListObject(PLUGINS, i);
            sPlugin = GetListString(PLUGINS, i);
            sTarget = AddPluginPage(sPlugin);
            nStatus = GetIsPluginActivated(oPlugin);
            sText = sPlugin + " " + PluginStatusText(nStatus);
            AddDialogNode(PLUGIN_PAGE_MAIN, sTarget, sText);
        }

        return;
    }

    // The page is for a plugin
    string sPlugin = GetDialogData(sPage);
    object oPlugin = GetPlugin(sPlugin);
    int nStatus = GetIsPluginActivated(oPlugin);
    switch (nStatus)
    {
        case PLUGIN_STATUS_OFF:
        case PLUGIN_STATUS_ON:
            FilterDialogNodes(!nStatus); break;
        default:
            FilterDialogNodes(0, CountDialogNodes(sPage) - 1);
    }

    CacheDialogToken("Plugin", sPlugin);
    CacheDialogToken("Status", PluginStatusText(nStatus));
    CacheDialogToken("Description", GetDescription(oPlugin));
}

void PluginControl_Node()
{
    string sPage = GetDialogPage();
    string sPrefix = GetStringLeft(sPage, GetStringLength(PLUGIN_PAGE));

    if (sPrefix == PLUGIN_PAGE)
    {
        int nNode = GetDialogNode();
        string sData = GetDialogData(sPage, nNode);
        string sPlugin = GetDialogData(sPage);

        if (sData == PLUGIN_ACTIVATE)
            ActivatePlugin(sPlugin);
        else if (sData == PLUGIN_DEACTIVATE)
            DeactivatePlugin(sPlugin);
    }
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    // Plugin setup
    if (!GetIfPluginExists("dlg"))
    {
        object oPlugin = CreatePlugin("dlg");
        SetName(oPlugin, "[Plugin] Dynamic Dialogs");
        SetDescription(oPlugin,
            "This plugin allows the creation and launching of script-driven dialogs.");
        LoadLibraries("dlg_l_tokens, dlg_l_demo");
    }

    // Event scripts
    RegisterLibraryScript("StartDialog",        0x0100+0x01);
    RegisterLibraryScript("StartGhostDialog",   0x0100+0x02);

    // Plugin Control Dialog
    RegisterLibraryScript("PluginControl_Init", 0x0200+0x01);
    RegisterLibraryScript("PluginControl_Page", 0x0200+0x02);
    RegisterLibraryScript("PluginControl_Node", 0x0200+0x03);

    RegisterDialogScript(PLUGIN_DIALOG, "PluginControl_Init", DLG_EVENT_INIT, DLG_PRIORITY_FIRST);
    RegisterDialogScript(PLUGIN_DIALOG, "PluginControl_Page", DLG_EVENT_PAGE);
    RegisterDialogScript(PLUGIN_DIALOG, "PluginControl_Node", DLG_EVENT_NODE);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry & 0xff00)
    {
        case 0x0100:
            switch (nEntry & 0x00ff)
            {
                case 0x01: WrapDialog();          break;
                case 0x02: WrapDialog(TRUE);      break;
            }  break;

        case 0x0200:
            switch (nEntry & 0x00ff)
            {
                 case 0x01: PluginControl_Init(); break;
                 case 0x02: PluginControl_Page(); break;
                 case 0x03: PluginControl_Node(); break;
             }   break;
    }
}
/// -----------------------------------------------------------------------------
/// @file   dlg_l_tokens.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Dynamic Dialogs (library script)
/// -----------------------------------------------------------------------------
/// This library script contains functions used to evaluate conversation tokens.
/// For example, the text "Good <quarterday>" will evaluate to "Good morning" or
/// "Good evening" based on the time of day. These tokens are evaluated at
/// display-time, so you can use the token in your dialog init script without
/// having to know what value the token will need to have when the dialog line is
/// displayed.
///
/// Token evaluation functions are added using the AddDialogToken() function.
/// This function takes a token to evaluate, a library script matching one of the
/// below functions, and (optionally) a list of possible values. When the library
/// function is called, it can query the token and possible values if needed and
/// then set the value of the token.
///
/// All of the default tokens provided by the game can be loaded using the
/// function AddDialogTokens() in your dialog init script. You can also add your
/// own tokens using the method above.
///
/// Tokens are added on a per-dialog basis; you can have different evaluation
/// functions in different dialogs for the same token. This may come in handy if
/// you want to interpolate variables into your dialogs using tokens and don't
/// want to worry about token names clashing.
///
/// All token evaluation functions have the following in common:
/// - OBJECT_SELF is the PC speaker
/// - GetLocalString(OBJECT_SELF, "*Token") yields the token to be evaluated
/// - GetLocalString(OBJECT_SELF, "*TokenValues") yields the possible values
/// - SetLocalString(OBJECT_SELF, "*Token", ...) sets the token value
/// - SetLocalInt(OBJECT_SELF, "*TokenCache", TRUE) caches the token value so the
///   library script does not have to be run again. This cache will last the
///   lifetime of the dialog.
/// - If a token can be lowercase or uppercase, the uppercase values should be
///   returned. The system takes care of changing to lowercase as needed.

#include "util_i_library"

// -----------------------------------------------------------------------------
//                        Library Script Implementations
// -----------------------------------------------------------------------------

string DialogToken_Alignment(string sToken, string sValues)
{
    string sRet;
    int nLawChaos = GetAlignmentLawChaos(OBJECT_SELF);
    int nGoodEvil = GetAlignmentGoodEvil(OBJECT_SELF);

    if (sToken == "alignment")
    {
        switch (nLawChaos)
        {
            case ALIGNMENT_LAWFUL:  sRet = "Lawful "; break;
            case ALIGNMENT_CHAOTIC: sRet = "Chaotic "; break;
            case ALIGNMENT_NEUTRAL:
            {
                if (nGoodEvil == ALIGNMENT_NEUTRAL) sRet = "True ";
                else sRet = "Neutral ";
            } break;
        }

        switch (nGoodEvil)
        {
            case ALIGNMENT_GOOD:    sRet += "Good";    break;
            case ALIGNMENT_EVIL:    sRet += "Evil";    break;
            case ALIGNMENT_NEUTRAL: sRet += "Neutral"; break;
        }
    }
    else if (sToken == "good/evil")
    {
        switch (nGoodEvil)
        {
            case ALIGNMENT_GOOD:    sRet = "Good";    break;
            case ALIGNMENT_EVIL:    sRet = "Evil";    break;
            case ALIGNMENT_NEUTRAL: sRet = "Neutral"; break;
        }
    }
    else if (sToken == "lawful/chaotic")
    {
        switch (nLawChaos)
        {
            case ALIGNMENT_LAWFUL:  sRet = "Lawful";  break;
            case ALIGNMENT_CHAOTIC: sRet = "Chaotic"; break;
            case ALIGNMENT_NEUTRAL: sRet = "Neutral"; break;
        }
    }
    else if (sToken == "law/chaos")
    {
        switch (nLawChaos)
        {
            case ALIGNMENT_LAWFUL:  sRet = "Law";        break;
            case ALIGNMENT_CHAOTIC: sRet = "Chaos";      break;
            case ALIGNMENT_NEUTRAL: sRet = "Neutrality"; break;
        }
    }

    return sRet;
}

// Helper function: yields the class in which the PC has the most levels
int GetClass()
{
    int i, nHighest, nLevel, nRet;
    int nClass = GetClassByPosition(++i);

    while (nClass != CLASS_TYPE_INVALID)
    {
        nLevel = GetLevelByClass(nClass);
        if (nLevel > nHighest)
        {
            nHighest = nLevel;
            nRet = nClass;
        }

        nClass = GetClassByPosition(++i);
    }

    return nRet;
}

string DialogToken_Class(string sToken, string sValues)
{
    string sField = (sToken == "classes" ? "Plural" : "Name");
    string sRef = Get2DAString("classes", sField, GetClass());
    return GetStringByStrRef(StringToInt(sRef), GetGender(OBJECT_SELF));
}

string DialogToken_DayNight(string sToken, string sValues)
{
    return GetIsDay() ? "Day" : "Night";
}

string DialogToken_Deity(string sToken, string sValues)
{
    return GetDeity(OBJECT_SELF);
}

string DialogToken_GameDate(string sToken, string sValues)
{
    string sYear  = IntToString(GetCalendarYear());
    string sMonth = IntToString(GetCalendarMonth());
    string sDay   = IntToString(GetCalendarDay());
    return (sToken == "gameyear"   ? sYear :
           (sToken == "gamemonth"  ? sMonth :
           (sToken == "gameday"    ? sDay :
           (sMonth + "/" + sDay + "/" + sYear))));
}

// Helper function that prints the time in an H:MM AM/PM format
string FormatTime12(int nHour, int nMinute)
{
    int nModHour = nHour % 12;
    if (nModHour == 0)
        nModHour = 12;
    string m = (nHour < 12 ? " AM" : " PM");
    string sHour = IntToString(nModHour);
    string sMinute = IntToString(nMinute);
    return sHour + ":" + (nMinute > 9 ? sMinute : "0" + sMinute + m);
}

// Helper function that prints the time in an HH:MM format
string FormatTime24(int nHour, int nMinute)
{
    string sHour   = (nHour   < 10 ? "0" : "") + IntToString(nHour);
    string sMinute = (nMinute < 10 ? "0" : "") + IntToString(nMinute);
    return sHour + ":" + sMinute;
}

string DialogToken_GameTime(string sToken, string sValues)
{
    int nHour   = GetTimeHour();
    int nMinute = GetTimeMinute();
    int nSecond = GetTimeSecond();
    return (sToken == "gamehour"   ? IntToString(nHour) :
           (sToken == "gameminute" ? IntToString(nMinute) :
           (sToken == "gamesecond" ? IntToString(nSecond) :
           (sToken == "gametime12" ? FormatTime12(nHour, nMinute) :
           (sToken == "gametime24" ? FormatTime24(nHour, nMinute) :
           (                         FormatTime24(nHour, nMinute)))))));
}

// General catch-all function for male/female tokens. Values are read from
// sValues. If only two values are found, male is first, then female. Otherwise,
// we use the gender as an index into the values field.
string DialogToken_Gender(string sToken, string sValues)
{
    SetLocalInt(OBJECT_SELF, "*TokenCache", TRUE);

    int nGender = GetGender(OBJECT_SELF);

    if (CountList(sValues) == 2)
        nGender = (nGender == GENDER_FEMALE) ? GENDER_FEMALE : GENDER_MALE;

    return GetListItem(sValues, nGender);
}

string DialogToken_Level(string sToken, string sValues)
{
    return IntToString(GetHitDice(OBJECT_SELF));
}

// This function assumes anything before the first space is the first name and
// anything after it is the last name.
string DialogToken_Name(string sToken, string sValues)
{
    string sName = GetName(OBJECT_SELF);
    if (sToken == "FullName")
        return sName;

    int nPos = FindSubString(sName, " ");
    return (sToken == "FirstName" ? GetStringLeft(sName, nPos) :
           (GetSubString(sName, nPos + 1, GetStringLength(sName))));
}

string DialogToken_PlayerName(string sToken, string sValues)
{
    SetLocalInt(OBJECT_SELF, "*TokenCache", TRUE);
    return GetPCPlayerName(OBJECT_SELF);
}

string DialogToken_QuarterDay(string sToken, string sValues)
{
    return (GetIsDawn()  ? "Morning" :
           (GetIsDay()   ? "Day"     :
           (GetIsDusk()  ? "Evening" : "Night")));
}

string DialogToken_Race(string sToken, string sValues)
{
    SetLocalInt(OBJECT_SELF, "*TokenCache", TRUE);
    int nRace = GetRacialType(OBJECT_SELF);
    int nGender = GetGender(OBJECT_SELF);
    string sField = (sToken == "races"  ? "NamePlural" :
                    (sToken == "racial" ? "ConverName" : "Name"));
    string sRef = Get2DAString("racialtypes", sField, nRace);
    return GetStringByStrRef(StringToInt(sRef), nGender);
}

string DialogToken_SubRace(string sToken, string sValues)
{
    return GetSubRace(OBJECT_SELF);
}

// General-purpose token that yields the supplied value
string DialogToken_Token(string sToken, string sValues)
{
    SetLocalInt(OBJECT_SELF, "*TokenCache", TRUE);
    return sValues;
}

// -----------------------------------------------------------------------------
//                          Library Dispatch Functions
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    RegisterLibraryScript("DialogToken_Alignment",   1);
    RegisterLibraryScript("DialogToken_Class",       2);
    RegisterLibraryScript("DialogToken_DayNight",    3);
    RegisterLibraryScript("DialogToken_Deity",       4);
    RegisterLibraryScript("DialogToken_GameDate",    5);
    RegisterLibraryScript("DialogToken_GameTime",    6);
    RegisterLibraryScript("DialogToken_Gender",      7);
    RegisterLibraryScript("DialogToken_Level",       8);
    RegisterLibraryScript("DialogToken_Name",        9);
    RegisterLibraryScript("DialogToken_PlayerName", 10);
    RegisterLibraryScript("DialogToken_QuarterDay", 11);
    RegisterLibraryScript("DialogToken_Race",       12);
    RegisterLibraryScript("DialogToken_SubRace",    13);
    RegisterLibraryScript("DialogToken_Token",      14);
}

void OnLibraryScript(string sScript, int nEntry)
{
    string sToken  = GetLocalString(OBJECT_SELF, "*Token");
    string sValues = GetLocalString(OBJECT_SELF, "*TokenValues");
    string sValue;

    switch (nEntry)
    {
        case  1: sValue = DialogToken_Alignment (sToken, sValues); break;
        case  2: sValue = DialogToken_Class     (sToken, sValues); break;
        case  3: sValue = DialogToken_DayNight  (sToken, sValues); break;
        case  4: sValue = DialogToken_Deity     (sToken, sValues); break;
        case  5: sValue = DialogToken_GameDate  (sToken, sValues); break;
        case  6: sValue = DialogToken_GameTime  (sToken, sValues); break;
        case  7: sValue = DialogToken_Gender    (sToken, sValues); break;
        case  8: sValue = DialogToken_Level     (sToken, sValues); break;
        case  9: sValue = DialogToken_Name      (sToken, sValues); break;
        case 10: sValue = DialogToken_PlayerName(sToken, sValues); break;
        case 11: sValue = DialogToken_QuarterDay(sToken, sValues); break;
        case 12: sValue = DialogToken_Race      (sToken, sValues); break;
        case 13: sValue = DialogToken_SubRace   (sToken, sValues); break;
        case 14: sValue = DialogToken_Token     (sToken, sValues); break;
    }

    SetLocalString(OBJECT_SELF, "*Token", sValue);
}
/// ----------------------------------------------------------------------------
/// @file   hook_nwn.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Global Core Framework event handler. Place this script in the
///     handler of every game object that the Core should manage.
/// @note If AUTO_HOOK_MODULE_EVENTS from core_c_config.nss is TRUE, you only
///     need to have this in OnModuleLoad to hook all module scripts.
/// @note If AUTO_HOOK_AREA_EVENTS from core_c_config.nss is TRUE, all areas
///     existing at the time the Core is initialized will automatically have
///     this script set as their event handler.
/// ----------------------------------------------------------------------------

#include "x2_inc_switches"
#include "util_i_varlists"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                                  Area of Effect
// -----------------------------------------------------------------------------

void OnAoEEnter()
{
    object oPC = GetEnteringObject();

    if (INCLUDE_NPC_IN_AOE_ROSTER || GetIsPC(oPC))
        AddListObject(OBJECT_SELF, oPC, AOE_ROSTER, TRUE);

    RunEvent(AOE_EVENT_ON_ENTER, oPC);
    AddScriptSource(oPC);
}

void OnAoEHeartbeat()
{
    RunEvent(AOE_EVENT_ON_HEARTBEAT);
}

void OnAoEExit()
{
    object oPC = GetExitingObject();

    RemoveListObject(OBJECT_SELF, oPC, AOE_ROSTER);
    RemoveScriptSource(oPC);
    int nState = RunEvent(AOE_EVENT_ON_EXIT, oPC);

    if (!(nState & EVENT_STATE_ABORT))
    {
        if (!CountObjectList(OBJECT_SELF, AOE_ROSTER))
            RunEvent(AOE_EVENT_ON_EMPTY);
    }
}

void OnAoEUserDefined()
{
    RunEvent(AOE_EVENT_ON_USER_DEFINED);
}

// -----------------------------------------------------------------------------
//                                  Area
// -----------------------------------------------------------------------------

void OnAreaHeartbeat()
{
    RunEvent(AREA_EVENT_ON_HEARTBEAT);
}

void OnAreaUserDefined()
{
    RunEvent(AREA_EVENT_ON_USER_DEFINED);
}

void OnAreaEnter()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC))
    {
        if (GetLocalInt(oPC, LOGIN_BOOT))
            return;

        if (ENABLE_ON_AREA_EMPTY_EVENT)
        {
            int nTimerID = GetLocalInt(OBJECT_SELF, TIMER_ON_AREA_EMPTY);
            if (GetIsTimerValid(nTimerID))
                KillTimer(nTimerID);
        }

        AddListObject(OBJECT_SELF, oPC, AREA_ROSTER, TRUE);
    }

    RunEvent(AREA_EVENT_ON_ENTER, oPC);
    AddScriptSource(oPC);
}

void OnAreaExit()
{
    // Don't run this event if the exiting object is a PC that is about to be booted.
    object oPC = GetExitingObject();

    if (GetLocalInt(oPC, IS_PC) && GetLocalInt(oPC, LOGIN_BOOT))
        return;

    if (!RemoveListObject(OBJECT_SELF, oPC, AREA_ROSTER) && ENABLE_ON_AREA_EMPTY_EVENT)
    {
        int nTimerID = CreateEventTimer(OBJECT_SELF, AREA_EVENT_ON_EMPTY, ON_AREA_EMPTY_EVENT_DELAY, 1);
        StartTimer(nTimerID, FALSE);
    }

    RemoveScriptSource(oPC);
    RunEvent(AREA_EVENT_ON_EXIT, oPC);
}

// -----------------------------------------------------------------------------
//                                  Creature
// -----------------------------------------------------------------------------

void OnCreatureHeartbeat(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_HEARTBEAT : CREATURE_EVENT_ON_HEARTBEAT);
}

void OnCreaturePerception(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_PERCEPTION : CREATURE_EVENT_ON_PERCEPTION, GetLastPerceived());
}

void OnCreatureSpellCastAt(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_SPELL_CAST_AT : CREATURE_EVENT_ON_SPELL_CAST_AT, GetLastSpellCaster());
}

void OnCreaturePhysicalAttacked(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_PHYSICAL_ATTACKED : CREATURE_EVENT_ON_PHYSICAL_ATTACKED, GetLastAttacker());
}

void OnCreatureDamaged(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_DAMAGED : CREATURE_EVENT_ON_DAMAGED, GetLastDamager());
}

void OnCreatureDisturbed(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_DISTURBED : CREATURE_EVENT_ON_DISTURBED, GetLastDisturbed());
}

void OnCreatureCombatRoundEnd(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_COMBAT_ROUND_END : CREATURE_EVENT_ON_COMBAT_ROUND_END);
}

void OnCreatureConversation(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_CONVERSATION : CREATURE_EVENT_ON_CONVERSATION, GetLastSpeaker());
}

void OnCreatureSpawn(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_SPAWN : CREATURE_EVENT_ON_SPAWN);
}

void OnCreatureRested(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_RESTED : CREATURE_EVENT_ON_RESTED);
}

void OnCreatureDeath(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_DEATH : CREATURE_EVENT_ON_DEATH, GetLastKiller());
}

void OnCreatureUserDefined(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_USER_DEFINED : CREATURE_EVENT_ON_USER_DEFINED);
}

void OnCreatureBlocked(int bIsPC)
{
    RunEvent(bIsPC ? PC_EVENT_ON_BLOCKED : CREATURE_EVENT_ON_BLOCKED, GetBlockingDoor());
}

// -----------------------------------------------------------------------------
//                                  Placeable
// -----------------------------------------------------------------------------

void OnPlaceableClose()
{
    RunEvent(PLACEABLE_EVENT_ON_CLOSE, GetLastClosedBy());
}

void OnPlaceableDamaged()
{
    RunEvent(PLACEABLE_EVENT_ON_DAMAGED, GetLastDamager());
}

void OnPlaceableDeath()
{
    RunEvent(PLACEABLE_EVENT_ON_DEATH, GetLastKiller());
}

void OnPlaceableHeartbeat()
{
    RunEvent(PLACEABLE_EVENT_ON_HEARTBEAT);
}

void OnPlaceableDisturbed()
{
    RunEvent(PLACEABLE_EVENT_ON_DISTURBED, GetLastDisturbed());
}

void OnPlaceableLock()
{
    RunEvent(PLACEABLE_EVENT_ON_LOCK, GetLastLocked());
}

void OnPlaceablePhysicalAttacked()
{
    RunEvent(PLACEABLE_EVENT_ON_PHYSICAL_ATTACKED, GetLastAttacker());
}

void OnPlaceableOpen()
{
    RunEvent(PLACEABLE_EVENT_ON_OPEN, GetLastOpenedBy());
}

void OnPlaceableSpellCastAt()
{
    RunEvent(PLACEABLE_EVENT_ON_SPELL_CAST_AT, GetLastSpellCaster());
}

void OnPlaceableUnLock()
{
    RunEvent(PLACEABLE_EVENT_ON_UNLOCK, GetLastUnlocked());
}

void OnPlaceableUsed()
{
    RunEvent(PLACEABLE_EVENT_ON_USED, GetLastUsedBy());
}

void OnPlaceableUserDefined()
{
    RunEvent(PLACEABLE_EVENT_ON_USER_DEFINED);
}

void OnPlaceableConversation()
{
    RunEvent(PLACEABLE_EVENT_ON_CONVERSATION, GetLastSpeaker());
}

void OnPlaceableClick()
{
    RunEvent(PLACEABLE_EVENT_ON_CLICK, GetPlaceableLastClickedBy());
}

// -----------------------------------------------------------------------------
//                                  Trigger
// -----------------------------------------------------------------------------

void OnTriggerHeartbeat()
{
    RunEvent(TRIGGER_EVENT_ON_HEARTBEAT);
}

void OnTriggerEnter()
{
    object oPC = GetEnteringObject();
    RunEvent(TRIGGER_EVENT_ON_ENTER, oPC);
    AddScriptSource(oPC);
}

void OnTriggerExit()
{
    object oPC = GetExitingObject();
    RemoveScriptSource(oPC);
    RunEvent(TRIGGER_EVENT_ON_EXIT, oPC);
}

void OnTriggerUserDefined()
{
    RunEvent(TRIGGER_EVENT_ON_USER_DEFINED);
}

void OnTriggerClick()
{
    RunEvent(TRIGGER_EVENT_ON_CLICK, GetClickingObject());
}

// -----------------------------------------------------------------------------
//                                  Store
// -----------------------------------------------------------------------------

void OnStoreOpen()
{
    RunEvent(STORE_EVENT_ON_OPEN, GetLastOpenedBy());
}

void OnStoreClose()
{
    RunEvent(STORE_EVENT_ON_CLOSE, GetLastClosedBy());
}

// -----------------------------------------------------------------------------
//                                  Encounter
// -----------------------------------------------------------------------------

void OnEncounterEnter()
{
    RunEvent(ENCOUNTER_EVENT_ON_ENTER, GetEnteringObject());
}

void OnEncounterExit()
{
    RunEvent(ENCOUNTER_EVENT_ON_EXIT, GetExitingObject());
}

void OnEncounterHeartbeat()
{
    RunEvent(ENCOUNTER_EVENT_ON_HEARTBEAT);
}

void OnEncounterExhausted()
{
    RunEvent(ENCOUNTER_EVENT_ON_EXHAUSTED);
}

void OnEncounterUserDefined()
{
    RunEvent(ENCOUNTER_EVENT_ON_USER_DEFINED);
}

// -----------------------------------------------------------------------------
//                                  Module
// -----------------------------------------------------------------------------

void OnHeartbeat()
{
    RunEvent(MODULE_EVENT_ON_HEARTBEAT);

    if (ENABLE_ON_HOUR_EVENT)
    {
        int nHour    = GetTimeHour();
        int nOldHour = GetLocalInt(OBJECT_SELF, CURRENT_HOUR);

        // If the hour has changed since the last heartbeat
        if (nHour != nOldHour)
        {
            SetLocalInt(OBJECT_SELF, CURRENT_HOUR, nHour);
            RunEvent(MODULE_EVENT_ON_HOUR);
        }
    }
}

void OnUserDefined()
{
    RunEvent(MODULE_EVENT_ON_USER_DEFINED);
}

void OnModuleLoad()
{
    // Set the spellhook event
    SetModuleOverrideSpellscript(CORE_HOOK_SPELLS);

    // If we're using the core's tagbased scripting, disable X2's version to
    // avoid conflicts with OnSpellCastAt; it will be handled by the spellhook.
    if (ENABLE_TAGBASED_SCRIPTS)
        SetModuleSwitch(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, FALSE);

    // Run our module load event
    RunEvent(MODULE_EVENT_ON_MODULE_LOAD);
}

void OnClientEnter()
{
    object oPC = GetEnteringObject();

    // Set this info since we can't get it OnClientLeave
    SetLocalString(oPC, PC_CD_KEY,      GetPCPublicCDKey(oPC));
    SetLocalString(oPC, PC_PLAYER_NAME, GetPCPlayerName (oPC));

    int nState = RunEvent(MODULE_EVENT_ON_CLIENT_ENTER, oPC);

    // The DENIED flag signals booting the player. This should be done by the
    // script setting the DENIED flag.
    if (nState & EVENT_STATE_DENIED)
    {
        // Set an int on the PC so we know we're booting him from the login
        // event. This will tell the OnClientLeave event hook not to execute.
        SetLocalInt(oPC, LOGIN_BOOT, TRUE);
    }
    else
    {
        // If the PC is logging back in after being booted but he passed all the
        // checks this time, clear the boot int so OnClientLeave scripts will
        // correctly execute for him.
        DeleteLocalInt(oPC, LOGIN_BOOT);

        // This is a running count of the number of players in the module.
        // It will count DMs separately. This is a handy utility for counting
        // online players.
        if (GetIsDM(oPC))
        {
            AddListObject(OBJECT_SELF, oPC, DM_ROSTER, TRUE);
            SetLocalInt(oPC, IS_DM, TRUE);
        }
        else
        {
            AddListObject(OBJECT_SELF, oPC, PLAYER_ROSTER, TRUE);
            SetLocalInt(oPC, IS_PC, TRUE);
        }

        // Set hook-in scripts for all PC events.
        if (AUTO_HOOK_PC_EVENTS)
            HookObjectEvents(oPC, !AUTO_HOOK_PC_HEARTBEAT_EVENT, FALSE);

        // Send the player the welcome message.
        if (WELCOME_MESSAGE != "")
            DelayCommand(1.0, SendMessageToPC(oPC, WELCOME_MESSAGE));
    }
}

void OnClientLeave()
{
    object oPC = GetExitingObject();

    // Only execute hook-in scripts if the PC was not booted OnClientEnter.
    if (!GetLocalInt(oPC, LOGIN_BOOT))
    {
        // Decrement the count of players in the module
        if (GetIsDM(oPC))
            RemoveListObject(OBJECT_SELF, oPC, DM_ROSTER);
        else
            RemoveListObject(OBJECT_SELF, oPC, PLAYER_ROSTER);

        RunEvent(MODULE_EVENT_ON_CLIENT_LEAVE);

        // OnTriggerExit and OnAoEExit do not fire OnClientLeave, and OnAreaExit
        // does not fire if the PC is dead. We run the exit event for all of
        // those here. We do it after the OnClientLeave event so that if they
        // have special OnClientLeave scripts, they still fire.
        sqlquery q = GetScriptSources(oPC);
        while (SqlStep(q))
        {
            object oSource = StringToObject(SqlGetString(q, 0));
            switch (GetObjectType(oSource))
            {
                case OBJECT_TYPE_TRIGGER:
                    if (GetIsInSubArea(oPC, oSource))
                        AssignCommand(oSource, OnTriggerExit());
                    break;
                case OBJECT_TYPE_AREA_OF_EFFECT:
                    if (GetIsInSubArea(oPC, oSource))
                        AssignCommand(oSource, OnAoEExit());
                    break;
                default:
                    if (GetArea(oPC) == oSource && GetIsDead(oPC))
                        AssignCommand(oSource, OnAreaExit());
                    break;
            }
        }
    }
}

void OnActivateItem()
{
    object oItem  = GetItemActivated();
    object oPC    = GetItemActivator();
    int    nState = RunItemEvent(MODULE_EVENT_ON_ACTIVATE_ITEM, oItem, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = GetTag(oItem);
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACTIVATE);
        RunLibraryScript(sTag);
    }
}

void OnAcquireItem()
{
    object oItem  = GetModuleItemAcquired();
    object oPC    = GetModuleItemAcquiredBy();
    int    nState = RunItemEvent(MODULE_EVENT_ON_ACQUIRE_ITEM, oItem, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = GetTag(oItem);
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_ACQUIRE);
        RunLibraryScript(sTag);
    }
}

void OnUnAcquireItem()
{
    object oItem  = GetModuleItemLost();
    object oPC    = GetModuleItemLostBy();
    int    nState = RunItemEvent(MODULE_EVENT_ON_UNACQUIRE_ITEM, oItem, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = GetTag(oItem);
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNACQUIRE);
        RunLibraryScript(sTag);
    }
}

void OnPlayerDeath()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_DEATH, GetLastPlayerDied());
}

void OnPlayerDying()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_DYING, GetLastPlayerDying());
}

void OnPlayerTarget()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_TARGET);
}

void OnPlayerReSpawn()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_RESPAWN, GetLastRespawnButtonPresser());
}

void OnPlayerRest()
{
    object oPC = GetLastPCRested();
    int nState = RunEvent(MODULE_EVENT_ON_PLAYER_REST, oPC);

    // Aborting from the base rest event will abort the other rest events. This
    // allows an OnPlayerRest script to decide if sub-events can fire at all.
    if (nState == EVENT_STATE_OK)
    {
        string sEvent;

        // Process the rest sub-events
        switch (GetLastRestEventType())
        {
            case REST_EVENTTYPE_REST_STARTED:
                sEvent = MODULE_EVENT_ON_PLAYER_REST_STARTED;
                break;

            case REST_EVENTTYPE_REST_CANCELLED:
                sEvent = MODULE_EVENT_ON_PLAYER_REST_CANCELLED;
                break;

            case REST_EVENTTYPE_REST_FINISHED:
                sEvent = MODULE_EVENT_ON_PLAYER_REST_FINISHED;
                break;
        }

        RunEvent(sEvent, oPC);
    }
}

void OnPlayerLevelUp()
{
    object oPC = GetPCLevellingUp();
    int nState = RunEvent(MODULE_EVENT_ON_PLAYER_LEVEL_UP, oPC);

    // If the PC's level up was denied, relevel him,
    if (nState & EVENT_STATE_DENIED)
    {
        int nLevel   = GetHitDice(oPC);
        int nOrigXP  = GetXP(oPC);
        int nLevelXP = (((nLevel - 1) * nLevel) / 2) * 1000;
        SetXP(oPC, nLevelXP - 1);
        DelayCommand(0.5, SetXP(oPC, nOrigXP));
    }
}

void OnCutSceneAbort()
{
    RunEvent(MODULE_EVENT_ON_CUTSCENE_ABORT, GetLastPCToCancelCutscene());
}

void OnPlayerEquipItem()
{
    object oItem  = GetPCItemLastEquipped();
    object oPC    = GetPCItemLastEquippedBy();
    int    nState = RunItemEvent(MODULE_EVENT_ON_PLAYER_EQUIP_ITEM, oItem, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = GetTag(oItem);
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_EQUIP);
        RunLibraryScript(sTag);
    }
}

void OnPlayerUnEquipItem()
{
    object oItem  = GetPCItemLastUnequipped();
    object oPC    = GetPCItemLastUnequippedBy();
    int    nState = RunItemEvent(MODULE_EVENT_ON_PLAYER_UNEQUIP_ITEM, oItem, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = GetTag(oItem);
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNEQUIP);
        RunLibraryScript(sTag);
    }
}

void OnPlayerChat()
{
    object oPC = GetPCChatSpeaker();

    // Suppress the chat message if the player is being booted. This will stop
    // players from executing chat commands or spamming the server when banned.
    if (GetLocalInt(oPC, LOGIN_BOOT))
        SetPCChatMessage();
    else
    {
        int nState = RunEvent(MODULE_EVENT_ON_PLAYER_CHAT, oPC);
        if (nState & EVENT_STATE_DENIED)
            SetPCChatMessage();
    }
}

void OnPlayerGUI()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_GUI, GetLastGuiEventPlayer());
}

void OnNUI()
{
    object oPC    = NuiGetEventPlayer();
    int    nState = RunEvent(MODULE_EVENT_ON_NUI, oPC);

    if (ENABLE_TAGBASED_SCRIPTS && !(nState & EVENT_STATE_DENIED))
    {
        string sTag = NuiGetWindowId(oPC, NuiGetEventWindow());
        RunLibraryScript(sTag);
    }
}

void OnPlayerTileAction()
{
    RunEvent(MODULE_EVENT_ON_PLAYER_TILE_ACTION, GetLastPlayerToDoTileAction());
}

// -----------------------------------------------------------------------------
//                                  Door
// -----------------------------------------------------------------------------

void OnDoorOpen()
{
    RunEvent(DOOR_EVENT_ON_OPEN, GetLastOpenedBy());
}

void OnDoorClose()
{
    RunEvent(DOOR_EVENT_ON_CLOSE, GetLastClosedBy());
}

void OnDoorDamaged()
{
    RunEvent(DOOR_EVENT_ON_DAMAGED, GetLastDamager());
}

void OnDoorDeath()
{
    RunEvent(DOOR_EVENT_ON_DEATH, GetLastKiller());
}

void OnDoorHeartbeat()
{
    RunEvent(DOOR_EVENT_ON_HEARTBEAT);
}

void OnDoorLock()
{
    RunEvent(DOOR_EVENT_ON_LOCK);
}

void OnDoorPhysicalAttacked()
{
    RunEvent(DOOR_EVENT_ON_PHYSICAL_ATTACKED, GetLastAttacker());
}

void OnDoorSpellCastAt()
{
    RunEvent(DOOR_EVENT_ON_SPELL_CAST_AT, GetLastSpellCaster());
}

void OnDoorUnLock()
{
    RunEvent(DOOR_EVENT_ON_UNLOCK, GetLastUnlocked());
}

void OnDoorUserDefined()
{
    RunEvent(DOOR_EVENT_ON_USER_DEFINED);
}

void OnDoorAreaTransitionClick()
{
    RunEvent(DOOR_EVENT_ON_AREA_TRANSITION_CLICK, GetEnteringObject());
}

void OnDoorConversation()
{
    RunEvent(DOOR_EVENT_ON_CONVERSATION, GetLastSpeaker());
}

void OnDoorFailToOpen()
{
    RunEvent(DOOR_EVENT_ON_FAIL_TO_OPEN, GetClickingObject());
}

// -----------------------------------------------------------------------------
//                                  Trap
// -----------------------------------------------------------------------------

void OnTrapDisarm()
{
    RunEvent(TRAP_EVENT_ON_DISARM, GetLastDisarmed());
}

void OnTrapTriggered()
{
    RunEvent(TRAP_EVENT_ON_TRIGGERED, GetEnteringObject());
}

// -----------------------------------------------------------------------------
//                                Event Dispatch
// -----------------------------------------------------------------------------

void main()
{
    int nCurrentEvent = GetCurrentlyRunningEvent();

    switch (nCurrentEvent / 1000)
    {
        case EVENT_TYPE_MODULE:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_MODULE_ON_HEARTBEAT:              OnHeartbeat();            break;
                case EVENT_SCRIPT_MODULE_ON_USER_DEFINED_EVENT:     OnUserDefined();          break;
                case EVENT_SCRIPT_MODULE_ON_MODULE_LOAD:            OnModuleLoad();           break;
                case EVENT_SCRIPT_MODULE_ON_MODULE_START:                                               break;
                case EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER:           OnClientEnter();          break;
                case EVENT_SCRIPT_MODULE_ON_CLIENT_EXIT:            OnClientLeave();          break;
                case EVENT_SCRIPT_MODULE_ON_ACTIVATE_ITEM:          OnActivateItem();         break;
                case EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM:           OnAcquireItem();          break;
                case EVENT_SCRIPT_MODULE_ON_LOSE_ITEM:              OnUnAcquireItem();        break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_DEATH:           OnPlayerDeath();          break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_DYING:           OnPlayerDying();          break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET:          OnPlayerTarget();         break;
                case EVENT_SCRIPT_MODULE_ON_RESPAWN_BUTTON_PRESSED: OnPlayerReSpawn();        break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_REST:            OnPlayerRest();           break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_LEVEL_UP:        OnPlayerLevelUp();        break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_CANCEL_CUTSCENE: OnCutSceneAbort();        break;
                case EVENT_SCRIPT_MODULE_ON_EQUIP_ITEM:             OnPlayerEquipItem();      break;
                case EVENT_SCRIPT_MODULE_ON_UNEQUIP_ITEM:           OnPlayerUnEquipItem();    break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_CHAT:            OnPlayerChat();           break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT:        OnPlayerGUI();            break;
                case EVENT_SCRIPT_MODULE_ON_NUI_EVENT:              OnNUI();                  break;
                case EVENT_SCRIPT_MODULE_ON_PLAYER_TILE_ACTION:     OnPlayerTileAction();     break;
            } break;
        }
        case EVENT_TYPE_AREA:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_AREA_ON_HEARTBEAT:            OnAreaHeartbeat();    break;
                case EVENT_SCRIPT_AREA_ON_USER_DEFINED_EVENT:   OnAreaUserDefined();  break;
                case EVENT_SCRIPT_AREA_ON_ENTER:                OnAreaEnter();        break;
                case EVENT_SCRIPT_AREA_ON_EXIT:                 OnAreaExit();         break;
            } break;
        }
        case EVENT_TYPE_AREAOFEFFECT:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_AREAOFEFFECT_ON_HEARTBEAT:            OnAoEHeartbeat();     break;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_USER_DEFINED_EVENT:   OnAoEUserDefined();   break;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_ENTER:         OnAoEEnter();         break;
                case EVENT_SCRIPT_AREAOFEFFECT_ON_OBJECT_EXIT:          OnAoEExit();          break;
            } break;
        }
        case EVENT_TYPE_CREATURE:
        {
            int bIsPC = GetIsPC(OBJECT_SELF);
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_CREATURE_ON_HEARTBEAT:            OnCreatureHeartbeat(bIsPC);        break;
                case EVENT_SCRIPT_CREATURE_ON_NOTICE:               OnCreaturePerception(bIsPC);       break;
                case EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT:          OnCreatureSpellCastAt(bIsPC);      break;
                case EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED:       OnCreaturePhysicalAttacked(bIsPC); break;
                case EVENT_SCRIPT_CREATURE_ON_DAMAGED:              OnCreatureDamaged(bIsPC);          break;
                case EVENT_SCRIPT_CREATURE_ON_DISTURBED:            OnCreatureDisturbed(bIsPC);        break;
                case EVENT_SCRIPT_CREATURE_ON_END_COMBATROUND:      OnCreatureCombatRoundEnd(bIsPC);   break;
                case EVENT_SCRIPT_CREATURE_ON_DIALOGUE:             OnCreatureConversation(bIsPC);     break;
                case EVENT_SCRIPT_CREATURE_ON_SPAWN_IN:             OnCreatureSpawn(bIsPC);            break;
                case EVENT_SCRIPT_CREATURE_ON_RESTED:               OnCreatureRested(bIsPC);           break;
                case EVENT_SCRIPT_CREATURE_ON_DEATH:                OnCreatureDeath(bIsPC);            break;
                case EVENT_SCRIPT_CREATURE_ON_USER_DEFINED_EVENT:   OnCreatureUserDefined(bIsPC);      break;
                case EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR:      OnCreatureBlocked(bIsPC);          break;
            } break;
        }
        case EVENT_TYPE_TRIGGER:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_TRIGGER_ON_HEARTBEAT:             OnTriggerHeartbeat();     break;
                case EVENT_SCRIPT_TRIGGER_ON_OBJECT_ENTER:          OnTriggerEnter();         break;
                case EVENT_SCRIPT_TRIGGER_ON_OBJECT_EXIT:           OnTriggerExit();          break;
                case EVENT_SCRIPT_TRIGGER_ON_USER_DEFINED_EVENT:    OnTriggerUserDefined();   break;
                case EVENT_SCRIPT_TRIGGER_ON_TRAPTRIGGERED:         OnTrapTriggered();        break;
                case EVENT_SCRIPT_TRIGGER_ON_DISARMED:              OnTrapDisarm();           break;
                case EVENT_SCRIPT_TRIGGER_ON_CLICKED:               OnTriggerClick();         break;
            } break;
        }
        case EVENT_TYPE_PLACEABLE:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_PLACEABLE_ON_CLOSED:              OnPlaceableClose();               break;
                case EVENT_SCRIPT_PLACEABLE_ON_DAMAGED:             OnPlaceableDamaged();             break;
                case EVENT_SCRIPT_PLACEABLE_ON_DEATH:               OnPlaceableDeath();               break;
                case EVENT_SCRIPT_PLACEABLE_ON_DISARM:              OnTrapDisarm();                   break;
                case EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT:           OnPlaceableHeartbeat();           break;
                case EVENT_SCRIPT_PLACEABLE_ON_INVENTORYDISTURBED:  OnPlaceableDisturbed();           break;
                case EVENT_SCRIPT_PLACEABLE_ON_LOCK:                OnPlaceableLock();                break;
                case EVENT_SCRIPT_PLACEABLE_ON_MELEEATTACKED:       OnPlaceablePhysicalAttacked();    break;
                case EVENT_SCRIPT_PLACEABLE_ON_OPEN:                OnPlaceableOpen();                break;
                case EVENT_SCRIPT_PLACEABLE_ON_SPELLCASTAT:         OnPlaceableSpellCastAt();         break;
                case EVENT_SCRIPT_PLACEABLE_ON_TRAPTRIGGERED:       OnTrapTriggered();                break;
                case EVENT_SCRIPT_PLACEABLE_ON_UNLOCK:              OnPlaceableUnLock();              break;
                case EVENT_SCRIPT_PLACEABLE_ON_USED:                OnPlaceableUsed();                break;
                case EVENT_SCRIPT_PLACEABLE_ON_USER_DEFINED_EVENT:  OnPlaceableUserDefined();         break;
                case EVENT_SCRIPT_PLACEABLE_ON_DIALOGUE:            OnPlaceableConversation();        break;
                case EVENT_SCRIPT_PLACEABLE_ON_LEFT_CLICK:          OnPlaceableClick();               break;
            } break;
        }
        case EVENT_TYPE_DOOR:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_DOOR_ON_OPEN:             OnDoorOpen();                 break;
                case EVENT_SCRIPT_DOOR_ON_CLOSE:            OnDoorClose();                break;
                case EVENT_SCRIPT_DOOR_ON_DAMAGE:           OnDoorDamaged();              break;
                case EVENT_SCRIPT_DOOR_ON_DEATH:            OnDoorDeath();                break;
                case EVENT_SCRIPT_DOOR_ON_DISARM:           OnTrapDisarm();               break;
                case EVENT_SCRIPT_DOOR_ON_HEARTBEAT:        OnDoorHeartbeat();            break;
                case EVENT_SCRIPT_DOOR_ON_LOCK:             OnDoorLock();                 break;
                case EVENT_SCRIPT_DOOR_ON_MELEE_ATTACKED:   OnDoorPhysicalAttacked();     break;
                case EVENT_SCRIPT_DOOR_ON_SPELLCASTAT:      OnDoorSpellCastAt();          break;
                case EVENT_SCRIPT_DOOR_ON_TRAPTRIGGERED:    OnTrapTriggered();            break;
                case EVENT_SCRIPT_DOOR_ON_UNLOCK:           OnDoorUnLock();               break;
                case EVENT_SCRIPT_DOOR_ON_USERDEFINED:      OnDoorUserDefined();          break;
                case EVENT_SCRIPT_DOOR_ON_CLICKED:          OnDoorAreaTransitionClick();  break;
                case EVENT_SCRIPT_DOOR_ON_DIALOGUE:         OnDoorConversation();         break;
                case EVENT_SCRIPT_DOOR_ON_FAIL_TO_OPEN:     OnDoorFailToOpen();           break;
            } break;
        }
        case EVENT_TYPE_ENCOUNTER:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_ENTER:        OnEncounterEnter();       break;
                case EVENT_SCRIPT_ENCOUNTER_ON_OBJECT_EXIT:         OnEncounterExit();        break;
                case EVENT_SCRIPT_ENCOUNTER_ON_HEARTBEAT:           OnEncounterHeartbeat();   break;
                case EVENT_SCRIPT_ENCOUNTER_ON_ENCOUNTER_EXHAUSTED: OnEncounterExhausted();   break;
                case EVENT_SCRIPT_ENCOUNTER_ON_USER_DEFINED_EVENT:  OnEncounterUserDefined(); break;
            } break;
        }
        case EVENT_TYPE_STORE:
        {
            switch (nCurrentEvent)
            {
                case EVENT_SCRIPT_STORE_ON_OPEN:    OnStoreOpen();    break;
                case EVENT_SCRIPT_STORE_ON_CLOSE:   OnStoreClose();   break;
            } break;
        }
    }
}
/// ----------------------------------------------------------------------------
/// @file   hook_spellhook.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  OnSpellhook event script.
/// ----------------------------------------------------------------------------

#include "core_i_framework"
#include "x2_inc_switches"

void main()
{
    int nState = RunEvent(MODULE_EVENT_ON_SPELLHOOK);

    // The DENIED state stops the spell from executing
    if (nState & EVENT_STATE_DENIED)
        SetModuleOverrideSpellScriptFinished();
    else
    {
        // Handle the special case of casting a spell at an item
        object oItem = GetSpellTargetObject();

        if (GetObjectType(oItem) == OBJECT_TYPE_ITEM)
        {
            string sTag = GetTag(oItem);
            SetUserDefinedItemEventNumber(X2_ITEM_EVENT_SPELLCAST_AT);
            RunLibraryScript(sTag);
        }
    }
}
/// ----------------------------------------------------------------------------
/// @file   hook_timerhook.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Hook script that handles timers as Core Framework events.
/// ----------------------------------------------------------------------------

#include "core_i_framework"

void main()
{
    string sEvent  = GetScriptParam(TIMER_ACTION);
    string sSource = GetScriptParam(TIMER_SOURCE);
    object oSource = StringToObject(sSource);
    RunEvent(sEvent, oSource);
}
// -----------------------------------------------------------------------------
//    File: pqj_i_main.nss
//  System: Persistent Quests and Journals (include script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This is the main include file for the Persistent Quests and Journals plugin.
// -----------------------------------------------------------------------------

#include "util_i_debug"
#include "util_i_sqlite"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ---< pqj_CreateTable >---
// ---< pqj_i_main >---
// Creates a table for PQJ quest data in oPC's persistent SQLite database. If
// bForce is true, will drop any existing table before creating a new one.
void pqj_CreateTable(object oPC, int bForce = FALSE);

// ---< pqj_RestoreJournalEntries >---
// ---< pqj_i_main >---
// Restores all journal entries from oPC's persistent SQLite database. This
// should be called once OnClientEnter. Ensure the table has been created using
// pqj_CreateTable() before calling this.
void pqj_RestoreJournalEntries(object oPC);

// ---< pqj_GetQuestState >---
// ---< pqj_i_main >---
// Returns the state of a quest for the PC. This matches a plot ID and number
// from the journal. Returns 0 if the quest has not been started.
int pqj_GetQuestState(string sPlotID, object oPC);

// ---< pqj_AddJournalQuestEntry >---
// ---< pqj_i_main >---
// As AddJournalQuestEntry(), but stores the quest state in the database so it
// can be restored after a server reset.
void pqj_AddJournalQuestEntry(string sPlotID, int nState, object oPC, int bAllPartyMembers = TRUE, int bAllPlayers = FALSE, int bAllowOverrideHigher = FALSE);

// ---< pqj_RemoveJournalQuestEntry >---
// ---< pqj_i_main >---
// As RemoveJournalQuestEntry(), but removes the quest from the database so it
// will not be restored after a server reset.
void pqj_RemoveJournalQuestEntry(string sPlotID, object oPC, int bAllPartyMembers = TRUE, int bAllPlayers = FALSE);

// -----------------------------------------------------------------------------
//                              Funcion Definitions
// -----------------------------------------------------------------------------

void pqj_CreateTable(object oPC, int bForce = FALSE)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC))
        return;

    Debug("Creating table pqjdata on " + GetName(oPC));
    SqlCreateTablePC(oPC, "pqjdata",
        "quest TEXT NOT NULL PRIMARY KEY, " +
        "state INTEGER NOT NULL DEFAULT 0", bForce);
}

void pqj_RestoreJournalEntries(object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC))
        return;

    int    nState;
    string sPlotID;
    string sName = GetName(oPC);
    string sQuery = "SELECT quest, state FROM pqjdata";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    while (SqlStep(qQuery))
    {
        sPlotID = SqlGetString(qQuery, 0);
        nState = SqlGetInt(qQuery, 1);
        Debug("Restoring journal entry; PC: " + sName + ", " +
              "PlotID: " + sPlotID + "; PlotState: " + IntToString(nState));
        AddJournalQuestEntry(sPlotID, nState, oPC, FALSE);
    }
}

int pqj_GetQuestState(string sPlotID, object oPC)
{
    if (!GetIsPC(oPC) || GetIsDM(oPC))
        return 0;

    string sQuery = "SELECT state FROM pqjdata WHERE quest=@quest;";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(qQuery, "@quest", sPlotID);
    if (SqlStep(qQuery))
        return SqlGetInt(qQuery, 0);

    return 0;
}

// Internal function for pqj_AddJournalQuestEntry().
void _StoreQuestEntry(string sPlotID, int nState, object oPC, int bAllowOverrideHigher = FALSE)
{
    string sMessage = "persistent journal entry for " + GetName(oPC) + "; " +
        "sPlotID: " + sPlotID + "; nState: " + IntToString(nState);
    string sQuery = "INSERT INTO pqjdata (quest, state) " +
        "VALUES (@quest, @state) ON CONFLICT (quest) DO UPDATE SET state = " +
        (bAllowOverrideHigher ? "@state" : "MAX(state, @state)") + ";";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(qQuery, "@quest", sPlotID);
    SqlBindInt(qQuery, "@state", nState);
    SqlStep(qQuery);

    string sError = SqlGetError(qQuery);
    if (sError == "")
        Debug("Adding " + sMessage);
    else
        CriticalError("Could not add " + sMessage + ": " + sError);
}

void pqj_AddJournalQuestEntry(string sPlotID, int nState, object oPC, int bAllPartyMembers = TRUE, int bAllPlayers = FALSE, int bAllowOverrideHigher = FALSE)
{
    if (!GetIsPC(oPC))
        return;

    AddJournalQuestEntry(sPlotID, nState, oPC, bAllPartyMembers, bAllPlayers, bAllowOverrideHigher);

    if (bAllPlayers)
    {
        Debug("Adding journal entry " + sPlotID + " for all players");
        oPC = GetFirstPC();
        while (GetIsObjectValid(oPC))
        {
            _StoreQuestEntry(sPlotID, nState, oPC, bAllowOverrideHigher);
            oPC = GetNextPC();
        }
    }
    else if (bAllPartyMembers)
    {
        Debug("Adding journal entry " + sPlotID + " for " + GetName(oPC) +
              "'s party members");
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            _StoreQuestEntry(sPlotID, nState, oPartyMember, bAllowOverrideHigher);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        _StoreQuestEntry(sPlotID, nState, oPC, bAllowOverrideHigher);
}

// Internal function for pqj_RemoveJournalQuestEntry()
void _DeleteQuestEntry(string sPlotID, object oPC)
{
    string sName    = GetName(oPC);
    string sMessage = "persistent journal entry for " + sName + "; " +
                      "PlotID: " + sPlotID;

    string sQuery = "DELETE FROM pqjdata WHERE quest=@quest;";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(qQuery, "@quest", sPlotID);
    SqlStep(qQuery);

    string sError = SqlGetError(qQuery);
    if (sError == "")
        Debug("Removed " + sMessage);
    else
        CriticalError("Could not remove " + sMessage + ": " + sError);
}

void pqj_RemoveJournalQuestEntry(string sPlotID, object oPC, int bAllPartyMembers = TRUE, int bAllPlayers = FALSE)
{
    RemoveJournalQuestEntry(sPlotID, oPC, bAllPartyMembers, bAllPlayers);

    if (bAllPlayers)
    {
        Debug("Removing journal entry " + sPlotID + " for all players");
        oPC = GetFirstPC();
        while (GetIsObjectValid(oPC))
        {
            _DeleteQuestEntry(sPlotID, oPC);
            oPC = GetNextPC();
        }
    }
    else if (bAllPartyMembers)
    {
        Debug("Removing journal entry " + sPlotID + " for " + GetName(oPC) +
              "'s party members");
        object oPartyMember = GetFirstFactionMember(oPC, TRUE);
        while (GetIsObjectValid(oPartyMember))
        {
            _DeleteQuestEntry(sPlotID, oPartyMember);
            oPartyMember = GetNextFactionMember(oPC, TRUE);
        }
    }
    else
        _DeleteQuestEntry(sPlotID, oPC);
}
// -----------------------------------------------------------------------------
//    File: pqj_l_plugin.nss
//  System: Persistent Quests and Journals (library script)
//     URL: https://github.com/squattingmonk/nwn-core-framework
// Authors: Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
// -----------------------------------------------------------------------------
// This library script contains scripts to hook in to Core Framework events.
// -----------------------------------------------------------------------------

#include "util_i_library"
#include "core_i_framework"
#include "pqj_i_main"

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("pqj"))
    {
        object oPlugin = CreatePlugin("pqj");
        SetName(oPlugin, "[Plugin] Persistent Quests and Journals");
        SetDescription(oPlugin,
            "This plugin allows database-driven persistent journal entries.");

        RegisterEventScript(oPlugin, MODULE_EVENT_ON_CLIENT_ENTER, "pqj_RestoreJournalEntries");
    }

    RegisterLibraryScript("pqj_RestoreJournalEntries", 1);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1:
        {
            object oPC = GetEventTriggeredBy();
            pqj_CreateTable(oPC);
            pqj_RestoreJournalEntries(oPC);
        } break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
/// ----------------------------------------------------------------------------
/// @file   target_l_plugin.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Event scripts to integrate player targeting into the
///     core framework
/// ----------------------------------------------------------------------------

#include "util_i_library"
#include "util_i_targeting"
#include "core_i_framework"

// -----------------------------------------------------------------------------
//                               Event Scripts
// -----------------------------------------------------------------------------

/// @brief Creates the required targeting hook and data tables in the
///     module's volatile sqlite database.
void targeting_OnModuleLoad()
{
    CreateTargetingDataTables(TRUE);
}

/// @brief Checks the targeting player for a current hook.  If found, executes
///     the targeting event and denies further OnPlayerTarget scripts.
void targeting_OnPlayerTarget()
{
    object oPC = GetLastPlayerToSelectTarget();

    if (SatisfyTargetingHook(oPC))
        SetEventState(EVENT_STATE_ABORT);
}

// -----------------------------------------------------------------------------
//                               Library Dispatch
// -----------------------------------------------------------------------------

void OnLibraryLoad()
{
    if (!GetIfPluginExists("targeting"))
    {
        object oPlugin = CreatePlugin("targeting");
        SetName(oPlugin, "[Plugin] Player Targeting System");
        SetDescription(oPlugin, "Manages forced player targeting mode and target lists.");
        SetDebugPrefix(HexColorString("[Targeting]", COLOR_CORAL_LIGHT), oPlugin);
        
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_MODULE_LOAD,   "targeting_OnModuleLoad");
        RegisterEventScript(oPlugin, MODULE_EVENT_ON_PLAYER_TARGET, "targeting_OnPlayerTarget", EVENT_PRIORITY_FIRST);
    }

    RegisterLibraryScript("targeting_OnModuleLoad",   1);
    RegisterLibraryScript("targeting_OnPlayerTarget", 2);
}

void OnLibraryScript(string sScript, int nEntry)
{
    switch (nEntry)
    {
        case 1: targeting_OnModuleLoad();   break;
        case 2: targeting_OnPlayerTarget(); break;
        default: CriticalError("Library function " + sScript + " not found");
    }
}
/// ----------------------------------------------------------------------------
/// @file   util_c_color.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_color.nss.
/// @details
/// These color codes are used with the functions from util_i_color.nss. These
/// are hex color codes, the same as you'd use in web design and may other
/// areas, so they are easy to look up and to copy-paste into other programs.
///
/// You can change the values of any of constants below, but do not change the
/// names of the constants themselves. You can also add your own constants for
/// use in your module.
///
/// ## Acknowledgement
/// - Function colors copied from https://nwn.wiki/display/NWN1/Colour+Tokens.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                               X11 Color Palette
// -----------------------------------------------------------------------------

// ----- Whites ----------------------------------------------------------------
const int COLOR_AZURE               = 0xf0ffff;
const int COLOR_BEIGE               = 0xf5f5dc;
const int COLOR_BLUE_ALICE          = 0xf0f8ff;
const int COLOR_HONEYDEW            = 0xf0fff0;
const int COLOR_IVORY               = 0xfffff0;
const int COLOR_LAVENDERBLUSH       = 0xfff0f5;
const int COLOR_LINEN               = 0xfaf0e6;
const int COLOR_MINTCREAM           = 0xf5fffa;
const int COLOR_MISTYROSE           = 0xffe4e1;
const int COLOR_OLDLACE             = 0xfdf5e6;
const int COLOR_SEASHELL            = 0xfff5ee;
const int COLOR_SNOW                = 0xfffafa;
const int COLOR_WHITE               = 0xffffff;
const int COLOR_WHITE_ANTIQUE       = 0xfaebd7;
const int COLOR_WHITE_FLORAL        = 0xfffaf0;
const int COLOR_WHITE_GHOST         = 0xf8f8ff;
const int COLOR_WHITE_SMOKE         = 0xf5f5f5;

// ----- Blues -----------------------------------------------------------------
const int COLOR_AQUA                = 0x00ffff;
const int COLOR_AQUAMARINE          = 0x7fffd4;
const int COLOR_BLUE                = 0x0000ff;
const int COLOR_BLUE_CORNFLOWER     = 0x6495ed;
const int COLOR_BLUE_DARK           = 0x00008b;
const int COLOR_BLUE_DODGER         = 0x1e90ff;
const int COLOR_BLUE_LIGHT          = 0xadd8e6;
const int COLOR_BLUE_MEDIUM         = 0x0000cd;
const int COLOR_BLUE_MIDNIGHT       = 0x191970;
const int COLOR_BLUE_POWDER         = 0xb0e0e6;
const int COLOR_BLUE_ROYAL          = 0x4169e1;
const int COLOR_BLUE_SKY            = 0x87ceeb;
const int COLOR_BLUE_SKY_DEEP       = 0x00bfff;
const int COLOR_BLUE_SKY_LIGHT      = 0x87cefa;
const int COLOR_BLUE_SLATE          = 0x6a5acd;
const int COLOR_BLUE_SLATE_MEDIUM   = 0x7b68ee;
const int COLOR_BLUE_STEEL          = 0x4682b4;
const int COLOR_BLUE_STEEL_LIGHT    = 0xb0c4de;
const int COLOR_CYAN                = 0x00ffff;
const int COLOR_CYAN_LIGHT          = 0xe0ffff;
const int COLOR_NAVY                = 0x000080;
const int COLOR_TURQUOISE           = 0x40e0d0;
const int COLOR_TURQUOISE_DARK      = 0x00ced1;
const int COLOR_TURQUOISE_MEDIUM    = 0x48d1cc;
const int COLOR_TURQUOISE_PALE      = 0xafeeee;

// ----- Browns ----------------------------------------------------------------
const int COLOR_BISQUE              = 0xffe4c4;
const int COLOR_BLANCHED_ALMOND     = 0xffebcd;
const int COLOR_BROWN               = 0xa52a2a;
const int COLOR_BROWN_LIGHT         = 0xd0814b;
const int COLOR_BROWN_ROSY          = 0xbc8f8f;
const int COLOR_BROWN_SADDLE        = 0x8b4513;
const int COLOR_BROWN_SANDY         = 0xf4a460;
const int COLOR_BURLYWOOD           = 0xdeb887;
const int COLOR_CHOCOLATE           = 0xd2691e;
const int COLOR_CORNSILK            = 0xfff8dc;
const int COLOR_GOLDENROD           = 0xdaa520;
const int COLOR_GOLDENROD_DARK      = 0xb8860b;
const int COLOR_MAROON              = 0x800000;
const int COLOR_PERU                = 0xcd853f;
const int COLOR_SIENNA              = 0xa0522d;
const int COLOR_TAN                 = 0xd2b48c;
const int COLOR_WHEAT               = 0xf5deb3;
const int COLOR_WHITE_NAVAJO        = 0xffdead;

// ----- Purples ---------------------------------------------------------------
const int COLOR_BLUE_SLATE_DARK     = 0x483d8b;
const int COLOR_BLUE_VIOLET         = 0x8a2be2;
const int COLOR_FUCHSIA             = 0xff00ff;
const int COLOR_INDIGO              = 0x4b0082;
const int COLOR_LAVENDER            = 0xe6e6fa;
const int COLOR_MAGENTA             = 0xff00ff;
const int COLOR_MAGENTA_DARK        = 0x8b008b;
const int COLOR_ORCHID              = 0xda70d6;
const int COLOR_ORCHID_DARK         = 0x9932cc;
const int COLOR_ORCHID_MEDIUM       = 0xba55d3;
const int COLOR_PLUM                = 0xdda0dd;
const int COLOR_PURPLE              = 0x800080;
const int COLOR_PURPLE_MEDIUM       = 0x9370d8;
const int COLOR_THISTLE             = 0xd8bfd8;
const int COLOR_VIOLET              = 0xee82ee;
const int COLOR_VIOLET_DARK         = 0x9400d3;
const int COLOR_VIOLET_LIGHT        = 0xf397f8;

// ----- Oranges ---------------------------------------------------------------
const int COLOR_CORAL               = 0xff7f50;
const int COLOR_ORANGE              = 0xffa500;
const int COLOR_ORANGE_DARK         = 0xff8c00;
const int COLOR_ORANGE_LIGHT        = 0xf3b800;
const int COLOR_ORANGE_RED          = 0xff4500;
const int COLOR_SALMON_LIGHT        = 0xffa07a;
const int COLOR_TOMATO              = 0xff6347;

// ----- Reds ------------------------------------------------------------------
const int COLOR_CORAL_LIGHT         = 0xf08080;
const int COLOR_CRIMSON             = 0xdc143c;
const int COLOR_FIREBRICK           = 0xb22222;
const int COLOR_RED                 = 0xff0000;
const int COLOR_RED_DARK            = 0x8b0000;
const int COLOR_RED_INDIAN          = 0xcd5c4c;
const int COLOR_RED_LIGHT           = 0xfa6155;
const int COLOR_SALMON              = 0xfa8072;
const int COLOR_SALMON_DARK         = 0xe9967a;

// ----- Pinks -----------------------------------------------------------------
const int COLOR_PINK                = 0xffc0cb;
const int COLOR_PINK_DEEP           = 0xff1493;
const int COLOR_PINK_HOT            = 0xff69b4;
const int COLOR_PINK_LIGHT          = 0xffb6c1;
const int COLOR_VIOLET_RED_MEDIUM   = 0xc71585;
const int COLOR_VIOLET_RED_PALE     = 0xdb7093;

// ----- Grays -----------------------------------------------------------------
const int COLOR_BLACK               = 0x000000;
const int COLOR_GAINSBORO           = 0xdcdcdc;
const int COLOR_GRAY                = 0x808080;
const int COLOR_GRAY_DARK           = 0xa9a9a9;
const int COLOR_GRAY_DIM            = 0x696969;
const int COLOR_GRAY_LIGHT          = 0xd3d3d3;
const int COLOR_GRAY_SLATE          = 0x708090;
const int COLOR_GRAY_SLATE_DARK     = 0x2f4f4f;
const int COLOR_GRAY_SLATE_LIGHT    = 0x778899;
const int COLOR_SILVER              = 0xc0c0c0;

// ----- Greens ----------------------------------------------------------------
const int COLOR_AQUAMARINE_MEDIUM   = 0x66cdaa;
const int COLOR_CHARTREUSE          = 0x7fff00;
const int COLOR_CYAN_DARK           = 0x008b8b;
const int COLOR_GREEN               = 0x008000;
const int COLOR_GREEN_DARK          = 0x006400;
const int COLOR_GREEN_FOREST        = 0x228b22;
const int COLOR_GREEN_LAWN          = 0x7cfc00;
const int COLOR_GREEN_LIGHT         = 0x90ee90;
const int COLOR_GREEN_LIME          = 0x32cd32;
const int COLOR_GREEN_OLIVE_DARK    = 0x556b2f;
const int COLOR_GREEN_PALE          = 0x98fb98;
const int COLOR_GREEN_SEA           = 0x2e8b57;
const int COLOR_GREEN_SEA_DARK      = 0x8fbc8f;
const int COLOR_GREEN_SEA_LIGHT     = 0x20b2aa;
const int COLOR_GREEN_SEA_MEDIUM    = 0x3cb371;
const int COLOR_GREEN_SPRING        = 0x00ff7f;
const int COLOR_GREEN_SPRING_MEDIUM = 0x00fa9a;
const int COLOR_GREEN_YELLOW        = 0xadff2f;
const int COLOR_LIME                = 0x00ff00;
const int COLOR_OLIVE               = 0x808000;
const int COLOR_OLIVE_DRAB          = 0x6b8e23;
const int COLOR_TEAL                = 0x008080;
const int COLOR_YELLOW_GREEN        = 0x9acd32;

// ----- Yellows ---------------------------------------------------------------
const int COLOR_GOLD                = 0xffd700;
const int COLOR_GOLDENROD_LIGHT     = 0xfafad2;
const int COLOR_GOLDENROD_PALE      = 0xeee8aa;
const int COLOR_KHAKI               = 0xf0e68c;
const int COLOR_KHAKI_DARK          = 0xbdb76b;
const int COLOR_LEMON_CHIFFON       = 0xfffacd;
const int COLOR_MOCCASIN            = 0xffe4b5;
const int COLOR_PAPAYA_WHIP         = 0xffefd5;
const int COLOR_PEACH_PUFF          = 0xffdab9;
const int COLOR_YELLOW              = 0xffff00;
const int COLOR_YELLOW_DARK         = 0xd0ce00;
const int COLOR_YELLOW_LIGHT        = 0xffffe0;

// -----------------------------------------------------------------------------
//                              Colors By Function
// -----------------------------------------------------------------------------

const int COLOR_DEFAULT             = 0xfefefe;
const int COLOR_ATTENTION           = 0xfea400;
const int COLOR_BUG                 = 0x660000;
const int COLOR_FAIL                = 0xff0000;
const int COLOR_SUCCESS             = 0x3dc93d;
const int COLOR_DEBUG               = 0xb4b4b4;
const int COLOR_INFO                = 0xd0814b;

// ----- Damage Types ----------------------------------------------------------
const int COLOR_DAMAGE_MAGICAL      = 0xcc77ff;
const int COLOR_DAMAGE_ACID         = 0x01ff01;
const int COLOR_DAMAGE_COLD         = 0x99ffff;
const int COLOR_DAMAGE_DIVINE       = 0xffff01;
const int COLOR_DAMAGE_ELECTRICAL   = 0x0166ff;
const int COLOR_DAMAGE_FIRE         = 0xff0101;
const int COLOR_DAMAGE_NEGATIVE     = 0x999999;
const int COLOR_DAMAGE_POSITIVE     = 0xffffff;
const int COLOR_DAMAGE_SONIC        = 0xff9901;

// ----- Chat Log Messages -----------------------------------------------------
const int COLOR_MESSAGE_FEEDBACK    = 0xffff01;
const int COLOR_MESSAGE_COMBAT      = 0xff6601;
const int COLOR_MESSAGE_MAGIC       = 0xcc77ff;
const int COLOR_MESSAGE_SKILLS      = 0x0166ff;
const int COLOR_MESSAGE_SAVING      = 0x66ccff;
const int COLOR_SAVE_STATUS         = 0x20ff20;
const int COLOR_PAUSE_STATE         = 0xff0101;
const int COLOR_NAME_CLIENT         = 0x99ffff;
const int COLOR_NAME_OTHER          = 0xcc99cc;

// -----------------------------------------------------------------------------
//                                 Custom Colors
// -----------------------------------------------------------------------------
// You can add any custom colors you need for your functions below this line.
// -----------------------------------------------------------------------------

/// ----------------------------------------------------------------------------
/// @file   util_c_debug.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Configuration file for util_i_debug.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                        Helper Constants and Functions
// -----------------------------------------------------------------------------
// If you need custom constants, functions, or #includes, you may add them here.
// Since this file is included by util_i_debug.nss, you do not need to #include
// it to use its constants.
// -----------------------------------------------------------------------------

/*
// These constants are used by the example code below. Uncomment if you want to
// use them.

/// @brief This is the minimum debug level required to trigger custom handling.
/// @details Setting this to DEBUG_LEVEL_ERROR means OnDebug() will handle only
///     messages marked as DEBUG_LEVEL_ERROR and DEBUG_LEVEL_CRITICAL. If set to
///     DEBUG_LEVEL_NONE, the user-defined event will never be triggered.
/// @warning It is not recommended to set this level to DEBUG_LEVEL_NOTICE or
///     DEBUG_LEVEL_DEBUG as this could create high message traffic rates.
const int DEBUG_EVENT_TRIGGER_LEVEL = DEBUG_LEVEL_ERROR;

// These are varnames for script parameters
const string DEBUG_PARAM_PREFIX  = "DEBUG_PARAM_PREFIX";
const string DEBUG_PARAM_MESSAGE = "DEBUG_PARAM_MESSAGE";
const string DEBUG_PARAM_LEVEL   = "DEBUG_PARAM_LEVEL";
const string DEBUG_PARAM_TARGET  = "DEBUG_PARAM_TARGET";
*/

// -----------------------------------------------------------------------------
//                                 Debug Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom debug event handler
/// @details This is a customizable function that runs before a message is shown
///     using Debug(). This function provides a user-definable hook into the
///     debug notification system. For example, a module can use this hook to
///     execute a script that may be able to handle module-specific error
///     handling or messaging.
/// @param sPrefix the debug message source provided by GetDebugPrefix()
/// @param sMessage the debug message provided to Debug()
/// @param nLevel the debug level of the message provided to Debug()
/// @param oTarget the game object being debugged as provided to Debug()
/// @returns TRUE if the message should be sent as normal; FALSE if no message
///     should be sent.
/// @note This function will never fire if oTarget is not debugging messages of
///     nLevel.
/// @warning Do not call Debug() or its aliases Notice(), Warning(), Error(), or
///     CriticalError() from this function; that would cause an infinite loop.
int HandleDebug(string sPrefix, string sMessage, int nLevel, object oTarget)
{
    /*
    // The following example code allows an external script to handle the event
    // with access to the appropriate script parameters. Optionally, all event
    // handling can be accomplished directly in this function.

    // Only do custom handling if the debug level is error or critical error.
    if (!nLevel || nLevel > DEBUG_EVENT_TRIGGER_LEVEL)
        return TRUE;

    SetScriptParam(DEBUG_PARAM_PREFIX,  sPrefix);
    SetScriptParam(DEBUG_PARAM_MESSAGE, sMessage);
    SetScriptParam(DEBUG_PARAM_LEVEL,   IntToString(nLevel));
    SetScriptParam(DEBUG_PARAM_TARGET,  ObjectToString(oTarget));
    ExecuteScript("mydebugscript", oTarget);
    return FALSE;
    */

    return TRUE;
}
/// ----------------------------------------------------------------------------
/// @file   util_c_strftime.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Configuration settings for util_i_strftime.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                    Locale
// -----------------------------------------------------------------------------
// A locale is a group of localization settings stored as key-value pairs on a
// json object which is then stored on the module and accessed by a name. Some
// functions can take a locale name as an optional parameter so they can access
// those settings. If no name is provided, those functions will use the default
// locale instead.
// -----------------------------------------------------------------------------

/// This is the name for the default locale. All settings below will apply to
/// this locale.
const string DEFAULT_LOCALE = "EN_US";

// -----------------------------------------------------------------------------
//                                 Translations
// -----------------------------------------------------------------------------

/// This is a 12-element comma-separated list of month names. `%B` evaluates to
/// the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS = "January, February, March, April, May, June, July, August, September, October, November, December";

/// This is a 12-element comma-separated list of abbreviated month names. `%b`
/// evaluates to the item at index `(month - 1) % 12`.
const string DEFAULT_MONTHS_ABBR = "Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec";

/// This is a 7-element comma-separated list of weekday names. `%A` evaluates to
/// the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS = "Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday";

/// This is a 7-element comma-separated list of abbreviated day names. `%a`
/// evaluates to the item at index `(day - 1) % 7`.
const string DEFAULT_DAYS_ABBR = "Mon, Tue, Wed, Thu, Fri, Sat, Sun";

/// This is a 2-element comma-separated list with the preferred representation
/// of AM/PM. Noon is treated as PM and midnight is treated as AM. Evaluated by
/// `%p` (uppercase) and `%P` (lowercase).
const string DEFAULT_AMPM = "AM, PM";

/// This is a comma-separated list of suffixes for ordinal numbers. The list
/// should start with the suffix for 0. When formatting using the ordinal flag
/// (e.g., "Today is the %Od day of %B"), the number being formatted is used as
/// an index into this list. If the last two digits of the number are greater
/// than or equal to the length of the list, only the last digit of the number
/// is used. The default value will handle all integers in English.
const string DEFAULT_ORDINAL_SUFFIXES = "th, st, nd, rd, th, th, th, th, th, th, th, th, th, th";
//                                       0   1   2   3   4   5   6   7   8   9   10  11  12  13

// -----------------------------------------------------------------------------
//                                  Formatting
// -----------------------------------------------------------------------------
// These are strings that are used to format dates and times. Refer to the
// comments in `util_i_strftime.nss` for the meaning of format codes. Some codes
// are aliases for these values, so take care to avoid using those codes in
// these values to prevent an infinite loop.
// -----------------------------------------------------------------------------

/// This is a string used to format a date and time. Aliased by `%c`.
const string DEFAULT_DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S:%f";

/// This is a string used to format a date without the time. Aliased by `%x`.
const string DEFAULT_DATE_FORMAT = "%Y-%m-%d";

/// This is a string used to format a time without the date. Aliased by `%X`.
const string DEFAULT_TIME_FORMAT = "%H:%M:%S";

/// This is a string used to format a time using AM/PM. Aliased by `%r`.
const string DEFAULT_AMPM_FORMAT = "%I:%M:%S %p";

/// This is a string used to format a date and time when era-based formatting is
/// used. If "", will fall back to DEFAULT_DATETIME_FORMAT. Aliased by `%Ec`.
const string DEFAULT_ERA_DATETIME_FORMAT = "";

/// This is a string used to format a date without the time when era-based
/// formatting is used. If "", will fall back to DEFAULT_DATE_FORMAT. Aliased by
/// `%Ex`.
const string DEFAULT_ERA_DATE_FORMAT = "";

/// This is a string used to format a time without the date when era-based
/// formatting is used. If "", will fall back to DEFAULT_TIME_FORMAT. Aliased by
/// `%EX`.
const string DEFAULT_ERA_TIME_FORMAT = "";

/// This is a string used to format years when era-based formatting is used. If
/// "", will always use the current year. Aliased by `%EY`.
const string DEFAULT_ERA_YEAR_FORMAT = "%Ey %EC";

/// This is a string used to format the era name when era-based formatting is
/// used. Normally, each era has its own name, but setting this can allow you
/// to display an era name even if you don't set up any eras for your locale.
const string DEFAULT_ERA_NAME = "";
/// ----------------------------------------------------------------------------
/// @file   util_c_targeting.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration settings for util_i_targeting.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                          Targeting Mode Script Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to run scripts associated with targeting hooks.
/// @param sScript The script assigned to the current targeting hook.
/// @param oSelf The PC object assigned to the current targeting event.
void RunTargetingHookScript(string sScript, object oSelf = OBJECT_SELF)
{
    /* Use this function to implement your module's methodology for
        running scripts.

    ExecuteScript(sScript, oSelf);
    */
}
/// ----------------------------------------------------------------------------
/// @file   util_c_unittest.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_unittest.nss.
/// ----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                        Unit Test Configuration Settings
// -----------------------------------------------------------------------------

// Set this value to the color the test title text will be colored to. The value
//  can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:  Test My Variable Test
//                  ^^^^ This portion of the text will be affected
const int UNITTEST_TITLE_COLOR = COLOR_CYAN;

// Set this value to the color the test name text will be colored to. The value
//  can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:  Test My Variable Test | PASS
//                       ^^^^^^^^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_NAME_COLOR = COLOR_ORANGE_LIGHT;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:    Input: my_input
//                 Expected: my_assertion
//                 Received: my_output
//                 ^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_COLOR = COLOR_WHITE;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output:    Input: my_input
//                 Expected: my_assertion
//                           ^^^^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_INPUT = COLOR_GREEN_SEA;

// Set this value to the color the test parameter text will be colored to. The
//  value can be a value from util_c_color or any other hex value representing a
//  color.
// Example Output: Received: my_output
//                           ^^^^^^^^^ This portion of the text will be affected
const int UNITTEST_PARAMETER_RECEIVED = COLOR_PINK;

// Set this value to the name of the script or event to run in case of a unit
//  test failure.
const string UNITTEST_FAILURE_SCRIPT = "";

// This value determines whether test results are expanded.  Set to TRUE to force
//  all test results to show expanded data.  Set to FALSE to show expanded data
//  only on test failures.
const int UNITTEST_ALWAYS_EXPAND = FALSE;

// -----------------------------------------------------------------------------
//                        Helper Constants and Functions
// -----------------------------------------------------------------------------
// If you need custom constants, functions, or #includes, you may add them here.
// Since this file is included by util_i_unittest.nss, you do not need to
// #include it to use its constants.
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                           Unit Test Output Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to handle reporting unit test results.
/// @param sOutput The formatted and colored output results of a unit test.
void HandleUnitTestOutput(string sOutput)
{
    // This handler can be used to report the unit test output using any module
    //  debugging or other reporting system.
    /*
        SendMessageToPC(GetFirstPC(), sOutput);
    */

    Notice(sOutput);
}

// -----------------------------------------------------------------------------
//                      Unit Test Failure Reporting Handler
// -----------------------------------------------------------------------------
// You may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Custom handler to report unit testing failures.
/// @param sOutput The formatted and colored output results of a unit test.
void HandleUnitTestFailure(string sOutput)
{
    // This handler can be used to report unit test failures to module systems
    //  or take specific action based on a failure. This function will
    //  generally not be used in a test environment, but may be useful for
    //  reporting failures in a production environment if unit tests are run
    //  during module startup.

    if (UNITTEST_FAILURE_SCRIPT != "")
        ExecuteScript(UNITTEST_FAILURE_SCRIPT, GetModule());
}
/// ----------------------------------------------------------------------------
/// @file   util_c_variables.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Configuration file for util_i_variables.nss.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                Configuration
// -----------------------------------------------------------------------------

// This volatile table will be created on the GetModule() object the first time
// a module variable is set.
const string VARIABLE_TABLE_MODULE      = "module_variables";

// This persitent table will be created on the PC object the first time a player
// variable is set.  This table will be stored in the player's .bic file.
const string VARIABLE_TABLE_PC          = "player_variables";

// A persistent table will be created in a campaign database with the following
// name.  The table name will be VARIABLE_TABLE_MODULE above.
const string VARIABLE_CAMPAIGN_DATABASE = "module_variables";

// -----------------------------------------------------------------------------
//                            Local VarName Constructor
// -----------------------------------------------------------------------------
// This function is called when attempting to copy variables from a database
//  to a game object.  Since game objects do not accept additonal fields, such
//  as a tag or timestamp, this function is provided to allow construction of
//  a unique varname, if desired, from the fields in the database record.  You
//  may alter the contents of this function, but do not alter its signature.
// -----------------------------------------------------------------------------

/// @brief Constructs a varname for a local variable copied from a database.
/// @param oDatabase The database object the variable is sourced from.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param oTarget The game object the variable will be copied to.
/// @param sVarName VarName field retrieved from database.
/// @param sTag Tag field retrieved from database.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string DatabaseToObjectVarName(object oDatabase, object oTarget, string sVarName,
                               string sTag, int nType)
{
    return sVarName;
}

// -----------------------------------------------------------------------------
//                    Database VarName and Tag Constructors
// -----------------------------------------------------------------------------
// These functions are called when attempting to copy variables from a game
//  object to a database.  These functions are provided to allow construction
//  of unique varnames and tag from local variables varnames.  If the function
//  `DatabaseToObjectVarName()` above is used to copy database variables to a
//  local object, these functions can be used to reverse the process if
//  previously copied variables are returned to a database. You may alter the
//  contents of these functions, but do not alter their signatures.
// -----------------------------------------------------------------------------

/// @brief Constructs a varname for a local variable copied to a database.
/// @param oSource The game object the variable will be copied from.
/// @param oDatabase The database object the variable will be copied to.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param sVarName VarName field retrieved from the local variable.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @param sTag sTag as passed to `CopyLocalVariablesToDatabase()`.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string ObjectToDatabaseVarName(object oSource, object oDatabase, string sVarName,
                               int nType, string sTag)
{
    return sVarName;
}

/// @brief Constructs a varname for a local variable copied to a database.
/// @param oSource The game object the variable will be copied from.
/// @param oDatabase The database object the variable will be copied to.  Will
///     be either a player object, DB_MODULE or DM_CAMPAIGN.
/// @param sVarName VarName field retrieved from the local variable.
/// @param nType Type field retrieved from database.  VARIABLE_TYPE_*, but
///     limited to VARIABLE_TYPE_INT|FLOAT|STRING|OBJECT|LOCATION|JSON.
/// @param sTag sTag as passed to `CopyLocalVariablesToDatabase()`.
/// @returns The constructed string that will be used as the varname once
///     copied to the target game object.
string ObjectToDatabaseTag(object oSource, object oDatabase, string sVarName,
                           int nType, string sTag)
{
    return sTag;
}

/// ----------------------------------------------------------------------------
/// @file   util_i_argstack.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating an argument stack.
/// @details
/// An argument stack provides a method for library functions to send values
///     to other functions without being able to call them directly.  This allows
///     library functions to abstract away the connection layer and frees the
///     builder to design plug-and-play systems that don't break when unrelated
///     systems are removed or replaced.
///
/// Stacks work on a last in - first out basis and are split by variable type.
///     Popping a value will delete and return the last entered value of the
///     specified type stack.  Other variable types will not be affected.
///
/// ```nwscript
/// PushInt(30);
/// PushInt(40);
/// PushInt(50);
/// PushString("test");
///
/// int nPop = PopInt();       // nPop = 50
/// string sPop = PopString(); // sPop = "test";
/// ```nwscript
/// ----------------------------------------------------------------------------

#include "util_i_varlists"

const string ARGS_DEFAULT_STACK = "ARGS_DEFAULT_STACK";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Push as value onto the stack.
/// @param nValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
int PopInt(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
int PeekInt(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountIntStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param sValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
string PopString(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
string PeekString(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountStringStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param fValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
float PopFloat(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
float PeekFloat(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountFloatStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param oValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
object PopObject(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
object PeekObject(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountObjectStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param lValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.getlistfloat
/// @returns Count of values on the stack.
int PushLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
location PopLocation(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
location PeekLocation(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountLocationStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param vValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
vector PopVector(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
vector PeekVector(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountVectorStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Push as value onto the stack.
/// @param jValue Value to add to stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Count of values on the stack.
int PushJson(json jValue, string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Pop a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
json PopJson(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Peek a value from the stack.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns Most recent value pushed on the stack.
json PeekJson(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Retrieve the stack size.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @returns The number of values in the stack.
int CountJsonStack(string sListName = "", object oTarget = OBJECT_INVALID);

/// @brief Clear all stack values.
/// @param sListName [Optional] Name of stack.
/// @param oTarget [Optional] Object stack will be saved to.
/// @note Use this function to ensure all stack values are cleared.
void ClearStacks(string sListName = "", object oTarget = OBJECT_INVALID);

// -----------------------------------------------------------------------------
//                              Function Definitions
// -----------------------------------------------------------------------------

string _GetListName(string s)
{
    return s == "" ? ARGS_DEFAULT_STACK : s;
}

object _GetTarget(object o)
{
    if (o == OBJECT_INVALID || GetIsObjectValid(o) == FALSE)
        return GetModule();
    return o;
}

int PushInt(int nValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListInt(_GetTarget(oTarget), 0, nValue, _GetListName(sListName));
}

int PopInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListInt(_GetTarget(oTarget), _GetListName(sListName));
}

int PeekInt(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListInt(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountIntStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountIntList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushString(string sValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListString(_GetTarget(oTarget), 0, sValue, _GetListName(sListName));
}

string PopString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListString(_GetTarget(oTarget), _GetListName(sListName));
}

string PeekString(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListString(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountStringStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountStringList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushFloat(float fValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListFloat(_GetTarget(oTarget), 0, fValue, _GetListName(sListName), FALSE);
}

float PopFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListFloat(_GetTarget(oTarget), _GetListName(sListName));
}

float PeekFloat(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListFloat(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountFloatStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountFloatList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushObject(object oValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListObject(_GetTarget(oTarget), 0, oValue, _GetListName(sListName));
}

object PopObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListObject(_GetTarget(oTarget), _GetListName(sListName));
}

object PeekObject(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListObject(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountObjectStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountObjectList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushLocation(location lValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListLocation(_GetTarget(oTarget), 0, lValue, _GetListName(sListName));
}

location PopLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListLocation(_GetTarget(oTarget), _GetListName(sListName));
}

location PeekLocation(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListLocation(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountLocationStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountLocationList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushVector(vector vValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListVector(_GetTarget(oTarget), 0, vValue, _GetListName(sListName));
}

vector PopVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListVector(_GetTarget(oTarget), _GetListName(sListName));
}

vector PeekVector(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListVector(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountVectorStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountVectorList(_GetTarget(oTarget), _GetListName(sListName));
}

int PushJson(json jValue, string sListName = "", object oTarget = OBJECT_INVALID)
{
    return InsertListJson(_GetTarget(oTarget), 0, jValue, _GetListName(sListName));
}

json PopJson(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return PopListJson(_GetTarget(oTarget), _GetListName(sListName));
}

json PeekJson(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return GetListJson(_GetTarget(oTarget), 0, _GetListName(sListName));
}

int CountJsonStack(string sListName = "", object oTarget = OBJECT_INVALID)
{
    return CountJsonList(_GetTarget(oTarget), _GetListName(sListName));
}

void ClearStacks(string sListName = "", object oTarget = OBJECT_INVALID)
{
    sListName = _GetListName(sListName);
    oTarget = _GetTarget(oTarget);

    DeleteIntList(oTarget, sListName);
    DeleteStringList(oTarget, sListName);
    DeleteFloatList(oTarget, sListName);
    DeleteObjectList(oTarget, sListName);
    DeleteLocationList(oTarget, sListName);
    DeleteVectorList(oTarget, sListName);
    DeleteJsonList(oTarget, sListName);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_color.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions to handle colors.
/// @details
/// NWN normally uses color codes to color strings. These codes take the format
/// `<cRGB>`, where RGB are ALT codes (0-0255) for colors.
///
/// Because color codes are arcane and can't be easily looked up, the functions
/// in this file prefer to use hex color codes. These codes are the same as
/// you'd use in web design and many other areas, so they are easy to look up
/// and can be copied and pasted into other programs. util_c_color.nss provides
/// some hex codes for common uses.
///
/// This file also contains functions to represent colors as RGB or HSV
/// triplets. HSV (Hue, Saturation, Value) may be particularly useful if you
/// want to play around with shifting colors.
///
/// ## Acknowledgements
/// - `GetColorCode()` function by rdjparadis.
/// - RGB <-> HSV colors adapted from NWShacker's Named Color Token System.
/// ----------------------------------------------------------------------------

#include "x3_inc_string"
#include "util_i_math"
#include "util_c_color"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

/// Used to generate colors from RGB values. NEVER modify this string.
/// @see https://nwn.wiki/display/NWN1/Colour+Tokens
/// @note First character is "nearest to 00" since we can't use `\x00` itself
/// @note COLOR_TOKEN originally by rdjparadis. Converted to NWN:EE escaped
///     characters by Jasperre.
const string COLOR_TOKEN = "\x01\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F\x20\x21\x22\x23\x24\x25\x26\x27\x28\x29\x2A\x2B\x2C\x2D\x2E\x2F\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x3A\x3B\x3C\x3D\x3E\x3F\x40\x41\x42\x43\x44\x45\x46\x47\x48\x49\x4A\x4B\x4C\x4D\x4E\x4F\x50\x51\x52\x53\x54\x55\x56\x57\x58\x59\x5A\x5B\x5C\x5D\x5E\x5F\x60\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6A\x6B\x6C\x6D\x6E\x6F\x70\x71\x72\x73\x74\x75\x76\x77\x78\x79\x7A\x7B\x7C\x7D\x7E\x7F\x80\x81\x82\x83\x84\x85\x86\x87\x88\x89\x8A\x8B\x8C\x8D\x8E\x8F\x90\x91\x92\x93\x94\x95\x96\x97\x98\x99\x9A\x9B\x9C\x9D\x9E\x9F\xA0\xA1\xA2\xA3\xA4\xA5\xA6\xA7\xA8\xA9\xAA\xAB\xAC\xAD\xAE\xAF\xB0\xB1\xB2\xB3\xB4\xB5\xB6\xB7\xB8\xB9\xBA\xBB\xBC\xBD\xBE\xBF\xC0\xC1\xC2\xC3\xC4\xC5\xC6\xC7\xC8\xC9\xCA\xCB\xCC\xCD\xCE\xCF\xD0\xD1\xD2\xD3\xD4\xD5\xD6\xD7\xD8\xD9\xDA\xDB\xDC\xDD\xDE\xDF\xE0\xE1\xE2\xE3\xE4\xE5\xE6\xE7\xE8\xE9\xEA\xEB\xEC\xED\xEE\xEF\xF0\xF1\xF2\xF3\xF4\xF5\xF6\xF7\xF8\xF9\xFA\xFB\xFC\xFD\xFE\xFF";

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

struct RGB
{
    int r;
    int g;
    int b;
};

struct HSV
{
    float h;
    float s;
    float v;
};

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Type Creation ---------------------------------------------------------

/// @brief Create an RBG color struct.
/// @param nRed The value of the red channel (0..255).
/// @param nGreen The value of the green channel (0..255).
/// @param nBlue The value of the blue channel (0..255).
struct RGB GetRGB(int nRed, int nGreen, int nBlue);

/// @brief Create an HSV color struct.
/// @details The ranges are as follows:
///     0.0 <= H < 360.0
///     0.0 <= S <= 1.0
///     0.0 <= V <= 1.0
/// @param fHue The hue (i.e. location on color wheel).
/// @param fSaturation The saturation (i.e., distance from white/black).
/// @param fValue The value (i.e., brightness of color).
struct HSV GetHSV(float fHue, float fSaturation, float fValue);

// ----- Type Conversion -------------------------------------------------------

/// @brief Convert a hexadecimal color to an RGB struct.
/// @param nColor Hexadecimal to convert to RGB.
struct RGB HexToRGB(int nColor);

/// @brief Convert an RGB struct to a hexadecimal color.
/// @param rgb RGB to convert to hexadecimal.
int RGBToHex(struct RGB rgb);

/// @brief Convert an RGB struct to an HSV struct.
/// @param rgb RGB to convert to HSV.
struct HSV RGBToHSV(struct RGB rgb);

/// @brief Convert an HSV struct to an RGB struct.
/// @param hsv HSV to convert to RGB.
struct RGB HSVToRGB(struct HSV hsv);

/// @brief Converts a hexadecimal color to an HSV struct.
/// @param nColor Hexadecimal to convert to HSV.
struct HSV HexToHSV(int nColor);

/// @brief Converts an HSV struct to a hexadecial color.
/// @param hsv HSV to convert to hexadecimal.
int HSVToHex(struct HSV hsv);

// ----- Coloring Functions ----------------------------------------------------

/// @brief Construct a color code that can be used to color a string.
/// @param nRed The intensity of the red channel (0..255).
/// @param nGreen The intensity of the green channel (0..255).
/// @param nBlue The intensity of the blue channel (0..255).
/// @returns A string color code in `<cRBG>` form.
string GetColorCode(int nRed, int nGreen, int nBlue);

/// @brief Convert a hexadecimal color to a color code.
/// @param nColor Hexadecimal representation of an RGB color.
/// @returns A string color code in `<cRBG>` form.
string HexToColor(int nColor);

/// @brief Convert a color code prefix to a hexadecimal
/// @param sColor A string color code in `<cRBG>` form.
int ColorToHex(string sColor);

/// @brief Color a string with a color code.
/// @param sString The string to color.
/// @param sColor A string color code in `<cRBG>` form.
string ColorString(string sString, string sColor);

/// @brief Color a string with a hexadecimal color.
/// @param sString The string to color.
/// @param nColor A hexadecimal color.
string HexColorString(string sString, int nColor);

/// @brief Color a string with an RGB color.
/// @param sString The string to color.
/// @param rgb The RGB color struct.
string RGBColorString(string sString, struct RGB rgb);

/// @brief Color a string with a struct HSV color
/// @param sString The string to color.
/// @param hsv The HSV color struct.
string HSVColorString(string sString, struct HSV hsv);

/// @brief Remove color codes from a string.
/// @param sString The string to uncolor.
/// @returns sString with color codes removed.
string UnColorString(string sString);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Type Creation ---------------------------------------------------------

struct RGB GetRGB(int nRed, int nGreen, int nBlue)
{
    struct RGB rgb;

    rgb.r = clamp(nRed,   0, 255);
    rgb.g = clamp(nGreen, 0, 255);
    rgb.b = clamp(nBlue,  0, 255);

    return rgb;
}

struct HSV GetHSV(float fHue, float fSat, float fVal)
{
    struct HSV hsv;

    hsv.h = fclamp(fHue, 0.0, 360.0);
    hsv.s = fclamp(fSat, 0.0,   1.0);
    hsv.v = fclamp(fVal, 0.0,   1.0);

    if (hsv.h == 360.0)
        hsv.h = 0.0;

    return hsv;
}

// ----- Type Conversion -------------------------------------------------------

struct RGB HexToRGB(int nColor)
{
    int nRed   = (nColor & 0xff0000) >> 16;
    int nGreen = (nColor & 0x00ff00) >> 8;
    int nBlue  = (nColor & 0x0000ff);
    return GetRGB(nRed, nGreen, nBlue);
}

int RGBToHex(struct RGB rgb)
{
    int nRed   = (clamp(rgb.r, 0, 255) << 16);
    int nGreen = (clamp(rgb.g, 0, 255) << 8);
    int nBlue  =  clamp(rgb.b, 0, 255);
    return nRed + nGreen + nBlue;
}

struct HSV RGBToHSV(struct RGB rgb)
{
    // Ensure the RGB values are within defined limits
    rgb = GetRGB(rgb.r, rgb.g, rgb.b);

    struct HSV hsv;

    // Convert RGB to a range from 0 - 1
    float fRed   = IntToFloat(rgb.r) / 255.0;
    float fGreen = IntToFloat(rgb.g) / 255.0;
    float fBlue  = IntToFloat(rgb.b) / 255.0;

    float fMax = fmax(fRed, fmax(fGreen, fBlue));
    float fMin = fmin(fRed, fmin(fGreen, fBlue));
    float fChroma = fMax - fMin;

    if (fMax > fMin)
    {
        if (fMax == fRed)
            hsv.h = 60.0 * ((fGreen - fBlue) / fChroma);
        else if (fMax == fGreen)
            hsv.h = 60.0 * ((fBlue - fRed) / fChroma + 2.0);
        else
            hsv.h = 60.0 * ((fRed - fGreen) / fChroma + 4.0);

        if (hsv.h < 0.0)
            hsv.h += 360.0;
    }

    if (fMax > 0.0)
        hsv.s = fChroma / fMax;

    hsv.v = fMax;
    return hsv;
}

struct RGB HSVToRGB(struct HSV hsv)
{
    // Ensure the HSV values are within defined limits
    hsv = GetHSV(hsv.h, hsv.s, hsv.v);

    struct RGB rgb;

    // If value is 0, the resulting color will always be black
    if (hsv.v == 0.0)
        return rgb;

    // If the saturation is 0, the resulting color will be a shade of grey
    if (hsv.s == 0.0)
    {
        // Scale from white to black based on value
        int nValue = FloatToInt(hsv.v * 255.0);
        return GetRGB(nValue, nValue, nValue);
    }

    float h = hsv.h / 60.0;
    float f = frac(h);
    int v = FloatToInt(hsv.v * 255.0);
    int p = FloatToInt(v * (1.0 - hsv.s));
    int q = FloatToInt(v * (1.0 - hsv.s * f));
    int t = FloatToInt(v * (1.0 - hsv.s * (1.0 - f)));
    int i = FloatToInt(h);

    switch (i % 6)
    {
        case 0: rgb = GetRGB(v, t, p); break;
        case 1: rgb = GetRGB(q, v, p); break;
        case 2: rgb = GetRGB(p, v, t); break;
        case 3: rgb = GetRGB(p, q, v); break;
        case 4: rgb = GetRGB(t, p, v); break;
        case 5: rgb = GetRGB(v, p, q); break;
    }

    return rgb;
}

struct HSV HexToHSV(int nColor)
{
    return RGBToHSV(HexToRGB(nColor));
}

int HSVToHex(struct HSV hsv)
{
    return RGBToHex(HSVToRGB(hsv));
}

// ----- Coloring Functions ----------------------------------------------------

string GetColorCode(int nRed, int nGreen, int nBlue)
{
    return "<c" + GetSubString(COLOR_TOKEN, nRed,   1) +
                  GetSubString(COLOR_TOKEN, nGreen, 1) +
                  GetSubString(COLOR_TOKEN, nBlue,  1) + ">";
}

string HexToColor(int nColor)
{
    if (nColor < 0 || nColor > 0xffffff)
        return "";

    int nRed   = (nColor & 0xff0000) >> 16;
    int nGreen = (nColor & 0x00ff00) >> 8;
    int nBlue  = (nColor & 0x0000ff);
    return GetColorCode(nRed, nGreen, nBlue);
}

int ColorToHex(string sColor)
{
    if (sColor == "")
        return -1;

    string sRed   = GetSubString(sColor, 2, 1);
    string sGreen = GetSubString(sColor, 3, 1);
    string sBlue  = GetSubString(sColor, 4, 1);

    int nRed   = FindSubString(COLOR_TOKEN, sRed) << 16;
    int nGreen = FindSubString(COLOR_TOKEN, sGreen) << 8;
    int nBlue  = FindSubString(COLOR_TOKEN, sBlue);

    return nRed + nGreen + nBlue;
}

string ColorString(string sString, string sColor)
{
    if (sColor != "")
        sString = sColor + sString + "</c>";

    return sString;
}

string HexColorString(string sString, int nColor)
{
    string sColor = HexToColor(nColor);
    return ColorString(sString, sColor);
}

string RGBColorString(string sString, struct RGB rgb)
{
    string sColor = GetColorCode(rgb.r, rgb.g, rgb.b);
    return ColorString(sString, sColor);
}

string HSVColorString(string sString, struct HSV hsv)
{
    struct RGB rgb = HSVToRGB(hsv);
    return RGBColorString(sString, rgb);
}

string UnColorString(string sString)
{
    return RegExpReplace("<c[\\S\\s]{3}>|<\\/c>", sString, "");
}
/// ----------------------------------------------------------------------------
/// @file   util_i_constants.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions to retrieve the value of a constant from a script file.
/// @details
///
/// ## Example Usage
///
/// To retrieve the value of string constant `MODULE_EVENT_ON_NUI` from the Core
/// Framework file `core_i_constants`:
/// ```nwscript
/// struct CONSTANT c = GetConstantString("MODULE_EVENT_ON_NUI", "core_i_constants");
/// string sSetting = c.sValue;
/// ```
/// If successful, `sSetting` will contain the string value "OnNUI". If not
/// successful, `c.bError` will be TRUE, `c.sError` will contain the reason for
/// the error, and `c.sValue` will be set to an empty string ("").
///
/// To retrieve the value of integer constant `EVENT_STATE_OK`from the Core
/// Framework file `core_i_constants`:
/// ```nwscript
/// struct CONSTANT c = GetConstantInt("EVENT_STATE_OK", "core_i_constants");
/// int nState = c.bError ? -1 : c.nValue;
///
/// // or...
/// if (!c.bError)
/// {
///     int nState = c.nValue;
///     ...
/// }
/// ```
/// If successful, `nState` will contain the integer value 0. Since an error
/// value will also return 0, scripts should check `[struct].bError` before
/// using any constant that could return 0 as a valid value.
///
/// @note These functions require uncompiled `.nss` files, otherwise only base
///     nwscript constants will be retrievable. If you use a tool such as nasher
///     to build your module, ensure you do not filter out the `.nss` files when
///     building.
///
/// @note Based on clippy's code at
///     https://github.com/Finaldeath/nwscript_utility_scripts
/// ----------------------------------------------------------------------------

#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string CONSTANTS_RESULT                   = "CONSTANTS_RESULT";
const string CONSTANTS_ERROR_FILE_NOT_FOUND     = "FILE NOT FOUND";
const string CONSTANTS_ERROR_CONSTANT_NOT_FOUND = "VARIABLE DEFINED WITHOUT TYPE";

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

struct CONSTANT
{
    int    bError;
    string sError;

    string sValue;
    int    nValue;
    float  fValue;

    string sFile;
    string sConstant;
};

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Retrieves a constant string value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     sValue - The value of the constant retrieved, if successful, or ""
struct CONSTANT GetConstantString(string sConstant, string sFile = "");

/// @brief Retrieves a constant integer value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     nValue - The value of the constant retrieved, if successful, or 0
struct CONSTANT GetConstantInt(string sConstant, string sFile = "");

/// @brief Retrieves a constant float value from a script file
/// @param sConstant Name of the constant, must match case
/// @param sFile Optional: file to retrieve value from; if omitted, nwscript
///     is assumed
/// @returns a CONSTANT structure containing the following:
///     bError - TRUE if the constant could not be found
///     sError - The reason for the error, if any
///     fValue - The value of the constant retrieved, if successful, or 0.0
struct CONSTANT GetConstantFloat(string sConstant, string sFile = "");

/// @brief Find an constant name given the constant value.
/// @param sPrefix The prefix portion of the constant name being sought.
/// @param jValue The value of the sPrefix_* constant being sought.  This must be
///     a json value to simplify argument passage.  Create via a Json* function,
///     such as JsonInt(n), JsonString(s) or JsonFloat(f).
/// @param bSuffixOnly If TRUE, will only return the portion of the constant name
///     found after sPrefix, not including an intervening underscore.
/// @param sFile If passed, sFile will be searched for the appropriate constant name.
///     If not passed, `nwscript.nss` will be searched.
/// @note Does not work with nwscript TRUE/FALSE.  Floats that are affected by
///     floating point error, such as 1.67, will also fail to find the correct
///     constant name. Floats that end in .0, such as for DIRECTION_, work correctly.
/// @warning This function is primarily designed for debugging messages.  Using it
///     regularly can result in degraded performance.
string GetConstantName(string sPrefix, json jValue, int bSuffixOnly = FALSE, string sFile = "");

// -----------------------------------------------------------------------------
//                               Private Functions
// -----------------------------------------------------------------------------

// Attempts to retrieve the value of sConstant from sFile.  If found, the
// appropriate fields in struct CONSTANT are populated.  If not, [struct].bError is
// set to TRUE and the reason for failure is populated into [struct].sError.  If the
// error cannot be determined, the error returned by ExecuteScriptChunk is
// populated directly into [struct].sError.
struct CONSTANT constants_RetrieveConstant(string sConstant, string sFile, string sType)
{
    int COLOR_KEY = COLOR_BLUE_LIGHT;
    int COLOR_VALUE = COLOR_SALMON;
    int COLOR_FAILED = COLOR_MESSAGE_FEEDBACK;

    struct CONSTANT c;
    string sError, sChunk = "SetLocal" + sType + "(GetModule(), \"" +
        CONSTANTS_RESULT + "\", " + sConstant + ");";

    c.sConstant = sConstant;
    c.sFile = sFile == "" ? "nwscript" : sFile;

    if (sFile != "")
        sChunk = "#include \"" + sFile + "\" void main() {" + sChunk + "}";

    if ((sError = ExecuteScriptChunk(sChunk, GetModule(), sFile == "")) != "")
    {
        c.bError = TRUE;

        if (FindSubString(sError, CONSTANTS_ERROR_FILE_NOT_FOUND) != -1)
            c.sError = "Unable to find file `" + c.sFile + ".nss`";
        else if (FindSubString(sError, CONSTANTS_ERROR_CONSTANT_NOT_FOUND) != -1)
            c.sError = "Constant `" + c.sConstant + "` not found in `" + c.sFile + ".nss`";
        else
            c.sError = sError;

        string sMessage = "[CONSTANTS] " + HexColorString("Failed", COLOR_FAILED) + " to retrieve constant value" +
            "\n   " + HexColorString("sConstant", COLOR_KEY) + "  " + HexColorString(sConstant, COLOR_VALUE) +
            "\n   " + HexColorString("sFile",     COLOR_KEY) + "  " + HexColorString(c.sFile,   COLOR_VALUE) +
            "\n   " + HexColorString("Reason",    COLOR_KEY) + "  " + HexColorString(c.sError,  COLOR_VALUE);
        Warning(sMessage);
    }

    return c;
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

struct CONSTANT GetConstantString(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "String");
    if (!c.bError)
        c.sValue = GetLocalString(GetModule(), CONSTANTS_RESULT);

    return c;
}

struct CONSTANT GetConstantInt(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "Int");
    if (!c.bError)
        c.nValue = GetLocalInt(GetModule(), CONSTANTS_RESULT);

    return c;
}

struct CONSTANT GetConstantFloat(string sConstant, string sFile = "")
{
    struct CONSTANT c = constants_RetrieveConstant(sConstant, sFile, "Float");
    if (!c.bError)
        c.fValue = GetLocalFloat(GetModule(), CONSTANTS_RESULT);

    return c;
}

string GetConstantName(string sPrefix, json jValue, int bSuffixOnly = FALSE, string sFile = "")
{
    if (sFile == "") sFile = "nwscript";

    sPrefix = GetStringUpperCase(bSuffixOnly ? sPrefix + "_?(" : "(" + sPrefix);
    json jMatch = RegExpMatch(sPrefix + ".*?)(?: |=).*?=\\s*(" +
        JsonDump(jValue) + ")\\s*;", ResManGetFileContents(sFile, RESTYPE_NSS));

    return jMatch != JsonArray() ? JsonGetString(JsonArrayGet(jMatch, 1)) : "";
}
/// ----------------------------------------------------------------------------
/// @file   util_i_csvlists.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating comma-separated value (CSV) lists.
/// @details
///
/// ## Usage:
///
/// ```nwscript
/// string sKnight, sKnights = "Lancelot, Galahad, Robin";
/// int i, nCount = CountList(sKnights);
/// for (i = 0; i < nCount; i++)
/// {
///     sKnight = GetListItem(sKnights, i);
///     SpeakString("Sir " + sKnight);
/// }
///
/// int bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// sKnights = AddListItem(sKnights, "Bedivere");
/// bBedivere = HasListItem(sKnights, "Bedivere");
/// SpeakString("Bedivere " + (bBedivere ? "is" : "is not") + " in the party.");
///
/// int nRobin = FindListItem(sKnights, "Robin");
/// SpeakString("Robin is knight " + IntToString(nRobin) + " in the party.");
/// ```
/// ----------------------------------------------------------------------------

#include "x3_inc_string"
#include "util_i_math"
#include "util_i_strings"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Trim excess space around commas and, optionally, remove excess commas/
///     empty list items.
/// @param sList The CSV list to normalize.
/// @param bRemoveEmpty TRUE to remove empty items.
string NormalizeList(string sList, int bRemoveEmpty = TRUE);

/// @brief Return the number of items in a CSV list.
/// @param sList The CSV list to count.
int CountList(string sList);

/// @brief Add an item to a CSV list.
/// @param sList The CSV list to add the item to.
/// @param sListItem The item to add to sList.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with sListItem added.
string AddListItem(string sList, string sListItem, int bAddUnique = FALSE);

/// @brief Insert an item into a CSV list.
/// @param sList The CSV list to insert the item into.
/// @param sListItem The item to insert into sList.
/// @param nIndex The index of the item to insert (0-based).
/// @param bAddUnique If TRUE, will only insert the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with sListItem inserted.
string InsertListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE);

/// @brief Modify an existing item in a CSV list.
/// @param sList The CSV list to modify.
/// @param sListItem The item to insert at nIndex.
/// @param nIndex The index of the item to modify (0-based).
/// @param bAddUnique If TRUE, will only modify the item to the list if it is not
///     already there.
/// @returns A modified copy of sList with item at nIndex modified.
/// @note If nIndex is out of bounds for sList, no values will be modified.
/// @warning If bAddUnique is TRUE and a non-unique value is set, the value with a lower
///     list index will be kept and values with higher list indices removed.
string SetListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE);

/// @brief Return the item at an index in a CSV list.
/// @param sList The CSV list to get the item from.
/// @param nIndex The index of the item to get (0-based).
string GetListItem(string sList, int nIndex = 0);

/// @brief Return the index of a value in a CSV list.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @param nNth The nth repetition of sListItem.
/// @returns -1 if the item was not found in the list.
int FindListItem(string sList, string sListItem, int nNth = 0);

/// @brief Return whether a CSV list contains a value.
/// @param sList The CSV list to search.
/// @param sListItem The value to search for.
/// @returns TRUE if the item is in the list, otherwise FALSE.
int HasListItem(string sList, string sListItem);

/// @brief Delete the item at an index in a CSV list.
/// @param sList The CSV list to delete the item from.
/// @param nIndex The index of the item to delete (0-based).
/// @returns A modified copy of sList with the item deleted.
string DeleteListItem(string sList, int nIndex = 0);

/// @brief Delete the first occurrence of an item in a CSV list.
/// @param sList The CSV list to remove the item from.
/// @param sListItem The value to remove from the list.
/// @param nNth The nth repetition of sListItem.
/// @returns A modified copy of sList with the item removed.
string RemoveListItem(string sList, string sListItem, int nNth = 0);

/// @brief Copy items from one CSV list to another.
/// @param sSource The CSV list to copy items from.
/// @param sTarget The CSV list to copy items to.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of items to copy.
/// @param bAddUnique If TRUE, will only copy items to sTarget if they are not
///     already there.
/// @returns A modified copy of sTarget with the items added to the end.
string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Merge the contents of two CSV lists.
/// @param sList1 The first CSV list.
/// @param sList2 The second CSV list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns A CSV list containing the items from each list.
string MergeLists(string sList1, string sList2, int bAddUnique = FALSE);

/// @brief Add an item to a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The item to add to the list.
/// @param bAddUnique If TRUE, will only add the item to the list if it is not
///     already there.
/// @returns The updated copy of the list with sListItem added.
string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE);

/// @brief Delete an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param nIndex The index of the item to delete (0-based).
/// @returns The updated copy of the list with the item at nIndex deleted.
string DeleteLocalListItem(object oObject, string sListName, int nIndex = 0);

/// @brief Remove an item in a CSV list saved as a local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListItem The value to remove from the list.
/// @param nNth The nth repetition of sListItem.
/// @returns The updated copy of the list with the first instance of sListItem
///     removed.
string RemoveLocalListItem(object oObject, string sListName, string sListItem, int nNth = 0);

/// @brief Merge the contents of a CSV list with those of a CSV list stored as a
///     local variable on an object.
/// @param oObject The object on which the local variable is saved.
/// @param sListName The varname for the local variable.
/// @param sListToMerge The CSV list to merge into the saved list.
/// @param bAddUnique If TRUE, will only put items in the returned list if they
///     are not already there.
/// @returns The updated copy of the list with all items from sListToMerge
///     added.
string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE);

/// @brief Convert a comma-separated value list to a JSON array.
/// @param sList Source CSV list.
/// @param bNormalize TRUE to remove excess spaces and values.  See NormalizeList().
/// @returns JSON array representation of CSV list.
json ListToJson(string sList, int bNormalize = TRUE);

/// @brief Convert a JSON array to a comma-separate value list.
/// @param jList JSON array list.
/// @param bNormalize TRUE to remove excess spaces and values.  See NormalizeList().
/// @returns CSV list of JSON array values.
string JsonToList(json jList, int bNormalize = TRUE);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

string NormalizeList(string sList, int bRemoveEmpty = TRUE)
{
    string sRegex = "(?:[\\s]*,[\\s]*)" + (bRemoveEmpty ? "+" : "");
    sList = RegExpReplace(sRegex, sList, ",");
    return TrimString(bRemoveEmpty ? RegExpReplace("^[\\s]*,|,[\\s]*$", sList, "") : sList);
}

int CountList(string sList)
{
    if (sList == "")
        return 0;

    return GetSubStringCount(sList, ",") + 1;
}

string AddListItem(string sList, string sListItem, int bAddUnique = FALSE)
{
    sList = NormalizeList(sList);
    sListItem = TrimString(sListItem);

    if (bAddUnique && HasListItem(sList, sListItem))
        return sList;

    if (sList != "")
        return sList + "," + sListItem;

    return sListItem;
}

string InsertListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE)
{
    if (nIndex == -1 || sList == "" || nIndex > CountList(sList) - 1)
        return AddListItem(sList, sListItem, bAddUnique);

    if (nIndex < 0) nIndex = 0;
    json jList = JsonArrayInsert(ListToJson(sList), JsonString(sListItem), nIndex);

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);
    
    return JsonToList(jList);
}

string SetListItem(string sList, string sListItem, int nIndex = -1, int bAddUnique = FALSE)
{
    if (nIndex < 0 || nIndex > (CountList(sList) - 1))
        return sList;

    json jList = JsonArraySet(ListToJson(sList), nIndex, JsonString(sListItem));

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);
    
    return JsonToList(jList);
}

string GetListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "" || nIndex > (CountList(sList) - 1))
        return "";

    return JsonGetString(JsonArrayGet(ListToJson(sList), nIndex));
}

int FindListItem(string sList, string sListItem, int nNth = 0)
{
    json jIndex = JsonFind(ListToJson(sList), JsonString(TrimString(sListItem)), nNth);
    return jIndex == JSON_NULL ? -1 : JsonGetInt(jIndex);
}

int HasListItem(string sList, string sListItem)
{
    return (FindListItem(sList, sListItem) > -1);
}

string DeleteListItem(string sList, int nIndex = 0)
{
    if (nIndex < 0 || sList == "" || nIndex > (CountList(sList) - 1))
        return sList;

    return JsonToList(JsonArrayDel(ListToJson(sList), nIndex));
}

string RemoveListItem(string sList, string sListItem, int nNth = 0)
{
    return DeleteListItem(sList, FindListItem(sList, sListItem, nNth));
}

string CopyListItem(string sSource, string sTarget, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    int i, nCount = CountList(sSource);

    if (nIndex < 0 || nIndex >= nCount || !nCount)
        return sSource;

    nRange = clamp(nRange, 1, nCount - nIndex);

    for (i = 0; i < nRange; i++)
        sTarget = AddListItem(sTarget, GetListItem(sSource, nIndex + i), bAddUnique);

    return sTarget;
}

string MergeLists(string sList1, string sList2, int bAddUnique = FALSE)
{
    if (sList1 != "" && sList2 == "")
        return sList1;
    else if (sList1 == "" && sList2 != "")
        return sList2;
    else if (sList1 == "" && sList2 == "")
        return "";

    string sList = sList1 + "," + sList2;

    if (bAddUnique)
        sList = JsonToList(JsonArrayTransform(ListToJson(sList), JSON_ARRAY_UNIQUE));

    return bAddUnique ? sList : NormalizeList(sList);
}

string AddLocalListItem(object oObject, string sListName, string sListItem, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = AddListItem(sList, sListItem, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string DeleteLocalListItem(object oObject, string sListName, int nIndex = 0)
{
    string sList = GetLocalString(oObject, sListName);
    sList = DeleteListItem(sList, nIndex);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string RemoveLocalListItem(object oObject, string sListName, string sListItem, int nNth = 0)
{
    string sList = GetLocalString(oObject, sListName);
    sList = RemoveListItem(sList, sListItem, nNth);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

string MergeLocalList(object oObject, string sListName, string sListToMerge, int bAddUnique = FALSE)
{
    string sList = GetLocalString(oObject, sListName);
    sList = MergeLists(sList, sListToMerge, bAddUnique);
    SetLocalString(oObject, sListName, sList);
    return sList;
}

json ListToJson(string sList, int bNormalize = TRUE)
{
    if (sList == "")
        return JSON_ARRAY;

    if (bNormalize)
        sList = NormalizeList(sList);
    
    sList = RegExpReplace("\"", sList, "\\\"");
    return JsonParse("[\"" + RegExpReplace(",", sList, "\",\"") + "\"]");
}

string JsonToList(json jList, int bNormalize = TRUE)
{
    if (JsonGetType(jList) != JSON_TYPE_ARRAY)
        return "";

    string sList;
    int n; for (n; n < JsonGetLength(jList); n++)
        sList += (sList == "" ? "" : ",") + JsonGetString(JsonArrayGet(jList, n));

    return bNormalize ? NormalizeList(sList) : sList;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_datapoint.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for creating and interacting with datapoints, which are
///     invisible objects used to hold variables specific to a system.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string DATA_PREFIX = "Datapoint: ";
const string DATA_POINT  = "x1_hen_inv";       ///< Resref for data points
const string DATA_ITEM   = "nw_it_msmlmisc22"; ///< Resref for data items

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a datapoint (placeable) that stores variables for a
///     specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     defaults to GetModule();
/// @note A datapoint is created at oOwner's location; if oOwner is invalid or
///     is an area object, the datapoint is created at the module starting
///     location.
/// @returns sSystem's datapoint object
object CreateDatapoint(string sSystem, object oOwner = OBJECT_INVALID);

/// @brief Retrieves a datapoint (placeable) that stores variables for a
///     specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     defaults to GetModule()
/// @param bCreate If TRUE and the datapoint cannot be found, a new datapoint
///     will be created at oOwner's location; if oOwner is invalid or is an
///     area object, the datapoint is created at the module starting location
/// @returns sSystem's datapoint object
object GetDatapoint(string sSystem, object oOwner = OBJECT_INVALID, int bCreate = TRUE);

/// @brief Sets a datapoint (game object) as the object that stores variables
///     for a specified system
/// @param sSystem Name of system associated with this datapoint
/// @param oTarget Object to be used as a datapoint
/// @param oOwner (optional) Parent object of this datapoint; if omitted,
///     default to GetModule()
/// @note Allows any valid game object to be used as a datapoint
void SetDatapoint(string sSystem, object oTarget, object oOwner = OBJECT_INVALID);

/// @brief Creates a data item (item) that stores variables for a specified
///     sub-system
/// @param oDatapoint Datapoint object on which to place the data item
/// @param sSubSystem Name of sub-system associated with this data item
/// @returns sSubSystem's data item object
object CreateDataItem(object oDatapoint, string sSubSystem);

/// @brief Retrieves a data item (item) that stores variables for a specified
///     sub-system
/// @param oDatapoint Datapoint object from which to retrieve the data item
/// @param sSubSystem Name of sub-system associated with the data item
/// @returns sSubSystem's data item object
object GetDataItem(object oDatapoint, string sSubSystem);

/// @brief Sets a data item (item) as the object that stores variables for a
///     specified sub-system
/// @param oDatapoint Datapoint object on which to place the data item
/// @param sSubSystem Name of sub-system assocaited with the data item
/// @param oItem Item to be used as a data item
/// @note oItem must a valid game item that can be placed into an object's
///     inventory
void SetDataItem(object oDatapoint, string sSubSystem, object oItem);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

object CreateDatapoint(string sSystem, object oOwner = OBJECT_INVALID)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    location lLoc = GetLocation(oOwner);
    if (!GetObjectType(oOwner))
        lLoc = GetStartingLocation();

    object oData = CreateObject(OBJECT_TYPE_PLACEABLE, DATA_POINT, lLoc);
    SetName(oData, DATA_PREFIX + sSystem);
    SetUseableFlag(oData, FALSE);
    SetDatapoint(sSystem, oData, oOwner);
    return oData;
}

object GetDatapoint(string sSystem, object oOwner = OBJECT_INVALID, int bCreate = TRUE)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    object oData = GetLocalObject(oOwner, DATA_PREFIX + sSystem);

    if (!GetIsObjectValid(oData) && bCreate)
        oData = CreateDatapoint(sSystem, oOwner);

    return oData;
}

void SetDatapoint(string sSystem, object oTarget, object oOwner = OBJECT_INVALID)
{
    if (oOwner == OBJECT_INVALID)
        oOwner = GetModule();

    SetLocalObject(oOwner, DATA_PREFIX + sSystem, oTarget);
}

object CreateDataItem(object oDatapoint, string sSubSystem)
{
    object oItem = CreateItemOnObject(DATA_ITEM, oDatapoint);
    SetLocalObject(oDatapoint, sSubSystem, oItem);
    SetName(oItem, sSubSystem);
    return oItem;
}

object GetDataItem(object oDatapoint, string sSubSystem)
{
    return GetLocalObject(oDatapoint, sSubSystem);
}

void SetDataItem(object oDatapoint, string sSubSystem, object oItem)
{
    SetLocalObject(oDatapoint, sSubSystem, oItem);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_debug.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for generating debug messages.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarNames
const string DEBUG_COLOR    = "DEBUG_COLOR";
const string DEBUG_LEVEL    = "DEBUG_LEVEL";
const string DEBUG_LOG      = "DEBUG_LOG";
const string DEBUG_OVERRIDE = "DEBUG_OVERRIDE";
const string DEBUG_PREFIX   = "DEBUG_PREFIX";
const string DEBUG_DISPATCH = "DEBUG_DISPATCH";

// Debug levels
const int DEBUG_LEVEL_NONE     = 0; ///< No debug level set
const int DEBUG_LEVEL_CRITICAL = 1; ///< Errors severe enough to stop the script
const int DEBUG_LEVEL_ERROR    = 2; ///< Indicates the script malfunctioned in some way
const int DEBUG_LEVEL_WARNING  = 3; ///< Indicates that unexpected behavior may occur
const int DEBUG_LEVEL_NOTICE   = 4; ///< Information to track the flow of the function
const int DEBUG_LEVEL_DEBUG    = 5; ///< Data dumps used for debugging

// Debug logging
const int DEBUG_LOG_NONE = 0x0; ///< Do not log debug messages
const int DEBUG_LOG_FILE = 0x1; ///< Send debug messages to the log file
const int DEBUG_LOG_DM   = 0x2; ///< Send debug messages to online DMs
const int DEBUG_LOG_PC   = 0x4; ///< Send debug messages to the first PC
const int DEBUG_LOG_LIST = 0x8; ///< Send debug messages to the dispatch list
const int DEBUG_LOG_ALL  = 0xf; ///< Send messages to the log file, DMs, and first PC or dispatch list

#include "util_c_debug"
#include "util_i_color"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Temporarily override the debug level for all objects.
/// @param nLevel The maximum verbosity of messages to show. Use FALSE to stop
///     overriding the debug level.
void OverrideDebugLevel(int nLevel);

/// @brief Return the verbosity of debug messages displayed for an object.
/// @param oTarget The object to check the debug level of. If no debug level has
///     been set on oTarget, will use the module instead.
/// @returns A `DEBUG_LEVEL_*` constant representing the maximum verbosity of
///     messages that will be displayed when debugging oTarget.
int GetDebugLevel(object oTarget = OBJECT_SELF);

/// @brief Set the verbosity of debug messages displayed for an object.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the maximum verbosity
///     of messages that will be displayed when debugging oTarget. If set to
///     `DEBUG_LEVEL_NONE`, oTarget will use the module's debug level instead.
/// @param oTarget The object to set the debug level of. If no debug level has
///     been set on oTarget, will use the module instead.
void SetDebugLevel(int nLevel, object oTarget = OBJECT_SELF);

/// @brief Return the color of debug messages of a given level.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the verbosity of debug
///     messsages to get the color for.
/// @returns A color code (in <cRGB> form).
string GetDebugColor(int nLevel);

/// @brief Set the color of debug messages of a given level.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the verbosity of debug
///     messsages to get the color for.
/// @param sColor A color core (in <cRBG> form) for the debug messages. If "",
///     will use the default color code for the level.
void SetDebugColor(int nLevel, string sColor = "");

/// @brief Return the prefix an object uses before its debug messages.
/// @param oTarget The target to check for a prefix.
/// @returns The user-defined prefix if one has been set. If it has not, will
///     return the object's tag (or name, if the object has no tag) in square
///     brackets.
string GetDebugPrefix(object oTarget = OBJECT_SELF);

/// @brief Set the prefix an object uses before its debug messages.
/// @param sPrefix The prefix to set. You can include color codes in the prefix,
///     but you can also set thedefault color code for all prefixes using
///     `SetDebugColor(DEBUG_COLOR_NONE, sColor);`.
/// @param oTarget The target to set the prefix for.
void SetDebugPrefix(string sPrefix, object oTarget = OBJECT_SELF);

/// @brief Return the enabled debug logging destinations.
/// @returns A bitmask of `DEBUG_LOG_*` values.
int GetDebugLogging();

/// @brief Set the enabled debug logging destinations.
/// @param nEnabled A bitmask of `DEBUG_LOG_*` destinations to enable.
void SetDebugLogging(int nEnabled);

/// @brief Add a player object to the debug message dispatch list.  Player
///     objects on the dispatch list will receive debug messages if the
///     module's DEBUG_LOG_LEVEL includes DEBUG_LOG_LIST.
/// @param oPC Player object to add.
void AddDebugLoggingPC(object oPC);

/// @brief Remove a player object from the debug dispatch list.
/// @param oPC Player object to remove.
void RemoveDebugLoggingPC(object oPC);

/// @brief Return whether debug messages of a given level will be logged on a
///     target. Useful for avoiding spending cycles computing extra debug
///     information if it will not be shown.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the message verbosity.
/// @param oTarget The object that would be debugged.
/// @returns TRUE if messages of nLevel would be logged on oTarget; FALSE
///     otherwise.
int IsDebugging(int nLevel, object oTarget = OBJECT_SELF);

/// If oTarget has a debug level of nLevel or higher, logs sMessages to all
/// destinations set with SetDebugLogging(). If no debug level is set on
/// oTarget,
/// will debug using the module's debug level instead.
/// @brief Display a debug message.
/// @details If the target has a debug level of nLevel or higher, sMessage will
///     be sent to all destinations enabled by SetDebugLogging(). If no debug
///     level is set on oTarget, will debug using the module's debug level
///     instead.
/// @param sMessage The message to display.
/// @param nLevel A `DEBUG_LEVEL_*` constant representing the message verbosity.
/// @param oTarget The object originating the message.
void Debug(string sMessage, int nLevel = DEBUG_LEVEL_DEBUG, object oTarget = OBJECT_SELF);

/// @brief Display a general notice message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Notice(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display a warning message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Warning(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display an error message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void Error(string sMessage, object oTarget = OBJECT_SELF);

/// @brief Display a critical error message. Alias for Debug().
/// @param sMessage The message to display.
/// @param oTarget The object originating the message.
void CriticalError(string sMessage, object oTarget = OBJECT_SELF);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void OverrideDebugLevel(int nLevel)
{
    nLevel = clamp(nLevel, DEBUG_LEVEL_NONE, DEBUG_LEVEL_DEBUG);
    SetLocalInt(GetModule(), DEBUG_OVERRIDE, nLevel);
}

int GetDebugLevel(object oTarget = OBJECT_SELF)
{
    object oModule = GetModule();
    int nOverride = GetLocalInt(oModule, DEBUG_OVERRIDE);
    if (nOverride)
        return nOverride;

    int nModule = GetLocalInt(oModule, DEBUG_LEVEL);
    if (oTarget == oModule || !GetIsObjectValid(oTarget))
        return nModule;

    int nLevel = GetLocalInt(oTarget, DEBUG_LEVEL);
    return (nLevel ? nLevel : nModule ? nModule : DEBUG_LEVEL_CRITICAL);
}

void SetDebugLevel(int nLevel, object oTarget = OBJECT_SELF)
{
    SetLocalInt(oTarget, DEBUG_LEVEL, nLevel);
}

string GetDebugColor(int nLevel)
{
    string sColor = GetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel));

    if (sColor == "")
    {
        int nColor;
        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: nColor = COLOR_RED;          break;
            case DEBUG_LEVEL_ERROR:    nColor = COLOR_ORANGE_DARK;  break;
            case DEBUG_LEVEL_WARNING:  nColor = COLOR_ORANGE_LIGHT; break;
            case DEBUG_LEVEL_NOTICE:   nColor = COLOR_YELLOW;       break;
            case DEBUG_LEVEL_NONE:     nColor = COLOR_GREEN_LIGHT;  break;
            default:                   nColor = COLOR_GRAY_LIGHT;   break;
        }

        sColor = HexToColor(nColor);
        SetDebugColor(nLevel, sColor);
    }

    return sColor;
}

void SetDebugColor(int nLevel, string sColor = "")
{
    SetLocalString(GetModule(), DEBUG_COLOR + IntToString(nLevel), sColor);
}

string GetDebugPrefix(object oTarget = OBJECT_SELF)
{
    string sColor = GetDebugColor(DEBUG_LEVEL_NONE);
    string sPrefix = GetLocalString(oTarget, DEBUG_PREFIX);
    if (sPrefix == "")
    {
        if (!GetIsObjectValid(oTarget))
        {
            sColor = GetDebugColor(DEBUG_LEVEL_WARNING);
            sPrefix = "Invalid Object: #" + ObjectToString(oTarget);
        }
        else
            sPrefix = (sPrefix = GetTag(oTarget)) == "" ?  GetName(oTarget) : sPrefix;

        sPrefix = "[" + sPrefix + "]";
    }

    return ColorString(sPrefix, sColor);
}

void SetDebugPrefix(string sPrefix, object oTarget = OBJECT_SELF)
{
    SetLocalString(oTarget, DEBUG_PREFIX, sPrefix);
}

int GetDebugLogging()
{
    return GetLocalInt(GetModule(), DEBUG_LOG);
}

void SetDebugLogging(int nEnabled)
{
    SetLocalInt(GetModule(), DEBUG_LOG, nEnabled);
}

void AddDebugLoggingPC(object oPC)
{
    if (GetIsPC(oPC))
        AddListObject(GetModule(), oPC, DEBUG_DISPATCH, TRUE);
}

void RemoveDebugLoggingPC(object oPC)
{
    RemoveListObject(GetModule(), oPC, DEBUG_DISPATCH);
}

int IsDebugging(int nLevel, object oTarget = OBJECT_SELF)
{
    return (nLevel <= GetDebugLevel(oTarget));
}

void Debug(string sMessage, int nLevel = DEBUG_LEVEL_DEBUG, object oTarget = OBJECT_SELF)
{
    if (IsDebugging(nLevel, oTarget))
    {
        string sColor = GetDebugColor(nLevel);
        string sPrefix = GetDebugPrefix(oTarget) + " ";

        switch (nLevel)
        {
            case DEBUG_LEVEL_CRITICAL: sPrefix += "[Critical Error] "; break;
            case DEBUG_LEVEL_ERROR:    sPrefix += "[Error] ";          break;
            case DEBUG_LEVEL_WARNING:  sPrefix += "[Warning] ";        break;
        }

        if (!HandleDebug(sPrefix, sMessage, nLevel, oTarget))
            return;

        sMessage = sPrefix + sMessage;
        int nLogging = GetLocalInt(GetModule(), DEBUG_LOG);

        if (nLogging & DEBUG_LOG_FILE)
            WriteTimestampedLogEntry(UnColorString(sMessage));

        sMessage = ColorString(sMessage, sColor);

        if (nLogging & DEBUG_LOG_DM)
            SendMessageToAllDMs(sMessage);

        if (nLogging & DEBUG_LOG_PC)
            SendMessageToPC(GetFirstPC(), sMessage);

        if (nLogging & DEBUG_LOG_LIST)
        {
            json jDispatchList = GetObjectList(GetModule(), DEBUG_DISPATCH);
            int n; for (n; n < JsonGetLength(jDispatchList); n++)
            {
                object oPC = GetListObject(GetModule(), n, DEBUG_DISPATCH);
                if (GetIsPC(oPC) && !((nLogging & DEBUG_LOG_PC) && oPC == GetFirstPC()))
                    SendMessageToPC(oPC, sMessage);
            }
        }
    }
}

void Notice(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_NOTICE, oTarget);
}

void Warning(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_WARNING, oTarget);
}

void Error(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_ERROR, oTarget);
}

void CriticalError(string sMessage, object oTarget = OBJECT_SELF)
{
    Debug(sMessage, DEBUG_LEVEL_CRITICAL, oTarget);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_libraries.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  This file holds functions for packing scripts into libraries. This
///     allows the builder to dramatically reduce the module script count by
///     keeping related scripts in the same file.
/// @details
/// Libraries allow the builder to encapsulate many scripts into one,
/// dramatically reducing the script count in the module. In a library, each
/// script is a function bound to a unique name and/or number. When the library
/// is called, the name is routed to the proper function.
///
/// Since each script defined by a library has a unique name to identify it, the
/// builder can execute a library script without having to know the file it is
/// located in. This makes it easy to create script systems to override behavior
/// of another system; you don't have to edit the other system's code, you just
/// implement your own function to override it.
///
/// ## Anatomy of a Library
/// This is an example of a simple library:
///
/// ``` nwscript
/// #include "util_i_libraries"
///
/// void MyFunction()
/// {
///     // ...
/// }
///
/// void MyOtherFunction()
/// {
///     // ...
/// }
///
/// void OnLibraryLoad()
/// {
///     RegisterLibraryScript("MyFunction");
///     RegisterLibraryScript("MyOtherFunction");
/// }
/// ```
///
/// This script contains custom functions (`MyFunction()` and `MyOtherFunction()`)
/// as well as an `OnLibraryLoad()` function. `OnLibraryLoad()` is executed
/// whenever the library is loaded by `LoadLibrary()`; it calls
/// `RegisterLibraryScript()` to expose the names of the custom functions as
/// library scripts. When a library script is called with `RunLibraryScript()`,
/// the custom functions are called.
///
/// If you want to do something more complicated that can't be handled by a
/// single function call, you can pass a unique number to
/// `RegisterLibraryScript()` as its second parameter, which will cause
/// `RunLibraryScript()` to call a special customizable dispatching function
/// called `OnLibraryScript()`. This function takes the name and number of the
/// desired function and executes the desired code. For example:
///
/// ``` nwscript
/// #include "util_i_libraries"
///
/// void OnLibraryLoad()
/// {
///     RegisterLibraryScript("Give50GP",  1);
///     RegisterLibraryScript("Give100GP", 2);
/// }
///
/// void OnLibraryScript(string sScript, int nEntry)
/// {
///     switch (nEntry)
///     {
///         case 1: GiveGoldToCreature(OBJECT_SELF, 50); break;
///         case 2: GiveGoldToCreature(OBJECT_SELF, 100); break;
///     }
/// }
/// ```
///
/// **Note:** A library does not need to have a `main()` function, because this
/// will be automatically generated by the `LoadLibrary()` and
/// `RunLibraryScript()` functions.
///
/// ## Using a Library
/// `util_i_libraries.nss` is needed to load or run library scripts.
///
/// To use a library, you must first load it. This will activate the library's
/// `OnLibraryLoad()` function and register each desired function.
///
/// ``` nwscript
/// // Loads a single library
/// LoadLibrary("my_l_library");
///
/// // Loads a CSV list of library scripts
/// LoadLibraries("pw_l_plugin, dlg_l_example, prr_l_main");
///
/// // Loads all libraries matching a glob pattern
/// LoadLibrariesByPattern("*_l_*");
///
/// // Loads all libraries matching a prefix
/// LoadLibrariesByPrefix("pw_l_");
/// ```
///
/// If a library implements a script that has already been implemented in
/// another library, a warning will be issued and the newer script will take
/// precedence.
///
/// Calling a library script is done using `RunLibraryScript()`. The name
/// supplied should be the name bound to the function in the library's
/// `OnLibraryLoad()`. If the name supplied is implemented by a library, the
/// library will be JIT compiled and the desired function will be called with
/// `ExecuteScriptChunk()`. Otherwise, the name will be assumed to match a
/// normal script, which will be executed with `ExecuteScript()`.
///
/// ``` nwscript
/// // Executes a single library script on OBJECT_SELF
/// RunLibraryScript("MyFunction");
///
/// // Executes a CSV list of library scripts, for which oPC will be OBJECT_SELF
/// object oPC = GetFirstPC();
/// RunLibraryScripts("MyFunction, MyOtherFunction", oPC);
/// ```
///
/// ## Pre-Compiled Libraries
/// By default, libraries are run using `ExecuteScriptChunk()`, which JIT
/// compiles the script and runs it each time the library script is called. If
/// you wish to have your script pre-compiled, you can include the script
/// `util_i_library.nss` in your file in place of `util_i_libraries.nss`. This
/// script contains a `main()` function that will call either your
/// `OnLibraryLoad()` or `OnLibraryScript()` function as appropriate; thus, if
/// you use this method, you *must* provide an `OnLibraryScript()` dispatch
/// function.
///
/// **Note**: `util_i_library.nss` uses the nwnsc `default_function` pragma to
/// prevent compilation errors and will not compile with the toolset compiler.
/// If this is not desired, you can either comment those lines out or implement
/// the `main()` function yourself.
/// ----------------------------------------------------------------------------

#include "util_i_debug"
#include "util_i_csvlists"
#include "util_i_sqlite"
#include "util_i_nss"
#include "util_i_matching"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string LIB_RETURN  = "LIB_RETURN";  ///< The return value of the library
const string LIB_LIBRARY = "LIB_LIBRARY"; ///< The library being processed
const string LIB_SCRIPT  = "LIB_SCRIPT";  ///< The library script name
const string LIB_ENTRY   = "LIB_ENTRY";   ///< The library script entry number

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Create a library table in the module's volatile sqlite database.
/// @param bReset if TRUE, the table will be dropped if already present.
/// @note This is called automatically by the library functions.
void CreateLibraryTable(int bReset = FALSE);

/// @brief Add a database record associating a script with a library.
/// @param sLibrary The script to source from.
/// @param sScript The name to associate with the library script.
/// @param nEntry A number unique to sLibrary to identify this script. If this
///     is 0 and the library has not been pre-compiled, RunLibraryScript() will
///     call sScript directly. Otherwise, RunLibraryScript() will run a dispatch
///     function that can use this number to execute the correct code. Thus,
///     nEntry must be set if sScript does not exactly match the desired
///     function name or the function requires parameters.
void AddLibraryScript(string sLibrary, string sScript, int nEntry = 0);

/// @brief Return the name of the library containing a script from the database.
/// @param sScript The name of the library script.
string GetScriptLibrary(string sScript);

/// @brief Return the entry number associated with a library script.
/// @param sScript The name of the library script.
int GetScriptEntry(string sScript);

/// @brief Return a prepared query with the with the library and entry data
///     associated with a library script.
/// @param sScript The name of the library script.
/// @note This allows users to retrive the same data returned by
///     GetScriptLibrary() and GetScriptEntry() with one function.
sqlquery GetScriptData(string sScript);

/// @brief Return whether a script library has been loaded.
/// @param sLibrary The name of the script library file.
int GetIsLibraryLoaded(string sLibrary);

/// @brief Load a script library by executing its OnLibraryLoad() function.
/// @param sLibrary The name of the script library file.
/// @param bForce If TRUE, will re-load the library if it was already loaded.
void LoadLibrary(string sLibrary, int bForce = FALSE);

/// @brief Load a list of script libraries in sequence.
/// @param sLibraries A CSV list of libraries to load.
/// @param bForce If TRUE, will re-load the library if it was already loaded.
void LoadLibraries(string sLibraries, int bForce = FALSE);

/// @brief Return a json array of script names with a prefix.
/// @param sPrefix The prefix matching the scripts to find.
/// @returns A sorted json array of script names, minus the extensions.
/// @note The search includes both nss and ncs files, with duplicates removed.
json GetScriptsByPrefix(string sPrefix);

/// @brief Load all scripts matching the given glob pattern(s).
/// @param sPattern A CSV list of glob patterns to match with. Supported syntax:
///     - `*`: match zero or more characters
///     - `?`: match a single character
///     - `[abc]`: match any of a, b, or c
///     - `[a-z]`: match any character from a-z
///     - other text is matched literally
/// @param bForce If TRUE, will-reload the library if it was already loaded.
void LoadLibrariesByPattern(string sPattern, int bForce = FALSE);

/// @brief Load all scripts with a given prefix as script libraries.
/// @param sPrefix A prefix for the desired script libraries.
/// @param bForce If TRUE, will re-load the library if it was already loaded.
/// @see GetMatchesPattern() for the rules on glob syntax.
void LoadLibrariesByPrefix(string sPrefix, int bForce = FALSE);

/// @brief Execute a registered library script.
/// @param sScript The unique name of the library script.
/// @param oSelf The object that should execute the script as OBJECT_SELF.
/// @returns The integer value set with LibraryReturn() by sScript.
/// @note If sScript is not registered as a library script, it will be executed
///     as a regular script instead.
int RunLibraryScript(string sScript, object oSelf = OBJECT_SELF);

/// @brief Execute a list of registered library scripts in sequence.
/// @param sScripts A CSV list of library script names.
/// @param oSelf The object that should execute the scripts as OBJECT_SELF.
/// @note If any script in sScripts is not registered as a library script, it
///     will be executed as a regular script instead.
void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF);

/// @brief Register a script to a library. The script can later be called using
///     RunLibraryScript().
/// @param sScript A name for the script. Must be unique in the module. If a
///     second script with the same name is registered, it will overwrite the
///     first one.  This value does not have to match the function or script name.
/// @param nEntry A number unique to this library to identify this script. If
///     this is 0 and the library has not been pre-compiled, RunLibraryScript()
///     will call sScript directly. Otherwise, RunLibraryScript() will run a
///     dispatch function that can use this number to execute the correct code.
///     Thus, nEntry must be set if sScript does not exactly match the desired
///     function name or the function requires parameters.
/// @note Must be called within a script library's OnLibraryLoad() function. For
///     uses in other places, use AddLibraryScript().
void RegisterLibraryScript(string sScript, int nEntry = 0);

/// @brief Set the return value of the currently executing library script.
/// @param nValue The value to return to the calling script.
void LibraryReturn(int nValue);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

void CreateLibraryTable(int bReset = FALSE)
{
    SqlCreateTableModule("library_scripts",
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "sLibrary TEXT NOT NULL, " +
        "sScript TEXT NOT NULL UNIQUE ON CONFLICT REPLACE, " +
        "nEntry INTEGER NOT NULL);",
        bReset);
}

void AddLibraryScript(string sLibrary, string sScript, int nEntry = 0)
{
    CreateLibraryTable();

    string sQuery = "INSERT INTO library_scripts (sLibrary, sScript, nEntry) " +
                    "VALUES (@sLibrary, @sScript, @nEntry);";
    sqlquery sql = SqlPrepareQueryModule(sQuery);
    SqlBindString(sql, "@sLibrary", sLibrary);
    SqlBindString(sql, "@sScript", sScript);
    SqlBindInt(sql, "@nEntry", nEntry);

    SqlStep(sql);
}

string GetScriptFieldData(string sField, string sScript)
{
    CreateLibraryTable();

    string sQuery = "SELECT " + sField + " FROM library_scripts " +
                    "WHERE sScript = @sScript;";
    sqlquery sql = SqlPrepareQueryModule(sQuery);
    SqlBindString(sql, "@sScript", sScript);

    return SqlStep(sql) ? SqlGetString(sql, 0) : "";
}

string GetScriptLibrary(string sScript)
{
    return GetScriptFieldData("sLibrary", sScript);
}

int GetScriptEntry(string sScript)
{
    return StringToInt(GetScriptFieldData("nEntry", sScript));
}

sqlquery GetScriptData(string sScript)
{
    CreateLibraryTable();

    string sQuery = "SELECT sLibrary, nEntry FROM library_scripts " +
                    "WHERE sScript = @sScript;";
    sqlquery sql = SqlPrepareQueryModule(sQuery);
    SqlBindString(sql, "@sScript", sScript);

    return sql;
}

int GetIsLibraryLoaded(string sLibrary)
{
    CreateLibraryTable();

    string sQuery = "SELECT COUNT(sLibrary) FROM library_scripts " +
                    "WHERE sLibrary = @sLibrary LIMIT 1;";
    sqlquery sql = SqlPrepareQueryModule(sQuery);
    SqlBindString(sql, "@sLibrary", sLibrary);

    return SqlStep(sql) ? SqlGetInt(sql, 0) : FALSE;
}

void LoadLibrary(string sLibrary, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load library " + sLibrary);

    if (bForce || !GetIsLibraryLoaded(sLibrary))
    {
        SetScriptParam(LIB_LIBRARY, sLibrary);
        if (ResManGetAliasFor(sLibrary, RESTYPE_NCS) == "")
        {
            Debug(sLibrary + ".ncs not present; loading library as chunk");
            string sChunk = NssInclude(sLibrary) + NssVoidMain(NssFunction("OnLibraryLoad"));
            string sError = ExecuteScriptChunk(sChunk, GetModule(), FALSE);
            if (sError != "")
                CriticalError("Could not load " + sLibrary + ": " + sError);
        }
        else
            ExecuteScript(sLibrary, GetModule());

    }
    else
        Error("Library " + sLibrary + " already loaded!");
}

void LoadLibraries(string sLibraries, int bForce = FALSE)
{
    Debug("Attempting to " + (bForce ? "force " : "") + "load libraries " + sLibraries);

    int i, nCount = CountList(sLibraries);
    for (i = 0; i < nCount; i++)
        LoadLibrary(GetListItem(sLibraries, i), bForce);
}

// Private function for GetScriptsByPrefix*(). Adds all scripts of nResType
// matching a prefix to a json array and returns it.
json _GetScriptsByPrefix(json jArray, string sPrefix, int nResType)
{
    int i;
    string sScript;
    while ((sScript = ResManFindPrefix(sPrefix, nResType, ++i)) != "")
        jArray = JsonArrayInsert(jArray, JsonString(sScript));

    return jArray;
}

json GetScriptsByPrefix(string sPrefix)
{
    json jScripts = _GetScriptsByPrefix(JsonArray(), sPrefix, RESTYPE_NCS);
         jScripts = _GetScriptsByPrefix(jScripts,    sPrefix, RESTYPE_NSS);
         jScripts = JsonArrayTransform(jScripts, JSON_ARRAY_UNIQUE);
         jScripts = JsonArrayTransform(jScripts, JSON_ARRAY_SORT_ASCENDING);
    return jScripts;
}

void LoadLibrariesByPattern(string sPatterns, int bForce = FALSE)
{
    if (sPatterns == "")
        return;

    Debug("Finding libraries matching \"" + sPatterns + "\"");
    json jPatterns  = ListToJson(sPatterns);
    json jLibraries = FilterByPatterns(GetScriptsByPrefix(""), jPatterns, TRUE);
    LoadLibraries(JsonToList(jLibraries), bForce);
}

void LoadLibrariesByPrefix(string sPrefix, int bForce = FALSE)
{
    Debug("Finding libraries with prefix \"" + sPrefix + "\"");
    json jLibraries = GetScriptsByPrefix(sPrefix);
    LoadLibraries(JsonToList(jLibraries), bForce);
}

void LoadPrefixLibraries(string sPrefix, int bForce = FALSE)
{
    Debug("LoadPrefixLibraries() is deprecated; use LoadLibrariesByPrefix()");
    LoadLibrariesByPrefix(sPrefix, bForce);
}

int RunLibraryScript(string sScript, object oSelf = OBJECT_SELF)
{
    if (sScript == "") return -1;

    string sLibrary;
    int nEntry;

    sqlquery sqlScriptData = GetScriptData(sScript);
    if (SqlStep(sqlScriptData))
    {
        sLibrary = SqlGetString(sqlScriptData, 0);
        nEntry = SqlGetInt(sqlScriptData, 1);
    }

    DeleteLocalInt(oSelf, LIB_RETURN);

    if (sLibrary != "")
    {
        Debug("Library script " + sScript + " found in " + sLibrary +
            (nEntry != 0 ? " at entry " + IntToString(nEntry) : ""));

        SetScriptParam(LIB_LIBRARY, sLibrary);
        SetScriptParam(LIB_SCRIPT, sScript);
        SetScriptParam(LIB_ENTRY, IntToString(nEntry));

        if (ResManGetAliasFor(sLibrary, RESTYPE_NCS) == "")
        {
            Debug(sLibrary + ".ncs not present; running library script as chunk");
            string sChunk = NssInclude(sLibrary) + NssVoidMain(nEntry ?
                NssFunction("OnLibraryScript", NssQuote(sScript) + ", " + IntToString(nEntry)) :
                NssFunction(sScript));
            string sError = ExecuteScriptChunk(sChunk, oSelf, FALSE);
            if (sError != "")
                CriticalError("RunLibraryScript(" + sScript +") failed: " + sError);
        }
        else
            ExecuteScript(sLibrary, oSelf);
    }
    else
    {
        Debug(sScript + " is not a library script; executing directly");
        ExecuteScript(sScript, oSelf);
    }

    return GetLocalInt(oSelf, LIB_RETURN);
}

void RunLibraryScripts(string sScripts, object oSelf = OBJECT_SELF)
{
    int i, nCount = CountList(sScripts);
    for (i = 0; i < nCount; i++)
        RunLibraryScript(GetListItem(sScripts, i), oSelf);
}

void RegisterLibraryScript(string sScript, int nEntry = 0)
{
    string sLibrary = GetScriptParam(LIB_LIBRARY);
    string sExist = GetScriptLibrary(sScript);

    if (sLibrary != sExist && sExist != "")
        Warning(sLibrary + " is overriding " + sExist + "'s implementation of " + sScript);

    int nOldEntry = GetScriptEntry(sScript);
    if (nOldEntry)
        Warning(sLibrary + " already declared " + sScript +
            " Old Entry: " + IntToString(nOldEntry) +
            " New Entry: " + IntToString(nEntry));

    AddLibraryScript(sLibrary, sScript, nEntry);
}

void LibraryReturn(int nValue)
{
    SetLocalInt(OBJECT_SELF, LIB_RETURN, nValue);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_library.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Boilerplace code for creating a library dispatcher. Should only be
///     included in library scripts as it implements main().
/// ----------------------------------------------------------------------------

#include "util_i_libraries"

// -----------------------------------------------------------------------------
//                              Function Protoypes
// -----------------------------------------------------------------------------

// This is a user-defined function that registers function names to a unique (to
// this library) number. When the function name is run using RunLibraryScript(),
// this number will be passed to the user-defined function OnLibraryScript(),
// which resolves the call to the correct function.
//
// Example usage:
// void OnLibraryLoad()
// {
//     RegisterLibraryScript("MyFunction");
//     RegisterLibraryScript("MyOtherFunction");
// }
//
// or, if using nEntry...
// void OnLibraryLoad()
// {
//     RegisterLibraryScript("MyFunction",      1);
//     RegisterLibraryScript("MyOtherFunction", 2);
// }
void OnLibraryLoad();

// This is a user-defined function that routes a unique (to the module) script
// name (sScript) or a unique (to this library) number (nEntry) to a function.
//
// Example usage:
// void OnLibraryScript(string sScript, int nEntry)
// {
//     if      (sScript == "MyFunction")      MyFunction();
//     else if (sScript == "MyOtherFunction") MyOtherFunction();
// }
//
// or, using nEntry...
// void OnLibraryScript(string sScript, int nEntry)
// {
//     switch (nEntry)
//     {
//         case 1: MyFunction();      break;
//         case 2: MyOtherFunction(); break;
//     }
// }
//
// For advanced usage, see the libraries included in the Core Framework.
void OnLibraryScript(string sScript, int nEntry);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

// These are dummy implementations to prevent nwnsc from complaining that they
// do not exist. If you want to compile in the toolset rather than using nwnsc,
// comment these lines out.
// #pragma default_function(OnLibraryLoad)
// #pragma default_function(OnLibraryScript)

// -----------------------------------------------------------------------------
//                                 Main Routine
// -----------------------------------------------------------------------------

void main()
{
    if (GetScriptParam(LIB_ENTRY) == "")
        OnLibraryLoad();
    else
        OnLibraryScript(GetScriptParam(LIB_SCRIPT),
            StringToInt(GetScriptParam(LIB_ENTRY)));
}
/// ----------------------------------------------------------------------------
/// @file   util_i_lists.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Compatibility functions to convert between CSV and localvar lists.
/// ----------------------------------------------------------------------------

#include "util_i_csvlists"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Acceptable values for nListType in SplitList() and JoinList().
const int LIST_TYPE_FLOAT  = 0;
const int LIST_TYPE_INT    = 1;
const int LIST_TYPE_STRING = 2;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Splits a comma-separated value list into a local variable list of the
///     given type.
/// @param oTarget Object on which to create the list
/// @param sList Source CSV list
/// @param sListName Name of the list to create or add to
/// @param bAddUnique If TRUE, prevents duplicate list items
/// @param nListType Type of list to create
///     LIST_TYPE_STRING (default)
///     LIST_TYPE_FLOAT
///     LIST_TYPE_INT
/// @returns JSON array of split CSV list
json SplitList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

/// @brief Joins a local variable list of a given type into a comma-separated
///     value list
/// @param oTarget Object from which to source the local variable list
/// @param sListName Name of the local variable list
/// @param bAddUnique If TRUE, prevents duplicate list items
/// @param nListType Type of local variable list
///     LIST_TYPE_STRING (default)
///     LIST_TYPE_FLOAT
///     LIST_TYPE_INT
/// @returns Joined CSV list of local variable list
string JoinList(object oTarget, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

json SplitList(object oTarget, string sList, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    json jList = JSON_ARRAY;

    if (nListType == LIST_TYPE_STRING)
        jList = ListToJson(sList, TRUE);
    else
        jList = JsonParse("[" + sList + "]");

    string sListType = (nListType == LIST_TYPE_STRING ? VARLIST_TYPE_STRING :
                        nListType == LIST_TYPE_INT ?    VARLIST_TYPE_INT :
                                                        VARLIST_TYPE_FLOAT);

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

    if (oTarget != OBJECT_INVALID)
        _SetList(oTarget, sListType, sListName, jList);

    return jList;
}

string JoinList(object oTarget, string sListName = "", int bAddUnique = FALSE, int nListType = LIST_TYPE_STRING)
{
    string sListType = (nListType == LIST_TYPE_STRING ? VARLIST_TYPE_STRING :
                        nListType == LIST_TYPE_INT ?    VARLIST_TYPE_INT :
                                                        VARLIST_TYPE_FLOAT);

    json jList = _GetList(oTarget, sListType, sListName);
    if (jList == JsonNull() || JsonGetLength(jList) == 0)
        return "";

    if (bAddUnique == TRUE)
        jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

    string sList;
    if (nListType == LIST_TYPE_STRING)
        sList = JsonToList(jList);
    else
    {
        sList = JsonDump(jList);
        sList = GetStringSlice(sList, 1, GetStringLength(sList) - 2);
    }

    return sList;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_matching.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Utilities for pattern matching.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return whether a string matches a glob pattern.
/// @param sString The string to check.
/// @param sPattern A glob pattern. Supported syntax:
///     - `*`: match zero or more characters
///     - `?`: match a single character
///     - `[abc]`: match any of a, b, or c
///     - `[a-z]`: match any character from a-z
///     - other text is matched literally
/// @returns TRUE if sString matches sPattern; FALSE otherwise.
int GetMatchesPattern(string sString, string sPattern);

/// @brief Return whether a string matches any of an array of glob patterns.
/// @param sString The string to check.
/// @param sPattern A json array of glob patterns.
/// @returns TRUE if sString matches sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetMatchesPatterns(string sString, json jPatterns);

/// @brief Return if any element of a json array matches a glob pattern.
/// @param jArray A json array of strings to check.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, returning whether any
///     element does not match the glob pattern.
/// @returns TRUE if any element of jArray matches sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetAnyMatchesPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Return if all elements of a json array match a glob pattern.
/// @param jArray A json array of strings to check.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, returning whether all
///     elements do not match the glob pattern.
/// @returns TRUE if all elements of jArray match sPattern; FALSE otherwise.
/// @see GetMatchesPattern() for supported glob syntax.
int GetAllMatchesPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Filter out all elements of an array that do not match a glob pattern.
/// @param jArray A json array of strings to filter.
/// @param sPattern A glob pattern.
/// @param bNot If TRUE, will invert the selection, only keeping elements that
///     do not match the glob pattern.
/// @returns A modified copy of jArray with all non-matching elements removed.
/// @see GetMatchesPattern() for supported glob syntax.
json FilterByPattern(json jArray, string sPattern, int bNot = FALSE);

/// @brief Filter out all elements of an array that do not match any of an array
///     of glob patterns.
/// @param jArray A json array of strings to filter.
/// @param jPatterns A json array of glob patterns.
/// @param bOrderByPatterns If TRUE, will order the results by the pattern they
///     matched with rather than by their placement in jArray.
/// @returns A modified copy of jArray with all non-matching elements removed.
/// @see GetMatchesPattern() for supported glob syntax.
json FilterByPatterns(json jArray, json jPatterns, int bOrderByPatterns = FALSE);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int GetMatchesPattern(string sString, string sPattern)
{
    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT @string GLOB @pattern;");
    SqlBindString(q, "@string", sString);
    SqlBindString(q, "@pattern", sPattern);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

int GetMatchesPatterns(string sString, json jPatterns)
{
    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT 1 FROM json_each(@patterns) WHERE @value GLOB json_each.value;");
    SqlBindString(q, "@value", sString);
    SqlBindJson(q, "@patterns", jPatterns);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

int GetAnyMatchesPattern(json jArray, string sPattern, int bNot = FALSE)
{
    jArray = FilterByPattern(jArray, sPattern, bNot);
    return JsonGetLength(jArray) != 0;
}

int GetAllMatchesPattern(json jArray, string sPattern, int bNot = FALSE)
{
    return jArray == FilterByPattern(jArray, sPattern, bNot);
}

json FilterByPattern(json jArray, string sPattern, int bNot = FALSE)
{
    if (!JsonGetLength(jArray))
        return jArray;

    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT json_group_array(value) FROM json_each(@array) " +
        "WHERE value " + (bNot ? "NOT " : "") + "GLOB @pattern;");
    SqlBindJson(q, "@array", jArray);
    SqlBindString(q, "@pattern", sPattern);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json FilterByPatterns(json jArray, json jPatterns, int bOrderByPattern = FALSE)
{
    if (!JsonGetLength(jArray) || ! JsonGetLength(jPatterns))
        return jArray;

    sqlquery q = SqlPrepareQueryObject(GetModule(),
        "SELECT json_group_array(value) FROM " +
            "(SELECT DISTINCT v.key, v.value FROM " +
                "json_each(@values) v JOIN " +
                "json_each(@patterns) p " +
                "WHERE v.value GLOB p.value " +
                (bOrderByPattern ? "ORDER BY p.key);" : ");"));
    SqlBindJson(q, "@values", jArray);
    SqlBindJson(q, "@patterns", jPatterns);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}
/// ----------------------------------------------------------------------------
/// @file   util_i_math.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Useful math utility functions.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return the closest integer to the binary logarithm of a number.
int log2(int n);

/// @brief Restrict an integer to a range.
/// @param nValue The number to evaluate.
/// @param nMin The minimum value for the number.
/// @param nMax The maximum value for the number.
/// @returns nValue if it is between nMin and nMax. Otherwise returns the
///     closest of nMin or nMax.
int clamp(int nValue, int nMin, int nMax);

/// @brief Restrict a float to a range.
/// @param fValue The number to evaluate.
/// @param fMin The minimum value for the number.
/// @param fMax The maximum value for the number.
/// @returns fValue if it is between fMin and fMax. Otherwise returns the
///     closest of fMin or fMax.
float fclamp(float fValue, float fMin, float fMax);

/// @brief Return the larger of two integers.
int max(int a, int b);

/// @brief Return the smaller of two integers.
int min(int a, int b);

/// @brief Return the sign of an integer.
/// @returns -1 if n is negative, 0 if 0, or 1 if positive.
int sign(int n);

/// @brief Return the larger of two floats.
float fmax(float a, float b);

/// @brief Return the smaller of two floats.
float fmin(float a, float b);

/// @brief Return the sign of a float.
/// @returns -1 if f is negative, 0 if 0, or 1 if positive.
int fsign(float f);

/// @brief Truncate a float (i.e., remove numbers to the right of the decimal
///     point).
float trunc(float f);

/// @brief Return the fractional part of a float (i.e., numbers to the right of
///     the decimal point).
float frac(float f);

/// @brief Return a % b (modulo function).
/// @param a The dividend
/// @param b The divisor
/// @note For consistency with NWN's integer modulo operator, the result has the
///     same sign as a (i.e., fmod(-1, 2) == -1).
float fmod(float a, float b);

/// @brief Round a float down to the nearest whole number.
float floor(float f);

/// @brief Round a float up to the nearest whole number.
float ceil(float f);

/// @brief Round a float towards to the nearest whole number.
/// @note In case of a tie (i.e., +/- 0.5), rounds away from 0.
float round(float f);

/// @brief Determine if x is in [a..b]
/// @param x Value to compare
/// @param a Low end of range
/// @param b High end of range
int between(int x, int a, int b);

/// @brief Determine if x is in [a..b]
/// @param x Value to compare
/// @param a Low end of range
/// @param b High end of range
int fbetween(float x, float a, float b);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int log2(int n)
{
    int nResult;
    while (n >>= 1)
        nResult++;
    return nResult;
}

int clamp(int nValue, int nMin, int nMax)
{
    return (nValue < nMin) ? nMin : ((nValue > nMax) ? nMax : nValue);
}

float fclamp(float fValue, float fMin, float fMax)
{
    return (fValue < fMin) ? fMin : ((fValue > fMax) ? fMax : fValue);
}

int max(int a, int b)
{
    return (b > a) ? b : a;
}

int min(int a, int b)
{
    return (b > a) ? a : b;
}

int sign(int n)
{
    return (n > 0) ? 1 : (n < 0) ? -1 : 0;
}

float fmax(float a, float b)
{
    return (b > a) ? b : a;
}

float fmin(float a, float b)
{
    return (b > a) ? a : b;
}

int fsign(float f)
{
    return f > 0.0 ? 1 : f < 0.0 ? -1 : 0;
}

float trunc(float f)
{
    return IntToFloat(FloatToInt(f));
}

float frac(float f)
{
    return f - trunc(f);
}

float fmod(float a, float b)
{
    return a - b * trunc(a / b);
}

float floor(float f)
{
    return IntToFloat(FloatToInt(f) - (f < 0.0));
}

float ceil(float f)
{
    return IntToFloat(FloatToInt(f) + (trunc(f) < f));
}

float round(float f)
{
    return IntToFloat(FloatToInt(f + (f < 0.0 ? -0.5 : 0.5)));
}

int between(int x, int a, int b)
{
    return ((x - a) * (x - b)) <= 0;
}

int fbetween(float x, float a, float b)
{
    return ((x - a) * (x - b)) <= 0.0;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_nss.nss
/// @author Daz <daztek@gmail.com>
/// @brief  Functions to assemble scripts for use with `ExecuteScriptChunk()`.
/// @note   Borrowed from https://github.com/Daztek/EventSystem
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return a `void main()` block.
/// @param sContents The contents of the block.
string NssVoidMain(string sContents);

/// @brief Return an `int StartingConditional()` block.
/// @param sContents The contents of the block.
string NssStartingConditional(string sContents);

/// @brief Return an include directive.
/// @param sIncludeFile The file to include.
string NssInclude(string sIncludeFile);

/// @brief Return an if statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssIf(string sLeft, string sComparison = "", string sRight = "");

/// @brief Return an else statement.
string NssElse();

/// @brief Return an else-if statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssElseIf(string sLeft, string sComparison = "", string sRight = "");

/// @brief Create a while statement with a comparison.
/// @param sLeft The left side of the comparison. If sComparison or sRight are
///     blank, will be evalated as a boolean expression.
/// @param sComparison The comparison operator.
/// @param sRight The right side of the comparison.
string NssWhile(string sLeft, string sComparison = "", string sRight = "");

/// @brief Return a script block bounded by curly brackets.
/// @param sContents The contents of the block.
string NssBrackets(string sContents);

/// @brief Return a string wrapped in double quotes.
/// @param sString The string to wrap.
string NssQuote(string sString);

/// @brief Return a switch statement.
/// @param sVariable The variable to evaluate in the switch statement.
/// @param sCases A series of case statements the switch should dispatch to.
/// @see NssCase().
string NssSwitch(string sVariable, string sCases);

/// @brief Return a case statement.
/// @param nCase The value matching the switch statement.
/// @param sContents The contents of the case block.
/// @param bBreak If TRUE, will add a break statement after sContents.
string NssCase(int nCase, string sContents, int bBreak = TRUE);

/// @brief Return an object variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssObject(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a string variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssString(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return an int variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssInt(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a float variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssFloat(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a vector variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssVector(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a location variable declaration and/or assignment.
/// @param sVarName The name for the variable.
/// @param sValue The value to assign to the variable. If blank, no value will
///     be assigned.
/// @param bIncludeType If TRUE, the variable will be declared as well.
string NssLocation(string sVarName, string sValue = "", int bIncludeType = TRUE);

/// @brief Return a call, prototype, or definition of a function.
/// @param sFunction The name of the function.
/// @param sArguments The list of arguments for the function.
/// @param bAddSemicolon If TRUE, a semicolon will be assed to the end of the
///     statement.
string NssFunction(string sFunction, string sArguments = "", int bAddSemicolon = TRUE);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

string NssVoidMain(string sContents)
{
    return "void main() { " + sContents + " }";
}

string NssStartingConditional(string sContents)
{
    return "int StartingConditional() { return " + sContents + " }";
}

string NssInclude(string sIncludeFile)
{
    return sIncludeFile == "" ? sIncludeFile : "#" + "include \"" + sIncludeFile + "\" ";
}

string NssCompare(string sLeft, string sComparison, string sRight)
{
    return (sComparison == "" || sRight == "") ? sLeft : sLeft + " " + sComparison + " " + sRight;
}

string NssIf(string sLeft, string sComparison = "", string sRight = "")
{
    return "if (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssElse()
{
    return "else ";
}

string NssElseIf(string sLeft, string sComparison = "", string sRight = "")
{
    return "else if (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssWhile(string sLeft, string sComparison = "", string sRight = "")
{
    return "while (" + NssCompare(sLeft, sComparison, sRight) + ") ";
}

string NssBrackets(string sContents)
{
    return "{ " + sContents + " } ";
}

string NssQuote(string sString)
{
    return "\"" + sString + "\"";
}

string NssSwitch(string sVariable, string sCases)
{
    return "switch (" + sVariable + ") { " + sCases + " }";
}

string NssCase(int nCase, string sContents, int bBreak = TRUE)
{
    return "case " + IntToString(nCase) + ": { " + sContents + (bBreak ? " break;" : "") + " } ";
}

string NssSemicolon(string sString)
{
    return (GetStringRight(sString, 1) == ";" || GetStringRight(sString, 2) == "; ") ? sString + " " : sString + "; ";
}

string NssVariable(string sType, string sVarName, string sValue)
{
    return sType + " " + sVarName + (sValue == "" ? "; " : " = " + NssSemicolon(sValue));
}

string NssObject(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "object" : "", sVarName, sValue);
}

string NssString(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "string" : "", sVarName, sValue);
}

string NssInt(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "int" : "", sVarName, sValue);
}

string NssFloat(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "float" : "", sVarName, sValue);
}

string NssVector(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "vector" : "", sVarName, sValue);
}

string NssLocation(string sVarName, string sValue = "", int bIncludeType = TRUE)
{
    return NssVariable(bIncludeType ? "location" : "", sVarName, sValue);
}

string NssFunction(string sFunction, string sArguments = "", int bAddSemicolon = TRUE)
{
    return sFunction + "(" + sArguments + (bAddSemicolon ? ");" : ")") + " ";
}
/// ----------------------------------------------------------------------------
/// @file   util_i_sqlite.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Helper functions for NWN:EE SQLite databases.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Alias for `SqlPreparerQueryObject(GetModule(), sSQL)`.
sqlquery SqlPrepareQueryModule(string sSQL);

/// @brief Prepares and executes a query on a PC's peristent database.
/// @param oPC The PC that stores the database.
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecPC(object oPC, string sQuery);

/// @brief Prepares and executes a query on the module's volatile database.
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecModule(string sQuery);

/// @brief Prepares and executes a query on a persistent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sQuery The SQL statement to execute.
/// @returns Whether the query was successful.
int SqlExecCampaign(string sDatabase, string sQuery);

/// @brief Creates a table in a PC's persistent database.
/// @param oPC The PC that stores the database.
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTablePC(object oPC, string sTable, string sStructure, int bForce = FALSE);

/// @brief Creates a table in the module's volatile database.
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTableModule(string sTable, string sStructure, int bForce = FALSE);

/// @brief Creates a table in a persistent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sTable The name of the table.
/// @param sStructure The SQL describing the structure of the table (i.e.,
/// everything that would go between the parentheses).
/// @param bForce Whether to drop an existing table.
void SqlCreateTableCampaign(string sDatabase, string sTable, string sStructure, int bForce = FALSE);

/// @brief Checks if a table exists the PC's persistent database.
/// @param oPC The PC that stores the database.
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsPC(object oPC, string sTable);

/// @brief Checks if a table exists in the module's volatile database.
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsModule(string sTable);

/// @brief Checks if a table exists in a peristent campaign database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @param sTable The name of the table to check for.
/// @returns Whether the table exists.
int SqlGetTableExistsCampaign(string sDatabase, string sTable);

/// @brief Gets the ID of the last row inserted into a PC's persistent database.
/// @param oPC The PC that stores the database.
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdPC(object oPC);

/// @brief Gets the ID of the last row inserted into the module's volatile
/// database.
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdModule();

/// @brief Gets the ID of the last row inserted into a persistent campaign
/// database.
/// @param sDatabase The name of the campaign database file (minus extension).
/// @returns The ID of the last inserted row or -1 on error.
int SqlGetLastInsertIdCampaign(string sDatabase);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

sqlquery SqlPrepareQueryModule(string sSQL)
{
    return SqlPrepareQueryObject(GetModule(), sSQL);
}

int SqlExecPC(object oPC, string sQuery)
{
    return SqlStep(SqlPrepareQueryObject(oPC, sQuery));
}

int SqlExecModule(string sQuery)
{
    return SqlStep(SqlPrepareQueryModule(sQuery));
}

int SqlExecCampaign(string sDatabase, string sQuery)
{
    return SqlStep(SqlPrepareQueryCampaign(sDatabase, sQuery));
}

void SqlCreateTablePC(object oPC, string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecPC(oPC, "DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecPC(oPC, "CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

void SqlCreateTableModule(string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecModule("DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecModule("CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

void SqlCreateTableCampaign(string sDatabase, string sTable, string sStructure, int bForce = FALSE)
{
    if (bForce)
        SqlExecCampaign(sDatabase, "DROP TABLE IF EXISTS " + sTable + ";");

    SqlExecCampaign(sDatabase, "CREATE TABLE IF NOT EXISTS " + sTable + "(" + sStructure + ");");
}

int SqlGetTableExistsPC(object oPC, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryObject(oPC, sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetTableExistsModule(string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryModule(sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetTableExistsCampaign(string sDatabase, string sTable)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name = @table;";
    sqlquery qQuery = SqlPrepareQueryCampaign(sDatabase, sQuery);
    SqlBindString(qQuery, "@table", sTable);
    return SqlStep(qQuery);
}

int SqlGetLastInsertIdPC(object oPC)
{
    sqlquery qQuery = SqlPrepareQueryObject(oPC, "SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}

int SqlGetLastInsertIdModule()
{
    sqlquery qQuery = SqlPrepareQueryModule("SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}

int SqlGetLastInsertIdCampaign(string sDatabase)
{
    sqlquery qQuery = SqlPrepareQueryCampaign(sDatabase, "SELECT last_insert_rowid();");
    return SqlStep(qQuery) ? SqlGetInt(qQuery, 0) : -1;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_strftime.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions for formatting times.
/// ----------------------------------------------------------------------------
/// @details This file contains an implementation of C's strftime() in nwscript.
///
/// # Formatting
///
/// You can format a Time using the `strftime()` function. This function takes
/// a Time as the first parameter (`t`) and a *format specification string*
/// (`sFormat`) as the second parameter. The format specification string may
/// contain special character sequences called *conversion specifications*, each
/// of which is introduced by the `%` character and terminated by some other
/// character known as a *conversion specifier character*. All other character
/// sequences are *ordinary character sequences*.
///
/// The characters of ordinary character sequences are copied verbatim from
/// `sFormat` to the returned value. However, the characters of conversion
/// specifications are replaced as shown in the list below. Some sequences may
/// have their output customized using a *locale*, which can be passed using the
/// third parameter of `strftime()` (`sLocale`).
///
/// Several aliases for `strftime()` exist. `FormatTime()`, `FormatDate()`, and
/// `FormatDateTime()` each take a calendar Time and will default to formatting
/// to a locale-specific representation of the time, date, or date and time
/// respectively. `FormatDuration()` takes a duration Time and defaults to
/// showing an ISO 8601 formatted datetime with a sign character before it.
///
/// ## Conversion Specifiers
/// - `%a`: The abbreviated name of the weekday according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_DAYS_ABBR`. If no abbreviated names are available in the
///         locale, will fall back to the full day name.
/// - `%A`: The full name of the weekday according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_DAYS`.
/// - `%b`: The abbreviated name of the month according to the current locale.
///         The specific names used in the current locale can be set using the
///         key `LOCALE_MONTHS_ABBR`. If no abbreviated names are available in
///         the locale, will fall back to the full month name.
/// - `%B`: The full name of the month according to the current locale. The
///         specific names used in the current locale can be set using the key
///         `LOCALE_MONTHS`.
/// - `%c`: The preferred date and time representation for the current locale.
///         The specific format used in the current locale can be set using the
///         key `LOCALE_DATETIME_FORMAT` for the `%c` conversion specification
///         and `ERA_DATETIME_FORMAT` for the `%Ec` conversion specification.
///         With the default settings, this is equivalent to `%Y-%m-%d
///         %H:%M:%S:%f`. This is the default value of `sFormat` for
///         `FormatDateTime()`.
/// - `%C`: The century number (year / 100) as a 2-or-3-digit integer (00..320).
///         (The `%EC` conversion specification corresponds to the name of the
///         era, which can be set using the era key `ERA_NAME`.)
/// - `%d`: The day of the month as a 2-digit decimal number (01..28).
/// - `%D`: Equivalent to `%m/%d/%y`, the standard US time format. Note that
///         this may be ambiguous and confusing for non-Americans.
/// - `%e`: The day of the month as a decimal number, but a leading zero is
///         replaced by a space. Equivalent to `%_d`.
/// - `%E`: Modifier: use alternative "era-based" format (see below).
/// - `%f`: The millisecond as a 3-digit decimal number (000..999).
/// - `%F`: Equivalent to `%Y-%m-%d`, the ISO 8601 date format.
/// - `%H`: The hour (24-hour clock) as a 2-digit decimal number (00..23).
/// - `%I`: The hour (12-hour clock) as a 2-digit decimal number (01..12).
/// - `%j`: The day of the year as a 3-digit decimal number (000..336).
/// - `%k`: The hour (24-hour clock) as a decimal number (0..23). Single digits
///         are preceded by a space. Equivalent to `%_H`.
/// - `%l`: The hour (12-hour clock) as a decimal number (1..12). Single digits
///         are preceded by a space. Equivalent to `%_I`.
/// - `%m`: The month as a 2-digit decimal number (01..12).
/// - `%M`: The minute as a 2-digit decimal number (00..59, depending on
///         `t.MinsPerHour`).
/// - `%O`: Modifier: use ordinal numbers (1st, 2nd, etc.) (see below).
/// - `%p`: Either "AM" or "PM" according to the given Time, or the
///         corresponding values from the locale. The specific word used can be
///         set for the current locale using the key `LOCALE_AMPM`.
/// - `%P`: Like `%p`, but lowercase. Yes, it's silly that it's not the other
///         way around.
/// - `%r`: The preferred AM/PM time representation for the current locale. The
///         specific format used in the current locale can be set using the key
///         `LOCALE_AMPM_FORMAT`. With the default settings, this is equivalent
///         to `%I:%M:%S %p`.
/// - `%R`: The time in 24-hour notation. Equivalent to `%H:%M`. For a version
///         including seconds, see `%T`.
/// - `%S`: The second as a 2-digit decimal number (00..59).
/// - `%T`: The time in 24-hour notation. Equivalent to `%H:%M:%S`. For a
///         version without seconds, see `%R`.
/// - `%u`: The day of the  week as a 1-indexed decimal (1..7).
/// - `%w`: The day of the week as a 0-indexed decimal (0..6).
/// - `%x`: The preferred date representation for the current locale without the
///         time. The specific format used in the current locale can be set
///         using the key `LOCALE_TIME_FORMAT` for the `%x` conversion
///         specification and `ERA_TIME_FORMAT` for the `%Ex` conversion
///         specification. With the default settings, this is equivalent to
///         `%Y-%m-%d`. This is the default value of `sFormat` for
///         `FomatDate()`.
/// - `%X`: The preferred time representation for the current locale without the
///         date. The specific format used in the current locale can be set
///         using the key `LOCALE_DATE_FORMAT` for the `%X` conversion
///         specification and `ERA_DATE_FORMAT` for the `%EX` conversion
///         specification. With the default settings, this is equivalent to
///         `%H:%M:%S`. This is the default value of `sFormat` for
///         `FormatTime()`.
/// - `%y`: The year as a 2-digit decimal number without the century (00..99).
///         (The `%Ey` conversion specification corresponds to the year since
///         the beginning of the era denoted by the `%EC` conversion
///         specification.)
/// - `%Y`: The year as a decimal number including the century (0000..32000).
///         (The `%EY` conversion specification corresponds to era key
///         `ERA_FORMAT`; with the default era settings, this is equivalent to
///         `%Ey %EC`.)
/// - `%%`: A literal `%` character.
///
/// ## Modifier Characters
/// Some conversion specifications can be modified by preceding the conversion
/// specifier character by the `E` or `O` *modifier* to indicate that an
/// alternative format should be used. If the alternative format does not exist
/// for the locale, the behavior will be as if the unmodified conversion
/// specification were used.
///
/// The `E` modifier signifies using an alternative era-based representation.
/// The following are valid: `%Ec`, `%EC`, `%Ex`, `%EX`, `%Ey`, and `%EY`.
///
/// The `O` modifier signifies representing numbers in ordinal form (e.g., 1st,
/// 2nd, etc.). The ordinal suffixes for each number can be set using the locale
/// key `LOCALE_ORDINAL_SUFFIXES`. The following are valid: `%Od`, `%Oe`, `%OH`,
/// `%OI`, `%Om`, `%OM`, `%OS`, `%Ou`, `%Ow`, `%Oy`, and `%OY`.
///
/// ## Flag Characters
/// Between the `%` character and the conversion specifier character, an
/// optional *flag* and *field width* may be specified. (These should precede
/// the `E` or `O` characters, if present).
///
/// The following flag characters are permitted:
/// - `_`: (underscore) Pad a numeric result string with spaces.
/// - `-`: (dash) Do not pad a numeric result string.
/// - `0`: Pad a numeric result string with zeroes even if the conversion
///        specifier character uses space-padding by default.
/// - `^`: Convert alphabetic characters in the result string to uppercase.
/// - `+`: Display a `-` before numeric values if the Time is negative, or a `+`
///        if the Time is positive or 0.
/// - `,`: Add comma separators for long numeric values.
///
/// An optional decimal width specifier may follow the (possibly absent) flag.
/// If the natural size of the field is smaller than this width, the result
/// string is padded (on the left) to the specified width. The string is never
/// truncated.
///
/// ## Examples
///
/// ```nwscript
/// struct Time t = StringToTime("1372-06-01 13:00:00:000");
///
/// // Default formatting
/// FormatDateTime(t); // "1372-06-01 13:00:00:000"
/// FormatDate(t); // "1372-06-01"
/// FormatTime(t); // "13:00:00:000"
///
/// // Using custom formats
/// FormatTime(t, "Today is %A, %B %Od."); // "Today is Monday, June 1st."
/// FormatTime(t, "%I:%M %p"); // "01:00 PM"
/// FormatTime(t, "%-I:%M %p"); // "1:00 PM"
/// ```
/// ----------------------------------------------------------------------------
/// # Advanced Usage
///
/// ## Locales
///
/// A locale is a json object that contains localization settings for formatting
/// functions. A default locale will be constructed using the configuration
/// values in `util_c_times.nss`, but you can also construct locales yourself.
/// An application for this might be having different areas in the module use
/// different month or day names, etc.
///
/// A locale is a simple json object:
/// ```nwscript
/// json jLocale = JsonObject();
/// ```
///
/// Alternatively, you can initialize a locale with the default values from
/// util_c_times:
/// ```nwscript
/// json jLocale = NewLocale();
/// ```
///
/// Keys are then added using `SetLocaleString()`:
/// ```nwscript
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, etc.");
/// ```
///
/// Keys can be retrieved using `GetLocaleString()`, which takes an optional
/// default value if the key is not set:
/// ```nwscript
/// string sDays     = GetLocaleString(jLocale, LOCALE_DAYS);
/// string sDaysAbbr = GetLocaleString(jLocale, LOCALE_DAYS_ABBR, sDays);
/// ```
///
/// Locales can be saved with a name. That names can then be passed to
/// formatting functions:
/// ```nwscript
/// json jLocale = JsonObject();
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
/// jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
/// SetLocale(jLocale, "ME");
/// FormatTime(t, "Today is %A, %B %Od.");       // "Today is Monday, June 1st
/// FormatTime(t, "Today is %A, %B %Od.", "ME"); // "Today is Moonday, Narie 1st
/// ```
///
/// You can change the default locale so that you don't have to pass the name
/// every time:
/// ```nwscript
/// SetDefaultLocale("ME");
/// FormatTime(t, "Today is %A, %B %Od."); // "Today is Moonday, Narie 1st
/// ```
///
/// The following keys are currently supported:
/// - `LOCALE_DAYS`: a CSV list of 7 weekday names. Accessed by `%A`.
/// - `LOCALE_DAYS_ABBR`: a CSV list of 7 abbreviated weekday names. If not set,
///    the `FormatTime()` function will use `LOCALE_DAYS` instead. Accessed by
///    `%a`.
/// - `LOCALE_MONTHS`: a CSV list of 12 month names. Accessed by `%B`.
/// - `LOCALE_MONTHS_ABBR`: a CSV list of 12 abbreviated month names. If not
///   set, the `FormatTime()` function will use `LOCALE_MONTHS` instead.
///   Accessed by `%b`.
/// - `LOCALE_AMPM`: a CSV list of 2 AM/PM elements. Accessed by `%p` and `%P`.
/// - `LOCALE_ORDINAL_SUFFIXES`: a CSV list of suffixes for constructing ordinal
///   numbers. See util_c_times's documentation of `DEFAULT_ORDINAL_SUFFIXES`
///   for details.
/// - `LOCALE_DATETIME_FORMAT`: a date and time format string. Aliased by `%c`.
/// - `LOCALE_DATE_FORMAT`: a date format string. Aliased by `%x`.
/// - `LOCALE_TIME_FORMAT`: a time format string. Aliased by `%X`.
/// - `LOCALE_AMPM_FORMAT`: a time format string using AM/PM form. Aliased
///   by `%r`.
/// - `ERA_DATETIME_FORMAT`: a format string to display the date and time. If
///   not set, will fall back to `LOCALE_DATETIME_FORMAT`. Aliased by `%Ec`.
/// - `ERA_DATE_FORMAT`: a format string to display the date without the time.
///   If not set, will fall back to `LOCALE_DATE_FORMAT`. Aliased by `%Ex`.
/// - `ERA_TIME_FORMAT`: a format string to display the time without the date.
///   If not set, will fall back to `LOCALE_TIME_FORMAT`. Aliased by `%EX`.
/// - `ERA_YEAR_FORMAT`: a format string to display the year. If not set, will
///   display the year. Aliased by `%EY`.
/// - `ERA_NAME`: the name of an era. If not set and no era matches the current
///   year, will display the century. Aliased by `%EC`.
///
/// ## Eras
/// Locales can also hold an array of eras. Eras are json objects which name a
/// time range. When formatting using the `%E` modifier, the start Times of each
/// era in the array are compared to the Time to be formatted; the era with the
/// latest start that is still before the Time is selected. Format codes can
/// then refer to the era's name, year relative to the era start, and other
/// era-specific formats.
///
/// An era can be created using `DefineEra()`. This function takes a name and a
/// start Time. See the documentation for `DefineEra()` for further info:
/// ```nwscript
/// // Create an era that begins at the first possible calendar time
/// json jFirst = DefineEra("First Age", GetTime());
///
/// // Create an era that begins on a particular year
/// json jSecond = DefineEra("Second Age", GetTime(590));
/// ```
///
/// The `{Get/Set}LocaleString()` functions also apply to eras:
/// ```nwscript
/// jSecond = SetLocaleString(jSecond, ERA_DATETIME_FORMAT, "%B %Od, %EY");
/// jSecond = SetLocaleString(jSecond, ERA_YEAR_FORMAT, "%EY 2E");
/// ```
///
/// You can add an era to a locale using `AddEra()`:
/// ```nwscript
/// json jLocale = GetLocale("ME");
/// jLocale = SetLocaleString(jLocale, LOCALE_DAYS, "Moonday, Treeday, Heavensday, Valarday, Shipday, Starday, Sunday");
/// jLocale = SetLocaleString(jLocale, LOCALE_MONTHS, "Narvinye, Nenime, Sulime, Varesse, Lotesse, Narie, Cermie, Urime, Yavannie, Narquelie, Hisime, Ringare");
/// jLocale = AddEra(jLocale, jFirst);
/// jLocale = AddEra(jLocale, jSecond);
/// SetLocale(jLocale, "ME");
/// ```
///
/// You can then access the era settings using the `%E` modifier:
/// ```nwscript
/// FormatTime(t, "Today is %A, %B %Od, %EY.", "ME"); // "Today is Moonday, Narie 1st, 783 2E."
///
/// // You can combine the `%E` and `%O` modifiers
/// FormatTime(t, "It is the %EOy year of the %EC.", "ME"); // "It is the 783rd year of the Second Age."
/// ```
///
/// The following keys are available to eras:
/// - `ERA_NAME`: the name of the era. Aliased by `%EC`.
/// - `ERA_DATETIME_FORMAT`: a format string to display the date and time. If
///   not set, will fall back to the value on the locale. Aliased by `%Ec`.
/// - `ERA_DATE_FORMAT`: a format string to display the date without the time.
///   If not set, will fall back to the value on the locale. Aliased by `%Ex`.
/// - `ERA_TIME_FORMAT`: a format string to display the time without the date.
///   If not set, will fall back to the value on the locale. Aliased by `%EX`.
/// - `ERA_YEAR_FORMAT`: a format string to display the year. Defaults to
///   `%Ey %EC`. If not set, will fall back to the value on the locale. Aliased
///   by `%EY`.
/// ----------------------------------------------------------------------------

#include "util_i_times"
#include "util_i_csvlists"
#include "util_c_strftime"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// These are the characters used as flags in time format codes.
const string TIME_FLAG_CHARS = "EO^,+-_0123456789";

const int TIME_FLAG_ERA       = 0x01; ///< `E`: use era-based formatting
const int TIME_FLAG_ORDINAL   = 0x02; ///< `O`: use ordinal numbers
const int TIME_FLAG_UPPERCASE = 0x04; ///< `^`: use uppercase letters
const int TIME_FLAG_COMMAS    = 0x08; ///< `,`: add comma separators
const int TIME_FLAG_SIGN      = 0x10; ///< `+`: prefix with sign character
const int TIME_FLAG_NO_PAD    = 0x20; ///< `-`: do not pad numbers
const int TIME_FLAG_SPACE_PAD = 0x40; ///< `_`: pad numbers with spaces
const int TIME_FLAG_ZERO_PAD  = 0x80; ///< `0`: pad numbers with zeros

// These are the characters allowed in time format codes.
const string TIME_FORMAT_CHARS = "aAbBpPIljwuCyYmdeHkMSfDFRTcxXr%";

// Begin time-only constants. It is an error to use these with a duration.
const int TIME_FORMAT_NAME_OF_DAY_ABBR   =  0; ///< `%a`: Mon..Sun
const int TIME_FORMAT_NAME_OF_DAY_LONG   =  1; ///< `%A`: Monday..Sunday
const int TIME_FORMAT_NAME_OF_MONTH_ABBR =  2; ///< `%b`: Jan..Dec
const int TIME_FORMAT_NAME_OF_MONTH_LONG =  3; ///< `%B`: January..December
const int TIME_FORMAT_AMPM_UPPER         =  4; ///< `%p`: AM..PM
const int TIME_FORMAT_AMPM_LOWER         =  5; ///< `%P`: am..pm
const int TIME_FORMAT_HOUR_12            =  6; ///< `%I`: 01..12
const int TIME_FORMAT_HOUR_12_SPACE_PAD  =  7; ///< `%l`: alias for %_I
const int TIME_FORMAT_DAY_OF_YEAR        =  8; ///< `%j`: 001..336
const int TIME_FORMAT_DAY_OF_WEEK_0_6    =  9; ///< `%w`: weekdays 0..6
const int TIME_FORMAT_DAY_OF_WEEK_1_7    = 10; ///< `%u`: weekdays 1..7
const int TIME_FORMAT_YEAR_CENTURY       = 11; ///< `%C`: 0..320
const int TIME_FORMAT_YEAR_SHORT         = 12; ///< `%y`: 00..99
const int TIME_FORMAT_YEAR_LONG          = 13; ///< `%Y`: 0..320000
const int TIME_FORMAT_MONTH              = 14; ///< `%m`: 01..12
const int TIME_FORMAT_DAY                = 15; ///< `%d`: 01..28
const int TIME_FORMAT_DAY_SPACE_PAD      = 16; ///< `%e`: alias for %_d
const int TIME_FORMAT_HOUR_24            = 17; ///< `%H`: 00..23
const int TIME_FORMAT_HOUR_24_SPACE_PAD  = 18; ///< `%k`: alias for %_H
const int TIME_FORMAT_MINUTE             = 19; ///< `%M`: 00..59 (depending on conversion factor)
const int TIME_FORMAT_SECOND             = 20; ///< `%S`: 00..59
const int TIME_FORMAT_MILLISECOND        = 21; ///< `%f`: 000...999
const int TIME_FORMAT_DATE_US            = 22; ///< `%D`: 06/01/72
const int TIME_FORMAT_DATE_ISO           = 23; ///< `%F`: 1372-06-01
const int TIME_FORMAT_TIME_US            = 24; ///< `%R`: 13:00
const int TIME_FORMAT_TIME_ISO           = 25; ///< `%T`: 13:00:00
const int TIME_FORMAT_LOCALE_DATETIME    = 26; ///< `%c`: locale-specific date and time
const int TIME_FORMAT_LOCALE_DATE        = 27; ///< `%x`: locale-specific date
const int TIME_FORMAT_LOCALE_TIME        = 28; ///< `%X`: locale-specific time
const int TIME_FORMAT_LOCALE_TIME_AMPM   = 29; ///< `%r`: locale-specific AM/PM time
const int TIME_FORMAT_PERCENT            = 30; ///< `%%`: %

// Time format codes with an index less than this number are not valid for
// durations.
const int DURATION_FORMAT_OFFSET = TIME_FORMAT_YEAR_CENTURY;

// ----- VarNames --------------------------------------------------------------

// Prefix for locale names stored on the module to avoid collision
const string LOCALE_PREFIX = "*Locale: ";

// Stores the default locale on the module
const string LOCALE_DEFAULT = "*DefaultLocale";

// Each of these keys stores a CSV list which is evaluated by a format code
const string LOCALE_DAYS        = "Days";       // day names (%A)
const string LOCALE_DAYS_ABBR   = "DaysAbbr";   // abbreviated day names (%a)
const string LOCALE_MONTHS      = "Months";     // month names (%B)
const string LOCALE_MONTHS_ABBR = "MonthsAbbr"; // abbreviated month names (%b)
const string LOCALE_AMPM        = "AMPM";       // AM/PM elements (%p and %P)

// This key stores a CSV list of suffixes used to convert integers to ordinals
// (e.g., 0th, 1st, etc.).
const string LOCALE_ORDINAL_SUFFIXES = "OrdinalSuffixes"; // %On

// Each of these keys stores a locale-specific format string which is aliased by
// a format code.
const string LOCALE_DATETIME_FORMAT  = "DateTimeFormat"; // %c
const string LOCALE_DATE_FORMAT      = "DateFormat";     // %x
const string LOCALE_TIME_FORMAT      = "TimeFormat";     // %X
const string LOCALE_AMPM_FORMAT      = "AMPMFormat";     // %r

// Each of these keys stores a locale-specific era-based format string which is
// aliased by a format code using the `E` modifier. If no string is stored at
// this key, it will resolve to the non-era based format above.
const string ERA_DATETIME_FORMAT = "EraDateTimeFormat"; // %Ec
const string ERA_DATE_FORMAT     = "EraDateFormat";     // %Ex
const string ERA_TIME_FORMAT     = "EraTimeFormat";     // %EX

// Key for Eras json array. Each element of the array is a json object having
// the three keys below.
const string LOCALE_ERAS = "Eras";

// Key for era name. Aliased by %EC.
const string ERA_NAME = "Name";

// Key for a format string for the year in the era. Aliased by %EY.
const string ERA_YEAR_FORMAT = "YearFormat";

// Key for the start of the era. Stored as a date in the form yyyy-mm-dd.
const string ERA_START = "Start";

// Key for the number of the year closest to the start date in an era. Used by
// %Ey to display the correct year. For example, if an era starts on 1372-01-01
// and the current date is 1372-06-01, an offset of 0 would make %Ey display 0,
// while an offset of 1 would make it display 1.
const string ERA_OFFSET = "Offset";


// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// ----- Locales ---------------------------------------------------------------

/// @brief Get the string at a given key in a locale object.
/// @param jLocale A json object containing the locale settings
/// @param sKey The key to return the value of (see the LOCALE_* constants)
/// @param sDefault A default value to return if sKey does not exist in jLocale.
string GetLocaleString(json jLocale, string sKey, string sSuffix = "");

/// @brief Set the string at a given key in a locale object.
/// @param jLocale A json object containing the locale settings
/// @param sKey The key to set the value of (see the LOCALE_* constants)
/// @param sValue The value to set the key to
/// @returns The updated locale object
json SetLocaleString(json j, string sKey, string sValue);

/// @brief Create a new locale object initialized with values from util_c_times.
/// @note If you do not want the default values, use JsonObject() instead.
json NewLocale();

/// @brief Get the name of the default locale for the module.
/// @returns The name of the default locale, or the value of DEFAULT_LOCALE from
///     util_c_times.nss if a locale is not set.
string GetDefaultLocale();

/// @brief Set the name of the default locale for the module.
/// @param sName The name of the locale (default: DEFAULT_LOCALE)
void SetDefaultLocale(string sName = DEFAULT_LOCALE);

/// @brief Get a locale object by name.
/// @param sLocale The name of the locale. Will return the default locale if "".
/// @param bInit If TRUE, will return an era with the default values from
///     util_c_times.nss if sLocale does not exist.
/// @returns A json object containing the locale settings, or JsonNull() if no
///     locale named sLocale exists.
json GetLocale(string sLocale = "", int bInit = TRUE);

/// @brief Save a locale object to a name.
/// @param jLocale A json object containing the locale settings.
/// @param sLocale The name of the locale. Will use the default local if "".
void SetLocale(json jLocale, string sLocale = "");

/// @brief Delete a locale by name.
/// @param sLocale The name of the locale. Will use the default local if "".
void DeleteLocale(string sLocale = "");

/// @brief Check if a locale exists.
/// @param sLocale The name of the locale. Will use the default local if "".
/// @returns TRUE if sLocale points to a valid json object, other FALSE.
int HasLocale(string sLocale = "");

/// @brief Get the name of a month given a locale.
/// @param nMonth The month of the year (1-indexed).
/// @param sMonths A CSV list of 12 month names to search through. If "", will
///     use the month list from a locale.
/// @param sLocale The name of a locale to check for month names if sMonths is
///     "". If sLocale is "", will use the default locale.
/// @returns The name of the month.
string MonthToString(int nMonth, string sMonths = "", string sLocale = "");

/// @brief Get the name of a day given a locale.
/// @param nDay The day of the week (1-indexed).
/// @param sDays A CSV list of 7 day names to search through. If "", will use
///     the day list from a locale.
/// @param sLocale The name of a locale to check for day names if sDays is "".
///     If sLocale is "", will use the default locale.
/// @returns The name of the day.
string DayToString(int nDay, string sDays = "", string sLocale = "");

// ----- Eras ------------------------------------------------------------------

/// @brief Create an era json object.
/// @param sName The name of the era.
/// @param tStart The Time marking the beginning of the era.
/// @param nOffset The number that represents the first year in an era. Used by
///     %Ey to display the correct year. For example, if an era starts on
///     1372-01-01 and the current date is 1372-06-01, an offset of 0 would make
///     %Ey display 0 while an offset of 1 would make %Ey display 1. The default
///     is 0 since NWN allows year 0.
/// @param sFormat The default format for an era-based year. The format code %EY
///     evaluates to this string for this era. With the default value, the 42nd
///     year of an era named "Foo" would be "4 Foo".
json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = "%Ey %EC");

/// @brief Add an era to a locale.
/// @param jLocale A locale json object.
/// @param jEra An era json object.
/// @returns A modified copy of jLocale with jEra added to its era array.
json AddEra(json jLocale, json jEra);

/// @brief Get the era in which a time occurs.
/// @param jLocale A locale json object containing an array of eras.
/// @param t A Time to check the era for.
/// @returns A json object for the era in jLocale with the latest start time
///     earlier than t or JsonNull() if no such era is present.
json GetEra(json jLocale, struct Time t);

/// @brief Get the year of an era given an NWN calendar year.
/// @param jEra A json object matching an era.
/// @param nYear An NWN calendar year (0..32000)
/// @returns The number of the year in the era, or nYear if jEra is not valid.
int GetEraYear(json jEra, int nYear);

/// @brief Gets a string from an era, falling back to a locale if not set.
/// @param jEra The era to check
/// @param jLocale The locale to fall back to
/// @param sKey The key to get the string from
/// @note If sKey begins with "Era" and was not found on the era or the locale,
///     will check jLocale for sKey without the "Era" prefix.
string GetEraString(json jEra, json jLocale, string sKey);

// ----- Formatting ------------------------------------------------------------

/// @brief Convert an integer into an ordinal number (e.g., 1 -> 1st, 2 -> 2nd).
/// @param n The number to convert.
/// @param sSuffixes A CSV list of suffixes for each integer, starting at 0. If
///     the n <= the length of the list, only the last digit will be checked. If
///     "", will use the suffixes provided by the locale instead.
/// @param sLocale The name of the locale to use when formatting the number. If
///     "", will use the default locale.
string IntToOrdinalString(int n, string sSuffixes = "", string sLocale = "");

/// @brief Format a Time into a string.
/// @param t A calendar or duration Time to format. No conversion is performed.
/// @param sFormat A string containing format codes to control the output.
/// @param sLocale The name of the locale to use when formatting the time. If
///     "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string strftime(struct Time t, string sFormat, string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%H:%M:%S".
/// @param sLocale The name of the locale to use when formatting the time. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d".
/// @param sLocale The name of the locale to use when formatting the date. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "");

/// @brief Format a calendar Time into a string.
/// @param t A calendar Time to format. If not a calendar Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to "%Y-%m-%d %H:%M:%S:%f".
/// @param sLocale The name of the locale to use when formatting the Time. If
///     "", will use the default locale.
/// @note This function differs only from FormatTime() in the default value of
///     sFormat. Character codes that apply to calendar Times are still valid.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "");

/// @brief Format a duration Time into a string.
/// @param t The duration Time to format. If not a duration Time, will be
///     converted into one.
/// @param sFormat A string containing format codes to control the output. The
///     default value is equivalent to ISO 8601 format preceded by the sign of
///     t (`-` if negative, `+` otherwise).
/// @param sLocale The name of the locale to use when formatting the duration.
///     If "", will use the default locale.
/// @note See the documentation at the top of this file for the list of possible
///     format codes.
string FormatDuration(struct Time t, string sFormat = "%+Y-%m-%d %H:%M:%S:%f", string sLocale = "");

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

// ----- Locales ---------------------------------------------------------------

string GetLocaleString(json jLocale, string sKey, string sDefault = "")
{
    json jElem = JsonObjectGet(jLocale, sKey);
    if (JsonGetType(jElem) == JSON_TYPE_STRING && JsonGetString(jElem) != "")
        return JsonGetString(jElem);
    return sDefault;
}

json SetLocaleString(json j, string sKey, string sValue)
{
    return JsonObjectSet(j, sKey, JsonString(sValue));
}

json NewLocale()
{
    json j = JsonObject();
    j = SetLocaleString(j, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    j = SetLocaleString(j, LOCALE_DAYS,             DEFAULT_DAYS);
    j = SetLocaleString(j, LOCALE_DAYS_ABBR,        DEFAULT_DAYS_ABBR);
    j = SetLocaleString(j, LOCALE_MONTHS,           DEFAULT_MONTHS);
    j = SetLocaleString(j, LOCALE_MONTHS_ABBR,      DEFAULT_MONTHS_ABBR);
    j = SetLocaleString(j, LOCALE_AMPM,             DEFAULT_AMPM);
    j = SetLocaleString(j, LOCALE_DATETIME_FORMAT,  DEFAULT_DATETIME_FORMAT);
    j = SetLocaleString(j, LOCALE_DATE_FORMAT,      DEFAULT_DATE_FORMAT);
    j = SetLocaleString(j, LOCALE_TIME_FORMAT,      DEFAULT_TIME_FORMAT);
    j = SetLocaleString(j, LOCALE_AMPM_FORMAT,      DEFAULT_AMPM_FORMAT);

    if (DEFAULT_ERA_DATETIME_FORMAT != "")
        j = SetLocaleString(j, ERA_DATETIME_FORMAT, DEFAULT_ERA_DATETIME_FORMAT);

    if (DEFAULT_ERA_DATE_FORMAT != "")
        j = SetLocaleString(j, ERA_DATE_FORMAT, DEFAULT_ERA_DATE_FORMAT);

    if (DEFAULT_ERA_TIME_FORMAT != "")
        j = SetLocaleString(j, ERA_TIME_FORMAT, DEFAULT_ERA_TIME_FORMAT);

    if (DEFAULT_ERA_NAME != "")
        j = SetLocaleString(j, ERA_NAME, DEFAULT_ERA_NAME);

    return JsonObjectSet(j, LOCALE_ERAS, JsonArray());
}

string GetDefaultLocale()
{
    string sLocale = GetLocalString(GetModule(), LOCALE_DEFAULT);
    return sLocale == "" ? DEFAULT_LOCALE : sLocale;
}

void SetDefaultLocale(string sName = DEFAULT_LOCALE)
{
    SetLocalString(GetModule(), LOCALE_DEFAULT, sName);
}

json GetLocale(string sLocale = "", int bInit = TRUE)
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    json j = GetLocalJson(GetModule(), LOCALE_PREFIX + sLocale);
    if (bInit && JsonGetType(j) != JSON_TYPE_OBJECT)
        j = NewLocale();
    return j;
}

void SetLocale(json jLocale, string sLocale = "")
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    SetLocalJson(GetModule(), LOCALE_PREFIX + sLocale, jLocale);
}

void DeleteLocale(string sLocale = "")
{
    if (sLocale == "")
        sLocale = GetDefaultLocale();
    DeleteLocalJson(GetModule(), LOCALE_PREFIX + sLocale);
}

int HasLocale(string sLocale = "")
{
    return JsonGetType(GetLocale(sLocale, FALSE)) == JSON_TYPE_OBJECT;
}

string MonthToString(int nMonth, string sMonths = "", string sLocale = "")
{
    if (sMonths == "")
        sMonths = GetLocaleString(GetLocale(sLocale), LOCALE_MONTHS);

    return GetListItem(sMonths, (nMonth - 1) % 12);
}

string DayToString(int nDay, string sDays = "", string sLocale = "")
{
    if (sDays == "")
        sDays = GetLocaleString(GetLocale(sLocale), LOCALE_DAYS);

    return GetListItem(sDays, (nDay - 1) % 7);
}

// ----- Eras ------------------------------------------------------------------

json DefineEra(string sName, struct Time tStart, int nOffset = 0, string sFormat = DEFAULT_ERA_YEAR_FORMAT)
{
    json jEra = JsonObject();
    jEra = JsonObjectSet(jEra, ERA_NAME,        JsonString(sName));
    jEra = JsonObjectSet(jEra, ERA_YEAR_FORMAT, JsonString(sFormat));
    jEra = JsonObjectSet(jEra, ERA_START,       TimeToJson(tStart));
    return JsonObjectSet(jEra, ERA_OFFSET,      JsonInt(nOffset));
}

json AddEra(json jLocale, json jEra)
{
    json jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    if (JsonGetType(jEras) != JSON_TYPE_ARRAY)
        jEras = JsonArray();

    jEras = JsonArrayInsert(jEras, jEra);
    return JsonObjectSet(jLocale, LOCALE_ERAS, jEras);
}

json GetEra(json jLocale, struct Time t)
{
    if (t.Type == TIME_TYPE_DURATION)
        return JsonNull();

    json  jEras = JsonObjectGet(jLocale, LOCALE_ERAS);
    json  jEra; // The closest era to the Time
    struct Time tEra; // The start Time of jEra
    int i, nLength = JsonGetLength(jEras);

    for (i = 0; i < nLength; i++)
    {
        json jCmp = JsonArrayGet(jEras, i);
        struct Time tCmp = JsonToTime(JsonObjectGet(jCmp, ERA_START));
        switch (CompareTime(t, tCmp))
        {
            case 0: return jCmp;
            case 1:
            {
                if (CompareTime(tCmp, tEra) >= 0)
                {
                    tEra = tCmp;
                    jEra = jCmp;
                }
            }
        }
    }

    return jEra;
}

int GetEraYear(json jEra, int nYear)
{
    int nOffset = JsonGetInt(JsonObjectGet(jEra, ERA_OFFSET));
    struct Time tStart = JsonToTime(JsonObjectGet(jEra, ERA_START));
    return nYear - tStart.Year + nOffset;
}

string GetEraString(json jEra, json jLocale, string sKey)
{
    json jValue = JsonObjectGet(jEra, sKey);
    if (JsonGetType(jValue) != JSON_TYPE_STRING)
    {
        jValue = JsonObjectGet(jLocale, sKey);
        if (JsonGetType(jValue) != JSON_TYPE_STRING &&
           (GetStringSlice(sKey, 0, 2) == "Era"))
            jValue = JsonObjectGet(jLocale, GetStringSlice(sKey, 3));
    }

    return JsonGetString(jValue);
}

// ----- Formatting ------------------------------------------------------------

string IntToOrdinalString(int n, string sSuffixes = "", string sLocale = "")
{
    if (sSuffixes == "")
    {
        json jLocale = GetLocale(sLocale);
        sSuffixes = GetLocaleString(jLocale, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    }

    int nIndex = abs(n) % 100;
    if (nIndex >= CountList(sSuffixes))
        nIndex = abs(n) % 10;

    return IntToString(n) + GetListItem(sSuffixes, nIndex);
}

string strftime(struct Time t, string sFormat, string sLocale)
{
    int  nOffset, nPos;
    int  nSign   = GetTimeSign(t);
    json jValues = JsonArray();
    json jLocale = GetLocale(sLocale);
    json jEra    = GetEra(jLocale, t);
    string sOrdinals = GetLocaleString(jLocale, LOCALE_ORDINAL_SUFFIXES, DEFAULT_ORDINAL_SUFFIXES);
    int nDigitsIndex = log2(TIME_FLAG_ZERO_PAD);

    while ((nPos = FindSubString(sFormat, "%", nOffset)) != -1)
    {
        nOffset = nPos;

        // Check for flags
        int nFlag, nFlags;
        string sPadding, sWidth, sChar;

        while ((nFlag = FindSubString(TIME_FLAG_CHARS, (sChar = GetChar(sFormat, ++nPos)))) != -1)
        {
            // If this character is not a digit after 0, we create a flag for it
            // and add it to our list of flags.
            if (nFlag < nDigitsIndex)
                nFlags |= (1 << nFlag);
            else
            {
                // The user has specified a width for the item. Parse all the
                // numbers.
                sWidth = ""; // in case the user added a width twice and separated with another flag.
                while (GetIsNumeric(sChar))
                {
                    sWidth += sChar;
                    sChar = GetChar(sFormat, ++nPos);
                }

                nPos--;
            }
        }

        string sValue;
        int nValue;
        int bAllowEmpty;
        int nPadding = 2; // Most numeric formats use this

        // We offset where we start looking for format codes based on whether
        // this is a calendar Time or duration Time. Durations cannot use time
        // codes that only make sense in the context of a calendar Time.
        int nFormat = FindSubString(TIME_FORMAT_CHARS, sChar, t.Type ? 0 : DURATION_FORMAT_OFFSET);
        switch (nFormat)
        {
            case -1:
            {
                string sError = GetStringSlice(sFormat, nOffset, nPos);
                string sColored = GetStringSlice(sFormat, 0, nOffset - 1) +
                                  HexColorString(sError, COLOR_RED) +
                                  GetStringSlice(sFormat, nPos + 1);
                Error("Illegal time format \"" + sError + "\": " + sColored);
                sFormat = ReplaceSubString(sFormat, "%" + sError, nOffset, nPos);
                continue;
            }

            // Note that some of these are meant to fall through
            case TIME_FORMAT_DAY_SPACE_PAD: // %e
                sPadding = " ";
            case TIME_FORMAT_DAY: // %d
                nValue = t.Day;
                break;
            case TIME_FORMAT_HOUR_24_SPACE_PAD: // %H
                sPadding = " ";
            case TIME_FORMAT_HOUR_24: // %H
                nValue = t.Hour;
                break;
            case TIME_FORMAT_HOUR_12_SPACE_PAD: // %l
                sPadding = " ";
            case TIME_FORMAT_HOUR_12: // %I
                nValue = t.Hour > 12 ? t.Hour % 12 : t.Hour;
                nValue = nValue ? nValue : 12;
                break;
            case TIME_FORMAT_MONTH: // %m
                nValue = t.Month;
                break;
            case TIME_FORMAT_MINUTE: // %M
                nValue = t.Minute;
                break;
            case TIME_FORMAT_SECOND: // %S
                nValue = t.Second;
                break;
            case TIME_FORMAT_MILLISECOND: // %f
                nValue = t.Millisecond;
                nPadding = 3;
                break;
            case TIME_FORMAT_DAY_OF_YEAR: // %j
                nValue = t.Month * 28 + t.Day;
                nPadding = 3;
                break;
            case TIME_FORMAT_DAY_OF_WEEK_0_6: // %w
                nValue = t.Day % 7;
                nPadding = 1;
                break;
            case TIME_FORMAT_DAY_OF_WEEK_1_7: // %u
                nValue = (t.Day % 7) + 1;
                nPadding = 1;
                break;
            case TIME_FORMAT_AMPM_UPPER: // %p
            case TIME_FORMAT_AMPM_LOWER: // %P
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_AMPM);
                sValue = GetListItem(sValue, t.Hour % 24 >= 12);
                if (nFormat == TIME_FORMAT_AMPM_LOWER)
                    sValue = GetStringLowerCase(sValue);
                break;
            case TIME_FORMAT_NAME_OF_DAY_LONG: // %A
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_DAYS);
                sValue = DayToString(t.Day, sValue);
                break;
            case TIME_FORMAT_NAME_OF_DAY_ABBR: // %a
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_DAYS);
                sValue = GetLocaleString(jLocale, LOCALE_DAYS_ABBR, sValue);
                sValue = DayToString(t.Day, sValue);
                break;
            case TIME_FORMAT_NAME_OF_MONTH_LONG: // %B
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS);
                sValue = MonthToString(t.Month, sValue);
                break;
            case TIME_FORMAT_NAME_OF_MONTH_ABBR: // %b
                bAllowEmpty = TRUE;
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS);
                sValue = GetLocaleString(jLocale, LOCALE_MONTHS_ABBR, sValue);
                sValue = MonthToString(t.Month, sValue);
                break;

            // We handle literal % here instead of replacing it directly because
            // we want the user to be able to pad it if desired.
            case TIME_FORMAT_PERCENT: // %%
                sValue = "%";
                break;

            case TIME_FORMAT_YEAR_CENTURY: // %C, %EC
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_NAME);
                nValue = t.Year / 100;
                break;
            case TIME_FORMAT_YEAR_SHORT: // %y, %Ey
                nValue = (nFlags & TIME_FLAG_ERA) ? GetEraYear(jEra, t.Year) : t.Year % 100;
                break;

            case TIME_FORMAT_YEAR_LONG: // %Y, %EY
                if (nFlags & TIME_FLAG_ERA)
                {
                    sValue = GetEraString(jEra, jLocale, ERA_YEAR_FORMAT);
                    if (sValue != "")
                    {
                        sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                        continue;
                    }
                }

                nValue = t.Year;
                nPadding = 4;
                break;

            // These codes are shortcuts to common operations. We replace the
            // parsed code with the substitution and re-parse from the same
            // offset.
            case TIME_FORMAT_DATE_US: // %D
                sFormat = ReplaceSubString(sFormat, "%m/%d/%y", nOffset, nPos);
                continue;
            case TIME_FORMAT_DATE_ISO: // %F
                sFormat = ReplaceSubString(sFormat, "%Y-%m-%d", nOffset, nPos);
                continue;
            case TIME_FORMAT_TIME_US: // %R
                sFormat = ReplaceSubString(sFormat, "%H:%M", nOffset, nPos);
                continue;
            case TIME_FORMAT_TIME_ISO: // %T
                sFormat = ReplaceSubString(sFormat, "%H:%M:%S", nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_DATETIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATETIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATETIME_FORMAT, DEFAULT_DATETIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_DATE: // %x, %Ex
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_DATE_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_DATE_FORMAT, DEFAULT_DATE_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_TIME: // %c, %Ec
                if (nFlags & TIME_FLAG_ERA)
                    sValue = GetEraString(jEra, jLocale, ERA_TIME_FORMAT);
                else
                    sValue = GetLocaleString(jLocale, LOCALE_TIME_FORMAT, DEFAULT_TIME_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
            case TIME_FORMAT_LOCALE_TIME_AMPM: // %r
                sValue = GetLocaleString(jLocale, LOCALE_AMPM_FORMAT, DEFAULT_AMPM_FORMAT);
                sFormat = ReplaceSubString(sFormat, sValue, nOffset, nPos);
                continue;
        }

        if ((sValue == "" && !bAllowEmpty) && (nFlags & TIME_FLAG_ORDINAL))
            sValue = IntToOrdinalString(nValue, sOrdinals);

        if (nFlags & TIME_FLAG_NO_PAD)
            sPadding = "";
        else if (sValue != "" || bAllowEmpty)
            sPadding = " " + sWidth;
        else
        {
            if (nFlags & TIME_FLAG_SPACE_PAD)
                sPadding = " ";
            else if (nFlags & TIME_FLAG_ZERO_PAD || sPadding == "")
                sPadding = "0";

            sPadding += sWidth != "" ? sWidth : IntToString(nPadding);
        }

        if (sValue != "" || bAllowEmpty)
        {
            if (nFlags & TIME_FLAG_UPPERCASE)
                sValue = GetStringUpperCase(sValue);
            jValues = JsonArrayInsert(jValues, JsonString(sValue));
            sFormat = ReplaceSubString(sFormat, "%" + sPadding + "s", nOffset, nPos);
        }
        else
        {
            if (nFlags & TIME_FLAG_SIGN)
                sValue = nSign < 0 ? "-" : "+";

            if (nFlags & TIME_FLAG_COMMAS)
                sPadding = "," + sPadding;

            jValues = JsonArrayInsert(jValues, JsonInt(abs(nValue)));
            sFormat = ReplaceSubString(sFormat, sValue + "%" + sPadding + "d", nOffset, nPos);
        }

        // Continue parsing from the end of the format string
        nOffset = nPos + GetStringLength(sPadding);
    }

    // Interpolate the values
    return FormatValues(jValues, sFormat);
}

string FormatTime(struct Time t, string sFormat = "%X", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDate(struct Time t, string sFormat = "%x", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDateTime(struct Time t, string sFormat = "%c", string sLocale = "")
{
    return strftime(DurationToTime(t), sFormat, sLocale);
}

string FormatDuration(struct Time t, string sFormat = "%+Y-%m-%d %H:%M:%S:%f", string sLocale = "")
{
    return strftime(TimeToDuration(t), sFormat, sLocale);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_strings.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating strings.
/// ----------------------------------------------------------------------------
/// @details This file holds utility functions for manipulating strings.
/// ----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string CHARSET_NUMERIC     = "0123456789";
const string CHARSET_ALPHA       = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
const string CHARSET_ALPHA_LOWER = "abcdefghijklmnopqrstuvwxyz";
const string CHARSET_ALPHA_UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Return the number of occurrences of a substring within a string.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
int GetSubStringCount(string sString, string sSubString);

/// @brief Return the position of a given occurrence of a substring within a
///     string.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
/// @param nNth The occurrence to search for. Uses a zero-based index.
/// @returns The position of the start of the nNth occurrence of the substring,
///     or -1 if the substring did not occur at least nNth + 1 times.
int FindSubStringN(string sString, string sSubString, int nNth = 0);

/// @brief Return the character at a position in a string.
/// @param sString The string to search.
/// @param nPos The position to check.
/// @returns "" if sString is not nPos + 1 characters long.
string GetChar(string sString, int nPos);

/// @brief Return the substring of a string bounded by a start and end position.
/// @param sString The string to search.
/// @param nStart The starting position of the substring to return.
/// @param nEnd The ending position of the substring to return. If -1, will
///     return to the end of the string.
/// @returns "" if nStart is not at least nStart + 1 characters long or if nEnd
///     is < nStart and not -1.
/// @note Both nStart and nEnd are inclusive, so if nStart == nEnd, the
///     character at that index will be returned.
string GetStringSlice(string sString, int nStart, int nEnd = -1);

/// @brief Replace the substring bounded by a string slice with another string.
/// @param sString The string to search.
/// @param sSub The substring to replace with.
/// @param nStart The starting position in sString of the substring to replace.
/// @param nEnd The ending position in sString of the substring to replace.
string ReplaceSubString(string sString, string sSub, int nStart, int nEnd);

/// @brief Replace a substring in a string with another string.
/// @param sString The string to search.
/// @param sToken The substring to search for.
/// @param sSub The substring to replace with.
string SubstituteSubString(string sString, string sToken, string sSub);

/// @brief Replace all substrings in a string with another string.
/// @param sString The string to search.
/// @param sToken The substring to search for.
/// @param sSub The substring to replace with.
string SubstituteSubStrings(string sString, string sToken, string sSub);

/// @brief Return whether a string contains a substring.
/// @param sString The string to search.
/// @param sSubString The substring to search for.
/// @param nStart The position in sString to begin searching from (0-based).
/// @returns TRUE if sSubString is in sString, FALSE otherwise.
int HasSubString(string sString, string sSubString, int nStart = 0);

/// @brief Return whether any of a string's characters are in a character set.
/// @param sString The string to search.
/// @param sSet The set of characters to search for.
/// @returns TRUE if any characters are in the set; FALSE otherwise.
int GetAnyCharsInSet(string sString, string sSet);

/// @brief Return whether all of a string's characters are in a character set.
/// @param sString The string to search.
/// @param sSet The set of characters to search for.
/// @returns TRUE if all characters are in the set; FALSE otherwise.
int GetAllCharsInSet(string sString, string sSet);

/// @brief Return whether all letters in a string are upper-case.
/// @param sString The string to check.
int GetIsUpperCase(string sString);

/// @brief Return whether all letters in a string are lower-case.
/// @param sString The string to check.
int GetIsLowerCase(string sString);

/// @brief Return whether all characters in sString are letters.
/// @param sString The string to check.
int GetIsAlpha(string sString);

/// @brief Return whether all characters in sString are digits.
/// @param sString The string to check.
int GetIsNumeric(string sString);

/// @brief Return whether all characters in sString are letters or digits.
/// @param sString The string to check.
int GetIsAlphaNumeric(string sString);

/// @brief Trim characters from the left side of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimStringLeft(string sString, string sRemove = " ");

/// @brief Trim characters from the right side of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimStringRight(string sString, string sRemove = " ");

/// @brief Trim characters from both sides of a string.
/// @param sString The string to trim.
/// @param sRemove The set of characters to remove.
string TrimString(string sString, string sRemove = " ");

/// @brief Interpolate values from a json array into a string using sqlite's
///     printf().
/// @param jArray A json array containing float, int, or string elements to
///     interpolate. The number of elements must match the number of format
///     specifiers in sFormat.
/// @param sFormat The string to interpolate the values into. Must contain
///     format specifiers that correspond to the elements in jArray. For details
///     on format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatValues(JsonParse("[\"Blue\", 255]"), "%s: #%06X"); // "Blue: #0000FF"
string FormatValues(json jArray, string sFormat);

/// @brief Interpolate a float into a string using sqlite's printf().
/// @param f A float to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatFloat(15.0, "%d"); // "15"
///   FormatFloat(15.0, "%.2f"); // "15.00"
///   FormatFloat(15.0, "%05.1f"); // "015.0"
string FormatFloat(float f, string sFormat);

/// @brief Interpolate an int into a string using sqlite's printf().
/// @param n An int to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatInt(15, "%d"); // "15"
///   FormatInt(15, "%04d"); // "0015"
///   FormatInt(15, "In hexadecimal, %d is %#x"); // "In hexadecimal, 15 is 0xf"
///   FormatInt(1000, "%,d"); // "1,000"
string FormatInt(int n, string sFormat);

/// @brief Interpolate a string into another string using sqlite's printf().
/// @param s A string to interpolate. Will be passed as an argument to the query
///     as many times as necessary to cover all format specifiers.
/// @param sFormat The string to interpolate the value into. For details on
///     format specifiers, see https://sqlite.org/printf.html.
/// @example
///   FormatString("foo", "%sbar"); // "foobar"
///   FormatString("foo", "%5sbar"); // "  foobar"
///   FormatString("foo", "%-5sbar"); // "foo  bar"
string FormatString(string s, string sFormat);

/// @brief Substitute tokens in a string with values from a json array.
/// @param s The string to interpolate the values into. Should have tokens wich
///     contain sDesignator followed by a number denoting the position of the
///     value in jArray (1-based index).
/// @param jArray An array of values to interpolate. May be any combination of
///     strings, floats, decimals, or booleans.
/// @param sDesignator The character denoting the beginning of a token.
/// @example
///   // Assumes jArray = ["Today", 34, 2.5299999999, true];
///   SubstituteString("$1, I ran $2 miles.", jArray);        // "Today, I ran 34 miles."
///   SubstituteString("The circle's radius is $3.", jArray); // "The circle's radius is 2.53."
///   SubstituteString("The applicant answered: $4", jArray); // "The applicant answered: true"
string SubstituteString(string s, json jArray, string sDesignator = "$");

/// @brief Repeats a string multiple times.
/// @param s The string to repeat.
/// @param n The number of times to repeat s.
/// @returns The repeated string.
string RepeatString(string s, int n);

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

int GetSubStringCount(string sString, string sSubString)
{
    if (sString == "" || sSubString == "")
        return 0;

    int nLength = GetStringLength(sSubString);
    int nCount, nPos = FindSubString(sString, sSubString);

    while (nPos != -1)
    {
        nCount++;
        nPos = FindSubString(sString, sSubString, nPos + nLength);
    }

    return nCount;
}

int FindSubStringN(string sString, string sSubString, int nNth = 0)
{
    if (nNth < 0 || sString == "" || sSubString == "")
        return -1;

    int nLength = GetStringLength(sSubString);
    int nPos = FindSubString(sString, sSubString);

    while (--nNth >= 0 && nPos != -1)
        nPos = FindSubString(sString, sSubString, nPos + nLength);

    return nPos;
}

string GetChar(string sString, int nPos)
{
    return GetSubString(sString, nPos, 1);
}

string GetStringSlice(string sString, int nStart, int nEnd = -1)
{
    int nLength = GetStringLength(sString);
    if (nEnd < 0 || nEnd > nLength)
        nEnd = nLength;

    if (nStart < 0 || nStart > nEnd)
        return "";

    return GetSubString(sString, nStart, nEnd - nStart + 1);
}

string ReplaceSubString(string sString, string sSub, int nStart, int nEnd)
{
    int nLength = GetStringLength(sString);
    if (nStart < 0 || nStart >= nLength || nStart > nEnd)
        return sString;

    return GetSubString(sString, 0, nStart) + sSub +
           GetSubString(sString, nEnd + 1, nLength - nEnd);
}

string SubstituteSubString(string sString, string sToken, string sSub)
{
    int nPos;
    if ((nPos = FindSubString(sString, sToken)) == -1)
        return sString;

    return ReplaceSubString(sString, sSub, nPos, nPos + GetStringLength(sToken) - 1);
}

string SubstituteSubStrings(string sString, string sToken, string sSub)
{
    while (FindSubString(sString, sToken) >= 0)
        sString = SubstituteSubString(sString, sToken, sSub);

    return sString;
}

int HasSubString(string sString, string sSubString, int nStart = 0)
{
    return FindSubString(sString, sSubString, nStart) >= 0;
}

int GetAnyCharsInSet(string sString, string sSet)
{
    int i, nLength = GetStringLength(sString);
    for (i = 0; i < nLength; i++)
    {
        if (HasSubString(sSet, GetChar(sString, i)))
            return TRUE;
    }
    return FALSE;
}

int GetAllCharsInSet(string sString, string sSet)
{
    int i, nLength = GetStringLength(sString);
    for (i = 0; i < nLength; i++)
    {
        if (!HasSubString(sSet, GetChar(sString, i)))
            return FALSE;
    }
    return TRUE;
}

int GetIsUpperCase(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA_UPPER + CHARSET_NUMERIC);
}

int GetIsLowerCase(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA_LOWER + CHARSET_NUMERIC);
}

int GetIsAlpha(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA);
}

int GetIsNumeric(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_NUMERIC);
}

int GetIsAlphaNumeric(string sString)
{
    return GetAllCharsInSet(sString, CHARSET_ALPHA + CHARSET_NUMERIC);
}

string TrimStringLeft(string sString, string sRemove = " ")
{
    return RegExpReplace("^(?:" + sRemove + ")*", sString, "");
}

string TrimStringRight(string sString, string sRemove = " ")
{
    return RegExpReplace("(:?" + sRemove + ")*$", sString, "");
}

string TrimString(string sString, string sRemove = " ")
{
    return RegExpReplace("^(:?" + sRemove + ")*|(?:" + sRemove + ")*$", sString, "");
}

string FormatValues(json jArray, string sFormat)
{
    if (JsonGetType(jArray) != JSON_TYPE_ARRAY)
        return "";

    string sArgs;
    int i, nLength = JsonGetLength(jArray);
    for (i = 0; i < nLength; i++)
        sArgs += ", @" + IntToString(i);

    sqlquery q = SqlPrepareQueryObject(GetModule(), "SELECT printf(@format" + sArgs + ");");
    SqlBindString(q, "@format", sFormat);
    for (i = 0; i < nLength; i++)
    {
        string sParam = "@" + IntToString(i);
        json jValue = JsonArrayGet(jArray, i);
        switch (JsonGetType(jValue))
        {
            case JSON_TYPE_FLOAT:   SqlBindFloat (q, sParam, JsonGetFloat (jValue)); break;
            case JSON_TYPE_INTEGER: SqlBindInt   (q, sParam, JsonGetInt   (jValue)); break;
            case JSON_TYPE_STRING:  SqlBindString(q, sParam, JsonGetString(jValue)); break;
            default: break;
        }
    }
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

string FormatFloat(float f, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        JsonArrayInsertInplace(jArray, JsonFloat(f));
    return FormatValues(jArray, sFormat);
}

string FormatInt(int n, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        JsonArrayInsertInplace(jArray, JsonInt(n));
    return FormatValues(jArray, sFormat);
}

string FormatString(string s, string sFormat)
{
    json jArray = JsonArray();
    int i, nCount = GetSubStringCount(sFormat, "%");
    for (i = 0; i < nCount; i++)
        JsonArrayInsertInplace(jArray, JsonString(s));
    return FormatValues(jArray, sFormat);
}

string SubstituteString(string s, json jArray, string sDesignator = "$")
{
    if (JsonGetType(jArray) != JSON_TYPE_ARRAY)
        return s;

    int n; for (n = JsonGetLength(jArray) - 1; n >= 0; n--)
    {
        string sValue;
        json jValue = JsonArrayGet(jArray, n);
        int nType = JsonGetType(jValue);
        if      (nType == JSON_TYPE_STRING)  sValue = JsonGetString(jValue);
        else if (nType == JSON_TYPE_INTEGER) sValue = IntToString(JsonGetInt(jValue));
        else if (nType == JSON_TYPE_FLOAT)   sValue = FormatFloat(JsonGetFloat(jValue), "%!f");
        else if (nType == JSON_TYPE_BOOL)    sValue = JsonGetInt(jValue) == 1 ? "true" : "false";
        else continue;

        s = SubstituteSubStrings(s, sDesignator + IntToString(n + 1), sValue);
    }

    return s;
}

string RepeatString(string s, int n)
{
    string sResult;
    while (n-- > 0)
        sResult += s;

    return sResult;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_targeting.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing forced targeting.
/// ----------------------------------------------------------------------------
/// @details
/*
This system is designed to take advantage of NWN:EE's ability to forcibly enter
Targeting Mode for any given PC. It is designed to add a single-use, multi-use,
or unlimited-use hook to the specified PC. Once the PC has satisfied the
conditions of the hook, or manually exited targeting mode, the targeted
objects/locations will be saved and a specified script will be run.

## Setup

1.  You must attach a targeting event script to the module. For example, in your
module load script, you can add this line:

    SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "module_opt");

where "module_opt" is the script that will handle all forced targeting.

2.  The chosen script ("module_opt") must contain reference to the
util_i_targeting function SatisfyTargetingHook(). An example of this follows.

```nwscript
#include "util_i_targeting"

void main()
{
    object oPC = GetLastPlayerToSelectTarget();

    if (SatisfyTargetingHook(oPC))
    {
        // This PC was marked as a targeter, do something here.
    }
}
```

Alternately, if you want the assigned targeting hook scripts to handle
everything, you can just let the system know a targeting event happened:

```nwscript
void main()
{
    object oPC = GetLastPlayerToSelectTarget();
    SatisfyTargetingHook(oPC);
}
```

If oPC didn't have a targeting hook specified, nothing happens.

## Usage

The design of this system centers around a module-wide list of "Targeting Hooks"
that are accessed by util_i_targeting when a player targets any object or
manually exits targeting mode. These hooks are stored in the module's organic
sqlite database. All targeting hook information is volatile and will be reset
when the server/module is reset.

This is the prototype for the `AddTargetingHook()` function:

```nwscript
int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "", int nUses = 1);
```

- `oPC` is the PC object that will be associated with this hook. This PC will be
  the player that will be entered into Targeting Mode. Additionally, the results
  of his targeting will be saved to the PC object.
- `sVarName` is the variable name to save the results of targeting to. This
  allows for targeting hooks to be added that can be saved to different
  variables for several purposes.
- `nObjectType` is the limiting variable for the types of objects the PC can
  target when they are in targeting mode forced by this hook. It is an optional
  parameter and can be bitmasked with any visible `OBJECT_TYPE_*` constant.
- `sScript` is the resref of the script that will run once the targeting
  conditions have been satisfied. For example, if you create a multi-use
  targeting hook, this script will run after all uses have been exhausted. This
  script will also run if the player manually exits targeting mode without
  selecting a target. Optional. A script-run is not always desirable. The
  targeted object may be required for later use, so a script entry is not a
  requirement.
- `nUses` is the number of times this target hook can be used before it is
  deleted. This is designed to allow multiple targets to be selected and saved
  to the same variable name sVarName. Multi-selection could be useful for DMs in
  defining DM Experience members, even from different parties, or selecting
  multiple NPCs to accomplish a specific action. Optional, defaulted to 1.

  Note: Targeting mode uses specified by `nUses` will be decremented every time
  a player selects a target. Uses will also be decremented when a user manually
  exits targeting mode. Manually exiting targeting mode will delete the
  targeting hook, but any selected targets before exiting targeting mode will be
  saved to the specified variable.

To add a single-use targeting hook that enters the PC into targeting mode, allows
for the selection of a single placeable | creature, then runs the script
"temp_target" upon exiting target mode or selecting a single target:

```nwscript
int nObjectType = OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "spell_target", nObjectType, "temp_target");
```

To add a multi-use targeting hook that enters the PC into targeting mode, allows
for the selection of a specified number of placeables | creatures, then runs the
script "DM_Party" upon exiting targeting mode or selecting the specified number
of targets:

```nwscript
int nObjectType = OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "DM_Party", nObjectType, "DM_Party", 3);
```

> Note: In this case, the player can select up to three targets to save to the
  "DM_Party" variable.

To add an unlmited-use targeting hook that enters the PC into targeting mode,
allows for the selection of an unspecified number of creatures, then runs the
script "temp_target" upon exiting targeting mode or selection of an invalid
target:

```nwscript
int nObjectType = OBJECT_TYPE_CREATURE;
AddTargetingHook(oPC, "NPC_Townspeople", nObjectType, "temp_target", -1);
```

Here is an example "temp_target" post-targeting script that will access each of
the targets saved to the specified variable and send their data to the chat log:

```nwscript
#include "util_i_targeting"

void main()
{
    object oPC = OBJECT_SELF;
    int n, nCount = CountTargetingHookTargets(oPC, "NPC_Townspeople");

    for (n = 0; n < nCount; n++)
    {
        object oTarget = GetTargetingHookObject(oPC, "NPC_Townspeople", n);
        location lTarget = GetTargetingHookLocation(oPC, "NPC_Townspeople", n);
        vector vTarget = GetTargetingHookPosition(oPC, "NPC_Townspeople", n);
    }
}
```

Note: Target objects and positions saved to the variables are persistent while
the server is running, but are not persistent (though they can be made so). If
you wish to overwrite a set of target data with a variable you've already used,
ensure you first delete the current target data with the function
`DeleteTargetingHookTargets();`.
*/

#include "util_c_targeting"
#include "util_i_debug"
#include "util_i_varlists"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// VarList names for the global targeting hook lists
const string TARGET_HOOK_ID = "TARGET_HOOK_ID";
const string TARGET_HOOK_BEHAVIOR = "TARGET_HOOK_BEHAVIOR";

// List Behaviors
const int TARGET_BEHAVIOR_ADD    = 1;
const int TARGET_BEHAVIOR_DELETE = 2;

// Targeting Hook Data Structure
struct TargetingHook
{
    int    nHookID;
    int    nObjectType;
    int    nUses;
    object oPC;
    string sVarName;
    string sScript;
    int    nValidCursor;
    int    nInvalidCursor;
};

struct TargetingHook TARGETING_HOOK_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates targeting hook data tables in the module's sqlite database.
/// @param bReset If TRUE, attempts to drop the tables before creation.
void CreateTargetingDataTables(int bReset = FALSE);

/// @brief Retrieve targeting hook data.
/// @param nHookID The targeting hook's ID.
/// @returns A TargetingHook containing all targeting hook data associated with
///     nHookID.
struct TargetingHook GetTargetingHookDataByHookID(int nHookID);

/// @brief Retrieve targeting hook data.
/// @param oPC The PC object associated with the targeting hook.
/// @param sVarName The varname associated with the targeting hook.
/// @returns A TargetingHook containing all targeting hook data associated with
///     nHookID.
struct TargetingHook GetTargetingHookDataByVarName(object oPC, string sVarName);

/// @brief Retrieve a list of targets.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index of the target to retrieve from the list. If omitted,
///     the entire target list will be returned.
/// @returns A prepared sqlquery containing the target list associated with
///     oPC's sVarName.
sqlquery GetTargetList(object oPC, string sVarName, int nIndex = -1);

/// @brief Add a target to a target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param oTarget The target object to be added to the target list.
/// @param oArea The area object where oTarget is located.
/// @param vTarget The position of oTarget within oArea.
/// @returns The number of targets on oPC's target list sVarName after insertion.
int AddTargetToTargetList(object oPC, string sVarName, object oTarget, object oArea, vector vTarget);

/// @brief Delete oPC's sVarName target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
void DeleteTargetList(object oPC, string sVarName);

/// @brief Delete a targeting hook and all associated targeting hook data.
/// @param nHookID The targeting hook's ID.
void DeleteTargetingHook(int nHookID);

/// @brief Force the PC object associated with targeting hook nHookID to enter
///     targeting mode using properties set by AddTargetingHook().
/// @param nHookID The targeting hook's ID.
/// @param nBehavior The behavior desired from the targeting session. Must be
///     a TARGET_BEHAVIOR_* constant.
void EnterTargetingModeByHookID(int nHookID, int nBehavior = TARGET_BEHAVIOR_ADD);

/// @brief Force the PC object associated with targeting hook nHookID to enter
///     targeting mode using properties set by AddTargetingHook().
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nBehavior The behavior desired from the targeting session. Must be
///     a TARGET_BEHAVIOR_* constant.
void EnterTargetingModeByVarName(object oPC, string sVarName, int nBehavior = TARGET_BEHAVIOR_ADD);

/// @brief Retrieve a targeting hook id.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @returns The targeting hook id assocaited with oPC's sVarName target list.
int GetTargetingHookID(object oPC, string sVarName);

/// @brief Retrieve a targeting hook's sVarName.
/// @param nHookID The targeting hook's ID.
/// @returns The target list name sVarName associated with nHookID.
string GetTargetingHookVarName(int nHookID);

/// @brief Retrieve a targeting hook's allowed object types.
/// @param nHookID The targeting hook's ID.
/// @returns A bitmap containing the allowed target types associated with
///     nHookID.
int GetTargetingHookObjectType(int nHookID);

/// @brief Retrieve a targeting hook's remaining uses.
/// @param nHookID The targeting hook's ID.
/// @returns The number of uses remaining for targeting hook nHookID.
int GetTargetingHookUses(int nHookID);

/// @brief Retrieve a targeting hook's script.
/// @param nHookID The targeting hook's ID.
/// @returns The script associated with targeting hook nHookID.
string GetTargetingHookScript(int nHookID);

/// @brief Add a targeting hook to the global targeting hook list and save
///     targeting hook parameters for later use.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nObjectType A bitmasked value containing all object types allowed
///     to be targeted by this hook.
/// @param sScript The script that will be run when this target hook is
///     satisfied.
/// @param nUses The number of times this targeting hook is allowed to be used
///     before it is automatically deleted. Omitting this value will yield a
///     single use hook.  Use -1 for an infinite-use hook.
/// @param nValidCursor A MOUSECURSOR_* cursor indicating a valid target.
/// @param nInvalidCursor A MOUSECURSOR_* cursor indicating an invalid target.
/// @returns A unique ID associated with the new targeting hook.
int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "",
                     int nUses = 1, int nValidCursor = MOUSECURSOR_MAGIC, int nInvalidCursor = MOUSECURSOR_NOMAGIC);

/// @brief Save target data to the PC object as an object and location variable
///     defined by sVarName in AddTargetingHook(). Decrements remaining targeting
///     hook uses and, if required, deletes the targeting hook.
/// @param oPC The PC object associated with the target list.
/// @returns TRUE if OpC has a current targeting hook, FALSE otherwise.
int SatisfyTargetingHook(object oPC);

/// @brief Retrieve a targeting list's object at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target object.
/// @returns The targeting's lists target at index nIndex, or the first
///     target on the list if nIndex is omitted.
object GetTargetingHookObject(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve a targeting list's location at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target location.
/// @returns The targeting's lists location at index nIndex, or the first
///     location on the list if nIndex is omitted.
location GetTargetingHookLocation(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve a targeting list's position at index nIndex.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to retrieve the target position.
/// @returns The targeting's lists position at index nIndex, or the first
///     position on the list if nIndex is omitted.
vector GetTargetingHookPosition(object oPC, string sVarName, int nIndex = 1);

/// @brief Determine how many targets are on a target list.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @returns The number of targets associated with the saved as sVarName
///     on oPC.
// ---< CountTargetingHookTargets >---
int CountTargetingHookTargets(object oPC, string sVarName);

/// @brief Delete a targeting hook target.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The index at which to delete the target data. If omitted,
///     the first target on the list will be deleted.
/// @returns The number of targets remaining on oPC's sVarName target list
///     after deletion.
int DeleteTargetingHookTarget(object oPC, string sVarName, int nIndex = 1);

/// @brief Retrieve the target list object's internal index.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param oObject The object to find on oPC's sVarName target list.
int GetTargetingHookIndex(object oPC, string sVarName, object oTarget);

/// @brief Delete target list target data by internal index.
/// @param oPC The PC object associated with the target list.
/// @param sVarName The VarName associated with the target list.
/// @param nIndex The internal index of the target data to be deleted. This
///     index can be retrieved from GetTargetingHookIndex().
/// @returns The number of targets remaining on oPC's sVarName target list
///     after deletion.
int DeleteTargetingHookTargetByIndex(object oPC, string sVarName, int nIndex);

// -----------------------------------------------------------------------------
//                            Private Function Definitions
// -----------------------------------------------------------------------------

sqlquery _PrepareTargetingQuery(string s)
{
    return SqlPrepareQueryObject(GetModule(), s);
}

string _GetTargetingHookFieldData(int nHookID, string sField)
{
    string s =  "SELECT " + sField + " " +
                "FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";
    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

int _GetLastTargetingHookID()
{
    string s = "SELECT seq FROM sqlite_sequence WHERE name = @name;";
    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@name", "targeting_hooks");

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

string _GetTargetData(object oPC, string sVarName, string sField, int nIndex = 1)
{
    string s =  "SELECT " + sField + " " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                "LIMIT 1 OFFSET " + IntToString(nIndex) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

void _EnterTargetingMode(struct TargetingHook th, int nBehavior)
{
    SetLocalInt(th.oPC, TARGET_HOOK_ID, th.nHookID);
    SetLocalInt(th.oPC, TARGET_HOOK_BEHAVIOR, nBehavior);
    EnterTargetingMode(th.oPC, th.nObjectType, th.nValidCursor, th.nInvalidCursor);
}

void _DeleteTargetingHookData(int nHookID)
{
    string s =  "DELETE FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);
    SqlStep(q);
}

void _ExitTargetingMode(int nHookID)
{
    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);
    if (th.sScript != "")
    {
        Debug("Running post-targeting script " + th.sScript + " from Targeting Hook ID " +
            IntToString(nHookID) + " on " + GetName(th.oPC) + " with varname " + th.sVarName);
        RunTargetingHookScript(th.sScript, th.oPC);
    }
    else
        Debug("No post-targeting script specified for Targeting Hook ID " + IntToString(nHookID) + " " +
            "on " + GetName(th.oPC) + " with varname " + th.sVarName);

    DeleteTargetingHook(nHookID);
    DeleteLocalInt(th.oPC, TARGET_HOOK_ID);
    DeleteLocalInt(th.oPC, TARGET_HOOK_BEHAVIOR);
}

// Reduces the number of targeting hooks remaining. When the remaining number is
// 0, the hook is automatically deleted.
int _DecrementTargetingHookUses(struct TargetingHook th, int nBehavior)
{
    int nUses = GetTargetingHookUses(th.nHookID);

    if (--nUses == 0)
    {
        if (IsDebugging(DEBUG_LEVEL_DEBUG))
            Debug("Decrementing target hook uses for ID " + HexColorString(IntToString(th.nHookID), COLOR_CYAN) +
                "\n  Uses remaining -> " + (nUses ? HexColorString(IntToString(nUses), COLOR_CYAN) : HexColorString(IntToString(nUses), COLOR_RED_LIGHT)) + "\n");

        _ExitTargetingMode(th.nHookID);
    }
    else
    {
        string s =  "UPDATE targeting_hooks " +
                    "SET nUses = nUses - 1 " +
                    "WHERE nHookID = @nHookID;";

        sqlquery q = _PrepareTargetingQuery(s);
        SqlBindInt(q, "@nHookID", th.nHookID);
        SqlStep(q);

        _EnterTargetingMode(th, nBehavior);
    }

    return nUses;
}

// -----------------------------------------------------------------------------
//                            Public Function Definitions
// -----------------------------------------------------------------------------

// Temporary function for feedback purposes only
string ObjectTypeToString(int nObjectType)
{
    string sResult;

    if (nObjectType & OBJECT_TYPE_CREATURE)
        sResult += (sResult == "" ? "" : ", ") + "Creatures";

    if (nObjectType & OBJECT_TYPE_ITEM)
        sResult += (sResult == "" ? "" : ", ") + "Items";

    if (nObjectType & OBJECT_TYPE_TRIGGER)
        sResult += (sResult == "" ? "" : ", ") + "Triggers";

    if (nObjectType & OBJECT_TYPE_DOOR)
        sResult += (sResult == "" ? "" : ", ") + "Doors";

    if (nObjectType & OBJECT_TYPE_AREA_OF_EFFECT)
        sResult += (sResult == "" ? "" : ", ") + "Areas of Effect";

    if (nObjectType & OBJECT_TYPE_WAYPOINT)
        sResult += (sResult == "" ? "" : ", ") + "Waypoints";

    if (nObjectType & OBJECT_TYPE_PLACEABLE)
        sResult += (sResult == "" ? "" : ", ") + "Placeables";

    if (nObjectType & OBJECT_TYPE_STORE)
        sResult += (sResult == "" ? "" : ", ") + "Stores";

    if (nObjectType & OBJECT_TYPE_ENCOUNTER)
        sResult += (sResult == "" ? "" : ", ") + "Encounters";

    if (nObjectType & OBJECT_TYPE_TILE)
        sResult += (sResult == "" ? "" : ", ") + "Tiles";

    return sResult;
}

void CreateTargetingDataTables(int bReset = FALSE)
{
    object oModule = GetModule();

    if (bReset)
    {
        string sDropHooks = "DROP TABLE IF EXISTS targeting_hooks;";
        string sDropTargets = "DROP TABLE IF EXISTS targeting_targets;";

        sqlquery q;
        q = _PrepareTargetingQuery(sDropHooks);   SqlStep(q);
        q = _PrepareTargetingQuery(sDropTargets); SqlStep(q);

        DeleteLocalInt(oModule, "TARGETING_INITIALIZED");
        Warning(HexColorString("Targeting database tables have been dropped", COLOR_RED_LIGHT));
    }

    if (GetLocalInt(oModule, "TARGETING_INITIALIZED"))
        return;

    string sData = "CREATE TABLE IF NOT EXISTS targeting_hooks (" +
        "nHookID INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "sUUID TEXT, " +
        "sVarName TEXT, " +
        "nObjectType INTEGER, " +
        "nUses INTEGER default '1', " +
        "sScript TEXT, " +
        "nValidCursor INTEGER, " +
        "nInvalidCursor INTEGER, " +
        "UNIQUE (sUUID, sVarName));";

    string sTargets = "CREATE TABLE IF NOT EXISTS targeting_targets (" +
        "nTargetID INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "sUUID TEXT, " +
        "sVarName TEXT, " +
        "sTargetObject TEXT, " +
        "sTargetArea TEXT, " +
        "vTargetLocation TEXT);";

    sqlquery q;
    q = _PrepareTargetingQuery(sData);     SqlStep(q);
    q = _PrepareTargetingQuery(sTargets);  SqlStep(q);

    Debug(HexColorString("Targeting database tables have been created", COLOR_GREEN_LIGHT));
    SetLocalInt(oModule, "TARGETING_INITIALIZED", TRUE);
}

struct TargetingHook GetTargetingHookDataByHookID(int nHookID)
{
    string s =  "SELECT sUUID, sVarName, nObjectType, nUses, sScript, nValidCursor, nInvalidCursor " +
                "FROM targeting_hooks " +
                "WHERE nHookID = @nHookID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nHookID", nHookID);

    struct TargetingHook th;

    if (SqlStep(q))
    {
        th.nHookID = nHookID;
        th.oPC = GetObjectByUUID(SqlGetString(q, 0));
        th.sVarName = SqlGetString(q, 1);
        th.nObjectType = SqlGetInt(q, 2);
        th.nUses = SqlGetInt(q, 3);
        th.sScript = SqlGetString(q, 4);
        th.nValidCursor = SqlGetInt(q, 5);
        th.nInvalidCursor = SqlGetInt(q, 6);
    }
    else
        Warning("Targeting data for target hook " + IntToString(nHookID) + " not found");

    return th;
}

struct TargetingHook GetTargetingHookDataByVarName(object oPC, string sVarName)
{
    int nHookID = GetTargetingHookID(oPC, sVarName);
    return GetTargetingHookDataByHookID(nHookID);
}

sqlquery GetTargetList(object oPC, string sVarName, int nIndex = -1)
{
    string s =  "SELECT sTargetObject, sTargetArea, vTargetLocation " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName" +
                    (nIndex == -1 ? ";" : "LIMIT 1 OFFSET " + IntToString(nIndex)) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return q;
}

int AddTargetToTargetList(object oPC, string sVarName, object oTarget, object oArea, vector vTarget)
{
    string s =  "INSERT INTO targeting_targets (sUUID, sVarName, sTargetObject, sTargetArea, vTargetLocation) " +
                "VALUES (@sUUID, @sVarName, @sTargetObject, @sTargetArea, @vTargetLocation);";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindString(q, "@sTargetObject", ObjectToString(oTarget));
    SqlBindString(q, "@sTargetArea", ObjectToString(oArea));
    SqlBindVector(q, "@vTargetLocation", vTarget);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}

void DeleteTargetList(object oPC, string sVarName)
{
    string s =  "DELETE FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    SqlStep(q);
}

void EnterTargetingModeByHookID(int nHookID, int nBehavior = TARGET_BEHAVIOR_ADD)
{
    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("EnterTargetingModeByHookID::Unable to retrieve valid targeting data for " +
            "targeting hook " + IntToString(nHookID));
        return;
    }

    if (GetIsObjectValid(th.oPC))
        _EnterTargetingMode(th, nBehavior);
}

void EnterTargetingModeByVarName(object oPC, string sVarName, int nBehavior = TARGET_BEHAVIOR_ADD)
{
    struct TargetingHook th = GetTargetingHookDataByVarName(oPC, sVarName);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("EnterTargetingModeByVarName::Unable to retrieve valid targeting data for " +
            "targeting hook " + sVarName + " on " + GetName(oPC));
        return;
    }

    if (GetIsObjectValid(th.oPC))
        _EnterTargetingMode(th, nBehavior);
}

int GetTargetingHookID(object oPC, string sVarName)
{
    string s =  "SELECT nHookID " +
                "FROM targeting_hooks " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

string GetTargetingHookVarName(int nHookID)
{
    return _GetTargetingHookFieldData(nHookID, "sVarName");
}

int GetTargetingHookObjectType(int nHookID)
{
    return StringToInt(_GetTargetingHookFieldData(nHookID, "nObjectType"));
}

int GetTargetingHookUses(int nHookID)
{
    return StringToInt(_GetTargetingHookFieldData(nHookID, "nUses"));
}

string GetTargetingHookScript(int nHookID)
{
    return _GetTargetingHookFieldData(nHookID, "sScript");
}

int AddTargetingHook(object oPC, string sVarName, int nObjectType = OBJECT_TYPE_ALL, string sScript = "",
                     int nUses = 1, int nValidCursor = MOUSECURSOR_MAGIC, int nInvalidCursor = MOUSECURSOR_NOMAGIC)
{
    CreateTargetingDataTables();

    string s =  "REPLACE INTO targeting_hooks (sUUID, sVarName, nObjectType, nUses, sScript, nValidCursor, nInvalidCursor) " +
                "VALUES (@sUUID, @sVarName, @nObjectType, @nUses, @sScript, @nValidCursor, @nInvalidCursor);";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindInt   (q, "@nObjectType", nObjectType);
    SqlBindInt   (q, "@nUses", nUses);
    SqlBindString(q, "@sScript", sScript);
    SqlBindInt   (q, "@nValidCursor", nValidCursor);
    SqlBindInt   (q, "@nInvalidCursor", nInvalidCursor);
    SqlStep(q);

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        Debug("Adding targeting hook ID " + HexColorString(IntToString(_GetLastTargetingHookID()), COLOR_CYAN) +
            "\n  sVarName -> " + HexColorString(sVarName, COLOR_CYAN) +
            "\n  nObjectType -> " + HexColorString(ObjectTypeToString(nObjectType), COLOR_CYAN) +
            "\n  sScript -> " + (sScript == "" ? HexColorString("[None]", COLOR_RED_LIGHT) :
                HexColorString(sScript, COLOR_CYAN)) +
            "\n  nUses -> " + (nUses == -1 ? HexColorString("Unlimited", COLOR_CYAN) :
                (nUses > 0 ? HexColorString(IntToString(nUses), COLOR_CYAN) :
                HexColorString(IntToString(nUses), COLOR_RED_LIGHT))) + 
            "\n  nValidCursor -> " + IntToString(nValidCursor) +
            "\n  nInvalidCursor -> " + IntToString(nInvalidCursor) + "\n");
    }

    return _GetLastTargetingHookID();
}

void DeleteTargetingHook(int nHookID)
{
    if (IsDebugging(DEBUG_LEVEL_DEBUG))
        Debug("Deleting targeting hook ID " + HexColorString(IntToString(nHookID), COLOR_CYAN) + "\n");

    _DeleteTargetingHookData(nHookID);
}

int SatisfyTargetingHook(object oPC)
{
    int nHookID = GetLocalInt(oPC, TARGET_HOOK_ID);
    if (nHookID == 0)
        return FALSE;

    int nBehavior = GetLocalInt(oPC, TARGET_HOOK_BEHAVIOR);

    struct TargetingHook th = GetTargetingHookDataByHookID(nHookID);

    if (th == TARGETING_HOOK_INVALID)
    {
        Warning("SatisfyTargetingHook::Unable to retrieve valid targeting data for " +
            "targeting hook " + IntToString(nHookID));
        return FALSE;
    }

    string sVarName = th.sVarName;
    object oTarget = GetTargetingModeSelectedObject();
    vector vTarget = GetTargetingModeSelectedPosition();

    int bValid = TRUE;

    if (IsDebugging(DEBUG_LEVEL_DEBUG))
    {
        Debug("Targeted Object -> " + (GetIsObjectValid(oTarget) ? (GetIsPC(oTarget) ? HexColorString(GetName(oTarget), COLOR_GREEN_LIGHT) : HexColorString(GetTag(oTarget), COLOR_CYAN)) : HexColorString("OBJECT_INVALID", COLOR_RED_LIGHT)) +
            "\n  Type -> " + HexColorString(ObjectTypeToString(GetObjectType(oTarget)), COLOR_CYAN));
        Debug("Targeted Position -> " + (vTarget == Vector() ? HexColorString("POSITION_INVALID", COLOR_RED_LIGHT) :
                                        HexColorString("(" + FloatToString(vTarget.x, 3, 1) + ", " +
                                            FloatToString(vTarget.y, 3, 1) + ", " +
                                            FloatToString(vTarget.z, 3, 1) + ")", COLOR_CYAN)) + "\n");
    }

    if (GetIsObjectValid(oTarget))
    {
        if (nBehavior == TARGET_BEHAVIOR_ADD)
        {
            if (IsDebugging(DEBUG_LEVEL_DEBUG))
            {
                object oArea = GetArea(oTarget);

                Debug(HexColorString("Saving targeted object and position to list [" + th.sVarName + "]:", COLOR_CYAN) +
                        "\n  Tag -> " + HexColorString(GetTag(oTarget), COLOR_CYAN) +
                        "\n  Location -> " + HexColorString(JsonDump(LocationToJson(Location(oArea, vTarget, 0.0))), COLOR_CYAN) +
                        "\n  Area -> " + HexColorString((GetIsObjectValid(oArea) ? GetTag(oArea) : "AREA_INVALID"), COLOR_CYAN) + "\n");
            }

            AddTargetToTargetList(oPC, sVarName, oTarget, GetArea(oPC), vTarget);
        }
        else if (nBehavior == TARGET_BEHAVIOR_DELETE)
        {
            if (GetArea(oTarget) == oTarget)
                Warning("Location/Tile targets cannot be deleted; select a game object");
            else
            {
                Debug(HexColorString("Attempting to delete targeted object and position from list [" + th.sVarName + "]:", COLOR_CYAN));
                int nIndex = GetTargetingHookIndex(oPC, sVarName, oTarget);
                if (nIndex == 0 && IsDebugging(DEBUG_LEVEL_DEBUG))
                    Debug("  > " + HexColorString("Target " + (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)) + " not found " +
                        "on list [" + th.sVarName + "]; removal aborted", COLOR_RED_LIGHT));
                else
                {
                    DeleteTargetingHookTargetByIndex(oPC, sVarName, nIndex);

                    if (IsDebugging(DEBUG_LEVEL_DEBUG))
                        Debug("  > " + HexColorString("Target " + (GetIsPC(oTarget) ? GetName(oTarget) : GetTag(oTarget)) + " removed from " +
                            "list [" + th.sVarName + "]", COLOR_GREEN_LIGHT));
                }
            }
        }
    }
    else
        bValid = FALSE;

    if (!bValid)
        _ExitTargetingMode(nHookID);
    else
    {
        if (th.nUses == -1)
            _EnterTargetingMode(th, nBehavior);
        else
            _DecrementTargetingHookUses(th, nBehavior);
    }

    return TRUE;
}

int DeleteTargetingHookTargetByIndex(object oPC, string sVarName, int nIndex)
{
    string s  = "DELETE FROM targeting_targets " +
                "WHERE nTargetID = @nTargetID;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindInt(q, "@nTargetID", nIndex);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}

int GetTargetingHookIndex(object oPC, string sVarName, object oTarget)
{
    string s =  "SELECT nTargetID " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                    "AND sTargetObject = @sTargetObject;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlBindString(q, "@sTargetObject", ObjectToString(oTarget));

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

object GetTargetingHookObject(object oPC, string sVarName, int nIndex = 1)
{
    return StringToObject(_GetTargetData(oPC, sVarName, "sTargetObject", nIndex));
}

location GetTargetingHookLocation(object oPC, string sVarName, int nIndex = 1)
{
    sqlquery q = GetTargetList(oPC, sVarName, 1);
    if (SqlStep(q))
    {
        object oArea = StringToObject(SqlGetString(q, 1));
        vector vTarget = SqlGetVector(q, 2);

        return Location(oArea, vTarget, 0.0);
    }

    return Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetTargetingHookPosition(object oPC, string sVarName, int nIndex = 1)
{
    sqlquery q = GetTargetList(oPC, sVarName, 1);
    if (SqlStep(q))
        return SqlGetVector(q, 2);

    return Vector();
}

int CountTargetingHookTargets(object oPC, string sVarName)
{
    string s =  "SELECT COUNT (nTargetID) " +
                "FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName;";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);

    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DeleteTargetingHookTarget(object oPC, string sVarName, int nIndex = 1)
{
    string s =  "DELETE FROM targeting_targets " +
                "WHERE sUUID = @sUUID " +
                    "AND sVarName = @sVarName " +
                "LIMIT 1 OFFSET " + IntToString(nIndex) + ";";

    sqlquery q = _PrepareTargetingQuery(s);
    SqlBindString(q, "@sUUID", GetObjectUUID(oPC));
    SqlBindString(q, "@sVarName", sVarName);
    SqlStep(q);

    return CountTargetingHookTargets(oPC, sVarName);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_timers.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for running scripts on an interval.
/// ----------------------------------------------------------------------------
/// @details
/// ## Concept
/// Timers are a way of running a script repeatedly on an interval. A timer can
/// be created on an object. Once started, it will continue to run until it is
/// finished iterating or until killed manually. Each time the timer elapses,
/// its action will run. By default, this action is to simply run a script.
///
/// ## Basic Usage
///
/// ### Creating a Timer
/// You can create a timer using `CreateTimer()`. This function takes the object
/// that should run the timer, the script that should execute when the timer
/// elapses, the interval between ticks, and the total number of iterations. It
/// returns the ID for the timer, which is used to reference it in the database.
/// You should save this timer for later use.
///
/// ```nwscript
/// // The following creates a timer on oPC that will run the script "foo" every
/// // 6 seconds for 4 iterations.
/// int nTimerID = CreateTimer(oPC, "foo", 6.0, 4);
/// ```
///
/// A timer created with 0 iterations will run until stopped or killed.
///
/// ## Starting a Timer
/// Timers will not run until they are started wiuth `StartTimer()`. This
/// function takes the ID of the timer returned from `CreateTimer()`. If the
/// second parameter, `bInstant`, is TRUE, the timer will elapse immediately;
/// otherwise, it will elapse when its interval is complete:
///
/// ```nwscript
/// StartTimer(nTimerID);
/// ```
///
/// ### Stopping a Timer
/// Stopping a timer with `StopTimer()` will suspend its execution:
/// ```nwscript
/// StopTimer(nTimerID);
/// ```
/// You can restart the timer later using `StartTimer()` to resume any remaining
/// iterations. If you want to start again from the beginning, you can call
/// `ResetTimer()` first:
/// ```nwscript
/// ResetTimer(nTimerID);
/// StartTimer(nTimerID);
/// ```
///
/// ### Destroying a Timer
/// Calling `KillTimer()` will clean up all data associated with the timer. A
/// timer cannot be restarted after it is killed; you will have to create and
/// start a new one.
/// ```nwscript
/// KillTimer(nTimerID);
/// ```
///
/// Timers automatically kill themselves when they are finished iterating or
/// when the object they are executed on is no longer valid. You only need to
/// use `KillTimer()` if you want to destroy it before it is done iterating or
/// if the timer is infinite.
///
/// ## Advanced Usage
/// By default, timer actions are handled by passing them to `ExecuteScript()`.
/// However, the final parameter of the `CreateTimer()` function allows you to
/// specify a handler script. If this parameter is not blank, the handler will
/// be called using `ExecuteScript()` and the action will be available to it as
/// a script parameter.
///
/// For example, the Core Framework allows timers to run event hooks by calling
/// the handler script `core_e_timerhook`, which is as follows:
/// ```nwscript
/// #include "core_i_framework"
///
/// void main()
/// {
///     string sEvent  = GetScriptParam(TIMER_ACTION);
///     string sSource = GetScriptParam(TIMER_SOURCE);
///     object oSource = StringToObject(sSource);
///     RunEvent(sEvent, oSource);
/// }
/// ```
///
/// To make this easier, `core_i_framework` contains an alias to `CreateTimer()`
/// called `CreateEventTimer()` that sets the handler script. You can create
/// your own aliases in the same way.

#include "util_i_sqlite"
#include "util_i_debug"
#include "util_i_datapoint"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

const string TIMER_DATAPOINT = "*Timers";
const string TIMER_INIT      = "*TimersInitialized";
const string TIMER_LAST      = "*TimerID";
const string TIMER_ACTION    = "*TimerAction";
const string TIMER_SOURCE    = "*TimerSource";

// -----------------------------------------------------------------------------
//                               Global Variables
// -----------------------------------------------------------------------------

// Running timers are AssignCommand()'ed to this datapoint. This ensures that
// even if the object that issued the StartTimer() becomes invalid, the timer
// will continue to run.
object TIMERS = GetDatapoint(TIMER_DATAPOINT, GetModule(), FALSE);

// -----------------------------------------------------------------------------
//                         Public Function Declarations
// -----------------------------------------------------------------------------

/// @brief Create a table for timers in the module's volatile database.
/// @param bReset If TRUE, will drop the existing timers table.
/// @note This function will be run automatically the first timer one of the
///     functions in this file is called. You only need to call this if you need
///     the table created earlier (e.g., because another table references it).
void CreateTimersTable(int bReset = FALSE);

/// @brief Create a timer that fires on a target at regular intervals.
/// @details After a timer is created, you will need to start it to get it to
///     run. You cannot create a timer on an invalid target or with a
///     non-positive interval value.
/// @param oTarget The object the action will run on.
/// @param sAction The action to execute when the timer elapses.
/// @param fInterval The number of seconds between iterations.
/// @param nIterations the number of times the timer can elapse. 0 means no
///     limit. If nIterations is 0, fInterval must be greater than or equal to
///     6.0.
/// @param fJitter A random number of seconds between 0.0 and fJitter to add to
///     fInterval between executions. Leave at 0.0 for no jitter.
/// @param sHandler A handler script to execute sAction. If "", sAction will be
///     called using ExecuteScript() instead.
/// @returns the ID of the timer. Save this so it can be used to start, stop, or
///     kill the timer later.
int CreateTimer(object oTarget, string sAction, float fInterval, int nIterations = 0, float fJitter = 0.0, string sHandler = "");

/// @brief Return if a timer exists.
/// @param nTimerID The ID of the timer in the database.
int GetIsTimerValid(int nTimerID);

/// @brief Start a timer, executing its action each interval until finished
///     iterating, stopped, or killed.
/// @param nTimerID The ID of the timer in the database.
/// @param bInstant If TRUE, execute the timer's action immediately.
void StartTimer(int nTimerID, int bInstant = TRUE);

/// @brief Suspend execution of a timer.
/// @param nTimerID The ID of the timer in the database.
/// @note This does not destroy the timer, only stops it from iterating or
///     executing its action.
void StopTimer(int nTimerID);

/// @brief Reset the number or remaining iterations on a timer.
/// @param nTimerID The ID of the timer in the database.
void ResetTimer(int nTimerID);

/// @brief Delete a timer.
/// @details This results in all information about the given timer being
///     deleted. Since the information is gone, the action associated with that
///     timer ID will not get executed again.
/// @param nTimerID The ID of the timer in the database.
void KillTimer(int nTimerID);

/// @brief Return whether a timer will run infinitely.
/// @param nTimerID The ID of the timer in the database.
int GetIsTimerInfinite(int nTimerID);

/// @brief Return the remaining number of iterations for a timer.
/// @details If called during a timer script, will not include the current
///     iteration. Returns -1 if nTimerID is not a valid timer ID. Returns 0 if
///     the timer is set to run indefinitely, so be sure to check for this with
///     GetIsTimerInfinite().
/// @param nTimerID The ID of the timer in the database.
int GetTimerRemaining(int nTimerID);

/// @brief Sets the remaining number of iterations for a timer.
/// @param nTimerID The ID of the timer in the database.
/// @param nRemaining The remaining number of iterations.
void SetTimerRemaining(int nTimerID, int nRemaining);

// -----------------------------------------------------------------------------
//                       Private Function Implementations
// -----------------------------------------------------------------------------

// Private function used by StartTimer().
void _TimerElapsed(int nTimerID, int nRunID, int bFirstRun = FALSE)
{
    // Timers are fired on a delay, so it's possible that the timer was stopped
    // and restarted before the delayed call could fail due to the timer being
    // stopped. We increment the run_id whenever the timer is started and pass
    // it along to the delayed calls so they can check if they are still valid.
    sqlquery q = SqlPrepareQueryModule("SELECT * FROM timers " +
        "WHERE timer_id = @timer_id AND run_id = @run_id AND running = 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    SqlBindInt(q, "@run_id", nRunID);

    // The timer was killed or stopped
    if (!SqlStep(q))
        return;

    string sTimerID    = IntToString(nTimerID);
    string sAction     = SqlGetString(q,  3);
    string sHandler    = SqlGetString(q,  4);
    string sTarget     = SqlGetString(q,  5);
    string sSource     = SqlGetString(q,  6);
    float  fInterval   = SqlGetFloat (q,  7);
    float  fJitter     = SqlGetFloat (q,  8);
    int    nIterations = SqlGetInt   (q,  9);
    int    nRemaining  = SqlGetInt   (q, 10);
    int    bIsPC       = SqlGetInt   (q, 11);
    object oTarget     = StringToObject(sTarget);
    object oSource     = StringToObject(sSource);

    string sMsg =
        "\n    Target: " + sTarget +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oTarget) : "INVALID") + ")" +
        "\n    Source: " + sSource +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oSource) : "INVALID") + ")" +
        "\n    Action: " + sAction +
        "\n    Handler: " + sHandler;

    if (!GetIsObjectValid(oTarget) || (bIsPC && !GetIsPC(oTarget)))
    {
        Warning("Target for timer " + sTimerID + " no longer valid:" + sMsg);
        KillTimer(nTimerID);
        return;
    }

    // If we're running infinitely or we have more runs remaining...
    if (!nIterations || nRemaining)
    {
        string sIterations = (nIterations ? IntToString(nIterations) : "Infinite");
        if (!bFirstRun)
        {
            Notice("Timer " + sTimerID + " elapsed" + sMsg +
                "\n    Iteration: " +
                    (nIterations ? IntToString(nIterations - nRemaining + 1) : "INFINITE") +
                    "/" + sIterations);

            // If we're not running an infinite number of times, decrement the
            // number of iterations we have remaining
            if (nIterations)
                SetTimerRemaining(nTimerID, nRemaining - 1);

            // Run the timer handler
            SetScriptParam(TIMER_LAST,   IntToString(nTimerID));
            SetScriptParam(TIMER_ACTION, sAction);
            SetScriptParam(TIMER_SOURCE, sSource);
            ExecuteScript(sHandler != "" ? sHandler : sAction, oTarget);

            // In case one of those scripts we just called reset the timer...
            if (nIterations)
                nRemaining = GetTimerRemaining(nTimerID);
        }

        // If we have runs left, call our timer's next iteration.
        if (!nIterations || nRemaining)
        {
            // Account for any jitter
            fJitter = IntToFloat(Random(FloatToInt(fJitter * 10) + 1)) / 10.0;
            fInterval += fJitter;

            Notice("Scheduling next iteration for timer " + sTimerID + ":" + sMsg +
                "\n    Delay: " + FloatToString(fInterval, 0, 1) +
                "\n    Remaining: " +
                    (nIterations ? (IntToString(nRemaining)) : "INFINITE") +
                    "/" + sIterations);

            DelayCommand(fInterval, _TimerElapsed(nTimerID, nRunID));
            return;
        }
    }

    // We have no more runs left! Kill the timer to clean up.
    Debug("Timer " + sTimerID + " expired:" + sMsg);
    KillTimer(nTimerID);
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

void CreateTimersTable(int bReset = FALSE)
{
    if (GetLocalInt(TIMERS, TIMER_INIT) && !bReset)
        return;

    // StartTimer() assigns the timer tick to TIMERS, so by deleting it, we are
    // able to cancel all currently running timers.
    DestroyObject(TIMERS);

    SqlCreateTableModule("timers",
        "timer_id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "run_id INTEGER NOT NULL DEFAULT 0, " +
        "running BOOLEAN NOT NULL DEFAULT 0, " +
        "action TEXT NOT NULL, " +
        "handler TEXT NOT NULL, " +
        "target TEXT NOT NULL, " +
        "source TEXT NOT NULL, " +
        "interval REAL NOT NULL, " +
        "jitter REAL NOT NULL, " +
        "iterations INTEGER NOT NULL, " +
        "remaining INTEGER NOT NULL, " +
        "is_pc BOOLEAN NOT NULL DEFAULT 0", bReset);

    TIMERS = CreateDatapoint(TIMER_DATAPOINT);
    SetDebugPrefix(HexColorString("[Timers]", COLOR_CYAN), TIMERS);
    SetLocalInt(TIMERS, TIMER_INIT, TRUE);
}

int CreateTimer(object oTarget, string sAction, float fInterval, int nIterations = 0, float fJitter = 0.0, string sHandler = "")
{
    string sSource = ObjectToString(OBJECT_SELF);
    string sTarget = ObjectToString(oTarget);
    string sDebug =
        "\n    OBJECT_SELF: " + sSource + " (" + GetName(OBJECT_SELF) + ")" +
        "\n    oTarget: " + sTarget +
            " (" + (GetIsObjectValid(oTarget) ? GetName(oTarget) : "INVALID") + ")" +
        "\n    sAction: " + sAction +
        "\n    sHandler: " + sHandler +
        "\n    nIterations: " + (nIterations ? IntToString(nIterations) : "Infinite") +
        "\n    fInterval: " + FloatToString(fInterval, 0, 1) +
        "\n    fJitter: " + FloatToString(fJitter, 0, 1);

    // Sanity checks: don't create the timer if...
    // 1. the target is invalid
    // 2. the interval is not greater than 0.0
    // 3. the number of iterations is non-positive
    // 4. the interval is more than once per round and the timer is infinite
    string sError;
    if (!GetIsObjectValid(oTarget))
        sError = "oTarget is invalid";
    else if (fInterval <= 0.0)
        sError = "fInterval must be positive";
    else if (fInterval + fJitter <= 0.0)
        sError = "fJitter is too low for fInterval";
    else if (nIterations < 0)
        sError = "nIterations is negative";
    else if (fInterval < 6.0 && !nIterations)
        sError = "fInterval is too short for infinite executions";

    if (sError != "")
    {
        CriticalError("CreateTimer() failed:\n    Error: " + sError + sDebug);
        return 0;
    }

    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule("INSERT INTO timers " +
        "(action, handler, target, source, interval, jitter, iterations, remaining, is_pc) " +
        "VALUES (@action, @handler, @target, @source, @interval, @jitter, @iterations, @remaining, @is_pc) " +
        "RETURNING timer_id;");
    SqlBindString(q, "@action",     sAction);
    SqlBindString(q, "@handler",    sHandler);
    SqlBindString(q, "@target",     sTarget);
    SqlBindString(q, "@source",     sSource);
    SqlBindFloat (q, "@interval",   fInterval);
    SqlBindFloat (q, "@jitter",     fJitter);
    SqlBindInt   (q, "@iterations", nIterations);
    SqlBindInt   (q, "@remaining",  nIterations);
    SqlBindInt   (q, "@is_pc",      GetIsPC(oTarget));

    int nTimerID = SqlStep(q) ? SqlGetInt(q, 0) : 0;
    if (nTimerID > 0)
        Notice("Created timer " + IntToString(nTimerID) + sDebug);

    return nTimerID;
}

int GetIsTimerValid(int nTimerID)
{
    // Timer IDs less than or equal to 0 are always invalid.
    if (nTimerID <= 0)
        return FALSE;

    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT 1 FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? SqlGetInt(q, 0) : FALSE;
}

void StartTimer(int nTimerID, int bInstant = TRUE)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET running = 1, run_id = run_id + 1 " +
        "WHERE timer_id = @timer_id AND running = 0 RETURNING run_id;");
    SqlBindInt(q, "@timer_id", nTimerID);

    if (SqlStep(q))
    {
        Notice("Started timer " + IntToString(nTimerID));
        AssignCommand(TIMERS, _TimerElapsed(nTimerID, SqlGetInt(q, 0), !bInstant));
    }
    else
    {
        string sDebug = "StartTimer(" + IntToString(nTimerID) + ")";
        if (GetIsTimerValid(nTimerID))
            Error(sDebug + "failed: timer is already running");
        else
            Error(sDebug + " failed: timer id does not exist");
    }
}

void StopTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET running = 0 " +
        "WHERE timer_id = @timer_id RETURNING 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
        Notice("Stopping timer " + IntToString(nTimerID));
}

void ResetTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET remaining = timers.iterations " +
        "WHERE timer_id = @timer_id AND iterations > 0 RETURNING remaining;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
    {
        Notice("ResetTimer(" + IntToString(nTimerID) + ") successful: " +
                IntToString(SqlGetInt(q, 0)) + " iterations remaining");
    }
}

void KillTimer(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "DELETE FROM timers WHERE timer_id = @timer_id RETURNING 1;");
    SqlBindInt(q, "@timer_id", nTimerID);
    if (SqlStep(q))
        Notice("Killing timer " + IntToString(nTimerID));
}

int GetIsTimerInfinite(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT iterations FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? !SqlGetInt(q, 0) : FALSE;
}

int GetTimerRemaining(int nTimerID)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "SELECT remaining FROM timers WHERE timer_id = @timer_id;");
    SqlBindInt(q, "@timer_id", nTimerID);
    return SqlStep(q) ? SqlGetInt(q, 0) : -1;
}

void SetTimerRemaining(int nTimerID, int nRemaining)
{
    CreateTimersTable();
    sqlquery q = SqlPrepareQueryModule(
        "UPDATE timers SET remaining = @remaining " +
        "WHERE timer_id = @timer_id AND iterations > 0;");
    SqlBindInt(q, "@timer_id",  nTimerID);
    SqlBindInt(q, "@remaining", nRemaining);
    SqlStep(q);
}
/// ----------------------------------------------------------------------------
/// @file   util_i_times.nss
/// @author Michael A. Sinclair (Squatting Monk) <squattingmonk@gmail.com>
/// @brief  Functions for managing times, dates, and durations.
/// ----------------------------------------------------------------------------
/// @details
/// # Concepts
/// - Time: a struct value that may represent either a *calendar time* or a
///   *duration*. A Time has a field for years, months, day, hours, minutes,
///   seconds, and milliseconds. A Time also has a field to set the minutes per
///   hour (defaults to the module setting, which defaults to 2).
/// - Calendar Time: A Time representing a particular *moment in time* as
///   measured using the game calendar and clock. In a calendar Time, the month
///   and day count from 1, while all other units count from 0 (including
///   years, since NWN allows year 0). A calendar Time must always be positive.
/// - Duration Time: A Time representing an *amount of time*. All units in a
///   duration Time count from 0. A duration Time may be negative, representing
///   going back in time. This can be useful for calculations. A duration Time
///   can be converted to seconds to pass it to game functions that expect a
///   time, such as `DelayCommand()`, `PlayAnimation()`, etc.
/// - Game Time: a Time (either calendar Time or duration Time) with a minutes
///   per hour setting of 60. This allows you to convert the time shown by the
///   game clock into a time that matches how the characters in the game would
///   perceive it. For example, with the default minutes per hour setting of 2,
///   the Time "13:01" would correspond to a Game Time of "13:30".
/// - Normalizing Times: You can normalize a Time to ensure none of its units
///   are overflowing their bounds. For example, a Time with a Minute field of 0
///   and Second field of 90 would be normalized to a Minute of 1 and a Second
///   of 30. Normalizing a Time also causes all non-zero units to take the same
///   sign (either positive or negative), so a Time with a Minute of 1 and a
///   Second of -30 would normalize to a Second of 30. When normalizing a Time,
///   you can also change the minutes per hour setting. This is how the
///   functions in this file convert between Time and Game Time.
///
/// **Note**: For brevity, some functions have a `Time` variant and a
/// `Duration` variant. In these cases, the `Time` variant refers to a
/// calendar Time (e.g., `StringToTime()` converts to a calendar Time while
/// `StringToDuration()` refers to a duration Time). If no `Duration` variant
/// of the function is present, the function may refer to a calendar Time *or* a
/// duration Time (e.g., `TimeToString()` accepts both types).
/// ----------------------------------------------------------------------------
/// # Usage
///
/// ## Creating a Time
/// You can create a calendar Time using `GetTime()` and a duration Time with
/// `GetDuration()`:
/// ```nwscript
/// struct Time t = GetTime(1372, 6, 1, 13);
/// struct Time d = GetDuration(1372, 5, 0, 13);
/// ```
///
/// You could also parse an ISO 8601 time string into a calendar Time or
/// duration Time:
/// ```nwscript
/// struct Time tTime = StringToTime("1372-06-01 13:00:00:000");
/// struct Time tDur = StringToDuration("1372-05-00 13:00:00:000");
///
/// // Negative durations are allowed:
/// struct Time tNeg = StringToDuration("-1372-05-00 13:00:00:000");
///
/// // Missing units are assumed to be their lowest bound:
/// struct Time a = StringToTime("1372-06-01 00:00:00:000");
/// struct Time b = StringToTime("1372-06-01");
/// struct Time c = StringToTime("1372-06");
/// Assert(a == b);
/// Assert(b == c);
/// ```
///
/// You can also create a Time manually by declaring a new Time struct and
/// setting the fields independently:
/// ```nwscript
/// struct Time t;
/// t.Type  = TIME_TYPE_CALENDAR;
/// t.Year  = 1372;
/// t.Month = 6;
/// t.Day   = 1;
/// t.Hour  = 13;
/// // ...
/// ```
///
/// When not using the `GetTime()` function, it's a good idea to normalize the
/// resultant Time to distribute the field values correctly:
/// ```nwscript
/// struct Time t = NewTime();
/// t.Second = 90;
///
/// t = NormalizeTime(t);
/// Assert(t.Minute == 1);
/// Assert(t.Second == 30);
/// ```
///
/// ## Converting Between Time and Game Time
///
/// ```nwscript
/// // Assuming the default module setting of 2 minutes per hour
/// struct Time tTime = StringToTime("1372-06-01 13:01:00:000");
/// Assert(tTime.Hour == 13);
/// Assert(tTime.Minute == 1);
///
/// struct Time tGame = TimeToGameTime(tTime);
/// Assert(tGame.Hour == 13);
/// Assert(tGame.Minute == 30);
///
/// struct tBack = GameTimeToTime(tGame);
/// Assert(tTime == tBack);
/// ```
///
/// ## Getting the Current Time
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// struct Time tGame = GetCurrentGameTime();
/// ```
///
/// ## Setting the Current Time
/// @note You can only set the time forward in NWN.
///
/// ```nwscript
/// struct Time t = StringToTime("2022-08-25 13:00:00:000");
/// SetCurrentTime(t);
/// ```
///
/// Alternatively, you can advance the current Time by a duration Time:
/// ```nwscript
/// AdvanceCurrentTime(FloatToDuration(120.0));
/// ```
///
/// ## Dropping units from a Time
/// You can reduce the precision of a Time. Units smaller than the precision
/// limit will be at their lower bound:
/// ```nwscript
/// struct Time a = GetTime(1372, 6, 1, 13);
/// struct Time b = GetTime(1372, 6, 1);
/// struct Time c = GetPrecisionTime(a, TIME_UNIT_DAY);
/// struct Time d = GetPrecisionTime(a, TIME_UNIT_MONTH);
/// Assert(a != b);
/// Assert(b == c);
/// Assert(b == d);
/// ```
///
/// ## Saving a Time
/// The easiest way to save a Time and get it later is to use the
/// `SetLocalTime()` and `GetLocalTime()` functions. These functions convert a
/// Time into json and save it as a local variable.
///
/// In this example, we save the server start time OnModuleLoad and then get it
/// later:
/// ```nwscript
/// // OnModuleLoad
/// SetLocalTime(GetModule(), "ServerStart", GetCurrentTime());
///
/// // later on...
/// struct Time tServerStart = GetLocalTime(GetModule(), "ServerStart");
/// ```
///
/// If you want to store a Time in a database, you can convert it into json or
/// into a string before passing it to a query. The json method is preferable
/// for persistent storage, since it is guaranteed to be correct if the module's
/// minutes per hour setting changes after the value is stored:
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// json jTime = TimeToJson(tTime);
/// string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// SqlBindJson(q, "@time", jTime);
/// SqlStep(q);
/// ```
///
/// You can then convert the json back into a Time:
/// ```nwscript
/// string Time tTime;
/// string sSql = "SELECT value FROM data WHERE varname='ServerTime';";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// if (SqlStep(q))
///     tTime = JsonToTime(SqlGetJson(q, 0));
/// ```
///
/// For simpler applications (such as saving to the module's volatile database),
/// converting to a string works fine and could even be preferable since you can
/// use sqlite's `<`, `>`, and `=` operators to check if one time is before,
/// after, or equal to another.
/// ```nwscript
/// struct Time tTime = GetCurrentTime();
/// string sTime = TimeToString();
/// string sSql = "INSERT INTO data (varname, value) VALUES ('ServerTime', @time);";
/// sqlquery q = SqlPrepareQueryCampaign("mydb", sSql);
/// SqlBindString(q, "@time", sTime);
/// SqlStep(q);
/// ```
///
/// ## Comparing Times
/// To check if one time is before or after another:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:30:500");
/// Assert(GetIsTimeBefore(a, b));
/// Assert(!GetIsTimeAfter(a, b));
/// ```
///
/// To check if two times are equal:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:00:000");
/// struct Time c = TimeToGameTime(b);
///
/// Assert(!GetIsTimeEqual(a, b));
/// Assert(GetIsTimeEqual(b, c));
///
/// // To check for exactly equal:
/// Assert(b != c);
/// ```
///
/// To check the amount of time between two Times:
/// ```nwscript
/// struct Time a = StringToTime("1372-06-01 13:00:00:000");
/// struct Time b = StringToTime("1372-06-01 13:01:30:500");
/// struct Time tDur = GetDurationBetween(a, b);
/// Assert(DurationToFloat(tDur) == 90.5);
/// ```
///
/// To check if a duration has passed since a Time:
/// ```nwscript
/// int CheckForMinRestTime(object oPC, float fMinTime)
/// {
///     struct Time tSince = GetDurationSince(GetLocalTime(oPC, "LastRest"));
///     return DurationToFloat(tSince) >= fMinTime;
/// }
/// ```
///
/// To calculate the duration until a Time is reached:
/// ```nwscript
/// struct Time tMidnight = GetTime(GetCalendarYear(), GetCalendarMonth(), GetCalendarDay() + 1);
/// struct Time tDurToMidnight = GetDurationUntil(tMidnight);
/// float fDurToMidnight = DurationToFloat(tDurToMidnight);
/// ```
/// ----------------------------------------------------------------------------

#include "util_i_strings"
#include "util_i_debug"

// -----------------------------------------------------------------------------
//                                     Types
// -----------------------------------------------------------------------------

/// @struct Time
/// @brief A datatype representing either an amount of time or a moment in time.
/// @note Times with a Type field of TIME_TYPE_DURATION represent an amount of
///     time as represented on a stopwatch. All duration units count from 0.
/// @note Times with a Type field of TIME_TYPE_CALENDAR represent a moment in
///     time as represented on a calendar. This means the month and day count
///     from 1, but all other units count from 0 (including the year, since NWN
///     allows year 0).
struct Time
{
    int Type;        ///< TIME_TYPE_DURATION || TIME_TYPE_CALENDAR
    int Year;        ///< 0..32000
    int Month;       ///< 0..11 for duration Times, 1..12 for calendar Times
    int Day;         ///< 0..27 for duration Times, 1..28 for calendar Times
    int Hour;        ///< 0..23
    int Minute;      ///< 0..MinsPerHour
    int Second;      ///< 0..59
    int Millisecond; ///< 0..999
    int MinsPerHour; ///< The minutes per hour setting: 1..60
};

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// These are the units in a valid Time.
const int TIME_UNIT_YEAR        = 0;
const int TIME_UNIT_MONTH       = 1;
const int TIME_UNIT_DAY         = 2;
const int TIME_UNIT_HOUR        = 3;
const int TIME_UNIT_MINUTE      = 4;
const int TIME_UNIT_SECOND      = 5;
const int TIME_UNIT_MILLISECOND = 6;

// These are the types of Times.
const int TIME_TYPE_DURATION = 0; ///< Represents an amount of time
const int TIME_TYPE_CALENDAR = 1; ///< Represents a moment in time

// Prefix for local variables to avoid collision
const string TIME_PREFIX = "*Time: ";

// These are field names for json objects
const string TIME_TYPE        = "Type";
const string TIME_YEAR        = "Year";
const string TIME_MONTH       = "Month";
const string TIME_DAY         = "Day";
const string TIME_HOUR        = "Hour";
const string TIME_MINUTE      = "Minute";
const string TIME_SECOND      = "Second";
const string TIME_MILLISECOND = "Millisecond";
const string TIME_MINSPERHOUR = "MinsPerHour";

/// Uninitialized Time value. Can be compared to Times returned from functions
/// to see if the Time is valid.
struct Time TIME_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Convert hours to minutes.
/// @param nHours The number of hours to convert.
/// @note The return value varies depending on the module's time settings.
int HoursToMinutes(int nHours = 1);

// ----- Times -----------------------------------------------------------------

/// @brief Return whether any unit in a Time is less than its lower bound.
/// @param t The Time to check.
int GetAnyTimeUnitNegative(struct Time t);

/// @brief Return whether any unit in a Time is greater than its lower bound.
/// @param t The Time to check.
int GetAnyTimeUnitPositive(struct Time t);

/// @brief Return the sign of a Time.
/// @param t The Time to check.
/// @returns 0 if all units equal the lower bound, -1 if any unit is less than
///     the lower bound, or 1 if any unit is greater than the lower bound.
/// @note The Time must be normalized to yield an acurate result.
int GetTimeSign(struct Time t);

/// @brief Create a new calendar Time.
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
struct Time NewTime(int nMinsPerHour = 0);

/// @brief Create a new duration Time.
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
struct Time NewDuration(int nMinsPerHour = 0);

/// @brief Convert a calendar Time into a duration Time.
/// @note This is safe to call on a duration Time.
struct Time TimeToDuration(struct Time t);

/// @brief Convert a duration Time into a calendar Time.
/// @note This is safe to call on a calendar Time.
struct Time DurationToTime(struct Time d);

/// @brief Distribute units in a Time, optionally converting minutes per hour.
/// @details Units that overflow their range have the excess added to the next
///     highest unit (e.g., 1500 msec -> 1 sec, 500 msec). If `nMinsPerHour`
///     does not match `t.MinsPerHour`, the minutes, seconds, and milliseconds
///     will be recalculated to match the new setting.
/// @param t The Time to normalize.
/// @param nMinsPerHour The number of minutes per hour to normalize with. If 0,
///     will use `t.MinsPerHour`.
/// @note If `t` is a duration Time, all non-zero units will be either positive
///     or negative (i.e., not a mix of both).
/// @note If `t` is a calendar Time and any unit in `t` falls outside the bounds
///     after normalization, an invalid Time is returned. You can check for this
///     using GetIsTimeValid().
struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0);

/// @brief Check if any unit in a normalized time is outside its range.
/// @param t The Time to validate.
/// @param bNormalize Whether to normalize the time before checking. You should
///     only set this to FALSE if you know `t` is already normalized and want to
///     save cycles.
/// @returns TRUE if valid, FALSE otherwise.
int GetIsTimeValid(struct Time t, int bNormalize = TRUE);

/// @brief Create a duration Time, representing an amount of time.
/// @note All units count from 0. Negative numbers are allowed.
/// @param nYear The number of years (0..32000).
/// @param nMonth The number of month (0..11).
/// @param nDay The number of day (0..27).
/// @param nHour The number of hours (0..23).
/// @param nMinute The number of minutes (0..nMinsPerHour).
/// @param nSecond The number of seconds (0..59).
/// @param nMillisecond The number of milliseconds (0..999).
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
/// @returns A normalized duration Time.
struct Time GetDuration(int nYears = 0, int nMonths = 0, int nDays = 0, int nHours = 0, int nMinutes = 0, int nSeconds = 0, int nMilliseconds = 0, int nMinsPerHour = 0);

/// @brief Create a calendar Time, representing a moment in time.
/// @param nYear The year (0..32000).
/// @param nMonth The month of the year (1..12).
/// @param nDay The day of the month (1..28).
/// @param nHour The hour (0..23).
/// @param nMinute The minute (0..nMinsPerHour).
/// @param nSecond The second (0..59).
/// @param nMillisecond The millisecond (0..999).
/// @param nMinsPerHour The number of minutes per hour (1..60). If 0, will use
///     the module's default setting.
/// @returns A normalized calendar Time.
struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0);

/// @brief Convert a Time to an in-game time (i.e., 60 minutes per hour).
/// @param t The Time to convert.
/// @note Alias for NormalizeTime(t, 60).
struct Time TimeToGameTime(struct Time t);

/// @brief Convert an in-game time (i.e., 60 minutes per hour) to a Time.
/// @param t The Time to convert.
/// @note Alias for NormalizeTime(t, HoursToMinutes()).
struct Time GameTimeToTime(struct Time t);

/// @brief Add a Time to another.
/// @param a The Time to modify.
/// @param b The Time to add.
/// @returns A Time of the same type and minutes per hour as `a`.
/// @note You can safely mix calendar or duration Times, as well as Times with
///     different minutes per hour settings.
struct Time AddTime(struct Time a, struct Time b);

/// @brief Subtract a Time from another.
/// @param a The Time to modify.
/// @param b The Time to subtract.
/// @returns A Time of the same type and minutes per hour as `a`.
/// @note You can safely mix calendar or duration Times, as well as Times with
///     different minutes per hour settings.
struct Time SubtractTime(struct Time a, struct Time b);

/// @brief Get the current calendar date and clock time as a calendar Time.
/// @note A calendar Time with a `MinsPerHour` matching to the module's setting.
struct Time GetCurrentTime();

/// @brief Get the current calendar date and in-game time as a calendar Time.
/// @returns A calendar Time with a `MinsPerHour` of 60.
/// @note Alias for TimeToGameTime(GetCurrentTime()).
struct Time GetCurrentGameTime();

/// @brief Set the current calendar date and clock time.
/// @param t The time to set the calendar and clock to. Must be a valid calendar
///     Time that is after the current time.
void SetCurrentTime(struct Time t);

/// @brief Set the current calendar date and clock time forwards.
/// @param d A duration Time by which to advance the time. Must be positive.
void AdvanceCurrentTime(struct Time d);

/// @brief Drop smaller units from a Time.
/// @param t The Time to modify.
/// @param nUnit A TIME_UNIT_* constant representing the maximum precision.
///     Units more precise than this are set to their lowest value.
struct Time GetPrecisionTime(struct Time t, int nUnit);

/// @brief Get the duration of the interval between two Times.
/// @param a The calendar Time at the start of interval.
/// @param b The calendar Time at the end of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationBetween(struct Time tStart, struct Time tEnd);

/// @brief Get the duration of the interval between a Time and the current time.
/// @param tSince The Time at the start of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationSince(struct Time tSince);

/// @brief Get the duration of the interval between the current time and a Time.
/// @param tUntil The Time at the end of the interval.
/// @returns A normalized duration Time. The duration will be negative if a is
///     after b and positive if b is after a. If the times are equivalent, the
///     duration will equal 0.
struct Time GetDurationUntil(struct Time tUntil);

/// @brief Compare two Times and find which is later.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns 0 if a == b, -1 if a < b, and 1 if a > b.
int CompareTime(struct Time a, struct Time b);

/// @brief Check whether a Time is after another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is after b, FALSE otherwise
int GetIsTimeAfter(struct Time a, struct Time b);

/// @brief Check whether a Time is before another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is before b, FALSE otherwise
int GetIsTimeBefore(struct Time a, struct Time b);

/// @brief Check whether a Time is equal to another Time.
/// @param a The Time to check.
/// @param b The Time to check against.
/// @returns TRUE if a is equivalent to b, FALSE otherwise.
/// @note This checks if the normalized Times represent equal moments in time.
///     If you want to instead check if two Time structs are exactly equal, use
///     `a == b`.
int GetIsTimeEqual(struct Time a, struct Time b);

// ----- Float Conversion ------------------------------------------------------

/// @brief Convert years to seconds.
/// @param nYears The number of years to convert.
float Years(int nYears);

/// @brief Convert months to seconds.
/// @param nMonths The number of months to convert.
float Months(int nMonths);

/// @brief Convert days to seconds.
/// @param nDays The number of days to convert.
float Days(int nDays);

/// @brief Convert hours to seconds.
/// @param nHours The number of hours to convert.
float Hours(int nHours);

/// @brief Convert minutes to seconds.
/// @param nMinutes The number of minutes to convert.
float Minutes(int nMinutes);

/// @brief Convert seconds to seconds.
/// @param nSeconds The number of seconds to convert.
float Seconds(int nSeconds);

/// @brief Convert milliseconds to seconds.
/// @param nYears The number of milliseconds to convert.
float Milliseconds(int nMilliseconds);

/// @brief Convert a duration Time to a float.
/// @param d The duration Time to convert.
/// @returns A float representing the number of seconds in `t`. Always has a
///     minutes per hour setting equal to the module's.
/// @note Use this function to pass a Time to a function like DelayCommand().
/// @note Long durations may lose precision when converting. Use with caution.
float DurationToFloat(struct Time d);

/// @brief Convert a float to a duration Time.
/// @param fDur A float representing a number of seconds.
/// @returns A duration Time with a minutes per hour setting equal to the
///     module's.
struct Time FloatToDuration(float fDur);

// ----- Json Conversion -------------------------------------------------------

/// @brief Convert a Time into a json object.
/// @details The json object will have a key for each field of the Time struct.
///     Since this includes the minutes per hour setting, this object is safe to
///     be stored in a database if it is possible the module's minutes per hour
///     setting will change. The object can be converted back using
///     JsonToTime().
/// @param t The Time to convert
json TimeToJson(struct Time t);

/// @brief Convert a json object into a Time.
/// @param j The json object to convert.
struct Time JsonToTime(json j);

// ----- Local Variables -------------------------------------------------------

/// @brief Return a Time from a local variable.
/// @param oObject The object to get the local variable from.
/// @param sVarName The varname for the local variable.
struct Time GetLocalTime(object oObject, string sVarName);

/// @brief Store a Time as a local variable.
/// @param oObject The object to store the local variable on.
/// @param sVarName The varname for the local variable.
/// @param tValue The Time to store.
void SetLocalTime(object oObject, string sVarName, struct Time tValue);

/// @brief Delete a Time from a local variable.
/// @param oObject The object to delete the local variable from.
/// @param sVarName The varname for the local variable.
void DeleteLocalTime(object oObject, string sVarName);

// ----- String Conversions ----------------------------------------------------

/// @brief Convert a Time into a string.
/// @param t The Time to convert.
/// @param bNormalize Whether to normalize the Time before converting.
/// @returns An ISO 8601 formatted datetime, e.g., "1372-06-01 13:00:00:000".
/// @note If `t` is a duration Time and is negative, the returned value will be
///     preceded by a `-` character.
string TimeToString(struct Time t, int bNormalize = TRUE);

/// @brief Convert an ISO 8601 formatted datetime string into a calendar Time.
/// @param sTime The string to convert.
/// @param nMinsPerHour The number of minutes per hour expected in the Time. If
///     0, will use the module setting.
/// @note The returned Time is not normalized.
/// @note If the first character in `sTime` is a `-`, all values will be treated
///     as negative. This will make the returned Time invalid when normalized.
struct Time StringToTime(string sTime, int nMinsPerHour = 0);

/// @brief Convert an ISO 8601 formatted datetime string into a duration Time.
/// @param sTime The string to convert.
/// @param nMinsPerHour The number of minutes per hour expected in the Time. If
///     0, will use the module setting.
/// @note The returned Time is not normalized.
/// @note If the first character in `sTime` is a `-`, all values will be treated
///     as negative.
struct Time StringToDuration(string sTime, int nMinsPerHour = 0);

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int HoursToMinutes(int nHours = 1)
{
    return FloatToInt(HoursToSeconds(nHours)) / 60;
}

// ----- Times -----------------------------------------------------------------

int GetAnyTimeUnitNegative(struct Time t)
{
    return t.Year < 0 || t.Month < t.Type || t.Day < t.Type ||
           t.Hour < 0 || t.Minute < 0 || t.Second < 0 || t.Millisecond < 0;
}

int GetAnyTimeUnitPositive(struct Time t)
{
    return t.Year > 0 || t.Month > t.Type || t.Day > t.Type ||
           t.Hour > 0 || t. Minute > 0 || t.Second > 0 || t.Millisecond > 0;
}

int GetTimeSign(struct Time t)
{
    return GetAnyTimeUnitNegative(t) ? -1 : GetAnyTimeUnitPositive(t) ? 1 : 0;
}

struct Time NewTime(int nMinsPerHour = 0)
{
    struct Time t;
    t.Type = TIME_TYPE_CALENDAR;
    t.MinsPerHour = nMinsPerHour <= 0 ? HoursToMinutes() : clamp(nMinsPerHour, 1, 60);
    t.Month = 1;
    t.Day   = 1;
    return t;
}

struct Time NewDuration(int nMinsPerHour = 0)
{
    struct Time t;
    t.Type = TIME_TYPE_DURATION;
    t.MinsPerHour = nMinsPerHour <= 0 ? HoursToMinutes() : clamp(nMinsPerHour, 1, 60);
    return t;
}

struct Time TimeToDuration(struct Time t)
{
    t.Day   -= t.Type;
    t.Month -= t.Type;
    t.Type   = TIME_TYPE_DURATION;
    return t;
}

struct Time DurationToTime(struct Time d)
{
    d.Day   += (1 - d.Type);
    d.Month += (1 - d.Type);
    d.Type   = TIME_TYPE_CALENDAR;
    return d;
}

struct Time NormalizeTime(struct Time t, int nMinsPerHour = 0)
{
    // Convert everything to a duration for ease of calculation
    int nType = t.Type;
    t = TimeToDuration(t);

    // If the conversion factor was not set, we assume it's using the module's.
    if (t.MinsPerHour <= 0)
        t.MinsPerHour = HoursToMinutes();

    // If this is > 0, we will adjust the time's conversion factor to match the
    // requested value. Otherwise, assume we're using the same conversion factor
    // and just prettifying units.
    nMinsPerHour = nMinsPerHour > 0 ? clamp(nMinsPerHour, 1, 60) : t.MinsPerHour;

    if (t.MinsPerHour != nMinsPerHour)
    {
        // Convert everything to milliseconds so we don't lose precision when
        // converting to a smaller mins-per-hour.
        t.Millisecond += (t.Minute * 60 + t.Second) * 1000;
        t.Millisecond = t.Millisecond * nMinsPerHour / t.MinsPerHour;
        t.Second = 0;
        t.Minute = 0;
        t.MinsPerHour = nMinsPerHour;
    }

    // Distribute units.
    int nFactor;
    if (abs(t.Millisecond) >= (nFactor = 1000))
    {
        t.Second += t.Millisecond / nFactor;
        t.Millisecond %= nFactor;
    }

    if (abs(t.Second) >= (nFactor = 60))
    {
        t.Minute += t.Second / nFactor;
        t.Second %= nFactor;
    }

    if (abs(t.Minute) >= (nFactor = t.MinsPerHour))
    {
        t.Hour += t.Minute / nFactor;
        t.Minute %= nFactor;
    }

    if (abs(t.Hour) >= (nFactor = 24))
    {
        t.Day += t.Hour / nFactor;
        t.Hour %= nFactor;
    }

    if (abs(t.Day) >= (nFactor = 28))
    {
        t.Month += t.Day / nFactor;
        t.Day %= nFactor;
    }

    if (abs(t.Month) >= (nFactor = 12))
    {
        t.Year += t.Month / nFactor;
        t.Month %= nFactor;
    }

    // A mix of negative and positive units means we need to consolidate and
    // re-normalize.
    if (GetAnyTimeUnitPositive(t) && GetAnyTimeUnitNegative(t))
    {
        struct Time d = NewDuration(t.MinsPerHour);
        d.Millisecond = (t.Minute * 60 + t.Second) * 1000 + t.Millisecond;
        d.Hour = ((t.Year * 12 + t.Month) * 28 + t.Day) * 24 + t.Hour;

        // If that didn't fix it, borrow a unit
        if ((d.Millisecond >= 0) != (d.Hour >= 0))
        {
            d.Millisecond += sign(d.Hour) * 1000 * 60 * d.MinsPerHour;
            d.Hour -= sign(d.Hour);
        }

        t = NormalizeTime(d);
    }

    // Convert back to a calendar Time if needed.
    if (nType)
    {
        if (GetAnyTimeUnitNegative(t))
            return TIME_INVALID;

        return DurationToTime(t);
    }

    return t;
}

int GetIsTimeValid(struct Time t, int bNormalize = TRUE)
{
    if (bNormalize)
        t = NormalizeTime(t);
    return t != TIME_INVALID;
}

struct Time GetDuration(int nYears = 0, int nMonths = 0, int nDays = 0, int nHours = 0, int nMinutes = 0, int nSeconds = 0, int nMilliseconds = 0, int nMinsPerHour = 0)
{
    struct Time d = NewDuration(nMinsPerHour);
    d.Year        = nYears;
    d.Month       = nMonths;
    d.Day         = nDays;
    d.Hour        = nHours;
    d.Minute      = nMinutes;
    d.Second      = nSeconds;
    d.Millisecond = nMilliseconds;
    return NormalizeTime(d);
}

struct Time GetTime(int nYear = 0, int nMonth = 1, int nDay = 1, int nHour = 0, int nMinute = 0, int nSecond = 0, int nMillisecond = 0, int nMinsPerHour = 0)
{
    struct Time t = NewTime(nMinsPerHour);
    t.Year        = nYear;
    t.Month       = nMonth;
    t.Day         = nDay;
    t.Hour        = nHour;
    t.Minute      = nMinute;
    t.Second      = nSecond;
    t.Millisecond = nMillisecond;
    return NormalizeTime(t);
}

struct Time TimeToGameTime(struct Time t)
{
    return NormalizeTime(t, 60);
}

struct Time GameTimeToTime(struct Time t)
{
    return NormalizeTime(t, HoursToMinutes());
}

struct Time AddTime(struct Time a, struct Time b)
{
    // Convert everything to a duration to ensure even comparison
    int nType = a.Type;
    a = NormalizeTime(TimeToDuration(a));
    b = NormalizeTime(TimeToDuration(b), a.MinsPerHour);

    a.Year        += b.Year;
    a.Month       += b.Month;
    a.Day         += b.Day;
    a.Hour        += b.Hour;
    a.Minute      += b.Minute;
    a.Second      += b.Second;
    a.Millisecond += b.Millisecond;

    // Convert back to calendar time if needed
    if (nType)
        a = DurationToTime(a);

    return NormalizeTime(a);
}

struct Time SubtractTime(struct Time a, struct Time b)
{
    // Convert everything to a duration to ensure even comparison
    int nType = a.Type;
    a = NormalizeTime(TimeToDuration(a));
    b = NormalizeTime(TimeToDuration(b), a.MinsPerHour);

    a.Year        -= b.Year;
    a.Month       -= b.Month;
    a.Day         -= b.Day;
    a.Hour        -= b.Hour;
    a.Minute      -= b.Minute;
    a.Second      -= b.Second;
    a.Millisecond -= b.Millisecond;

    // Convert back to calendar time if needed
    if (nType)
        a = DurationToTime(a);

    return NormalizeTime(a);
}

struct Time GetCurrentTime()
{
    struct Time t = NewTime();
    t.Year        = GetCalendarYear();
    t.Month       = GetCalendarMonth();
    t.Day         = GetCalendarDay();
    t.Hour        = GetTimeHour();
    t.Minute      = GetTimeMinute();
    t.Second      = GetTimeSecond();
    t.Millisecond = GetTimeMillisecond();
    return t;
}

struct Time GetCurrentGameTime()
{
    return TimeToGameTime(GetCurrentTime());
}

void SetCurrentTime(struct Time t)
{
    t = NormalizeTime(t, HoursToMinutes());
    struct Time tCurrent = GetCurrentTime();
    if (GetIsTimeAfter(t, tCurrent))
    {
        SetTime(t.Hour, t.Minute, t.Second, t.Millisecond);
        SetCalendar(t.Year, t.Month, t.Day);
    }
    else
    {
        CriticalError("Cannot set time to " + TimeToString(t, FALSE) + " " +
                      "because it is before " + TimeToString(tCurrent));
    }
}

void AdvanceCurrentTime(struct Time d)
{
    int nSign = GetTimeSign(d);
    if (nSign > 0)
    {
        d = AddTime(GetCurrentTime(), d);
        SetTime(d.Hour, d.Minute, d.Second, d.Millisecond);
        SetCalendar(d.Year, d.Month, d.Day);
    }
    else if (nSign < 0)
        CriticalError("Cannot advance time by a negative amount");
}

struct Time GetPrecisionTime(struct Time t, int nUnit)
{
    while (nUnit < TIME_UNIT_MILLISECOND)
    {
        switch (++nUnit)
        {
            case TIME_UNIT_YEAR:        t.Year        = 0;           break;
            case TIME_UNIT_MONTH:       t.Month       = 0  + t.Type; break;
            case TIME_UNIT_DAY:         t.Day         = 0  + t.Type; break;
            case TIME_UNIT_HOUR:        t.Hour        = 0;           break;
            case TIME_UNIT_MINUTE:      t.Minute      = 0;           break;
            case TIME_UNIT_SECOND:      t.Second      = 0;           break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = 0;           break;
        }
    }

    return t;
}

struct Time GetDurationBetween(struct Time tStart, struct Time tEnd)
{
    // Convert to duration before passing to ensure we get a duration back
    return SubtractTime(TimeToDuration(tEnd), tStart);
}

struct Time GetDurationSince(struct Time tSince)
{
    return GetDurationBetween(tSince, GetCurrentTime());
}

struct Time GetDurationUntil(struct Time tUntil)
{
    return GetDurationBetween(tUntil, GetCurrentTime());
}

int CompareTime(struct Time a, struct Time b)
{
    return GetTimeSign(GetDurationBetween(b, a));
}

int GetIsTimeAfter(struct Time a, struct Time b)
{
    return CompareTime(a, b) > 0;
}

int GetIsTimeBefore(struct Time a, struct Time b)
{
    return CompareTime(a, b) < 0;
}

int GetIsTimeEqual(struct Time a, struct Time b)
{
    return !CompareTime(a, b);
}

// ----- Float Conversion ------------------------------------------------------

float Years(int nYears)
{
    return HoursToSeconds(nYears * 12 * 28 * 24);
}

float Months(int nMonths)
{
    return HoursToSeconds(nMonths * 28 * 24);
}

float Days(int nDays)
{
    return HoursToSeconds(nDays * 24);
}

float Hours(int nHours)
{
    return HoursToSeconds(nHours);
}

float Minutes(int nMinutes)
{
    return nMinutes * 60.0;
}

float Seconds(int nSeconds)
{
    return IntToFloat(nSeconds);
}

float Milliseconds(int nMilliseconds)
{
    return nMilliseconds / 1000.0;
}

float DurationToFloat(struct Time d)
{
    d = NormalizeTime(TimeToDuration(d), HoursToMinutes());
    return Years(d.Year) + Months(d.Month) + Days(d.Day) + Hours(d.Hour) +
        Minutes(d.Minute) + Seconds(d.Second) + Milliseconds(d.Millisecond);
}

struct Time FloatToDuration(float fDur)
{
    struct Time t = NewDuration(HoursToMinutes());
    t.Millisecond = FloatToInt(frac(fDur) * 1000);
    t.Second      = FloatToInt(fmod(fDur, 60.0));
    t.Minute      = FloatToInt(fDur / 60) % t.MinsPerHour;
    int nHours    = FloatToInt(fDur / HoursToSeconds(1));
    t.Hour        = nHours % 24;
    t.Day         = (nHours / 24) % 28;
    t.Month       = (nHours / 24 / 28) % 12;
    t.Year        = (nHours / 24 / 28 / 12);
    return t;
}

// ----- Json Conversion -------------------------------------------------------

json TimeToJson(struct Time t)
{
    json j = JsonObject();
    j = JsonObjectSet(j, TIME_TYPE,        JsonInt(t.Type));
    j = JsonObjectSet(j, TIME_YEAR,        JsonInt(t.Year));
    j = JsonObjectSet(j, TIME_MONTH,       JsonInt(t.Month));
    j = JsonObjectSet(j, TIME_DAY,         JsonInt(t.Day));
    j = JsonObjectSet(j, TIME_HOUR,        JsonInt(t.Hour));
    j = JsonObjectSet(j, TIME_MINUTE,      JsonInt(t.Minute));
    j = JsonObjectSet(j, TIME_SECOND,      JsonInt(t.Second));
    j = JsonObjectSet(j, TIME_MILLISECOND, JsonInt(t.Millisecond));
    j = JsonObjectSet(j, TIME_MINSPERHOUR, JsonInt(t.MinsPerHour));
    return j;
}

struct Time JsonToTime(json j)
{
    if (JsonGetType(j) != JSON_TYPE_OBJECT)
        return TIME_INVALID;

    struct Time t;
    t.Type        = JsonGetInt(JsonObjectGet(j, TIME_TYPE));
    t.Year        = JsonGetInt(JsonObjectGet(j, TIME_YEAR));
    t.Month       = JsonGetInt(JsonObjectGet(j, TIME_MONTH));
    t.Day         = JsonGetInt(JsonObjectGet(j, TIME_DAY));
    t.Hour        = JsonGetInt(JsonObjectGet(j, TIME_HOUR));
    t.Minute      = JsonGetInt(JsonObjectGet(j, TIME_MINUTE));
    t.Second      = JsonGetInt(JsonObjectGet(j, TIME_SECOND));
    t.Millisecond = JsonGetInt(JsonObjectGet(j, TIME_MILLISECOND));
    t.MinsPerHour = JsonGetInt(JsonObjectGet(j, TIME_MINSPERHOUR));
    return t;
}

// ----- Local Variables -------------------------------------------------------

struct Time GetLocalTime(object oObject, string sVarName)
{
    return JsonToTime(GetLocalJson(oObject, TIME_PREFIX + sVarName));
}

void SetLocalTime(object oObject, string sVarName, struct Time tValue)
{
    SetLocalJson(oObject, TIME_PREFIX + sVarName, TimeToJson(tValue));
}

void DeleteLocalTime(object oObject, string sVarName)
{
    DeleteLocalJson(oObject, TIME_PREFIX + sVarName);
}

// ----- String Conversions ----------------------------------------------------

string TimeToString(struct Time t, int bNormalize = TRUE)
{
    if (bNormalize)
        t = NormalizeTime(t);

    json j = JsonArray();
    j = JsonArrayInsert(j, JsonString(t.Type || GetTimeSign(t) >= 0 ? "" : "-"));
    j = JsonArrayInsert(j, JsonInt(abs(t.Year)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Month)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Day)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Hour)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Minute)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Second)));
    j = JsonArrayInsert(j, JsonInt(abs(t.Millisecond)));
    return FormatValues(j, "%s%04d-%02d-%02d %02d:%02d:%02d:%03d");
}

struct Time _StringToTime(string sTime, struct Time t)
{
    if (sTime == "")
        return TIME_INVALID;

    string sDelims = "-- :::";
    int nUnit = TIME_UNIT_YEAR;
    int nPos, nLength = GetStringLength(sTime);
    int nSign = 1;

    // Strip off an initial "-"
    if (GetChar(sTime, 0) == "-")
    {
        nSign = -1;
        nPos++;
    }

    while (nPos < nLength)
    {
        string sDelim, sToken, sChar;
        while (HasSubString(CHARSET_NUMERIC, (sChar = GetChar(sTime, nPos++))))
            sToken += sChar;

        if (GetStringLength(sToken) < 1)
            return TIME_INVALID;

        // If the first character was a -, all subsequent values are negative
        int nToken = StringToInt(sToken) * nSign;
        switch (nUnit)
        {
            case TIME_UNIT_YEAR:        t.Year        = nToken; break;
            case TIME_UNIT_MONTH:       t.Month       = nToken; break;
            case TIME_UNIT_DAY:         t.Day         = nToken; break;
            case TIME_UNIT_HOUR:        t.Hour        = nToken; break;
            case TIME_UNIT_MINUTE:      t.Minute      = nToken; break;
            case TIME_UNIT_SECOND:      t.Second      = nToken; break;
            case TIME_UNIT_MILLISECOND: t.Millisecond = nToken; break;
            default:
                return TIME_INVALID;
        }

        // Check if we encountered a delimiter with no characters following.
        if (nPos == nLength && sChar != "")
            return TIME_INVALID;

        // If we run out of characters before we've parsed all the units, we can
        // return the partial time. However, if we run into an unexpected
        // character, we should yield an invalid time.
        if (sChar != GetChar(sDelims, nUnit++))
        {
            if (sChar == "")
                return t;
            return TIME_INVALID;
        }
    }

    return t;
}

struct Time StringToTime(string sTime, int nMinsPerHour = 0)
{
    return _StringToTime(sTime, NewTime(nMinsPerHour));
}

struct Time StringToDuration(string sTime, int nMinsPerHour = 0)
{
    return _StringToTime(sTime, NewDuration(nMinsPerHour));
}
/// ----------------------------------------------------------------------------
/// @file   util_i_unittest.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing unit test reporting.
/// ----------------------------------------------------------------------------
/// @details
///
/// Variable Conventions:
///
/// Tests can be written in just about any format, however since tests tend to be
///     repetitive, having a variable and formatting convention can make building
///     multiple tests quick and easy.  Following are variable naming conventions
///     and an example that showcases how to use them.
///
///     Variable Naming:
///         ix - Function Input Variables
///         ex - Expected Function Result Variables
///         rx - Actual Function Result Variables
///         bx - Boolean Test Result Variables
///         tx - Timer Variables
///
///     Convenience Functions:
///         _i : IntToString
///         _f : FloatToString; Rounds to significant digits
///         _b : Returns `True` or `False` (literals)
///
///         _q  : Returns string wrapped in single quotes
///         _qq : Returns string wrapped in double quotes
///         _p  : Returns string wrapped in parenthesis
///
///     Timers:
///         To start a timer:
///             t1 = Timer();   : Sets timer variable `t1` to GetMicrosecondCounter()
///
///         To end a timer and save the results:
///             t1 = Timer(t1); : Sets timer variable `t1` to GetMicrosecondCounter() - t1
/// 
/// The following example shows how to create a grouped assertion and display
///     only relevant results, assuming only assertion failures are of
///     interest.  If you always want to see expanded results regardless of test
///     outcome, set UNITTEST_ALWAYS_EXPAND to TRUE in `util_c_unittest`.
///
/// For example purposes only, this unit test sample code will run a unittest
///     against the following function, which will return:
///         -1, if n <= 0
///         20 * n, if 0 < n <= 3
///         100, if n > 3
///
/// ```nwscript
/// int unittest_demo_ConvertValue(int n)
/// {
///     return n <= 0 ? -1 : n > 3 ? 100 : 20 * n;
/// }
/// ```
///
/// The following unit test will run against the function above for three test cases:
///     - Out of bounds (low) -> n <= 0;
///     - In bounds -> 0 < n <= 3;
///     - Out of bounds (high) -> n > 3;
///
/// ```nwscript
/// int unittest_ConvertValue()
/// {
///     int i1, i2, i3;
///     int e1, e2, e3;
///     int r1, r2, r3;
///     int b1, b2, b3, b;
///     int t1, t2, t3, t;
/// 
///     // Setup the input values
///     i1 = -10;
///     i2 = 2;
///     i3 = 12;
/// 
///     // Setup the expected return values 
///     e1 = -1;
///     e2 = 40;
///     e3 = 100;
/// 
///     // Run the unit tests with timers
///     t = Timer();
///     t1 = Timer(); r1 = unittest_demo_ConvertValue(i1); t1 = Timer(t1);
///     t2 = Timer(); r2 = unittest_demo_ConvertValue(i2); t2 = Timer(t2);
///     t3 = Timer(); r3 = unittest_demo_ConvertValue(i3); t3 = Timer(t3);
///     t = Timer(t);
/// 
///     // Populate the results
///     b = (b1 = r1 == e1) &
///         (b2 = r2 == e2) &
///         (b3 = r3 == e3);
/// 
///     // Display the result
///     if (!AssertGroup("ConvertValue()", b))
///     {
///         if (!Assert("Out of bounds (low)", b1))
///             DescribeTestParameters(_i(i1), _i(e1), _i(r1));
///         DescribeTestTime(t1);
/// 
///         if (!Assert("In bounds", b2))
///             DescribeTestParameters(_i(i2), _i(e2), _i(r2));
///         DescribeTestTime(t2);
/// 
///         if (!Assert("Out of bounds (high)", b3))
///             DescribeTestParameters(_i(i3), _i(e3), _i(r3));
///         DescribeTestTime(t3);
///     } DescribeGroupTime(t); Outdent();
/// }
/// Note:  Use of ResetIndent() or another indentation function, such as
/// Outdent(), may be required if moving to another group assertion.

#include "util_c_unittest"
#include "util_i_strings"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

string TEST_INDENT = "TEST_INDENT";

string TEST_PASS      = HexColorString("PASS", COLOR_GREEN_LIGHT);
string TEST_FAIL      = HexColorString("FAIL", COLOR_RED_LIGHT);
string TEST_DELIMITER = HexColorString(" | ", COLOR_WHITE);

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Establishes or calculates a timer or elapsed value.
/// @param t Previous timer value derived from this function.
/// @note Calling this function without parameter `t` specified will
///     return a starting value in microseconds.  When the code in
///     question has been run, call this function again and pass
///     the previously returned value as parameter `t` to calculate
///     the total elapsed time for between calls to this function.
int Timer(int t = 0);

/// @brief Reset the indentation level used in displaying test results.
/// @returns The indenation string used to pad test result output.
string ResetIndent();

/// @brief Indent test results display by one indentation level.
/// @param bReset If TRUE, will reset the indentation level to 0 before
///     adding an indentation level.
/// @returns The indenation string used to pad test result output.
string Indent(int bReset = FALSE);

/// @brief Outdent test results display by one indentation level.
/// @returns The indenation string used to pad test result output.
string Outdent();

/// @brief Provide a test suite description.
/// @param sDescription The description to display.
/// @note Test suite description will always display at indentation level
///     0 and will reset the indentation level for the subsequest assertions.
void DescribeTestSuite(string sDescription);

/// @brief Provide a test group description.
/// @param sDescription The description to display.
/// @note Test groups are used to minimize unit test output if all tests
///     within a group pass. This function only provides a header for the
///     test group. To provide a test group description combined with
///     test group ouput, use AssertGroup().
void DescribeTestGroup(string sDescription);

/// @brief Display the parameter used in a test.
/// @param sInput The input data.
/// @param sExpected The expected test result.
/// @param sReceived The actual test result.
/// @note Each paramater is optional. If any parameter is an empty string,
///     that parameter will not be output.
void DescribeTestParameters(string sInput = "", string sExpected = "", string sReceived = "");

/// @brief Display function timer result.
/// @param nTime Function timer result, in microseconds.
/// @note This function is intended to use output from GetMicrosecondCounter().
void DescribeTestTime(int nTime);

/// @brief Display function timer result.
/// @param nTime Function timer result, in microseconds.
/// @note This function is intended to use output from GetMicrosecondCounter().
void DescribeGroupTime(int nTime);

/// @brief Display the results of a unit test.
/// @param sTest The name of the unit test.
/// @param bAssertion The results of the unit test.
/// @returns The results of the unit test.
int Assert(string sTest, int bAssertion);

/// @brief Display the results of a group test.
/// @param sTest The name of the group test.
/// @param bAssertion The results of the group test.
/// @returns The results of the group test.
int AssertGroup(string sGroup, int bAssertion);

// -----------------------------------------------------------------------------
//                        Private Function Implementations
// -----------------------------------------------------------------------------

string _GetIndent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    string sIndent;
    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    if (nIndent == 0)
        return "";

    while (nIndent-- > 0)
        sIndent += "  ";

    return sIndent;
}

// -----------------------------------------------------------------------------
//                        Public Function Implementations
// -----------------------------------------------------------------------------

string _i(int n)     { return IntToString(n); }
string _f(float f)   { return FormatFloat(f, "%!f"); }
string _b(int b)     { return b ? "True" : "False"; }

string _q(string s)  { return "'" + s + "'"; }
string _qq(string s) { return "\"" + s + "\""; }
string _p(string s)  { return "(" + s + ")"; }

int Timer(int t = 0)
{
    return GetMicrosecondCounter() - t;
}

string ResetIndent()
{
    DeleteLocalInt(GetModule(), TEST_INDENT);
    return _GetIndent();
}

string Indent(int bReset = FALSE)
{
    if (bReset)
        ResetIndent();

    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    SetLocalInt(GetModule(), TEST_INDENT, ++nIndent);
    return _GetIndent();
}

string Outdent()
{
    int nIndent = GetLocalInt(GetModule(), TEST_INDENT);
    SetLocalInt(GetModule(), TEST_INDENT, max(0, --nIndent));
    return _GetIndent();
}

void DescribeTestSuite(string sDescription)
{
    sDescription = HexColorString("Test Suite ", UNITTEST_TITLE_COLOR) +
        HexColorString(sDescription, UNITTEST_NAME_COLOR);
    Indent(TRUE);
    HandleUnitTestOutput(sDescription);
}

void DescribeTestGroup(string sDescription)
{
    sDescription = HexColorString("Test Group ", UNITTEST_TITLE_COLOR) +
        HexColorString(sDescription, UNITTEST_NAME_COLOR);
    HandleUnitTestOutput(_GetIndent() + sDescription);
    Indent();
}

void DescribeTestParameters(string sInput, string sExpected, string sReceived)
{
    Indent();
    if (sInput != "")
    {
        json jInput = JsonParse(sInput);
        if (jInput != JSON_NULL && JsonGetLength(jInput) > 0)
        {
            if (JsonGetType(jInput) == JSON_TYPE_ARRAY)
            {
                string s = "WITH atoms AS (SELECT atom FROM json_each(@json)) " +
                           "SELECT group_concat(atom, ' | ') FROM atoms;";
                sqlquery q = SqlPrepareQueryObject(GetModule(), s);
                SqlBindJson(q, "@json", jInput);
                sInput = SqlStep(q) ? SqlGetString(q, 0) : sInput;
            }
            else if (JsonGetType(jInput) == JSON_TYPE_OBJECT)
            {
                string s = "WITH kvps AS (SELECT key, value FROM json_each(@json)) " +
                           "SELECT group_concat(key || ' = ' || (IFNULL(value, '\"\"\"\"')), ' | ') FROM kvps;";
                sqlquery q = SqlPrepareQueryObject(GetModule(), s);
                SqlBindJson(q, "@json", jInput);
                sInput = SqlStep(q) ? SqlGetString(q, 0) : sInput;
            }

            sInput = RegExpReplace("(?:^|\\| )(.*?)(?= =)", sInput, HexToColor(COLOR_BLUE_STEEL) + "$&</c>");
            sInput = RegExpReplace("\\||=", sInput, HexToColor(COLOR_WHITE) + "$&</c>");
        }

        sInput = _GetIndent() + HexColorString("Input: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sInput, UNITTEST_PARAMETER_INPUT);

        HandleUnitTestOutput(sInput);
    }

    if (sExpected != "")
    {
        sExpected = _GetIndent() + HexColorString("Expected: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sExpected, UNITTEST_PARAMETER_INPUT);

        HandleUnitTestOutput(sExpected);
    }

    if (sReceived != "")
    {
        sReceived = _GetIndent() + HexColorString("Received: ", UNITTEST_PARAMETER_COLOR) +
            HexColorString(sReceived, UNITTEST_PARAMETER_RECEIVED);

        HandleUnitTestOutput(sReceived);
    }
    Outdent();
}

void DescribeTestTime(int nTime)
{
    if (nTime <= 0)
        return;

    Indent();
    string sTimer = _f(nTime / 1000000.0);
    string sTime = _GetIndent() + HexColorString("Test Time: ", UNITTEST_PARAMETER_COLOR) +
        HexColorString(sTimer + "s", UNITTEST_PARAMETER_INPUT);
    Outdent();

    HandleUnitTestOutput(sTime);
}

void DescribeGroupTime(int nTime)
{
    if (nTime <= 0)
        return;

    string sTimer = _f(nTime / 1000000.0);
    string sTime = _GetIndent() + HexColorString("Group Time: ", UNITTEST_PARAMETER_COLOR) +
        HexColorString(sTimer + "s", UNITTEST_PARAMETER_INPUT);

    HandleUnitTestOutput(sTime);
}

int Assert(string sTest, int bAssertion)
{
    sTest = HexColorString("Test ", UNITTEST_TITLE_COLOR) +
        HexColorString(sTest, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sTest + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));

    if (!bAssertion)
        HandleUnitTestFailure(sTest);

    return UNITTEST_ALWAYS_EXPAND ? FALSE : bAssertion;
}

int AssertGroup(string sGroup, int bAssertion)
{
    sGroup = HexColorString("Test Group ", UNITTEST_TITLE_COLOR) +
        HexColorString(sGroup, UNITTEST_NAME_COLOR);

    HandleUnitTestOutput(_GetIndent() + sGroup + TEST_DELIMITER + (bAssertion ? TEST_PASS : TEST_FAIL));
    Indent();

    if (!bAssertion)
        HandleUnitTestFailure(sGroup);

    return UNITTEST_ALWAYS_EXPAND ? FALSE : bAssertion;
}
/// ----------------------------------------------------------------------------
/// @file   util_i_variables.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for managing database variables.
/// ----------------------------------------------------------------------------

/// @details The functions in this include are meant to complement and extend
/// the game's basic variable handling functions, such as GetLocalInt() and
/// SetLocalString().  These functions allow variable storage in the module's
/// volatile sqlite database, the module's persistent campaign database, and the
/// player's sqlite database, as well as movement of variables to and from game
/// objects and various databases.  Configuration options for this utility can be
/// set in `util_c_variables.nss`.
///
/// Concepts:
///     - Databases:  There are three sqlite database types available to store
///         variables:  a player's bic-based db, the module's volatile db and
///         the external/persistent campaign db.  When calling a function that
///         requires a database object reference (such as param oDatabase), it
///         must be a player object, DB_MODULE or DB_CAMPAIGN.  All other values
///         will result in the function failing with a message to the game's log.
///     - Tag: Any Set, Increment, Decrement or Append function allows a variable
///         to be tagged with a string value of any composition or length.  This
///         tag is designed to be used to group values for future delete or copy
///         operations, but may be used for any other purpose.  It is important
///         to understan that the tag field is part of the primary key, which makes
///         each record unique.  Although the tag is optional, if included, it must
///         be included in each subsequent call to ensure the correct variable
///         record is being operated on.
///     - Timestamp:  Any Set, Increment, Decrement or Append function updates
///         the time at which the variables was set or updated.  This time can be
///         be used in advanced query functions to copy or delete specific variables
///         by group.
///     - Glob/wildcard Syntax:  There are several functions which allow criteria
///         to be specified to retrieve or delete variables.  These criteria
///         allow the use of bitmasked types and glob syntax.  If the function
///         description specified this ability, the following syntax is allowed:
///             nType - Can be a single variable type, such as
///                 VARIABLE_TYPE_INT, or a bitmasked set of variable types,
///                 such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.  Other
///                 normal bitwise operators are also allowed.  To select
///                 all variables types except integer, the value can be
///                 passed as ~VARIABLE_TYPE_INT.  Pass VARIABLE_TYPE_ALL
///                 to ignore variable types.  Passing VARIABLE_TYPE_NONE will
///                 generally result in zero returned results.
///             sVarName - Can be an exact varname as previously set, or
///                 will accept any wildcards or sets allowed by glob:
///                     **Glob operations are case-senstive**
///                     * - 0 or more characters
///                     ? - Any single character
///                     [a-j] - Any single character in the range a-j
///                     [a-zA-Z] - Any single upper or lowercase letter
///                     [0-9] - Any single digit
///                     [^cde] - Any single character not in [cde]
///                 Pass "" to ignore varnames.
///             sTag - Can be an exact tag as previously set, or will accept
///                 any wildcards or sets allowed by glob.  See previous
///                 examples for sVarName.  Pass "" to ignore tags.
///             nTime - Filter results by timestamp.  A timestamp is set on
///                 the variable anytime a variable is inserted or updated.
///                 If nTime is negative, the system will match all variables
///                 set before nTime.  If nTime is positive, the system will
///                 match all variables set after nTime.  The easiest way to
///                 understand this concept is to determine the time you want
///                 to compare against (in Unix seconds), then pass that time
///                 as negative to seek variables set/updated before that time,
///                 or positive to seek variables set/updated after that time.
///                 Pass 0 to ignore timestamps.
///
/// Advanced Usage:
///     - Copying from Database to Locals:  `CopyDatabaseVariablesToObject()`
///         allows specified database variables to any valid game object.
///         Local variables do not allow additional fields that are retrieved
///         from the database, so the function `DatabaseToObjectVarName()` is
///         provided in `util_c_variables.nss` to allow users to construct
///         unique varnames for a copied database variable.  See glob/wildcard
///         syntax concept above for how to use parameters in this function.
///
///     - Copying from Locals to Database:  `CopyLocalVariablesToDatabase()`
///         allows specified local variables from any game object (except the
///         module object) to any database.  



///     - Copying from Locals to Database:  There are three functions which allow
///         variables which meet specific criteria to be copied from a game object
///         to a specified database.  Local variables do not have tags, however, a
///         tag can be supplied to these functions and the tag will be saved into
///         the database.  These methods may be useful to save current object
///         state into a persistent database to be later retrieved individually
///         of by mass copy with a database -> local copy method.
///
///     - Record uniqueness:  Module, Player and Persistent variables are stored
///         in sqlite databases.  Each record is unique based on variable type,
///         name and tag.  The variable tag is optional.  This behavior allows
///         multiple variables with the same type and name, but with different
///         tags.  If using tags, it is incumbent upon the user to include the
///         desired tag is in all functions calls to ensure the correct record
///         is operated on.

#include "util_i_debug"
#include "util_i_lists"
#include "util_i_matching"
#include "util_c_variables"

// -----------------------------------------------------------------------------
//                                  Constants
// -----------------------------------------------------------------------------

const int VARIABLE_TYPE_NONE         = 0x00;
const int VARIABLE_TYPE_INT          = 0x01;
const int VARIABLE_TYPE_FLOAT        = 0x02;
const int VARIABLE_TYPE_STRING       = 0x04;
const int VARIABLE_TYPE_OBJECT       = 0x08;
const int VARIABLE_TYPE_VECTOR       = 0x10;
const int VARIABLE_TYPE_LOCATION     = 0x20;
const int VARIABLE_TYPE_JSON         = 0x40;
const int VARIABLE_TYPE_SERIALIZED   = 0x80;
const int VARIABLE_TYPE_ALL          = 0xff;

const string VARIABLE_OBJECT   = "VARIABLE:OBJECT";
const string VARIABLE_CAMPAIGN = "VARIABLE:CAMPAIGN";

object DB_MODULE = GetModule();
object DB_CAMPAIGN = OBJECT_INVALID;

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Creates a variable table in oObject's database.
/// @param oObject Optional object reference.  If passed, should
///     be a PC object or a db object (DB_MODULE || DB_CAMPAIGN).
/// @note This function is never required to be called separately
///     during OnModuleLoad.  Table creation is handled during
///     the variable setting process.
void CreateVariableTable(object oObject);

// -----------------------------------------------------------------------------
//                               Local Variables
// -----------------------------------------------------------------------------

/// @brief Returns a json array of all local variables on oObject.
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param nType VARIABLE_TYPE_* constant for type of variable to retrieve.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to retrieve.  Accepts glob wildcard and
///     set syntax.
/// @returns a JSON array of variables set on oObject.  The array will consist
///     of JSON objects with the following key:value pairs:
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///         varname: <varname> {string}
json GetLocalVariables(object oObject, int nType = VARIABLE_TYPE_ALL, string sVarName = "*");

/// @brief Deletes local variables from oObject.
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param nType VARIABLE_TYPE_* constant for type of variable to delete.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to delete.  Accepts glob wildcard and
///     set syntax.
void DeleteLocalVariables(object oObject, int nType = VARIABLE_TYPE_NONE, string sVarName = "");

/// @brief Copies local variables from oObject to another game object oTarget.
/// @param oSource Game object to get local variables from.  This method will
///     not work on the module object.
/// @param oTarget The game object to copy local variables to.
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param bDelete If TRUE, deletes the local variables from oSource after they
///     are copied oTarget.
/// @note This method *can* be used to set variables onto the module object.
void CopyLocalVariablesToObject(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                string sVarName = "", int bDelete = TRUE);

/// @brief Copies local variables from oSource to oDatabase.
/// @param oSource Game object to get local variables from.  This method will
///     not work on the module object.
/// @param oDatabase Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  All variables copied with this function
///     will have sTag applied.
/// @param bDelete If TRUE, deletes the local variables from oSource after they
///     are copied to the module database.
void CopyLocalVariablesToDatabase(object oSource, object oDatabase, int nType = VARIABLE_TYPE_ALL, 
                                  string sVarName = "", string sTag = "", int bDelete = TRUE);

/// @brief Copies variables from an sqlite database to a game object as local variables.
/// @param oDatabase Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param oTarget Game object to set local variables on.
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  Accepts glob wildcard and set syntax.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @param bDelete If TRUE, deletes the local variables from oObject after they
///     are copied to the module database.
/// @note This method *can* be used to set variables onto the module object.
void CopyDatabaseVariablesToObject(object oDatabase, object oTarget, int nType = VARIABLE_TYPE_ALL, 
                                   string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE);

/// @brief Copies variables from an sqlite database to another sqlite database.
/// @param oSource Database to copy variables from (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param oTarget Database to copy variables to (PC Object || DB_MODULE || DB_CAMPAIGN).
/// @param nType VARIABLE_TYPE_* constant for type of variable to copy.
///     Accepts bitmasked types such as VARIABLE_TYPE_INT | VARIABLE_TYPE_FLOAT.
/// @param sVarName Name of variable to copy.  Accepts glob wildcard and
///     set syntax.
/// @param sTag Optional tag reference.  Accepts glob wildcard and set syntax.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @param bDelete If TRUE, deletes the local variables from oObject after they
///     are copied to the module database.
void CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                     string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalInt(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalFloat(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalString(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalObject(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalLocation(object oObject, string sVarName);

/// @brief Determines whether a local variable has been set on oObject
/// @param oObject Game object to get local variables from.  This method will
///     not work on the module object.
/// @param sVarName Name of variable to retrieve.  This must be the exact varname,
///     glob wildcards and sets are not accepted.
int HasLocalJson(object oObject, string sVarName);

// -----------------------------------------------------------------------------
//                               Module Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleInt(string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleFloat(string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleString(string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleObject(string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetModuleObject().
void SetModuleSerialized(string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleLocation(string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleVector(string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetModuleJson(string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
/// @param sNewTag New tag to assign.
void SetModuleVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetModuleInt(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetModuleFloat(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetModuleString(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetModuleObject(string sVarName, string sTag = "");

/// @brief Retrieve and create a serialized object from the module's
///     volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetModuleSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetModuleLocation(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetModuleVector(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetModuleJson(string sVarName, string sTag = "");

/// @brief Returns a json array of key-value pairs.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetModuleVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0);

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
int DeleteModuleInt(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeleteModuleFloat(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeleteModuleString(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeleteModuleObject(string sVarName, string sTag = "");

/// @brief Delete a serialized object from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeleteModuleSerialized(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeleteModuleLocation(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeleteModuleVector(string sVarName, string sTag = "");

/// @brief Delete a variable from the module's volatile sqlite database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeleteModuleJson(string sVarName, string sTag = "");

/// @brief Deletes all variables from the module's volatile sqlite database.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeleteModuleVariables();

/// @brief Deletes all variables from the module's volatile sqlite database
///     that match the parameter criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be returned.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the module's volatile sqlite database being
///     deleted without additional warning.
void DeleteModuleVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "*", int nTime = 0);

/// @brief Increments an integer variable in the module's volatile sqlite
///     database by nIncrement. If the variable doesn't exist, it will be
///     initialized to 0 before incrementing.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///      previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementModuleInt(string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the module's volatile sqlite
///     database by nDecrement. If the variable doesn't exist, it will be
///     initialized to 0 before decrementing.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementModuleInt(string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the module's volatile sqlite
///     database by nIncrement. If the variable doesn't exist, it will be
///     initialized to 0.0 before incrementing.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementModuleFloat(string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the module's volatile sqlite
///     database by nDecrement. If the variable doesn't exist, it will be
///     initialized to 0.0 before decrementing.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementModuleFloat(string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the module's
///     volatile sqlite database. If the variable doesn't exist, it will be
///     initialized to "" before appending.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after appending.
string AppendModuleString(string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                               Player Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerInt(object oPlayer, string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerFloat(object oPlayer, string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerString(object oPlayer, string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerObject(object oPlayer, string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetPlayerObject().
void SetPlayerSerialized(object oPlayer, string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerLocation(object oPlayer, string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerVector(object oPlayer, string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPlayerJson(object oPlayer, string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param oPlayer Player object reference.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
void SetPlayerVariableTag(object oPlayer, int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetPlayerInt(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetPlayerFloat(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetPlayerString(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetPlayerObject(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve and create a serialized object from the player's sqlite
///     database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetPlayerSerialized(object oPlayer, string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetPlayerLocation(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetPlayerVector(object oPlayer, string sVarName, string sTag = "");

/// @brief Retrieve a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetPlayerJson(object oPlayer, string sVarName, string sTag = "");

/// @brief Returns a json array of key-value pairs.
/// @param oPlayer Player object reference.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetPlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_ALL,
                                 string sVarName = "", string sTag = "", int nTime = 0);

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
int DeletePlayerInt(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeletePlayerFloat(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeletePlayerString(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeletePlayerObject(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a serialized object from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeletePlayerSerialized(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeletePlayerLocation(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeletePlayerVector(object oPlayer, string sVarName, string sTag = "");

/// @brief Delete a variable from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeletePlayerJson(object oPlayer, string sVarName, string sTag = "");

/// @brief Deletes all variables from the player's sqlite database.
/// @param oPlayer Player object reference.
/// @warning Calling this method will result in all variables in the module's
///     volatile sqlite database being deleted without additional warning.
void DeletePlayerVariables(object oPlayer);

/// @brief Deletes all variables from the player's sqlite database
///     that match the parameter criteria.
/// @param oPlayer Player object reference.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be returned.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the player's sqlite database being
///     deleted without additional warning.
void DeletePlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_NONE,
                                    string sVarName = "", string sTag = "", int nTime = 0);

/// @brief Increments an integer variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0 before
///     incrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementPlayerInt(object oPlayer, string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0 before
///     decrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementPlayerInt(object oPlayer, string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     incrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementPlayerFloat(object oPlayer, string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the player's sqlite database.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     decrementing.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementPlayerFloat(object oPlayer, string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the player's
///     sqlite database.  If the variable doesn't exist, it will be
///     initialized to "" before appending.
/// @param oPlayer Player object reference.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.
/// @returns The value of the variable after appending.
string AppendPlayerString(object oPlayer, string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                               Campaign Database
// -----------------------------------------------------------------------------

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param nValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentInt(string sVarName, int nValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param fValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentFloat(string sVarName, float fValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param sValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentString(string sVarName, string sValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentObject(string sVarName, object oValue, string sTag = "");

/// @brief Set a serialized object into the campaign database.
/// @param sVarName Name of the variable.
/// @param oValue Value of the variable.
/// @param sTag Optional tag reference.
/// @note This function will serialize the passed object.  To store an object by
///     reference, use SetPersistentObject().
void SetPersistentSerialized(string sVarName, object oValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param lValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentLocation(string sVarName, location lValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param vValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentVector(string sVarName, vector vValue, string sTag = "");

/// @brief Set a variable into the campaign database.
/// @param sVarName Name of the variable.
/// @param jValue Value of the variable.
/// @param sTag Optional tag reference.
void SetPersistentJson(string sVarName, json jValue, string sTag = "");

/// @brief Set a previously set variable's tag to sTag.
/// @param nType VARIABLE_TYPE_* constant.
/// @param sVarName Name of the variable.
/// @param sTag Tag reference.
void SetPersistentVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.
/// @param sTag Optional tag reference.
int GetPersistentInt(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise 0.0.
/// @param sTag Optional tag reference.
float GetPersistentFloat(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise "".
/// @param sTag Optional tag reference.
string GetPersistentString(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise OBJECT_INVALID.
/// @param sTag Optional tag reference.
object GetPersistentObject(string sVarName, string sTag = "");

/// @brief Retrieve and create a serialized object from the campaign database.
/// @param sVarName Name of the variable.
/// @param l Location to create the deserialized object.
/// @param oTarget Target object on which to create the deserialized object.
/// @returns The requested serialized object, if found, otherwise
///     OBJECT_INVALID.
/// @note If oTarget is passed and has inventory, the retrieved object
///     will be created in oTarget's inventory, otherwise it will be created
///     at location l.
object GetPersistentSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID);

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise LOCATION_INVALID.
/// @param sTag Optional tag reference.
location GetPersistentLocation(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise Vector().
/// @param sTag Optional tag reference.
vector GetPersistentVector(string sVarName, string sTag = "");

/// @brief Retrieve a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @returns Variable value, if found, otherwise JsonNull().
/// @param sTag Optional tag reference.
json GetPersistentJson(string sVarName, string sTag = "");

/// @brief Returns a json array of key-value pairs.
/// @param nType VARIABLE_TYPE_*, accepts bitmasked values.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, all variables will be returned.
/// @details This function will return an array of json objects containing
///     information about each variable found.  Each json object in the
///     array will contain the following key-value pairs:
///         tag: <tag> {string}
///         timestamp: <timestamp> {int} UNIX seconds
///         type: <type> {int} Reference to VARIABLE_TYPE_*
///         value: <value> {type} Type depends on type
///             -- objects will be returned as a string object id which
///                 can be used in StringToObject()
///             -- serialized objects will be returned as their json
///                 representation and can be used in JsonToObject()
///         varname: <varname> {string}
json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "*",
                                     string sTag = "*", int nTime = 0);

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
int DeletePersistentInt(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
float DeletePersistentFloat(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
string DeletePersistentString(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
object DeletePersistentObject(string sVarName, string sTag = "");

/// @brief Delete a serialized object from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
void DeletePersistentSerialized(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
location DeletePersistentLocation(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
vector DeletePersistentVector(string sVarName, string sTag = "");

/// @brief Delete a variable from the campaign database.
/// @param sVarName Name of the variable.
/// @param sTag Optional tag reference.
json DeletePersistentJson(string sVarName, string sTag = "");

/// @brief Deletes all variables from the campaign database.
/// @warning Calling this method will result in all variables in the campaign
///     database being deleted without additional warning.
void DeletePersistentVariables();

/// @brief Deletes all variables from the campaign database that match the
///     parameter criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accepts glob patterns, sets
///     and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @note If no parameters are passed, no variables will be deleted.
/// @warning Calling this method without passing any parameters will result
///     in all variables in the campaign database being
///     deleted without additional warning.
void DeletePersistentVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                        string sTag = "", int nTime = 0);

/// @brief Increments an integer variable in the campaign database by nIncrement.
///     If the variable doesn't exist, it will be initialized to 0 before
///     incrementing.
/// @param sVarName Name of the variable.
/// @param nIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///      previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positive, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
int IncrementPersistentInt(string sVarName, int nIncrement = 1, string sTag = "");

/// @brief Decrements an integer variable in the campaign database by nDecrement.
///     If the variable doesn't exist, it will be initialized to 0 before
///     decrementing.
/// @param sVarName Name of the variable.
/// @param nDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
int DecrementPersistentInt(string sVarName, int nDecrement = -1, string sTag = "");

/// @brief Increments an float variable in the campaign database by nIncrement.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     incrementing.
/// @param sVarName Name of the variable.
/// @param fIncrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after incrementing.
/// @note nIncrement is expected to be positing, however, this method will
///     accept a negative value for nIncrement and will decrement the variable
///     value.
float IncrementPersistentFloat(string sVarName, float fIncrement = 1.0, string sTag = "");

/// @brief Decrements an float variable in the campaign database by nDecrement.
///     If the variable doesn't exist, it will be initialized to 0.0 before
///     decrementing.
/// @param sVarName Name of the variable.
/// @param fDecrement Amount to increment the variable by.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after decrementing.
/// @note nDecrement is expected to be negative.  If nDecrement is a positive,
///     this method will decrement the variable by nDecrement and will not
///     fallback to incrementing behavior.
float DecrementPersistentFloat(string sVarName, float fDecrement = -1.0, string sTag = "");

/// @brief Appends sAppend to the end of a string variable in the campaign
///     database. If the variable doesn't exist, it will be initialized to ""
///     before appending.
/// @param sVarName Name of the variable.
/// @param sAppend Value to append.
/// @param sTag Optional tag reference.  Only used if the variable was not
///     previously set.
/// @returns The value of the variable after appending.
string AppendPersistentString(string sVarName, string sAppend, string sTag = "");

// -----------------------------------------------------------------------------
//                              Private Functions
// -----------------------------------------------------------------------------

/// @private Returns the variable type as a string
/// @note For debug purposes only.
string _VariableTypeToString(int nType)
{
    if      (nType == VARIABLE_TYPE_INT)        return "INT";
    else if (nType == VARIABLE_TYPE_FLOAT)      return "FLOAT";
    else if (nType == VARIABLE_TYPE_STRING)     return "STRING";
    else if (nType == VARIABLE_TYPE_OBJECT)     return "OBJECT";
    else if (nType == VARIABLE_TYPE_VECTOR)     return "VECTOR";
    else if (nType == VARIABLE_TYPE_LOCATION)   return "LOCATION";
    else if (nType == VARIABLE_TYPE_JSON)       return "JSON";
    else if (nType == VARIABLE_TYPE_SERIALIZED) return "SERIALIZED";
    else if (nType == VARIABLE_TYPE_NONE)       return "NONE";
    else if (nType == VARIABLE_TYPE_ALL)        return "ALL";
    else                                        return "UNKNOWN";
}

/// @private Converts an NWN type to a VARIABLE_TYPE_*
int _TypeToVariableType(json jType)
{
    int nType = JsonGetInt(jType);

    if      (nType == 1) return VARIABLE_TYPE_INT;
    else if (nType == 2) return VARIABLE_TYPE_FLOAT;
    else if (nType == 3) return VARIABLE_TYPE_STRING;
    else if (nType == 4) return VARIABLE_TYPE_OBJECT;
    else if (nType == 5) return VARIABLE_TYPE_LOCATION;
    else if (nType == 7) return VARIABLE_TYPE_JSON;
    return                      VARIABLE_TYPE_NONE;
}

/// @private Converts VARIABLE_TYPE_* bitmask to IN
string _VariableTypeToArray(int nTypes)
{
    if      (nTypes == VARIABLE_TYPE_NONE) return "";
    else if (nTypes == VARIABLE_TYPE_ALL)  return "1,2,3,4,5,6,7";

    string sArray;    
    if (nTypes & VARIABLE_TYPE_INT)       sArray = AddListItem(sArray, "1");
    if (nTypes & VARIABLE_TYPE_FLOAT)     sArray = AddListItem(sArray, "2");
    if (nTypes & VARIABLE_TYPE_STRING)    sArray = AddListItem(sArray, "3");
    if (nTypes & VARIABLE_TYPE_OBJECT)    sArray = AddListItem(sArray, "4");
    if (nTypes & VARIABLE_TYPE_LOCATION)  sArray = AddListItem(sArray, "5");
    if (nTypes & VARIABLE_TYPE_JSON)      sArray = AddListItem(sArray, "7");
    
    return sArray;
}

/// @private Deletes a single local variable
void _DeleteLocalVariable(object oObject, string sVarName, int nType)
{
    if      (nType == VARIABLE_TYPE_INT)       DeleteLocalInt(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_FLOAT)     DeleteLocalFloat(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_STRING)    DeleteLocalString(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_OBJECT)    DeleteLocalObject(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_LOCATION)  DeleteLocalLocation(oObject, sVarName);
    else if (nType == VARIABLE_TYPE_JSON)      DeleteLocalJson(oObject, sVarName);
}

/// @private Sets a single local variable
void _SetLocalVariable(object oObject, string sVarName, int nType, json jValue)
{
    if      (nType == VARIABLE_TYPE_INT)       SetLocalInt(oObject, sVarName, JsonGetInt(jValue));
    else if (nType == VARIABLE_TYPE_FLOAT)     SetLocalFloat(oObject, sVarName, JsonGetFloat(jValue));
    else if (nType == VARIABLE_TYPE_STRING)    SetLocalString(oObject, sVarName, JsonGetString(jValue));
    else if (nType == VARIABLE_TYPE_OBJECT)    SetLocalObject(oObject, sVarName, StringToObject(JsonGetString(jValue)));
    else if (nType == VARIABLE_TYPE_LOCATION)  SetLocalLocation(oObject, sVarName, JsonToLocation(jValue));
    else if (nType == VARIABLE_TYPE_JSON)      SetLocalJson(oObject, sVarName, jValue);
}

/// @private Prepares an query against an object (module/player).  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryObject(object oObject, string sQuery)
{
    CreateVariableTable(oObject);
    return SqlPrepareQueryObject(oObject, sQuery);
}

/// @private Prepares an query against an campaign database.  Ensures
///     appropriate tables have been created before attempting query.
sqlquery _PrepareQueryCampaign(string sQuery)
{
    CreateVariableTable(DB_CAMPAIGN);
    return SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, sQuery);
}

/// @private Prepares a select query to retrieve a variable value stored
///     in any database.
sqlquery _PrepareVariableSelect(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "SELECT value FROM " + sTable + " WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB @tag;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares an insert query to stored a variable in any database.
sqlquery _PrepareVariableInsert(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, IIF(json_valid(@value), @value ->> '$', @value), " +
                "@tag, strftime('%s', 'now')) ON CONFLICT (type, varname, tag) DO UPDATE " +
                "SET value = IIF(json_valid(@value), @value ->> '$', @value), tag = @tag, " +
                "timestamp = strftime('%s', 'now');";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares an update query to modify the tag assicated with a variable.
sqlquery _PrepareTagUpdate(object oObject, int nType, string sVarName, string sTag1, string sTag2)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "UPDATE " + sTable + " SET tag = @tag2 WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB tag1;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag1", sTag1);
    SqlBindString(q, "@tag2", sTag2);
    return q;    
}

/// @private Prepares an delete query to remove a variable stored in any database.
sqlquery _PrepareSimpleVariableDelete(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "DELETE FROM " + sTable + " WHERE type = @type " +
                    "AND varname GLOB @varname AND tag GLOB @tag " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Prepares a complex delete query to remove multiple variables by criteria.
/// @param nType Bitwise VARIABLE_TYPE_*.
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards.
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards.
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
sqlquery _PrepareComplexVariableDelete(object oObject, int nType, string sVarName, string sTag, int nTime)
{
    int n, bPC    = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " (type & @type) > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");

    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = SubstituteString("DELETE FROM " + sTable + sWhere + ";", jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));
    return q;
}

/// @private Retrieves variables from database associated with oObject and returns
///     selected variables in a json array containing variable metadata and value.
/// @param nType Bitwise VARIABLE_TYPE_*
/// @param sVarName Variable name pattern, accept glob patterns, sets and wildcards
/// @param sTag Tag pattern, accepts glob patterns, sets and wildcards
/// @param nTime A positive value will filter for timestamps after
///     nTime, a negative value will filter for timestamps before nTime.
/// @warning If no parameters are passed, this query will result in no variables being
///     retrieved.
json _DatabaseVariablesToJson(object oObject, int nType, string sVarName, string sTag, int nTime)
{
    int n, bPC    = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " varname GLOB @varname");
           sWhere += (sTag == ""     ? "" : " $" + IntToString(++n) + " tag GLOB @tag");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " (type & @type) > 0");
           sWhere += (nTime == 0     ? "" : " $" + IntToString(++n) + " timestamp " + (nTime > 0 ? ">" : "<") + " @time");

    json jKeyWords = ListToJson("WHERE,AND,AND,AND");
    string s = "WITH json_variables AS (SELECT json_object('type', type, 'varname', varname, " +
                    "'tag', tag, 'value', value, 'timestamp', timestamp) AS variable_object " +
                    "FROM " + sTable + sWhere + ") " +
                "SELECT json_group_array(json(variable_object)) FROM json_variables;";
    s = SubstituteString(s, jKeyWords);

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    if (sVarName != "") SqlBindString(q, "@varname", sVarName);
    if (sTag != "")     SqlBindString(q, "@tag", sTag);
    if (nType > 0)      SqlBindInt   (q, "@type", nType);
    if (nTime != 0)     SqlBindInt   (q, "@time", abs(nTime));

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

json _LocalVariablesToJson(object oObject, int nType, string sVarName)
{
    if (!GetIsObjectValid(oObject) || oObject == DB_MODULE)
        return JsonArray();

    json jVarTable = JsonPointer(ObjectToJson(oObject, TRUE), "/VarTable/value");
    if (!JsonGetLength(jVarTable))
        return JsonArray();

    int n;
    string sWhere =  (sVarName == "" ? "" : " $" + IntToString(++n) + " variable_object ->> 'varname' GLOB @varname");
           sWhere += (nType <= 0     ? "" : " $" + IntToString(++n) + " variable_object ->> 'type' IN (" + _VariableTypeToArray(nType) + ")"); 
    
    json jKeyWords = ListToJson("WHERE,AND");
    string s = "WITH local_variables AS (SELECT json_object('type', v.value -> 'Type.value', " +
                    "'varname', v.value -> 'Name.value', 'value', v.value -> 'Value.value') " +
                    "as variable_object FROM json_each(@vartable) as v) " +
                "SELECT json_group_array(json(variable_object)) FROM local_variables " + sWhere + ";";
    s = SubstituteString(s, jKeyWords);

    sqlquery q = SqlPrepareQueryObject(DB_MODULE, s);
    SqlBindJson(q, "@vartable", jVarTable);
    SqlBindString(q, "@varname", sVarName);

    return SqlStep(q) ? SqlGetJson(q, 0) : JsonArray();
}

/// @private Increments/Decremenst an existing variable (int/float).  If the variable
///     does not exist, creates variable, then increments/decrements.
sqlquery _PrepareVariableIncrement(object oObject, int nType, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s','now')) " +
                "ON CONFLICT (type, varname, tag) DO UPDATE SET value = value + @value, " +
                    "timestamp = strftime('%s','now') RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindInt   (q, "@type", nType);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Appends a string to an existing variable.  If the variables does not
///     exist, creates the variable, then appends.
sqlquery _PrepareVariableAppend(object oObject, string sVarName, string sTag)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s =  "INSERT INTO " + sTable + " " +
                    "(type, varname, value, tag, timestamp) " +
                "VALUES (@type, @varname, @value, @tag, strftime('%s', 'now')) " +
                "ON CONFLICT (type, varname, tag) " +
                    "DO UPDATE SET value = value || @value, " +
                        "timestamp = strftime('%s', 'now') " +
                "RETURNING value;";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlBindString(q, "@varname", sVarName);
    SqlBindString(q, "@tag", sTag);
    return q;
}

/// @private Opens an sqlite transaction
void _BeginSQLTransaction(object oObject)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;

    string s = "BEGIN TRANSACTION;";
    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlStep(q);
}

/// @private Commits an open sqlite transaction
void _CommitSQLTransaction(object oObject)
{
    int bPC       = GetIsPC(oObject);
    int bCampaign = oObject == DB_CAMPAIGN;

    string s = "COMMIT TRANSACTION;";
    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oObject, s) : _PrepareQueryCampaign(s);
    SqlStep(q);   
}

/// @private Copies specified variables from oSource (game object) to oTarget (db).
void _CopyVariablesToDatabase(object oSource, object oDatabase, int nTypes,
                              string sVarNames, string sTag, int bDelete)
{
    if (oSource == GetModule())
        return;

    if (!GetIsPC(oDatabase) && oDatabase != DB_MODULE && oDatabase != DB_CAMPAIGN)
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy local variables to database failed:" +
                "\n  oSource -> " + GetName(oSource) +
                "\n  oDatabase -> " + GetName(oDatabase) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = GetLocalVariables(oSource, nTypes, sVarNames);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;
    
    _BeginSQLTransaction(oDatabase);
    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        json   jValue    = JsonPointer(jVariable, "/value");

        sVarName = ObjectToDatabaseVarName(oSource, oDatabase, sVarName, nType, sTag);
        sTag     = ObjectToDatabaseTag(oSource, oDatabase, sVarName, nType, sTag);

        sqlquery q = _PrepareVariableInsert(oDatabase, nType, sVarName, sTag);
        SqlBindJson(q, "@value", jValue);
        SqlStep(q);

        if (bDelete)
            _DeleteLocalVariable(oSource, sVarName, nType);
    }
    _CommitSQLTransaction(oDatabase);
}

/// @private Copies specified variables from oSource (db) to oTarget (game object).
void _CopyVariablesToObject(object oDatabase, object oTarget, int nTypes, string sVarNames,
                            string sTag, int nTime, int bDelete)
{
    if (!GetIsPC(oDatabase) && oDatabase != DB_MODULE && oDatabase != DB_CAMPAIGN)
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy database variables to game object failed:" +
                "\n  oDatabase -> " + GetName(oDatabase) +
                "\n  oTarget -> " + GetName(oTarget) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  nTime -> " + IntToString(nTime) +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = _DatabaseVariablesToJson(oDatabase, nTypes, sVarNames, sTag, nTime);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;

    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        string sTag      = JsonGetString(JsonPointer(jVariables, "/tag"));
        json   jValue    = JsonPointer(jVariable, "/value");

        _SetLocalVariable(oTarget, DatabaseToObjectVarName(oDatabase, oTarget, sVarName, sTag, nType), nType, jValue);
    }

    if (bDelete)
        SqlStep(_PrepareComplexVariableDelete(oDatabase, nTypes, sVarNames, sTag, nTime));
}

void _CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nTypes, string sVarNames,
                                      string sTag, int nTime, int bDelete)
{
    if ((!GetIsPC(oSource) && oSource != DB_MODULE && oSource != DB_CAMPAIGN) ||
        (!GetIsPC(oTarget) && oTarget != DB_MODULE && oTarget != DB_CAMPAIGN) ||
        (oSource == oTarget))
    {
        if (IsDebugging(DEBUG_LEVEL_NOTICE))
            Notice("Attempt to copy variables between databases failed:" +
                "\n  oSource -> " + GetName(oSource) +
                "\n  oTarget -> " + GetName(oTarget) +
                "\n  nTypes -> " + IntToHexString(nTypes) +
                "\n  sVarName -> " + sVarNames +
                "\n  sTag -> " + sTag +
                "\n  nTime -> " + IntToString(nTime) +
                "\n  bDelete -> " + (bDelete ? "TRUE" : "FALSE"));
        return;
    }

    json jVariables = _DatabaseVariablesToJson(oSource, nTypes, sVarNames, sTag, nTime);

    int bPC       = GetIsPC(oTarget);
    int bCampaign = oTarget == DB_CAMPAIGN;
    string sTable = bPC ? VARIABLE_TABLE_PC : VARIABLE_TABLE_MODULE;

    string s = "INSERT INTO " + sTable + " (type, varname, value, tag, timestamp) " +
        "SELECT value ->> '$.type', value ->> '$.varname', value ->> '$.value', " +
        "value ->> '$.tag', strftime('%s','now') FROM (SELECT value FROM json_each(@variables));";

    sqlquery q = bPC || !bCampaign ? _PrepareQueryObject(oTarget, s) : _PrepareQueryCampaign(s);
    SqlBindJson(q, "@variables", jVariables);
    SqlStep(q);

    if (bDelete)
        SqlStep(_PrepareComplexVariableDelete(oSource, nTypes, sVarNames, sTag, nTime));
}

void _CopyLocalVariablesToObject(object oSource, object oTarget, int nTypes,
                                 string sVarNames, int bDelete)
{
    if (oSource == GetModule())
    {
        Notice("Attempt to copy variables between objects failed; " +
            "cannot copy from the module object");
        return;
    }
    else if (oSource == oTarget)
        return;

    json jVariables = _LocalVariablesToJson(oSource, nTypes, sVarNames);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return;

    int n; for (n; n < nCount; n++)
    {
        json   jVariable = JsonPointer(jVariables, "/" + IntToString(n));
        int    nType     = JsonGetInt(JsonPointer(jVariable, "/type"));
        string sVarName  = JsonGetString(JsonPointer(jVariable, "/varname"));
        json   jValue    = JsonPointer(jVariable, "/value");

        _SetLocalVariable(oTarget, sVarName, nType, jValue);

        if (bDelete)
            _DeleteLocalVariable(oSource, sVarName, nType);
    }
}

// -----------------------------------------------------------------------------
//                             Public Functions
// -----------------------------------------------------------------------------

void CreateVariableTable(object oObject)
{
    string sVarName = VARIABLE_OBJECT;
    string sTable   = VARIABLE_TABLE_MODULE;
    int bCampaign   = oObject == DB_CAMPAIGN;

    if (bCampaign)
    {
        sVarName = VARIABLE_CAMPAIGN;
        oObject = DB_MODULE;
    }
    else if (GetIsPC(oObject))
        sTable = VARIABLE_TABLE_PC;
    else if (oObject != DB_MODULE)
        return;

    if (GetLocalInt(oObject, sVarName))
        return;

    string s = "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        "type INTEGER, " +
        "varname TEXT, " +
        "tag TEXT, " +
        "value TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY (type, varname, tag));";

    sqlquery q;
    if (bCampaign)
        q = SqlPrepareQueryCampaign(VARIABLE_CAMPAIGN_DATABASE, s);
    else
        q = SqlPrepareQueryObject(oObject, s);

    SqlStep(q);
    SetLocalInt(oObject, sVarName, TRUE);
}

// -----------------------------------------------------------------------------
//                               Local Variables
// -----------------------------------------------------------------------------

json GetLocalVariables(object oObject, int nType = VARIABLE_TYPE_ALL, string sVarName = "*")
{
    if (oObject == DB_MODULE)
        return JsonArray();

    json jVariables = _LocalVariablesToJson(oObject, nType, sVarName);
    int nCount = JsonGetLength(jVariables);

    if (!nCount)
        return JsonArray();

    int n; for (n; n < nCount; n++)
    {
        json j = JsonArrayGet(jVariables, n);
             j = JsonObjectSet(j, "type", JsonInt(_TypeToVariableType(JsonObjectGet(j, "type"))));

        jVariables = JsonArraySet(jVariables, n, j);
    }

    return jVariables;
}

void DeleteLocalVariables(object oObject, int nTypes = VARIABLE_TYPE_NONE, string sVarNames = "")
{
    json jVariables = GetLocalVariables(oObject, nTypes, sVarNames);
    int n; for (n; n < JsonGetLength(jVariables); n++)
    {
        json   jVariable = JsonArrayGet(jVariables, n);
        int    nType     = JsonGetInt(JsonObjectGet(jVariable, "type"));
        string sName     = JsonGetString(JsonObjectGet(jVariable, "varname"));

        _DeleteLocalVariable(oObject, sName, nType);
    }
}

void CopyLocalVariablesToObject(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                string sVarName = "", int bDelete = TRUE)
{
    _CopyLocalVariablesToObject(oSource, oTarget, nType, sVarName, bDelete);
}

void CopyLocalVariablesToDatabase(object oSource, object oDatabase, int nType = VARIABLE_TYPE_ALL,
                                  string sVarName = "", string sTag = "", int bDelete = TRUE)
{
    _CopyVariablesToDatabase(oSource, oDatabase, nType, sVarName, sTag, bDelete);
}

void CopyDatabaseVariablesToObject(object oDatabase, object oTarget, int nType = VARIABLE_TYPE_ALL, 
                                   string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE)
{
    _CopyVariablesToObject(oDatabase, oTarget, nType, sVarName, sTag, nTime, bDelete);
}

void CopyDatabaseVariablesToDatabase(object oSource, object oTarget, int nType = VARIABLE_TYPE_ALL,
                                     string sVarName = "", string sTag = "", int nTime = 0, int bDelete = TRUE)
{
    _CopyDatabaseVariablesToDatabase(oSource, oTarget, nType, sVarName, sTag, nTime, bDelete);
}

int HasLocalInt(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_INT, sVarName));
}

int HasLocalFloat(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_FLOAT, sVarName));
}

int HasLocalString(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_STRING, sVarName));
}

int HasLocalObject(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_OBJECT, sVarName));
}

int HasLocalLocation(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_LOCATION, sVarName));
}

int HasLocalJson(object oObject, string sVarName)
{
    return JsonGetLength(_LocalVariablesToJson(oObject, VARIABLE_TYPE_JSON, sVarName));
}

// SetModule* ------------------------------------------------------------------

void SetModuleInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetModuleFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetModuleString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetModuleObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetModuleSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetModuleLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetModuleVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetModuleJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetModuleVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "")
{
    SqlStep(_PrepareTagUpdate(DB_MODULE, nType, sVarName, sTag, sNewTag));
}

// GetModule* ------------------------------------------------------------------

int GetModuleInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetModuleFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetModuleString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetModuleObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetModuleSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetModuleLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetModuleVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetModuleJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetModuleVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "",
                                 string sTag = "", int nTime = 0)
{
    return _DatabaseVariablesToJson(DB_MODULE, nType, sVarName, sTag, nTime);
}

// DeleteModule* ---------------------------------------------------------------

int DeleteModuleInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeleteModuleFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeleteModuleString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeleteModuleObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeleteModuleSerialized(string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeleteModuleLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeleteModuleVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeleteModuleJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_MODULE, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeleteModuleVariables()
{
    SqlStep(_PrepareComplexVariableDelete(DB_MODULE, VARIABLE_TYPE_NONE, "*", "*", 0));
}

void DeleteModuleVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "*", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(DB_MODULE, nType, sVarName, sTag, nTime));
}

int IncrementModuleInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_MODULE, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementModuleInt(string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetModuleInt(sVarName);
    else if (nDecrement > 0) nDecrement *= -1;
    return IncrementModuleInt(sVarName, nDecrement, sTag);
}

float IncrementModuleFloat(string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_MODULE, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementModuleFloat(string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetModuleFloat(sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;
    return IncrementModuleFloat(sVarName, fDecrement, sTag);
}

string AppendModuleString(string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(DB_MODULE, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// Player Database -------------------------------------------------------------

void SetPlayerInt(object oPlayer, string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPlayerFloat(object oPlayer, string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPlayerString(object oPlayer, string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPlayerObject(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPlayerSerialized(object oPlayer, string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPlayerLocation(object oPlayer, string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPlayerVector(object oPlayer, string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPlayerJson(object oPlayer, string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

// GetPlayer* ------------------------------------------------------------------

int GetPlayerInt(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPlayerFloat(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPlayerString(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPlayerObject(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPlayerSerialized(object oPlayer, string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPlayerLocation(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetPlayerVector(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetPlayerJson(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetPlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_ALL,
                                 string sVarName = "", string sTag = "", int nTime = 0)
{
    return _DatabaseVariablesToJson(oPlayer, nType, sVarName, sTag, nTime);
}

// DeletePlayer* ---------------------------------------------------------------

int DeletePlayerInt(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePlayerFloat(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePlayerString(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePlayerObject(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePlayerSerialized(object oPlayer, string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeletePlayerLocation(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeletePlayerVector(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeletePlayerJson(object oPlayer, string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(oPlayer, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePlayerVariables(object oPlayer)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, 0, "*", "*", 0));
}

void DeletePlayerVariablesByPattern(object oPlayer, int nType = VARIABLE_TYPE_NONE,
                                    string sVarName = "", string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(oPlayer, nType, sVarName, sTag, nTime));
}

int IncrementPlayerInt(object oPlayer, string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementPlayerInt(object oPlayer, string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetPlayerInt(oPlayer, sVarName);
    else if (nDecrement > 0) nDecrement *= -1;
    return IncrementPlayerInt(oPlayer, sVarName, nDecrement, sTag);
}

float IncrementPlayerFloat(object oPlayer, string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(oPlayer, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementPlayerFloat(object oPlayer, string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetPlayerFloat(oPlayer, sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;
    return IncrementPlayerFloat(oPlayer, sVarName, fDecrement, sTag);
}

string AppendPlayerString(object oPlayer, string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(oPlayer, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

// SetPersistent* ------------------------------------------------------------------

void SetPersistentInt(string sVarName, int nValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nValue);
    SqlStep(q);
}

void SetPersistentFloat(string sVarName, float fValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fValue);
    SqlStep(q);
}

void SetPersistentString(string sVarName, string sValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    SqlBindString(q, "@value", sValue);
    SqlStep(q);
}

void SetPersistentObject(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    SqlBindString(q, "@value", ObjectToString(oValue));
    SqlStep(q);
}

void SetPersistentSerialized(string sVarName, object oValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    SqlBindJson(q, "@value", ObjectToJson(oValue, TRUE));
    SqlStep(q);
}

void SetPersistentLocation(string sVarName, location lValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    SqlBindJson(q, "@value", LocationToJson(lValue));
    SqlStep(q);
}

void SetPersistentVector(string sVarName, vector vValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);
    SqlBindJson(q, "@value", VectorToJson(vValue));
    SqlStep(q);
}

void SetPersistentJson(string sVarName, json jValue, string sTag = "")
{
    sqlquery q = _PrepareVariableInsert(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    SqlBindJson(q, "@value", jValue);
    SqlStep(q);
}

void SetPersistentVariableTag(int nType, string sVarName, string sTag = "", string sNewTag = "")
{
    SqlStep(_PrepareTagUpdate(DB_CAMPAIGN, nType, sVarName, sTag, sNewTag));
}

// GetPersistent* ------------------------------------------------------------------

int GetPersistentInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float GetPersistentFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string GetPersistentString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object GetPersistentObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

object GetPersistentSerialized(string sVarName, string sTag, location l, object oTarget = OBJECT_INVALID)
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag);
    return SqlStep(q) ? JsonToObject(SqlGetJson(q, 0), l, oTarget, TRUE) : OBJECT_INVALID;
}

location GetPersistentLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector GetPersistentVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json GetPersistentJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareVariableSelect(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

json GetPersistentVariablesByPattern(int nType = VARIABLE_TYPE_ALL, string sVarName = "*",
                                     string sTag = "*", int nTime = 0)
{
    return _DatabaseVariablesToJson(DB_CAMPAIGN, nType, sVarName, sTag, nTime);
}

// DeletePersistent* ---------------------------------------------------------------

int DeletePersistentInt(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

float DeletePersistentFloat(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

string DeletePersistentString(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_STRING, sVarName, sTag);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}

object DeletePersistentObject(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_OBJECT, sVarName, sTag);
    return SqlStep(q) ? StringToObject(SqlGetString(q, 0)) : OBJECT_INVALID;
}

void DeletePersistentSerialized(string sVarName, string sTag = "")
{
    SqlStep(_PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_SERIALIZED, sVarName, sTag));
}

location DeletePersistentLocation(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_LOCATION, sVarName, sTag);
    return SqlStep(q) ? JsonToLocation(SqlGetJson(q, 0)) : Location(OBJECT_INVALID, Vector(), 0.0);
}

vector DeletePersistentVector(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_VECTOR, sVarName, sTag);

    vector v;
    if (SqlStep(q)) v = JsonToVector(SqlGetJson(q, 0));
    else            v = Vector();

    return v;
}

json DeletePersistentJson(string sVarName, string sTag = "")
{
    sqlquery q = _PrepareSimpleVariableDelete(DB_CAMPAIGN, VARIABLE_TYPE_JSON, sVarName, sTag);
    return SqlStep(q) ? SqlGetJson(q, 0) : JsonNull();
}

void DeletePersistentVariables()
{
    SqlStep(_PrepareComplexVariableDelete(DB_CAMPAIGN, 0, "*", "*", 0));
}

void DeletePersistentVariablesByPattern(int nType = VARIABLE_TYPE_NONE, string sVarName = "",
                                    string sTag = "", int nTime = 0)
{
    SqlStep(_PrepareComplexVariableDelete(DB_CAMPAIGN, nType, sVarName, sTag, nTime));
}

int IncrementPersistentInt(string sVarName, int nIncrement = 1, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_CAMPAIGN, VARIABLE_TYPE_INT, sVarName, sTag);
    SqlBindInt(q, "@value", nIncrement);
    return SqlStep(q) ? SqlGetInt(q, 0) : 0;
}

int DecrementPersistentInt(string sVarName, int nDecrement = -1, string sTag = "")
{
    if      (nDecrement == 0) return GetPersistentInt(sVarName);
    else if (nDecrement > 0) nDecrement *= -1;
    return IncrementPersistentInt(sVarName, nDecrement, sTag);
}

float IncrementPersistentFloat(string sVarName, float fIncrement = 1.0, string sTag = "")
{
    sqlquery q = _PrepareVariableIncrement(DB_CAMPAIGN, VARIABLE_TYPE_FLOAT, sVarName, sTag);
    SqlBindFloat(q, "@value", fIncrement);
    return SqlStep(q) ? SqlGetFloat(q, 0) : 0.0;
}

float DecrementPersistentFloat(string sVarName, float fDecrement = -1.0, string sTag = "")
{
    if      (fDecrement == 0.0) return GetPersistentFloat(sVarName);
    else if (fDecrement > 0.0) fDecrement *= -1.0;
    return IncrementPersistentFloat(sVarName, fDecrement, sTag);
}

string AppendPersistentString(string sVarName, string sAppend, string sTag = "")
{
    sqlquery q = _PrepareVariableAppend(DB_CAMPAIGN, sVarName, sTag);
    SqlBindString(q, "@value", sAppend);
    SqlBindInt   (q, "@type", VARIABLE_TYPE_STRING);
    return SqlStep(q) ? SqlGetString(q, 0) : "";
}
/// ----------------------------------------------------------------------------
/// @file   util_i_varlists.nss
/// @author Ed Burke (tinygiant98) <af.hog.pilot@gmail.com>
/// @brief  Functions for manipulating local variable lists.
/// @details
/// Local variable lists are json arrays of a single type stored as local
/// variables. They are namespaced by type, so you can maintain lists of
/// different types using the same varname.
///
/// The majority of functions in this file apply to each possible variable type:
/// float, int, location, vector, object, string, json. However, there are some
/// that only apply to a subset of variable types, such as
/// Sort[Float|Int|String]List() and [Increment|Decrement]ListInt().
/// ----------------------------------------------------------------------------

#include "util_i_math"

// -----------------------------------------------------------------------------
//                                   Constants
// -----------------------------------------------------------------------------

// Constants used to describe float|int|string sorting order
const int LIST_SORT_ASC  = 1;
const int LIST_SORT_DESC = 2;

// Prefixes used to keep list variables from colliding with other locals. These
// constants are considered private and should not be referenced from other scripts.
const string LIST_REF              = "Ref:";
const string VARLIST_TYPE_VECTOR   = "VL:";
const string VARLIST_TYPE_FLOAT    = "FL:";
const string VARLIST_TYPE_INT      = "IL:";
const string VARLIST_TYPE_LOCATION = "LL:";
const string VARLIST_TYPE_OBJECT   = "OL:";
const string VARLIST_TYPE_STRING   = "SL:";
const string VARLIST_TYPE_JSON     = "JL:";

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
/// @note Alias for JsonVector().
json VectorToJson(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a vector to a json object.
/// @param vPosition The vector to convert.
json JsonVector(vector vPosition = [0.0, 0.0, 0.0]);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
/// @note Alias for JsonGetVector().
vector JsonToVector(json jPosition);

/// @brief Convert a json object to a vector.
/// @param jPosition The json object to convert.
vector JsonGetVector(json jPosition);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
/// @note Alias for JsonLocation().
json LocationToJson(location lLocation);

/// @brief Convert a location to a json object.
/// @param lLocation The location to convert.
json JsonLocation(location lLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
/// @note Alias for JsonGetLocation().
location JsonToLocation(json jLocation);

/// @brief Convert a json object to a location.
/// @param jLocation The json object to convert.
location JsonGetLocation(json jLocation);

/// @brief Add a value to a float list on a target.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to an int list on a target.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a location list on a target.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a vector list on a target.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to an object list on a target.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a string list on a target.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListString(object oTarget, string sValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Add a value to a json list on a target.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to add to the list.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, will not add the value if it is already present.
/// @returns TRUE if the operation was successful; FALSE otherwise.
int AddListJson(object oTarget, json jValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Return the value at an index in a target's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns 0.0 if no value is found at nIndex.
float GetListFloat(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns 0 if no value is found at nIndex.
int GetListInt(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns LOCATION_INVALID if no value is found at nIndex.
location GetListLocation(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns [0.0. 0.0, 0.0] if no value was found at nIndex.
vector GetListVector(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns OBJECT_INVALID if no value was found at nIndex.
object GetListObject(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns "" if no value was found at nIndex.
string GetListString(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Return the value at an index in a target's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @returns JSON_NULL if no value was found at nIndex.
json GetListJson(object oTarget, int nIndex = 0, string sListName = "");

/// @brief Delete the value at an index on an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Delete the value at an index on an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int DeleteListJson(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Remove the first instance of a value from an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to remove.
/// @param sListName The name of the list.
/// @param bMaintainOrder Not used; exists for legacy purposes only.
/// @returns The number of items remanining in the list.
int RemoveListJson(object oTarget, json jValue, string sListName = "", int bMaintainOrder = FALSE);

/// @brief Removes and returns the first value from an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
float PopListFloat(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int PopListInt(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
location PopListLocation(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
vector PopListVector(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
object PopListObject(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
string PopListString(object oTarget, string sListName = "");

/// @brief Removes and returns the first value from an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
json PopListJson(object oTarget, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListFloat(object oTarget, float fValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListInt(object oTarget, int nValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListLocation(object oTarget, location lValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListVector(object oTarget, vector vValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListObject(object oTarget, object oValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListString(object oTarget, string sValue, string sListName = "");

/// @brief Return the index of the first occurrence of a value in an object's
///     json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to find.
/// @param sListName The name of the list.
/// @returns The index of the value (0-based), or -1 if it is not in the list.
int FindListJson(object oTarget, json jValue, string sListName = "");

/// @brief Return whether a value is present in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param fValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListFloat(object oTarget, float fValue, string sListName = "");

/// @brief Return whether a value is present in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListInt(object oTarget, int nValue, string sListName = "");

/// @brief Return whether a value is present in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param lValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListLocation(object oTarget, location lValue, string sListName = "");

/// @brief Return whether a value is present in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param vValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListVector(object oTarget, vector vValue, string sListName = "");

/// @brief Return whether a value is present in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param oValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListObject(object oTarget, object oValue, string sListName = "");

/// @brief Return whether a value is present in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListString(object oTarget, string sValue, string sListName = "");

/// @brief Return whether a value is present in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jValue The value to find.
/// @param sListName The name of the list.
/// @returns TRUE if the value is in the list; FALSE otherwise.
int HasListJson(object oTarget, json jValue, string sListName = "");

/// @brief Insert a value at an index in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param fValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListFloat(object oTarget, int nIndex, float fValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param nValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListInt(object oTarget, int nIndex, int nValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param lValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListLocation(object oTarget, int nIndex, location lValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param vValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListVector(object oTarget, int nIndex, vector vValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's objeect list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param oValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListObject(object oTarget, int nIndex, object oValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param sValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListString(object oTarget, int nIndex, string sValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Insert a value at an index in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to insert the value at. If the index exceeds the
///     length of the list, nothing is added.
/// @param jValue The value to insert.
/// @param sListName The name of the list.
/// @param bAddUnique If TRUE, the insert operation will be conducted first and
///     then duplicate values will be removed.
/// @returns The length of the updated list.
int InsertListJson(object oTarget, int nIndex, json jValue, string sListName = "", int bAddUnique = FALSE);

/// @brief Set the value at an index in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param fValue The value to set.
/// @param sListName The name of the list.
void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "");

/// @brief Set the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param nValue The value to set.
/// @param sListName The name of the list.
void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "");

/// @brief Set the value at an index in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param lValue The value to set.
/// @param sListName The name of the list.
void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "");

/// @brief Set the value at an index in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param vValue The value to set.
/// @param sListName The name of the list.
void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "");

/// @brief Set the value at an index in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param oValue The value to set.
/// @param sListName The name of the list.
void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "");

/// @brief Set the value at an index in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param sValue The value to set.
/// @param sListName The name of the list.
void SetListString(object oTarget, int nIndex, string sValue, string sListName = "");

/// @brief Set the value at an index in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index to set the value of. If the index exceeds the length
///     of the list, nothing is added.
/// @param jValue The value to set.
/// @param sListName The name of the list.
void SetListJson(object oTarget, int nIndex, json jValue, string sListName = "");

/// @brief Copy value from one object's float list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's int list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's location list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's vector list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's object list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's string list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Copy value from one object's json list to another's.
/// @param oSource The object to copy the list values of.
/// @param oTarget The object to copy the list values to.
/// @param sSourceName The name of the list on oSource.
/// @param sTargetName The name of the list on oTarget.
/// @param nIndex The index to begin copying from.
/// @param nRange The number of values to copy. If -1, will copy all values from
///     nIndex and up.
/// @param bAddUnique If TRUE, the copy operation will be conducted first and
///     then any duplicate values will be removed. Values in the target list
///     will be prioritiezed over values from the source list.
/// @returns The number of values copied.
int CopyListJson(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE);

/// @brief Increment the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param nIncrement The amount to increment the value by.
/// @param sListName The name of the list.
/// @returns The new value of the int.
int IncrementListInt(object oTarget, int nIndex, int nIncrement = 1, string sListName = "");

/// @brief Decrement the value at an index in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nIndex The index of the value.
/// @param nIncrement The amount to decrement the value by.
/// @param sListName The name of the list.
/// @returns The new value of the int.
int DecrementListInt(object oTarget, int nIndex, int nDecrement = -1, string sListName = "");

/// @brief Convert an object's float list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetFloat().
json GetFloatList(object oTarget, string sListName = "");

/// @brief Convert an object's int list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetInt().
json GetIntList(object oTarget, string sListName = "");

/// @brief Convert an object's location list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetLocation().
json GetLocationList(object oTarget, string sListName = "");

/// @brief Convert an object's vector list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetVector().
json GetVectorList(object oTarget, string sListName = "");

/// @brief Convert an object's object list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with
///     ObjectToString(JsonGetString()).
json GetObjectList(object oTarget, string sListName = "");

/// @brief Convert an object's string list to a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
/// @note Elements of the returned array can be decoded with JsonGetString().
json GetStringList(object oTarget, string sListName = "");

/// @brief Convert an object's json list into a json array.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
json GetJsonList(object oTarget, string sListName = "");

/// @brief Save a json array as an object's float list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonFloat()s.
/// @param sListName The name of the list.
void SetFloatList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's int list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonInt()s.
/// @param sListName The name of the list.
void SetIntList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's location list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonLocation()s.
/// @param sListName The name of the list.
void SetLocationList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonVector()s.
/// @param sListName The name of the list.
void SetVectorList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's object list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonObject()s.
/// @param sListName The name of the list.
void SetObjectList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's string list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of JsonString()s.
/// @param sListName The name of the list.
void SetStringList(object oTarget, json jList, string sListName = "");

/// @brief Save a json array as an object's json list.
/// @param oTarget The object the list is stored on.
/// @param jList A JsonArray() made up of any json types.
/// @param sListName The name of the list.
void SetJsonList(object oTarget, json jList, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteFloatList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteIntList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteLocationList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteVectorList(object oTarget, string sListName = "");

/// @brief Delete an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteObjectList(object oTarget, string sListName = "");

/// @brief Delete an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteStringList(object oTarget, string sListName = "");

/// @brief Delete an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void DeleteJsonList(object oTarget, string sListName = "");

/// @brief Create a float list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param fDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0);

/// @brief Create an int list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param nDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0);

/// @brief Create a location list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareLocationList(object oTarget, int nCount, string sListName = "");

/// @brief Create a vector list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareVectorList(object oTarget, int nCount, string sListName = "");

/// @brief Create an object list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareObjectList(object oTarget, int nCount, string sListName = "");

/// @brief Create a string list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @param sDefault The value to initialize the list with.
/// @returns A json array copy of the created list.
json DeclareStringList(object oTarget, int nCount, string sListName = "", string sDefault = "");

/// @brief Create a json list on a target, deleting any current list.
/// @param oTarget The object to create the list on.
/// @param nCount The number of values to initialize the list with.
/// @param sListName The name of the list.
/// @returns A json array copy of the created list.
json DeclareJsonList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param fDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0);

/// @brief Set the length of an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param nDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0);

/// @brief Set the length of an object's location list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeLocationList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeVectorList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's object list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeObjectList(object oTarget, int nCount, string sListName = "");

/// @brief Set the length of an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional values will be added to the end of the list.
/// @param sListName The name of the list.
/// @param sDefault The value to set any added elements to.
/// @returns A json array copy of the updated list.
json NormalizeStringList(object oTarget, int nCount, string sListName = "", string sDefault = "");

/// @brief Set the length of an object's json list.
/// @param oTarget The object the list is stored on.
/// @param nCount The length to set the list to. If less than the current
///     length, the list will be shortened to match. If greater than the current
///     length, additional null values will be added to the end of the list.
/// @param sListName The name of the list.
/// @returns A json array copy of the updated list.
json NormalizeJsonList(object oTarget, int nCount, string sListName = "");

/// @brief Copy all items from one object's float list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's int list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's location list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's vector list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's object list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's string list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Copy all items from one object's json list to another's.
/// @param oSource The object to copy the list from.
/// @param oTarget The object to copy the list to.
/// @param sSourceName The name of the source list.
/// @param sTargetName The name of the target list.
/// @param bAddUnique If TRUE, will only copy items that are not already present
///     in the target list.
void CopyJsonList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE);

/// @brief Return the number of items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountFloatList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountIntList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountLocationList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountVectorList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountObjectList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountStringList(object oTarget, string sListName = "");

/// @brief Return the number of items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
int CountJsonList(object oTarget, string sListName = "");

/// @brief Sort an object's float list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortFloatList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Sort an object's int list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortIntList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Sort an object's string list.
/// @param oTarget The object the list is stored on.
/// @param nOrder A `LIST_ORDER_*` constant representing how to sort the list.
/// @param sListName The name of the list.
void SortStringList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "");

/// @brief Shuffle the items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleFloatList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleIntList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleLocationList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleVectorList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleObjectList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleStringList(object oTarget, string sListName = "");

/// @brief Shuffle the items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ShuffleJsonList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's float list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseFloatList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's int list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseIntList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's location list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseLocationList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's vector list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseVectorList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's object list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseObjectList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's string list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseStringList(object oTarget, string sListName = "");

/// @brief Reverse the order of the items in an object's json list.
/// @param oTarget The object the list is stored on.
/// @param sListName The name of the list.
void ReverseJsonList(object oTarget, string sListName = "");

// -----------------------------------------------------------------------------
//                           Function Implementations
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                              Private Functions
// -----------------------------------------------------------------------------

// Determines whether nIndex is a valid reference to an array element in jList.
// If bNegative is TRUE, -1 will be returned as a valid nIndex value.
int _GetIsIndexValid(json jList, int nIndex, int bNegative = FALSE)
{
    return nIndex == 0 || nIndex >= (0 - bNegative) && nIndex < JsonGetLength(jList);
}

// Retrieves json array sListName of sListType from oTarget.
json _GetList(object oTarget, string sListType, string sListName = "")
{
    json jList = GetLocalJson(oTarget, LIST_REF + sListType + sListName);
    return jList == JSON_NULL ? JSON_ARRAY : jList;
}

// Sets sListType json array jList as sListName on oTarget.
void _SetList(object oTarget, string sListType, string sListName, json jList)
{
    SetLocalJson(oTarget, LIST_REF + sListType + sListName, jList);
}

// Deletes sListType json array sListName from oTarget.
void _DeleteList(object oTarget, string sListType, string sListName)
{
    DeleteLocalJson(oTarget, LIST_REF + sListType + sListName);
}

// Inserts array element jValue into json array sListName at nIndex on oTarget.
// Returns the number of elements in the array after insertion. If bUnique is
// TRUE, duplicate values with be removed after the insert operation.
int _InsertListElement(object oTarget, string sListType, string sListName,
                       json jValue, int nIndex, int bUnique)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex, TRUE) == TRUE)
    {
        JsonArrayInsertInplace(jList, jValue, nIndex);
        if (bUnique == TRUE)
            jList = JsonArrayTransform(jList, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sListName, jList);
    }

    return JsonGetLength(jList);
}

// Returns array element at nIndex from array sListName on oTarget. If not
// found, returns JSON_NULL.
json _GetListElement(object oTarget, string sListType, string sListName, int nIndex)
{
    json jList = _GetList(oTarget, sListType, sListName);
    return _GetIsIndexValid(jList, nIndex) ? JsonArrayGet(jList, nIndex) : JSON_NULL;
}

// Deletes array element at nIndex from array sListName on oTarget. Element order
// is maintained. Returns the number of array elements remaining after deletion.
int _DeleteListElement(object oTarget, string sListType, string sListName, int nIndex)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex) == TRUE && JsonGetLength(jList) > 0)
    {
        JsonArrayDelInplace(jList, nIndex);
        _SetList(oTarget, sListType, sListName, jList);
    }

    return JsonGetLength(jList);
}

// Finds array element jValue in array sListName on oTarget. If found, returns the
// index of the elements. If not, returns -1.
int _FindListElement(object oTarget, string sListType, string sListName, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);
    json jIndex = JsonFind(jList, jValue, 0, JSON_FIND_EQUAL);
    return jIndex == JSON_NULL ? -1 : JsonGetInt(jIndex);
}

// Deletes array element jValue from array sListName on oTarget. Element order
// is maintained. Returns the number of array elements remaining after deletion.
int _RemoveListElement(object oTarget, string sListType, string sListName, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);
    int nIndex = _FindListElement(oTarget, sListType, sListName, jValue);

    if (nIndex > -1)
    {
        JsonArrayDelInplace(jList, nIndex);
        _SetList(oTarget, sListType, sListName, JsonArrayDel(jList, nIndex));
    }

    return JsonGetLength(jList);
}

// Finds array element jValue in array sListName on oTarget. Returns TRUE if found,
// FALSE otherwise.
int _HasListElement(object oTarget, string sListType, string sListName, json jValue)
{
    return _FindListElement(oTarget, sListType, sListName, jValue) > -1;
}

// Replaces array element at nIndex in array sListName on oTarget with jValue.
void _SetListElement(object oTarget, string sListType, string sListName, int nIndex, json jValue)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (_GetIsIndexValid(jList, nIndex) == TRUE)
        _SetList(oTarget, sListType, sListName, JsonArraySet(jList, nIndex, jValue));
}

// This procedure exists because current json operations cannot easily append a list without
// removing duplicate elements or auto-sorting the list. BD is expected to update json
// functions with an append option. If so, replace this function with the json append
// function from nwscript.nss or fold this into _SortList() below.
json _JsonArrayAppend(json jFrom, json jTo)
{
    string sFrom = JsonDump(jFrom);
    string sTo = JsonDump(jTo);

    sFrom = GetStringRight(sFrom, GetStringLength(sFrom) - 1);
    sTo = GetStringLeft(sTo, GetStringLength(sTo) - 1);

    int nFrom = JsonGetLength(jFrom);
    int nTo = JsonGetLength(jTo);

    string s = (nTo == 0 ? "" :
                nTo > 0 && nFrom == 0 ? "" : ",");

    return JsonParse(sTo + s + sFrom);
}

// Copies specified elements from oSource array sSourceName to oTarget array sTargetName.
// Copied elements start at nIndex and continue for nRange elements. Elements copied from
// oSource are appended to the end of oTarget's array.
int _CopyListElements(object oSource, object oTarget, string sListType, string sSourceName,
                      string sTargetName, int nIndex, int nRange, int bUnique)
{
    json jSource = _GetList(oSource, sListType, sSourceName);
    json jTarget = _GetList(oTarget, sListType, sTargetName);

    if (jTarget == JSON_NULL)
        jTarget = JSON_ARRAY;

    int nSource = JsonGetLength(jSource);
    int nTarget = JsonGetLength(jTarget);

    if (nSource == 0) return 0;

    json jCopy, jReturn;

    if (nIndex == 0 && (nRange == -1 || nRange >= nSource))
    {
        if (jSource == JSON_NULL || nSource == 0)
            return 0;

        jReturn = _JsonArrayAppend(jSource, jTarget);
        if (bUnique == TRUE)
            jReturn = JsonArrayTransform(jReturn, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sTargetName, jReturn);
        return nSource;
    }

    if (_GetIsIndexValid(jSource, nIndex) == TRUE)
    {
        int nMaxIndex = nSource - nIndex;
        if (nRange == -1)
            nRange = nMaxIndex;
        else if (nRange > (nMaxIndex))
            nRange = clamp(nRange, 1, nMaxIndex);

        jCopy = JsonArrayGetRange(jSource, nIndex, nIndex + (nRange - 1));
        jReturn = _JsonArrayAppend(jTarget, jCopy);
        if (bUnique == TRUE)
            jReturn = JsonArrayTransform(jReturn, JSON_ARRAY_UNIQUE);

        _SetList(oTarget, sListType, sTargetName, jReturn);
        return JsonGetLength(jCopy) - JsonGetLength(JsonSetOp(jCopy, JSON_SET_INTERSECT, jTarget));
    }

    return 0;
}

// Modifies an int list element by nIncrement and returns the new value.
int _IncrementListElement(object oTarget, string sListName, int nIndex, int nIncrement)
{
    json jList = _GetList(oTarget, VARLIST_TYPE_INT, sListName);

    if (_GetIsIndexValid(jList, nIndex))
    {
        int nValue = JsonGetInt(JsonArrayGet(jList, nIndex)) + nIncrement;
        JsonArraySetInplace(jList, nIndex, JsonInt(nValue));
        _SetList(oTarget, VARLIST_TYPE_INT, sListName, jList);

        return nValue;
    }

    return 0;
}

// Creates an array of length nLength jDefault elements as sListName on oTarget.
json _DeclareList(object oTarget, string sListType, string sListName, int nLength, json jDefault)
{
    json jList = JSON_ARRAY;

    int n;
    for (n = 0; n < nLength; n++)
        JsonArrayInsertInplace(jList, jDefault);

    _SetList(oTarget, sListType, sListName, jList);
    return jList;
}

// Sets the array length to nLength, adding/removing elements as required.
json _NormalizeList(object oTarget, string sListType, string sListName, int nLength, json jDefault)
{
    json jList = _GetList(oTarget, sListType, sListName);
    if (jList == JSON_ARRAY)
        return _DeclareList(oTarget, sListType, sListName, nLength, jDefault);
    else if (nLength < 0)
        return jList;
    else
    {
        int n, nList = JsonGetLength(jList);
        if (nList > nLength)
            jList = JsonArrayGetRange(jList, 0, nLength - 1);
        else
        {
            for (n = 0; n < nLength - nList; n++)
                JsonArrayInsertInplace(jList, jDefault);
        }

        _SetList(oTarget, sListType, sListName, jList);
    }

    return jList;
}

// Returns the length of array sListName on oTarget.
int _CountList(object oTarget, string sListType, string sListName)
{
    return JsonGetLength(_GetList(oTarget, sListType, sListName));
}

// Sorts sListName on oTarget in order specified by nOrder.
void _SortList(object oTarget, string sListType, string sListName, int nOrder)
{
    json jList = _GetList(oTarget, sListType, sListName);

    if (JsonGetLength(jList) > 1)
        _SetList(oTarget, sListType, sListName, JsonArrayTransform(jList, nOrder));
}

// -----------------------------------------------------------------------------
//                              Public Functions
// -----------------------------------------------------------------------------

json VectorToJson(vector vPosition = [0.0, 0.0, 0.0])
{
    json jPosition = JSON_OBJECT;
    JsonObjectSetInplace(jPosition, "x", JsonFloat(vPosition.x));
    JsonObjectSetInplace(jPosition, "y", JsonFloat(vPosition.y));
    JsonObjectSetInplace(jPosition, "z", JsonFloat(vPosition.z));

    return jPosition;
}

json JsonVector(vector vPosition = [0.0, 0.0, 0.0])
{
    return VectorToJson(vPosition);
}

vector JsonToVector(json jPosition)
{
    float x = JsonGetFloat(JsonObjectGet(jPosition, "x"));
    float y = JsonGetFloat(JsonObjectGet(jPosition, "y"));
    float z = JsonGetFloat(JsonObjectGet(jPosition, "z"));

    return Vector(x, y, z);
}

vector JsonGetVector(json jPosition)
{
    return JsonToVector(jPosition);
}

json LocationToJson(location lLocation)
{
    json jLocation = JSON_OBJECT;
    JsonObjectSetInplace(jLocation, "area", JsonString(GetTag(GetAreaFromLocation(lLocation))));
    JsonObjectSetInplace(jLocation, "position", VectorToJson(GetPositionFromLocation(lLocation)));
    JsonObjectSetInplace(jLocation, "facing", JsonFloat(GetFacingFromLocation(lLocation)));

    return jLocation;
}

json JsonLocation(location lLocation)
{
    return LocationToJson(lLocation);
}

location JsonToLocation(json jLocation)
{
    object oArea = GetObjectByTag(JsonGetString(JsonObjectGet(jLocation, "area")));
    vector vPosition = JsonToVector(JsonObjectGet(jLocation, "position"));
    float fFacing = JsonGetFloat(JsonObjectGet(jLocation, "facing"));

    return Location(oArea, vPosition, fFacing);
}

location JsonGetLocation(json jLocation)
{
    return JsonToLocation(jLocation);
}

int AddListFloat(object oTarget, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue), -1, bAddUnique);
}

int AddListInt(object oTarget, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue), -1, bAddUnique);
}

int AddListLocation(object oTarget, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation, -1, bAddUnique);
}

int AddListVector(object oTarget, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector, -1, bAddUnique);
}

int AddListObject(object oTarget, object oValue, string sListName = "", int bAddUnique = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _InsertListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject, -1, bAddUnique);
}

int AddListString(object oTarget, string sString, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sString), -1, bAddUnique);
}

int AddListJson(object oTarget, json jValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue, -1, bAddUnique);
}

float GetListFloat(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex);
    return jValue == JSON_NULL ? 0.0 : JsonGetFloat(jValue);
}

int GetListInt(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex);
    return jValue == JSON_NULL ? -1 : JsonGetInt(jValue);
}

location GetListLocation(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex);

    if (jValue == JSON_NULL)
        return Location(OBJECT_INVALID, Vector(), 0.0);
    else
        return JsonToLocation(jValue);
}

vector GetListVector(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex);

    if (jValue == JSON_NULL)
        return Vector();
    else
        return JsonToVector(jValue);
}

object GetListObject(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex);
    return jValue == JSON_NULL ? OBJECT_INVALID : StringToObject(JsonGetString(jValue));
}

string GetListString(object oTarget, int nIndex = 0, string sListName = "")
{
    json jValue = _GetListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex);
    return jValue == JSON_NULL ? "" : JsonGetString(jValue);
}

json GetListJson(object oTarget, int nIndex = 0, string sListName = "")
{
    return _GetListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex);
}

int DeleteListFloat(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex);
}

int DeleteListInt(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex);
}

int DeleteListLocation(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex);
}

int DeleteListVector(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex);
}

int DeleteListObject(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex);
}

int DeleteListString(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex);
}

int DeleteListJson(object oTarget, int nIndex, string sListName = "", int bMaintainOrder = FALSE)
{
    return _DeleteListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex);
}

int RemoveListFloat(object oTarget, float fValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue));
}

int RemoveListInt(object oTarget, int nValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue));
}

int RemoveListLocation(object oTarget, location lValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _RemoveListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation);
}

int RemoveListVector(object oTarget, vector vValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _RemoveListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector);
}

int RemoveListObject(object oTarget, object oValue, string sListName = "", int bMaintainOrder = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _RemoveListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject);
}

int RemoveListString(object oTarget, string sValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue));
}

int RemoveListJson(object oTarget, json jValue, string sListName = "", int bMaintainOrder = FALSE)
{
    return _RemoveListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue);
}

float PopListFloat(object oTarget, string sListName = "")
{
    float f = GetListFloat(oTarget, 0, sListName);
    DeleteListFloat(oTarget, 0, sListName);
    return f;
}

int PopListInt(object oTarget, string sListName = "")
{
    int n = GetListInt(oTarget, 0, sListName);
    DeleteListInt(oTarget, 0, sListName);
    return n;
}

location PopListLocation(object oTarget, string sListName = "")
{
    location l = GetListLocation(oTarget, 0, sListName);
    DeleteListLocation(oTarget, 0, sListName);
    return l;
}

vector PopListVector(object oTarget, string sListName = "")
{
    vector v = GetListVector(oTarget, 0, sListName);
    DeleteListVector(oTarget, 0, sListName);
    return v;
}

object PopListObject(object oTarget, string sListName = "")
{
    object o = GetListObject(oTarget, 0, sListName);
    DeleteListObject(oTarget, 0, sListName);
    return o;
}

string PopListString(object oTarget, string sListName = "")
{
    string s = GetListString(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName);
    return s;
}

json PopListJson(object oTarget, string sListName = "")
{
    json j = GetListJson(oTarget, 0, sListName);
    DeleteListString(oTarget, 0, sListName);
    return j;
}

int FindListFloat(object oTarget, float fValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue));
}

int FindListInt(object oTarget, int nValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue));
}

int FindListLocation(object oTarget, location lValue, string sListName = "")
{
    json jLocation = LocationToJson(lValue);
    return _FindListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation);
}

int FindListVector(object oTarget, vector vValue, string sListName = "")
{
    json jVector = VectorToJson(vValue);
    return _FindListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector);
}

int FindListObject(object oTarget, object oValue, string sListName = "")
{
    json jObject = JsonString(ObjectToString(oValue));
    return _FindListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject);
}

int FindListString(object oTarget, string sValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue));
}

int FindListJson(object oTarget, json jValue, string sListName = "")
{
    return _FindListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue);
}

int HasListFloat(object oTarget, float fValue, string sListName = "")
{
    return FindListFloat(oTarget, fValue, sListName) != -1;
}

int HasListInt(object oTarget, int nValue, string sListName = "")
{
    return FindListInt(oTarget, nValue, sListName) != -1;
}

int HasListLocation(object oTarget, location lValue, string sListName = "")
{
    return FindListLocation(oTarget, lValue, sListName) != -1;
}

int HasListVector(object oTarget, vector vValue, string sListName = "")
{
    return FindListVector(oTarget, vValue, sListName) != -1;
}

int HasListObject(object oTarget, object oValue, string sListName = "")
{
    return FindListObject(oTarget, oValue, sListName) != -1;
}

int HasListString(object oTarget, string sValue, string sListName = "")
{
    return FindListString(oTarget, sValue, sListName) != -1;
}

int HasListJson(object oTarget, json jValue, string sListName = "")
{
    return FindListJson(oTarget, jValue, sListName) != -1;
}

int InsertListFloat(object oTarget, int nIndex, float fValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, JsonFloat(fValue), nIndex, bAddUnique);
}

int InsertListInt(object oTarget, int nIndex, int nValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_INT, sListName, JsonInt(nValue), nIndex, bAddUnique);
}

int InsertListLocation(object oTarget, int nIndex, location lValue, string sListName = "", int bAddUnique = FALSE)
{
    json jLocation = LocationToJson(lValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, jLocation, nIndex, bAddUnique);
}

int InsertListVector(object oTarget, int nIndex, vector vValue, string sListName = "", int bAddUnique = FALSE)
{
    json jVector = VectorToJson(vValue);
    return _InsertListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, jVector, nIndex, bAddUnique);
}

int InsertListObject(object oTarget, int nIndex, object oValue, string sListName = "", int bAddUnique = FALSE)
{
    json jObject = JsonString(ObjectToString(oValue));
    return _InsertListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, jObject, nIndex, bAddUnique);
}

int InsertListString(object oTarget, int nIndex, string sValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_STRING, sListName, JsonString(sValue), nIndex, bAddUnique);
}

int InsertListJson(object oTarget, int nIndex, json jValue, string sListName = "", int bAddUnique = FALSE)
{
    return _InsertListElement(oTarget, VARLIST_TYPE_JSON, sListName, jValue, nIndex, bAddUnique);
}

void SetListFloat(object oTarget, int nIndex, float fValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_FLOAT, sListName, nIndex, JsonFloat(fValue));
}

void SetListInt(object oTarget, int nIndex, int nValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_INT, sListName, nIndex, JsonInt(nValue));
}

void SetListLocation(object oTarget, int nIndex, location lValue, string sListName = "")
{
    json jLocation = LocationToJson(lValue);
    _SetListElement(oTarget, VARLIST_TYPE_LOCATION, sListName, nIndex, jLocation);
}

void SetListVector(object oTarget, int nIndex, vector vValue, string sListName = "")
{
    json jVector = VectorToJson(vValue);
    _SetListElement(oTarget, VARLIST_TYPE_VECTOR, sListName, nIndex, jVector);
}

void SetListObject(object oTarget, int nIndex, object oValue, string sListName = "")
{
    json jObject = JsonString(ObjectToString(oValue));
    _SetListElement(oTarget, VARLIST_TYPE_OBJECT, sListName, nIndex, jObject);
}

void SetListString(object oTarget, int nIndex, string sValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_STRING, sListName, nIndex, JsonString(sValue));
}

void SetListJson(object oTarget, int nIndex, json jValue, string sListName = "")
{
    _SetListElement(oTarget, VARLIST_TYPE_JSON, sListName, nIndex, jValue);
}

int CopyListFloat(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_FLOAT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListInt(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_INT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListLocation(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_LOCATION, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListVector(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_VECTOR, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListObject(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_OBJECT, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListString(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_STRING, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int CopyListJson(object oSource, object oTarget, string sSourceName, string sTargetName, int nIndex, int nRange = 1, int bAddUnique = FALSE)
{
    return _CopyListElements(oSource, oTarget, VARLIST_TYPE_JSON, sSourceName, sTargetName, nIndex, nRange, bAddUnique);
}

int IncrementListInt(object oTarget, int nIndex, int nIncrement = 1, string sListName = "")
{
    return _IncrementListElement(oTarget, sListName, nIndex, nIncrement);
}

int DecrementListInt(object oTarget, int nIndex, int nDecrement = -1, string sListName = "")
{
    return _IncrementListElement(oTarget, sListName, nIndex, nDecrement);
}

json GetFloatList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

json GetIntList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_INT, sListName);
}

json GetLocationList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

json GetVectorList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

json GetObjectList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

json GetStringList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_STRING, sListName);
}

json GetJsonList(object oTarget, string sListName = "")
{
    return _GetList(oTarget, VARLIST_TYPE_JSON, sListName);
}

void SetFloatList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_FLOAT, sListName, jList);
}

void SetIntList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_INT, sListName, jList);
}

void SetLocationList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_LOCATION, sListName, jList);
}

void SetVectorList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_VECTOR, sListName, jList);
}

void SetObjectList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_OBJECT, sListName, jList);
}

void SetStringList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_STRING, sListName, jList);
}

void SetJsonList(object oTarget, json jList, string sListName = "")
{
    _SetList(oTarget, VARLIST_TYPE_JSON, sListName, jList);
}

void DeleteFloatList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

void DeleteIntList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_INT, sListName);
}

void DeleteLocationList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

void DeleteVectorList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

void DeleteObjectList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

void DeleteStringList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_STRING, sListName);
}

void DeleteJsonList(object oTarget, string sListName = "")
{
    _DeleteList(oTarget, VARLIST_TYPE_JSON, sListName);
}

json DeclareFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0)
{
    return _DeclareList(oTarget, VARLIST_TYPE_FLOAT, sListName, nCount, JsonFloat(fDefault));
}

json DeclareIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0)
{
    return _DeclareList(oTarget, VARLIST_TYPE_INT, sListName, nCount, JsonInt(nDefault));
}

json DeclareLocationList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_LOCATION, sListName, nCount, JSON_NULL);
}

json DeclareVectorList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_VECTOR, sListName, nCount, JSON_NULL);
}

json DeclareObjectList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_OBJECT, sListName, nCount, JSON_NULL);
}

json DeclareStringList(object oTarget, int nCount, string sListName = "", string sDefault = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_STRING, sListName, nCount, JsonString(sDefault));
}

json DeclareJsonList(object oTarget, int nCount, string sListName = "")
{
    return _DeclareList(oTarget, VARLIST_TYPE_JSON, sListName, nCount, JSON_NULL);
}

json NormalizeFloatList(object oTarget, int nCount, string sListName = "", float fDefault = 0.0)
{
    return _NormalizeList(oTarget, VARLIST_TYPE_FLOAT, sListName, nCount, JsonFloat(fDefault));
}

json NormalizeIntList(object oTarget, int nCount, string sListName = "", int nDefault = 0)
{
    return _NormalizeList(oTarget, VARLIST_TYPE_INT, sListName, nCount, JsonInt(nDefault));
}

json NormalizeLocationList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_LOCATION, sListName, nCount, JSON_NULL);
}

json NormalizeVectorList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_VECTOR, sListName, nCount, JSON_NULL);
}

json NormalizeObjectList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_OBJECT, sListName, nCount, JSON_NULL);
}

json NormalizeStringList(object oTarget, int nCount, string sListName = "", string sDefault = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_STRING, sListName, nCount, JsonString(sDefault));
}

json NormalizeJsonList(object oTarget, int nCount, string sListName = "")
{
    return _NormalizeList(oTarget, VARLIST_TYPE_JSON, sListName, nCount, JSON_NULL);
}

void CopyFloatList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_FLOAT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyIntList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_INT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyLocationList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_LOCATION, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyVectorList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_VECTOR, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyObjectList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_OBJECT, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyStringList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_STRING, sSourceName, sTargetName, 0, -1, bAddUnique);
}

void CopyJsonList(object oSource, object oTarget, string sSourceName, string sTargetName, int bAddUnique = FALSE)
{
    _CopyListElements(oSource, oTarget, VARLIST_TYPE_JSON, sSourceName, sTargetName, 0, -1, bAddUnique);
}

int CountFloatList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_FLOAT, sListName);
}

int CountIntList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_INT, sListName);
}

int CountLocationList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_LOCATION, sListName);
}

int CountVectorList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_VECTOR, sListName);
}

int CountObjectList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_OBJECT, sListName);
}

int CountStringList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_STRING, sListName);
}

int CountJsonList(object oTarget, string sListName = "")
{
    return _CountList(oTarget, VARLIST_TYPE_JSON, sListName);
}

void SortFloatList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, nOrder);
}

void SortIntList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, nOrder);
}

void SortStringList(object oTarget, int nOrder = LIST_SORT_ASC, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, nOrder);
}

void ShuffleFloatList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleIntList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleLocationList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_LOCATION, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleVectorList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_VECTOR, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleObjectList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_OBJECT, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleStringList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, JSON_ARRAY_SHUFFLE);
}

void ShuffleJsonList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_JSON, sListName, JSON_ARRAY_SHUFFLE);
}

void ReverseFloatList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_FLOAT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseIntList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_INT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseLocationList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_LOCATION, sListName, JSON_ARRAY_REVERSE);
}

void ReverseVectorList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_VECTOR, sListName, JSON_ARRAY_REVERSE);
}

void ReverseObjectList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_OBJECT, sListName, JSON_ARRAY_REVERSE);
}

void ReverseStringList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_STRING, sListName, JSON_ARRAY_REVERSE);
}

void ReverseJsonList(object oTarget, string sListName = "")
{
    _SortList(oTarget, VARLIST_TYPE_JSON, sListName, JSON_ARRAY_REVERSE);
}
ARE V3.28      t   Q   @  3   p  T   �  D  	     �����   )          
      (   
      P   
      x   
          ���        2                                                                      	          
                                                                                            	          
                                                                                             	          
                                                                                            	          
                                                             22d                                      ����         
      !                   22d            
      1         h~�                                                                 !          "         #   dd�    $   5      %   >       &          '   ?      (     4B    )          *   ����    +           ,         -          .   E      /   F      0   G      1          2      SunDiffuseColor ShadowOpacity   Tile_List       Tile_AnimLoop1  Tile_AnimLoop2  Tile_MainLight2 Tile_SrcLight1  Tile_Height     Tile_SrcLight2  Tile_MainLight1 Tile_ID         Tile_AnimLoop3  Tile_OrientationChanceLightning Name            SunAmbientColor DayNightCycle   SunShadows      LightingScheme  Creator_ID      Height          Tag             LoadScreenID    MoonFogColor    SkyBox          Comments        SunFogColor     IsNight         MoonAmbientColorChanceSnow      Width           MoonShadows     ModListenCheck  ModSpotCheck    Flags           MoonDiffuseColorOnEnter         OnUserDefined   SunFogAmount    Tileset         FogClipDist     NoRest          ID              MoonFogAmount   PlayerVsPlayer  WindPower       OnExit          OnHeartbeat     ResRef          ChanceRain      Expansion_List     ����          Starting Area   StartingArea    hook_nwn tms01  startingarea                     	   
                                                                      !   "   #   $   %   &   '   (   )          *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P                      IFO V3.28      P   0   �  0   �  �     �   �     ����    /                                      "                   /            A      0   
      1                 	         
   ;         <                  =         >         R   
      S                     �?         A                          [         h         i         j         k   
      l          
                           p          q      !   z      "   {      #   |       $         %         &   }      '          (   \     )          *   ~      +          ,         -   �      .          /      Mod_Creator_ID  Mod_Name        Mod_Area_list   Area_Name       Mod_OnSpawnBtnDnMod_Entry_Y     Mod_OnPlrChat   Mod_Tag         Mod_IsSaveGame  Mod_HakList     Mod_OnPlrUnEqItmMod_OnClientEntrMod_GVar_List   Mod_OnPlrRest   Mod_Description Mod_OnClientLeavMod_MinGameVer  Mod_StartHour   Mod_Entry_Dir_Y Mod_Entry_X     Mod_DuskHour    Mod_MinPerHour  Mod_Entry_Area  Mod_OnPlrEqItm  Mod_OnHeartbeat Mod_OnCutsnAbortMod_StartMovie  Mod_CustomTlk   Mod_XPScale     Mod_Expan_List  Expansion_Pack  Mod_OnPlrDeath  Mod_OnModLoad   Mod_OnPlrLvlUp  Mod_OnModStart  Mod_OnAcquirItemMod_StartMonth  Mod_CutSceneListMod_OnUsrDefinedMod_Entry_Z     Mod_StartYear   Mod_Entry_Dir_X Mod_OnActvtItem Mod_OnUnAqreItemMod_DawnHour    Mod_OnPlrDying  Mod_Version     Mod_StartDay       ����          core_frameworkstartingarea     MODULE      ����               1.83startingarea         hook_nwn                                	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /                         GIT V3.28   W   L  �  �  �   \(    ],  �  3  �  �����  
         G                  !          "          #          $          %          &          '          (          )          *          +          ,          -          .          /          0          1          2          3          4          5          6          7          8          9          :          ;         J         K                             ,  ^      �         �         �         �         �         �         �         �         �         �         0  -              �        �        �                 �          �          �          �          �          �          �          �          �          �          �                                                                                            	         
                                                                     	   �  8       �     	   �  7   	   �  8       l         x     d   d  	                                       �          
         y                         	         
                  
                        �                                                           �,<A                �         !         "                                                    
      /                           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "           "          !          #          $          %          &   3      '   4      (   �       )   2      *       
   +   5       ,          -          .           /   
      1        1   .      0   |      2   �       3          4   �5?    5       
   7   9   
   8   D      9         6   �      :     �>    ;   2      <   S      =   `      >   a      ?   b       @   
       A   
      B   c      C          D         E   o       F   
      G   p      H   #JA   I   �5�   K         L         J   �      M   |      N   �      O          P            }         �                    
         �         �      
           Q      
      �                            R            �         ��}@    S          T             �                U      
      �                             #          $         &   �       V         *           ,          -          /         1         1         1        1   �      1   g     1   �     1   A     1        1          1   .      0   �      W                 
      �       X          Y           Z          [              ��        ��    \          ]          ^          _          `         a   �       b          c          d           e   '       f   %      g   �       h          i          j          k           l          m         4          n           o           p         q         <   �       r          s          t          u          v           w          x          y   �      G   �      H     ��   I     �?    z         2   �       3         :      ?   <   �      >   �       {          |           }          @          A          ~          D          F                    G   �      H   ��@   K         L          �          �   !       �          �          �   %       �          �          �   d       �          �          �   �       �         �   �      J   �       z                     �            ��     	                                                   �    �          �            	                 
                                     �       "           "          "           "          "          "          "          "          "          "           "          "          "          "          "           "           "          "           "          "          "          "          "          "          "           "           "           "          !   �       �          %          (          '         )   2   
   +         �   �       .          4   �;?    5       
   7     
   8        9         6   l      ;   2      =   )     ?   *      �          �          �         C         B   +     E   C     I   /�T?    �         M   D     N   �         t     �   �     �   �     �   �     �   �     �   �                �          �          �   E     �   ��=A
      F        |      �           �                   �      �    �          �          �   U      �           �          �         �   V        W  
   �   X     �   \     �   �I�    �           �           �           #          �   ]     �   ^     �   j      �           �          �   k  
   7   l  
   8        9         6   �     �   �     �   �     <   �     �   9A    �         �   �     �   �      �          �          �          �          9          �   �      �          �         �   �     �          �          �   �      �         G   �      �          �   �               �          �          �   �     �   ���@
      �        �      �           �                   �      �    �          �          �   �      �           �          �         �   �        �  
   �   �     �   �     �   ���    �           �           �           #          �   �     �   �     �   �      �           �          �   �     �   �     �   �     <   �     �   N�M@    �         �   �     �   �      �          �          �          �   �       9          �   �      �          �         �   �     �          �          �   �      �         G          �          �   �               �          �          �   �     �   �D�@
      �        �      �           �                   �           �          �          �   �      �           �          �         �   �        �  
   �   �     �   �     �   ��?    �           �           �           #          �   �     �   �     �   �      �           �          �   �  
   7   �  
   8   �     9      
   7   �  
   8   �     9         6   �     �   �     �   �     <   �     �   ���@    �         �   �     �   �      �          �          �          �   0       9          �   �      �          �         �   �     �          �          �   �      �         G   �      �          �         �   �     �   �     �          �         �          �         �         �   "      �          �   �S    �         �   V      �   �  Creature List   Plot            LastName        ScriptEndRound  Tail_New        Wis             SoundSetFile    TemplateList    ScriptSpawn     ScriptDisturbed fortbonus       NoPermDeath     Tag             WalkRate        PortraitId      Lootable        Phenotype       ZPosition       Interruptable   ScriptSpellAt   YPosition       ScriptDamaged   Appearance_Type ScriptOnNotice  Conversation    MaxHitPoints    Race            CRAdjust        CurrentHitPointsIsImmortal      Deity           SpecAbilityList willbonus       SkillList       Rank            BodyBag         HitPoints       NaturalAC       ScriptAttacked  ScriptHeartbeat Wings_New       LawfulChaotic   refbonus        Subrace         PerceptionRange Disarmable      Gender          Int             FeatList        Feat            Equip_ItemList  StartingPackage XOrientation    IsPC            VarTable        Name            Value           Type            ChallengeRating GoodEvil        TemplateResRef  ScriptDeath     ScriptDialogue  ScriptUserDefineCha             Dex             FirstName       FactionID       Str             ScriptRested    Con             Description     XPosition       YOrientation    ClassList       Class           ClassLevel      ScriptOnBlocked DecayTime       BodyPart_Neck   Color_Tattoo1   BodyPart_LThigh BodyPart_LFoot  BodyPart_LBicep BodyPart_LShoul BodyPart_LFArm  BodyPart_RThigh Cost            ArmorPart_RFArm ArmorPart_LShoulArmorPart_RBicepLeather2Color   Leather1Color   Cursed          BaseItem        Metal1Color     ArmorPart_LThighPropertiesList  ArmorPart_LHand ArmorPart_Neck  Charges         ArmorPart_Torso ArmorPart_PelvisDescIdentified  ArmorPart_LShin ArmorPart_LFoot ArmorPart_LBicepArmorPart_Belt  ArmorPart_RShin Metal2Color     AddCost         ArmorPart_Robe  ArmorPart_RThighStackSize       Identified      Cloth2Color     ArmorPart_RHand ArmorPart_LFArm ArmorPart_RShoulCloth1Color     Stolen          LocalizedName   ArmorPart_RFoot Color_Skin      BodyPart_Belt   BodyPart_RShin  Color_Hair      BodyPart_RShoul KnownList0      SpellMetaMagic  Spell           SpellFlags      BodyPart_LShin  Color_Tattoo2   BodyPart_Pelvis BodyPart_RFArm  Appearance_Head BodyPart_LHand  BodyPart_RHand  BodyPart_Torso  BodyPart_RBicep Door List       TriggerList     WaypointList    Encounter List  StoreList       Placeable List  Faction         Locked          OnOpen          X               AutoRemoveKey   Fort            Z               Hardness        AnimationState  OnLock          HasInventory    TrapDisarmable  Useable         OnUserDefined   KeyName         OnInvDisturbed  Bearing         KeyRequired     Lockable        TrapType        OnTrapTriggered LocName         OnUsed          Static          Ref             OnSpellCastAt   OnDisarm        OnClick         Y               DisarmDC        OnDeath         OnClosed        TrapDetectable  OpenLockDC      Will            Appearance      OnUnlock        TrapDetectDC    HP              OnMeleeAttacked CurrentHP       CloseLockDC     OnDamaged       TrapOneShot     TrapFlag        OnHeartbeat     List            AreaProperties  AmbientSndNitVolAmbientSndDay   EnvAudio        MusicNight      AmbientSndNight MusicBattle     AmbientSndDayVolMusicDelay      MusicDay        SoundList          ����          NW_MALEKID01   dlg_convzoom             *Dialog   TokenDialognw_malekid01      Z1          ����        ����                Poet dlg_convzoom        NW_CLOTH024   ����    nw_cloth024   }2         ����    dlg_demo_poet    ����               *Dialog
   PoetDialog     ����          Poet      FloorLever1            )9           OnPlaceableUsed   _test  plc_flrlever1        (9           MerchantsShingle3            �8            Poet Dialog    plc_billboard3     �  �8         q  This NPC is demonstrating a simple dynamic dialog. To make this happen, we:

1. Set his  conversation to "dlg_conv_zoom" (or "dlg_conv_nozoom" if we don't want to zoom in).
2. Add a string variable named "*Dialog" with the value "PoetDialog".
3. Ensure that clicking on the NPC starts his conversation. In this case, we use the "bw_defaultevents" plugin to handle that.     Anvil            :           OnPlaceableUsed   StartDialog   *Dialog   AnvilDialog  	plc_anvil        �8       Q   R   S   e   f                               	   
                                                                  <   =   >   ?   @   A   B   C   D   E   F   G   H   I   L   M   N   O   P   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `   a   b   c   d   g   h   i   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                              !  "  #  $  %  &  '  (  )  *  +  ,  S  T  U  3  4  5  6  7  8  9  :  ;  <  =  >  ?  @  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  V  W  X  Y  Z  [  \  ]  ^  _  `  a  b  c  d  e  f  g  h  i  j  k  l  m  n  o  p  q  r  s  t  u  v  w  x  y  z  {  |  }  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  -  .  /  0  1  2  �  �  �  �                                  	   
                                                                                   !       
   #   $   %   &   '   (   )   *   +   ,          -      /   0   1   2      .          3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N      O         "                          Q      T   U      P   R   S           UTI V3.28      |  a        h  <  �  �  (  p   ����8                                        $          0          <          H          T          `          l          x          �          �          �          �          �          �          �          �          �          �          �                                      ,                                                         
                   
      %   
   	   6      
      
      H   
   	   Z      
      
      l   
   	   }      
      
      �   
   	   �      
      
      �   
   	   �      
      
      �   
   	   �      
      
      �   
   	   	     
      
        
   	   .     
      
      ?  
   	   O     
      
      b  
   	   y     
      
      �  
   	   �     
      
      �  
   	   �     
      
      �  
   	   �     
      
      	  
   	   #     
      
      N  
   	   c     
      
      u  
   	   �     
      
      �  
   	   �     
      
      �  
   	   �     
      
      �  
   	        
      
        
   	   4     
      
      F  
   	   Z     
      
      l  
   	        
      
      �  
   	   �     
      
      �  
   	   �     
      
      �  
   	        
      
        
   	   3     
                                              
      N        l                              �                  �        0  Cost            PaletteID       Plot            AddCost         StackSize       Tag             TemplateResRef  VarTable        Name            Value           Type            Identified      Cursed          BaseItem        Comment         PropertiesList  Charges         Stolen          LocalizedName   ModelPart1      DescIdentified  Description        bw_defaulteventsbw_defaultevents   OnAcquireItem   x2_mod_def_aqu   OnActivateItem   x2_mod_def_act   OnClientEnter   x3_mod_def_enter   OnModuleLoad   x2_mod_def_load   OnPlayerDeath   nw_o0_death   OnPlayerDying   nw_o0_dying   OnPlayerEquipItem   x2_mod_def_equ   OnPlayerRespawn   nw_o0_respawn   OnPlayerRest   x2_mod_def_rest   OnPlayerUnEquipItem   x2_mod_def_unequ   OnUnAcquireItem   x2_mod_def_unaqu   OnCreatureBlocked   nw_c2_defaulte   OnCreatureCombatRoundEnd   nw_c2_default3   OnCreatureConversation'   nw_c2_default4, nw_g0_conversat:default   OnCreatureDamaged   nw_c2_default6   OnCreatureDeath   nw_c2_default7   OnCreatureDisturbed   nw_c2_default8   OnCreatureHeartbeat   nw_c2_default1   OnCreaturePerception   nw_c2_default2   OnCreaturePhysicalAttacked   nw_c2_default5   OnCreatureRested   nw_c2_defaulta   OnCreatureSpawn   nw_c2_default9   OnCreatureSpellCastAt   nw_c2_defaultb   OnCreatureUserDefined   nw_c2_defaultd   OnPlaceableConversation   nw_g0_conversat:default   OnDoorConversation   nw_g0_conversat:default>   This is a template for a data item used by the Core Framework./   ����          [Plugin] Default BioWare Eventsi   ����       Y   This plugin supplies the default BioWare events for the module and creature object types.   ����          	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T                         U   V   W   X   Y   Z   [   \   ]   ^   _   `                              	   
                                                       UTC V3.28   .   `  �   P	  g   �  �   Y  �    �   ����H   [      !         "         #         $         %         &         '         (         )         *         ,         0                                     $          ^          _          `          a          b          c          d          e          f          g          h          i          j          k          l          m          n          o          p          q          r          s          t          u          v          w          x          y          <                                            ,                             
                         	           
      
                                                           
                          #                      
      0                                                  4                                                         "         "         "        "   �      "   g     "   �     "   A     "        "          "   .      !         $   5      #   0       %         &      ?   '   A      (   O       )          *           +          ,          -          .          /          0          1          2   P      4         5          7          8   !       9          7          8   %       9          7          8   d       9          7          8   �       9         6   8      3   L       :          ;           <         =   ��     >   \       ?         @         A        B           C          D         E   ]      F         G   ^      H          I         J          K   T       M           M          M           M          M          M          M          M          M          M           M          M          M          M          M           M           M          M           M          M          M          M          M          M          M           M           M           M          L   X       N          O          P          Q   _       R   2   
   S   `       T   �       U           V       
   X   d   
   Y   o      Z         W   �       [   2      \   }      ]   ~       ^          _          `         a         b         c   �       d         e   �      f   �  BodyPart_Neck   Color_Tattoo1   LastName        PaletteID       ScriptEndRound  Tail_New        Wis             TemplateList    ScriptSpawn     fortbonus       BodyPart_LThigh Tag             Lootable        Interruptable   BodyPart_LFoot  ScriptSpellAt   BodyPart_LBicep Comment         BodyPart_LShoul Conversation    CurrentHitPointsBodyPart_LFArm  Deity           IsImmortal      willbonus       BodyBag         HitPoints       ScriptAttacked  BodyPart_RThigh refbonus        PerceptionRange Disarmable      Int             FeatList        Feat            Equip_ItemList  EquippedRes     StartingPackage ChallengeRating TemplateResRef  ScriptDialogue  Color_Skin      BodyPart_Belt   BodyPart_RShin  Cha             Dex             Color_Hair      Str             Con             BodyPart_RShoul Description     ClassList       Class           ClassLevel      KnownList0      SpellMetaMagic  Spell           SpellFlags      ArmorPart_RFoot Plot            BodyPart_LShin  SoundSetFile    ScriptDisturbed NoPermDeath     WalkRate        PortraitId      Phenotype       Color_Tattoo2   BodyPart_Pelvis ScriptDamaged   Appearance_Type ScriptOnNotice  MaxHitPoints    Race            CRAdjust        SpecAbilityList SkillList       Rank            BodyPart_RFArm  NaturalAC       Wings_New       ScriptHeartbeat LawfulChaotic   Subrace         Appearance_Head Gender          IsPC            VarTable        Name            Value           Type            GoodEvil        ScriptDeath     ScriptUserDefineBodyPart_LHand  BodyPart_RHand  BodyPart_Torso  FactionID       FirstName       ScriptRested    BodyPart_RBicep ScriptOnBlocked DecayTime          ����                Poet     dlg_convzoom     nw_cloth024dlg_demo_poet    ����               *Dialog
   PoetDialog     ����          Poet  >   ?   @   A   B   C   D   E   F   G   H   I   <   =   J   �   �   �                               	   
                                                                      +   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   z   {   |   }   ~      �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �       
                           	   
                                                                                      !   "   #   $   %   &   '   (   )   *   +   ,      -   DLG V3.28   m   T  �  |     <  �	  5%  �  �+  �  �����  	       h                                                 8          0         P          H         h          `         �          x         �          �         �          �         �          �      	   �          �      
   �          �                          (                  @         8        X         P         �         �         �  
       �        �         �         �        (  
       �                                  |  
       P        X         h         `        �  
       �        �         �         �        $  
       �                                   x  
       L        T         d         \        �  
       �        �         �         �           
       �        �                          t  
       H        P         `         X     	   �  
       �        �         �         �     
     
       �        �                           p  
       D        L         \         T        �  
       �        �         �         �          
       �        �                  �        l  
       @        H         X         P                     ����                    
                   
         
   
   	   
            	                                   
   
   ,   
      7      	                     A              
   
   O   
      Z      	                     d              
   
   r   
      }      	                     �              
   
   �   
      �      	   $         
         �              
   
   �   
      �      	   ,         	         �              
   
   �   
      �      	   4                  �              
   
   �   
      	     	   <                               
   
   !  
      ,     	   D                  6             
   
   D  
      O     	   L                  Y             
   
   g  
      r     	   T                  |             
   
   �  
      �     	   \                  �             
   
   �  
      �     	   d                  �             
   
   �  
      �     	   l                  �             
   
   �  
      �     	   t                                      |                             
      8        �             
   
   <  
      G     	   �                   P        �         ^                  h        ����          
   
   t  
      }  
   
   �  
      �        �   
      �  
   
   �  
      �     	   �                   �            
      �        �   
      �        �        �                  �        ����          
   
   �  
      �  
   
     
              �   
        
   
     
      '     	   �                   0            
      >          
      B        F        G                  U        ����          
   
   v  
        
   
   �  
      �          
      �  
   
   �  
      �     	                     �            
      �           
      �        �        �                  �        ����          
   
   �  
         
   
     
              (  
        
   
     
      )     	   4                  2            
      @        <  
      D        H        I                  W        ����          
   
   x  
      �  
   
   �  
      �        D  
      �  
   
   �  
      �     	   P                  �            
      �        X  
      �        �        �                  �        ����          
   
   �  
        
   
     
              `  
        
   
     
      *     	   l                  3            
      A        t  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        |  
      �  
   
   �  
      �     	   �                  �            
      �        �  
      �        �        �                  �        ����          
   
   �  
        
   
     
              �  
        
   
     
      *     	   �                  3            
      A        �  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        �  
      �  
   
   �  
      �     	   �                  �            
      �        �  
      �        �        �                  �        ����          
   
   �  
        
   
     
              �  
        
   
     
      *     	   �                  3            
      A        �  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        �  
      �  
   
   �  
      �     	   �                  �            
      �           
      �        �        �                  �        ����          
   
   �  
        
   
     
                
        
   
     
      *     	                     3            
      A          
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        $  
      �  
   
   �  
      �     	   0                  �            
      �        8  
      �        �        �                  �        ����          
   
   �  
      	  
   
   	  
      	        @  
      	  
   
   	  
      *	     	   L                  3	            
      A	        T  
      E	        I	        J	                  X	        ����          
   
   y	  
      �	  
   
   �	  
      �	        \  
      �	  
   
   �	  
      �	     	   h                  �	            
      �	        p  
      �	        �	        �	                  �	        x            NumWords        EntryList       Delay           AnimLoop        ActionParams    Comment         Sound           Quest           RepliesList     ConditionParams Key             Value           Index           Active          IsChild         Script          Animation       Text            Speaker         DelayReply      StartingList    EndConversation PreventZoomIn   EndConverAbort  ReplyList       EntriesList     LinkComment     DelayEntry                  *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs    ����          <CUSTOM20000>       *Action   *Pagedlg_e_dialogs	dlg_e_enddlg_e_abort   *Node   14   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20015>   *Node   13   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20014>   *Node   12   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20013>   *Node   11   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20012>   *Node   10   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20011>   *Node   9   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20010>   *Node   8   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20009>   *Node   7   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20008>   *Node   6   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20007>   *Node   5   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20006>   *Node   4   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20005>   *Node   3   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20004>   *Node   2   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20003>   *Node   1   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20002>   *Node   0   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20001>      	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `                     a   b   c   d   e   h   i   j   k   l   s   t   u   v   y   z   {   |   }   ~      q   r   w   x   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                  	                    
                        !  "  #  $  %  &  '           (  )  *  +  ,  -  0  1  2  3  6  7  8  9  :  ;  <  .  /  4  5  =  >  ?  @  A  B  E  F  G  H  K  L  M  N  O  P  Q  C  D  I  J  R  S  T  U  V  W  Z  [  \  ]  `  a  b  c  d  e  f  X  Y  ^  _  g  h  i  j  k  l  o  p  q  r  u  v  w  x  y  z  {  m  n  s  t  |  }  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �      f   g   m   n   o   p   �  �                           	                                                                                    
                                          !             #   $      &      %      (   )      +      *      -   .      0      /      2   3      5      4      7   8      :      9      <   =      ?      >      A   B      D      C      F   G      I      H      K   L      N      M      P   Q      S      R      U   V      X      W      Z   [      ]      \      _   `      b      a      d   e      g      f      i   j      l      k      "   '   ,   1   6   ;   @   E   J   O   T   Y   ^   c   h   DLG V3.28   m   T  �  |     <  �	  5%  �  �+  �  �����  	       h                                                 8          0         P          H         h          `         �          x         �          �         �          �         �          �      	   �          �      
   �          �                          (                  @         8        X         P         �         �         �  
       �        �         �         �        (  
       �                                  |  
       P        X         h         `        �  
       �        �         �         �        $  
       �                                   x  
       L        T         d         \        �  
       �        �         �         �           
       �        �                          t  
       H        P         `         X     	   �  
       �        �         �         �     
     
       �        �                           p  
       D        L         \         T        �  
       �        �         �         �          
       �        �                  �        l  
       @        H         X         P                     ����                    
                   
         
   
   	   
            	                                   
   
   ,   
      7      	                     A              
   
   O   
      Z      	                     d              
   
   r   
      }      	                     �              
   
   �   
      �      	   $         
         �              
   
   �   
      �      	   ,         	         �              
   
   �   
      �      	   4                  �              
   
   �   
      	     	   <                               
   
   !  
      ,     	   D                  6             
   
   D  
      O     	   L                  Y             
   
   g  
      r     	   T                  |             
   
   �  
      �     	   \                  �             
   
   �  
      �     	   d                  �             
   
   �  
      �     	   l                  �             
   
   �  
      �     	   t                                      |                             
      8        �             
   
   <  
      G     	   �                   P        �         ^                   h        ����          
   
   t  
      }  
   
   �  
      �        �   
      �  
   
   �  
      �     	   �                   �            
      �        �   
      �        �        �                  �        ����          
   
   �  
      �  
   
     
              �   
        
   
     
      '     	   �                   0            
      >          
      B        F        G                  U        ����          
   
   v  
        
   
   �  
      �          
      �  
   
   �  
      �     	                     �            
      �           
      �        �        �                  �        ����          
   
   �  
         
   
     
              (  
        
   
     
      )     	   4                  2            
      @        <  
      D        H        I                  W        ����          
   
   x  
      �  
   
   �  
      �        D  
      �  
   
   �  
      �     	   P                  �            
      �        X  
      �        �        �                  �        ����          
   
   �  
        
   
     
              `  
        
   
     
      *     	   l                  3            
      A        t  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        |  
      �  
   
   �  
      �     	   �                  �            
      �        �  
      �        �        �                  �        ����          
   
   �  
        
   
     
              �  
        
   
     
      *     	   �                  3            
      A        �  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        �  
      �  
   
   �  
      �     	   �                  �            
      �        �  
      �        �        �                  �        ����          
   
   �  
        
   
     
              �  
        
   
     
      *     	   �                  3            
      A        �  
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        �  
      �  
   
   �  
      �     	   �                  �            
      �           
      �        �        �                  �        ����          
   
   �  
        
   
     
                
        
   
     
      *     	                     3            
      A          
      E        I        J                  X        ����          
   
   y  
      �  
   
   �  
      �        $  
      �  
   
   �  
      �     	   0                  �            
      �        8  
      �        �        �                  �        ����          
   
   �  
      	  
   
   	  
      	        @  
      	  
   
   	  
      *	     	   L                  3	            
      A	        T  
      E	        I	        J	                  X	        ����          
   
   y	  
      �	  
   
   �	  
      �	        \  
      �	  
   
   �	  
      �	     	   h                  �	            
      �	        p  
      �	        �	        �	                  �	        x            NumWords        EntryList       Delay           AnimLoop        ActionParams    Comment         Sound           Quest           RepliesList     ConditionParams Key             Value           Index           Active          IsChild         Script          Animation       Text            Speaker         DelayReply      StartingList    EndConversation PreventZoomIn   EndConverAbort  ReplyList       EntriesList     LinkComment     DelayEntry                  *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs   *Action   *Checkdlg_e_dialogs    ����          <CUSTOM20000>       *Action   *Pagedlg_e_dialogs	dlg_e_enddlg_e_abort   *Node   14   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20015>   *Node   13   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20014>   *Node   12   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20013>   *Node   11   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20012>   *Node   10   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20011>   *Node   9   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20010>   *Node   8   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20009>   *Node   7   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20008>   *Node   6   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20007>   *Node   5   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20006>   *Node   4   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20005>   *Node   3   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20004>   *Node   2   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20003>   *Node   1   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20002>   *Node   0   *Action   *Node       *Action   *Pagedlg_e_dialogs         dlg_e_dialogs   ����          <CUSTOM20001>      	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _   `                     a   b   c   d   e   h   i   j   k   l   s   t   u   v   y   z   {   |   }   ~      q   r   w   x   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                  	                    
                        !  "  #  $  %  &  '           (  )  *  +  ,  -  0  1  2  3  6  7  8  9  :  ;  <  .  /  4  5  =  >  ?  @  A  B  E  F  G  H  K  L  M  N  O  P  Q  C  D  I  J  R  S  T  U  V  W  Z  [  \  ]  `  a  b  c  d  e  f  X  Y  ^  _  g  h  i  j  k  l  o  p  q  r  u  v  w  x  y  z  {  m  n  s  t  |  }  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �      f   g   m   n   o   p   �  �                           	                                                                                    
                                          !             #   $      &      %      (   )      +      *      -   .      0      /      2   3      5      4      7   8      :      9      <   =      ?      >      A   B      D      C      F   G      I      H      K   L      N      M      P   Q      S      R      U   V      X      W      Z   [      ]      \      _   `      b      a      d   e      g      f      i   j      l      k      "   '   ,   1   6   ;   @   E   J   O   T   Y   ^   c   h   ITP V3.28   >      ~   	     �	  "   �	  �  �     ����}          X                    0                                                   (          8          @          H          p          P          X          `          h          �          x          �          �          �          �          �          �          �          �          �          �          �                   �          �          �          �                             P                            (         0         8         @         H         �         `         h         p         x         �         �         �         �         �         �         �         �         �         �         �         �           %        �         0         &        '                  (                  )                  *                  �          	                   8                  9                  :                          G         "         H         #         I         $         J         %                  1        2                  3                  4                  5                  6                                    �          2         ,         ,        -         
         .                  L         �         1         8                  ;        <                  =                  >                  +         /         ?                  X         /                  #        
                  B                  �                   D                  C                  k                   E         !         p         �         K                  &                   '                   (                   *                   )         !          +         #   
                   
                  ?      �          ,         �          -         �                                     !                  "                  #                  $                  �         L         .            MAIN            STRREF          LIST            ID              FACTION         RESREF          NAME            CR                 Commonerdlg_demo_poet   Poet                     	   
                                                                      !   "   #   $   %   &   '   (   )   *   +   ,   -      .   0   1   2   3   /   4   5   6   7   8   :   ;   <   =   >   ?   @   A   B   C   9   D   E   F   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   G   V       W   Y   Z   [   \   ]   ^   _   `   a   b   c   d   f   g   h   i   e   j   k   l   m   X   n   p   q   r   s   t   u   v   w   x   y   o   z   {   |                                                                               !   "   #      &   '   (   )   *   +   ,            	   
                        $   %      5      .   /   0   1   2   3   4   6      8   9   :   ;   <         -   7   =   ITP V3.28      �            @      @  `   �  <   ����          (                                                              0          X          8          @          H          P                                        !                  "                  #                  $                            N                  O        P                  �          	         Q                  R                            ,   MAIN            STRREF          LIST            ID                                      	   
                                                                   	   
                     ITP V3.28      �      �             X   t  4   ����                                                   H                     (          0          8          @          P            �                  �         	         �                  �                                              !                  "                  #                  $                            �                      MAIN            STRREF          ID              LIST                                     	   
                                                   	   
                        ITP V3.28   P   �  �   x     �  4     |  �  |  �����          P                                                              (          H          0          8          @          �          X          `          h          p          x          �                   �          �          �          �          �          �          �          �          �          �          �          �          �          �                                      T         (                   4         <         D         L         \         t         |         d         l         t         �         �         �         �         �         �         �         �         �         �         �                  �         �         �         �         �                           4                  $         ,         <         d         D         L         T         \         l           O        �                   �                  S         	         �                                    �         :         T        �                  U         
         V                                     W        �         7         X                  �         ?         �         ;         �                  �         8         0         8        �         <         �         Y                  �                  Z                  [                  �                  L         �F        @         �         9         ]        ^                  _                  d         \                  +                  a                  b                  p         �         6                              
               �                    !                  "                  #                  $                  �         L         5         �        d        e                  f                  g                  �         �        j                   h                  i                  �         k        l         !         m         "         n         #         o         $         +         %         p         &         �         �        q         '         r         (         s         )         t         *         �         =         �         w         .         x         /         y        z         0         {         1         |         2                 �         3         �        v         +         �         ,         �         -         �         >                 �         4         0         \  MAIN            STRREF          LIST            ID              RESREF          NAME            bw_defaultevents   [Plugin] Default BioWare Events                        	   
                                                                       !   "      #   %   &   (   )   *   +   ,   -   .   /   0   1   '   2   3   4   5   6   8   9   :   ;   7   <   =   >   ?   @   A   B   C   D   $   E   F   G   J   K   I   L   M   N   O   P   Q   R   S   T   U   H   V   W   X   [   \   ]   ^   _   `   Z   a   c   d   e   f   g   h   b   i   k   l   m   n   o   p   q   r   s   t   u   v   j   w   y   z   {   |   }   ~      �   �   �   x   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   Y   �      	   
                                                                              	                      !   "   #      '      &   (   )   *   +      /   0   1      3   4   5      7   8   9   :   ;   <      >   ?   @   A   B      F   G   H      K   L   M   N   
   .   2   6   =   C   D   E   I   J   O               $   %   ,   -   ITP V3.28      d  2   �     �      �  �   �  l   ����1                                                              (          0          8          @          H          x          P          X          `          h          p          �          �          �          �          �          �          �          �                              /�                 ~                  �                  8         	         �         
         �                  �                  �#                  �#                                              !                  "                  #                  $                            �                  �       �                  �                                   ��                  <                                    }                   0   MAIN            STRREF          ID              LIST                                        	   
                                                                      !   #   $   %   &   '   (   )   *   +   ,   "   -   .   /   0                                                                  	   
               ITP V3.28      �            @      @  `   �  8   ����                                                              P          (          0          8          @          H          X            &                  9�                  �                  �                  �                                              !                  "                  #                  $                            �                      MAIN            STRREF          ID              LIST                                        	                                 
                     	   
                              ITP V3.28      �      L     �      �  8   �  $   ����                     0                                                   (            �                                              !                  "                  #                  $                                MAIN            STRREF          ID              LIST                                     	   
                                          ITP V3.28      �      l     �      �  x   $  H   ����                                         @                               (          0          8          p          H          P          X          `          h            :                  �                  �#                                              !                  "                  #                  $                            �        ��                  �                  �                  �                  ��                            0   MAIN            STRREF          ID              LIST                                     	   
                                                                              	                                    
   ITP V3.28      �      L     �      �  8   �  $   ����          (                                                              0                                        !                  "                  #                  $                            �                      MAIN            STRREF          LIST            ID                                      	   
                                           FAC V3.28      p  M        �  5   �  4  �  l   ����,                                     $         0          <         H         T         `         l         x         �         �         �      	   �      
   �         �         �         �         �         �         �                                     ����         
                ����         
               ����         
               ����         
               ����         
      )                                                 2                            2                            2                            d                                                                                                                                           d                           2                           d                                                       2                           d                           d                                                       2                           d                           d                              FactionList     FactionParentID FactionGlobal   FactionName     RepList         FactionRep      FactionID1      FactionID2         PC   Hostile   Commoner   Merchant   Defender                            	   
                                                                   !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   A   B   C   D   E   F   G   H   I   J   K      L                                 	   
                                                GIC V3.28      �      (  
   �     �  $      8   ����    	                      	         	   	      	   
      
          
                                                                 
         
         
                         0      	   4   Creature List   Comment         Door List       TriggerList     WaypointList    Encounter List  StoreList       Placeable List  List            SoundList                                                                                                       JRL V3.28      h           �  n   .  4   b     ����                                                                                                                        @         ��  
      b      	      
   
   j             Categories      XP              EntryList       End             Text            ID              Name            Picture         Tag             Priority        Comment            ����          Test entry 1   ����          Test entry 2   ����          PQJ Test Entry   test                                	   
                        