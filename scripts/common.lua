local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc.scripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[9.0.1] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

Define(humming_black_dragonscale 174044)
    ItemInfo(humming_black_dragonscale unusable=1)


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
