//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_subraces3 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.

#include "sha_subr_methds"
void main()
{
//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Gnome - Forest ::::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Forest

//Properties from the Skin:
    //AC bonus vs Goblinoid +1
    //AC bonus vs Orc +1
    //AC bonus vs Reptillian +1
    //Skill Bonus: Hide +4

//Must be: Gnome.
    CreateSubrace(RACIAL_TYPE_GNOME, "Gnome-Forest", "sha_pc_forest");
    SetupSubraceAlias("Gnome-Forest", "Forest Gnome");

//::::::::::::::::::::::::::::::::
//:::: SUBRACE: Gnome - Rock :::::
//::::::::::::::::::::::::::::::::

//Subrace Name: Gnome-Rock

//Must be: Gnome.
    CreateSubrace(RACIAL_TYPE_GNOME, "Gnome-Rock");
    SetupSubraceAlias("Gnome-Rock", "Rock Gnome");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Gnome - Svirfneblin :::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Svirfneblin

//Properties from the Skin:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Wisdom +2
    //Bonus Feat: Dodge
    //Darkvision
    //Decreased Ability Score: Charisma -4
    //Saving Throw Bonus: Universal +2
    //Skill Bonus: Search +2

//Abilities from the unique item:
   //Cast Spell: Blindness/Deafness (3) 1 Use/Day

//Must be: Gnome.
//Light Sensitive.
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_GNOME, "Svirfneblin", "sha_pc_svirfnebl", "sha_subrace_svir", TRUE, 0, FALSE, 2);

// Hair, Skin: stone = 60
    ModifySubraceAppearanceColors("Svirfneblin",60,60,60,60);

//Spell Resistance: 10 + 1 Per Level.
    CreateSubraceSpellResistance("Svirfneblin", 10, 50);

    SetupSubraceAlias("Svirfneblin", "Gnome-Deep");
    SetupSubraceAlias("Svirfneblin", "Deep Gnome");

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Gnome - Tinker ::::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Tinker

//Properties from the Skin:
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Wisdom -2
    //Skill Bonus: Appraise +2
    //Skill Bonus: Craft Armor +4
    //Skill Bonus: Craft Trap +4
    //Skill Bonus: Craft Weapon +4
    //Skill Bonus: Disable Trap +2
    //Skill Bonus: Open Lock +2
    //Skill Bonus: Set Trap +2
    //Skill Bonus: Use Magic Device +4

//Must be: Gnome.
    CreateSubrace(RACIAL_TYPE_GNOME, "Tinker", "sha_pc_tinker");

    SetupSubraceAlias("Tinker", "Gnome-Tinker");
    SetupSubraceAlias("Tinker", "Tinker Gnome");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Deep :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Deep

//Properties from the Skin:
     //Darkvision
     //Skill Bonus: Search +2

//Must be: Halfling.
     CreateSubrace(RACIAL_TYPE_HALFLING, "Deep", "sha_pc_deep");

    SetupSubraceAlias("Deep", "Halfling-Deep");
    SetupSubraceAlias("Deep", "Deep Halfling");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Ghostwise ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Ghostwise

//Must be: Halfling.
     CreateSubrace(RACIAL_TYPE_HALFLING, "Ghostwise", "none");

//Favored Class: Barbarian.
     AddSubraceFavoredClass("Ghostwise", CLASS_TYPE_BARBARIAN, CLASS_TYPE_BARBARIAN);

    SetupSubraceAlias("Ghostwise", "Ghostwise Halfling");
    SetupSubraceAlias("Ghostwise", "Halfling-Ghostwise");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Lightfoot ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Halfling-Lightfoot

//Must be: Halfling.
    CreateSubrace(RACIAL_TYPE_HALFLING, "Halfling-Lightfoot");
    SetupSubraceAlias("Halfling-Lightfoot", "Lightfoot");
    SetupSubraceAlias("Halfling-Lightfoot", "Lightfoot Halfling");

//:::::::::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Tallfellow :::::::::
//:::::::::::::::::::::::::::::::::::::::::::::

//Subrace Name: Halfling-Tallfellow

//Properties from the Skin:
     //Skill Bonus: Listen +2
     //Skill Bonus: Spot +2
     //Skill Decrease: Move Silent -2

//Must be: Halfling.
    CreateSubrace(RACIAL_TYPE_HALFLING, "Halfling-Tallfellow", "sha_pc_tall");
    SetupSubraceAlias("Halfling-Tallfellow", "Tallfellow");
    SetupSubraceAlias("Halfling-Tallfellow", "Tallfellow Halfling");

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Goblin :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Goblin

