//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces3 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: This script holds the pre-made 'default' core races
//              If you do not want to use these, simply comment the lines:
//                  DelayCommand(3.0, ExecuteScript("sha_subraces3", GetModule()));
//              in the script: sha_on_modload.

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
    //AC Bonus +3

//Must be: Half-Orc.
//ECL: + 1
     CreateSubrace(RACIAL_TYPE_HALFORC, "Bugbear", "sha_pcl_bugbear", "", FALSE, 0 , FALSE, 0, 1);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +2
    //Ability Bonus: Strength +4
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier BugbearStats = CustomBaseStatsModifiers(4, 0, 2, 0, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Bugbear", BugbearStats, 1);

//LETO - Feats:
    //Darkvision
    //Bonus Feat: Armor Proficiency (light)
    //Bonus Feat: Shield Proficiency
    //Bonus Feat: Weapon Proficiency (simple)
    ModifySubraceFeat("Bugbear", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Bugbear", FEAT_ARMOR_PROFICIENCY_LIGHT, 1);
    ModifySubraceFeat("Bugbear", FEAT_SHIELD_PROFICIENCY, 1);
    ModifySubraceFeat("Bugbear", FEAT_WEAPON_PROFICIENCY_SIMPLE, 1);

//Apearance: Bugbear - Permanent.
    CreateSubraceAppearance("Bugbear", TIME_BOTH, APPEARANCE_TYPE_BUGBEAR_CHIEFTAIN_A, APPEARANCE_TYPE_BUGBEAR_A);

//::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Gnoll :::::::
//::::::::::::::::::::::::::::::::::::::

//Subrace Name: Gnoll

//Properties from the Skin:
    //AC +1

//Must be: Half-Orc.
//ECL +1
      CreateSubrace(RACIAL_TYPE_HALFORC, "Gnoll", "sha_pcl_gnoll", "",FALSE, 0, FALSE, 0,1);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    struct SubraceBaseStatsModifier GnollStats = CustomBaseStatsModifiers(2, 0, 2, 0, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Gnoll", GnollStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Gnoll", FEAT_DARKVISION, 1);

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
//  AC +9

//Spell-Like Abilities from subrace item :
//Hurl rocks

//Must be:  Half-Orc
//ECL: + 4
    CreateSubrace(RACIAL_TYPE_HALFORC, "giant-hill", "sha_pcl_giant_hl", "sha_subrace_rock", FALSE, 0, FALSE, 0, 4);
    SetupSubraceAlias("giant-hill", "Hill Giant");

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
//  Str +12
//  Dex -2
//  Con +8
//  Int -2
//  Cha -2
    struct SubraceBaseStatsModifier HillGiantStats = CustomBaseStatsModifiers(12, -2, 8, -2, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("giant-hill", HillGiantStats, 1);

//LETO - Feats:
    //Bonus Feats: Profiecient with Simple, Shield, Light Medium armor
    //Darkvision
    ModifySubraceFeat("giant-hill", FEAT_DARKVISION, 1);
    ModifySubraceFeat("giant-hill", FEAT_SHIELD_PROFICIENCY, 1);
    ModifySubraceFeat("giant-hill", FEAT_WEAPON_PROFICIENCY_SIMPLE, 1);
    ModifySubraceFeat("giant-hill", FEAT_ARMOR_PROFICIENCY_LIGHT, 1);
    ModifySubraceFeat("giant-hill", FEAT_ARMOR_PROFICIENCY_MEDIUM, 1);

//Alignment Restriction - Chaotic Evil.
    CreateSubraceAlignmentRestriction("giant-hill", FALSE, FALSE, TRUE, FALSE,FALSE,TRUE);

//Appearance: Ogre - Permanent.
    CreateSubraceAppearance("giant-hill", TIME_BOTH, APPEARANCE_TYPE_GIANT_HILL, APPEARANCE_TYPE_GIANT_HILL);

//:::::::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Lizardfolk :::::::
//:::::::::::::::::::::::::::::::::::::::::::

//Subrace Name: Lizardfolk

//Properties from the Skin:
    //AC +5

//Must be: Half-Orc.
      CreateSubrace(RACIAL_TYPE_HALFORC, "Lizardfolk", "sha_pcl_lizard", "");

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    struct SubraceBaseStatsModifier LizardStats = CustomBaseStatsModifiers(0, 0, 2, 0, 0, 2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Lizardfolk", LizardStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Lizardfolk", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Lizardfolk", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);
    ModifySubraceFeat("Lizardfolk", FEAT_WEAPON_PROFICIENCY_SIMPLE, 1);
    ModifySubraceFeat("Lizardfolk", FEAT_SHIELD_PROFICIENCY, 1);

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
    //AC +5

//Natuaral Weaponry: Gore d8

//Must be: Half-Orc.
//ECL +2
   CreateSubrace(RACIAL_TYPE_HALFORC, "Minotaur", "sha_pcl_minotaur", "",FALSE, 0, FALSE, 0,2);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Ability Bonus: str +6
    //Ability Bonus: con +4
    //Decreased Ability: int -2
    struct SubraceBaseStatsModifier MinotaurStats = CustomBaseStatsModifiers(6, 0, 4, -2, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Minotaur", MinotaurStats, 1);

//LETO - Feats:

    //Darkvision
    //Bonus Feat: weapon prof simple
    //Bonus Feat: weapon prof martial
    //Bonus Feat: weapon prof creature
    //Bonus Feat: power attack
    ModifySubraceFeat("Minotaur", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Minotaur", FEAT_WEAPON_PROFICIENCY_SIMPLE, 1);
    ModifySubraceFeat("Minotaur", FEAT_WEAPON_PROFICIENCY_MARTIAL, 1);
    ModifySubraceFeat("Minotaur", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);

//LETO - Skills:
    //Skill bonus : +4 search
    //Skill bonus : +4 spot
    //Skill bonus : +4 listen
    ModifySubraceSkill("Minotaur", SKILL_LISTEN, 4, 1, FALSE);
    ModifySubraceSkill("Minotaur", SKILL_SEARCH, 4, 1, FALSE);
    ModifySubraceSkill("Minotaur", SKILL_SPOT, 4, 1, FALSE);

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
    //AC Bonus +5

//Must be:  Half-Orc
//ECL: + 2
     CreateSubrace(RACIAL_TYPE_HALFORC, "Ogre", "sha_pcl_Ogre", "", FALSE, 0, FALSE, 0, 2);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +4
    //Ability Bonus: Strength +6
    //Decreased Ability Score: Charisma -4
    //Decreased Ability Score: Dexterity -2
    //Decreased Ability Score: Intelligence -4
    struct SubraceBaseStatsModifier OgreStats = CustomBaseStatsModifiers(6, -2, 4, -4, 0, -4, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Ogre", OgreStats, 1);

//LETO - Feats:
    //Darkvision
    //Bonus Feat: Armor Proficiency (light)
    //Bonus Feat: Armor Proficiency (medium)
    //Bonus Feat: Shield Proficiency
    //Bonus Feat: Weapon Proficiency (martial)
    //Bonus Feat: Weapon Proficiency (simple)
    ModifySubraceFeat("Ogre", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Ogre", FEAT_ARMOR_PROFICIENCY_LIGHT, 1);
    ModifySubraceFeat("Ogre", FEAT_ARMOR_PROFICIENCY_MEDIUM, 1);
    ModifySubraceFeat("Ogre", FEAT_SHIELD_PROFICIENCY, 1);
    ModifySubraceFeat("Ogre", FEAT_WEAPON_PROFICIENCY_MARTIAL, 1);
    ModifySubraceFeat("Ogre", FEAT_WEAPON_PROFICIENCY_SIMPLE, 1);

//LETO - Skills:
    //Decreased Skill Modifier: Move Silently -5
    //Decreased Skill Modifier: Hide -8
    ModifySubraceSkill("Ogre", SKILL_HIDE, -8, 1, FALSE);
    ModifySubraceSkill("Ogre", SKILL_MOVE_SILENTLY, -5, 1, FALSE);

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
//  Ac +5 Natural
//  Regeneration 5
//  Spell Resistance : 18

//cast :
//  darkness, invisibility at will,
//  charm person, cone of cold, polymorph, sleep 1/day

//Must be:  Half-Orc
//ECL: + 7
    CreateSubrace(RACIAL_TYPE_HALFORC, "Ogre-Mage", "sha_pcl_ogre_mag", "sha_subrace_ogrm", FALSE, 0, FALSE, 0, 7);
    SetupSubraceAlias("Ogre-Mage", "Ogre Mage");
    SetupSubraceAlias("Ogre-Mage", "Ogre Magi");
    SetupSubraceAlias("Ogre-Mage", "Ogre-Magi");

// Can Fly
   AddSubraceItem("Ogre-Mage", "sha_subrace_fly");

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //  Str +8
    //  Con +6
    //  Int +2
    //  Wis +4
    //  Cha +8
    struct SubraceBaseStatsModifier OgreMageStats = CustomBaseStatsModifiers(8, 0, 6, 2, 4, 8, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Ogre-Mage", OgreMageStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Ogre-Mage", FEAT_DARKVISION, 1);

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

//Must be:  Half-Orc
//Light Sensitive
    CreateSubrace(RACIAL_TYPE_HALFORC, "Orc", "", "", TRUE);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    struct SubraceBaseStatsModifier OrcStats = CustomBaseStatsModifiers(2, 0, 0, 0, -2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Orc", OrcStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Orc", FEAT_DARKVISION, 1);

//Alignment Restriction -  Evil.
    CreateSubraceAlignmentRestriction("Orc", FALSE, FALSE, TRUE);

//Appearance: Orc - Permanent.
    CreateSubraceAppearance("Orc", TIME_BOTH, APPEARANCE_TYPE_ORC_A, APPEARANCE_TYPE_ORC_SHAMAN_A);

//:::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Stinger ::::
//:::::::::::::::::::::::::::::::::::::

//Subrace Name: Half-Orc - Stinger

//Properties from Hide:
//AC +4

//Must Be Half-Orc
//ECL : +4
    CreateSubrace(RACIAL_TYPE_HALFORC, "stinger", "sha_pcl_stinger", "", FALSE, 0, FALSE, 0, 4);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Str +6
    //Dex +4
    //Con +4
    //Wis +2
    struct SubraceBaseStatsModifier StingerStats = CustomBaseStatsModifiers(6, 4, 4, 0, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("stinger", StingerStats, 1);

//LETO - Feats:
    //Bonus Feat : imporvied initiative
    //Bonus Feat : creature weapon
    //Bonus Feat : exotic weapon
    ModifySubraceFeat("stinger", FEAT_IMPROVED_INITIATIVE, 1);
    ModifySubraceFeat("stinger", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);
    ModifySubraceFeat("stinger", FEAT_WEAPON_PROFICIENCY_EXOTIC, 1);

//LETO - Skills:
    //Skill Bonus : Listen +4
    //Skill Bonus : Search +4
    //Skill Bonus : Spot +4
    //Skill Bonus : move silent +2
    ModifySubraceSkill("stinger", SKILL_LISTEN, 4, 1, FALSE);
    ModifySubraceSkill("stinger", SKILL_SEARCH, 4, 1, FALSE);
    ModifySubraceSkill("stinger", SKILL_SPOT, 4, 1, FALSE);
    ModifySubraceSkill("stinger", SKILL_MOVE_SILENTLY, 2, 1, FALSE);

// Favored Class : Ranger
    AddSubraceFavoredClass("stinger", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

// Add Poison Stinger
    AddClawsToSubrace("stinger","sha_tail_stinger","",1);

//  Evil Only
    CreateSubraceAlignmentRestriction("stinger", FALSE, FALSE, TRUE);

// Appearance:
    CreateSubraceAppearance("stinger", TIME_BOTH, APPEARANCE_TYPE_STINGER, APPEARANCE_TYPE_STINGER);

// Gender : Male Only
    CreateSubraceGenderRestriction("stinger",TRUE,FALSE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Half-Orc - Troll ::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Troll

//Properties from the Skin:
    //AC Bonus +4
    //Regeneration +3
    //Decreased Skill Modifier: Hide -8
    //Decreased Skill Modifier: Move Silently -5

//Must be: Half-Orc
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_HALFORC, "Troll", "sha_pcl_Troll","", FALSE, 0, FALSE, 0, 2);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +6
    //Ability Bonus: Strength +6
    //Decreased Ability Score: Charisma -4
    //Decreased Ability Score: Intelligence -4
    //Decreased Ability Score: Wisdom -2
    struct SubraceBaseStatsModifier TrollStats = CustomBaseStatsModifiers(6, 0, 6, -4, -2, -4, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Troll", TrollStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Troll", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Decreased Skill Modifier: Move Silently -5
    //Decreased Skill Modifier: Hide -8
    ModifySubraceSkill("Troll", SKILL_HIDE, -8, 1, FALSE);
    ModifySubraceSkill("Troll", SKILL_MOVE_SILENTLY, -5, 1, FALSE);

//Appearance: Troll - Permanent.
     CreateSubraceAppearance("Troll", TIME_BOTH, APPEARANCE_TYPE_TROLL_CHIEFTAIN, APPEARANCE_TYPE_TROLL_SHAMAN);

//Can't use any Tiny weapons (Too big to hold them!!)
    SubraceRestrictUseOfItems("Troll", ITEM_TYPE_WEAPON_SIZE_TINY, TIME_BOTH);

//Favored Class: Fighter.
    AddSubraceFavoredClass("Troll", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

}
