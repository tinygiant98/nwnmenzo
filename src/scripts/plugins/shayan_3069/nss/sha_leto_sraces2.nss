//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_leto_sraces2 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: This script holds the pre-made 'wacky' subraces.These sub-races
//              are either planar or monsterous. These include things like:
//              Ogre, Illithid, Pixies... just to name a few.
//              This script is the Leto equivalent of sha_subraces2.
//              It will give players permanent ability scores,feats, etc rather than
//              as a bonus from skin/creature hide. It may also contain added benefits like
//              wings.

#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Drider :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Drider

//Properties from the Skin:
    //Saving Throw Bonus: Specific: Will +2

//Abilities from the unique item:
    //Cast Spell: Darkness (5) 1 Use Per Day
    //Cast Spell: Light () 1 Use Per Day

//Poison : Drider Bite

//Must be Elf. Light Sensitive.
//ECL: +4

   CreateSubrace(RACIAL_TYPE_ELF, "drider", "sha_pcl_drider", "sha_subrace_drid", TRUE, 0, FALSE, 0, 4);

//LETO - Change ability scores:
    //Ability Bonus: Strength +4
    //Ability Bonus: Dexterity +4
    //Ability Bonus: Constitution +6
    //Ability Bonus: Intelligence +4
    //Ability Bonus: Wisdom +6
    //Ability Bonus: Charisma +6
    struct SubraceBaseStatsModifier DriderStats = CustomBaseStatsModifiers(4, 4, 6, 4, 6, 6, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("drider", DriderStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("drider", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Skill Bonus: Hide +4
    //Skill Bonus: Move Silently +4
    ModifySubraceSkill("drider", SKILL_HIDE, 4, 1, FALSE);
    ModifySubraceSkill("drider", SKILL_MOVE_SILENTLY, 4, 1, FALSE);

//Favored Class - Male: Wizard, Female: Cleric.
   AddSubraceFavoredClass("drider", CLASS_TYPE_WIZARD, CLASS_TYPE_CLERIC);

//Can only be evil
   CreateSubraceAlignmentRestriction("drider", FALSE, FALSE, TRUE);

//Spell Resistance: Base (at Level 1): 10, Max(at Level 40): 50.
   CreateSubraceSpellResistance("drider", 10, 50);

//Appearance is permanently changed to Driders (male is different from female)
   CreateSubraceAppearance("drider", TIME_BOTH, APPEARANCE_TYPE_DRIDER, APPEARANCE_TYPE_DRIDER_FEMALE);

// Give Faerie Fire - Violet
   AddSubraceItem("drider","sha_subrace_ff_v");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Nymph ::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Nymph

//Properties from the Skin:
//  AC : +5
//  DR 10/+1

// Spell-Like Abilities From Subrace Item
//  cast : displacement 1/day

// ToDo
//  unearthly grace : Cha Bonus to save

//  ECL : +6

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "nymph", "sha_pcl_nymph", "sha_subrace_nymp", FALSE, 0 , FALSE, 0, 6);

//LETO - Change ability scores:
    //  Dex +6
    //  Con +2
    //  Int +6
    //  Wis +6
    //  Cha +8
    struct SubraceBaseStatsModifier NymphStats = CustomBaseStatsModifiers(0, 6, 2, 6, 6, 8, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("nymph", NymphStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("nymph", FEAT_DARKVISION, 1);

//LETO - Skills:
    //  Skill bonus: Animal Empath +6
    ModifySubraceSkill("nymph", SKILL_ANIMAL_EMPATHY, 6, 1, FALSE);

//Favored Class: Sorcerer
    AddSubraceFavoredClass("nymph", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//Appearance: Satyr - Permanent.
     CreateSubraceAppearance("nymph", TIME_BOTH, APPEARANCE_TYPE_NYMPH, APPEARANCE_TYPE_NYMPH);

//Chaotic Good Only
   CreateSubraceAlignmentRestriction("nymph", TRUE, FALSE, TRUE, FALSE, FALSE, TRUE);

// Gender : Female Only
     CreateSubraceGenderRestriction("nymph",FALSE,TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Air-Touched ::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Air-Touched

//Properties from the Skin:
    //AC Bonus vs. Alignment Group: Lawful +2
    //Damage Vulnerability: Magical 25% Damage Vulnerability
    //Immunity: Damage Type: Cold 10% Immunity Bonus
    //Immunity: Damage Type: Electrical 10% Immunity Bonus

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Air-touched", "sha_pcl_airtouch");

// Hair : lightest gray 16, Skin: light blue 20
    ModifySubraceAppearanceColors("Air-touched",16,16,20,20);

//LETO - Change ability scores:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Strength -2
    //Decreased Ability Score: Wisdom -2
    struct SubraceBaseStatsModifier AirTouchedStats = CustomBaseStatsModifiers(-2, 2, 0, 2, -2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Air-touched", AirTouchedStats, 1);

//Favored Class: Shadow Dancer
    AddSubraceFavoredClass("Air-touched", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

    SetupSubraceAlias("Air-touched", "air touched");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Half-Drow ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-Drow


//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Half-drow");

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Half-drow", FEAT_DARKVISION, 1);

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

    //AC Bonus vs. Alignment Group: Good +1
    //Damage Vulnerability: Positive Energy 25% Damage Vulnerability
    //Immunity: Damage Type: Negative Energy 10% Immunity Bonus

//Must be: Half-Elf
    CreateSubrace(RACIAL_TYPE_HALFELF, "Shadow", "sha_pcl_shadow", "");

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Shadow", FEAT_DARKVISION, 1);

//LETO - Change ability scores:
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier ShadowStats = CustomBaseStatsModifiers(0, 0, 0, 2, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Shadow", ShadowStats, 1);

//Favored Class: Shadow Dancer
    AddSubraceFavoredClass("Shadow", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

//::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Elf - Satyr :::::::
//::::::::::::::::::::::::::::::::::::::

//Subrace Name: Satyr

//Properties from the Skin:
//  AC +4

//Must be: Half-Elf
//  ECL : +2
    CreateSubrace(RACIAL_TYPE_HALFELF, "satyr", "sha_pcl_satyr", "", FALSE, 0, FALSE, 0, 2);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //  Dex +2
    //  Con +2
    //  Int +2
    //  Wis +2
    //  Cha +2
    //  Make Fast as Satyr Model is Slower
    struct SubraceBaseStatsModifier SatyrStats = CustomBaseStatsModifiers(0, 2, 2, 2, 2, 2, MOVEMENT_SPEED_FAST);
    CreateBaseStatModifier("satyr", SatyrStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("satyr", FEAT_DARKVISION, 1);

//LETO - Skills:
    //  Hide, move silent, listen, perform, spot +4
    ModifySubraceSkill("satyr", SKILL_HIDE, 4, 1, FALSE);
    ModifySubraceSkill("satyr", SKILL_LISTEN, 4, 1, FALSE);
    ModifySubraceSkill("satyr", SKILL_MOVE_SILENTLY, 4, 1, FALSE);
    ModifySubraceSkill("satyr", SKILL_PERFORM, 4, 1, FALSE);
    ModifySubraceSkill("satyr", SKILL_SPOT, 4, 1, FALSE);

//Favored Class: Bard
    AddSubraceFavoredClass("satyr", CLASS_TYPE_BARD, CLASS_TYPE_BARD);

//Appearance: Satyr - Permanent.
     CreateSubraceAppearance("satyr", TIME_BOTH, 143, 143);

// Gender : Male Only
     CreateSubraceGenderRestriction("satyr",TRUE,FALSE);
}
