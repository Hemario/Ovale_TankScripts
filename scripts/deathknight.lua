local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_deathknight_blood"
    local desc = "[9.0.1] Ovale_TankScripts: DeathKnight Blood"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
# 9.0.1 (36272) BfA Blood Death Knight

# Talents
Define(antimagic_barrier_talent 11)
Define(blood_tap_talent 9)
Define(blooddrinker_talent 2)
Define(bonestorm_talent 21)
Define(consumption_talent 6)
Define(foul_bulwark_talent 7)
Define(heartbreaker_talent 1)
Define(mark_of_blood_talent 12)
Define(relish_in_blood_talent 8)
Define(tightening_grasp_talent 14)
Define(tombstone_talent 3)
Define(voracious_talent 16)

# Spells
Define(antimagic_shell 48707)
	SpellInfo(antimagic_shell cd=60 offgcd=1 duration=5)
	SpellInfo(antimagic_shell addcd=-20 addduration=2 talent=antimagic_barrier_talent specialization=blood)
Define(asphyxiate_blood 221562)
	SpellInfo(asphyxiate_blood cd=45 duration=5)
	SpellAddTargetDebuff(asphyxiate_blood asphyxiate_blood=1)
Define(blood_tap 221699)
	SpellInfo(blood_tap cd=60 runes=-1 talent=blood_tap_talent)
Define(blooddrinker 206931)
	SpellInfo(blooddrinker runes=1 runicpower=-10 cd=30 duration=3 channel=3 tick=1 talent=blooddrinker_talent)
	SpellAddTargetDebuff(blooddrinker blooddrinker=1)
Define(bonestorm 194844)
	SpellInfo(bonestorm runicpower=10 cd=60 duration=1 tick=1 talent=bonestorm_talent)
	SpellAddBuff(bonestorm bonestorm=1 talent=bonestorm_talent)
Define(consumption 274156)
	SpellInfo(consumption cd=30 talent=consumption_talent)
Define(dancing_rune_weapon 49028)
	SpellInfo(dancing_rune_weapon cd=120)
Define(death_and_decay 43265)
	SpellInfo(death_and_decay cd=30 runes=1 runicpower=-10)
Define(death_grip 49576)
	SpellInfo(death_grip cd=25)
Define(death_strike 49998)
	SpellInfo(death_strike runicpower=45)
Define(gorefiends_grasp 108199)
	SpellInfo(gorefiends_grasp cd=120)
	SpellInfo(gorefiends_grasp addcd=-30 talent=tightening_grasp_talent)
Define(heart_strike 206930)
	SpellInfo(heart_strike runes=1 runicpower=-10 duration=8)
	SpellInfo(heart_strike addrunicpower=-5 level=23)
	SpellInfo(heart_strike addrunicpower=-2 talent=heartbreaker_talent)
	SpellAddTargetDebuff(heart_strike heart_strike=1)
Define(icebound_fortitude 48792)
	SpellInfo(icebound_fortitude cd=180 offgcd=1 duration=8)
Define(mark_of_blood 206940)
	SpellInfo(mark_of_blood cd=6 duration=15 talent=mark_of_blood_talent)
	SpellAddTargetDebuff(mark_of_blood mark_of_blood=1 talent=mark_of_blood_talent)
Define(marrowrend 195182)
	SpellInfo(marrowrend runes=2 runicpower=-20)
Define(mind_freeze 47528)
	SpellInfo(mind_freeze cd=15 offgcd=1 interrupt=1)
Define(rune_tap 194679)
	SpellInfo(rune_tap cd=25 offgcd=1 runes=1 runicpower=-10 duration=4)
Define(tombstone 219809)
	SpellInfo(tombstone cd=60 duration=8 runicpower=-6 talent=tombstone_talent)
	SpellAddBuff(tombstone tombstone=1 talent=tombstone_talent)
Define(vampiric_blood 55233)
	SpellInfo(vampiric_blood cd=90 offgcd=1 duration=10)
	SpellInfo(vampiric_blood addduration=2 level=56)
	SpellAddBuff(vampiric_blood vampiric_blood=1)
Define(war_stomp 20549)
	SpellInfo(war_stomp cd=90 duration=2 offgcd=1)
	SpellAddTargetDebuff(war_stomp war_stomp=1)

