//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine::::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_on_modhrtbt ::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleHeartBeat script :::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: Sets the correct time of the day for the players.
//
//NOTE:
//::This script is NOT necessay for the Shayan's Subrace Engine to function.
//::This script is useful if you have a fairly large module (with more than 300 areas)
//::Basically what this script does is to make sure the time is advancing on the
//::clock (located on the lower right hand corner, on the compass) for the player,
//::so that they are not surprised when sub-racial events happen. IE: Changes in
//::appearance etc.
void main()
{
    int iHour = GetTimeHour ();
    int iMinute = GetTimeMinute ();
    int iSecond = GetTimeSecond ();
    int iMillisecond = GetTimeMillisecond();
    SetTime(iHour, iMinute, iSecond, iMillisecond);
}
