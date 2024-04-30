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
//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Default :::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Human

//Must be: Human
     CreateSubrace(RACIAL_TYPE_HUMAN, "Human");

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Aasimar :::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Aasimar

//Properties from the Skin:
    //Damage Resistance: Acid Resist 5 / -
    //Damage Resistance: Cold Resist 5 / -
    //Damage Resistance: Electrical Resist 5 / -
    //Saving Throw Bonus: Universal +2

//Abilities from the unique item:
    //Cast Spell: Light (5) 1 Use/Per Day

//Must be: Human
//ECL: + 1
     CreateSubrace(RACIAL_TYPE_HUMAN, "Aasimar", "sha_pcl_aasimar", "sha_subrace_aasi", FALSE, 0, FALSE, 0, 1);

// Can Fly
   AddSubraceItem("Aasimar", "sha_subrace_fly");

// Eyes : White
   SHA_ModifySubraceEyeColors("Aasimar", SSE_EYE_COLOR_WHITE,SSE_EYE_COLOR_WHITE);

//LETO - Change ability scores:
    //Ability Bonus: Charisma +2
    //Ability Bonus: Wisdom +2
    struct SubraceBaseStatsModifier AasimarStats = CustomBaseStatsModifiers(0, 0, 0, 0, 2, 2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Aasimar", AasimarStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Aasimar", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Skill Bonus: Listen +2
    //Skill Bonus: Spot +2
    ModifySubraceSkill("Aasimar", SKILL_SPOT, 2, 1, FALSE);
    ModifySubraceSkill("Aasimar", SKILL_LISTEN, 2, 1, FALSE);

//Alignment Restriction: Good
      CreateSubraceAlignmentRestriction("Aasimar", TRUE, FALSE, FALSE);

//Favored Class: Paladin
     AddSubraceFavoredClass("Aasimar", CLASS_TYPE_PALADIN, CLASS_TYPE_PALADIN);

//LETO - Add Angel Wings.
     ModifySubraceAppearanceAttachment("Aasimar", CREATURE_WING_TYPE_ANGEL, CREATURE_WING_TYPE_ANGEL, 0, 0, 1);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Air Genasi ::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Air-Genasi

//Properties from the Skin:


//Must be: Human
    CreateSubrace(RACIAL_TYPE_HUMAN, "Air-genasi", "");

// Can Fly
   AddSubraceItem("Air-genasi", "sha_subrace_fly");

//LETO - Change ability scores:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Charisma -2
    //Decreased Ability Score: Wisdom -2
    struct SubraceBaseStatsModifier AirGenasiStats = CustomBaseStatsModifiers(0, 2, 0, 2, -2, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Air-genasi", AirGenasiStats, 1);

// Hair : lightest gray 16, Skin: light blue 20
    ModifySubraceAppearanceColors("Air-genasi",16,16,20,20);

// Eyes : Cyan
   SHA_ModifySubraceEyeColors("Air-genasi", SSE_EYE_COLOR_CYAN,SSE_EYE_COLOR_CYAN);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Air-genasi", FEAT_DARKVISION, 1);


//Favored Class: Fighter
     AddSubraceFavoredClass("Air-genasi", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

     SetupSubraceAlias("Air-genasi", "air genasi");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Earth Genasi ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Earth-Genasi

//Properties from the Skin:


//Must be: Human
    CreateSubrace(RACIAL_TYPE_HUMAN, "Earth-genasi", "");

// Eyes : Orange
   SHA_ModifySubraceEyeColors("Earth-genasi", SSE_EYE_COLOR_ORANGE,SSE_EYE_COLOR_ORANGE);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +2
    //Ability Bonus: Strength +2
    //Decreased Ability Score: Charisma -2
    //Decreased Ability Score: Wisdom -2
    struct SubraceBaseStatsModifier EarthGenasiStats = CustomBaseStatsModifiers(2, 0, 2, 0, -2, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Earth-genasi", EarthGenasiStats, 1);

// Hair, Skin: stone = 60
    ModifySubraceAppearanceColors("Earth-genasi",60,60,60,60);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Earth-genasi", FEAT_DARKVISION, 1);

//Favored Class: Fighter
     AddSubraceFavoredClass("Earth-genasi", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

     SetupSubraceAlias("Earth-genasi", "earth genasi");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Fire Genasi :::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Fire-Genasi

//Properties from the Skin:
    //Ability Bonus: Intelligence +2
    //Darkvision
    //Decreased Ability Score: Charisma -2

//Must be: Human
    CreateSubrace(RACIAL_TYPE_HUMAN, "Fire-genasi", "");

// Eyes : Red
   SHA_ModifySubraceEyeColors("Fire-genasi", SSE_EYE_COLOR_RED,SSE_EYE_COLOR_RED);

// Hair : flame yellow 93, Skin: fire red 44
    ModifySubraceAppearanceColors("Fire-genasi",93,93,44,44);

//LETO - Change ability scores:
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier FireGenasiStats = CustomBaseStatsModifiers(0, 0, 0, 2, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Fire-genasi", FireGenasiStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Fire-genasi", FEAT_DARKVISION, 1);

//Favored Class: Fighter
     AddSubraceFavoredClass("Fire-genasi", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

     SetupSubraceAlias("Fire-genasi", "fire genasi");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Water Genasi ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Water-Genasi

//Properties from the Skin:
    //Immunity: Specific Spell Drown

//Must be: Human
    CreateSubrace(RACIAL_TYPE_HUMAN, "Water-genasi", "sha_pcl_watergen");
     SetupSubraceAlias("Water-genasi", "water genasi");

// Hair : light green 152, Skin: dark green 153
    ModifySubraceAppearanceColors("Water-genasi",152,152,153,153);

// Eyes : Green
   SHA_ModifySubraceEyeColors("Water-genasi", SSE_EYE_COLOR_GREEN,SSE_EYE_COLOR_GREEN);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +2
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier WaterGenasiStats = CustomBaseStatsModifiers(0, 0, 2, 0, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Water-genasi", WaterGenasiStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Water-genasi", FEAT_DARKVISION, 1);

//Favored Class: Fighter
     AddSubraceFavoredClass("Water-genasi", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Tiefling ::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Tiefling

//Properties from the Skin:
    //Damage Resistance: Cold Resist 5 / -
    //Damage Resistance: Electrical Resist 5 / -
    //Damage Resistance: Fire Resist 5 / -


//Abilities from the unique item:
    //Cast Spell: Darkness (3) 1 Use/Per Day


//Must be: Human
//ECL: + 1
     CreateSubrace(RACIAL_TYPE_HUMAN, "Tiefling", "sha_pcl_tiefling", "sha_subrace_tief", FALSE, 0, FALSE, 0, 1);

// Can Fly
   AddSubraceItem("Tiefling", "sha_subrace_fly");

//LETO - Change ability scores:
    //Ability Bonus: Charisma +2
    //Ability Bonus: Wisdom +2
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier TieflingStats = CustomBaseStatsModifiers(0, 2, 0, 2, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Tiefling", TieflingStats, 1);

// Eyes : Red
   SHA_ModifySubraceEyeColors("Tiefling", SSE_EYE_COLOR_RED,SSE_EYE_COLOR_RED);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Tiefling", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Skill Bonus: Bluff +2
    //Skill Bonus: Hide +2

    //ModifySubraceSkill("Tiefling", SKILL_BLUFF, 2, 1, FALSE);
    ModifySubraceSkill("Tiefling", SKILL_HIDE, 2, 1, FALSE);

//Alignment Restriction: Evil
      CreateSubraceAlignmentRestriction("Tiefling", FALSE, FALSE, TRUE);

//Favored Class: Rogue
     AddSubraceFavoredClass("Tiefling", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);

//LETO - Add Demon Wings and Demon tail.
     ModifySubraceAppearanceAttachment("Tiefling", CREATURE_WING_TYPE_DEMON, CREATURE_WING_TYPE_DEMON, CREATURE_TAIL_TYPE_DEVIL, CREATURE_TAIL_TYPE_DEVIL, 1);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Eyeball :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Eyeball

//Properties from the Skin:
//AC +4
//Immunity : Knockdown
//Immunity : Sneak Attacks

//Flight

//Spell-Like abilies from subrace item :
//Eyeball Rays

//Must be: Human.
//ECL +1
    CreateSubrace(RACIAL_TYPE_HUMAN, "Eyeball", "sha_pcl_eyeball","sha_subrace_eyeb",FALSE,0,FALSE,0,1);

// Can Fly
   AddSubraceItem("Eyeball", "sha_subrace_fly");

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Str -4
    //Dex +6
    struct SubraceBaseStatsModifier EyeballStats = CustomBaseStatsModifiers(-4, 6, 0, 0, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Eyeball", EyeballStats, 1);

//LETO - Feats:
    //Bonus Feat : Dodge
    //Bonus Feat : Mobility
    //Bonus Feat : Creature Weapon Proficiency
    ModifySubraceFeat("Eyeball", FEAT_DODGE, 1);
    ModifySubraceFeat("Eyeball", FEAT_MOBILITY, 1);
    ModifySubraceFeat("Eyeball", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);

//LETO - Skills:
    //Hide +6
    //Search +6
    //Spot +6
    ModifySubraceSkill("Eyeball", SKILL_HIDE, 6, 1, FALSE);
    ModifySubraceSkill("Eyeball", SKILL_SEARCH, 6, 1, FALSE);
    ModifySubraceSkill("Eyeball", SKILL_SPOT, 6, 1, FALSE);

// Appearance:
    CreateSubraceAppearance("Eyeball", TIME_BOTH, APPEARANCE_TYPE_BEHOLDER_EYEBALL, APPEARANCE_TYPE_BEHOLDER_EYEBALL);

// Lawful Evil Only
    CreateSubraceAlignmentRestriction("Eyeball", FALSE, FALSE, TRUE, TRUE, FALSE, FALSE);

// Add Natural Weaponry: Bite d4
    AddClawsToSubrace("Eyeball","sha_bite_d4","",1);

// Add Eyes
    AddSubraceItem("Eyeball","sha_subrace_eye1");
    AddSubraceItem("Eyeball","sha_subrace_eye2");
    AddSubraceItem("Eyeball","sha_subrace_eye3");
    AddSubraceItem("Eyeball","sha_subrace_eye4");

    SubraceRestrictUseOfItems("Eyeball", ITEM_TYPE_JEWLERY|ITEM_TYPE_MISC_CLOTHING|ITEM_TYPE_FULL_ARMOR_SET |ITEM_TYPE_WEAPON);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Githyanki :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Githyanki

// Subrace Abilities:
//  Daze 3/day

//Must be Human
//ECL : +2
    CreateSubrace(RACIAL_TYPE_HUMAN, "Githyanki", "", "sha_subrace_gy", FALSE, 0, FALSE, 0, 2);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
//  Dex +2
//  Con +2
//  Wis -2
    struct SubraceBaseStatsModifier GithyStats = CustomBaseStatsModifiers(0, 2, 2, 0, -2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Githyanki", GithyStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Githyanki", FEAT_DARKVISION, 1);

// Hair: red 5  Skin: yellow 94
    ModifySubraceAppearanceColors("Githyanki",5,5,94,94);

// Heads : Male 33, Female 27
   ModifySubraceHead("Githyanki", 33,27);

//Spell Resistance: 5 + 1 Per Level.
    CreateSubraceSpellResistance("Githyanki", 5, 45);

//Favored Class: Fighter
    AddSubraceFavoredClass("Githyanki", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

//Evil Only
   CreateSubraceAlignmentRestriction("Githyanki", FALSE, FALSE, TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Githzerai :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Githzerai

//Subrace Abilities :
//Daze 3/day

//Must be Human
//ECL : +2
    CreateSubrace(RACIAL_TYPE_HUMAN, "Githzerai", "", "sha_subrace_gz", FALSE, 0, FALSE, 0, 2);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
//  Dex +6
//  Int -2
//  Wis +2
    struct SubraceBaseStatsModifier GithzStats = CustomBaseStatsModifiers(0, 6, 0, -2, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Githzerai", GithzStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Githzerai", FEAT_DARKVISION, 1);

// Hair and Skin : Mottled Green 175
    ModifySubraceAppearanceColors("Githzerai",175,175,175,175);

// Heads : Male 34, Female 26
   ModifySubraceHead("Githzerai", 34, 26);

//Inertial Barrier at will
    AddSubraceItem("Githzerai","sha_subrace_ps_i");

//Spell Resistance: 5 + Level.
    CreateSubraceSpellResistance("Githzerai", 5, 45);

//Neutral Only
   CreateSubraceAlignmentRestriction("Githzerai", FALSE, TRUE, FALSE, TRUE, TRUE, TRUE);

//Favored Class: Monk
    AddSubraceFavoredClass("Githzerai", CLASS_TYPE_MONK, CLASS_TYPE_MONK);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: HUMAN - Hobgoblin :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Hobgoblin

//Must be: Human.
//ECL +1
      CreateSubrace(RACIAL_TYPE_HUMAN, "Hobgoblin", "sha_pc_hobgoblin", "",FALSE, 0, FALSE, 0,1);

//Apearance: Goblin - Permanent.
      CreateSubraceAppearance("Hobgoblin", TIME_BOTH, APPEARANCE_TYPE_HOBGOBLIN_WARRIOR, APPEARANCE_TYPE_HOBGOBLIN_WIZARD);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Constitution +2
    struct SubraceBaseStatsModifier HobgoblinStats = CustomBaseStatsModifiers(0, 2, 2, 0, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Hobgoblin", HobgoblinStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Hobgoblin", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Skill Bonus: Move Silent +4
    ModifySubraceSkill("Hobgoblin", SKILL_MOVE_SILENTLY, 4, 1, FALSE);

//Favored Class: Fighter
    AddSubraceFavoredClass("Hobgoblin", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);

//Evil Only
   CreateSubraceAlignmentRestriction("Hobgoblin", FALSE, FALSE, TRUE);

//:::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Illithid ::
//:::::::::::::::::::::::::::::::::

//Subrace Name: Illithid.

//Properties from the Skin:
    //AC Bonus +3

    //Immunity: Miscellaneous: Mind-Affecting Spells

//Abilities from the unique item:
    //Cast Spell: Charm Monster (10) 1 Use/Day
    //Cast Spell: Charm Person (10) 1 Use/Day

//Must be Human, and is light sensitive.
//ECL: + 2
   CreateSubrace(RACIAL_TYPE_HUMAN, "Illithid", "sha_pcl_Illithid", "sha_subrace_illi", TRUE, 0, FALSE, 0, 3);

// Add Extract Brain
   AddSubraceItem("illithid", "sha_subrace_illb");

// Add Dimension Door
   AddSubraceItem("illithid", "sha_subrace_dimd");

// Add Psionic Mind Blast
   AddSubraceItem("illithid", "sha_subrace_ps_m");

//LETO - Change ability scores:
    //Ability Bonus: Charisma +2
    //Ability Bonus: Constitution -4
    //Ability Bonus: Dexterity +4
    //Ability Bonus: Intelligence +8
    //Ability Bonus: Strength +2
    //Ability Bonus: Wisdom +4
    struct SubraceBaseStatsModifier IllithidStats = CustomBaseStatsModifiers(2, 4, -4, 8, 4, 2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Illithid", IllithidStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Illithid", FEAT_DARKVISION, 1);

//Lawful Evil Only
   CreateSubraceAlignmentRestriction("Illithid", FALSE, FALSE, TRUE, TRUE, FALSE, FALSE);

//Favored Class: Male: Wizard, Female: Wizard.
   AddSubraceFavoredClass("Illithid", CLASS_TYPE_WIZARD, CLASS_TYPE_WIZARD);

//Can only be Monk, Cleric or Wizard
   CreateSubraceClassRestriction("Illithid", FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE,  FALSE, FALSE, TRUE);

//Spell Resistance: Base: 25, Max: 65.  (25 + 1 per level)
   CreateSubraceSpellResistance("Illithid", 25, 65);

//Appearance is permanently changed to Mind flayers (male is different from female)
   CreateSubraceAppearance("Illithid", TIME_BOTH, APPEARANCE_TYPE_MINDFLAYER, APPEARANCE_TYPE_MINDFLAYER_2);

   SetupSubraceAlias("Illithid", "mind flayer");
   SetupSubraceAlias("Illithid", "mind flayer");
   SetupSubraceAlias("Illithid", "mind-flayer");

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Sahuagin ::::
//:::::::::::::::::::::::::::::::::::

//Properties from Skin:
    //AC +5

//Subrace Abilities :
    //Cast : Blood Frenzy 1/day

// Must be human, light sensisitve
// ECL : +2
    CreateSubrace(RACIAL_TYPE_HUMAN, "Sahuagin", "sha_pcl_Sahuagin", "sha_subrace_shau", TRUE, 0, FALSE, 0, 2);


//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Str +4
    //Dex +2
    //Con +2
    //Int +4
    //Wis +2
    struct SubraceBaseStatsModifier SahuStats = CustomBaseStatsModifiers(4, 2, 2, 4, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Sahuagin", SahuStats, 1);

//LETO - Feats:
    //Bonus Feat : Creature Weapons
    //Bonus Feat : Blind Fighting
    //Darkvision
    ModifySubraceFeat("Sahuagin", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Sahuagin", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);
    ModifySubraceFeat("Sahuagin", FEAT_BLIND_FIGHT, 1);

//LETO - Skills:
    //Skill Bonus: Hide +4
    //Skill Bonus: Listen +4
    //Skill Bonus: Spot +4
    //Skill Bonus: Animal Empathy +4
    ModifySubraceSkill("Sahuagin", SKILL_HIDE, 4, 1, FALSE);
    ModifySubraceSkill("Sahuagin", SKILL_LISTEN, 4, 1, FALSE);
    ModifySubraceSkill("Sahuagin", SKILL_SPOT, 4, 1, FALSE);
    ModifySubraceSkill("Sahuagin", SKILL_ANIMAL_EMPATHY, 4, 1, FALSE);

// Favored Class : Ranger
    AddSubraceFavoredClass("Sahuagin", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

// Lawful Evil Only
    CreateSubraceAlignmentRestriction("Sahuagin", FALSE, FALSE, TRUE, TRUE, FALSE, FALSE);

//Appearance:
    CreateSubraceAppearance("Sahuagin", TIME_BOTH, APPEARANCE_TYPE_SAHUAGIN, APPEARANCE_TYPE_SAHUAGIN_CLERIC);

// Claws d4
    AddClawsToSubrace("Sahuagin","sha_claw_d4","sha_claw_d4",1);

//:::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Human - Troglodyte ::::
//:::::::::::::::::::::::::::::::::::::

//Propertide from Skin:
//AC +5 natural

//Subrace Ability:
//Cast : Troglodyte Stench 1/day

//Must Be Human
//ECL : +2
    CreateSubrace(RACIAL_TYPE_HUMAN, "Troglodyte", "sha_pcl_trog", "sha_subrace_trog", TRUE, 0, FALSE, 0, 2);


//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Dex -2
    //Con +2
    //Int -2
    struct SubraceBaseStatsModifier TrogStats = CustomBaseStatsModifiers(0, -2, 2, -2, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Troglodyte", TrogStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Troglodyte", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);
    ModifySubraceFeat("Troglodyte", FEAT_DARKVISION, 1);

//LETO - Skills:
    ModifySubraceSkill("Troglodyte", SKILL_HIDE, 4, 1, FALSE);

// Favored Class : Cleric
    AddSubraceFavoredClass("Troglodyte", CLASS_TYPE_CLERIC, CLASS_TYPE_CLERIC);

// Evil Only
    CreateSubraceAlignmentRestriction("Troglodyte", FALSE, FALSE, TRUE);

//Appearance:
    CreateSubraceAppearance("Troglodyte", TIME_BOTH, APPEARANCE_TYPE_TROGLODYTE, APPEARANCE_TYPE_TROGLODYTE_WARRIOR);

// Claws d4
    AddClawsToSubrace("Troglodyte","sha_claw_d4","sha_claw_d4",1);

//::::::::::::::::::::::
//:::SUBRACE: Werewolf ::
//::::::::::::::::::::::

//Subrace Name: Werewolf

//Properties from the Skin:
//Dr 10/+1

//Human.
//ECL: + 3
   CreateSubrace(RACIAL_TYPE_HUMAN, "Werewolf", "sha_pcl_lycan", "", TRUE, 0, FALSE, 0, 3);

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    //Wis +2
    struct SubraceBaseStatsModifier WereWolfStats = CustomBaseStatsModifiers(0, 0, 0, 0, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Werewolf", WereWolfStats, 1);

//LETO - Feats:
    //Darkvision, Creature Wep Porf, Iron Will
    ModifySubraceFeat("Werewolf", FEAT_WEAPON_PROFICIENCY_CREATURE, 1);
    ModifySubraceFeat("Werewolf", FEAT_IRON_WILL, 1);
    ModifySubraceFeat("Werewolf", FEAT_DARKVISION, 1);

//Alignment Restriction: Can only be chaotic evil.
   CreateSubraceAlignmentRestriction("Werewolf", FALSE, FALSE, TRUE, FALSE, FALSE, TRUE);

//Appearance: Change the Appearance to a Werewolf using the appearance changer device.
  CreateSubraceAppearance("Werewolf", TIME_NIGHT, APPEARANCE_TYPE_WEREWOLF, APPEARANCE_TYPE_WEREWOLF, 1);

//Temporary Stats: Bonuses at Night time.
//Increase Strength by 2 points, Dexterity by 4 points, Constitution by 4, and AC by 2 during the Night.
   struct SubraceStats LycanWolfStats1 =  CreateCustomStats(SUBRACE_STAT_MODIFIER_TYPE_POINTS, 2.0, 4.0, 4.0, 0.0, 0.0, 0.0, 2.0, 0.0);
   CreateTemporaryStatModifier("Werewolf", LycanWolfStats1, TIME_NIGHT);

   AddClawsToSubrace("Werewolf","sha_claw_d4","sha_claw_d4",1,TIME_NIGHT);

}
