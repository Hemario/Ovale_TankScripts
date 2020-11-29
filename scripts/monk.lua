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
Include(ovale_monk_spells)

# blackout_combo_buff
    SpellAddBuff(blackout_kick blackout_combo_buff add=1 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(breath_of_fire blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(celestial_brew blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(keg_smash blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
    SpellAddBuff(tiger_palm blackout_combo_buff set=0 enabled=(HasTalent(blackout_combo_talent)))
Define(bonedust_brew 325216)
    SpellInfo(bonedust_brew cd=120 duration=10)
    SpellAddTargetDebuff(bonedust_brew bonedust_brew add=1)
Define(exploding_keg 325153)
    SpellInfo(exploding_keg cd=60 duration=3)
    SpellAddTargetDebuff(exploding_keg exploding_keg add=1)
Define(faeline_stomp 327104)
    SpellInfo(faeline_stomp cd=30 duration=30)
    SpellAddBuff(faeline_stomp faeline_stomp add=1)
Define(fallen_order 326860)
    SpellInfo(fallen_order cd=180 duration=24)
    SpellAddBuff(fallen_order fallen_order add=1)
Define(fortifying_brew_brm 115203)
    SpellInfo(fortifying_brew_brm cd=360 duration=15 gcd=0 offgcd=1)
# touch_of_death
    SpellRequire(touch_of_death unusable set=1 enabled=(not (target.Health() < Health() or (Level() >= 44 and target.HealthPercent() <= 15))))
Define(weapons_of_order 310454)
    SpellInfo(weapons_of_order cd=120 duration=30)
    SpellAddBuff(weapons_of_order weapons_of_order add=1)
Define(zen_meditation 115176)
    SpellInfo(zen_meditation cd=300 gcd=0 offgcd=1 duration=8)

AddCheckBox(opt_interrupt L(interrupt) default enabled=(Specialization(brewmaster)))
AddCheckBox(opt_dispel L(dispel) default enabled=(Specialization(brewmaster)))
AddCheckBox(opt_melee_range L(not_in_melee_range) enabled=(Specialization(brewmaster)))
AddCheckBox(opt_monk_bm_aoe L(AOE) default enabled=(Specialization(brewmaster)))
AddCheckBox(opt_monk_bm_offensive L(seperate_offensive_icon) default enabled=(Specialization(brewmaster)))
AddCheckBox(opt_use_consumables L(opt_use_consumables) default enabled=(Specialization(brewmaster)))

AddFunction BrewmasterHealMeShortCd
{
    # Use Healing Elixir proactively to prevent dropping below 50% health.
    if (HealthPercent() < 100 - 25 * (3 - SpellCharges(healing_elixir count=0))) Spell(healing_elixir)
    if (HealthPercent() < 35) UseHealthPotions()
    CovenantShortCDHealActions()
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
    # Blackout Kick right before Keg Smash to grant more Brew charges with Blackout Combo talent.
    if (HasTalent(blackout_combo_talent) and SpellCooldown(keg_smash) > GCD() and SpellCooldown(keg_smash) <= GCD() + GCDRemaining()) Spell(blackout_kick)
    Spell(keg_smash)
    # Push back the next spell if Keg Smash will be ready within the current GCD().
    unless SpellCooldown(keg_smash) <= GCDRemaining()
    {
        if (Enemies() >= 3) Spell(breath_of_fire)
        if (not HasTalent(blackout_combo_talent)) Spell(blackout_kick)
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
        if TimeToEnergy(100) < GCD() Spell(tiger_palm)
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

    Spell(fortifying_brew_brm)
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

AddIcon help=shortcd enabled=(Specialization(brewmaster))
{
    BrewmasterDefaultShortCDActions()
}

AddIcon enemies=1 help=main enabled=(Specialization(brewmaster))
{
    BrewmasterDefaultMainActions()
}

AddIcon help=aoe enabled=(CheckBoxOn(opt_monk_bm_aoe) and Specialization(brewmaster))
{
    BrewmasterDefaultAoEActions()
}

AddIcon help=cd enabled=(Specialization(brewmaster))
{
    BrewmasterDefaultCdActions()
}

AddIcon size=small enabled=(CheckBoxOn(opt_monk_bm_offensive) and Specialization(brewmaster))
{
    BrewmasterDefaultOffensiveActions()
}
]]
    OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end