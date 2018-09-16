local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "icyveins_druid_guardian"
    local desc = "[8.0.1] Icy-Veins: Druid Guardian"
    local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=guardian)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=guardian)
AddCheckBox(opt_druid_guardian_aoe L(AOE) default specialization=guardian)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=guardian)

AddFunction GuardianHealMeShortCd
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if BuffExpires(frenzied_regeneration_buff) and HealthPercent() <= 70 
		{
            if (SpellCharges(frenzied_regeneration)>=2 or HealthPercent() <= 50) Spell(frenzied_regeneration)
		}
		
		if HealthPercent() < 35 UseHealthPotions()
	}
}

AddFunction GuardianHealMeMain
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if HealthPercent() <= 50 Spell(lunar_beam)
		if HealthPercent() <= 80 and not InCombat() Spell(regrowth)
	}
}

AddFunction GuardianGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and (Stance(druid_bear_form) and not target.InRange(mangle) or { Stance(druid_cat_form) or Stance(druid_claws_of_shirvallah) } and not target.InRange(shred))
	{
		if target.InRange(wild_charge) Spell(wild_charge)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction GuardianDefaultShortCDActions
{
	GuardianHealMeShortCd()
	if IncomingDamage(5 physical=1) Spell(ironfur)
	GuardianGetInMeleeRange()
}

#
# Single-Target
#

AddFunction GuardianDefaultMainActions
{
    GuardianHealMeMain()
	if not Stance(druid_bear_form) Spell(bear_form)

    if (RageDeficit() <= 20 and (IncomingDamage(5) == 0 or (SpellCharges(ironfur)==0 and SpellCharges(frenzied_regeneration) == 0))) Spell(maul)
    if (target.DebuffRefreshable(moonfire_debuff)) Spell(moonfire)
    if (target.DebuffStacks(thrash_bear_debuff) < 3) Spell(thrash_bear)
    if (BuffRefreshable(pulverize_buff)) Spell(pulverize)
	Spell(mangle)
	Spell(thrash_bear)
    if not BuffExpires(galactic_guardian_buff) Spell(moonfire)
	if (RageDeficit() <= 20 or IncomingDamage(5) == 0 or not UnitInParty()) Spell(maul)
	Spell(swipe_bear)
}

#
# AOE
#

AddFunction GuardianDefaultAoEActions
{
    GuardianHealMeMain()
	if not Stance(druid_bear_form) Spell(bear_form)
	if Enemies() >= 4 and HealthPercent() <= 80 Spell(lunar_beam)
    
    if not BuffExpires(incarnation_guardian_of_ursoc_buff) 
	{
        if (DebuffCountOnAny(moonfire_debuff) < 1) Spell(moonfire)
		if (BuffRefreshable(pulverize_buff)) Spell(pulverize)
        if (Enemies() <= 3) Spell(mangle)
        Spell(thrash_bear)
	}
    
    if (RageDeficit() <= 20 and (IncomingDamage(5) == 0 or (SpellCharges(ironfur)==0 and SpellCharges(frenzied_regeneration) == 0))) Spell(maul)
    if (DebuffCountOnAny(moonfire_debuff) < 2 and target.DebuffRefreshable(moonfire_debuff)) Spell(moonfire)
    Spell(thrash_bear)
    if (Enemies() <= 2 and BuffRefreshable(pulverize_buff)) Spell(pulverize)
    if (Enemies() <= 4) Spell(mangle)
    if (Enemies() <= 3 and not BuffExpires(galactic_guardian_buff)) Spell(moonfire)
    if (Enemies() <= 3 and (RageDeficit() <= 20 or IncomingDamage(5) == 0)) Spell(maul)
    Spell(swipe_bear)
}

AddFunction GuardianDefaultCdActions 
{
	GuardianInterruptActions()
	if not CheckBoxOn(opt_druid_guardian_offensive) GuardianDefaultOffensiveCooldowns()
    
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)

	if BuffExpires(bristling_fur_buff) and BuffExpires(survival_instincts_buff) and BuffExpires(barkskin_buff) and BuffExpires(potion_buff)
	{
		Spell(bristling_fur)
        Spell(barkskin)
		Spell(survival_instincts)
		if CheckBoxOn(opt_use_consumables) 
        {
            Item(battle_potion_of_agility usable=1)
            Item(steelskin_potion usable=1)
            Item(battle_potion_of_stamina usable=1)
        }
	}
}

AddFunction GuardianDefaultOffensiveCooldowns
{
    Spell(incarnation_guardian_of_ursoc)
}

AddFunction GuardianInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
	{
		if target.InRange(skull_bash) and target.IsInterruptible() Spell(skull_bash)
		if not target.Classification(worldboss)
		{
			Spell(mighty_bash)
			if target.Distance(less 10) Spell(incapacitating_roar)
			if target.Distance(less 8) Spell(war_stomp)
			if target.Distance(less 15) Spell(typhoon)
		}
	}
}

AddIcon help=shortcd specialization=guardian
{
	GuardianDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=guardian
{
	GuardianDefaultMainActions()
}

AddIcon checkbox=opt_druid_guardian_aoe help=aoe specialization=guardian
{
	GuardianDefaultAoEActions()
}

AddIcon help=cd specialization=guardian
{
	GuardianDefaultCdActions()
}

AddCheckBox(opt_druid_guardian_offensive L(opt_druid_guardian_offensive) default specialization=guardian)
AddIcon checkbox=opt_druid_guardian_offensive size=small specialization=guardian
{
    GuardianDefaultOffensiveCooldowns()
}
]]
    OvaleScripts:RegisterScript("DRUID", "guardian", name, desc, code, "script")
end