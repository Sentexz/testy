-- ============================================================
-- SENTEXMODZ LIBRARY v6.2 - DISEÑO RICOMENU (corregido)
-- Con selector de tecla, banner y dibujo estable
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.CurrentSubmenu = nil
Menu.CurrentOption = 1
Menu.OptionCount = 0
Menu.SelectingKey = false
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil
Menu.LoadingComplete = false
Menu.IsLoading = true
Menu.LoadingProgress = 0
Menu.LoadingStartTime = nil
Menu.LoadingDuration = 3000

-- Banner
Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.imgur.com/JV6Drrz.png",
    height = 100
}
Menu.bannerTexture = nil

-- Configuración visual (basada en tema "infamous" de RicoMenu)
Menu.Style = {
    menuX = 0.025,          -- posición X (esquina izquierda)
    menuY = 0.025,          -- posición Y (esquina superior)
    menuWidth = 0.23,       -- ancho
    maxOptions = 13,        -- máx. opciones visibles
    titleHeight = 0.15,     -- altura del título
    titleXOffset = 0.5,     -- centrado
    titleYOffset = 0.05,
    buttonHeight = 0.045,
    buttonScale = 0.380,
    buttonTextXOffset = 0.010,
    buttonTextYOffset = 0.010,
    titleFont = 4,
    titleColor = { r = 240, g = 240, b = 240, a = 255 },
    titleBackgroundColor = { r = 61, g = 248, b = 249, a = 255 },
    menuBackgroundColor = { r = 38, g = 38, b = 38, a = 180 },  -- más opaco
    menuFocusBackgroundColor = { r = 61, g = 248, b = 249, a = 255 },
    menuTextColor = { r = 255, g = 255, b = 255, a = 255 },
    menuSubTextColor = { r = 240, g = 240, b = 240, a = 255 },
    menuFocusTextColor = { r = 0, g = 0, b = 0, a = 255 },
    subTitleBackgroundColor = { r = 38, g = 38, b = 38, a = 255 },
}

-- Teclas de navegación
Menu.Keys = {
    up = 172, down = 173, left = 174, right = 175, select = 191, back = 202
}

