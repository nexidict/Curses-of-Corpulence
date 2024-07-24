require "/scripts/messageutil.lua"
require "/scripts/util.lua"
starPounds = getmetatable ''.starPounds

function init()
    tabs = root.assetJson("/scripts/corpulence/corpulence_options.config:tabs")

    if starPounds then
        populateTabs()
    end
end

function update()
    if isAdmin ~= admin() then
        isAdmin = admin()
        weightDecrease:setVisible(isAdmin)
        weightIncrease:setVisible(isAdmin)
        barPadding:setVisible(not isAdmin)
    end
end

function populateTabs()
    local firstTab = tabField:newTab(tabField.data.activeTab)
    tabField:newTab(tabField.data.codexTab)
    tabField:newTab(tabField.data.optionsTab)
    
    firstTab:select()
end

function weightDecrease:onClick()
    local progress = (starPounds.weight - starPounds.currentSize.weight)/((starPounds.sizes[starPounds.currentSizeIndex + 1] and starPounds.sizes[starPounds.currentSizeIndex + 1].weight or starPounds.settings.maxWeight) - starPounds.currentSize.weight)
    local targetWeight = starPounds.sizes[math.max(starPounds.currentSizeIndex - 1, 1)].weight
    local targetWeight2 = starPounds.sizes[starPounds.currentSizeIndex].weight
    starPounds.setWeight(metagui.checkShift() and 0 or (targetWeight + (targetWeight2 - targetWeight) * progress))
end

function weightIncrease:onClick()
    local progress = math.max(0.01, (starPounds.weight - starPounds.currentSize.weight)/((starPounds.sizes[starPounds.currentSizeIndex + 1] and starPounds.sizes[starPounds.currentSizeIndex + 1].weight or starPounds.settings.maxWeight) - starPounds.currentSize.weight))
    local targetWeight = starPounds.sizes[starPounds.currentSizeIndex + 1] and starPounds.sizes[starPounds.currentSizeIndex + 1].weight or starPounds.settings.maxWeight
    local targetWeight2 = starPounds.sizes[starPounds.currentSizeIndex + 2] and starPounds.sizes[starPounds.currentSizeIndex + 2].weight or starPounds.settings.maxWeight
    starPounds.setWeight(metagui.checkShift() and starPounds.settings.maxWeight or (targetWeight + (targetWeight2 - targetWeight) * progress))
end

function enable:onClick()
    local buttonIcon = string.format("%s.png", starPounds.toggleEnable() and "enabled" or "disabled")
    enable:setImage(buttonIcon, buttonIcon, buttonIcon.."?border=2;00000000;00000000?crop=2;3;88;22")
end

function reset:onClick()
    local confirmLayout = sb.jsonMerge(root.assetJson("/interface/confirmation/resetstarpoundsconfirmation.config"), {
        title = "Curses",
        icon = "/interface/scripted/starpounds/curses/icon.png",
        images = { portrait = world.entityPortrait(player.id(), "full") }
    })

    promises:add(
        player.confirm(confirmLayout), 
        function(response)
            if response then
                promises:add(world.sendEntityMessage(player.id(), "starPounds.reset"), 
                    function()
                        local buttonIcon = "disabled.png"
                        enable:setImage(buttonIcon, buttonIcon, buttonIcon.."?border=2;00000000;00000000?crop=2;3;88;22")
                    end
                )
            end
        end
    )
end

function admin()
    return (player.isAdmin() or starPounds.hasOption("admin")) or false
end

function replaceInData(data, keyname, value, replacevalue)
    if type(data) == "table" then
        for k, v in pairs(data) do
            if (k == keyname or keyname == nil) and (v == value or value == nil) then
                -- sb.logInfo("Replacing value %s of key %s with value %s", v, k, replacevalue)
                data[k] = replacevalue
            else
                replaceInData(v, keyname, value, replacevalue)
            end
        end
    end
end