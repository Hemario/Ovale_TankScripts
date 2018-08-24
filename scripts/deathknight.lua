local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "icyveins_deathknight_blood"
    local desc = "[7.3.2] Icy-Veins: DeathKnight Blood"
    local code = [[

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=blood)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=blood)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=blood)

AddFunction BloodDefaultShortCDActions
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(death_strike) Texture(misc_arrowlup help=L(not_in_melee_range))
	if not BuffPresent(rune_tap_buff) Spell(rune_tap)
}

AddFunction BloodDefaultMainActions
{
	BloodHealMe()
	if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
	if target.DebuffRefreshable(blood_plague_debuff) Spell(blood_boil)
	if not BuffPresent(death_and_decay_buff) and BuffPresent(crimson_scourge_buff) and Talent(rapid_decomposition_talent) Spell(death_and_decay)
	if RunicPower() >= 100 and target.TimeToDie() >= 10 Spell(bonestorm)
	if RunicPowerDeficit() <= 20 Spell(death_strike)
	if BuffStacks(bone_shield_buff) <= 2+4*Talent(ossuary_talent) Spell(marrowrend)
	if not BuffPresent(death_and_decay_buff) and Rune() >= 3 and Talent(rapid_decomposition_talent) Spell(death_and_decay)
	if not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if Rune() >= 3 or RunicPower() < 45 Spell(heart_strike)
	Spell(consumption)
	Spell(blood_boil)
}

AddFunction BloodDefaultAoEActions
{
	BloodHealMe()
	if RunicPower() >= 100 Spell(bonestorm)
	if InCombat() and BuffExpires(bone_shield_buff 3) Spell(marrowrend)
	if DebuffCountOnAny(blood_plague_debuff) < Enemies(tagged=1) Spell(blood_boil)
	if not BuffPresent(death_and_decay_buff) and BuffPresent(crimson_scourge_buff) Spell(death_and_decay)
	if RunicPowerDeficit() <= 20 Spell(death_strike)
	if BuffStacks(bone_shield_buff) <= 2+4*Talent(ossuary_talent) Spell(marrowrend)
	if not BuffPresent(death_and_decay_buff) and Enemies() >= 3 Spell(death_and_decay)
	if not target.DebuffPresent(mark_of_blood_debuff) Spell(mark_of_blood)
	if Rune() >= 3 or RunicPower() < 45 Spell(heart_strike)
	Spell(consumption)
	Spell(blood_boil)
}

 AddFunction BloodHealMe
 {
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if HealthPercent() <= 70 Spell(death_strike)
		if (DamageTaken(5) * 0.2) > (Health() / 100 * 25) Spell(death_strike)
		if (BuffStacks(bone_shield_buff) * 3) > (100 - HealthPercent()) Spell(tombstone)
		if HealthPercent() <= 70 Spell(consumption)
		if (HealthPercent() < 35) UseHealthPotions()
	}
}

AddFunction BloodDefaultCdActions
{
	BloodInterruptActions()
	if IncomingDamage(1.5 magic=1) > 0 spell(antimagic_shell)
	if (HasEquippedItem(shifting_cosmic_sliver)) Spell(icebound_fortitude)
	Item(Trinket0Slot usable=1 text=13)
	Item(Trinket1Slot usable=1 text=14)
	Spell(vampiric_blood)
	Spell(icebound_fortitude)
	Spell(dancing_rune_weapon)
	if BuffStacks(bone_shield_buff) >= 5 Spell(tombstone)
	if CheckBoxOn(opt_use_consumables) Item(unbending_potion usable=1)
	UseRacialSurvivalActions()
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
	BloodDefaultAoEActions()
}

AddIcon help=cd specialization=blood
{
	#if not InCombat() ProtectionPrecombatCdActions()
	BloodDefaultCdActions()
}
]]
    OvaleScripts:RegisterScript("DEATHKNIGHT", "blood", name, desc, code, "script")
end