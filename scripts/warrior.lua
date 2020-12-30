local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_warrior_protection"
    local desc = "[9.0.2] Ovale_TankScripts: Warrior Protection"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_warrior_spells)

Define(bolster_talent 23099)
Define(booming_voice_talent 22626)
Define(devastator_talent 15774)
Define(impending_victory_talent_protection 22800)
Define(rumbling_earth_talent 22629)

Define(ancient_aftershock 325886)
    SpellInfo(ancient_aftershock cd=90)
Define(charge 100)
Define(condemn 317349)
    #max_rage doesn't work in current Ovale version
    #SpellInfo(condemn rage=20 max_rage=40)
    SpellInfo(condemn rage=20)
    SpellRequire(condemn unusable set=1 enabled=(target.healthpercent()>20 and target.healthpercent()<=80))
Define(conquerors_banner 324143)
    SpellInfo(conquerors_banner cd=180)
Define(demoralizing_shout 1160)
    SpellInfo(demoralizing_shout cd=45)
    SpellRequire(demoralizing_shout rage add=-40 enabled=(hastalent(booming_voice_talent)))
Define(devastate 20243)
    SpellRequire(devastate unusable set=1 enabled=(hastalent(devastator_talent)))
Define(execute 163201)
    #max_rage doesn't work in current Ovale version
    #SpellInfo(execute rage=20 max_rage=40)
    SpellInfo(execute rage=20)
    SpellRequire(execute unusable set=1 enabled=(target.healthpercent()>20))
    SpellRequire(execute replaced_by set=condemn enabled=(iscovenant(2)))
Define(ignore_pain 190456)
    SpellInfo(ignore_pain rage=40 cd=1 offgcd=1)
Define(impending_victory 202168)
    SpellInfo(impending_victory cd=30 rage=10)
Define(intimidating_shout 5246)
    SpellInfo(intimidating_shout cd=90 duration=8)
Define(last_stand 12975)
    SpellInfo(last_stand duration=15 cd=180)
Define(rallying_cry 97462)
    SpellInfo(rallying_cry cd=180)
    SpellAddBuff(rallying_cry rallying_cry_buff add=1)
Define(rallying_cry_buff 97463)
    SpellInfo(rallying_cry duration=10)
Define(ravager_prot 228920)
    SpellInfo(ravager_prot cd=45)
Define(revenge 6572)
    SpellInfo(revenge rage=20)
    SpellRequire(revenge rage percent=0 enabled=(buffpresent(revenge_buff)))
	SpellAddBuff(revenge revenge_buff set=0)
Define(revenge_buff 5302)
	SpellInfo(revenge_buff duration=6)
Define(shield_block 2565)
    SpellInfo(shield_block charge_cd=15 rage=30)
    SpellAddBuff(shield_block shield_block_buff add=1)
Define(shield_block_buff 132404)
    SpellInfo(shield_block_buff duration=6)
Define(shield_slam 23922)
    SpellInfo(shield_slam rage=-15 cd=9)
Define(shield_wall 871)
    SpellInfo(shield_wall cd=240)
Define(spear_of_bastion 307865)
    SpellInfo(spear_of_bastion cd=60)
Define(spell_reflection 23920)
    SpellInfo(spell_reflection cd=25 duration=6)
Define(thunder_clap 6343)
    SpellInfo(thunder_clap cd=6 rage=-5)
Define(victorious 32216)
    SpellInfo(victorious duration=20)
    SpellAddBuff(victory_rush victorious set=0)
Define(victory_rush 34428)
    SpellRequire(victory_rush replaced_by set=impending_victory enabled=(hastalent(impending_victory_talent_protection)))
    SpellRequire(victory_rush unusable set=1 enabled=(not BuffPresent(victorious)))

AddCheckBox(opt_interrupt L(interrupt) default enabled=(specialization(protection)))
AddCheckBox(opt_dispel L(dispel) default enabled=(specialization(protection)))
AddCheckBox(opt_melee_range L(not_in_melee_range) enabled=(specialization(protection)))
AddCheckBox(opt_warrior_protection_aoe L(AOE) default enabled=(specialization(protection)))
AddCheckBox(opt_use_consumables L(opt_use_consumables) default enabled=(specialization(vengeance)))
AddCheckBox(opt_warrior_protection_offensive L(seperate_offensive_icon) default enabled=(specialization(protection)))

AddFunction ProtectionHealMe
{
    if (HealthPercent() < 70) 
    {
        Spell(victory_rush)
        Spell(impending_victory)
    }
    if (HealthPercent() < 35) UseHealthPotions()
    CovenantShortCDHealActions()
}

