local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_monk_brewmaster"
    local desc = "[8.2.0] Ovale_TankScripts: Monk Brewmaster"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_monk_spells)

Define(hot_trub 202126)

AddCheckBox(opt_interrupt L(interrupt) default specialization=brewmaster)
AddCheckBox(opt_dispel L(dispel) default specialization=brewmaster)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=brewmaster)
AddCheckBox(opt_monk_bm_aoe L(AOE) default specialization=brewmaster)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=brewmaster)

AddFunction BrewmasterHealMeShortCd
{
    unless(DebuffPresent(healing_immunity_debuff)) 
    {
        if (HealthPercent() < 35) 
        {
            Spell(healing_elixir)
            Spell(expel_harm)
        }
        if (HealthPercent() <= 100 - (15 * 2.6)) Spell(healing_elixir)
        if (HealthPercent() < 35) UseHealthPotions()
    }
}

AddFunction BrewmasterHealMeMain
{
    unless(DebuffPresent(healing_immunity_debuff)) 
    {
    }
}

AddFunction StaggerPercentage
{
    StaggerRemaining() / MaxHealth() * 100
}

AddFunction BrewmasterRangeCheck
{
    if CheckBoxOn(opt_melee_range) and not target.InRange(tiger_palm) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BrewmasterDefaultShortCDActions
{
    # keep ISB up always when taking dmg
    if ((BaseDuration(light_stagger_debuff)-DebuffRemaining(any_stagger_debuff)<3 or target.IsTargetingPlayer()) and BuffExpires(ironskin_brew_buff 3) and BuffExpires(blackout_combo_buff)) Spell(ironskin_brew text=min)
    
    # keep stagger below 100% (70% when in a party, 30% when BOB is up)
    if (StaggerPercentage() >= 100 or (StaggerPercentage() >= 70 and not UnitInRaid()) or (StaggerPercentage() >= 30 and Talent(black_ox_brew_talent) and SpellCooldown(black_ox_brew) <= 0)) Spell(purifying_brew)
    # use black_ox_brew when at 0 charges and low energy (or in an emergency)
    if (Spell(black_ox_brew) and SpellCharges(ironskin_brew count=0) <= 0.75)
    {
        #black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
        if IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) Spell(black_ox_brew)
        #black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
        if Energy() < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 Spell(black_ox_brew)
    }
    
    # heal me
    BrewmasterHealMeShortCd()
    # Guard
    Spell(guard)
    # range check
    BrewmasterRangeCheck()

    unless StaggerPercentage() > 100
    {
        # purify heavy stagger when we have enough ISB
        if (StaggerPercentage() >= 60 and (BuffRemaining(ironskin_brew_buff) >= 2*BaseDuration(ironskin_brew_buff))) Spell(purifying_brew)

        # always bank 1 charge
        unless (SpellCharges(ironskin_brew) <= 1)
        {
            # Purify with hot trub
            if (StaggerPercentage() >= 30 and SpellKnown(hot_trub)) Spell(purifying_brew) 
            # keep ISB rolling
            if BuffRemaining(ironskin_brew_buff) < DebuffRemaining(any_stagger_debuff) and BuffExpires(blackout_combo_buff) Spell(ironskin_brew)
            # Purify lower stagger amounts when we can
            if (StaggerPercentage() >= 70 - (SpellCharges(ironskin_brew count=0)-2) * 15) Spell(purifying_brew)
            
            # never be at (almost) max charges 
            unless (SpellFullRecharge(ironskin_brew) > 3)
            {
                if (StaggerPercentage() >= 30 or Talent(special_delivery_talent) or SpellKnown(hot_trub)) Spell(purifying_brew text=max)
                if (BuffRemaining(ironskin_brew_buff) < 2*BaseDuration(ironskin_brew_buff)-2 and BuffExpires(blackout_combo_buff)) Spell(ironskin_brew text=max)
            }
        }
    }
}

AddFunction BrewmasterDefaultMainActions
{
    BrewmasterHealMeMain()
    
    if (BuffPresent(blackout_combo_buff)) Spell(tiger_palm)
    if (Enemies() > 1 or not InCombat()) Spell(keg_smash)
    Spell(blackout_strike)
    Spell(keg_smash)
    
    if (PreviousGCDSpell(blackout_strike) or PreviousGCDSpell(blackout_strike count=2)) 
    {
        AzeriteEssenceMain()
        if (target.DebuffPresent(keg_smash)) Spell(breath_of_fire)
        if (Energy()+EnergyRegenRate()*GCDRemaining() >= 100) Spell(tiger_palm)
        if (BuffRemaining(rushing_jade_wind_buff)<GCD()+GCDRemaining()) Spell(rushing_jade_wind)
        Spell(chi_burst)
        Spell(chi_wave)
        if (SpellCooldown(keg_smash) > GCD() and (Energy()+EnergyRegenRate()*(SpellCooldown(keg_smash)+GCDRemaining()+GCD())) > PowerCost(keg_smash)+PowerCost(tiger_palm)) Spell(tiger_palm)
        Spell(rushing_jade_wind)
        Spell(breath_of_fire)
    }
}

AddFunction BrewmasterDefaultAoEActions
{
    BrewmasterHealMeMain()
    
    if(Enemies() < 3) BrewmasterDefaultMainActions()
    unless(Enemies() < 3) 
    {
        Spell(keg_smash)
        Spell(breath_of_fire)
        if (BuffRemaining(rushing_jade_wind_buff)<GCD()+GCDRemaining()) Spell(rushing_jade_wind)
        Spell(chi_burst)
        if (BuffPresent(blackout_combo_buff)) Spell(tiger_palm)
        AzeriteEssenceMain()
        Spell(blackout_strike)
        Spell(chi_wave)
        if (SpellCooldown(keg_smash) > GCD() and (Energy()+EnergyRegenRate()*(SpellCooldown(keg_smash)+GCDRemaining()+GCD())) > PowerCost(keg_smash)+PowerCost(tiger_palm)) Spell(tiger_palm)
        Spell(rushing_jade_wind)
        Spell(arcane_pulse)
    }
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
    UseRacialSurvivalActions()
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
            if target.InRange(quaking_palm) Spell(quaking_palm)
            if target.Distance(less 5) Spell(war_stomp)
            if target.InRange(paralysis) Spell(paralysis)
        }
    }
}

AddFunction BrewmasterDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if Spell(arcane_torrent_chi) and target.HasDebuffType(magic) Spell(arcane_torrent_chi)
        if player.HasDebuffType(poison disease) Spell(detox)
        if Spell(fireblood) and player.HasDebuffType(poison disease curse magic) Spell(fireblood)
    }
}

AddFunction BrewmasterDefaultOffensiveCooldowns
{
    if not PetPresent(name=Niuzao) Spell(invoke_niuzao_the_black_ox)
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