# Buffs & debuffs
Define(blood_boil 50842)
	SpellInfo(blood_boil cd=7.5)
Define(blood_plague_debuff 55078)
	SpellInfo(blood_plague_debuff duration=24)
Define(blood_shield_buff 77535)
	SpellInfo(blood_shield_buff duration=10)
	SpellAddBuff(death_strike blood_shield_buff=1)
Define(bone_shield_buff 195181)
	SpellInfo(bone_shield_buff duration=30 max_stacks=10)
	SpellAddBuff(marrowrend bone_shield_buff=3)
	SpellAddBuff(tombstone bone_shield_buff=-5 talent=tombstone_talent)
Define(crimson_scourge_buff 81141)
	SpellInfo(crimson_scourge_buff duration=15)
	SpellAddBuff(death_and_decay crimson_scourge_buff=0 specialization=blood)
	SpellRequire(death_and_decay runes 0=buff,crimson_scourge_buff specialization=blood)
	SpellRequire(death_and_decay runicpower 0=buff,crimson_scourge_buff talent=blood_tap_talent specialization=blood)
	SpellRequire(death_and_decay runicpower 0=buff,crimson_scourge_buff talent=foul_bulwark_talent specialization=blood)
	SpellRequire(death_and_decay runicpower -10=buff,crimson_scourge_buff talent=relish_in_blood_talent specialization=blood)
Define(dancing_rune_weapon_buff 81256)
	SpellInfo(dancing_rune_weapon_buff duration=8)
	SpellAddBuff(dancing_rune_weapon dancing_rune_weapon_buff=1)
Define(death_and_decay_buff 188290)
	SpellInfo(death_and_decay_buff duration=10)
	SpellAddBuff(death_and_decay death_and_decay_buff=1)
Define(hemostasis_buff 273947)
	SpellInfo(hemostasis_buff duration=15 max_stacks=5)
	SpellAddBuff(death_strike hemostasis_buff=0 specialization=blood)
Define(lifeblood_buff 295137)

# Items
Define(item_battle_potion_of_stamina 163225)
Define(item_steelskin_potion 152557)
Define(item_superior_battle_potion_of_stamina 168499)
Define(item_superior_steelskin_potion 168501)

AddCheckBox(opt_interrupt L(interrupt) default specialization=blood)
AddCheckBox(opt_dispel L(dispel) default specialization=blood)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=blood)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=blood)
AddCheckBox(opt_mythic_plus_rotation L(mythic_plus_rotation) specialization=blood)

AddFunction BloodPoolingForBoneStorm
{
	Talent(bonestorm_talent) and SpellCooldown(bonestorm) < 3 and Enemies() >= 3 and RunicPower() < 100
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
	if not BuffPresent(rune_tap) and (not BuffPresent(bone_shield_buff) or RunicPower() < 30) Spell(rune_tap)
}

