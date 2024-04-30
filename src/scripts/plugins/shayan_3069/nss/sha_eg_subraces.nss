//::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
//:::::::::::::::::::::::: Shayan's Subrace Engine :::::::::::::::::::::::::::::
//::::::::::::::::::::::: File Name: sha_subr_methds :::::::::::::::::::::::::::
//:::::::::::::::::::::::::: Include script ::::::::::::::::::::::::::::::::::::
//:: Written by: Shayan                                                     :://
//:: Contact: mail_shayan@yhaoo.com                                         :://
//
// ::Description: This is STRICTLY an example script showing how you can setup
//                dynamic subrace switching system using SetupSubraceSwitch(...)
//
// :: WARNING: This is a example script and these subraces are not intended to be
//             used in any module, as the skins and other items either have not been
//             created or is from another subrace. I say it again, this script is
//             STRICTLY for a scripters eye only, and should not be used.
//
//
// :: Here is how the following system is setup:
//
//
// ::                                                                                                   Undead
// ::                                                                                                      |
// ::                                                                                                      |
// ::                                                                                                      |
// ::                                                                                                      |
// ::                                                                          -------------------------------------------------------------
// ::                                                                          |                                                           |
// ::                                                                          |                                                           |
// ::                                                                          | (Level 5)                                                 | (Level 20)
// ::                                                                          |                                                           |
// ::                      -----------------------------------------------------------------------------------------------              Zombie
// ::                      |                                                       |                                     |
// ::                      |                                                       |                                     |
// ::                      |                                                       |                                     |
// ::                   Phantasm                                               Skeleton                              Vampire
// ::                      |                                                       |
// ::                      | (Level 10)                                            |  (Level 10)
// ::            ----------------------------                ----------------------------------------------------
// ::            |                          |                |                        |                         |
// ::            |                          |                |                        |                         |
// ::            |                          |                |                        |                         |
// ::         Shadow                      Allip         Skeleton Mage          Skeleton Warrior          Skeleton Priest
// ::            |                          |                |                        |
// ::            |                          |                |                        |
// ::            | (Level 20)               | (Level 15)     |                        |
// ::         Shade                      Spectre             |                        |
// ::                                                        |                        |
// ::                                                        |                        |
// ::                                                        |                        |
// ::                                                        | (Level 15)             |  (Level 25)
// ::                                                       Lich                Skeleton-Chieftan
// ::
// ::
// ::
// :: NOTE: Most of these subraces subraces have restrictions. If a PC does not meet them they will not change in subrace.
// ::       EG: For a Skeleton to become either skeleton mage or skeleton warrior oe skeleton priest, it must meet certain alignment and
// ::           class restrictions. If a certain Skeleton PC does not meet any the criteria to become part of another skeletal subrace at
// ::           Level 10, then he/she will continue as a Skeleton, forever.
// ::
// ::
// :: NOTE 2: A Player can de-level and relevel again inorder to try and become a part of a subrace he/she failed to meet criteria of.
// ::         EG: If my Undead character failed to meet any criteria to switch to one of the subraces (Phatasm or Skeleton or Vampire) at level 5,
// ::             and continues on as Undead, then he/she can de-level to level 5 and try again.
// ::
// ::         HOWEVER the reverse is not true. That is once you are part of a subrace, you can't revert back the previous one.
// ::         EG: If my Undead character became a vampire, when I wanted to become a Phantasm, I can't de-level my vampire expecting to
// ::             switch back.
#include "sha_subr_methds"
void main()
{
   //:: An Undead subrace
   CreateSubrace(RACIAL_TYPE_ALL, "undead", "sha_pc_undead", "", TRUE, 2, FALSE, -1, 2, FALSE);
   //:: Non-good only. . .
   CreateSubraceAlignmentRestriction("undead", FALSE);
   //:: Setup a subrace switch: Phantasm, Skeleton or Vampire at Level 5
   SetupSubraceSwitch("undead", "phantasm_skeleton_vampire", 5, TRUE);
   //:: Setup a subrace switch at level 20 to: Zombie. (Do not check requirements
   //   - meaning ALL 'Undead' PCs -that didn't make it as a vampire or a phantasm or a skeleton- will become Zombie at level 20)
   SetupSubraceSwitch("undead", "zombie", 20, FALSE);


       //Phantasm

       CreateSubrace(RACIAL_TYPE_ALL, "phantasm", "sha_pc_phantasm", "", TRUE, 2, FALSE, -1, 2, TRUE);
       //Neutral only
       CreateSubraceAlignmentRestriction("phantasm", FALSE, TRUE, FALSE);
       CreateSubraceAppearance("phantasm", TIME_BOTH, APPEARANCE_TYPE_ALLIP, APPEARANCE_TYPE_ALLIP);
       //:: Concealed at 20%
       AddSubraceEffect("phantasm", EFFECT_TYPE_CONCEALMENT, 20, MISS_CHANCE_TYPE_NORMAL, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);
       SetupSubraceSwitch("phantasm", "shadow_allip", 10, TRUE);

                //Shadow

                CreateSubrace(RACIAL_TYPE_ALL, "shadow", "sha_pc_shadow", "", TRUE, 2, FALSE, -1, 2, TRUE);
                //Evil only
                CreateSubraceAlignmentRestriction("shadow", FALSE, FALSE, TRUE);
                //:: Fighter, Monk, Rogue and Sorcerer only.
                CreateSubraceClassRestriction("shadow", FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, FALSE);
                //:: Atleast 2 levels of Shadow Dancer.
                CreateSubracePrestigiousClassRestriction("shade", 2, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
                CreateSubraceAppearance("shadow", TIME_BOTH, APPEARANCE_TYPE_SHADOW, APPEARANCE_TYPE_SHADOW);
                //:: Concealed at 25%
                AddSubraceEffect("shadow", EFFECT_TYPE_CONCEALMENT, 25, MISS_CHANCE_TYPE_NORMAL, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);
                SetupSubraceSwitch("shadow", "shade", 20, TRUE);

                    //Shade

                    CreateSubrace(RACIAL_TYPE_ALL, "shade", "sha_pc_shade", "", TRUE, 2, FALSE, -1, 3, TRUE);
                    //Evil only
                    CreateSubraceAlignmentRestriction("shade", FALSE, FALSE, TRUE);
                    //:: Sorcerer only.
                    CreateSubraceClassRestriction("shade", FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE, FALSE);
                    //:: Must have atleast 6 levels of Blackguard or Shadow Dancer (or some combination of both adding to 6).
                    CreateSubracePrestigiousClassRestriction("shade", 6, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE);
                    CreateSubraceAppearance("shade", TIME_BOTH, APPEARANCE_TYPE_SHADOW_FIEND, APPEARANCE_TYPE_SHADOW_FIEND);
                    //:: Concealed at 40%
                    AddSubraceEffect("shade", EFFECT_TYPE_CONCEALMENT, 40, MISS_CHANCE_TYPE_NORMAL, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);
                    CreateSubraceSpellResistance("shade", 10, 50);


                //Allip

                CreateSubrace(RACIAL_TYPE_ALL, "allip", "sha_pc_allip", "", TRUE, 2, FALSE, -1, 2, TRUE);
                //Neutral only
                CreateSubraceAlignmentRestriction("allip", FALSE, TRUE, FALSE);
                //:: Bard, Cleric, Fighter, Monk, Rogue, Sorcerer and Wizard only.
                CreateSubraceClassRestriction("allip", FALSE, TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, TRUE, TRUE);
                CreateSubraceAppearance("allip", TIME_BOTH, APPEARANCE_TYPE_ALLIP, APPEARANCE_TYPE_ALLIP);
                //:: Permanently concealed at 30%
                AddSubraceEffect("allip", EFFECT_TYPE_CONCEALMENT, 30, MISS_CHANCE_TYPE_NORMAL, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);
                SetupSubraceSwitch("allip", "spectre", 15, TRUE);

                    //Spectre

                    CreateSubrace(RACIAL_TYPE_ALL, "spectre", "sha_pc_spectre", "", TRUE, 2, FALSE, -2, 3, TRUE);
                    //Neutral-Evil or Chaotic-Evil only.
                    CreateSubraceAlignmentRestriction("spectre", FALSE, FALSE, TRUE, FALSE, TRUE);
                    CreateSubraceAppearance("spectre", TIME_BOTH, APPEARANCE_TYPE_WRAITH, APPEARANCE_TYPE_WRAITH);
                    CreateSubraceSpellResistance("spectre", 5, 35);
                    //:: Concealed at 50%
                    AddSubraceEffect("spectre", EFFECT_TYPE_CONCEALMENT, 50, MISS_CHANCE_TYPE_NORMAL, DURATION_TYPE_PERMANENT, 0.0, TIME_BOTH);

       //Skeleton

       CreateSubrace(RACIAL_TYPE_HUMAN, "skeleton", "sha_pc_skeleton", "", TRUE, 3, FALSE, -1, 3, TRUE);
       //Can also be Elf.
       AddAdditionalBaseRaceToSubrace("skeleton", RACIAL_TYPE_ELF);

       //Can also be Half-Elf.
       AddAdditionalBaseRaceToSubrace("skeleton", RACIAL_TYPE_HALFELF);

       //:: Lawful Evil and Neutral Evil only.
       CreateSubraceAlignmentRestriction("skeleton", FALSE, FALSE, TRUE, TRUE, TRUE, FALSE);
       CreateSubraceAppearance("skeleton", TIME_BOTH, APPEARANCE_TYPE_SKELETON_COMMON, APPEARANCE_TYPE_SKELETON_COMMON);
       SetupSubraceSwitch("skeleton", "skeleton-mage_skeleton-warrior_skeleton-priest", 10, TRUE);

            //Skeleton-Mage

            CreateSubrace(RACIAL_TYPE_HUMAN, "skeleton-mage", "sha_pc_skelem", "", TRUE, 2, FALSE, -2, 3, TRUE);
            //Can also be Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-mage", RACIAL_TYPE_ELF);

            //Can also be Half-Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-mage", RACIAL_TYPE_HALFELF);

            //Neutral-Evil or Chaotic-Evil only.
            CreateSubraceAlignmentRestriction("skeleton-mage", FALSE, FALSE, TRUE, TRUE, TRUE, FALSE);
            //:: Sorcerer or Wizard only.
            CreateSubraceClassRestriction("skeleton-mage", FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);
            CreateSubraceAppearance("skeleton-mage", TIME_BOTH, APPEARANCE_TYPE_SKELETON_MAGE, APPEARANCE_TYPE_SKELETON_MAGE);
            CreateSubraceSpellResistance("skeleton-mage", 5, 25);
            //:: Switch to Lich
            SetupSubraceSwitch("skeleton-mage", "lich", 15, TRUE);

                //Lich

                //Human. Light Sensitive. Takes 5 Divine Damage While in Sunlight.
                //ECL: + 3
                //Undead
                    CreateSubrace(RACIAL_TYPE_HUMAN, "lich", "sha_pc_lich", "sha_subrace_lich", TRUE, 4, FALSE, 0, 3, TRUE, TRUE);

                //Can also be Elf.
                    AddAdditionalBaseRaceToSubrace("lich", RACIAL_TYPE_ELF);

                //Can also be Half-Elf.
                    AddAdditionalBaseRaceToSubrace("lich", RACIAL_TYPE_HALFELF);

                //The different skins to be equipped at different levels...
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich1", 5);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich2", 10);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich3", 15);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich4", 20);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich5", 25);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich6", 30);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich7", 35);
                    AddAdditionalSkinsToSubrace("lich", "sha_pc_lich8", 40);

                //Alignment Restriction - Must be Evil.
                    CreateSubraceAlignmentRestriction("lich", FALSE, FALSE, TRUE);
                //Class Restriction - Can only be Wizard or Sorcerer.
                    CreateSubraceClassRestriction("lich", FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);
                //Prestige Class Restriction - Needs atleast 5 levels of Pale Master
                    CreateSubracePrestigiousClassRestriction("lich", 5, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE);
                //Spell Resistance: 10 + 1/2 Per Level.
                    CreateSubraceSpellResistance("lich", 10, 30);
                //Appearance: Lich - Permanent.
                    CreateSubraceAppearance("lich", TIME_BOTH, APPEARANCE_TYPE_LICH, APPEARANCE_TYPE_HEURODIS_LICH);
                //Favored Class: Wizard
                    AddSubraceFavoredClass("lich", CLASS_TYPE_WIZARD, CLASS_TYPE_WIZARD);



            //Skeleton-Warrior

            CreateSubrace(RACIAL_TYPE_HUMAN, "skeleton-warrior", "sha_pc_skelew", "", TRUE, 2, FALSE, -2, 3, TRUE);
            //Can also be Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-warrior", RACIAL_TYPE_ELF);
            //Can also be Half-Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-warrior", RACIAL_TYPE_HALFELF);
            //Neutral-Evil or Chaotic-Evil only.
            CreateSubraceAlignmentRestriction("skeleton-warrior", FALSE, FALSE, TRUE, TRUE, TRUE, FALSE);
            //:: Non-casting types only.
            CreateSubraceClassRestriction("skeleton-warrior", TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSubraceAppearance("skeleton-warrior", TIME_BOTH, APPEARANCE_TYPE_SKELETON_WARRIOR, APPEARANCE_TYPE_SKELETON_WARRIOR_1);
            CreateSubraceSpellResistance("skeleton-warrior", 5, 20);
            SetupSubraceSwitch("skeleton-warrior", "skeleton-chieftan", 25, TRUE);

                    //Skeleton-Chieftan

                    CreateSubrace(RACIAL_TYPE_HUMAN, "skeleton-chieftan", "sha_pc_skelec", "", TRUE, 2, FALSE, -2, 3, TRUE);
                    //Can also be Elf.
                    AddAdditionalBaseRaceToSubrace("skeleton-chieftan", RACIAL_TYPE_ELF);
                    //Can also be Half-Elf.
                    AddAdditionalBaseRaceToSubrace("skeleton-chieftan", RACIAL_TYPE_HALFELF);
                    //Neutral-Evil or Chaotic-Evil only.
                    CreateSubraceAlignmentRestriction("skeleton-chieftan", FALSE, FALSE, TRUE, TRUE, TRUE, FALSE);
                    //Non-casting types only.
                    CreateSubraceClassRestriction("skeleton-chieftan", TRUE, FALSE, FALSE, FALSE, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
                    //Must have atleast 4 level in Blackguard, Assasin or Weapon Master or some combination of those classes adding up 4 levels.
                    CreateSubracePrestigiousClassRestriction("skeleton-chieftan", 4, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE);
                    CreateSubraceAppearance("skeleton-chieftan", TIME_BOTH, APPEARANCE_TYPE_SKELETON_CHIEFTAIN, APPEARANCE_TYPE_SKELETON_CHIEFTAIN);
                    CreateSubraceSpellResistance("skeleton-chieftan", 5, 20);


            //Skeleton-Priest

            CreateSubrace(RACIAL_TYPE_HUMAN, "skeleton-priest", "sha_pc_skelep", "", TRUE, 2, FALSE, -2, 3, TRUE);
            //Can also be Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-priest", RACIAL_TYPE_ELF);
            //Can also be Half-Elf.
            AddAdditionalBaseRaceToSubrace("skeleton-priest", RACIAL_TYPE_HALFELF);
            //Neutral-Evil or Chaotic-Evil only.
            CreateSubraceAlignmentRestriction("skeleton-priest", FALSE, FALSE, TRUE, TRUE, TRUE, FALSE);
            //:: Druid or Cleric only.
            CreateSubraceClassRestriction("skeleton-priest", FALSE, FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
            CreateSubraceAppearance("skeleton-priest", TIME_BOTH, APPEARANCE_TYPE_SKELETON_PRIEST, APPEARANCE_TYPE_SKELETON_PRIEST);
            CreateSubraceSpellResistance("skeleton-priest", 5, 30);


       //Vampire
       //Human. Light Sensitive. Takes 2 Divine Damage while in Sunlight.
       //ECL: + 3
       //Undead
       CreateSubrace(RACIAL_TYPE_HUMAN, "vampire", "sha_pc_vamp001", "sha_subrace_vamp", TRUE, 2, FALSE, 0, 3, TRUE);
        //Can also be Elf
       AddAdditionalBaseRaceToSubrace("vampire", RACIAL_TYPE_ELF);
        //Can also be Half-Elf
       AddAdditionalBaseRaceToSubrace("vampire", RACIAL_TYPE_HALFELF);
        //Skins that are equipped at certain levels...
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp002", 5);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp003", 10);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp004", 15);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp005", 20);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp006", 25);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp007", 30);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp008", 35);
       AddAdditionalSkinsToSubrace("vampire", "sha_pc_vamp", 40);
        //Alignment Restriction: Can only be chaotic Evil.
       CreateSubraceAlignmentRestriction("vampire", FALSE, FALSE, TRUE, FALSE, FALSE, TRUE);
        //Appearance: Change the Appearance to a Vampire during night time, and revert back to normal during day time.
      CreateSubraceAppearance("vampire", TIME_NIGHT, APPEARANCE_TYPE_VAMPIRE_MALE, APPEARANCE_TYPE_VAMPIRE_FEMALE, 1);
        //Temporary Stats: Bonuses at Night time.
        //Increase Strength by 6 points, Dexterity by 4 points, Consitution by 4, Charisma by 2, and AC by 5 and AB 10 during the Night.
       struct SubraceStats VampStats1 =  CreateCustomStats(SUBRACE_STAT_MODIFIER_TYPE_POINTS, 6.0, 4.0, 4.0, 0.0, 0.0, 2.0, 5.0, 10.0);
       CreateTemporaryStatModifier("vampire", VampStats1, TIME_NIGHT);
        //Favored Class: Rogue.
       AddSubraceFavoredClass("vampire", CLASS_TYPE_ROGUE, CLASS_TYPE_ROGUE);




       //:: Zombie
       CreateSubrace(RACIAL_TYPE_ALL, "zombie", "sha_pc_zombie", "", TRUE, 2, FALSE, -1, 2, TRUE);
       CreateSubraceAppearance("zombie", TIME_BOTH, APPEARANCE_TYPE_ZOMBIE, APPEARANCE_TYPE_ZOMBIE);
}
