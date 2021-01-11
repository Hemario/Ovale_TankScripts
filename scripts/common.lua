local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[9.0.2] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

Define(grim_codex 178811)
    ItemRequire(grim_codex unusable set=1 enabled=(target.isfriend()))
Define(mistcaller_ocarina 178715)
    ItemRequire(mistcaller_ocarina unusable set=1 enabled=(InCombat() or player.BuffPresent(mistcaller_ocarina_buff)))
Define(mistcaller_ocarina_crit_buff 332299)
Define(mistcaller_ocarina_haste_buff 332300)
Define(mistcaller_ocarina_mastery_buff 332301)
Define(mistcaller_ocarina_vers_buff 330067)
SpellList(mistcaller_ocarina_buff mistcaller_ocarina_crit_buff mistcaller_ocarina_haste_buff mistcaller_ocarina_mastery_buff mistcaller_ocarina_vers_buff)

Define(item_abyssal_healing_potion 169451)
Define(item_coastal_healing_potion 152494)
Define(item_healthstone 5512)

AddFunction UseHealthPotions
{
	Item(item_healthstone usable=1)
	Item(item_abyssal_healing_potion usable=1)
	Item(item_coastal_healing_potion usable=1)
}

Define(fleshcraft 324631)
    SpellInfo(fleshcraft cd=120)
Define(phial_of_serenity 177278)
    ItemInfo(phial_of_serenity cd=180)

AddFunction CovenantShortCDHealActions
{
    if (not InCombat()) Spell(fleshcraft)
    if (HealthPercent() <= 40) Item(phial_of_serenity usable=1)
}

AddFunction CovenantDispelActions
{
    if Item(phial_of_serenity) and player.HasDebuffType(poison disease curse bleed) Item(phial_of_serenity usable=1)
}

]]
    OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
