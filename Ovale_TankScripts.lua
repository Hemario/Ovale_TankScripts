local ADDON_NAME, Private = ...

local ovale = LibStub and LibStub:GetLibrary("ovale")
local scripts = ovale and ovale.ioc and ovale.ioc.scripts

if scripts then
    -- Export
    Private.name = ADDON_NAME
    Private.scripts = scripts
    Private.initialized = true

    local baseGetDefaultScriptName = scripts.getDefaultScriptName
    do
        -- Ovale<=9.0.43
        if not baseGetDefaultScriptName then
	        baseGetDefaultScriptName = scripts.GetDefaultScriptName
        end
    end

    local getDefaultScriptName = function(self, className, specialization)
        if false
            or (className == "DEATHKNIGHT" and specialization == "blood") 
            or (className == "DEMONHUNTER" and specialization == "vengeance") 
            or (className == "DRUID" and specialization == "guardian")
            or (className == "MONK" and specialization == "brewmaster") 
            or (className == "PALADIN" and specialization == "protection")
            or (className == "WARRIOR" and specialization == "protection")
        then
            return format("ovale_tankscripts_%s_%s", string.lower(className), specialization)
        else
            return baseGetDefaultScriptName(self, className, specialization)
        end
    end

    -- Overwrite default script selection function.
    if scripts.getDefaultScriptName then
        scripts.getDefaultScriptName = getDefaultScriptName
    end
    do
        -- Ovale<=9.0.43
        if scripts.GetDefaultScriptName then
            scripts.GetDefaultScriptName = getDefaultScriptName
        end
        if not scripts.registerScript then
            scripts.registerScript = scripts.RegisterScript
        end
    end
end
