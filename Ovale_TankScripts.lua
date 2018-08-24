-- Overwrite Default script selection for tank classes
local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

local baseGetDefaultScriptName = OvaleScripts.GetDefaultScriptName
OvaleScripts.GetDefaultScriptName = function(self, className, specialization)
    local scriptName
    if (className == "DRUID" and specialization == "guardian")
        or (className == "MONK" and specialization == "brewmaster") 
        or (className == "PALADIN" and specialization == "protection")
        or (className == "WARRIOR" and specialization == "protection")
    then
        scriptName = format("icyveins_%s_%s", lower(className), specialization)
    else
        return baseGetDefaultScriptName(self, className, specialization)
    end
    return scriptName
end