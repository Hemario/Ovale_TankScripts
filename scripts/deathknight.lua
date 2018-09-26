local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
	local name = "icyveins_deathknight_blood"
	local desc = "[8.0.1] Icy-Veins: DeathKnight Blood"
	local code = [[

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=blood)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=blood)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=blood)

AddFunction BloodDeathStrikeHealing
{
	if (IncomingDamage(5) / 4 > MaxHealth() / 100 * 7) IncomingDamage(5) / 4
	MaxHealth() / 100 * 7
}

AddFunction BloodDefaultShortCDActions
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
	if not BuffPresent(rune_tap_buff) Spell(rune_tap)
}

AddFunction BloodDefaultMainActions
{
	# Heal
	BloodHealMe()
	# keep marrowrend up
	if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
	# AoE
	if (Enemies() >= 4 and RunicPower() >= 100) Spell(bonestorm)
	if (Enemies() >= 3) Spell(consumption)
	# Death Strike
	if (BuffExpires(blood_shield_buff 3)) Spell(death_strike)
	if (RunicPowerDeficit() <= 20) Spell(death_strike)
	if (target.BuffExpires(mark_of_blood_debuff) and target.IsTargetingPlayer()) Spell(mark_of_blood)
	# Blooddrinker
	if not BuffPresent(dancing_rune_weapon_buff) Spell(blooddrinker)
	# Blood boil
	if (SpellCharges(blood_boil) == SpellMaxCharges(blood_boil)) Spell(blood_boil)
	if (DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) or target.DebuffRefreshable(blood_plague_debuff)) Spell(blood_boil)
	# Marrowrend (279502 = trait Bones of the Damned)
	if (BuffStacks(bone_shield_buff) <= 7-HasAzeriteTrait(279502)-3*BuffPresent(dancing_rune_weapon_buff)) Spell(marrowrend)
	# rune strike
	if (SpellCharges(rune_strike) == SpellMaxCharges(rune_strike) and Rune() <= 3) Spell(rune_strike)
	# dump runes
	if Rune() >= 3 and Enemies() >= 3 Spell(death_and_decay)
	if Rune() >= 3 or RunicPower() < 45 Spell(heart_strike)
	# fillers
	if BuffPresent(dancing_rune_weapon_buff) Spell(blood_boil)
	if BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
	Spell(blood_boil)
	Spell(rune_strike)
}

AddFunction BloodHealMe
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if HealthPercent() <= 70 Spell(death_strike)
		if (HealthPercent() <= 50 and BloodDeathStrikeHealing() <= HealthMissing()) Spell(death_strike)
		if (HealthPercent() < 35) UseHealthPotions()
	}
}

AddFunction BloodDefaultCdActions
{
	if not CheckBoxOn(opt_deathknight_blood_offensive) 
	{
		BloodInterruptActions()
		BloodDefaultOffensiveCooldowns()
	}
	if IncomingDamage(1.5 magic=1) > 0 spell(antimagic_shell)
	Spell(consumption)
	if (BuffStacks(bone_shield_buff) >= 6) Spell(tombstone)
	Item(Trinket0Slot usable=1 text=13)
	Item(Trinket1Slot usable=1 text=14)
	Spell(vampiric_blood)
	Spell(icebound_fortitude)
	if CheckBoxOn(opt_use_consumables) 
	{
		Item(steelskin_potion usable=1)
		Item(battle_potion_of_stamina usable=1)
	}
	UseRacialSurvivalActions()
}

AddFunction BloodDefaultOffensiveCooldowns
{
	Spell(dancing_rune_weapon)
}

AddFunction BloodInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(mind_freeze) and target.IsInterruptible() Spell(mind_freeze)
		if target.InRange(asphyxiate) and not target.Classification(worldboss) Spell(asphyxiate)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
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

AddCheckBox(opt_deathknight_blood_offensive L(opt_deathknight_blood_offensive) default specialization=blood)
AddIcon checkbox=opt_deathknight_blood_offensive size=small specialization=blood
{
	BloodInterruptActions()
	BloodDefaultOffensiveCooldowns()
}
]]
	OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end