local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
	local name = "icyveins_paladin_protection"
	local desc = "[8.0.1] Icy-Veins: Paladin Protection"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_paladin_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=protection)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=protection)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=protection)

AddFunction PaladinHealMe
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if (HealthPercent() <= 50) Spell(light_of_the_protector)
		if (HealthPercent() < 35) UseHealthPotions()
	}
}

AddFunction ProtectionHasProtectiveCooldown
{
	BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) or BuffPresent(potion_buff)
}

AddFunction ProtectionCooldownTreshold
{
	HealthPercent() <= 100 and not ProtectionHasProtectiveCooldown()
}

AddFunction ProtectionGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(rebuke) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction ProtectionDefaultShortCDActions
{
	PaladinHealMe()
	#bastion_of_light,if=talent.bastion_of_light.enabled&action.shield_of_the_righteous.charges<1
	if Charges(shield_of_the_righteous count=0) < 0.8 Spell(bastion_of_light)
	#seraphim,if=talent.seraphim.enabled&action.shield_of_the_righteous.charges>=2
	if Charges(shield_of_the_righteous) >= 2 Spell(seraphim)

	ProtectionGetInMeleeRange()
	
	if (BuffRemaining(shield_of_the_righteous_buff) < 2*BaseDuration(shield_of_the_righteous_buff)) 
	{
		#max sotr charges
		if (SpellCharges(shield_of_the_righteous count=0) >= SpellMaxCharges(shield_of_the_righteous)-0.2) Spell(shield_of_the_righteous text=max)
		
		if not ProtectionHasProtectiveCooldown() 
			and BuffPresent(avengers_valor_buff) 
			and (IncomingDamage(5 physical=1) > 0 or (IncomingDamage(5) > 0 and Talent(holy_shield_talent)))
			and (not HasAzeriteTrait(inner_light_trait) or not BuffPresent(shield_of_the_righteous_buff))
		{
			# Dumping SotR charges
			if (Talent(bastion_of_light_talent) and SpellCooldown(bastion_of_light) == 0) Spell(shield_of_the_righteous)
			if (SpellCharges(shield_of_the_righteous count=0) >= 1.8 and (not Talent(seraphim_talent) or SpellFullRecharge(shield_of_the_righteous) < SpellCooldown(seraphim))) Spell(shield_of_the_righteous)
		}
	}
}

AddFunction ProtectionDefaultMainActions
{
	if target.IsInterruptible() Spell(avengers_shield)
	Spell(judgment_prot)
	if Speed() == 0 and not BuffPresent(consecration_buff) Spell(consecration)
	Spell(avengers_shield)
	Spell(hammer_of_the_righteous)
	Spell(consecration)
}

AddFunction ProtectionDefaultAoEActions
{
	Spell(avengers_shield)
	if Speed() == 0 and not BuffPresent(consecration_buff) Spell(consecration)
	Spell(judgment_prot)
	Spell(hammer_of_the_righteous)
	Spell(consecration)
}

AddCheckBox(opt_avenging_wrath SpellName(avenging_wrath) default specialization=protection)
AddFunction ProtectionDefaultCdActions
{
	ProtectionInterruptActions()
	if CheckBoxOn(opt_avenging_wrath) Spell(avenging_wrath)
	if not DebuffPresent(forbearance_debuff) and HealthPercent() <= 15 Spell(lay_on_hands)
	Item(Trinket0Slot usable=1 text=13)
	Item(Trinket1Slot usable=1 text=14)
	
	if ProtectionCooldownTreshold() 
	{
		Spell(divine_protection)
		Spell(ardent_defender)
		Spell(guardian_of_ancient_kings)
		Spell(aegis_of_light)
		if Talent(final_stand_talent) Spell(divine_shield)
		if CheckBoxOn(opt_use_consumables) 
		{
			Item(steelskin_potion usable=1)
			Item(battle_potion_of_stamina usable=1)
		}
		UseRacialSurvivalActions()
	}
}

AddFunction ProtectionInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(rebuke) Spell(rebuke)
		if not target.Classification(worldboss)
		{
			if target.InRange(hammer_of_justice) Spell(hammer_of_justice)
			if target.Distance(less 10) Spell(blinding_light)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddIcon help=shortcd specialization=protection
{
	ProtectionDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=protection
{
	ProtectionDefaultMainActions()
}

AddIcon help=aoe specialization=protection
{
	ProtectionDefaultAoEActions()
}

AddIcon help=cd specialization=protection
{
	#if not InCombat() ProtectionPrecombatCdActions()
	ProtectionDefaultCdActions()
}
	]]
	OvaleScripts:RegisterScript("PALADIN", "protection", name, desc, code, "script")
end