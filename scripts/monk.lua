local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_monk_brewmaster"
    local desc = "[9.0.2] Ovale_TankScripts: Monk Brewmaster"
    local code = [[
# Adapted from Wowhead's "Brewmaster Monk Rotation Guide - Shadowlands 9.0.2"
#   by Llarold-Area52
# https://www.wowhead.com/brewmaster-monk-rotation-guide

Include(ovale_common)
Include(ovale_tankscripts_common)

# Talents
Define(blackout_combo_talent 22108)
Define(black_ox_brew_talent 19992)
Define(chi_burst_talent 20185)
Define(chi_wave_talent 19820)
Define(dampen_harm_talent 20175)
Define(exploding_keg_talent 22103)
Define(healing_elixir_talent 23363)
Define(rushing_jade_wind_talent 20184)
Define(spitfire_talent 22097)
Define(tiger_tail_sweep_talent 19993)

# Class Abilities
Define(black_ox_brew 115399)
    SpellInfo(black_ox_brew cd=120 gcd=0 offgcd=1 energy=-200)
    SpellRequire(black_ox_brew unusable set=1 enabled=(not HasTalent(black_ox_brew_talent)))
Define(blackout_combo_buff 228563)
    SpellInfo(blackout_combo_buff duration=15)
    SpellAddBuff(blackout_kick blackout_combo_buff add=1 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(breath_of_fire blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(celestial_brew blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(keg_smash blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(tiger_palm blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
Define(blackout_kick 205523)
    SpellInfo(blackout_kick cd=4)
Define(breath_of_fire 115181)
    SpellInfo(breath_of_fire cd=15)
Define(celestial_brew 322507)
    SpellInfo(celestial_brew cd=60)
Define(chi_burst 123986)
    SpellInfo(chi_burst cd=30)
    SpellRequire(chi_burst unusable set=1 enabled=(not HasTalent(chi_burst_talent)))
Define(chi_wave 115098)
    SpellInfo(chi_wave cd=15)
    SpellRequire(chi_wave unusable set=1 enabled=(not HasTalent(chi_wave_talent)))
Define(dampen_harm 122278)
    SpellInfo(dampen_harm cd=120 gcd=0 offgcd=1)
    SpellRequire(dampen_harm unusable set=1 enabled=(not HasTalent(dampen_harm_talent)))
Define(detox 218164)
    SpellInfo(detox cd=8)
Define(exploding_keg 325153)
    SpellInfo(exploding_keg cd=60)
    SpellAddTargetDebuff(exploding_keg exploding_keg add=1)
    SpellRequire(exploding_keg unusable set=1 enabled=(not HasTalent(exploding_keg_talent)))
Define(expel_harm 322101)
    SpellInfo(expel_harm energy=15 cd=15)
    SpellRequire(expel_harm cd add=-10 enabled=(Level() >= 43))
Define(fortifying_brew 115203)
    SpellInfo(fortifying_brew cd=360 gcd=0 offgcd=1)
Define(healing_elixir 122281)
    SpellInfo(healing_elixir charge_cd=30 gcd=0 offgcd=1)
    SpellRequire(healing_elixir unusable set=1 enabled=(not HasTalent(healing_elixir_talent)))
Define(invoke_niuzao_the_black_ox 132578)
    SpellInfo(invoke_niuzao_the_black_ox cd=180)
Define(keg_smash 121253)
    SpellInfo(keg_smash energy=40 charge_cd=8)
Define(leg_sweep 119381)
    SpellInfo(leg_sweep cd=60)
    SpellRequire(leg_sweep cd add=-10 enabled=(HasTalent(tiger_tail_sweep_talent)))
Define(paralysis 115078)
    SpellInfo(paralysis energy=20 cd=45)
    SpellRequire(paralysis cd add=-15 enabled=(Level() >= 56))
Define(purifying_brew 119582)
    SpellInfo(purifying_brew cd=1 charge_cd=20 gcd=0 offgcd=1)
    SpellRequire(purifying_brew unusable set=1 enabled=(not DebuffPresent(any_stagger_debuff)))
Define(rushing_jade_wind 116847)
    SpellInfo(rushing_jade_wind cd=6)
    SpellRequire(rushing_jade_wind unusable set=1 enabled=(not HasTalent(rushing_jade_wind_talent)))
Define(spear_hand_strike 116705)
    SpellInfo(spear_hand_strike cd=15 gcd=0 offgcd=1 interrupt=1)
Define(spinning_crane_kick 322729)
    SpellInfo(spinning_crane_kick energy=25 channel=1.5)
Define(tiger_palm 100780)
    SpellInfo(tiger_palm energy=25)
Define(touch_of_death 322109)
    SpellInfo(touch_of_death cd=180 unusable=1)
    SpellRequire(touch_of_death unusable set=0 enabled=(target.Health() < player.Health() or (Level() >= 44 and target.HealthPercent() < 15)))
Define(zen_meditation 115176)
    SpellInfo(zen_meditation cd=300 gcd=0 offgcd=1)

# Stagger
Define(heavy_stagger_debuff 124273)
    SpellInfo(heavy_stagger_debuff duration=10 tick=1)
    SpellRequire(heavy_stagger_debuff duration add=3 enabled=(talent(bob_and_weave_talent)))
Define(light_stagger_debuff 124275)
    SpellInfo(light_stagger_debuff duration=10 tick=1)
    SpellRequire(light_stagger_debuff duration add=3 enabled=(talent(bob_and_weave_talent)))
Define(moderate_stagger_debuff 124274)
    SpellInfo(moderate_stagger_debuff duration=10 tick=1)
    SpellRequire(moderate_stagger_debuff duration add=3 enabled=(talent(bob_and_weave_talent)))
SpellList(any_stagger_debuff light_stagger_debuff moderate_stagger_debuff heavy_stagger_debuff)

# Racial Abilities
Define(arcane_torrent 25046)
    SpellInfo(arcane_torrent cd=120 energy=-15)
Define(fireblood 265221)
    SpellInfo(fireblood cd=120 gcd=0 offgcd=1)
Define(quaking_palm 107079)
    SpellInfo(quaking_palm cd=120)
Define(war_stomp 20549)
    SpellInfo(war_stomp cd=90 gcd=0 offgcd=1)

# Covenant Abilities
Define(bonedust_brew 325216)
    SpellInfo(bonedust_brew cd=120)
    SpellRequire(bonedust_brew unusable set=1 enabled=(not IsCovenant(necrolord)))
Define(faeline_stomp 327104)
    SpellInfo(faeline_stomp cd=30)
    SpellRequire(faeline_stomp unusable set=1 enabled=(not IsCovenant(night_fae)))
Define(fallen_order 326860)
    SpellInfo(fallen_order cd=180)
    SpellRequire(fallen_order unusable set=1 enabled=(not IsCovenant(venthyr)))
Define(weapons_of_order 310454)
    SpellInfo(weapons_of_order cd=120)
    SpellRequire(weapons_of_order unusable set=1 enabled=(not IsCovenant(kyrian)))

AddCheckBox(opt_interrupt L(interrupt) default)
AddCheckBox(opt_dispel L(dispel) default)
AddCheckBox(opt_melee_range L(not_in_melee_range))
AddCheckBox(opt_monk_bm_aoe L(AOE) default)
AddCheckBox(opt_monk_bm_offensive L(seperate_offensive_icon) default)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default)

AddFunction BrewmasterHealMeShortCd
{
    # Use Healing Elixir proactively to prevent dropping below 50% health.
    if (HealthPercent() < 100 - 25 * (3 - SpellCharges(healing_elixir count=0))) Spell(healing_elixir)
    if (HealthPercent() < 50) Spell(expel_harm)
    if (HealthPercent() < 35) UseHealthPotions()
    CovenantShortCDHealActions()
}

AddFunction BrewmasterHealMeMain
{
    
}

AddFunction BrewmasterRangeCheck
{
    if CheckBoxOn(opt_melee_range) and not target.InRange(tiger_palm) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BrewmasterHasEnergyForKegSmash
{
    if (SpellCooldown(keg_smash) > GCDRemaining())  (Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) >= PowerCost(keg_smash))
    if (SpellCooldown(keg_smash) <= GCDRemaining()) (Energy() + EnergyRegenRate() * GCDRemaining() >= PowerCost(keg_smash))
}

AddFunction BrewmasterEnergyForKegSmashPlusFiller
{
    if (SpellCooldown(keg_smash) > GCDRemaining())  (Energy() + EnergyRegenRate() * (GCD() + SpellCooldown(keg_smash)))
    if (SpellCooldown(keg_smash) <= GCDRemaining()) (Energy() + EnergyRegenRate() * (GCD() + GCDRemaining()))
}

AddFunction BrewmasterDefaultShortCDActions
{
    # Use Black Ox Brew when Celestial Brew is on cooldown and Purifying Brew has no charges.
    if (SpellCooldown(celestial_brew) > GCD() and SpellCharges(purifying_brew count=0) < 0.75) Spell(black_ox_brew)
    # Never let Celestial Brew or Purifying Brew sit on cooldown while tanking.
    if (SpellCharges(purifying_brew count=0) > 1.8) Spell(purifying_brew)
    # Use up Purifying Brew charges if Black Ox Brew is coming off cooldown.
    if (HasTalent(black_ox_brew_talent) and SpellCooldown(black_ox_brew) < GCD()) Spell(purifying_brew)
    if BuffExpires(blackout_combo_buff) Spell(celestial_brew)
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

    # Opener
    if not InCombat()
    {
        Spell(rushing_jade_wind)
        Spell(keg_smash)
    }
    # Use the Blackout Combo buff for damage if it won't push back Keg Smash.
    if BuffPresent(blackout_combo_buff)
    {
        if (Enemies() >= 3 and not HasTalent(spitfire_talent) and BrewmasterEnergyForKegSmashPlusFiller() >= PowerCost(keg_smash)) Spell(breath_of_fire)
        if (BrewmasterEnergyForKegSmashPlusFiller() >= PowerCost(keg_smash) + PowerCost(tiger_palm)) Spell(tiger_palm)
    }
    Spell(keg_smash)
    # Push back the next spell if Keg Smash will be ready within the current GCD.
    unless SpellCooldown(keg_smash) <= GCDRemaining()
    {
        if (Enemies() >= 3) Spell(breath_of_fire)
        Spell(blackout_kick)
        Spell(faeline_stomp)
        Spell(breath_of_fire)
        Spell(rushing_jade_wind)
        Spell(chi_wave)
        Spell(chi_burst)
        if SpellCooldown(keg_smash) > GCD()
        {
            # Use Spinning Crane Kick and Tiger Palm as fillers for multi-target if it won't push back Keg Smash.
            if (Enemies() >= 3 and BrewmasterEnergyForKegSmashPlusFiller() >= PowerCost(keg_smash) + PowerCost(spinning_crane_kick)) Spell(spinning_crane_kick)
            if (Enemies() >= 2 and BrewmasterEnergyForKegSmashPlusFiller() >= PowerCost(keg_smash) + PowerCost(tiger_palm)) Spell(tiger_palm)
        }
        # Tiger Palm is a terrible offensive skill, so only use it as a filler to prevent capping energy.
        if (EnergyDeficit() <= 15) Spell(tiger_palm)
    }
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
    BrewmasterDefaultOffensiveCooldowns()
}

AddFunction BrewmasterInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(spear_hand_strike) and target.IsInterruptible() Spell(spear_hand_strike)
        if not target.Classification(worldboss)
        {
            if (target.Distance() < 5) Spell(leg_sweep)
            if (target.Distance() < 5) Spell(war_stomp)
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
        CovenantDispelActions()
    }
}

AddFunction BrewmasterDefaultOffensiveCooldowns
{
    Spell(touch_of_death)
    if (target.TimeToDie() > 25) Spell(invoke_niuzao_the_black_ox)
    Spell(bonedust_brew)
    Spell(weapons_of_order)
    Spell(fallen_order)
    Spell(invoke_niuzao_the_black_ox)
    Spell(exploding_keg)
}

AddIcon help=shortcd
{
    BrewmasterDefaultShortCDActions()
}

AddIcon enemies=1 help=main
{
    BrewmasterDefaultMainActions()
}

AddIcon help=aoe enabled=(CheckBoxOn(opt_monk_bm_aoe))
{
    BrewmasterDefaultAoEActions()
}

AddIcon help=cd
{
    BrewmasterDefaultCdActions()
}

AddIcon size=small enabled=(CheckBoxOn(opt_monk_bm_offensive))
{
    BrewmasterDefaultOffensiveActions()
}
]]
    OvaleScripts:registerScript("MONK", "brewmaster", name, desc, code, "script")
end