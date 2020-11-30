local ovale = LibStub:GetLibrary("ovale")
local OvaleScripts = ovale.ioc and ovale.ioc.scripts

-- Overwrite default script selection for tank classes.
local baseGetDefaultScriptName = OvaleScripts.GetDefaultScriptName
OvaleScripts.GetDefaultScriptName = function(self, className, specialization)
    --print("Ovale_TankScripts GetDefaultScriptName")
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

-- Define our own IncomingMagicDamage() and IncomingPhysicalDamage() conditions
-- until IncomingDamage() is fixed in Ovale.

local __Condition = LibStub:GetLibrary("ovale/engine/condition")
local Compare = __Condition.Compare

local OvaleCondition = ovale.ioc and ovale.ioc.condition
local OvaleConditions = ovale.ioc and ovale.ioc.conditions
local OvaleDamageTaken = ovale.ioc and ovale.ioc.damageTaken

local function IncomingMagicDamage(positionalParams, namedParams, atTime)
    local interval, comparator, limit = positionalParams[1], positionalParams[2], positionalParams[3]
    local value = 0
    if interval > 0 then
        local _, totalMagic = OvaleDamageTaken:GetRecentDamage(interval)
        value = totalMagic
        return Compare(value, comparator, limit)
    end
end

local function IncomingPhysicalDamage(positionalParams, namedParams, atTime)
    local interval, comparator, limit = positionalParams[1], positionalParams[2], positionalParams[3]
    local value = 0
    if interval > 0 then
        local total, totalMagic = OvaleDamageTaken:GetRecentDamage(interval)
        value = total - totalMagic
        return Compare(value, comparator, limit)
    end
end

OvaleCondition:RegisterCondition("incomingmagicdamage", false, IncomingMagicDamage)
OvaleCondition:RegisterCondition("incomingphysicaldamage", false, IncomingPhysicalDamage)