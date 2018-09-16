local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "icyveins_demonhunter_vengeance"
    local desc = "[8.0.1] Icy-Veins: DemonHunter Vengeance"
    local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=vengeance)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=vengeance)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=vengeance)
AddCheckBox(opt_infernal_strike SpellName(infernal_strike) default specialization=vengeance)

AddFunction VengeanceHealMeShortCd
{
    unless(DebuffPresent(healing_immunity_debuff)) 
	{
 		if (HealthPercent() < 35) UseHealthPotions()
	}
}
AddFunction VengeanceHealMeMain
{
	unless(DebuffPresent(healing_immunity_debuff)) 
	{
		if (HealthPercent() < 70) Spell(fel_devastation)
		if (HealthPercent() < 50) 
        {
            if (SoulFragments() >= 4 and Enemies()>=3) Spell(spirit_bomb)
            Spell(soul_cleave)
        }
	}
}

AddFunction VengeanceInfernalStrike
{
	CheckBoxOn(opt_infernal_strike) and (not Talent(flame_crash_talent) or VengeanceSigilOfFlame()) and (SpellFullRecharge(infernal_strike) <= 3)
}

AddFunction VengeanceSigilOfFlame
{
	(not SigilCharging(flame) and target.DebuffRemaining(sigil_of_flame_debuff) <= 2-Talent(quickened_sigils_talent))
}

AddFunction VengeanceRangeCheck
{
	if (CheckBoxOn(opt_melee_range) and not target.InRange(shear))
	{
		if (target.InRange(felblade)) Spell(felblade)
		if (CheckBoxOn(opt_infernal_strike) and (target.Distance(more 5) and (target.Distance() < 30+10*Talent(abyssal_strike_talent)))) Spell(infernal_strike text=range)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction VengeanceDefaultShortCDActions
{
    VengeanceHealMeShortCd()
    Spell(soul_barrier)
	
	if (IncomingDamage(5 physical=1) > 0 and (BuffExpires(metamorphosis_veng_buff) or SpellCharges(demon_spikes) == SpellMaxCharges(demon_spikes) or Talent(razor_spikes_talent)))
	{
		if (BuffRemaining(demon_spikes_buff)<2*BaseDuration(demon_spikes_buff)) Spell(demon_spikes)
	}
	
	VengeanceRangeCheck()
}

AddFunction VengeanceDefaultMainActions
{
    VengeanceHealMeMain()
    if (VengeanceInfernalStrike()) Spell(infernal_strike)
    
    # fiery demise
    if (not target.DebuffExpires(fiery_demise_debuff))
    {
        if (SoulFragments() >= 4) Spell(spirit_bomb)
        Spell(immolation_aura)
        Spell(sigil_of_flame)
        Spell(fel_devastation)
        Spell(felblade)
        Spell(fel_eruption)
    }
    
    if (SoulFragments() >= 4) Spell(spirit_bomb)
    if (not Talent(spirit_bomb_talent) or (Talent (spirit_bomb_talent) and SoulFragments() == 0)) Spell(soul_cleave)
    if (PainDeficit() >= 10) Spell(immolation_aura)
    if (PainDeficit() >= 30) Spell(felblade)
    if (SoulFragments() <= 3) Spell(fracture)
    Spell(fel_devastation)
    if (VengeanceSigilOfFlame()) Spell(sigil_of_flame)
    if (not Talent(fracture_talent) and PainDeficit() >= 10) Spell(shear)
    Spell(throw_glaive_veng)
}

AddFunction VengeanceDefaultCdActions
{
	VengeanceInterruptActions()
    if not CheckBoxOn(opt_demonhunter_vengeance_offensive) VengeanceDefaultOffensiveCooldowns()
    Item(Trinket0Slot text=13 usable=1)
	Item(Trinket1Slot text=14 usable=1)
	if (BuffExpires(metamorphosis_veng_buff) and target.DebuffExpires(fiery_brand_debuff)) 
    {
        Spell(fiery_brand)
        Spell(metamorphosis_veng)
        if CheckBoxOn(opt_use_consumables) 
        {
            Item(battle_potion_of_agility usable=1)
            Item(steelskin_potion usable=1)
            Item(battle_potion_of_stamina usable=1)
        }
    }
}

AddFunction VengeanceDefaultOffensiveCooldowns
{
    if Talent(charred_flesh_talent) Spell(fiery_brand)
    Spell(metamorphosis_veng)
}

AddFunction VengeanceInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(consume_magic) Spell(consume_magic)
		if not target.Classification(worldboss) and not SigilCharging(silence misery chains)
		{
			if target.Distance(less 8) Spell(arcane_torrent_dh)
			Spell(fel_eruption)
			if (target.RemainingCastTime() >= (2 - Talent(quickened_sigils_talent) + GCDRemaining()))
			{
				Spell(sigil_of_silence)
				Spell(sigil_of_misery)
				Spell(sigil_of_chains)
			}
			if target.CreatureType(Demon Humanoid Beast) Spell(imprison)
		}
	}
}

AddCheckBox(opt_demonhunter_vengeance_aoe L(AOE) default specialization=vengeance)

AddIcon help=shortcd specialization=vengeance
{
	VengeanceDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=vengeance
{
	VengeanceDefaultMainActions()
}

AddIcon checkbox=opt_demonhunter_vengeance_aoe help=aoe specialization=vengeance
{
	VengeanceDefaultMainActions()
}

AddIcon help=cd specialization=vengeance
{
	#if not InCombat() VengeancePrecombatCdActions()
	VengeanceDefaultCdActions()
}

AddCheckBox(opt_demonhunter_vengeance_offensive L(opt_demonhunter_vengeance_offensive) default specialization=vengeance)
AddIcon checkbox=opt_demonhunter_vengeance_offensive size=small specialization=vengeance
{
    VengeanceDefaultOffensiveCooldowns()
}
	]]
    OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end