//Properties from the Skin:
    //Darkvision
    //Decreased Ability Score: Charisma -2

//Must be: Halfling.
      CreateSubrace(RACIAL_TYPE_HALFLING, "goblin", "sha_pc_goblin", "");

//Apearance: Goblin - Permanent.
      CreateSubraceAppearance("Goblin", TIME_BOTH, APPEARANCE_TYPE_GOBLIN_CHIEF_A, APPEARANCE_TYPE_GOBLIN_A);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Kobold :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Kobold

//Properties from the Skin:
//  Str -2
//  Con -2
//  AC +1
//  Darkvision
//  Skill Bonus: Craft Trap +2
//  Skill Bonus: Search +2

//Must be: Halfling.
      CreateSubrace(RACIAL_TYPE_HALFLING, "Kobold", "sha_pc_Kobold", "");

//Apearance: Kobold - Permanent.
      CreateSubraceAppearance("Kobold", TIME_BOTH, APPEARANCE_TYPE_KOBOLD_A, APPEARANCE_TYPE_KOBOLD_A);

//Favored Class: Sorcerer
    AddSubraceFavoredClass("Kobold", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//Evil Only
   CreateSubraceAlignmentRestriction("Kobold", FALSE, FALSE, TRUE, TRUE, TRUE, TRUE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Pixie ::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Pixie

//Properties from the Skin:
    //Ability Bonus: Charisma +6
    //Ability Bonus: Dexterity +8
    //Ability Bonus: Intelligence +6
    //Ability Bonus: Wisdom +4
    //AC Bonus +1
    //Bonus Feat: Dodge
    //Damage Reduction: +1 Soak 5 Damage
    //Darkvision
    //Decreased Ability Score: Constitution -4
    //Decreased Ability Score: Strength -4

//Abilities from the unique item:
    //Cast Spell: Confusion (10) 1 Use/Day
    //Cast Spell: Entangle (5) 1 Use/Day
    //Cast Spell: Invisibility (3) 1 Use/Day
    //Cast Spell: Lesser Dispel (5) 1 Use/Day
    //Cast Spell: Polymorph Self (7) 1 Use/Day


//Must be: Halfling.
//ECL: +3
    CreateSubrace(RACIAL_TYPE_HALFLING, "Pixie", "sha_pc_pixie", "sha_subrace_pixi", FALSE, 0, FALSE, 0, 3);

// Can Fly
   AddSubraceItem("Pixie", "sha_subrace_fly");

//Alignment Restriction: Neutral Only.
    CreateSubraceAlignmentRestriction("Pixie", FALSE, TRUE, FALSE);

//Class Restriction: Can only be either: Bard, Rogue, Sorcerer or Wizard.
    CreateSubraceClassRestriction("Pixie", FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE);

//Favored Class: Sorcerer.
    AddSubraceFavoredClass("Pixie", CLASS_TYPE_SORCERER, CLASS_TYPE_SORCERER);

//Appearance Change: Permanent - Pixie
    CreateSubraceAppearance("Pixie", TIME_BOTH, APPEARANCE_TYPE_FAIRY, APPEARANCE_TYPE_FAIRY);

//Effect: Visual Effect - Fairy Dust.
   AddSubraceEffect("Pixie", EFFECT_TYPE_VISUALEFFECT, VFX_DUR_PIXIEDUST, FALSE, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);

//Spell Resistance: Base (at Level 1): 15, Max(at Level 40): 55.
   CreateSubraceSpellResistance("Pixie", 15, 55);

//3.0.6
//Replaced Old : SubraceRestrictUseOfItems("Pixie", ITEM_TYPE_ARMOR_TYPE_CLOTH |ITEM_TYPE_WEAPON_SIZE_TINY, TIME_SPECIAL_APPEARANCE_SUBRACE, ITEM_TYPE_REQ_ANY);
//Added Shayan's Fix from Forum
//Updated to ITEM_TYPE_ARMOR_AC_0
//Removed from Shayan's Forum fix : /* ITEM_TYPE_MAGICAL_ITEM, */

//Can only use tiny weapons, Can only wear clothing. Can't use any shields.
   SubraceRestrictUseOfItems("Pixie", ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_ARMOR_AC_0 | ITEM_TYPE_MISC_CLOTHING | ITEM_TYPE_JEWLERY | ITEM_TYPE_HELM | TIME_BOTH,ITEM_TYPE_REQ_ALL);

}
