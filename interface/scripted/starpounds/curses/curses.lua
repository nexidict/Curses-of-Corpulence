require "/scripts/messageutil.lua"
require "/scripts/util.lua"
starPounds = getmetatable ''.starPounds

function init()
    Tabs = root.assetJson("/scripts/corpulence/corpulence_curses.config:tabs")
    Curses = root.assetJson("/scripts/corpulence/corpulence_curses.config:curses")

    IsAdmin = admin()

    weightDecrease:setVisible(isAdmin)
    weightIncrease:setVisible(isAdmin)
    barPadding:setVisible(not isAdmin)

    EnableControls = metagui.inputData.isObject or isAdmin
    SelectedCurseKey = nil

    if starPounds then
        buildTabs()
        populateCodexTab()
    end
    resetInfoPanel()
end

function update()
    if IsAdmin ~= admin() then
        IsAdmin = admin()
        weightDecrease:setVisible(isAdmin)
        weightIncrease:setVisible(isAdmin)
        barPadding:setVisible(not isAdmin)
    end

    promises:update()
end

function buildTabs()
    for _, tab in ipairs(Tabs) do
        tab.title = " "
        tab.icon = string.format("icons/tabs/%s.png", tab.id)
        tab.contents = copy(tabField.data.templateTab)
        tab.contents[1].children[2].text = tab.paneTitle
        tab.contents[1].children[3].children[1].id = string.format("panel_%s", tab.id)

        local newTab = tabField:newTab(tab)
        newTab.friendlyName = tab.friendlyName
        newTab.description = tab.description

        if not currentTab then
            currentTab = newTab
        end
    end
    currentTab:select()
end

function populateCodexTab()
    local sortedCurseKeys = {}
    for curseKey, curse in pairs(Curses) do
        table.insert(sortedCurseKeys, curseKey)
    end
    table.sort(sortedCurseKeys)

    for _, curseKey in ipairs(sortedCurseKeys) do
        local curse = Curses[curseKey]
        if _ENV["panel_codex"] then
            _ENV["panel_codex"]:addChild(makeCurseWidget(curseKey, curse))
            _ENV[string.format("%sCurse", curseKey)].onClick = function() selectCurse(curseKey, curse) end
        end
    end
end

function makeCurseWidget(curseKey, curse)
    if not curse then return end

    local curseWidget = {
        type = "layout", size = {142, 20}, mode = "manual", children = {
            { id = string.format("%sCurse_back", curseKey), type = "image", noAutoCrop = true, position = {0, 0}, file = "unselected.png" },
            { id = string.format("%sCurse_name", curseKey), type = "label", position = {22, 6}, size = {117, 9}, text = curse.friendlyName },
            { id = string.format("%sCurse_icon", curseKey), type = "image", noAutoCrop = true, position = {2, 2}, file = string.format("icons/curses/%s.png", curseKey) },
            { id = string.format("%sCurse", curseKey), type = "iconButton", size = {142, 20} }
        }
    }

    return curseWidget
end

function makeCurseWidget(curseKey, curse)
    local curseWidget = {
        type = "layout", size = {142, 20}, mode = "manual", children = {
            { id = string.format("%sCurse_back", curseKey), type = "image", noAutoCrop = true, position = {0, 0}, file = "unselected.png" },
            { id = string.format("%sCurse_name", curseKey), type = "label", position = {22, 6}, size = {117, 9}, text = curse.friendlyName },
            { id = string.format("%sCurse_icon", curseKey), type = "image", noAutoCrop = true, position = {2, 2}, file = string.format("icons/curses/%s.png", curseKey) },
            { id = string.format("%sCurse", curseKey), type = "iconButton", size = {142, 20} }
        }
    }

    return curseWidget
end

function selectCurse(curseKey, curse)
    effectsPanel:setVisible(true)
    local canIncrease = false
    local canDecrease = false
    local canUpgrade = false
    local useToggle = false

    if SelectedCurseKey and (not curseKey or SelectedCurseKey ~= curseKey) then
        _ENV[string.format("%sCurse_back", SelectedCurseKey)]:setFile("unselected.png")
        _ENV[string.format("%sCurse_back", SelectedCurseKey)]:queueRedraw()
    end

    if curseKey then
        _ENV[string.format("%sCurse_back", curseKey)]:setFile("selected.png")
        _ENV[string.format("%sCurse_back", curseKey)]:queueRedraw()

        local icon = string.format("icons/curses/%s.png", curseKey)
        detailsTitle:setText(curse.friendlyName)
        tabDescription:setText("")
        detailsDescription:setText(curse.description)
        detailsIcon:setFile(icon)
        detailsIcon:queueRedraw()
    end

    SelectedCurseKey = curseKey
end

function resetInfoPanel()
    selectCurse()
    local icon = string.format("icons/tabs/%s.png", currentTab.id)
    effectsPanel:setVisible(false)
    detailsTitle:setText(currentTab.friendlyName)
    tabDescription:setText(currentTab.description)
    detailsDescription:setText("")
    detailsIcon:setFile(icon)
    detailsIcon:queueRedraw()
end

function tabField:onTabChanged(tab, previous)
    if currentTab then
        currentTab = tab
        resetInfoPanel()
    end
end

function enable:onClick()
  local buttonIcon = string.format("%s.png", starPounds.toggleEnable() and "enabled" or "disabled")
  enable:setImage(buttonIcon, buttonIcon, buttonIcon.."?border=2;00000000;00000000?crop=2;3;88;22")
end

function reset:onClick()
  local confirmLayout = sb.jsonMerge(root.assetJson("/interface/confirmation/resetstarpoundsconfirmation.config"), {
    title = metagui.inputData.title or "Skills",
    icon = string.format("/interface/scripted/starpounds/skills/icon%s.png", metagui.inputData.iconSuffix or ""),
    images = {
      portrait = world.entityPortrait(player.id(), "full")
    }
  })
  promises:add(player.confirm(confirmLayout), function(response)
    if response then
      promises:add(world.sendEntityMessage(player.id(), "starPounds.reset"), function()
        -- checkSkills()
        resetInfoPanel()
        -- traitButtons(true)
        local buttonIcon = "disabled.png"
        enable:setImage(buttonIcon, buttonIcon, buttonIcon.."?border=2;00000000;00000000?crop=2;3;88;22")
      end)
    end
  end)
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

function admin()
    return (player.isAdmin() or starPounds.hasOption("admin")) or false
end