-- ============================================================
-- SENTEXMODZ MENU - VERSIÓN AUTOCONTENIDA (sin RAW)
-- Diseño RicoMenu, selector de tecla incluido
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.CurrentSubmenu = nil
Menu.CurrentOption = 1
Menu.SelectingKey = true
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil

-- Configuración visual
Menu.Style = {
    x = 50, y = 100, w = 360,
    bannerH = 100,
    titleH = 30,
    buttonH = 34,
    maxOptions = 12,
    bgColor = {38,38,38,200},
    focusBgColor = {61,248,249,255},
    textColor = {255,255,255,255},
    focusTextColor = {0,0,0,255},
    titleBgColor = {61,248,249,255},
    subTitleBgColor = {38,38,38,255}
}

-- Teclas de navegación (códigos FiveM nativos)
local Keys = { up = 172, down = 173, left = 174, right = 175, select = 191, back = 202 }

-- Mapeo para selector de tecla
local KeyNames = {
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
}
function GetKeyName(code) return KeyNames[code] or ("0x"..string.format("%02X", code)) end

-- Estructura del menú principal
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

-- Submenús (se rellenarán después)
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

-- Funciones de dibujo
function DrawRect(x,y,w,h,r,g,b,a)
    DrawRect(x + w/2, y + h/2, w, h, r, g, b, a)
end
function DrawText(x,y,text,font,scale,r,g,b,a,center)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r,g,b,a)
    SetTextCentre(center or false)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(x,y)
end

-- Dibujar menú
function Menu.Draw()
    if Menu.SelectingKey then
        -- Selector de tecla
        local sw, sh = GetActiveScreenResolution()
        local w, h = 500, 280
        local x, y = (sw-w)/2, (sh-h)/2
        DrawRect(x, y, w, h, 0,0,0, 200)
        DrawRect(x, y, w, 4, Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3], 255)
        DrawText(x+w/2, y+35, "🔑 SELECCIONA TECLA DE APERTURA", 4, 0.5, Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3], 255, true)
        DrawText(x+w/2, y+75, "Presiona cualquier tecla o elige una rápida:", 0, 0.35, 220,220,220, 200, true)
        local btnW, btnH = 100, 40
        local startX = x + w/2 - (btnW*3)/2 - 10
        local quickKeys = { {0x60,"Numpad 0"}, {0x79,"F10"}, {0x2D,"Insert"} }
        for i, key in ipairs(quickKeys) do
            local btnX = startX + (i-1)*(btnW+10)
            local col = (i == selectedQuick) and {Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3]} or {40,40,40}
            DrawRect(btnX, y+110, btnW, btnH, col[1], col[2], col[3], 255)
            DrawText(btnX+btnW/2, y+110+btnH/2-7, key[2], 0, 0.35, 255,255,255,255, true)
        end
        if Menu.SelectedKeyName then
            DrawRect(x+w/2-80, y+170, 160, 50, Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3], 200)
            DrawText(x+w/2, y+195, Menu.SelectedKeyName, 0, 0.45, 0,0,0,255, true)
            DrawText(x+w/2, y+240, "▶ Presiona ENTER para guardar", 0, 0.3, 200,200,200,180, true)
        else
            local pulse = 0.7 + math.sin(GetGameTimer()/200)*0.3
            DrawText(x+w/2, y+200, "⌨️ Esperando tecla... ⌨️", 0, 0.35, 200*pulse,200*pulse,200*pulse, 200, true)
        end
        return
    end
    if not Menu.Visible then return end

    local items = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].items or Menu.Structure
    if not items or #items == 0 then return end
    local totalOptions = #items
    local startIdx = math.max(1, Menu.CurrentOption - math.floor(Menu.Style.maxOptions/2))
    local endIdx = math.min(totalOptions, startIdx + Menu.Style.maxOptions - 1)
    if endIdx - startIdx + 1 < Menu.Style.maxOptions then
        startIdx = math.max(1, endIdx - Menu.Style.maxOptions + 1)
    end

    -- Banner
    DrawRect(Menu.Style.x, Menu.Style.y, Menu.Style.w, Menu.Style.bannerH, Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3], 255)
    DrawText(Menu.Style.x + Menu.Style.w/2, Menu.Style.y + Menu.Style.bannerH/2 - 10, "SENTEXMODZ", 4, 0.8, 255,255,255,255, true)

    -- Título
    local titleY = Menu.Style.y + Menu.Style.bannerH
    local title = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].title or "SENTEXMODZ"
    DrawRect(Menu.Style.x, titleY, Menu.Style.w, Menu.Style.titleH, Menu.Style.focusBgColor[1], Menu.Style.focusBgColor[2], Menu.Style.focusBgColor[3], 255)
    DrawText(Menu.Style.x + Menu.Style.w/2, titleY + Menu.Style.titleH/2 - 8, title, 4, 0.5, 240,240,240,255, true)

    -- Subtítulo
    local subY = titleY + Menu.Style.titleH
    local subTitle = Menu.CurrentSubmenu and (string.upper(Menu.CurrentSubmenu) .. " OPTIONS") or "MAIN MENU"
    DrawRect(Menu.Style.x, subY, Menu.Style.w, Menu.Style.buttonH, Menu.Style.subTitleBgColor[1], Menu.Style.subTitleBgColor[2], Menu.Style.subTitleBgColor[3], 255)
    DrawText(Menu.Style.x + 10, subY + Menu.Style.buttonH/2 - 8, subTitle, 0, 0.4, 255,255,255,255, false)
    if totalOptions > Menu.Style.maxOptions then
        DrawText(Menu.Style.x + Menu.Style.w - 50, subY + Menu.Style.buttonH/2 - 8, Menu.CurrentOption.."/"..totalOptions, 0, 0.4, 200,200,200,255, false)
    end

    -- Opciones
    local visibleIndex = 1
    for i = startIdx, endIdx do
        local item = items[i]
        local isCurrent = (i == Menu.CurrentOption)
        local y = subY + Menu.Style.buttonH + (visibleIndex-1) * Menu.Style.buttonH
        local bg = isCurrent and Menu.Style.focusBgColor or Menu.Style.bgColor
        local txtCol = isCurrent and Menu.Style.focusTextColor or Menu.Style.textColor
        DrawRect(Menu.Style.x, y, Menu.Style.w, Menu.Style.buttonH, bg[1], bg[2], bg[3], bg[4])
        DrawText(Menu.Style.x + 10, y + Menu.Style.buttonH/2 - 8, item.name, 0, 0.4, txtCol[1], txtCol[2], txtCol[3], txtCol[4], false)
        if item.type == "toggle" then
            local status = item.value and "~g~On" or "~r~Off"
            DrawText(Menu.Style.x + Menu.Style.w - 10, y + Menu.Style.buttonH/2 - 8, status, 0, 0.35, txtCol[1], txtCol[2], txtCol[3], txtCol[4], true)
        elseif item.type == "slider" then
            DrawText(Menu.Style.x + Menu.Style.w - 10, y + Menu.Style.buttonH/2 - 8, tostring(item.value), 0, 0.35, txtCol[1], txtCol[2], txtCol[3], txtCol[4], true)
        end
        visibleIndex = visibleIndex + 1
    end
