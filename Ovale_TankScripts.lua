-- Overwrite Default script selection for tank classes
local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

local baseGetDefaultScriptName = OvaleScripts.GetDefaultScriptName
OvaleScripts.GetDefaultScriptName = function(self, className, specialization)
    local scriptName
    if (className == "MONK" and specialization == "brewmaster") then
        scriptName = "icyveins_monk_brewmaster"
    else
        return baseGetDefaultScriptName(self, className, specialization)
    end
    return scriptName
end