local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_demonhunter_vengeance"
    local desc = "[9.0.2] Ovale_TankScripts: DemonHunter Vengeance"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_demonhunter_spells)

Define(demonic_talent 17)
Define(demon_spikes_buff 203819)
    SpellInfo(demon_spikes duration=6)
Define(fel_devastation 212084)
    SpellInfo(fel_devastation cd=60 fury=50)
Define(fiery_brand_debuff 207771)
    SpellInfo(fiery_brand_debuff duration=8)
    SpellAddTargetDebuff(fiery_brand fiery_brand_debuff set=1)
Define(immolation_aura 258920)
    SpellInfo(immolation_aura cd=15)
Define(infernal_strike 189110)
Define(soul_barrier 263648)
    SpellInfo(soul_barrier cd=30)
Define(void_reaver_talent 16)

AddCheckBox(opt_interrupt L(interrupt) default enabled=(specialization(vengeance)))
AddCheckBox(opt_dispel L(dispel) default enabled=(specialization(vengeance)))
AddCheckBox(opt_melee_range L(not_in_melee_range) enabled=(specialization(vengeance)))
AddCheckBox(opt_demonhunter_vengeance_aoe L(AOE) default enabled=(specialization(vengeance)))
AddCheckBox(opt_use_consumables L(opt_use_consumables) default enabled=(specialization(vengeance)))
AddCheckBox(opt_infernal_strike SpellName(infernal_strike) default enabled=(specialization(vengeance)))
AddCheckBox(opt_demonhunter_vengeance_offensive L(seperate_offensive_icon) default enabled=(specialization(vengeance)))

AddFunction VengeanceHealMeShortCd
{
    if (HealthPercent() < 35) UseHealthPotions()
    CovenantShortCDHealActions()
}

AddFunction VengeanceHealMeMain
{
    if (HealthPercent() < 70) Spell(fel_devastation)
    if (HealthPercent() < 50) 
    {
        if (SoulFragments() >= 4 and Enemies()>=3) Spell(spirit_bomb)
        if (not VengeancePoolingForDemonic()) Spell(soul_cleave)
    }
}

AddFunction VengeancePoolingForDemonic
{
    Talent(demonic_talent) and SpellCooldown(fel_devastation)<5 and Fury()<50
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
    if (CheckBoxOn(opt_melee_range) and not target.InRange(soul_cleave))
    {
        if (target.InRange(felblade)) Spell(felblade)
        if (CheckBoxOn(opt_infernal_strike) and (target.Distance(more 5) and target.Distance(atMost 30))) Spell(infernal_strike text=range)
        Texture(misc_arrowlup help=L(not_in_melee_range))
    }
}

AddFunction VengeanceDefaultShortCDActions
{
    VengeanceHealMeShortCd()

    if (IncomingDamage(5)>0 and target.DebuffExpires(fiery_brand_debuff) and BuffExpires(metamorphosis) and BuffExpires(soul_barrier)) 
    {
        if (IncomingPhysicalDamage(5) > 0 and BuffRemaining(demon_spikes_buff)<2) Spell(demon_spikes)
        if (not BuffPresent(demon_spikes_buff) or IncomingPhysicalDamage(5) <= 0)
        {
            if (Talent(demonic_talent)) Spell(fel_devastation)
            Spell(soul_barrier)
            Spell(fiery_brand)
        }
    }
    VengeanceRangeCheck()
}

AddFunction VengeanceDefaultMainActions
{
    VengeanceHealMeMain()
    
    if (VengeanceInfernalStrike()) Spell(infernal_strike)
    
    if (SoulFragments() >= 5-Talent(fracture_talent)-BuffPresent(metamorphosis) or target.DebuffExpires(frailty_debuff)) Spell(spirit_bomb)
    if (BuffPresent(metamorphosis) and Talent(fracture_talent)) Spell(fracture)
    if (not VengeancePoolingForDemonic() and ((not Talent(spirit_bomb_talent) and SoulFragments() >= 4-BuffPresent(metamorphosis)) or SoulFragments() == 0 or PreviousGCDSpell(spirit_bomb))) Spell(soul_cleave)
    if (FuryDeficit() >= 10) Spell(immolation_aura)
    if (FuryDeficit() >= 30) Spell(felblade)
    if (SoulFragments() <= 3) Spell(fracture)
    if (not Talent(demonic_talent)) Spell(fel_devastation)
    if (VengeanceSigilOfFlame()) Spell(sigil_of_flame)
    if (not Talent(fracture_talent) and FuryDeficit() >= 10) Spell(shear)
    if (Enemies() >= 2) Spell(throw_glaive)
    if (not Talent(fracture_talent)) Spell(shear)
    Spell(throw_glaive)
}

AddFunction VengeanceDefaultCdActions
{
    if not CheckBoxOn(opt_demonhunter_vengeance_offensive) { VengeanceDefaultOffensiveActions() }
    
    Item(Trinket0Slot text=13 usable=1)
    Item(Trinket1Slot text=14 usable=1)
    
    Spell(metamorphosis)
    if CheckBoxOn(opt_use_consumables) 
    {
        Item(item_battle_potion_of_agility usable=1)
        Item(item_steelskin_potion usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
}

AddFunction VengeanceDefaultOffensiveActions
{
    VengeanceInterruptActions()
    VengeanceDispelActions()
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
        if Spell(arcane_torrent) and target.HasDebuffType(magic) Spell(arcane_torrent)
    }
}

AddFunction VengeanceDefaultOffensiveCooldowns
{
    if Talent(charred_flesh_talent) Spell(fiery_brand)
    if (SoulFragments() <= 2) Spell(elysian_decree)
    Spell(sinful_brand)
    Spell(the_hunt)
    Spell(fodder_to_the_flame)
}

AddIcon help=shortcd enabled=(specialization(vengeance))
{
    VengeanceDefaultShortCDActions()
}

AddIcon enemies=1 help=main enabled=(specialization(vengeance))
{
    VengeanceDefaultMainActions()
}

AddIcon help=aoe enabled=(checkboxon(opt_demonhunter_vengeance_aoe) and specialization(vengeance))
{
    VengeanceDefaultMainActions()
}

AddIcon help=cd enabled=(specialization(vengeance))
{
    VengeanceDefaultCdActions()
}

AddIcon size=small enabled=(checkboxon(opt_demonhunter_vengeance_offensive) and specialization(vengeance))
{
    VengeanceDefaultOffensiveActions()
}
    ]]
    OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end