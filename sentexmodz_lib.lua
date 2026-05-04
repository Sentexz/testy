-- ============================================================
-- SENTEXMODZ LIBRARY v6.0 - DIBUJO NATIVO (FONDO NEGRO ASEGURADO)
-- Usa DrawRect y DrawText nativos, coordenadas normalizadas
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.SelectingKey = false
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil
Menu.LoadingComplete = false
Menu.CurrentCategory = 2
Menu.CurrentItem = 1
Menu.ItemsPerPage = 9
Menu.OpenedCategory = nil
Menu.CurrentTab = 1
Menu.Scale = 1.0

-- Colores (verde lima)
local lime = { r = 50, g = 205, b = 50 }
local black = { r = 0, g = 0, b = 0 }
local white = { r = 255, g = 255, b = 255 }

-- Posición y tamaño del menú (coordenadas normalizadas)
local menu = {
    x = 0.10,   -- 10% desde la izquierda
    y = 0.10,   -- 10% desde arriba
    w = 0.22,   -- 22% del ancho de la pantalla
    h = 0.70    -- 70% del alto
}
local itemH = 0.045
local headerH = 0.09
local tabH = 0.04
local footerH = 0.03

-- Lista de categorías (de prueba)
local categories = {
    "Player",
    "Vehicle",
    "World",
    "Online",
    "Settings"
}

-- Funciones de dibujo NATIVAS (siempre funcionan)
local function DrawRect(x, y, w, h, r, g, b, a)
    DrawRect(x, y, w, h, r, g, b, a)
end

local function DrawText(text, x, y, scale, r, g, b, a, center)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextCentre(center or false)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

-- Fondo del menú principal (negro opaco)
local function DrawMenuBackground()
    DrawRect(menu.x + menu.w/2, menu.y + menu.h/2, menu.w, menu.h, black.r, black.g, black.b, 255)
    -- Borde verde lima
    DrawRect(menu.x + menu.w/2, menu.y + 0.002, menu.w, 0.002, lime.r, lime.g, lime.b, 255)
    DrawRect(menu.x + menu.w/2, menu.y + menu.h - 0.002, menu.w, 0.002, lime.r, lime.g, lime.b, 255)
    DrawRect(menu.x + 0.002, menu.y + menu.h/2, 0.002, menu.h, lime.r, lime.g, lime.b, 255)
    DrawRect(menu.x + menu.w - 0.002, menu.y + menu.h/2, 0.002, menu.h, lime.r, lime.g, lime.b, 255)
end

-- Cabecera (solo texto, porque el banner es opcional)
local function DrawHeader()
    DrawRect(menu.x + menu.w/2, menu.y + headerH/2, menu.w, headerH, 0,0,0, 255)
    DrawText("SENTEXMODZ", menu.x + menu.w/2, menu.y + headerH/2 - 0.015, 0.6, lime.r, lime.g, lime.b, 255, true)
end

