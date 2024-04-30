//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces6 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.

#include "sha_subr_methds"
void main()
{
//::::::::::::::::::::::::::::::::::::
//::::: SUBRACE: Undead - Lich :::::::
//::::::::::::::::::::::::::::::::::::

//This is an example of how you can equip different skins on Players at different level.
//So that you do not necessarily have to give all subrace feats at once.


//Subrace Name: Lich

//Properties from the Skin:
    //Level 1:
        //Ability Bonus: Charisma +2
        //Ability Bonus: Intelligence +2
        //Ability Bonus: Wisdom +2
        //Damage Reduction: +1 Soak 15 Damage
        //Turn Resistance +4
        //Immunity: Damage Type: Cold 100% Immunity Bonus
        //Immunity: Damage Type: Electrical 100% Immunity Bonus

    //Level 5:
        //Gains - Immunity: Miscellaneous: Disease

    //Level 10:
        //Gains - Immunity: Miscellaneous: Poison

    //Level 15:
        //Gains - Immunity: Miscellaneous: Paralysis

    //Level 20:
        //Gains - Immunity: Miscellaneous: Level/Ability Drain

    //Level 25:
        //Gains - Immunity: Miscellaneous: Mind-Affecting Spells

    //Level 30:
        //Gains - Immunity: Miscellaneous: Death Magic

    //Level 35:
        //Gains - Immunity: Miscellaneous: Sneak Attack

    //Level 40:
        //Gains - Immunity: Miscellaneous: Critical Hits


//Abilities from the unique item:
    //Cast Spell: Destruction (13) 1 Use/Day
    //Cast Spell: Vampiric Touch (5) 1 Use/Day

//Human. Light Sensitive. Takes 5 Divine Damage While in Sunlight.
//ECL: + 3
//Undead
    CreateSubrace(RACIAL_TYPE_HUMAN, "Lich", "sha_pc_lich", "sha_subrace_lich", TRUE, 4, FALSE, 0, 3, TRUE);

//Can also be Elf.
    AddAdditionalBaseRaceToSubrace("Lich", RACIAL_TYPE_ELF);

//Can also be Half-Elf.
    AddAdditionalBaseRaceToSubrace("Lich", RACIAL_TYPE_HALFELF);

//The different skins to be equipped at different levels...
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich1", 5);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich2", 10);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich3", 15);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich4", 20);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich5", 25);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich6", 30);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich7", 35);
    AddAdditionalSkinsToSubrace("Lich", "sha_pc_lich8", 40);

//Alignment Restriction - Must be Evil.
    CreateSubraceAlignmentRestriction("Lich", FALSE, FALSE, TRUE);

//Class Restriction - Can only be Wizard or Sorcerer.
    CreateSubraceClassRestriction("Lich", FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);

//Spell Resistance: 10 + 1/2 Per Level.
    CreateSubraceSpellResistance("Lich", 10, 30);

//Appearance: Lich - Permanent.
    CreateSubraceAppearance("Lich", TIME_BOTH, APPEARANCE_TYPE_LICH, APPEARANCE_TYPE_HEURODIS_LICH);

//Favored Class: Pale Master
    AddSubraceFavoredClass("Lich", CLASS_TYPE_WIZARD, CLASS_TYPE_WIZARD);

//::::::::::::::::::::::
//:::SUBRACE: Vampire ::
//::::::::::::::::::::::

//Subrace Name: Vampire

//Properties from the Skin:
    //Level 1:
        //Damage Vulnerability: Divine 100% Damage Vulnerability
        //Darkvision
        //Decreased Ability Score: Charisma -2
        //Decreased Saving Throws: Divine -5
        //Regeneration +1
    //Level 5:
        //Gains - Immunity: Miscellaneous: Paralysis
    //Level 10:
        //Gains - Immunity: Miscellaneous: Poison
    //Level 15:
        //Gains - Immunity: Miscellaneous: Disease
    //Level 20:
        //Gains - Immunity: Miscellaneous: Death Magic
        //        Regeneration Increases by +1
    //Level 25:
        //Gains - Immunity: Miscellaneous: Level/Ability Drain
    //Level 30:
        //Gains - Immunity: Miscellaneous: Mind-Affecting Spells
    //Level 35:
        //Gains - Immunity: Miscellaneous: Sneak Attack
    //Level 40:
        //Gains - Immunity: Miscellaneous: Critical Hits
        //        Regeneration Increases by +1
    //NOTE: Final Regeneration rate (At Level 40) is +3.

//Human. Light Sensitive. Takes 2 Divine Damage while in Sunlight.
//ECL: + 3
//Undead
   CreateSubrace(RACIAL_TYPE_HUMAN, "Vampire", "sha_pc_vamp001", "sha_subrace_vamp", TRUE, 2, FALSE, 0, 3, TRUE);

// Can Fly
   AddSubraceItem("Vampire", "sha_subrace_fly");

//Can also be Elf
   AddAdditionalBaseRaceToSubrace("Vampire", RACIAL_TYPE_ELF);

//Can also be Half-Elf
   AddAdditionalBaseRaceToSubrace("Vampire", RACIAL_TYPE_HALFELF);

//Skins that are equipped at certain levels...
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp002", 5);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp003", 10);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp004", 15);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp005", 20);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp006", 25);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp007", 30);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp008", 35);
   AddAdditionalSkinsToSubrace("Vampire", "sha_pc_vamp", 40);

//Alignment Restriction: Can only be evil.
   CreateSubraceAlignmentRestriction("Vampire", FALSE, FALSE, TRUE);

// Hair : any, Skin: light gray 16
   ModifySubraceAppearanceColors("Vampire",-1,-1,16,16);

//Appearance: Change the Appearance to a Vampire using the appearance changer device.
  CreateSubraceAppearance("Vampire", TIME_NONE, APPEARANCE_TYPE_VAMPIRE_MALE, APPEARANCE_TYPE_VAMPIRE_FEMALE, 1);

//Temporary Stats: Bonuses at Night time.
//Increase Strength by 6 points, Dexterity by 4 points, Charisma by 2, and AC by 5 and AB 10 during the Night.
   struct SubraceStats VampStats1 =  CreateCustomStats(SUBRACE_STAT_MODIFIER_TYPE_POINTS, 6.0, 4.0, 0.0, 0.0, 0.0, 2.0, 5.0, 10.0);
   CreateTemporaryStatModifier("Vampire", VampStats1, TIME_NIGHT);

//Favored Class: Rogue.
   AddSubraceFavoredClass("Vampire", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

//Appearance changer device
   AddSubraceItem("Vampire", "sha_vamp_cont", 1);
}
