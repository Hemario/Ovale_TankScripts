local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_druid_guardian"
    local desc = "[9.0.1] Ovale_TankScripts: Druid Guardian"
    local code = [[
Include(ovale_common)
Include(ovale_tankscripts_common)
Include(ovale_druid_spells)

Define(bristling_fur 155835)
    SpellInfo(bristling_fur cd=40)
Define(earthwarden_talent 16)
Define(earthwarden_buff 203975)
Define(galactic_guardian_buff 213708)
    SpellAddBuff(moonfire galactic_guardian_buff set=0)
Define(moonfire_debuff 164812)
    SpellAddTargetDebuff(moonfire moonfire_debuff add=1)
Define(regrowth 8936)
Define(renewal 108238)
Define(remove_corruption 2782)
    SpellInfo(remove_corruption cd=8)
Define(rejuvination 774)
    SpellInfo(rejuvination duration=16)
Define(soothe 2908)
    SpellInfo(soothe cd=10)
Define(survival_instincts 61336)
    SpellInfo(survival_instincts charge_cd=140)
    SpellRequire(survival_instincts unusable set=1 enabled=(buffpresent(survival_instincts)))
Define(swiftmend 18562)
Define(swipe_bear 213771)
Define(swipe_cat 106785)
    SpellInfo(swipe_cat energy=35 combopoints=-1)
    SpellRequire(swipe_cat unusable set=1 enabled=(not stance(druid_cat_form)))
Define(wild_charge_bear 16979)
    SpellRequire(wild_charge_bear unusable set=1 enabled=(not stance(druid_bear_form)))
Define(wild_charge_cat 49376)
    SpellInfo(wild_charge_cat cd=15)
    SpellRequire(swipe_cat unusable set=1 enabled=(not stance(druid_cat_form)))
Define(wild_growth 48438)

AddCheckBox(opt_interrupt L(interrupt) default enabled=(specialization(guardian)))
AddCheckBox(opt_dispel L(dispel) default enabled=(specialization(guardian)))
AddCheckBox(opt_melee_range L(not_in_melee_range) enabled=(specialization(guardian)))
AddCheckBox(opt_druid_guardian_aoe L(AOE) default enabled=(specialization(guardian)))
AddCheckBox(opt_use_consumables L(opt_use_consumables) default enabled=(specialization(guardian)))
AddCheckBox(opt_druid_guardian_offensive L(seperate_offensive_icon) default enabled=(specialization(guardian)))
AddCheckBox(opt_druid_guardian_catweave L(cat_weaving) enabled=(specialization(guardian)))

AddFunction GuardianHealMeShortCd
{
    if BuffExpires(frenzied_regeneration) and HealthPercent() <= 50+(SpellCharges(frenzied_regeneration)-1)*18
    {
        Spell(frenzied_regeneration)
    }
    if (HealthPercent() < 35) UseHealthPotions()
    CovenantShortCDHealActions()
}

AddFunction GuardianHealMeMain
{
    if HealthPercent() <= 80 and not InCombat() 
    {
        if UnitInParty() Spell(wild_growth)
        if BuffPresent(regrowth) or BuffPresent(rejuvination) Spell(swiftmend)
        if BuffRefreshable(rejuvination) Spell(rejuvination)
        Spell(regrowth)
    }
}

AddFunction GuardianGetInMeleeRange
{
    if CheckBoxOn(opt_melee_range) and ((Stance(druid_bear_form) and not target.InRange(mangle)) or (Stance(druid_cat_form) and not target.InRange(shred)))
    {
        if target.InRange(wild_charge_bear) Spell(wild_charge_bear)
        if target.InRange(wild_charge_cat) Spell(wild_charge_cat)
        Texture(misc_arrowlup help=L(not_in_melee_range))
    }
}

AddFunction GuardianDefaultShortCDActions
{
    GuardianHealMeShortCd()
    if (IncomingDamage(5 physical=1) and (BuffExpires(ironfur 1) or RageDeficit() <= 20))
    {
        Spell(ironfur)
    }
    GuardianGetInMeleeRange()
    if IncomingDamage(5) > 0 Spell(bristling_fur)
    Spell(pulverize)
}

AddFunction GuardianCanCatweave
{
    CheckBoxOn(opt_druid_guardian_catweave) and Talent(feral_affinity_talent_guardian) and not (UnitInParty() and target.IsTargetingPlayer())
}

AddFunction GuardianCatweaveActions
{
    if ComboPoints() >= 5
    {
        # Rip at 5 CPs and Rip is either not ticking or will fall off before you can re-apply it. 
        if (target.DebuffExpires(rip) or target.DebuffRefreshable(rip)) Spell(rip)
        # Ferocious Bite at 5 CPs.
        Spell(ferocious_bite)
    }
    # Rake if Rake is either not ticking or will fall off before you can re-apply it.
    if (target.DebuffExpires(rake_debuff) or (target.DebuffRefreshable(rake_debuff) and target.DebuffPersistentMultiplier(rake_debuff) < PersistentMultiplier(rake_debuff))) Spell(rake)
    # Generate CPs with fillers.
    if Enemies() > 1 Spell(swipe_cat)
    Spell(shred)
}

#
# Single-Target
#

AddFunction GuardianDefaultMainActions
{
    GuardianHealMeMain()
    if GuardianCanCatweave() and Stance(druid_cat_form) GuardianCatweaveActions()
    if not Stance(druid_bear_form) Spell(bear_form)
    
    if (RageDeficit() <= 20 and (IncomingDamage(5) == 0 or (SpellCharges(ironfur)==0 and SpellCharges(frenzied_regeneration) == 0) or not UnitInParty())) Spell(maul)

    if (target.DebuffRefreshable(moonfire_debuff)) Spell(moonfire)
    if ((target.DebuffStacks(thrash_bear_debuff) < 3) or (target.DebuffRefreshable(thrash_bear_debuff)) or (Talent(earthwarden_talent) and BuffStacks(earthwarden_buff)<3)) Spell(thrash_bear)
    Spell(mangle)
    Spell(thrash_bear)
    if not BuffExpires(galactic_guardian_buff) Spell(moonfire)
    if (RageDeficit() <= 20 or IncomingDamage(5 physical=1) == 0 or not UnitInParty()) Spell(maul)
    if GuardianCanCatweave() and TimeToEnergy(100) < GCD() Spell(cat_form)
    Spell(swipe_bear)
}

#
# AOE
#

AddFunction GuardianDefaultAoEActions
{
    GuardianHealMeMain()
    if GuardianCanCatweave() and Stance(druid_cat_form) GuardianCatweaveActions()
    if not Stance(druid_bear_form) Spell(bear_form)
    
    if (RageDeficit() <= 20 and (IncomingDamage(5) == 0 or (SpellCharges(ironfur)==0 and SpellCharges(frenzied_regeneration) == 0) or not UnitInParty())) Spell(maul)
    
    if not BuffExpires(incarnation_guardian_of_ursoc) 
    {
        if ((target.DebuffStacks(thrash_bear_debuff) < 3) or (target.DebuffRefreshable(thrash_bear_debuff)) or (Talent(earthwarden_talent) and BuffStacks(earthwarden_buff)<=1)) Spell(thrash_bear)
        if (Enemies() <= 3) Spell(mangle)
        Spell(thrash_bear)
    }
    
    if (DebuffCountOnAny(moonfire_debuff) < 2 and target.DebuffRefreshable(moonfire_debuff)) Spell(moonfire)
    Spell(thrash_bear)
    if (Enemies() <= 4) Spell(mangle)
    if (DebuffCountOnAny(moonfire_debuff) < 3 and not BuffExpires(galactic_guardian_buff)) Spell(moonfire)
    if (Enemies() <= 3 and (RageDeficit() <= 20 or IncomingDamage(5) == 0 or not UnitInParty())) Spell(maul)
    if GuardianCanCatweave() and TimeToEnergy(100) < GCD() Spell(cat_form)
    Spell(swipe_bear)
}

AddFunction GuardianDefaultCdActions 
{
    if not CheckBoxOn(opt_druid_guardian_offensive) { GuardianDefaultOffensiveActions() }
    
    Item(Trinket0Slot usable=1 text=13)
    Item(Trinket1Slot usable=1 text=14)
    
    if HealthPercent() <= 50 Spell(renewal)
    if Talent(incarnation_guardian_of_ursoc_talent) and not BuffPresent(incarnation_guardian_of_ursoc) Spell(incarnation_guardian_of_ursoc)
    Spell(barkskin)
    Spell(survival_instincts)
    if CheckBoxOn(opt_use_consumables) 
    {
        Item(item_battle_potion_of_agility usable=1)
        Item(item_steelskin_potion usable=1)
        Item(item_battle_potion_of_stamina usable=1)
    }
}

AddFunction GuardianDefaultOffensiveActions
{
    GuardianInterruptActions()
    GuardianDispelActions()
    GuardianDefaultOffensiveCooldowns()
}

AddFunction GuardianInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(skull_bash) and target.IsInterruptible() Spell(skull_bash)
        if not target.Classification(worldboss)
        {
            Spell(mighty_bash)
            if target.distance(less 10) spell(incapacitating_roar)
            if target.Distance(less 8) Spell(war_stomp)
            if target.Distance(less 15) Spell(typhoon)
        }
    }
}

