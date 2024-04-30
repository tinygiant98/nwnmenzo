//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//:::::::::::::::::File Name: sha_leto_sraces3 ::::::::::::::::::::::::::::::::::::
//::::::::::::::::::::: OnModuleLoad script ::::::::::::::::::::::::::::::::::::
//:: Written By: Shayan.
//:: Contact: mail_shayan@yahoo.com
//
// Description: This script holds the pre-made 'default' subraces.

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

//Must be: Gnome.
    CreateSubrace(RACIAL_TYPE_GNOME, "Gnome-Forest", "sha_pcl_forest");
    SetupSubraceAlias("Gnome-Forest", "Forest Gnome");

//LETO - Skills:
    //Skill Bonus: Hide +4
ModifySubraceSkill("Halfling-Tallfellow", SKILL_HIDE, 4, 1, FALSE);

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
    //Saving Throw Bonus: Universal +2

//Abilities from the unique item:
   //Cast Spell: Blindness/Deafness (3) 1 Use/Day

//Must be: Gnome.
//Light Sensitive.
//ECL: + 2
    CreateSubrace(RACIAL_TYPE_GNOME, "Svirfneblin", "sha_pcl_svirfneb", "sha_subrace_svir", TRUE, 0, FALSE, 2);

// Hair, Skin: stone = 60
    ModifySubraceAppearanceColors("Svirfneblin",60,60,60,60);

