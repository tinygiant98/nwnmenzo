//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces4 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.

#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Savage :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-Orc-Savage

//Must be: Half-Orc
    CreateSubrace(RACIAL_TYPE_HALFORC, "Half-Orc-Savage");

    SetupSubraceAlias("Half-Orc-Savage", "Savage Half-Orc");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Bugbear ::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Bugbear.

//Properties from the Skin:
    //Ability Bonus: Constitution +2
    //Ability Bonus: Strength +4
    //AC Bonus +3
    //Bonus Feat: Armor Proficiency (light)
    //Bonus Feat: Shield Proficiency
    //Bonus Feat: Weapon Proficiency (simple)
    //Darkvision
    //Decreased Ability Score: Charisma -2


//Must be: Half-Orc.
//ECL: + 1

//3.0.6 - Changed to Half-Orc
     CreateSubrace(RACIAL_TYPE_HALFORC, "Bugbear", "sha_pc_bugbear", "", FALSE, 0 , FALSE, 0, 1);

//Apearance: Bugbear - Permanent.
    CreateSubraceAppearance("Bugbear", TIME_BOTH, APPEARANCE_TYPE_BUGBEAR_CHIEFTAIN_A, APPEARANCE_TYPE_BUGBEAR_A);

//::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Gnoll :::::::
//::::::::::::::::::::::::::::::::::::::

//Subrace Name: Gnoll

//Properties from the Skin:
    //Ability Bonus: Strength +2
    //Ability Bonus: Constitution +2
    //AC +1
    //Darkvision

//Must be: Half-Orc.
//ECL +1
      CreateSubrace(RACIAL_TYPE_HALFORC, "Gnoll", "sha_pc_gnoll", "",FALSE, 0, FALSE, 0,1);

//Apearance: Goblin - Permanent.
      CreateSubraceAppearance("Gnoll", TIME_BOTH, APPEARANCE_TYPE_GNOLL_WARRIOR, APPEARANCE_TYPE_GNOLL_WIZ);

