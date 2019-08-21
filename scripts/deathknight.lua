local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_deathknight_blood"
    local desc = "[8.2.0] Ovale_TankScripts: DeathKnight Blood"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_deathknight_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=blood)
AddCheckBox(opt_dispel L(dispel) default specialization=blood)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=blood)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=blood)

AddFunction BloodPoolingForBoneStorm
{
    Talent(bonestorm_talent) and SpellCooldown(bonestorm) < 3 and Enemies()>=3 and RunicPower() < 100
}

AddFunction BloodDeathStrikeHealing
{
    if (IncomingDamage(5) / 4 > MaxHealth() / 100 * 7) IncomingDamage(5) / 4
    MaxHealth() / 100 * 7
}

AddFunction BloodDefaultShortCDActions
{
    BloodHealMeShortCd()
    if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
    if not BuffPresent(rune_tap_buff) Spell(rune_tap)
}

AddFunction BloodHealMeShortCd
{
    unless(DebuffPresent(healing_immunity_debuff)) 
    {
        if (HealthPercent() < 35) UseHealthPotions()
    }
}

AddFunction BloodHealMeMain
{
    unless(DebuffPresent(healing_immunity_debuff)) 
    {
        if (HealthPercent() <= 75) 
        {
            if (Enemies() >= 3 and RunicPower() >= 70) Spell(bonestorm)
            if (not BloodPoolingForBoneStorm() and BloodDeathStrikeHealing() <= HealthMissing()) Spell(death_strike)
            if (HealthPercent() <= 50) Spell(death_strike)
        } 
    }
}

AddFunction BloodDefaultMainActions
{
    # Heal
    BloodHealMeMain()
    
    AzeriteEssenceMain()
    
    # keep marrowrend up
    if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
    # AoE
    if (Enemies() >= 3 and RunicPower() >= 100) Spell(bonestorm)
    if (Enemies() >= 3) Spell(consumption)
    # Death Strike
    if (BuffPresent(blood_shield_buff) and BuffExpires(blood_shield_buff 3)) Spell(death_strike)
    if (not BloodPoolingForBoneStorm() and RunicPowerDeficit() <= 20) Spell(death_strike)
    # Mark of Blood
    if (target.BuffExpires(mark_of_blood_debuff) and target.IsTargetingPlayer()) Spell(mark_of_blood)
    # Blooddrinker
    if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)
    # Blood boil
    if (Charges(blood_boil count=0) >= 1.8) Spell(blood_boil)
    if (DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) or target.DebuffRefreshable(blood_plague_debuff)) Spell(blood_boil)
    # Marrowrend (279502 = trait Bones of the Damned)
    if (BuffStacks(bone_shield_buff) <= 7-HasAzeriteTrait(279502)-3*BuffPresent(dancing_rune_weapon_buff)) Spell(marrowrend)
    # rune strike
    if (SpellCharges(rune_strike) == SpellMaxCharges(rune_strike) and Rune() <= 3) Spell(rune_strike)
    # dump runes
    if Rune() >= 3 and Enemies() >= 3 Spell(death_and_decay)
    if TimeToRunes(3) < GCD() or RunicPower() < 45 Spell(heart_strike)
    # fillers
    if BuffPresent(dancing_rune_weapon_buff) Spell(blood_boil)
    if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
    if TimeToRunes(3) < GCD() or BuffStacks(bone_shield_buff) > 6 Spell(heart_strike)
    Spell(blood_boil)
    Spell(rune_strike)
}

AddFunction BloodDefaultCdActions
{
    if not CheckBoxOn(opt_deathknight_blood_offensive) { BloodDefaultOffensiveActions() }

    if IncomingDamage(1.5 magic=1) > 0 spell(antimagic_shell)
    Spell(consumption)
    if (BuffStacks(bone_shield_buff) >= 6) Spell(tombstone)
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)
    
    AzeriteEssenceDefensiveCooldowns()
    
    Spell(vampiric_blood)
    Spell(icebound_fortitude)
    if CheckBoxOn(opt_use_consumables) 
    {
        Item(item_steelskin_potion usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
    UseRacialSurvivalActions()
}

AddFunction BloodDefaultOffensiveActions
{
    BloodInterruptActions()
    BloodDispelActions()
    AzeriteEssenceOffensiveCooldowns()
    BloodDefaultOffensiveCooldowns()
}

AddFunction BloodInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(mind_freeze) and target.IsInterruptible() Spell(mind_freeze)
        if not target.Classification(worldboss) 
        {
            if target.InRange(asphyxiate_blood) Spell(asphyxiate_blood)
            if target.InRange(death_grip) Spell(death_grip)
            if target.Distance(less 15) Spell(gorefiends_grasp)
            if target.Distance(less 5) Spell(war_stomp)
        }
    }
}

AddFunction BloodDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if Spell(arcane_torrent_runicpower) and target.HasDebuffType(magic) Spell(arcane_torrent_runicpower)
    }
}

AddFunction BloodDefaultOffensiveCooldowns
{
    Spell(dancing_rune_weapon)
}

AddCheckBox(opt_deathknight_blood_aoe L(AOE) default specialization=blood)

AddIcon help=shortcd specialization=blood
{
    BloodDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=blood
{
    BloodDefaultMainActions()
}

AddIcon checkbox=opt_deathknight_blood_aoe help=aoe specialization=blood
{
    BloodDefaultMainActions()
}

AddIcon help=cd specialization=blood
{
    #if not InCombat() ProtectionPrecombatCdActions()
    BloodDefaultCdActions()
}

AddCheckBox(opt_deathknight_blood_offensive L(seperate_offensive_icon) default specialization=blood)
AddIcon checkbox=opt_deathknight_blood_offensive size=small specialization=blood
{
    BloodDefaultOffensiveActions()
}
]]
    OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end