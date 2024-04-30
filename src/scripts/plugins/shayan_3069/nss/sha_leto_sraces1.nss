//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_leto_sraces1 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: This script holds the pre-made 'normal' subraces. (By normal I mean,
//              subraces that are often found on persistent worlds. These sub-races
//              are humaniod sub-races... that is subraces like:
//              Drow, Aasimar, Duergar, etc.
//              This script is the Leto equivalent of sha_subraces1.
//              It will give players permanent ability scores,feats, etc rather than
//              as a bonus from skin/creature hide. It may also contain added benefits like
//              wings.


#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Artic :::::::::
//:::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Artic.

//Properties from the Skin:
    //AC Bonus +1
    //Immunity: Damage Type: Cold 100% Immunity Bonus


//Must be: Dwarf.
//ECL: + 1
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-artic", "sha_pcl_dwarfart", "", FALSE, 0, FALSE, 0, 1);

//LETO - Change ability scores:
    //Ability Bonus: Strength +4
    //Decreased Ability Score: Dexterity -2
    struct SubraceBaseStatsModifier DwarfArticStats = CustomBaseStatsModifiers(4, -2, 0, 0, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Dwarf-artic", DwarfArticStats, 1);

//LETO - Skills:
    //Skill Bonus: Hide +4
    ModifySubraceSkill("Dwarf-artic", SKILL_HIDE, 4, 1, FALSE);

//Favored class: Ranger.
    AddSubraceFavoredClass("Dwarf-artic", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

     SetupSubraceAlias("Dwarf-artic", "artic dwarf");
     SetupSubraceAlias("Dwarf-artic", "dwarf artic");
     SetupSubraceAlias("Dwarf-artic", "artic");

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Deep :::::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Deep

//Properties from the Skin:
    //+3 save vs poison

//Must be: Dwarf. Light sensitive.
   CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Deep", "sha_pc_dwarfdeep", "", TRUE);
   SetupSubraceAlias("Dwarf-Deep", "Deep Dwarf");

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Dwarf-Deep", FEAT_DARKVISION, 1);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Duergar :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Duergar

//Properties from the Skin:
    //Immunity: Miscellaneous: Paralysis
    //Immunity: Miscellaneous: Poison
    //Immunity: Specific Spell Phantasmal Killer
    //Immunity: Specific Spell Weird

//Abilities from the unique item:
    //Cast Spell: Invisibility (3) 1 Use Per/Day.
//Must be: Dwarf. Light sensitive.
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-duergar", "sha_pcl_dwarfdue", "sha_subrace_duer", TRUE, 0, FALSE, 0, 2);

// Hair: lightest gray = 16, Skin: stone = 60
    ModifySubraceAppearanceColors("Dwarf-duergar",16,16,60,60);

//LETO - Change ability scores:
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier DwarfDuergarStats = CustomBaseStatsModifiers(0, 0, 0, 0, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Dwarf-duergar", DwarfDuergarStats, 1);

    SetupSubraceAlias("Dwarf-duergar", "duergar");
    SetupSubraceAlias("Dwarf-duergar", "dwarf duergar");

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Hill :::::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Hill

//Must be: Dwarf.
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Hill");
    SetupSubraceAlias("Dwarf-Hill", "Hill Dwarf");

//Human Faction
   ModifySubraceFaction("Dwarf-Hill", "HUMAN_FACTION_NPC", SUBRACE_FACTION_REPUTATION_FRIENDLY);

//Human Starting Point
   CreateSubraceStartLocation("Dwarf-Hill", "wp_human_start");

//Human Respawn Point
   CreateSubraceDeathLocation("Dwarf-Hill", "wp_human_death");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Wild ::::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Wild.

//Properties from the Skin:
    //AC Bonus +1
    //Damage Resistance: Fire Resist 5 / -
    //Saving Throw Bonus: Disease +4
    //Saving Throw Bonus: Poison +1

//Must be: Dwarf.
   CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Wild", "sha_pcl_dwarfwil", "");

//LETO - Feats:
    //Use Poison
    ModifySubraceFeat("Dwarf-Wild", FEAT_USE_POISON, 1);

//LETO - Skills:
    //Skill Bonus: Hide +4
    ModifySubraceSkill("Dwarf-Wild", SKILL_HIDE, 4, 1, FALSE);

//Favored class: Barbarian.
    AddSubraceFavoredClass("Dwarf-Wild", CLASS_TYPE_BARBARIAN, CLASS_TYPE_BARBARIAN);

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Azer ::::::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Azer

//Properties from the Skin:
    //AC Bonus +6
    //Damage Vulnerability: Cold 50% Damage Vulnerability
    //Immunity: Damage Type: Fire 100% Immunity Bonus

//Must be: Dwarf
//ECL: + 3
     CreateSubrace(RACIAL_TYPE_DWARF, "Azer", "sha_pcl_azer", "", FALSE, 0, FALSE, 0, 3);

//LETO - Change ability scores:
    //Ability Bonus: Constitution +2
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Ability Bonus: Strength +2
    //Ability Bonus: Wisdom +2
    struct SubraceBaseStatsModifier AzerStats = CustomBaseStatsModifiers(2, 2, 2, 2, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Azer", AzerStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Azer", FEAT_DARKVISION, 1);

//Appearance: Azer - Permanent.
     CreateSubraceAppearance("Azer", TIME_BOTH, APPEARANCE_TYPE_AZER_MALE, APPEARANCE_TYPE_AZER_FEMALE);

//Spell Resistance: 13 + 1 Per Level.
     CreateSubraceSpellResistance("Azer", 13, 53);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Elf - Aquatic :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Aquatic

//Properties from the Skin:
    //Immunity: Specific Spell Drown

//Must be: Elf
   CreateSubrace(RACIAL_TYPE_ELF, "Elf-Aquatic", "sha_pcl_elfaquat", "");

// Hair: green = 153, Skin: blue = 20
    ModifySubraceAppearanceColors("Elf-Aquatic",153,153,20,20);

//LETO - Change ability scores:
    //Decreased Ability Score: Intelligence -2
    struct SubraceBaseStatsModifier ElfAquaticStats = CustomBaseStatsModifiers(0, 0, 0, -2, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Elf-Aquatic", ElfAquaticStats, 1);

//Favored Class: Fighter
   AddSubraceFavoredClass("Elf-Aquatic", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);


    SetupSubraceAlias("Elf-Aquatic", "Aquatic Elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:  Elf - Avariel ::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Avariel

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Avariel");

//LETO - Change ability scores:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Ability Bonus: Wisdom +2
    struct SubraceBaseStatsModifier ElfAvarielStats = CustomBaseStatsModifiers(0, 2, 0, 2, 2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Elf-Avariel", ElfAvarielStats, 1);

// Can Fly
   AddSubraceItem("Elf-Avariel", "sha_subrace_fly");

//LETO - Skills:
    //Skill Bonus: Spot +2
    ModifySubraceSkill("Elf-Avariel", SKILL_SPOT, 2, 1, FALSE);

//Favored Class: Cleric
    AddSubraceFavoredClass("Elf-avaiel", CLASS_TYPE_CLERIC, CLASS_TYPE_CLERIC);

//Leto - Add Bird wings
    ModifySubraceAppearanceAttachment("Elf-Avariel", CREATURE_WING_TYPE_BIRD, CREATURE_WING_TYPE_BIRD, 0, 0, 1);

    SetupSubraceAlias("Elf-Avariel", "avariel");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Gray :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Gray

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Gray");
    SetupSubraceAlias("Elf-Gray", "Gray Elf");
    SetupSubraceAlias("Elf-Gray", "Grey Elf");
    SetupSubraceAlias("Elf-Gray", "Elf-Grey");


//LETO - Change ability scores:
    //Decreased Ability Score: Strength -2
    //Increased Ability Score: Intelligence +2
    struct SubraceBaseStatsModifier ElfGrayStats = CustomBaseStatsModifiers(-2, 0, 0, 2, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Elf-Gray", ElfGrayStats, 1);

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Elf - High :::::::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-High

//Must be: Elf
   CreateSubrace(RACIAL_TYPE_ELF, "Elf-High");
    SetupSubraceAlias("Elf-High", "High Elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Wild :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Wild

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-wild");

//LETO - Change ability scores:
    //Decreased Ability Score: Intelligence -2
    struct SubraceBaseStatsModifier ElfWildStats = CustomBaseStatsModifiers(0, 0, 0, -2, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Elf-wild", ElfWildStats, 1);

//Favored Class: Sorcerer
    AddSubraceFavoredClass("Elf-wild", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Wood :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Wood

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Wood");

//LETO - Change ability scores:
    //Ability Bonus: Strength +2
    //Decreased Ability Score: Charisma -2
    //Decreased Ability Score: Intelligence -2
    struct SubraceBaseStatsModifier ElfWoodStats = CustomBaseStatsModifiers(2, 0, 0, -2, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Elf-Wood", ElfWoodStats, 1);

//Favored Class: Ranger
    AddSubraceFavoredClass("Elf-Wood", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

    SetupSubraceAlias("Elf-Wood", "wood elf");
    SetupSubraceAlias("Elf-Wood", "wood-elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Drow :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Drow

//Properties from the Skin:
    //Saving Throw Bonus: Specific: Will +2

//Abilities from the unique item:
    //Cast Spell: Darkness (5) 1 Use Per Day
    //Cast Spell: Light () 1 Use Per Day

//Must be Elf. Light Sensitive.
//ECL: +2
   CreateSubrace(RACIAL_TYPE_ELF, "Drow", "sha_pcl_drow", "sha_subrace_drow", TRUE, 0, FALSE, 0, 2);

// White Hair, Black Skin
    ModifySubraceAppearanceColors("Drow", 16, 16, 30, 30, 1);

// Give Faerie Fire - Violet
    AddSubraceItem("Drow","sha_subrace_ff_v");

//LETO - Change ability scores:
    //Ability Bonus: Charisma +2
    //Ability Bonus: Intelligence +2
    struct SubraceBaseStatsModifier DrowStats = CustomBaseStatsModifiers(0, 0, 0, 2, 0, 2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Drow", DrowStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Drow", FEAT_DARKVISION, 1);

//LETO - Skills:
    //Skill Bonus: Move Silently +2
    //Skill Bonus: Hide +2
    ModifySubraceSkill("Drow", SKILL_MOVE_SILENTLY, 2, 1, FALSE);
    ModifySubraceSkill("Drow", SKILL_HIDE, 2, 1, FALSE);

//Favored Class - Male: Wizard, Female: Cleric.
   AddSubraceFavoredClass("Drow", CLASS_TYPE_WIZARD, CLASS_TYPE_CLERIC);

//Can only be evil
   CreateSubraceAlignmentRestriction("Drow", FALSE, FALSE, TRUE);

//Spell Resistance: Base (at Level 1): 10, Max(at Level 40): 50.
   CreateSubraceSpellResistance("Drow", 10, 50);

    SetupSubraceAlias("Drow", "dark elf");
    SetupSubraceAlias("Drow", "dark-elf");


}