AddFunction BloodDefaultShortCdActions
{
	BloodHealMeShortCd()
	if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BloodHealMeShortCd
{
	if (HealthPercent() < 35) UseHealthPotions()
    if (HealthPercent() < 35) UseRacialHealActions()
}

AddFunction BloodHealMeMain
{
    if (HealthPercent() <= 75) 
    {
        if (Enemies() >= 3 and RunicPower() >= 70) Spell(bonestorm)
        if (not BloodPoolingForBoneStorm() and BloodDeathStrikeHealing() <= HealthMissing()) Spell(death_strike)
        if (HealthPercent() <= 50) Spell(death_strike)
    } 
}

AddFunction BloodDefaultMainActions
{
	# Heal
	BloodHealMeMain()
	
	AzeriteEssenceMain()
	
	# keep marrowrend up
	if (InCombat() and BuffRemaining(bone_shield_buff) < TimeToRunes(3)) Spell(marrowrend)
	# AoE
	if (Enemies() >= 3 and RunicPower() >= 100) Spell(bonestorm)
	if (Enemies() >= 3) Spell(consumption)
	# Death Strike
	if (BuffPresent(blood_shield_buff) and BuffRemaining(blood_shield_buff) < 3) Spell(death_strike)
	if (not BloodPoolingForBoneStorm() and RunicPowerDeficit() <= 20) Spell(death_strike)
	# Mark of Blood is not worth using even if it is a baseline ability
	#if (target.DebuffExpires(mark_of_blood) and target.IsTargetingPlayer()) Spell(mark_of_blood)
	# Blooddrinker
	if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)
	# Blood boil
	if (Charges(blood_boil count=0) >= 1.8) Spell(blood_boil)
	if (DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) or target.DebuffRefreshable(blood_plague_debuff)) Spell(blood_boil)
	# Marrowrend (279502 = trait Bones of the Damned)
	if (BuffStacks(bone_shield_buff) <= 7-HasAzeriteTrait(279502)-3*BuffPresent(dancing_rune_weapon_buff)) Spell(marrowrend)
	# Blood Tap
	if ((Rune() < 3) and ((Charges(blood_tap) >= 1.8) or (HealthPercent() < 75 and RunicPower() < 63))) Spell(blood_tap)
	# dump runes while keeping at most 3 runes on cooldown
	if TimeToRunes(3) < GCD()
	{
		if (Enemies() >= 3) Spell(death_and_decay)
		if (BuffStacks(bone_shield_buff) >= 6) Spell(heart_strike)
	}
	# pool runic power for emergency Death Strike
	if (RunicPower() < 45) Spell(heart_strike)
	# fillers
	if BuffPresent(dancing_rune_weapon_buff) Spell(blood_boil)
	if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
	Spell(blood_boil
    UseRacialDamageActions()
}

# Core Ability Priority List from "[8.3] Advanced Blood Death Knight M+ Guide" by Kyrasis-Stormreaver
AddFunction BloodMythicPlusMainActions
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		# Bonestorm if you are below 75% health with 3+ targets and Runic Power is above 70.
		if (HealthPercent() <= 75 and Enemies() >= 3 and RunicPower() >= 70) Spell(bonestorm)
		# Death Strike if you are below 60% Health.
		if (HealthPercent() <= 60 and not BloodPoolingForBoneStorm() and BloodDeathStrikeHealing() <= HealthMissing()) Spell(death_strike)
	}
	# Marrowrend if Bone Shield is not active or about to expire.
	if (InCombat() and BuffRemaining(bone_shield_buff) < GCD() + 2) Spell(marrowrend)
	if not BuffPresent(memory_of_lucid_dreams) and not BuffPresent(dancing_rune_weapon_buff)
	{
		# Use Crucible of Flame major essence (from SimC).
		if (target.DebuffRemaining(concentrated_flame_burn_debuff) < 2) Spell(concentrated_flame_essence)
		# Blooddrinker if Dancing Rune Weapon is not active (from SimC).
		Spell(blooddrinker)
	}
	# Blood Boil if a target does not have Blood Plague.
	if (DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) or target.DebuffRefreshable(blood_plague_debuff)) Spell(blood_boil)
	# Bonestorm with 3+ targets and Runic Power is above 100 (from SimC).
	if (not BuffPresent(dancing_rune_weapon_buff) and Enemies() >= 3 and RunicPower() >= 100) Spell(bonestorm)
	# Consumption with 3+ targets.
	if (Enemies() >= 3) Spell(consumption)
	# Death Strike when Runic Power within one Rune spent of being capped.
	if (not BloodPoolingForBoneStorm() and RunicPowerDeficit() < 10) Spell(death_strike)
	# Marrowrend if below 8 stacks of Bone Shield (below 7 with Bones of the Damned)
	if (BuffStacks(bone_shield_buff) < 8 - HasAzeriteTrait(279502) - 3 * BuffPresent(dancing_rune_weapon_buff)) Spell(marrowrend)
	# Blood Tap at less than 3 Runes and at, or close to having, 2 charges.
	# Blood Tap at less than 3 Runes on 1 charge and Runic Power is below the cost of two Death Strike minus the gain from Heart Strike.
	if ((Rune() < 3) and ((Charges(blood_tap) >= 1.8) or (HealthPercent() < 75 and RunicPower() < 63))) Spell(blood_tap)
	# Heart Strike with or when 1.5 second away from having more than 3 Runes.
	if (TimeToRunes(3) < GCD()) Spell(heart_strike)
	if not BuffPresent(memory_of_lucid_dreams)
	{
		# Death and Decay when Crimson Scourge procs with either 3+ targets or Bloody Runeblade.
		if (BuffPresent(crimson_scourge_buff) and (Enemies() >= 3 or HasAzeriteTrait(289347))) Spell(death_and_decay)
		# Blood Boil with 2 charges and less than 5 stacks of Hemostasis.
		if (Charges(blood_boil) >= 1.8 and BuffStacks(hemostasis_buff) < 5) Spell(blood_boil)
	}
	# Heart Strike with 3 Runes.
	if (Rune() >= 3) Spell(heart_strike)
	# Heart Strike with:
	#   ((Dancing Rune Weapon and less than 76 RP) or
	#    (Death and Decay with 3+ targets without Dancing Rune Weapon and less than 81 RP))
	#   and 8+ stacks of Bone Shield and 7.5+ seconds left of Bone Shield duration.
	if BuffStacks(bone_shield_buff) >= 8 and BuffRemaining(bone_shield_buff) >= 7.5
	{
		if (BuffPresent(dancing_rune_weapon_buff) and RunicPowerDeficit() > 40) Spell(heart_strike)
		if (not BuffPresent(dancing_rune_weapon_buff) and BuffPresent(death_and_decay_buff) and Enemies() >= 3 and RunicPowerDeficit() > 35) Spell(heart_strike)
	}
	if not BuffPresent(memory_of_lucid_dreams)
	{
		# Blood Boil with 1 Blood Boil charge and less than 5 stacks of Hemostasis.
		if (BuffStacks(hemostasis_buff) < 5) Spell(blood_boil)
		# Death and Decay with a Crimson Scourge proc.
		if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
	}
	# Mark of Blood wouldn't be worth using even if it was a baseline ability.
	#if (target.DebuffExpires(mark_of_blood) and target.IsTargetingPlayer()) Spell(mark_of_blood)
}