end

-- Detección de teclas
local keyStates = {}
function IsKeyJustPressed(key)
    local down = IsControlJustPressed(1, key)
    local was = keyStates[key] or false
    keyStates[key] = down
    return down and not was
end

-- Manejador de input
function Menu.HandleInput(actionHandler)
    if Menu.SelectingKey then
        if IsKeyJustPressed(0x25) then selectedQuick = math.max(1, (selectedQuick or 1) - 1)
        elseif IsKeyJustPressed(0x27) then selectedQuick = math.min(3, (selectedQuick or 1) + 1)
        elseif IsKeyJustPressed(0x0D) then
            if Menu.SelectedKey then
                Menu.SelectingKey = false
                Menu.Visible = false
                print("Tecla guardada: "..Menu.SelectedKeyName)
            else
                local quickKeys = { {0x60,"Numpad 0"}, {0x79,"F10"}, {0x2D,"Insert"} }
                local key = quickKeys[selectedQuick or 1]
                Menu.SelectedKey = key[1]
                Menu.SelectedKeyName = key[2]
                Menu.SelectingKey = false
                Menu.Visible = false
                print("Tecla rápida guardada: "..key[2])
            end
            return
        end
        local forbidden = {0x0D,0x25,0x27,0x26,0x28}
        for k, _ in pairs(KeyNames) do
            local isForbidden = false
            for _, f in ipairs(forbidden) do if k == f then isForbidden = true end end
            if not isForbidden and IsKeyJustPressed(k) then
                Menu.SelectedKey = k
                Menu.SelectedKeyName = GetKeyName(k)
                break
            end
        end
        return
    end

    if not Menu.Visible then
        if Menu.SelectedKey and IsKeyJustPressed(Menu.SelectedKey) then
            Menu.Visible = true
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        end
        return
    end

    if Menu.SelectedKey and IsKeyJustPressed(Menu.SelectedKey) then
        Menu.Visible = false
        return
    end

    local items = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].items or Menu.Structure
    if not items or #items == 0 then return end

    if IsKeyJustPressed(Keys.down) then
        Menu.CurrentOption = (Menu.CurrentOption % #items) + 1
    elseif IsKeyJustPressed(Keys.up) then
        Menu.CurrentOption = ((Menu.CurrentOption - 2 + #items) % #items) + 1
    elseif IsKeyJustPressed(Keys.select) then
        local item = items[Menu.CurrentOption]
        if item then
            if item.submenu then
                Menu.CurrentSubmenu = item.submenu
                Menu.CurrentOption = 1
            elseif item.type == "toggle" then
                item.value = not item.value
                if actionHandler then actionHandler(item.actionKey, item.value) end
            elseif item.type == "action" then
                if actionHandler then actionHandler(item.actionKey) end
            elseif item.action == "exit" then
                Menu.Visible = false
            end
        end
    elseif IsKeyJustPressed(Keys.back) then
        if Menu.CurrentSubmenu then
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        else
            Menu.Visible = false
        end
    elseif IsKeyJustPressed(Keys.left) then
        local item = items[Menu.CurrentOption]
        if item and item.type == "slider" then
            item.value = math.max(item.min, item.value - (item.step or 1))
            if actionHandler then actionHandler(item.actionKey, item.value) end
        end
    elseif IsKeyJustPressed(Keys.right) then
        local item = items[Menu.CurrentOption]
        if item and item.type == "slider" then
            item.value = math.min(item.max, item.value + (item.step or 1))
            if actionHandler then actionHandler(item.actionKey, item.value) end
        end
    end
end

-- Bucle principal
Citizen.CreateThread(function()
    while true do
        Menu.Draw()
        Citizen.Wait(0)
    end
end)

-- Iniciar el selector de tecla
local function StartMenu(actionHandler)
    Menu.SelectingKey = true
    selectedQuick = 1
    while true do
        Menu.HandleInput(actionHandler)
        Citizen.Wait(0)
    end
end

-- ============================================================
-- EJEMPLO DE ACCIONES (puedes agregar las que quieras)
-- ============================================================
local function ActionHandler(_, _)
    -- Aquí irán tus funciones reales (godmode, noclip, etc.)
    -- Por ahora vacío para probar el menú
end

StartMenu(ActionHandler)
print("Menú listo. Selecciona una tecla.")
