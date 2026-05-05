-- ============================================================
-- SENTEXMODZ LIBRARY v6.0 - DISEÑO RICOMENU (infamous theme)
-- Solo visual y navegación. Las acciones se inyectan externamente.
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.CurrentCategory = nil
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

-- Configuración visual (basada en el tema "infamous" de RicoMenu)
Menu.Style = {
    menuX = 0.725,          -- posición X (0.0 - 1.0)
    menuY = 0.1,            -- posición Y
    menuWidth = 0.23,       -- ancho
    maxOptions = 13,        -- máx. opciones visibles
    titleHeight = 0.15,     -- altura del título
    titleXOffset = 0.5,     -- centrado
    titleYOffset = 0.05,
    titleSpacing = 2,
    buttonHeight = 0.045,
    buttonScale = 0.380,
    buttonTextXOffset = 0.010,
    buttonTextYOffset = 0.010,
    titleFont = 4,
    titleColor = { r = 240, g = 240, b = 240, a = 255 },
    titleBackgroundColor = { r = 61, g = 248, b = 249, a = 255 },  -- cyan
    menuBackgroundColor = { r = 38, g = 38, b = 38, a = 80 },      -- semi-transparente
    menuFocusBackgroundColor = { r = 61, g = 248, b = 249, a = 255 }, -- cyan
    menuTextColor = { r = 255, g = 255, b = 255, a = 255 },
    menuSubTextColor = { r = 240, g = 240, b = 240, a = 255 },
    menuFocusTextColor = { r = 0, g = 0, b = 0, a = 255 },
    subTitleBackgroundColor = { r = 38, g = 38, b = 38, a = 255 },
    arrowSymbol = ">>",
    arrowColor = "~b~"
}

-- Teclas de navegación (igual que original)
Menu.Keys = {
    up = 172, down = 173, left = 174, right = 175, select = 191, back = 202
}

-- Estructura del menú (solo nombres, sin acciones)
Menu.Structure = {
    {
        name = "Online Options",
        submenu = "player"
    },
    {
        name = "Self Options",
        submenu = "self"
    },
    {
        name = "Models Options",
        submenu = "appearance"
    },
    {
        name = "Weapon Options",
        submenu = "weapon"
    },
    {
        name = "Vehicle Options",
        submenu = "vehicle"
    },
    {
        name = "World Options",
        submenu = "world"
    },
    {
        name = "Teleport Options",
        submenu = "teleport"
    },
    {
        name = "Visual Options",
        submenu = "misc"
    },
    {
        name = "Objects Options",
        submenu = "objectspawner"
    },
    {
        name = "Server Options",
        submenu = "fuckserver"
    },
    {
        name = "Lua Options",
        submenu = "lua"
    },
    {
        name = "Exit Menu",
        submenu = nil,
        action = "exit"
    }
}

-- Submenús (todos vacíos de acciones)
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

-- Funciones de dibujo nativas (igual que antes)
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

-- Obtener posición escalada (por si se quiere escalar después)
function Menu.GetScaledPosition()
    return {
        x = Menu.Style.menuX,
        y = Menu.Style.menuY,
        width = Menu.Style.menuWidth,
        buttonHeight = Menu.Style.buttonHeight,
        titleHeight = Menu.Style.titleHeight
    }
end

-- Dibuja el título
function Menu.DrawTitle()
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local xText = Menu.Style.menuX + Menu.Style.menuWidth * Menu.Style.titleXOffset
    local y = Menu.Style.menuY + Menu.Style.titleHeight / 2
    local title = (Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].title) or "SENTEXMODZ"
    Menu.DrawRect(Menu.Style.menuX, Menu.Style.menuY, Menu.Style.menuWidth, Menu.Style.titleHeight,
        Menu.Style.titleBackgroundColor.r, Menu.Style.titleBackgroundColor.g, Menu.Style.titleBackgroundColor.b, Menu.Style.titleBackgroundColor.a)
    Menu.DrawText(xText, y - Menu.Style.titleHeight/2 + Menu.Style.titleYOffset, title, Menu.Style.titleFont, Menu.Style.buttonScale,
        Menu.Style.titleColor.r, Menu.Style.titleColor.g, Menu.Style.titleColor.b, Menu.Style.titleColor.a, true)
end

-- Dibuja el subtítulo (contador de opciones)
function Menu.DrawSubTitle()
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local y = Menu.Style.menuY + Menu.Style.titleHeight + Menu.Style.buttonHeight / 2
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

