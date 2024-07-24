require "/scripts/messageutil.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"

local function nullFunction()
end

corpulence = {
    stats = root.assetJson("/scripts/corpulence/")
}

corpulence.updateStatuses = function()
    corpulence.createStatuses()
    return
end

