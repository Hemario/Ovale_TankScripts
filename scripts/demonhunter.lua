local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_demonhunter_vengeance"
    local desc = "[8.2.0] Ovale_TankScripts: DemonHunter Vengeance"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_demonhunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=vengeance)
AddCheckBox(opt_dispel L(dispel) default specialization=vengeance)
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
    target.TimeToDie() > 2-Talent(quickened_sigils_talent)+GCDRemaining()
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

AddFunction VengeancePowerGainShear
{
    if (Talent(fracture_talent)) 0-PowerCost(fracture) 
    0-PowerCost(shear)
}

AddFunction VengeanceDefaultShortCDActions
{
    VengeanceHealMeShortCd()
    Spell(soul_barrier)
    
    if ((IncomingDamage(5 physical=1) > 0 and BuffExpires(metamorphosis_veng_buff) and target.DebuffExpires(fiery_brand_debuff) and target.DebuffExpires(fiery_demise_debuff) and BuffExpires(demon_spikes_buff)) or (Talent(razor_spikes_talent) and PainDeficit()<20))
    {
        if (BuffRemaining(demon_spikes_buff)<2*BaseDuration(demon_spikes_buff)) 
        {
            if (SpellFullRecharge(demon_spikes) < 3) Spell(demon_spikes text=max)
            Spell(demon_spikes)
        }
    }
    
    VengeanceRangeCheck()
}

AddFunction VengeanceDefaultMainActions
{
    VengeanceHealMeMain()
    if (VengeanceInfernalStrike()) Spell(infernal_strike)
    
    AzeriteEssenceMain()
    
    # fiery demise
    if (not target.DebuffExpires(fiery_demise_debuff))
    {
        Spell(immolation_aura)
        Spell(fel_devastation)
        if (CheckBoxOn(opt_infernal_strike)) Spell(infernal_strike)
        if (VengeanceSigilOfFlame()) Spell(sigil_of_flame)
        Spell(felblade)
        Spell(fel_eruption)
    }
    
    if (SoulFragments() >= 5-Talent(fracture_talent)-BuffPresent(metamorphosis_veng_buff) or target.DebuffExpires(frailty_debuff)) Spell(spirit_bomb)
    if (Talent(fracture_talent) and (Charges(fracture) >= 2 or PainDeficit() >= VengeancePowerGainShear() or BuffPresent(metamorphosis_veng_buff))) Spell(fracture)
    if (PainDeficit() >= 10) Spell(immolation_aura)
    if ((not Talent(spirit_bomb_talent) or SoulFragments() == 0) and (Pain()>=60 or (Talent(void_reaver_talent) and target.DebuffExpires(void_reaver_debuff)) or HealthPercent()<=75)) Spell(soul_cleave)
    if (VengeanceSigilOfFlame()) Spell(sigil_of_flame)
    if (PainDeficit() >= 30) Spell(felblade)
    if (Talent(fracture_talent)) Spell(fracture)
    if (not Talent(fracture_talent) and PainDeficit() >= VengeancePowerGainShear()) Spell(shear)
    if (Enemies() >= 2) Spell(throw_glaive_veng)
    if (not Talent(fracture_talent)) Spell(shear)
    Spell(throw_glaive_veng)
}

AddFunction VengeanceDefaultCdActions
{
    if not CheckBoxOn(opt_demonhunter_vengeance_offensive) { VengeanceDefaultOffensiveActions() }
    
    Item(Trinket0Slot text=13 usable=1)
    Item(Trinket1Slot text=14 usable=1)
    
    AzeriteEssenceDefensiveCooldowns()
    
    if (BuffExpires(metamorphosis_veng_buff) and target.DebuffExpires(fiery_brand_debuff)) 
    {
        Spell(fiery_brand)
        Spell(metamorphosis_veng)
        if CheckBoxOn(opt_use_consumables) 
        {
            Item(item_battle_potion_of_agility usable=1)
            Item(item_steelskin_potion usable=1)
            Item(item_battle_potion_of_stamina usable=1)
        }
    }
}

AddFunction VengeanceDefaultOffensiveActions
{
    VengeanceInterruptActions()
    VengeanceDispelActions()
    AzeriteEssenceOffensiveCooldowns()
    VengeanceDefaultOffensiveCooldowns()
}

AddFunction VengeanceInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(disrupt) and target.IsInterruptible() Spell(disrupt)
        if not target.Classification(worldboss) and not SigilCharging(silence misery chains)
        {
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

AddFunction VengeanceDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if target.HasDebuffType(magic) Spell(consume_magic)
        if Spell(arcane_torrent_dh) and target.HasDebuffType(magic) Spell(arcane_torrent_dh)
    }
}

AddFunction VengeanceDefaultOffensiveCooldowns
{
    if Talent(charred_flesh_talent) Spell(fiery_brand)
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
    VengeanceDefaultCdActions()
}

AddCheckBox(opt_demonhunter_vengeance_offensive L(seperate_offensive_icon) default specialization=vengeance)
AddIcon checkbox=opt_demonhunter_vengeance_offensive size=small specialization=vengeance
{
    VengeanceDefaultOffensiveActions()
}
    ]]
    OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end