-- Mapeo de teclas
Menu.KeyNames = {
    [0x08] = "Backspace", [0x09] = "Tab", [0x0D] = "Enter", [0x10] = "Shift",
    [0x11] = "Ctrl", [0x12] = "Alt", [0x1B] = "ESC", [0x20] = "Space",
    [0x21] = "Page Up", [0x22] = "Page Down", [0x23] = "End", [0x24] = "Home",
    [0x25] = "Left", [0x26] = "Up", [0x27] = "Right", [0x28] = "Down",
    [0x2D] = "Insert", [0x2E] = "Delete", [0x30] = "0", [0x31] = "1",
    [0x32] = "2", [0x33] = "3", [0x34] = "4", [0x35] = "5",
    [0x36] = "6", [0x37] = "7", [0x38] = "8", [0x39] = "9",
    [0x41] = "A", [0x42] = "B", [0x43] = "C", [0x44] = "D", [0x45] = "E",
    [0x46] = "F", [0x47] = "G", [0x48] = "H", [0x49] = "I", [0x4A] = "J",
    [0x4B] = "K", [0x4C] = "L", [0x4D] = "M", [0x4E] = "N", [0x4F] = "O",
    [0x50] = "P", [0x51] = "Q", [0x52] = "R", [0x53] = "S", [0x54] = "T",
    [0x55] = "U", [0x56] = "V", [0x57] = "W", [0x58] = "X", [0x59] = "Y",
    [0x5A] = "Z", [0x60] = "Numpad 0", [0x61] = "Numpad 1", [0x62] = "Numpad 2",
    [0x63] = "Numpad 3", [0x64] = "Numpad 4", [0x65] = "Numpad 5", [0x66] = "Numpad 6",
    [0x67] = "Numpad 7", [0x68] = "Numpad 8", [0x69] = "Numpad 9",
    [0x6A] = "Multiply", [0x6B] = "Add", [0x6D] = "Subtract", [0x6E] = "Decimal",
    [0x6F] = "Divide", [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
    [0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
    [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
    [0xA0] = "Left Shift", [0xA1] = "Right Shift", [0x90] = "Num Lock", [0x91] = "Scroll Lock"
}
function Menu.GetKeyName(code) return Menu.KeyNames[code] or ("0x"..string.format("%02X", code)) end

-- Estructura del menú principal (categorías)
Menu.Structure = {
    { name = "Online Options", submenu = "player" },
    { name = "Self Options", submenu = "self" },
    { name = "Models Options", submenu = "appearance" },
    { name = "Weapon Options", submenu = "weapon" },
    { name = "Vehicle Options", submenu = "vehicle" },
    { name = "World Options", submenu = "world" },
    { name = "Teleport Options", submenu = "teleport" },
    { name = "Visual Options", submenu = "misc" },
    { name = "Objects Options", submenu = "objectspawner" },
    { name = "Server Options", submenu = "fuckserver" },
    { name = "Lua Options", submenu = "lua" },
    { name = "Exit Menu", action = "exit" }
}

-- Submenús (vacíos, se llenan desde el executor)
Menu.Submenus = {
    player = { title = "Online Options", items = {} },
    self = { title = "Self Options", items = {} },
    appearance = { title = "Appearance Options", items = {} },
    weapon = { title = "Weapon Options", items = {} },
    vehicle = { title = "Vehicle Options", items = {} },
    world = { title = "World Options", items = {} },
    teleport = { title = "Teleport Options", items = {} },
    misc = { title = "Visual Options", items = {} },
    objectspawner = { title = "Objects Options", items = {} },
    fuckserver = { title = "Server Options", items = {} },
    lua = { title = "Lua Options", items = {} }
}

-- ============================================================
-- FUNCIONES DE DIBUJO (usando DrawRect nativo para fiabilidad)
-- ============================================================
function Menu.DrawRect(x, y, w, h, r, g, b, a)
    DrawRect(x + w/2, y + h/2, w, h, r, g, b, a)
end

function Menu.DrawText(x, y, text, font, scale, r, g, b, a, center, rightJustify)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center or false)
    if rightJustify then
        SetTextWrap(x - 0.01, x + Menu.Style.menuWidth)
        SetTextRightJustify(true)
    end
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end

-- Cargar banner
function Menu.LoadBannerTexture(url)
    if not url or not Susano or not Susano.HttpGet or not Susano.LoadTextureFromBuffer then return end
    CreateThread(function()
        local status, body = Susano.HttpGet(url)
        if status == 200 and body and #body > 0 then
            local tex = Susano.LoadTextureFromBuffer(body)
            if tex then Menu.bannerTexture = tex end
        end
    end)
end

function Menu.DrawHeader()
    local x = Menu.Style.menuX
    local y = Menu.Style.menuY
    local w = Menu.Style.menuWidth
    local h = Menu.Banner.height / 1080.0  -- convertir a coordenadas relativas (1080p)
    if Menu.Banner.enabled and Menu.bannerTexture and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, w, h, 1,1,1,1,0)
    else
        Menu.DrawRect(x, y, w, h, Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, 255)
        Menu.DrawText(x + w/2, y + h/2 - 0.02, "SENTEXMODZ", Menu.Style.titleFont, Menu.Style.buttonScale, 255,255,255,255, true)
    end
end

function Menu.DrawTitle()
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local xText = Menu.Style.menuX + Menu.Style.menuWidth * Menu.Style.titleXOffset
    local headerH = Menu.Banner.height / 1080.0
    local y = Menu.Style.menuY + headerH + Menu.Style.titleHeight / 2
    local title = (Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].title) or "SENTEXMODZ"
    Menu.DrawRect(Menu.Style.menuX, y - Menu.Style.titleHeight/2, Menu.Style.menuWidth, Menu.Style.titleHeight,
        Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, Menu.Style.titleBackgroundColor.a)
    Menu.DrawText(xText, y - Menu.Style.titleHeight/2 + Menu.Style.titleYOffset, title, Menu.Style.titleFont, Menu.Style.buttonScale,
        Menu.Style.titleColor.r, Menu.Style.titleColor.g, Menu.Style.titleColor.b, Menu.Style.titleColor.a, true)
