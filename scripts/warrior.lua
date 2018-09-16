local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "icyveins_warrior_protection"
    local desc = "[7.3.2] Icy-Veins: Warrior Protection"
    local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warrior_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=protection)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=protection)
AddCheckBox(opt_warrior_protection_aoe L(AOE) default specialization=protection)

AddFunction ProtectionHealMe
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if HealthPercent() < 70 Spell(victory_rush)
		if HealthPercent() < 85 Spell(impending_victory)
		if (HealthPercent() < 35) UseHealthPotions()
	}
}

AddFunction ProtectionGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not InFlightToTarget(intercept) and not InFlightToTarget(heroic_leap)
	{
		if target.InRange(intercept) Spell(intercept)
		if SpellCharges(intercept) == 0 and target.Distance(atLeast 8) and target.Distance(atMost 40) Spell(heroic_leap)
		if not target.InRange(pummel) Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction ProtectionInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(pummel) and target.IsInterruptible() Spell(pummel)
		if not target.Classification(worldboss) 
        {
            if target.InRange(storm_bolt) Spell(storm_bolt)
            if target.InRange(intercept) and Talent(warbringer_talent) Spell(intercept)
            if target.Distance(less 10) Spell(shockwave)
            if target.InRange(quaking_palm) Spell(quaking_palm)
            if target.Distance(less 5) Spell(war_stomp)
            if target.InRange(intimidating_shout) Spell(intimidating_shout)
        }
	}
}

AddFunction ProtectionOffensiveCooldowns
{
	Spell(avatar)
	if (Talent(booming_voice_talent) and RageDeficit() >= Talent(booming_voice_talent)*60) Spell(demoralizing_shout)
}

#
# Short
#

AddFunction ProtectionDefaultShortCDActions
{
	ProtectionHealMe()
    if IncomingDamage(5 physical=1)
        and (not Talent(bolster_talent) or not BuffPresent(last_stand_buff)) 
        and (BuffRemaining(shield_block_buff) < 2*BaseDuration(shield_block_buff)) 
    {
        Spell(shield_block)
    }
	if (IncomingDamage(5) and Rage() >= 70) Spell(ignore_pain)
	# range check
	ProtectionGetInMeleeRange()
}

#
# Single-Target
#

AddFunction ProtectionDefaultMainActions
{
    if not BuffPresent(battle_shout_buff) Spell(battle_shout)
	Spell(shield_slam)
	if Talent(devastatator_talent) and BuffPresent(revenge_buff) Spell(revenge)
	if BuffPresent(vengeance_revenge_buff) Spell(revenge)
	Spell(thunder_clap)
	if BuffPresent(revenge_buff) Spell(revenge)
	Spell(storm_bolt)
	Spell(devastate)
}

#
# AOE
#

AddFunction ProtectionDefaultAoEActions
{
	Spell(ravager)
	Spell(revenge)
	Spell(thunder_clap)
	if not BuffPresent(battle_shout_buff) Spell(battle_shout)
	Spell(shield_slam)
	if Enemies() >= 3 Spell(shockwave)
	Spell(devastate)
}

#
# Cooldowns
#

AddFunction ProtectionDefaultCdActions 
{
	ProtectionInterruptActions()
	ProtectionOffensiveCooldowns()
	if IncomingDamage(1.5 magic=1) > 0 Spell(spell_reflection)
	if (HasEquippedItem(shifting_cosmic_sliver)) Spell(shield_wall)
	Item(Trinket0Slot usable=1 text=13)
	Item(Trinket1Slot usable=1 text=14)
	Spell(demoralizing_shout)
	Spell(shield_wall)
	Spell(last_stand)
	
}

#
# Icons
#

AddIcon help=shortcd specialization=protection
{
	ProtectionDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=protection
{
	ProtectionDefaultMainActions()
}

AddIcon checkbox=opt_warrior_protection_aoe help=aoe specialization=protection
{
	ProtectionDefaultAoEActions()
}

AddIcon help=cd specialization=protection
{
	ProtectionDefaultCdActions()
}
]]
    OvaleScripts:RegisterScript("WARRIOR", "protection", name, desc, code, "script")
end