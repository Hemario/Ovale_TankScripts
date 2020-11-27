local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_deathknight_blood"
    local desc = "[9.0.2] Ovale_TankScripts: Death Knight Blood"
    local code = [[
# Adapted from Kyrasis's "Advanced Blood Death Knight Guide for M+"

Include(ovale_tankscripts_common)
Include(ovale_deathknight_spells)

# Talents
Define(antimagic_barrier_talent 11)
Define(relish_in_blood_talent 8)
Define(tightening_grasp_talent 14)
Define(voracious_talent 16)

# Spells
Define(antimagic_shell 48707)
    SpellInfo(antimagic_shell cd=60 offgcd=1 duration=5)
    SpellRequire(antimagic_shell cd add=-20 enabled=(HasTalent(antimagic_barrier_talent)))
    SpellRequire(antimagic_shell duration add=2 enabled=(HasTalent(antimagic_barrier_talent)))
Define(blood_tap 221699)
    SpellInfo(blood_tap cd=60 runes=-1)
Define(death_grip 49576)
    SpellInfo(death_grip cd=25)
Define(death_strike_blood 49998)
    SpellInfo(death_strike_blood runicpower=45)
Define(deaths_due 324128)
    SpellInfo(deaths_due cd=30 runes=1 runicpower=-10)
    SpellRequire(death_and_decay replaced_by set=deaths_due enabled=(SpellKnown(deaths_due)))
Define(gorefiends_grasp 108199)
    SpellInfo(gorefiends_grasp cd=120)
    SpellRequire(gorefiends_grasp cd add=-30 enabled=(HasTalent(tightening_grasp_talent)))
Define(icebound_fortitude 48792)
    SpellInfo(icebound_fortitude cd=180 offgcd=1 duration=8)
Define(mark_of_blood 206940)
    SpellInfo(mark_of_blood cd=6 duration=15)
    SpellAddTargetDebuff(mark_of_blood mark_of_blood add=1)
Define(rune_tap 194679)
    SpellInfo(rune_tap cd=25 offgcd=1 runes=1 runicpower=-10 duration=4)
Define(swarming_mist 311648)
    SpellInfo(swarming_mist cd=60 runes=1 runicpower=-10 duration=8)
    SpellAddBuff(swarming_mist swarming_mist add=1)

# Buffs & debuffs
Define(blood_plague_debuff 55078)
    SpellInfo(blood_plague_debuff duration=24)
Define(blood_shield_buff 77535)
    SpellInfo(blood_shield_buff duration=10)
    SpellAddBuff(death_strike_blood blood_shield_buff add=1)
# bone_shield
    SpellAddBuff(marrowrend bone_shield add=3)
    SpellAddBuff(tombstone bone_shield add=-5)
# crimson_scourge_buff
    SpellAddBuff(death_and_decay crimson_scourge_buff set=0)
    SpellRequire(death_and_decay runes set=0 enabled=(BuffPresent(crimson_scourge_buff)))
    SpellRequire(death_and_decay runicpower set=0 enabled=(BuffPresent(crimson_scourge_buff) and not HasTalent(relish_in_blood_talent)))
    SpellRequire(death_and_decay runicpower add=-10 enabled=(BuffPresent(crimson_scourge_buff) and HasTalent(relish_in_blood_talent)))
    SpellAddBuff(deaths_due crimson_scourge_buff set=0)
    SpellRequire(deaths_due runes set=0 enabled=(BuffPresent(crimson_scourge_buff)))
    SpellRequire(deaths_due runicpower set=0 enabled=(BuffPresent(crimson_scourge_buff) and not HasTalent(relish_in_blood_talent)))
    SpellRequire(deaths_due runicpower add=-10 enabled=(BuffPresent(crimson_scourge_buff) and HasTalent(relish_in_blood_talent)))
Define(death_and_decay_buff 188290)
    SpellInfo(death_and_decay_buff duration=10 tick=1)
    SpellAddBuff(death_and_decay death_and_decay_buff add=1)
Define(deaths_due_buff 315442)
    SpellInfo(deaths_due_buff duration=10 tick=1)
    SpellAddBuff(deaths_due deaths_due_buff add=1)
Define(deaths_due_debuff 324164)
    SpellInfo(deaths_due_debuff duration=12)
    SpellAddTargetDebuff(deaths_due deaths_due_debuff add=1)
# hemostasis_buff
    SpellAddBuff(death_strike_blood hemostasis_buff set=0)

# Items
Define(item_battle_potion_of_stamina 163225)
Define(item_steelskin_potion 152557)
Define(item_superior_battle_potion_of_stamina 168499)
Define(item_superior_steelskin_potion 168501)

AddCheckBox(opt_interrupt L(interrupt) default enabled=(Specialization(blood)))
AddCheckBox(opt_melee_range L(not_in_melee_range) enabled=(Specialization(blood)))
AddCheckBox(opt_use_consumables L(opt_use_consumables) default enabled=(Specialization(blood)))

AddFunction BloodPoolingForBoneStorm
{
    Talent(bonestorm_talent) and SpellCooldown(bonestorm) < 3 and Enemies() >= 3 and not RunicPower() > 90
}

AddFunction BloodDeathStrikeMinHealing
{
    MaxHealth() * (7 + 3 * Talent(voracious_talent)) / 100
}

AddFunction BloodDeathStrikeBaseHealing
{
    if (IncomingDamage(5) / 4 > BloodDeathStrikeMinHealing()) IncomingDamage(5) / 4
    BloodDeathStrikeMinHealing()
}

AddFunction BloodDeathStrikeHealing
{
    # Death Strike healing is increased by both Voracious and Hemostatis talents.
    BloodDeathStrikeBaseHealing() * ((100 + 20 * Talent(voracious_talent)) / 100) * ((100 + 8 * BuffStacks(hemostasis_buff)) / 100)
}

AddFunction BloodPrecombatShortCdActions
{
    # Only Rune Tap if Bone Shield is down or Runic Power is low.
    if not BuffPresent(rune_tap) and (not BuffPresent(bone_shield) or RunicPower() < 30) Spell(rune_tap)
}

AddFunction BloodDefaultShortCdActions
{
    BloodHealMeShortCd()

    if Rune() < 3
    {
        # Blood Tap if you have 2 charges, or are less than 5 seconds away from 2 charges of Blood Tap, and you have less than 3 Runes.
        if (Charges(blood_tap) > 1.9) Spell(blood_tap)
        # Blood Tap if you have less than 3 Runes and less than 63 RP (57 RP with Bryndaor’s Might equipped).
        if (RunicPowerDeficit() > 63) Spell(blood_tap)
    }

    if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike_blood) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BloodHealMeShortCd
{
    if (HealthPercent() < 35) UseHealthPotions()
}

AddFunction BloodHealMeMain
{
    if (HealthPercent() <= 60)
    {
        if Enemies() >= 3
        {
            # [*] Bonestorm if you are below 60% health with 3+ targets and Runic Power is above 90 for full healing ticks.
            if (RunicPower() > 90) Spell(bonestorm)
            # [*] Consumption with 3+ targets.
            Spell(consumption)
        }
        # Death Strike if you are below 60% Health.
        if (not BloodPoolingForBoneStorm() and BloodDeathStrikeHealing() <= HealthMissing()) Spell(death_strike_blood)
    }
}

AddFunction BloodDefaultMainActions
{
    BloodHealMeMain()

    # Marrowrend if Bone Shield is not active or about to expire.
    if (InCombat() and BuffRemaining(bone_shield) < GCD() + 2) Spell(marrowrend)
    # [*] Blooddrinker when closing with the boss on the opener.
    if (not Incombat() and not BuffPresent(dancing_rune_weapon_buff)) Spell(blooddrinker)
    # (Venthyr) Swarming Mist with less than 67 RP (61 RP with Bryndaor’s Might equipped).
    if (RunicPowerDeficit() > 59) Spell(swarming_mist)
    # Blood Boil if a target does not have Blood Plague.
    if (DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) or target.DebuffRefreshable(blood_plague_debuff)) Spell(blood_boil)
    # (Kyrian) Shackle the Unworthy (with Combat Meditation enabled).
    # (Night Fae) Death and Decay when the duration of the Death’s Due buff/debuff is about to expire, but with enough remaining time to Heart Strike.
    if (BuffRemaining(deaths_due_buff) < 3 and target.DebuffRemaining(deaths_due_debuff) > 3) Spell(deaths_due)
    # (Night Fae) Heart Strike:
    #   while in Death and Decay when the duration of the Death’s Due buff/debuff is about to expire or
    #   (the duration of our Death and Decay ground effect is about to expire and
    #       the Death’s Due buff/debuff won’t outlast the Death and Decay by at least ~9 seconds).
    if BuffPresent(deaths_due_buff)
    {
        if (target.DebuffRemaining(deaths_due_debuff) < 2) Spell(heart_strike)
        if (BuffRemaining(deaths_due_buff) < 3 and (target.DebuffRemaining(deaths_due_debuff) - BuffRemaining(deaths_due_buff) < 9)) Spell(heart_strike)
    }
    # Death Strike when Runic Power is above 105 (121 with Rune of Hysteria).
    if (not BloodPoolingForBoneStorm() and RunicPowerDeficit() < 20) Spell(death_strike_blood)
    # Marrowrend if below 8 stacks of Bone Shield.
    if (BuffStacks(bone_shield) < 8 - 3 * BuffPresent(dancing_rune_weapon_buff)) Spell(marrowrend)
    # Heart Strike with, or when 1.5 second away from, having more than 3 Runes.
    if (TimeToRunes(3) < GCD()) Spell(heart_strike)
    # Death and Decay when Crimson Scourge procs with 3+ targets or Night Fae.
    if BuffPresent(crimson_scourge_buff) and Enemies() >= 3
    {
        Spell(deaths_due)
        Spell(death_and_decay)
    }
    # Blood Boil with 2 Blood Boil charges and less than 5 stacks of Hemostasis.
    if (Charges(blood_boil) >= 1.8 and BuffStacks(hemostasis_buff) < 5) Spell(blood_boil)
    # Heart Strike with 3 Runes.
    if (Rune() >= 3) Spell(heart_strike)
    # Heart Strike with:
    #   (([Dancing Rune Weapon] and less than 76 RP (86 RP with [Rune of Hysteria])) or
    #    ([Death and Decay] with 3+ targets without [Dancing Rune Weapon] and less than 81 RP (92 RP with [Rune of Hysteria])))
    #   and 8+ stacks of Bone Shield and 7.5+ seconds left of Bone Shield duration.
    if BuffStacks(bone_shield) >= 8 and BuffRemaining(bone_shield) >= 7.5
    {
        if (BuffPresent(dancing_rune_weapon_buff) and RunicPowerDeficit() > 50) Spell(heart_strike)
        if (not BuffPresent(dancing_rune_weapon_buff) and BuffPresent(death_and_decay_buff) and Enemies() >= 3 and RunicPowerDeficit() > 40) Spell(heart_strike)
    }
    # Blood Boil with 1 charge and less than 5 stacks of Hemostasis.
    if (BuffStacks(hemostasis_buff) < 5) Spell(blood_boil)
    # Death and Decay when Crimson Scourge procs.
    if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)

    # [*] Fillers that don't consume Runes or Runic Power.
    if (target.DebuffExpires(mark_of_blood) and target.IsTargetingPlayer()) Spell(mark_of_blood)
    if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)
    Spell(consumption)
}