//LETO - Change ability scores:
    //Ability Bonus: Dexterity +2
    //Ability Bonus: Wisdom +2
    //Decreased Ability Score: Charisma -4
    struct SubraceBaseStatsModifier SvirnStats = CustomBaseStatsModifiers(0, 2, 0, 0, 2, -4, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Svirfneblin", SvirnStats, 1);

//LETO - Feats:
    //Darkvision
    //Bonus Feat: Dodge
    ModifySubraceFeat("Svirfneblin", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Svirfneblin", FEAT_DODGE, 1);

//LETO - Skills:
    //Skill Bonus: Search +2
    ModifySubraceSkill("Svirfneblin", SKILL_SEARCH, 2, 1, FALSE);


//Spell Resistance: 10 + 1 Per Level.
    CreateSubraceSpellResistance("Svirfneblin", 10, 50);

//:::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Gnome - Tinker ::::::
//:::::::::::::::::::::::::::::::::::

//Subrace Name: Tinker

//Must be: Gnome.
    CreateSubrace(RACIAL_TYPE_GNOME, "Tinker");

//LETO - Change ability scores:
    //Ability Bonus: Intelligence +2
    //Decreased Ability Score: Wisdom -2
    struct SubraceBaseStatsModifier TinkerStats = CustomBaseStatsModifiers(0, 0, 0, 2, -2, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Tinker", TinkerStats, 1);

//LETO - Skills:
    //Skill Bonus: Appraise +2
    //Skill Bonus: Craft Armor +4
    //Skill Bonus: Craft Trap +4
    //Skill Bonus: Craft Weapon +4
    //Skill Bonus: Disable Trap +2
    //Skill Bonus: Open Lock +2
    //Skill Bonus: Set Trap +2
    //Skill Bonus: Use Magic Device +4

    //ModifySubraceSkill("Tinker", SKILL_APPRAISE, 2, 1, FALSE);
    //ModifySubraceSkill("Tinker", SKILL_CRAFT_ARMOR, 4, 1, FALSE);
    //ModifySubraceSkill("Tinker", SKILL_CRAFT_TRAP, 4, 1, FALSE);
    ModifySubraceSkill("Tinker", SKILL_DISABLE_TRAP, 2, 1, FALSE);
    ModifySubraceSkill("Tinker", SKILL_OPEN_LOCK, 2, 1, FALSE);
    ModifySubraceSkill("Tinker", SKILL_SET_TRAP, 2, 1, FALSE);
    ModifySubraceSkill("Tinker", SKILL_USE_MAGIC_DEVICE, 4, 1, FALSE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Deep :::::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Deep


//Must be: Halfling.
     CreateSubrace(RACIAL_TYPE_HALFLING, "deep");

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("deep", FEAT_DARKVISION, 1);


//LETO - Skills:
    //Skill Bonus: Search +2
    ModifySubraceSkill("deep", SKILL_SEARCH, 2, 1, FALSE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Ghostwise ::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Ghostwise

//Must be: Halfling.
     CreateSubrace(RACIAL_TYPE_HALFLING, "ghostwise");

//Favored Class: Barbarian.
     AddSubraceFavoredClass("ghostwise", CLASS_TYPE_BARBARIAN, CLASS_TYPE_BARBARIAN);

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

//Must be: Halfling.
    CreateSubrace(RACIAL_TYPE_HALFLING, "Halfling-Tallfellow");
    SetupSubraceAlias("Halfling-Tallfellow", "Tallfellow");
    SetupSubraceAlias("Halfling-Tallfellow", "Tallfellow Halfling");

//LETO - Skills:
     //Skill Bonus: Listen +2
     //Skill Bonus: Spot +2
     //Skill Decrease: Move Silent -2
    ModifySubraceSkill("Halfling-Tallfellow", SKILL_SPOT, 2, 1, FALSE);
    ModifySubraceSkill("Halfling-Tallfellow", SKILL_LISTEN, 2, 1, FALSE);
    ModifySubraceSkill("Halfling-Tallfellow", SKILL_MOVE_SILENTLY, -2, 1, FALSE);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Goblin :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Goblin

//Must be: Halfling.
      CreateSubrace(RACIAL_TYPE_HALFLING, "Goblin");

//LETO - Change ability scores:
    //Decreased Ability Score: Charisma -2
    struct SubraceBaseStatsModifier GoblinStats = CustomBaseStatsModifiers(0, 0, 0, 0, 0, -2, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Goblin", GoblinStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Goblin", FEAT_DARKVISION, 1);

//Apearance: Goblin - Permanent.
      CreateSubraceAppearance("Goblin", TIME_BOTH, APPEARANCE_TYPE_GOBLIN_CHIEF_A, APPEARANCE_TYPE_GOBLIN_A);

//:::::::::::::::::::::::::::::::::::::::
//:::: SUBRACE: Halfling - Kobold :::::::
//:::::::::::::::::::::::::::::::::::::::

//Subrace Name: Kobold

//Properties from the Skin:
//  AC +1

//Must be: Halfling.
      CreateSubrace(RACIAL_TYPE_HALFLING, "Kobold", "sha_pcl_kobold", "");

//LETO - Change ability scores:  (Str, Dex, Con, Int, Wis, Cha)
    struct SubraceBaseStatsModifier KoboldStats = CustomBaseStatsModifiers(-2, 0, -2, 0, 0, 0, MOVEMENT_SPEED_CURRENT);
    CreateBaseStatModifier("Kobold", KoboldStats, 1);

//LETO - Feats:
    //Darkvision
    ModifySubraceFeat("Kobold", FEAT_DARKVISION, 1);

//LETO - Skills:
    ModifySubraceSkill("Kobold", SKILL_CRAFT_TRAP, 2, 1, FALSE);
    ModifySubraceSkill("Kobold", SKILL_SEARCH, 2, 1, FALSE);

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
    //AC Bonus +1
    //Damage Reduction: +1 Soak 5 Damage

//Abilities from the unique item:
    //Cast Spell: Confusion (10) 1 Use/Day
    //Cast Spell: Entangle (5) 1 Use/Day
    //Cast Spell: Invisibility (3) 1 Use/Day
    //Cast Spell: Lesser Dispel (5) 1 Use/Day
    //Cast Spell: Polymorph Self (7) 1 Use/Day

//Must be: Halfling.
//ECL: +3
    CreateSubrace(RACIAL_TYPE_HALFLING, "Pixie", "sha_pcl_pixie", "sha_subrace_pixi", FALSE, 0, FALSE, 0, 3);

// Can Fly
   AddSubraceItem("Pixie", "sha_subrace_fly");

//LETO - Change ability scores:
    //Ability Bonus: Charisma +6
    //Ability Bonus: Dexterity +8
    //Ability Bonus: Intelligence +6
    //Ability Bonus: Wisdom +4
    //Decreased Ability Score: Constitution -4
    //Decreased Ability Score: Strength -4
    //Movement Speed: Fast
    struct SubraceBaseStatsModifier PixieStats = CustomBaseStatsModifiers(-4, 8, -4, 6, 4, 6, MOVEMENT_SPEED_FAST);
    CreateBaseStatModifier("Pixie", PixieStats, 1);

//LETO - Feats:
    //Darkvision
    //Bonus Feat: Dodge
    ModifySubraceFeat("Pixie", FEAT_DARKVISION, 1);
    ModifySubraceFeat("Pixie", FEAT_DODGE, 1);

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

//Can only use tiny weapons.
//Can only wear clothing. Can't use any shields.
   SubraceRestrictUseOfItems("Pixie", ITEM_TYPE_WEAPON_SIZE_TINY | ITEM_TYPE_ARMOR_TYPE_CLOTH, TIME_BOTH, ITEM_TYPE_REQ_ANY);

}