-- Lista de categorías
local function DrawCategories()
    local startY = menu.y + headerH
    local visible = math.min(#categories, Menu.ItemsPerPage)
    for i = 1, visible do
        local y = startY + (i-1) * itemH
        local isSelected = (i == Menu.CurrentCategory - 1)
        -- Fondo de la opción
        DrawRect(menu.x + menu.w/2, y + itemH/2, menu.w - 0.01, itemH - 0.002, 30,30,30, 255)
        if isSelected then
            DrawRect(menu.x + 0.008, y + itemH/2, 0.006, itemH - 0.002, lime.r, lime.g, lime.b, 255)
        end
        DrawText(categories[i], menu.x + 0.025, y + itemH/2 - 0.009, 0.32, white.r, white.g, white.b, 255, false)
        DrawText(">", menu.x + menu.w - 0.025, y + itemH/2 - 0.009, 0.32, 180,180,180, 255, false)
    end
end

-- Pie de página
local function DrawFooter()
    local y = menu.y + headerH + (Menu.ItemsPerPage * itemH) + 0.01
    DrawRect(menu.x + menu.w/2, y + footerH/2, menu.w, footerH, 0,0,0, 255)
    DrawText("discord.gg/vanitymenu", menu.x + 0.01, y + footerH/2 - 0.008, 0.22, 150,150,150, 255, false)
    local posText = string.format("%d/%d", Menu.CurrentCategory-1, #categories)
    DrawText(posText, menu.x + menu.w - 0.05, y + footerH/2 - 0.008, 0.22, 150,150,150, 255, false)
end

-- Selector de tecla (diseño simple pero funcional)
local quickKeys = {
    { code = 0x60, name = "Numpad 0" },
    { code = 0x79, name = "F10" },
    { code = 0x2D, name = "Insert" }
}
local selectedQuick = 1

local function DrawKeySelector()
    local w, h = 0.26, 0.18
    local x, y = 0.5 - w/2, 0.5 - h/2
    DrawRect(x + w/2, y + h/2, w, h, 0,0,0, 220)
    DrawRect(x + w/2, y + h/2, w, h, lime.r, lime.g, lime.b, 255)  -- borde
    DrawRect(x + w/2, y + h/2, w - 0.004, h - 0.004, 0,0,0, 220)
    DrawText("Tecla de apertura", x + w/2, y + 0.035, 0.35, lime.r, lime.g, lime.b, 255, true)
    DrawText("Presiona cualquier tecla", x + w/2, y + 0.075, 0.24, 220,220,220, 255, true)
    local btnW = 0.06
    local startX = x + w/2 - (btnW * 3)/2 - 0.01
    for i, key in ipairs(quickKeys) do
        local bx = startX + (i-1)*(btnW+0.01)
        local isHover = (i == selectedQuick)
        DrawRect(bx + btnW/2, y + 0.12, btnW, 0.04, isHover and lime.r or 60, isHover and lime.g or 60, isHover and lime.b or 60, 255)
        DrawText(key.name, bx + btnW/2, y + 0.12 - 0.01, 0.22, 255,255,255, 255, true)
    end
    if Menu.SelectedKeyName then
        DrawText("Tecla: " .. Menu.SelectedKeyName, x + w/2, y + 0.165, 0.22, 255,255,255, 255, true)
    else
        DrawText("⌨️ Esperando...", x + w/2, y + 0.165, 0.22, 200,200,200, 255, true)
    end
end

-- Render principal
function Menu.Render()
    if Menu.SelectingKey then
        Susano.BeginFrame()
        DrawKeySelector()
        Susano.SubmitFrame()
    elseif Menu.Visible then
        Susano.BeginFrame()
        DrawMenuBackground()
        DrawHeader()
        DrawCategories()
        DrawFooter()
        Susano.SubmitFrame()
    end
end

-- Manejo de teclas (simplificado)
Menu.KeyStates = {}
function Menu.IsKeyJustPressed(key)
    if not Susano or not Susano.GetAsyncKeyState then return false end
    local down, pressed = Susano.GetAsyncKeyState(key)
    local was = Menu.KeyStates[key] or false
    Menu.KeyStates[key] = down
    return pressed or (down and not was)
end

function Menu.HandleInput()
    if Menu.SelectingKey then
        if Menu.IsKeyJustPressed(0x25) then selectedQuick = math.max(1, selectedQuick - 1)
        elseif Menu.IsKeyJustPressed(0x27) then selectedQuick = math.min(#quickKeys, selectedQuick + 1)
        elseif Menu.IsKeyJustPressed(0x0D) then
            if Menu.SelectedKey then
                Menu.SelectingKey = false
                Menu.Visible = false
                if Susano and Susano.ShowNotification then
                    Susano.ShowNotification("Tecla guardada: "..Menu.SelectedKeyName, 2000)
                end
            else
                local key = quickKeys[selectedQuick]
                Menu.SelectedKey = key.code
                Menu.SelectedKeyName = key.name
                Menu.SelectingKey = false
                Menu.Visible = false
                if Susano and Susano.ShowNotification then
                    Susano.ShowNotification("Tecla rápida: "..key.name, 2000)
                end
            end
            return
        end
        local forbidden = {0x0D, 0x25, 0x27}
        for k, name in pairs(Menu.KeyNames or {}) do
            local isForbidden = false
            for _, f in ipairs(forbidden) do if k == f then isForbidden = true break end end
            if not isForbidden and Menu.IsKeyJustPressed(k) then
                Menu.SelectedKey = k
                Menu.SelectedKeyName = name
                break
            end
        end
        return
    end

    if not Menu.Visible then
        if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
            Menu.Visible = true
        end
        return
    end

    if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
        Menu.Visible = false
        return
    end

    if Menu.IsKeyJustPressed(0x26) then
        Menu.CurrentCategory = Menu.CurrentCategory - 1
        if Menu.CurrentCategory < 2 then Menu.CurrentCategory = #categories + 1 end
    elseif Menu.IsKeyJustPressed(0x28) then
        Menu.CurrentCategory = Menu.CurrentCategory + 1
        if Menu.CurrentCategory > #categories + 1 then Menu.CurrentCategory = 2 end
    elseif Menu.IsKeyJustPressed(0x0D) then
        -- Aquí se puede abrir submenú más adelante
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("Opción: " .. categories[Menu.CurrentCategory-1], 1500)
        end
    end
end

-- Mapa de nombres de teclas (básico)
Menu.KeyNames = {
    [0x60] = "Numpad 0", [0x61] = "Numpad 1", [0x62] = "Numpad 2", [0x63] = "Numpad 3",
    [0x64] = "Numpad 4", [0x65] = "Numpad 5", [0x66] = "Numpad 6", [0x67] = "Numpad 7",
    [0x68] = "Numpad 8", [0x69] = "Numpad 9", [0x70] = "F1", [0x71] = "F2",
    [0x72] = "F3", [0x73] = "F4", [0x74] = "F5", [0x75] = "F6", [0x76] = "F7",
    [0x77] = "F8", [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
    [0x2D] = "Insert", [0x2E] = "Delete", [0x24] = "Home", [0x23] = "End",
    [0x21] = "Page Up", [0x22] = "Page Down", [0x25] = "Left", [0x27] = "Right",
    [0x26] = "Up", [0x28] = "Down", [0x20] = "Space", [0x0D] = "Enter"
}

-- Inicialización
CreateThread(function()
    Citizen.Wait(1000)
    Menu.SelectingKey = true
    while true do
        Menu.Render()
        if Menu.SelectingKey or Menu.Visible then
            Menu.HandleInput()
        end
        Wait(0)
    end
end)

return Menu
