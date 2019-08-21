local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts
do
    local name = "ovale_tankscripts_common"
    local desc = "[8.2.0] Ovale_TankScripts: Common"
    local code = [[
Include(ovale_common)

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

]]
    OvaleScripts:RegisterScript(nil, nil, name, desc, code, "include")
end