AddFunction GuardianDispelActions
{
    if CheckBoxOn(opt_dispel) 
    {
        if (target.HasDebuffType(enrage)) Spell(soothe)
        if (player.HasDebuffType(poison curse)) Spell(remove_corruption)
        CovenantDispelActions()
    }
}

AddFunction GuardianDefaultOffensiveCooldowns
{
    if Stance(druid_cat_form)
    {
        if GuardianCanCatweave() Spell(heart_of_the_wild)
    }
    if Stance(druid_bear_form)
    {
        if not Talent(incarnation_guardian_of_ursoc_talent) Spell(berserk)
    }
}

AddIcon help=shortcd enabled=(specialization(guardian))
{
    GuardianDefaultShortCDActions()
}

AddIcon enemies=1 help=main enabled=(specialization(guardian))
{
    GuardianDefaultMainActions()
}

AddIcon help=aoe enabled=(checkboxon(opt_druid_guardian_aoe) and specialization(guardian))
{
    GuardianDefaultAoEActions()
}

AddIcon help=cd enabled=(specialization(guardian))
{
    GuardianDefaultCdActions()
}

AddIcon size=small enabled=(checkboxon(opt_druid_guardian_offensive) and specialization(guardian))
{
    GuardianDefaultOffensiveActions()
}
]]
    OvaleScripts:RegisterScript("DRUID", "guardian", name, desc, code, "script")
end