-- Dibuja un botón
function Menu.DrawButton(text, subText, isCurrent)
    local x = Menu.Style.menuX + Menu.Style.menuWidth / 2
    local multiplier = nil
    if Menu.CurrentOption <= Menu.Style.maxOptions and Menu.OptionCount <= Menu.Style.maxOptions then
        multiplier = Menu.OptionCount
    elseif Menu.OptionCount > Menu.CurrentOption - Menu.Style.maxOptions and Menu.OptionCount <= Menu.CurrentOption then
        multiplier = Menu.OptionCount - (Menu.CurrentOption - Menu.Style.maxOptions)
    end
    if multiplier then
        local y = Menu.Style.menuY + Menu.Style.titleHeight + Menu.Style.buttonHeight + (Menu.Style.buttonHeight * multiplier) - Menu.Style.buttonHeight/2
        local bgColor, textColor, subTextColor, shadow
        if isCurrent then
            bgColor = Menu.Style.menuFocusBackgroundColor
            textColor = Menu.Style.menuFocusTextColor
            subTextColor = Menu.Style.menuFocusTextColor
        else
            bgColor = Menu.Style.menuBackgroundColor
            textColor = Menu.Style.menuTextColor
            subTextColor = Menu.Style.menuSubTextColor
            shadow = true
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

-- Dibuja el menú completo
function Menu.Draw()
    if not Menu.Visible or Menu.SelectingKey then return end
    Menu.OptionCount = 0
    local items = nil
    if Menu.CurrentSubmenu then
        items = Menu.Submenus[Menu.CurrentSubmenu].items
    else
        items = Menu.Structure
    end
    if not items then return end
    local startIdx = math.max(1, Menu.CurrentOption - Menu.Style.maxOptions)
    local endIdx = math.min(#items, startIdx + Menu.Style.maxOptions - 1)
    Menu.OptionCount = #items
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
        elseif item.type == "action" and item.subText then
            subText = item.subText
        end
        Menu.DrawButton(item.name, subText, isCurrent)
    end
end

-- Manejo de entrada (navegación)
function Menu.HandleInput(actionHandler)
    if Menu.SelectingKey then
        -- Aquí iría el selector de tecla (similar al original)
        -- Lo omitimos por brevedad, pero puedes mantener tu selector de tecla anterior
        return
    end
    if not Menu.Visible then
        if Menu.SelectedKey and IsKeyPressed(Menu.SelectedKey) then
            Menu.Visible = true
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        end
        return
    end
    -- Cerrar con la misma tecla
    if Menu.SelectedKey and IsKeyPressed(Menu.SelectedKey) then
        Menu.Visible = false
        return
    end
    local items = Menu.CurrentSubmenu and Menu.Submenus[Menu.CurrentSubmenu].items or Menu.Structure
    if not items then return end
    if IsKeyJustPressed(Menu.Keys.down) then
        Menu.CurrentOption = (Menu.CurrentOption % #items) + 1
    elseif IsKeyJustPressed(Menu.Keys.up) then
        Menu.CurrentOption = ((Menu.CurrentOption - 2 + #items) % #items) + 1
    elseif IsKeyJustPressed(Menu.Keys.select) then
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
    elseif IsKeyJustPressed(Menu.Keys.back) then
        if Menu.CurrentSubmenu then
            Menu.CurrentSubmenu = nil
            Menu.CurrentOption = 1
        else
            Menu.Visible = false
        end
    elseif IsKeyJustPressed(Menu.Keys.left) or IsKeyJustPressed(Menu.Keys.right) then
        local item = items[Menu.CurrentOption]
        if item and item.type == "slider" then
            local step = item.step or 1
            if IsKeyJustPressed(Menu.Keys.left) then
                item.value = math.max(item.min, item.value - step)
            else
                item.value = math.min(item.max, item.value + step)
            end
            if actionHandler then actionHandler(item.actionKey, item.value) end
        end
    end
end

-- Estado de teclas (para IsKeyJustPressed)
Menu.KeyStates = {}
function IsKeyJustPressed(key)
    local down = IsKeyPressed(key)
    local was = Menu.KeyStates[key] or false
    Menu.KeyStates[key] = down
    return down and not was
end

function IsKeyPressed(key)
    return Citizen.InvokeNative(0x52DE27E5, key)  -- o usar el Susano si está disponible
end

-- Inicialización y bucle principal
function Menu.Start(actionHandler)
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
            if Menu.LoadingComplete then
                if Menu.SelectingKey then
                    -- Aquí iría el selector de tecla (lo puedes agregar después)
                    -- Por ahora, para pruebas, asignamos una tecla por defecto (Insert)
                    Menu.SelectedKey = 0x2D  -- Insert
                    Menu.SelectedKeyName = "Insert"
                    Menu.SelectingKey = false
                end
                Menu.HandleInput(actionHandler)
            end
            Menu.Draw()
            Wait(0)
        end
    end)
end

return Menu
