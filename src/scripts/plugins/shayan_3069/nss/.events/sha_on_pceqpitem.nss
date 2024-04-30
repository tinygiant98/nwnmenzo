//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine::::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_on_pceqpitem :::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnPlayerEquipItem script :::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: This script is used to check whether the PC belonging to a
//              particular subrace can use the item (weapon) they are trying to
//              equip.

#include "sha_subr_methds"

// 3.0.6.3 - Added fix by MetaPhaze
#include "x2_inc_intweapon"

void main()
{
// 3.0.6.3 - Added fix by MetaPhaze
    if(!GetHasEffect(EFFECT_TYPE_POLYMORPH, GetPCItemLastEquippedBy())) return;

    SubraceOnPlayerEquipItem();
}



