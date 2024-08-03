require "/scripts/messageutil.lua"
require "/scripts/util.lua"
starPounds = getmetatable ''.starPounds

function init()
    tabs = root.assetJson("/scripts/corpulence/corpulence_curses.config:tabs")
    curses = root.assetJson("/scripts/corpulence/corpulence_curses.config:curses")

    currentTab = nil

    isAdmin = admin()

    enableControls = metagui.inputData.isObject or isAdmin
    selectedCurse = nil

    if starPounds then
        buildTabs()
        populateCodexTab()
    end
    resetInfoPanel()
end

function update()
    
end

function buildTabs()
    for _, tab in ipairs(tabs) do
        tab.title = " "
        tab.icon = string.format("icons/tabs/%s.png", tab.id)
        tab.contents = copy(tabField.data.templateTab)
        tab.contents[1].children[2].text = tab.friendlyName
        tab.contents[1].children[3].children[1].id = string.format("panel_%s", tab.id)

        local newTab = tabField:newTab(tab)

        if not currentTab then
            currentTab = newTab
        end
    end
    currentTab:select()
end

function populateCodexTab()
    for curseKey, curse in pairs(curses) do
        sb.logInfo("Loop: adding "..curseKey)
        if _ENV["panel_codex"] then
            _ENV["panel_codex"]:addChild(makeCurseWidget(curseKey, curse))
            sb.logInfo(curseKey.." added")
        end
    end
end

function makeCurseWidget(curseKey, curse)
    local curseWidget = {
        type = "layout", size = {142, 20}, mode = "manual", children = {
            { id = string.format("%sCurse_back", curseKey), type = "image", noAutoCrop = true, position = {0, 0}, file = "item.png" },
            { id = string.format("%sCurse_name", curseKey), type = "label", position = {22, 6}, size = {117, 9}, text = curse.friendlyName },
            { id = string.format("%sCurse_icon", curseKey), type = "image", noAutoCrop = true, position = {2, 2}, file =  "icons/curses/placeholder.png" }
        }
    }

    return curseWidget
end

function selectCurse(curseKey, curse)
    local canIncrease = false
    local canDecrease = false
    local canUpgrade = false
    local useToggle = false
end

function resetInfoPanel()
    -- effectsPanel:setVisible(true)
end

function tabField:onTabChanged(tab, previous)
    if currentTab then
        currentTab = tab
        resetInfoPanel()
    end
end

function admin()
    return (player.isAdmin() or starPounds.hasOption("admin")) or false
end