AddFunction BloodDefaultCdActions
{
	if CheckBoxOff(opt_deathknight_blood_offensive) BloodDefaultOffensiveActions()

	if (IncomingDamage(1.5 magic=1) > 0) Spell(antimagic_shell)
	if (BuffStacks(bone_shield_buff) >= 6) Spell(tombstone)
	Item(Trinket0Slot usable=1 text=13)
	Item(Trinket1Slot usable=1 text=14)
	
	AzeriteEssenceDefensiveCooldowns()
	
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
    BloodDispelActions()
    UseRacialOffensiveActions()
	AzeriteEssenceOffensiveCooldowns()
	BloodDefaultOffensiveCooldowns()
}

AddFunction BloodInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if (target.InRange(mind_freeze) and target.IsInterruptible()) Spell(mind_freeze)
		if not target.Classification(worldboss) 
		{
			if target.InRange(asphyxiate_blood) Spell(asphyxiate_blood)
			if target.InRange(death_grip) Spell(death_grip)
			if (target.Distance() < 15) Spell(gorefiends_grasp)
            UseRacialInterruptActions()
		}
	}
}

AddFunction BloodDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        UseRacialDispelActions()
    }
}

AddFunction BloodDefaultOffensiveCooldowns
{
	Spell(dancing_rune_weapon)
}

AddCheckBox(opt_deathknight_blood_aoe L(AOE) default specialization=blood)

AddIcon help=shortcd specialization=blood
{
	if not InCombat() BloodPrecombatShortCdActions()
	BloodDefaultShortCdActions()
}

AddIcon enemies=1 help=main specialization=blood
{
	if CheckBoxOn(opt_advanced_mythicplus_rotation) BloodMythicPlusMainActions()
	if CheckBoxOff(opt_advanced_mythicplus_rotation) BloodDefaultMainActions()
}

AddIcon checkbox=opt_deathknight_blood_aoe help=aoe specialization=blood
{
	if CheckBoxOn(opt_advanced_mythicplus_rotation) BloodMythicPlusMainActions()
	if CheckBoxOff(opt_advanced_mythicplus_rotation) BloodDefaultMainActions()
}

AddIcon help=cd specialization=blood
{
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