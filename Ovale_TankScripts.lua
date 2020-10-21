-- Overwrite Default script selection for tank classes
local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScriptsClass

local baseGetDefaultScriptName = OvaleScripts.GetDefaultScriptName
OvaleScripts.GetDefaultScriptName = function(self, className, specialization)
    --print("Ovale_TankScripts GetDefaultScriptName")
    if false
        --or (className == "DEATHKNIGHT" and specialization == "blood") 
        --or (className == "DEMONHUNTER" and specialization == "vengeance") 
        --or (className == "DRUID" and specialization == "guardian")
        or (className == "MONK" and specialization == "brewmaster") 
        or (className == "PALADIN" and specialization == "protection")
        --or (className == "WARRIOR" and specialization == "protection")
    then
        return format("ovale_tankscripts_%s_%s", string.lower(className), specialization)
    else
        return baseGetDefaultScriptName(self, className, specialization)
    end
end