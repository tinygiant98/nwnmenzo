//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces1 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.

#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Artic :::::::::
//:::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Artic.

//Properties from the Skin:
    //Ability Bonus: Strength +4
    //AC Bonus +1
    //Decreased Ability Score: Dexterity -2
    //Immunity: Damage Type: Cold 100% Immunity Bonus
    //Skill Bonus: Hide +4

//Must be: Dwarf.
//ECL: + 1
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-artic", "sha_pc_dwarfarti", "", FALSE, 0, FALSE, 0, 1);

//Favored class: Ranger.
    AddSubraceFavoredClass("Dwarf-artic", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

     SetupSubraceAlias("Dwarf-artic", "artic dwarf");
     SetupSubraceAlias("Dwarf-artic", "dwarf artic");
     SetupSubraceAlias("Dwarf-artic", "artic");

//Human Faction
   ModifySubraceFaction("Dwarf-artic", "HUMAN_FACTION_NPC", SUBRACE_FACTION_REPUTATION_FRIENDLY);

//Human Starting Point
   CreateSubraceStartLocation("Dwarf-artic", "wp_human_start");

//Human Respawn Point
   CreateSubraceDeathLocation("Dwarf-artic", "wp_human_death");

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Deep :::::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Deep

//Properties from the Skin:
    //+3 save vs spells
    //+3 save vs poison
    //Darkvision

//Must be: Dwarf. Light sensitive.
   CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Deep", "sha_pc_dwarfdeep", "", TRUE);
   SetupSubraceAlias("Dwarf-Deep", "Deep Dwarf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Duergar :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Duergar

//Properties from the Skin:
    //Decreased Ability Score: Charisma -2
    //Immunity: Miscellaneous: Paralysis
    //Immunity: Miscellaneous: Poison
    //Immunity: Specific Spell Phantasmal Killer
    //Immunity: Specific Spell Weird

//Abilities from the unique item:
    //Cast Spell: Invisibility (3) 1 Use Per/Day.
//Must be: Dwarf. Light sensitive.
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-duergar", "sha_pc_dwarfduer", "sha_subrace_duer", TRUE, 0, FALSE, 0, 2);
    SetupSubraceAlias("Dwarf-duergar", "duergar");
    SetupSubraceAlias("Dwarf-duergar", "dwarf duergar");

// Hair: lightest gray = 16, Skin: stone = 60
    ModifySubraceAppearanceColors("Dwarf-duergar",16,16,60,60);

//::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Hill :::::::::
//::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Hill

//Must be: Dwarf.
    CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Hill");
    SetupSubraceAlias("Dwarf-Hill", "Hill Dwarf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Wild ::::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Dwarf-Wild.

//Properties from the Skin:
    //AC Bonus +1
    //Bonus Feat: Use Poison
    //Damage Resistance: Fire Resist 5 / -
    //Saving Throw Bonus: Disease +4
    //Saving Throw Bonus: Poison +1
    //Skill Bonus: Hide +4

//Must be: Dwarf.
   CreateSubrace(RACIAL_TYPE_DWARF, "Dwarf-Wild", "sha_pc_dwarfwild", "");
    SetupSubraceAlias("Dwarf-Wild", "wild dwarf");

//Favored class: Barbarian.
    AddSubraceFavoredClass("Dwarf-Wild", CLASS_TYPE_BARBARIAN, CLASS_TYPE_BARBARIAN);

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Dwarf - Azer ::::::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Azer

//Properties from the Skin:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Ability Bonus: Constitution +2
    //Ability Bonus: Strength +2
    //Ability Bonus: Wisdom +2
    //AC Bonus +6
    //Damage Vulnerability: Cold 50% Damage Vulnerability
    //Darkvision
    //Immunity: Damage Type: Fire 100% Immunity Bonus

//Must be: Dwarf
//ECL: + 3
     CreateSubrace(RACIAL_TYPE_DWARF, "Azer", "sha_pc_azer", "", FALSE, 0, FALSE, 0, 3);

//Appearance: Azer - Permanent.
     CreateSubraceAppearance("Azer", TIME_BOTH, APPEARANCE_TYPE_AZER_MALE, APPEARANCE_TYPE_AZER_FEMALE);

//Spell Resistance: 13 + 1 Per Level.
     CreateSubraceSpellResistance("Azer", 13, 53);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Elf - Aquatic :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Aquatic

//Properties from the Skin:
    //Decreased Ability Score: Intelligence -2
    //Immunity: Specific Spell Drown

//Must be: Elf
   CreateSubrace(RACIAL_TYPE_ELF, "Elf-Aquatic", "sha_pc_elfaquati", "");

//Favored Class: Fighter
   AddSubraceFavoredClass("Elf-Aquatic", CLASS_TYPE_FIGHTER, CLASS_TYPE_FIGHTER);
    SetupSubraceAlias("Elf-Aquatic", "aquatic");
    SetupSubraceAlias("Elf-Aquatic", "Aquatic Elf");

// Hair: green = 153, Skin: blue = 20
    ModifySubraceAppearanceColors("Elf-Aquatic",153,153,20,20);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:  Elf - Avariel ::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Avariel

//Properties from the Skin:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Intelligence +2
    //Ability Bonus: Wisdom +2
    //Skill Bonus: Spot +2


//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Avariel", "sha_pc_elfavarie", "");

// Can Fly
   AddSubraceItem("Elf-Avariel", "sha_subrace_fly");

//Favored Class: Cleric
    AddSubraceFavoredClass("Elf-Avariel", CLASS_TYPE_CLERIC, CLASS_TYPE_CLERIC);

//Leto - Add Bird wings
    ModifySubraceAppearanceAttachment("Elf-Avariel", CREATURE_WING_TYPE_BIRD, CREATURE_WING_TYPE_BIRD, 0, 0, 1);

    SetupSubraceAlias("Elf-Avariel","avariel");
    SetupSubraceAlias("Elf-Avariel","avariel elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Gray :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Gray

//Properties from the Skin:
    //Decreased Ability Score: Strength -2
    //Increased Ability Score: Intelligence +2

//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Gray", "sha_pc_elfgray", "");
    SetupSubraceAlias("Elf-Gray", "Gray Elf");
    SetupSubraceAlias("Elf-Gray", "Grey Elf");
    SetupSubraceAlias("Elf-Gray", "Elf-Grey");

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

//Properties from the Skin:
    //Decreased Ability Score: Intelligence -2


//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Wild", "sha_pc_elfwild", "");

//Favored Class: Sorcerer
    AddSubraceFavoredClass("Elf-Wild", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

    SetupSubraceAlias("Elf-Wild", "wild elf");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Wood :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Elf-Wood

//Properties from the Skin:
    //Ability Bonus: Strength +2
    //Decreased Ability Score: Charisma -2
    //Decreased Ability Score: Intelligence -2


//Must be: Elf
    CreateSubrace(RACIAL_TYPE_ELF, "Elf-Wood", "sha_pc_elfwood", "");

//Favored Class: Ranger
    AddSubraceFavoredClass("Elf-Wood", CLASS_TYPE_RANGER, CLASS_TYPE_RANGER);

    SetupSubraceAlias("Elf-Wood", "wood elf");
    SetupSubraceAlias("Elf-Wood", "wood-elf");
    SetupSubraceAlias("Elf-Wood", "slyvan elf");
    SetupSubraceAlias("Elf-Wood", "elf-slyvan");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE:    Elf - Drow :::::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Drow

//Properties from the Skin:
    //Ability Bonus: Charisma +2
    //Ability Bonus: Intelligence +2
    //Darkvision
    //Saving Throw Bonus: Specific: Will +2
    //Skill Bonus: Hide +2
    //Skill Bonus: Move Silently +2

//Abilities from the unique item:
    //Cast Spell: Darkness (5) 1 Use Per Day
    //Cast Spell: Light (1) 1 Use Per Day

//Must be Elf. Light Sensitive.
//ECL: +2
   CreateSubrace(RACIAL_TYPE_ELF, "Drow", "sha_pc_drow", "sha_subrace_drow", TRUE, 0, FALSE, 0, 2);
   SetupSubraceAlias("Drow", "dark elf");
   SetupSubraceAlias("Drow", "dark-elf");
   SetupSubraceAlias("Drow", "elf-dark");
   SetupSubraceAlias("Drow", "elf-drow");

// White Hair, Black Skin
    ModifySubraceAppearanceColors("Drow", 16, 16, 30, 30, 1);

//Favored Class - Male: Wizard, Female: Cleric.
   AddSubraceFavoredClass("Drow", CLASS_TYPE_WIZARD, CLASS_TYPE_CLERIC);

// Give Faerie Fire - Violet
    AddSubraceItem("Drow","sha_subrace_ff_v");

//Can only be evil
   CreateSubraceAlignmentRestriction("Drow", FALSE, FALSE, TRUE);

//Spell Resistance: Base (at Level 1): 10, Max(at Level 40): 50.
   CreateSubraceSpellResistance("Drow", 10, 50);

}
