local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[9.0.2] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

Define(humming_black_dragonscale 174044)
    ItemInfo(humming_black_dragonscale unusable=1)

Define(fleshcraft 324631)
    SpellInfo(fleshcraft cd=120)
Define(phial_of_serenity 177278)
    ItemInfo(phial_of_serenity cd=180)

Define(item_abyssal_healing_potion 169451)
Define(item_coastal_healing_potion 152494)
Define(item_healthstone 5512)

AddFunction UseHealthPotions
{
	Item(item_healthstone usable=1)
	Item(item_abyssal_healing_potion usable=1)
	Item(item_coastal_healing_potion usable=1)
}

AddFunction CovenantShortCDHealActions
{
    if not InCombat() Spell(fleshcraft)
}

AddFunction CovenantDispelActions
{
    if Item(phial_of_serenity) and player.HasDebuffType(poison disease curse bleed) Item(phial_of_serenity usable=1)
}

]]
    OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
