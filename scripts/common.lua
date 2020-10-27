local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[9.0.1] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

###
### Essences
###
Define(anima_of_death_essence 294926)
    SpellInfo(anima_of_death_essence tag=cd)
Define(concentrated_flame_essence 295373)
    SpellInfo(concentrated_flame_essence cd=30 tag=main)
    Define(concentrated_flame_burn_debuff 295368)
    SpellInfo(concentrated_flame_burn_debuff duration=6)
    SpellAddTargetDebuff(concentrated_flame_essence concentrated_flame_burn_debuff=1)
Define(focused_azerite_beam_essence 295258)
    SpellInfo(focused_azerite_beam_essence cd=90 tag=cd)
Define(memory_of_lucid_dreams_essence 298357)
    SpellInfo(memory_of_lucid_dreams_essence cd=120 tag=cd)
    Define(memory_of_lucid_dreams_essence_buff 298357)
Define(ripple_in_space_essence 302731)
    SpellInfo(ripple_in_space_essence cd=60 tag=shortcd)
Define(the_unbound_force_essence 298452)
    SpellInfo(the_unbound_force_essence cd=60 tag=shortcd)
    Define(reckless_force_counter_buff 302917)
    SpellInfo(reckless_force_counter_buff max_stacks=20)
Define(worldvein_resonance_essence 295186)
    SpellInfo(worldvein_resonance_essence cd=60 tag=shortcd)
    Define(lifeblood_buff 295137)

AddFunction AzeriteEssenceMain
{
    if target.DebuffExpires(concentrated_flame_burn_debuff) Spell(concentrated_flame_essence)
}

AddFunction AzeriteEssenceOffensiveCooldowns
{
    if BuffStacks(lifeblood_buff) < 4 Spell(worldvein_resonance_essence)
    Spell(anima_of_death_essence)
}

AddFunction AzeriteEssenceDefensiveCooldowns
{
    Spell(memory_of_lucid_dreams_essence)
}

Define(item_abyssal_healing_potion 169451)
Define(item_coastal_healing_potion 152494)
Define(item_healthstone 5512)

AddFunction UseHealthPotions
{
	Item(item_healthstone usable=1)
	Item(item_abyssal_healing_potion usable=1)
	Item(item_coastal_healing_potion usable=1)
}

]]
    OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