//Favored Class: Fighter
    AddSubraceFavoredClass("Gnoll", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

// Evil Only
   CreateSubraceAlignmentRestriction("Gnoll", FALSE, FALSE, TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Hill Giant :::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Giant-Hill

//Properties from the Skin:

//  Str +12
//  Dex -2
//  Con +8
//  Int -2
//  Cha -2
//  AC +9
//  Bonus Feats: Profiecient with Simple, Shield, Light Medium armor
//  Darkvision

//Spell-Like Abilities from subrace item :
//Hurl rocks

//Must be:  Half-Orc
// Give Hurl Rock
//ECL: + 4
     CreateSubrace(RACIAL_TYPE_HALFORC, "Giant-Hill", "sha_pc_giant_hil", "sha_subrace_rock", FALSE, 0, FALSE, 0, 4);
    SetupSubraceAlias("Giant-Hill", "Hill Giant");

//Alignment Restriction - Chaotic Evil.
     CreateSubraceAlignmentRestriction("Giant-Hill", FALSE, FALSE, TRUE, FALSE,FALSE,TRUE);

//Appearance: Ogre - Permanent.
     CreateSubraceAppearance("Giant-Hill", TIME_BOTH, APPEARANCE_TYPE_GIANT_HILL, APPEARANCE_TYPE_GIANT_HILL);

//:::::::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Lizardfolk :::::::
//:::::::::::::::::::::::::::::::::::::::::::

//Subrace Name: Lizardfolk

//Properties from the Skin:
    //AC +5
    //Darkvision
    //Ability Bonus: Constitution +2
    //Ability Bonus: Charisma +2
    //Bonus Feat: Creature Weapon Proficiency
    //Bonus Feat: Simple Weapon Proficiency
    //Bonus Feat: Shield Prficiency

//Must be: Half-Orc.
      CreateSubrace(RACIAL_TYPE_HALFORC, "Lizardfolk", "sha_pc_lizard", "");

//Apearance: Goblin - Permanent.
      CreateSubraceAppearance("Lizardfolk", TIME_BOTH, APPEARANCE_TYPE_LIZARDFOLK_A, APPEARANCE_TYPE_LIZARDFOLK_SHAMAN_A);
    SetupSubraceAlias("Lizardfolk", "Lizardman");
    SetupSubraceAlias("Lizardfolk", "Lizard Man");

// Claws d4
    AddClawsToSubrace("Lizardfolk","sha_claw_d4","sha_claw_d4",1);

// Add Lizard tail.
     ModifySubraceAppearanceAttachment("Lizardfolk", CREATURE_WING_TYPE_NONE, CREATURE_WING_TYPE_NONE, CREATURE_TAIL_TYPE_LIZARD, CREATURE_TAIL_TYPE_LIZARD, 1);

//Favored Class: Druid
    AddSubraceFavoredClass("Lizardfolk", CLASS_TYPE_DRUID, CLASS_TYPE_DRUID);

//Neutral Only
   CreateSubraceAlignmentRestriction("Lizardfolk", FALSE, TRUE, FALSE, TRUE, TRUE, TRUE);

//:::::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Minotaur :::::::
//:::::::::::::::::::::::::::::::::::::::::

//Subrace Name: Minotaur

//Properties from the Skin:
    //Ability Bonus: str +6
    //Ability Bonus: con +4
    //Decreased Ability: int -2
    //AC +5
    //Darkvision
    //Bonus Feat: weapon prof simple
    //Bonus Feat: weapon prof martial
    //Bonus Feat: weapon prof creature
    //Feat: power attack
    //Skill bonus : +4 search
    //Skill bonus : spot
    //Skill bonus : listen

//Natuaral Weaponry: Gore d8

//Must be: Half-Orc.
//ECL +2
   CreateSubrace(RACIAL_TYPE_HALFORC, "Minotaur", "sha_pc_minotaur", "",FALSE, 0, FALSE, 0,2);

//Apearance: Goblin - Permanent.
   CreateSubraceAppearance("Minotaur", TIME_BOTH, APPEARANCE_TYPE_MINOTAUR, APPEARANCE_TYPE_MINOTAUR_SHAMAN);

// Add Natural Weaponry: Gore d8
    AddClawsToSubrace("Minotaur","sha_gore_d8","",1);

//Favored Class: Fighter
   AddSubraceFavoredClass("Minotaur", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

// Evil Only
   CreateSubraceAlignmentRestriction("Minotaur", FALSE, FALSE, TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Ogre :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Ogre

//Properties from the Skin:
    //Ability Bonus: Constitution +4
    //Ability Bonus: Strength +6
    //AC Bonus +5
    //Bonus Feat: Armor Proficiency (light)
    //Bonus Feat: Armor Proficiency (medium)
    //Bonus Feat: Shield Proficiency
    //Bonus Feat: Weapon Proficiency (martial)
    //Bonus Feat: Weapon Proficiency (simple)
    //Darkvision
    //Decreased Ability Score: Charisma -4
    //Decreased Ability Score: Dexterity -2
    //Decreased Ability Score: Intelligence -4
    //Decreased Skill Modifier: Hide -8
    //Decreased Skill Modifier: Move Silently -5


//Must be:  Half-Orc
//ECL: + 2
     CreateSubrace(RACIAL_TYPE_HALFORC, "Ogre", "sha_pc_ogre", "", FALSE, 0, FALSE, 0, 2);

//Alignment Restriction - Cannot be Lawful.
     CreateSubraceAlignmentRestriction("Ogre", TRUE, TRUE, TRUE, FALSE);

//Appearance: Ogre - Permanent.
     CreateSubraceAppearance("Ogre", TIME_BOTH, APPEARANCE_TYPE_OGRE_CHIEFTAIN, APPEARANCE_TYPE_OGREB);

//Can't use any Tiny weapons (Too big to hold them!!)
    SubraceRestrictUseOfItems("Ogre", ITEM_TYPE_WEAPON_SIZE_TINY, TIME_BOTH);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Ogre Mage ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Ogre-Mage

//Properties from the Skin:
//  Str +8
//  Con +6
//  Int +2
//  Wis +4
//  Cha +8
//  Ac +5 Natural
//  Darkvision
//  Regeneration 5
//  Spell Resistance : 18

//cast :
//  darkness, invisibility at will,
//  charm person, cone of cold, polymorph, sleep 1/day

//Must be:  Half-Orc
//ECL: + 7
     CreateSubrace(RACIAL_TYPE_HALFORC, "Ogre-Mage", "sha_pc_ogre_mage", "sha_subrace_ogrm", FALSE, 0, FALSE, 0, 7);
    SetupSubraceAlias("Ogre-Mage", "Ogre Mage");
    SetupSubraceAlias("Ogre-Mage", "Ogre Magi");
    SetupSubraceAlias("Ogre-Mage", "Ogre-Magi");

// Can Fly
   AddSubraceItem("Ogre-Mage", "sha_subrace_fly");

//Alignment Restriction - Cannot be Lawful.
     CreateSubraceAlignmentRestriction("Ogre-Mage", TRUE, TRUE, TRUE, FALSE);

//Appearance: Ogre - Permanent.
     CreateSubraceAppearance("Ogre-Mage", TIME_BOTH, APPEARANCE_TYPE_OGRE_MAGE, APPEARANCE_TYPE_OGRE_MAGEB);

//Can't use any Tiny weapons (Too big to hold them!!)
//   SubraceRestrictUseOfItems("Ogre-Mage", ITEM_TYPE_WEAPON_SIZE_TINY, TIME_BOTH);

//Favored Class: Sorcerer
   AddSubraceFavoredClass("Ogre-Mage", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//Lawful Evil Only
   CreateSubraceAlignmentRestriction("Ogre-Mage", FALSE, FALSE, TRUE, TRUE, FALSE, FALSE);

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Orc :::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Orc

//Properties from the Skin:
    //Ability Bonus: Str +2
    //Decreased Ability : Wis -2
    //Darkvision

//Must be:  Half-Orc
//Light Sensitive
     CreateSubrace(RACIAL_TYPE_HALFORC, "Orc", "sha_pc_orc", "", TRUE);

//Alignment Restriction -  Evil.
     CreateSubraceAlignmentRestriction("Orc", FALSE, FALSE, TRUE);

//Appearance: Orc - Permanent.
     CreateSubraceAppearance("Orc", TIME_BOTH, APPEARANCE_TYPE_ORC_A, APPEARANCE_TYPE_ORC_SHAMAN_A);

//:::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Stinger ::::
//:::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-Orc - Stinger

/*
Str +6
Dex +4
Con +4
Wis +2
AC +4
Skill Bonus : Listen +4
Skill Bonus : Search +4
Skill Bonus : Spot +4
Skill Bonus : move silent +2
Feat : imporvied initiative
Feat : exotic weapon

Alignment : Evil
Base Races : Half-Orc
Favored Class : Ranger
ECL : +4

*/

    CreateSubrace(RACIAL_TYPE_HALFORC, "stinger", "sha_pc_Stinger", "", FALSE, 0, FALSE, 0, 4);

// Favored Class : Ranger
    AddSubraceFavoredClass("Stinger", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

// Add Poison Stinger
    AddClawsToSubrace("Stinger","sha_tail_Stinger","",1);

//  Evil Only
    CreateSubraceAlignmentRestriction("Stinger", FALSE, FALSE, TRUE);

//Appearance:
    CreateSubraceAppearance("Stinger", TIME_BOTH, APPEARANCE_TYPE_STINGER, APPEARANCE_TYPE_STINGER);

// Gender : Male Only
    CreateSubraceGenderRestriction("Stinger",TRUE,FALSE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Troll ::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Troll

//Properties from the Skin:
    //Ability Bonus: Constitution +6
    //Ability Bonus: Strength +6
    //AC Bonus +4
    //Darkvision
    //Decreased Ability Score: Charisma -4
    //Decreased Ability Score: Intelligence -4
    //Decreased Ability Score: Wisdom -2
    //Regeneration +3
    //Decreased Skill Modifier: Hide -8
    //Decreased Skill Modifier: Move Silently -5

//Must be: Half-Orc
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_HALFORC, "Troll", "sha_pc_troll","", FALSE, 0, FALSE, 0, 2);

//Appearance: Troll - Permanent.
     CreateSubraceAppearance("Troll", TIME_BOTH, APPEARANCE_TYPE_TROLL_CHIEFTAIN, APPEARANCE_TYPE_TROLL_SHAMAN);

//Can't use any Tiny weapons (Too big to hold them!!)
    SubraceRestrictUseOfItems("Troll", ITEM_TYPE_WEAPON_SIZE_TINY, TIME_BOTH);

//Favored Class: Fighter.
    AddSubraceFavoredClass("Troll", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);
}
