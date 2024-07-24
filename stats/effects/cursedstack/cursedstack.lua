require "/scripts/messageutil.lua"

function init()
    message.setHandler("corpulence.expire", localHandler(effect.expire))
end

function update(dt)
    if world.entityType(entity.id()) == "player" then
    end

    
end