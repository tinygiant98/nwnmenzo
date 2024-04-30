//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces2 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.

#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Drider :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Drider

//Properties from the Skin:
    //Ability Bonus: Strength +4
    //Ability Bonus: Dexterity +4
    //Ability Bonus: Constitution +6
    //Ability Bonus: Intelligence +4
    //Ability Bonus: Wisdom +6
    //Ability Bonus: Charisma +6
    //Darkvision
    //Saving Throw Bonus: Specific: Will +2
    //Skill Bonus: Hide +4
    //Skill Bonus: Move Silently +4

//Abilities from the unique item:
    //Cast Spell: Darkness (5) 1 Use Per Day
    //Cast Spell: Light () 1 Use Per Day

//Poison : Drider Bite

//Must be Elf. Light Sensitive.
//ECL: +4

   CreateSubrace(RACIAL_TYPE_ELF, "Drider", "sha_pc_Drider", "sha_subrace_drid", TRUE, 0, FALSE, 0, 4);

//Favored Class - Male: Wizard, Female: Cleric.
   AddSubraceFavoredClass("Drider", CLASS_TYPE_WIZARD, CLASS_TYPE_CLERIC);

//Can only be evil
   CreateSubraceAlignmentRestriction("Drider", FALSE, FALSE, TRUE);

//Spell Resistance: Base (at Level 1): 10, Max(at Level 40): 50.
   CreateSubraceSpellResistance("Drider", 10, 50);

//Appearance is permanently changed to Driders (male is different from female)
   CreateSubraceAppearance("Drider", TIME_BOTH, APPEARANCE_TYPE_DRIDER, APPEARANCE_TYPE_DRIDER_FEMALE);

// Give Faerie Fire - Violet
   AddSubraceItem("Drider","sha_subrace_ff_v");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Nymph ::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Nymph

//Properties from the Skin:
//  Dex +6
//  Con +2
//  Int +6
//  Wis +6
//  Cha +8
//  AC : +5
//  DR 10/+1
//  Dark Vision
//  Animal Empath +6

// Spell-Like Abilities From Subrace Item
//  cast : displacement 1/day

// ToDo
//  Aquatic
//  bonus feat : dominate animal
//  cast : Blinding Beauty
//  cast : Stunning glance
//  unearthly grace : Cha Bonus to save

//  ECL : +6

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Nymph", "sha_pc_Nymph", "sha_subrace_nymp", FALSE, 0 , FALSE, 0, 6);

//Favored Class: Sorcerer
    AddSubraceFavoredClass("Nymph", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//Appearance: Satyr - Permanent.
    CreateSubraceAppearance("Nymph", TIME_BOTH, APPEARANCE_TYPE_NYMPH, APPEARANCE_TYPE_NYMPH);

//Chaotic Good Only
   CreateSubraceAlignmentRestriction("Nymph", TRUE, FALSE, FALSE, FALSE, FALSE, TRUE);

// Gender : Female Only
   CreateSubraceGenderRestriction("Nymph",FALSE,TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Air-Touched ::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Air-Touched

//Properties from the Skin:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //AC Bonus vs. Alignment Group: Lawful +2
    //Damage Vulnerability: Magical 25% Damage Vulnerability
    //Decreased Ability Score: Strength -2
    //Decreased Ability Score: Wisdom -2
    //Immunity: Damage Type: Cold 10% Immunity Bonus
    //Immunity: Damage Type: Electrical 10% Immunity Bonus

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Air-touched", "sha_pc_airtouche", "");

// Hair : lightest gray 16, Skin: light blue 20
    ModifySubraceAppearanceColors("Air-touched",16,16,20,20);

//Favored Class: Shadow Dancer
    AddSubraceFavoredClass("Air-touched", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

    SetupSubraceAlias("Air-touched", "air touched");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Half-Drow ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-Drow

//Properties from the Skin:
    //Darkvision

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Half-drow", "sha_pc_halfdrow", "");
    SetupSubraceAlias("Half-drow", "Half-Elf-Dark");
    SetupSubraceAlias("Half-drow", "Half-Elf-Drow");

// White Hair, Black Skin
    ModifySubraceAppearanceColors("Half-drow", 16, 16, 30, 30, 1);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Half-High ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-High
//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Half-Elf-High");
    SetupSubraceAlias("Half-Elf-High", "Half-High");
    SetupSubraceAlias("Half-Elf-High", "Half-High Elf");
    SetupSubraceAlias("Half-Elf-High", "High Half-Elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Shadow :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Shadow

//Properties from the Skin:
    //Ability Bonus: Intelligence +2
    //AC Bonus vs. Alignment Group: Good +1
    //Damage Vulnerability: Positive Energy 25% Damage Vulnerability
    //Darkvision
    //Decreased Ability Score: Charisma -2
    //Immunity: Damage Type: Negative Energy 10% Immunity Bonus

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Shadow", "sha_pc_shadow", "");

//Favored Class: Shadow Dancer
    AddSubraceFavoredClass("Shadow", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

    SetupSubraceAlias("Shadow", "Half-Elf-Shadow");

//::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Satyr :::::::
//::::::::::::::::::::::::::::::::::::::

//Subrace Name: Satyr

//Properties from the Skin:
//  Dex +2
//  Con +2
//  Int +2
//  Wis +2
//  Cha +2
//  AC +4
//  Darkvision
//  Hide, listen, move silent, listen, perform, spot +4

//  ECL : +2

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Satyr", "sha_pc_satyr", "", FALSE, 0, FALSE, 0, 2);

//Favored Class: Bard
    AddSubraceFavoredClass("Satyr", CLASS_TYPE_BARD, CLASS_TYPE_BARD);

//Appearance: Satyr - Permanent.
     CreateSubraceAppearance("Satyr", TIME_BOTH, 143, 143);

// Gender : Male Only
     CreateSubraceGenderRestriction("Satyr",TRUE,FALSE);
}