end

function Menu.DrawSubTitle()
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local headerH = Menu.Banner.height / 1080.0
    local y = Menu.Style.menuY + headerH + Menu.Style.titleHeight + Menu.Style.buttonHeight / 2
    local subTitle = Menu.CurrentSubmenu and (Menu.CurrentSubmenu:upper() .. " OPTIONS") or "MAIN MENU"
    Menu.DrawRect(x, y, Menu.Style.menuWidth, Menu.Style.buttonHeight,
        Menu.Style.subTitleBackgroundColor.r, Menu.Style.subTitleBackgroundColor.g, Menu.Style.subTitleBackgroundColor.b, Menu.Style.subTitleBackgroundColor.a)
    Menu.DrawText(Menu.Style.menuX + Menu.Style.buttonTextXOffset, y - Menu.Style.buttonHeight/2 + Menu.Style.buttonTextYOffset,
        subTitle, 0, Menu.Style.buttonScale, 255, 255, 255, 255, false)
    if Menu.OptionCount > Menu.Style.maxOptions then
        local posText = tostring(Menu.CurrentOption) .. " / " .. tostring(Menu.OptionCount)
        Menu.DrawText(Menu.Style.menuX + Menu.Style.menuWidth - 0.02, y - Menu.Style.buttonHeight/2 + Menu.Style.buttonTextYOffset,
            posText, 0, Menu.Style.buttonScale, 200, 200, 200, 255, false, true)
    end
end

function Menu.DrawButton(text, subText, isCurrent)
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local multiplier = nil
    if Menu.CurrentOption <= Menu.Style.maxOptions and Menu.OptionCount <= Menu.Style.maxOptions then
        multiplier = Menu.OptionCount
    elseif Menu.OptionCount > Menu.CurrentOption - Menu.Style.maxOptions and Menu.OptionCount <= Menu.CurrentOption then
        multiplier = Menu.OptionCount - (Menu.CurrentOption - Menu.Style.maxOptions)
    end
    if multiplier then
        local headerH = Menu.Banner.height / 1080.0
        local y = Menu.Style.menuY + headerH + Menu.Style.titleHeight + Menu.Style.buttonHeight + (Menu.Style.buttonHeight * multiplier) - Menu.Style.buttonHeight/2
        local bgColor, textColor, subTextColor
        if isCurrent then
            bgColor = Menu.Style.menuFocusBackgroundColor
            textColor = Menu.Style.menuFocusTextColor
            subTextColor = Menu.Style.menuFocusTextColor
        else
            bgColor = Menu.Style.menuBackgroundColor
            textColor = Menu.Style.menuTextColor
            subTextColor = Menu.Style.menuSubTextColor
        end
        Menu.DrawRect(x, y, Menu.Style.menuWidth, Menu.Style.buttonHeight, bgColor.r, bgColor.g, bgColor.b, bgColor.a)
        Menu.DrawText(Menu.Style.menuX + Menu.Style.buttonTextXOffset, y - Menu.Style.buttonHeight/2 + Menu.Style.buttonTextYOffset,
            text, 0, Menu.Style.buttonScale, textColor.r, textColor.g, textColor.b, textColor.a, false, false)
        if subText then
            Menu.DrawText(Menu.Style.menuX + Menu.Style.menuWidth - Menu.Style.buttonTextXOffset, y - Menu.Style.buttonHeight/2 + Menu.Style.buttonTextYOffset,
                subText, 0, Menu.Style.buttonScale, subTextColor.r, subTextColor.g, subTextColor.b, subTextColor.a, false, true)
        end
    end
end