AddFunction BloodDefaultCdActions
{
    if CheckBoxOff(opt_deathknight_blood_offensive) BloodDefaultOffensiveActions()

    if (IncomingDamage(1.5 magic=1) > 0) Spell(antimagic_shell)
    if (BuffStacks(bone_shield) >= 6) Spell(tombstone)
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)

    Spell(vampiric_blood)
    Spell(icebound_fortitude)
    if CheckBoxOn(opt_use_consumables)
    {
        Item(item_superior_steelskin_potion usable=1)
        Item(item_steelskin_potion usable=1)
        Item(item_superior_battle_potion_of_stamina usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
}

AddFunction BloodDefaultOffensiveActions
{
    BloodInterruptActions()
    BloodDefaultOffensiveCooldowns()
}

AddFunction BloodInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if (target.InRange(mind_freeze) and target.IsInterruptible()) Spell(mind_freeze)
        if not target.Classification(worldboss)
        {
            if target.InRange(asphyxiate) Spell(asphyxiate)
            if target.InRange(death_grip) Spell(death_grip)
            if (target.Distance() < 15) Spell(gorefiends_grasp)
            if (target.Distance() < 5) Spell(war_stomp)
        }
    }
}

AddFunction BloodDefaultOffensiveCooldowns
{
    Spell(dancing_rune_weapon)
}

AddCheckBox(opt_deathknight_blood_aoe L(AOE) default enabled=(Specialization(blood)))

AddIcon help=shortcd enabled=(Specialization(blood))
{
    if not InCombat() BloodPrecombatShortCdActions()
    BloodDefaultShortCdActions()
}

AddIcon enemies=1 help=main enabled=(Specialization(blood))
{
    BloodDefaultMainActions()
}

AddIcon help=aoe enabled=(CheckBoxOn(opt_deathknight_blood_aoe) and Specialization(blood))
{
    BloodDefaultMainActions()
}

AddIcon help=cd enabled=(Specialization(blood))
{
    BloodDefaultCdActions()
}

AddCheckBox(opt_deathknight_blood_offensive L(seperate_offensive_icon) default enabled=(Specialization(blood)))
AddIcon help=smallcd size=small enabled=(CheckBoxOn(opt_deathknight_blood_offensive) and Specialization(blood))
{
    BloodDefaultOffensiveActions()
}
]]
    OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end