AddFunction ProtectionGetInMeleeRange
{
    if CheckBoxOn(opt_melee_range) and not InFlightToTarget(charge) and not InFlightToTarget(intervene) and not InFlightToTarget(heroic_leap) and not target.InRange(pummel)
    {
        if target.InRange(charge) Spell(charge)
        if (target.Distance() >= 8 and target.Distance() <= 40) Spell(heroic_leap)
        Texture(misc_arrowlup help=L(not_in_melee_range))
    }
}

AddFunction ProtectionDefaultShortCDActions
{
    ProtectionHealMe()
    if IncomingPhysicalDamage(5)
        and (not Talent(bolster_talent) or not BuffPresent(last_stand)) 
        and (BuffRemaining(shield_block_buff) <= 2)
    {
        Spell(shield_block)
    }

    if (IncomingDamage(5)>0 and (Rage() >= 70 or not BuffPresent(ignore_pain))) Spell(ignore_pain)
    # range check
    ProtectionGetInMeleeRange()
}

AddFunction ProtectionDefaultMainActions
{
    if (Talent(booming_voice_talent) and RageDeficit() >= 40) Spell(demoralizing_shout)
    Spell(ravager_prot)
    Spell(dragon_roar)
    Spell(shield_slam)
    Spell(thunder_clap)
    if (RageDeficit() <= 20) Spell(execute)
    if (BuffPresent(revenge_buff) or RageDeficit() <= 20) Spell(revenge)
    if (not target.Classification(worldboss)) Spell(storm_bolt)
    Spell(devastate)
}

AddFunction ProtectionDefaultAoEActions
{
    if (Talent(booming_voice_talent) and RageDeficit() >= 40) Spell(demoralizing_shout)
    Spell(ravager_prot)
    Spell(dragon_roar)
    if (Enemies()<=2) Spell(execute)
    Spell(revenge)
    Spell(thunder_clap)
    Spell(shield_slam)
    if (not BuffPresent(shield_block_buff) and Enemies() >= 2+Talent(rumbling_earth_talent)) Spell(shockwave)
    Spell(devastate)
}

AddFunction ProtectionDefaultCdActions 
{
    if not CheckBoxOn(opt_warrior_protection_offensive) { ProtectionDefaultOffensiveActions() }
    
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)
    
    if not Talent(booming_voice_talent) Spell(demoralizing_shout)
    if not (Talent(bolster_talent) and (BuffPresent(shield_block_buff) or Spell(shield_block))) Spell(last_stand)
    Spell(shield_wall)
    if CheckBoxOn(opt_use_consumables) 
    {
        Item(item_steelskin_potion usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
    if not BuffPresent(rallying_cry_buff) Spell(rallying_cry)
}

AddFunction ProtectionDefaultOffensiveActions 
{
    ProtectionInterruptActions()
    ProtectionDispelActions()
    ProtectionDefaultOffensiveCooldowns()
}

AddFunction ProtectionInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.IsInterruptible() 
        {
            if target.InRange(pummel) Spell(pummel)
            if target.IsTargetingPlayer() Spell(spell_reflection)
        }
        if not target.Classification(worldboss) 
        {
            if target.InRange(storm_bolt) Spell(storm_bolt)
            if (target.Distance() < 10) Spell(shockwave)
            if target.InRange(quaking_palm) Spell(quaking_palm)
            if (target.Distance() < 5) Spell(war_stomp)
            if target.InRange(intimidating_shout) Spell(intimidating_shout)
        }
    }
}

AddFunction ProtectionDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if Spell(arcane_torrent) and target.HasDebuffType(magic) Spell(arcane_torrent)
        if Spell(fireblood) and player.HasDebuffType(poison disease curse magic) Spell(fireblood)
        CovenantDispelActions()
    }
}

AddFunction ProtectionDefaultOffensiveCooldowns
{
    if RageDeficit() >= 20 Spell(avatar)
    Spell(spear_of_bastion)
    Spell(conquerors_banner)
    Spell(ancient_aftershock)
}

AddIcon help=shortcd enabled=(specialization(protection))
{
    ProtectionDefaultShortCDActions()
}

AddIcon enemies=1 help=main enabled=(specialization(protection))
{
    ProtectionDefaultMainActions()
}

AddIcon help=aoe enabled=(checkboxon(opt_warrior_protection_aoe) and specialization(protection))
{
    ProtectionDefaultAoEActions()
}

AddIcon help=cd enabled=(specialization(protection))
{
    ProtectionDefaultCdActions()
}

AddIcon size=small enabled=(checkboxon(opt_warrior_protection_offensive) and specialization(protection))
{
    ProtectionDefaultOffensiveActions()
}
]]
    OvaleScripts:RegisterScript("WARRIOR", "protection", name, desc, code, "script")
end