function Menu.Draw()
    if Menu.SelectingKey then
        Menu.DrawKeySelector()
        return
    end
    if not Menu.Visible then return end
    Menu.OptionCount = 0
    local items = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].items or Menu.Structure
    if not items or #items == 0 then return end
    local startIdx = math.max(1, Menu.CurrentOption - Menu.Style.maxOptions)
    local endIdx = math.min(#items, startIdx + Menu.Style.maxOptions - 1)
    Menu.OptionCount = #items
    Menu.DrawHeader()
    Menu.DrawTitle()
    Menu.DrawSubTitle()
    for i = startIdx, endIdx do
        local item = items[i]
        local isCurrent = (i == Menu.CurrentOption)
        local subText = nil
        if item.type == "toggle" then
            subText = item.value and "~g~On" or "~r~Off"
        elseif item.type == "slider" then
            subText = tostring(item.value)
        end
        Menu.DrawButton(item.name, subText, isCurrent)
    end
end

-- ============================================================
-- SELECTOR DE TECLA
-- ============================================================
local quickKeys = {
    { code = 0x60, name = "Numpad 0" },
    { code = 0x79, name = "F10" },
    { code = 0x2D, name = "Insert" }
}
local selectedQuick = 1

function Menu.DrawKeySelector()
    local sw, sh = GetActiveScreenResolution()
    local w, h = 500/sw, 280/sh  -- coordenadas relativas
    local x, y = (1-w)/2, (1-h)/2
    Menu.DrawRect(x, y, w, h, 0,0,0, 200)
    Menu.DrawRect(x, y, w, 0.01, Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, 255)
    Menu.DrawText(x+w/2, y+0.05, "🔑 SELECCIONA TECLA DE APERTURA", Menu.Style.titleFont, 0.5, Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, 255, true)
    Menu.DrawText(x+w/2, y+0.1, "Presiona cualquier tecla o elige una rápida:", 0, 0.35, 220,220,220, 200, true)
    local btnW = 0.12
    local btnH = 0.05
    local startX = x + w/2 - (btnW * 3)/2 - 0.01
    for i, key in ipairs(quickKeys) do
        local btnX = startX + (i-1)*(btnW+0.01)
        local isHover = (i == selectedQuick)
        local col = isHover and { Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b } or {40,40,40}
        Menu.DrawRect(btnX, y+0.15, btnW, btnH, col[1], col[2], col[3], 255)
        Menu.DrawText(btnX+btnW/2, y+0.15+btnH/2-0.01, key.name, 0, 0.35, 255,255,255, 255, true)
    end
    if Menu.SelectedKeyName then
        Menu.DrawRect(x+w/2-0.1, y+0.22, 0.2, 0.06, Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, 200)
        Menu.DrawText(x+w/2, y+0.25, Menu.SelectedKeyName, 0, 0.45, 0,0,0, 255, true)
        Menu.DrawText(x+w/2, y+0.3, "▶ Presiona ENTER para guardar", 0, 0.3, 200,200,200, 180, true)
    else
        local pulse = 0.7 + math.sin(GetGameTimer()/200)*0.3
        Menu.DrawText(x+w/2, y+0.27, "⌨️ Esperando tecla... ⌨️", 0, 0.35, 200*pulse,200*pulse,200*pulse, 200, true)
    end
end

-- ============================================================
-- MANEJO DE TECLAS
-- ============================================================
Menu.KeyStates = {}
function Menu.IsKeyJustPressed(key)
    if not Susano or not Susano.GetAsyncKeyState then
        return IsControlJustPressed(1, key)
    end
    local down, pressed = Susano.GetAsyncKeyState(key)
    local was = Menu.KeyStates[key] or false
    Menu.KeyStates[key] = down
    return pressed or (down and not was)
end

function Menu.HandleInput(actionHandler)
    if Menu.SelectingKey then
        if Menu.IsKeyJustPressed(0x25) then selectedQuick = math.max(1, selectedQuick - 1)
        elseif Menu.IsKeyJustPressed(0x27) then selectedQuick = math.min(#quickKeys, selectedQuick + 1)
        elseif Menu.IsKeyJustPressed(0x0D) then
            if Menu.SelectedKey then
                Menu.SelectingKey = false
                Menu.Visible = false
                if Susano and Susano.ShowNotification then
                    Susano.ShowNotification("~g~Tecla guardada: "..Menu.SelectedKeyName, 2000)
                end
            else
                local key = quickKeys[selectedQuick]
                Menu.SelectedKey = key.code
                Menu.SelectedKeyName = key.name
                Menu.SelectingKey = false
                Menu.Visible = false
                if Susano and Susano.ShowNotification then
                    Susano.ShowNotification("~g~Tecla rápida guardada: "..key.name, 2000)
                end
            end
            return
        end
        local forbidden = {0x0D, 0x25, 0x27, 0x26, 0x28}
        for k, _ in pairs(Menu.KeyNames) do
            local isForbidden = false
            for _, f in ipairs(forbidden) do if k == f then isForbidden = true break end end
            if not isForbidden and Menu.IsKeyJustPressed(k) then
                Menu.SelectedKey = k
                Menu.SelectedKeyName = Menu.GetKeyName(k)
                break
            end
        end
        return
    end

    if not Menu.Visible then
        if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
            Menu.Visible = true
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        end
        return
    end

    if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
        Menu.Visible = false
        return
    end

    local items = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].items or Menu.Structure
    if not items or #items == 0 then return end

    if Menu.IsKeyJustPressed(Menu.Keys.down) then
        Menu.CurrentOption = (Menu.CurrentOption % #items) + 1
    elseif Menu.IsKeyJustPressed(Menu.Keys.up) then
        Menu.CurrentOption = ((Menu.CurrentOption - 2 + #items) % #items) + 1
    elseif Menu.IsKeyJustPressed(Menu.Keys.select) then
        local item = items[Menu.CurrentOption]
        if item then
            if item.submenu then
                Menu.CurrentSubmenu = item.submenu
                Menu.CurrentOption = 1
            elseif item.type == "toggle" then
                item.value = not item.value
                if actionHandler then actionHandler(item.actionKey, item.value) end
            elseif item.type == "slider" then
                -- handled by left/right
            elseif item.type == "action" then
                if actionHandler then actionHandler(item.actionKey) end
            elseif item.action == "exit" then
                Menu.Visible = false
            end
        end
    elseif Menu.IsKeyJustPressed(Menu.Keys.back) then
        if Menu.CurrentSubmenu then
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        else
            Menu.Visible = false
        end
    elseif Menu.IsKeyJustPressed(Menu.Keys.left) then
        local item = items[Menu.CurrentOption]
        if item and item.type == "slider" then
            item.value = math.max(item.min, item.value - (item.step or 1))
            if actionHandler then actionHandler(item.actionKey, item.value) end
        end
    elseif Menu.IsKeyJustPressed(Menu.Keys.right) then
        local item = items[Menu.CurrentOption]
        if item and item.type == "slider" then
            item.value = math.min(item.max, item.value + (item.step or 1))
            if actionHandler then actionHandler(item.actionKey, item.value) end
        end
    end
end

-- ============================================================
-- RENDER Y CICLO PRINCIPAL
-- ============================================================
function Menu.Render()
    if not Susano or not Susano.BeginFrame then return end
    Susano.BeginFrame()
    Menu.Draw()
    Susano.SubmitFrame()
end

function Menu.Start(actionHandler)
    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end

    CreateThread(function()
        Menu.LoadingStartTime = GetGameTimer()
        while Menu.IsLoading do
            local elapsed = GetGameTimer() - Menu.LoadingStartTime
            Menu.LoadingProgress = math.min(100, (elapsed / 3000) * 100)
            if elapsed >= 3000 then
                Menu.IsLoading = false
                Menu.LoadingComplete = true
                Menu.SelectingKey = true
                break
            end
            Wait(0)
        end
    end)

    CreateThread(function()
        while true do
            Menu.Render()
            if Menu.LoadingComplete then
                Menu.HandleInput(actionHandler)
            end
            Wait(0)
        end
    end)
end

return Menu
