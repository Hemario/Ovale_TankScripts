local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_monk_brewmaster"
    local desc = "[9.0.1] Ovale_TankScripts: Monk Brewmaster"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_monk_spells)

Define(blackout_combo_buff 228563)
    SpellInfo(blackout_combo_buff duration=15)
    SpellAddBuff(blackout_kick blackout_combo_buff=1)
    SpellAddBuff(breath_of_fire blackout_combo_buff=0)
    SpellAddBuff(celestial_brew blackout_combo_buff=0)
    SpellAddBuff(keg_smash blackout_combo_buff=0)
    SpellAddBuff(tiger_palm blackout_combo_buff=0)
Define(blackout_combo_talent 21)
Define(expel_harm 322101)
Define(fortifying_brew 115203)
    SpellInfo(fortifying_brew cd=300 duration=15 gcd=0 offgcd=1)
Define(touch_of_death_brm 322109)
Define(zen_meditation 115176)
	SpellInfo(zen_meditation cd=300 gcd=0 offgcd=1 duration=8)

AddCheckBox(opt_interrupt L(interrupt) default specialization=brewmaster)
AddCheckBox(opt_dispel L(dispel) default specialization=brewmaster)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=brewmaster)
AddCheckBox(opt_monk_bm_aoe L(AOE) default specialization=brewmaster)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=brewmaster)

AddFunction BrewmasterHealMeShortCd
{
    if (HealthPercent() < 35) 
    {
        Spell(healing_elixir)
    }
    if (HealthPercent() <= 100 - (15 * 2.6)) Spell(healing_elixir)
    if (HealthPercent() < 35) UseHealthPotions()
}

AddFunction BrewmasterHealMeMain
{
    if (HealthPercent() < 50)
    {
        Spell(expel_harm)
    }
}

AddFunction BrewmasterRangeCheck
{
    if CheckBoxOn(opt_melee_range) and not target.InRange(tiger_palm) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BrewmasterDefaultShortCDActions
{
    # keep purifying brew on cooldown
    if (SpellCharges(purifying_brew count=0)>1.8) Spell(purifying_brew)
    # use celestial_brew on cooldown
    if BuffExpires(blackout_combo_buff) Spell(celestial_brew)
    # use black_ox_brew when at 0 charges and low energy (or in an emergency)
    if (Spell(black_ox_brew) and SpellCharges(purifying_brew count=0) <= 0.5)
    {
        #black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
        if IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) Spell(black_ox_brew)
        #black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
        if Energy() < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 Spell(black_ox_brew)
    }
    
    # heal me
    BrewmasterHealMeShortCd()
    # Purify on red stagger
    if (StaggerPercent() > 70) Spell(purifying_brew)
    # range check
    BrewmasterRangeCheck()
}

AddFunction BrewmasterDefaultMainActions
{
    BrewmasterHealMeMain()
    
    if (Enemies()>1 or not InCombat()) Spell(keg_smash)
    if (BuffPresent(blackout_combo_buff)) Spell(tiger_palm)
    if (SpellCount(expel_harm)>4) Spell(expel_harm)
    if (BuffExpires(blackout_combo_buff)) Spell(blackout_kick)
    Spell(keg_smash)
    AzeriteEssenceMain()
    if (SpellCount(expel_harm)>=3) Spell(expel_harm)
    if (not BuffPresent(rushing_jade_wind)) Spell(rushing_jade_wind)
    Spell(breath_of_fire)
    Spell(chi_burst)
    Spell(chi_wave)
    if (SpellCount(expel_harm)>=2) Spell(expel_harm)
    if (SpellCooldown(keg_smash) > GCD() and (Energy()+EnergyRegenRate()*(SpellCooldown(keg_smash)+GCDRemaining()+GCD())) > PowerCost(keg_smash)+PowerCost(tiger_palm)) 
    {
        if (Enemies()>= 3) Spell(spinning_crane_kick)
        if (not HasTalent(blackout_combo_talent)) Spell(tiger_palm)
    }
    Spell(rushing_jade_wind)
}

AddFunction BrewmasterDefaultAoEActions
{
    BrewmasterDefaultMainActions()
}

AddFunction BrewmasterDefaultCdActions 
{
    if not CheckBoxOn(opt_monk_bm_offensive) { BrewmasterDefaultOffensiveActions() }
    
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)
    
    AzeriteEssenceDefensiveCooldowns()
    
    Spell(fortifying_brew)
    Spell(dampen_harm)
    
    if CheckBoxOn(opt_use_consumables) 
    {
        Item(item_battle_potion_of_agility usable=1)
        Item(item_steelskin_potion usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
    
    Spell(zen_meditation)
}

AddFunction BrewmasterDefaultOffensiveActions
{
    BrewmasterInterruptActions()
    BrewmasterDispelActions()
    AzeriteEssenceOffensiveCooldowns()
    BrewmasterDefaultOffensiveCooldowns()
}

AddFunction BrewmasterInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(spear_hand_strike) and target.IsInterruptible() Spell(spear_hand_strike)
        if not target.Classification(worldboss) 
        {
            if target.Distance(less 5) Spell(leg_sweep)
            if target.Distance(less 5) Spell(war_stomp)
            if target.InRange(quaking_palm) Spell(quaking_palm)
            if target.InRange(paralysis) Spell(paralysis)
        }
    }
}

AddFunction BrewmasterDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if Spell(arcane_torrent) and target.HasDebuffType(magic) Spell(arcane_torrent)
        if player.HasDebuffType(poison disease) Spell(detox)
        if Spell(fireblood) and player.HasDebuffType(poison disease curse magic) Spell(fireblood)
    }
}

AddFunction BrewmasterDefaultOffensiveCooldowns
{
    if target.HealthPercent() <= 15 Spell(touch_of_death_brm)
    Spell(invoke_niuzao_the_black_ox)
}

AddIcon help=shortcd specialization=brewmaster
{
    BrewmasterDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=brewmaster
{
    BrewmasterDefaultMainActions()
}

AddIcon checkbox=opt_monk_bm_aoe help=aoe specialization=brewmaster
{
    BrewmasterDefaultAoEActions()
}

AddIcon help=cd specialization=brewmaster
{
    BrewmasterDefaultCdActions()
}

AddCheckBox(opt_monk_bm_offensive L(seperate_offensive_icon) default specialization=brewmaster)
AddIcon checkbox=opt_monk_bm_offensive size=small specialization=brewmaster
{
    BrewmasterDefaultOffensiveActions()

}
]]
    OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end