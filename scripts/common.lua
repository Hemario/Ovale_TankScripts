local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[8.2.0] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

AddFunction AzeriteEssenceMain
{
    Spell(concentrated_flame_essence)
}

AddFunction AzeriteEssenceOffensiveCooldowns
{
}

AddFunction AzeriteEssenceDefensiveCooldowns
{
}

]]
    OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
