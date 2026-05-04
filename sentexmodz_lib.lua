-- ============================================================
-- SENTEXMODZ LIBRARY v3.0 - COMPLETA Y FUNCIONAL
-- Diseño verde lima, banner personalizado, todas las acciones
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.CurrentCategory = 2
Menu.CurrentPage = 1
Menu.ItemsPerPage = 9
Menu.OpenedCategory = nil
Menu.CurrentItem = 1
Menu.CurrentTab = 1
Menu.ItemScrollOffset = 0
Menu.CategoryScrollOffset = 0
Menu.EditorMode = false
Menu.ShowSnowflakes = false
Menu.SelectingKey = false
Menu.SelectedKey = nil
Menu.SelectedKeyName = nil
Menu.LoadingComplete = false
Menu.IsLoading = true
Menu.LoadingProgress = 0
Menu.LoadingStartTime = nil
Menu.LoadingDuration = 3000
Menu.CurrentTopTab = 1
Menu.KeySelectorAnim = 0

-- Colores (verde lima)
Menu.Colors = {
    HeaderPink = { r = 50, g = 205, b = 50 },
    SelectedBg = { r = 50, g = 205, b = 50 },
    TextWhite = { r = 255, g = 255, b = 255 },
    BackgroundDark = { r = 0, g = 0, b = 0 },
    FooterBlack = { r = 0, g = 0, b = 0 }
}

-- Banner
Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.imgur.com/JV6Drrz.png",
    height = 100
}
Menu.bannerTexture = nil

-- Variables de estado para funciones
Menu.godmodeActive = false
Menu.noclipActive = false
Menu.noclipSpeed = 5.0

-- Posición y tamaño (se adapta a la pantalla)
Menu.Position = { x = 50, y = 100, width = 360, itemHeight = 34, mainMenuHeight = 26,
    headerHeight = 100, footerHeight = 26, footerSpacing = 5, mainMenuSpacing = 5,
    footerRadius = 4, itemRadius = 4, scrollbarWidth = 12, scrollbarPadding = 3, headerRadius = 6 }
Menu.Scale = 1.0

-- Mapeo de teclas a nombres legibles
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
    [0x70] = "F1", [0x71] = "F2", [0x72] = "F3", [0x73] = "F4",
    [0x74] = "F5", [0x75] = "F6", [0x76] = "F7", [0x77] = "F8",
    [0x78] = "F9", [0x79] = "F10", [0x7A] = "F11", [0x7B] = "F12",
    [0xA0] = "Left Shift", [0xA1] = "Right Shift"
}

function Menu.GetKeyName(code) return Menu.KeyNames[code] or ("0x"..string.format("%02X", code)) end

-- Funciones de dibujo (usando Susano)
function Menu.DrawRect(x,y,w,h,r,g,b,a)
    if Susano and Susano.DrawFilledRect then
        Susano.DrawFilledRect(x,y,w,h,r/255,g/255,b/255,a/255)
    else
        DrawRect(x,y,w,h,r,g,b,a)
    end
end
function Menu.DrawText(x,y,text,size,r,g,b,a,center)
    if Susano and Susano.DrawText then
        Susano.DrawText(x,y,text,size,r/255,g/255,b/255,a/255)
    else
        SetTextFont(0)
        SetTextScale(size/50,size/50)
        SetTextColour(r,g,b,a)
        SetTextCentre(center or false)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x,y)
    end
end
function Menu.DrawRoundedRect(x,y,w,h,r,g,b,a,radius)
    if Susano and Susano.DrawRectFilled then
        Susano.DrawRectFilled(x,y,w,h,r/255,g/255,b/255,a/255,radius)
    else
        Menu.DrawRect(x,y,w,h,r,g,b,a)
    end
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

-- Funciones de acción REALES
local function ToggleGodmode()
    Menu.godmodeActive = not Menu.godmodeActive
    local ped = PlayerPedId()
    if Menu.godmodeActive then
        SetEntityInvincible(ped, true)
        SetEntityProofs(ped, true, true, true, true, true)
        SetPedCanRagdoll(ped, false)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Godmode ~s~Activado", 1500)
        end
    else
        SetEntityInvincible(ped, false)
        SetEntityProofs(ped, false, false, false, false, false)
        SetPedCanRagdoll(ped, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Godmode ~s~Desactivado", 1500)
        end
    end
end

local function ToggleNoclip()
    Menu.noclipActive = not Menu.noclipActive
    local ped = PlayerPedId()
    if Menu.noclipActive then
        SetEntityVisible(ped, false, false)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Noclip ~s~Activado", 1500)
        end
    else
        SetEntityVisible(ped, true, false)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Noclip ~s~Desactivado", 1500)
        end
    end
end

local function HealPlayer()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    if Susano and Susano.ShowNotification then
        Susano.ShowNotification("~g~Salud restaurada", 1500)
    end
end

local function RepairCurrentVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        SetVehicleFixed(veh)
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleEngineHealth(veh, 1000.0)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Vehículo reparado", 1500)
        end
    else
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~No estás en un vehículo", 1500)
        end
    end
end

local function TeleportToWaypoint()
    local waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        local coords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector())
        local ped = PlayerPedId()
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Teletransportado al waypoint", 1500)
        end
    else
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~No hay waypoint marcado", 1500)
        end
    end
end

local weathers = {"EXTRASUNNY","CLEAR","CLOUDS","SMOG","FOG","OVERCAST","RAIN","THUNDER","CLEARING","NEUTRAL","SNOW","BLIZZARD"}
local currentWeather = 1
local function ChangeWeather()
    currentWeather = currentWeather % #weathers + 1
    SetWeatherTypeNowPersist(weathers[currentWeather])
    if Susano and Susano.ShowNotification then
        Susano.ShowNotification("~g~Clima cambiado: ~s~"..weathers[currentWeather], 1500)
    end
end

-- Estructura del menú (con acciones reales)
Menu.TopLevelTabs = { { name = "SENTEXMODZ", categories = {}, autoOpen = true } }
Menu.Categories = {
    { name = "MAIN" },
    { name = "Player", hasTabs = true, tabs = {
        { name = "Opciones", items = {
            { name = "Godmode", type = "toggle", value = false, onClick = ToggleGodmode },
            { name = "Noclip", type = "toggle", value = false, onClick = ToggleNoclip },
            { name = "Curar", type = "action", onClick = HealPlayer },
            { name = "Velocidad Noclip", type = "slider", value = 5.0, min = 1.0, max = 20.0, step = 0.5, onClick = function(v) Menu.noclipSpeed = v end }
        } }
    } },
    { name = "Vehículos", hasTabs = true, tabs = {
        { name = "Opciones", items = {
            { name = "Reparar vehículo", type = "action", onClick = RepairCurrentVehicle },
            { name = "Teletransporte a waypoint", type = "action", onClick = TeleportToWaypoint }
        } }
    } },
    { name = "Mundo", hasTabs = true, tabs = {
        { name = "Opciones", items = {
            { name = "Cambiar clima", type = "action", onClick = ChangeWeather }
        } }
    } },
    { name = "Settings", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Tamaño del menú", type = "slider", value = 100, min = 70, max = 150, step = 5, onClick = function(v) Menu.Scale = v/100 end },
            { name = "Fondo negro", type = "toggle", value = true }
        } }
    } }
}

function Menu.GetScaledPosition()
    local s = Menu.Scale
    return {
        x = Menu.Position.x, y = Menu.Position.y,
        width = Menu.Position.width * s, itemHeight = Menu.Position.itemHeight * s,
        mainMenuHeight = Menu.Position.mainMenuHeight * s, headerHeight = Menu.Position.headerHeight * s,
        footerHeight = Menu.Position.footerHeight * s, footerSpacing = Menu.Position.footerSpacing * s,
        mainMenuSpacing = Menu.Position.mainMenuSpacing * s, scrollbarWidth = Menu.Position.scrollbarWidth * s
    }
end

function Menu.DrawHeader()
    local sp = Menu.GetScaledPosition()
    local x, y, w = sp.x, sp.y, sp.width-1
    local h = Menu.Banner.height * Menu.Scale
    if Menu.Banner.enabled and Menu.bannerTexture and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, w, h, 1,1,1,1,0)
    else
        Menu.DrawRect(x, y, w, h, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255)
    end
end

function Menu.DrawCategories()
    if Menu.OpenedCategory then
        local cat = Menu.Categories[Menu.OpenedCategory]
        if not cat or not cat.hasTabs then return end
        local sp = Menu.GetScaledPosition()
        local x, startY = sp.x, sp.y + sp.headerHeight
        local w, tabH = sp.width, sp.mainMenuHeight
        -- Dibujar pestañas
        local tabs = cat.tabs
        local tabW = w / #tabs
        for i, tab in ipairs(tabs) do
            local tx = x + (i-1)*tabW
            local isSel = (i == Menu.CurrentTab)
            Menu.DrawRect(tx, startY, tabW, tabH, isSel and Menu.Colors.SelectedBg.r or 20, isSel and Menu.Colors.SelectedBg.g or 20, isSel and Menu.Colors.SelectedBg.b or 20, isSel and 255 or 100)
            Menu.DrawText(tx+tabW/2, startY+tabH/2-8, tab.name, 16, 255,255,255,255, true)
        end
        -- Items de la pestaña actual
        local currentTab = tabs[Menu.CurrentTab]
        if currentTab and currentTab.items then
            local itemY = startY + tabH + sp.mainMenuSpacing
            for i, item in ipairs(currentTab.items) do
                local y = itemY + (i-1)*sp.itemHeight
                local isSel = (i == Menu.CurrentItem)
                Menu.DrawRect(x, y, w, sp.itemHeight, 30,30,30, 200)
                if isSel then Menu.DrawRect(x, y, 3, sp.itemHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255) end
                Menu.DrawText(x+10, y+sp.itemHeight/2-8, item.name, 16, 255,255,255,255)
                if item.type == "toggle" then
                    local tw, th = 36, 16
                    local tx = x + w - tw - 10
                    local ty = y + sp.itemHeight/2 - th/2
                    Menu.DrawRect(tx, ty, tw, th, 100,100,100, 150)
                    if item.value then Menu.DrawRect(tx+2, ty+2, tw-4, th-4, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255) end
                elseif item.type == "slider" then
                    local sw, sh = 80, 8
                    local sx = x + w - sw - 10
                    local sy = y + sp.itemHeight/2 - sh/2
                    Menu.DrawRect(sx, sy, sw, sh, 80,80,80, 255)
                    local percent = (item.value - item.min) / (item.max - item.min)
                    Menu.DrawRect(sx, sy, sw * percent, sh, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
                    Menu.DrawText(sx+sw+5, sy+sh/2-4, string.format("%.1f", item.value), 12, 200,200,200,255)
                end
            end
        end
    else
        local sp = Menu.GetScaledPosition()
        local x, startY = sp.x, sp.y + sp.headerHeight
        local w, itemH = sp.width, sp.itemHeight
        local categories = {}
        for i=2, #Menu.Categories do table.insert(categories, Menu.Categories[i]) end
        for i, cat in ipairs(categories) do
            local y = startY + (i-1)*itemH
            local isSel = (i+1 == Menu.CurrentCategory)
            Menu.DrawRect(x, y, w, itemH, 30,30,30, 200)
            if isSel then Menu.DrawRect(x, y, 3, itemH, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255) end
            Menu.DrawText(x+10, y+itemH/2-8, cat.name, 16, 255,255,255,255)
            Menu.DrawText(x+w-30, y+itemH/2-8, ">", 16, 200,200,200,255)
        end
    end
end

function Menu.DrawFooter()
    local sp = Menu.GetScaledPosition()
    local totalH = sp.headerHeight + sp.mainMenuHeight + sp.mainMenuSpacing + (#Menu.Categories-1)*sp.itemHeight + sp.footerSpacing
    local y = sp.y + totalH
    Menu.DrawRect(sp.x, y, sp.width-1, sp.footerHeight, 0,0,0, 255)
    Menu.DrawText(sp.x+10, y+sp.footerHeight/2-8, "SENTEXMODZ .gg/discord", 13, 150,150,150,255)
    local pos = string.format("%d/%d", Menu.CurrentCategory-1, #Menu.Categories-1)
    Menu.DrawText(sp.x+sp.width-50, y+sp.footerHeight/2-8, pos, 13, 150,150,150,255)
end

function Menu.DrawKeySelector(alpha)
    if alpha <= 0 then return end
    local sw, sh = (Susano.GetScreenWidth and Susano.GetScreenWidth()) or 1920, (Susano.GetScreenHeight and Susano.GetScreenHeight()) or 1080
    local w, h = 480, 220
    local x, y = (sw-w)/2, (sh-h)/2
    Menu.DrawRoundedRect(x+5, y+5, w, h, 0,0,0, 100*alpha, 12)
    Menu.DrawRoundedRect(x, y, w, h, 0,0,0, 220*alpha, 12)
    Menu.DrawRoundedRect(x, y, w, h, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255*alpha, 12)
    Menu.DrawText(x+w/2, y+45, "⚙  SELECCIONA UNA TECLA  ⚙", 20, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255*alpha, true)
    Menu.DrawText(x+w/2, y+90, "Presiona cualquier tecla para abrir el menú", 16, 220,220,220, 220*alpha, true)
    if Menu.SelectedKeyName then
        Menu.DrawRoundedRect(x+w/2-60, y+125, 120, 50, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 200*alpha, 8)
        Menu.DrawText(x+w/2, y+150, Menu.SelectedKeyName, 22, 0,0,0, 255*alpha, true)
        Menu.DrawText(x+w/2, y+190, "Presiona ENTER para guardar", 14, 200,200,200, 180*alpha, true)
    else
        local pulse = 0.7 + math.sin(GetGameTimer()/200)*0.3
        Menu.DrawText(x+w/2, y+140, "⌨️ Esperando tecla... ⌨️", 16, 200*pulse,200*pulse,200*pulse, 200*alpha, true)
    end
end

function Menu.Render()
    if not (Susano and Susano.BeginFrame) then return end
    Susano.BeginFrame()
    if Menu.SelectingKey then
        Menu.DrawKeySelector(1.0)
    elseif Menu.Visible then
        Menu.DrawHeader()
        Menu.DrawCategories()
        Menu.DrawFooter()
    end
    Susano.SubmitFrame()
end

-- Manejo de teclas y noclip
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
        if Menu.IsKeyJustPressed(0x0D) and Menu.SelectedKey then
            Menu.SelectingKey = false
            Menu.Visible = false
            if Susano and Susano.ShowNotification then
                Susano.ShowNotification("~g~Tecla guardada: "..Menu.SelectedKeyName, 2000)
            end
            return
        end
        for k, _ in pairs(Menu.KeyNames) do
            if k ~= 0x0D and Menu.IsKeyJustPressed(k) then
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
        end
        return
    end

    if Menu.SelectedKey and Menu.IsKeyJustPressed(Menu.SelectedKey) then
        Menu.Visible = false
        return
    end

    if Menu.OpenedCategory then
        local cat = Menu.Categories[Menu.OpenedCategory]
        if not cat then Menu.OpenedCategory = nil return end
        local tab = cat.tabs[Menu.CurrentTab]
        if tab and tab.items then
            local items = tab.items
            if Menu.IsKeyJustPressed(0x26) then
                Menu.CurrentItem = Menu.CurrentItem - 1
                if Menu.CurrentItem < 1 then Menu.CurrentItem = #items end
            elseif Menu.IsKeyJustPressed(0x28) then
                Menu.CurrentItem = Menu.CurrentItem + 1
                if Menu.CurrentItem > #items then Menu.CurrentItem = 1 end
            elseif Menu.IsKeyJustPressed(0x08) then
                Menu.OpenedCategory = nil
            elseif Menu.IsKeyJustPressed(0x0D) then
                local item = items[Menu.CurrentItem]
                if item then
                    if item.type == "toggle" then
                        item.value = not item.value
                        if item.onClick then item.onClick(item.value) end
                    elseif item.type == "action" then
                        if item.onClick then item.onClick() end
                    elseif item.type == "slider" then
                        -- los sliders se manejan con izquierda/derecha
                    end
                end
            elseif Menu.IsKeyJustPressed(0x25) then
                local item = items[Menu.CurrentItem]
                if item and item.type == "slider" then
                    item.value = math.max(item.min, item.value - (item.step or 1))
                    if item.onClick then item.onClick(item.value) end
                end
            elseif Menu.IsKeyJustPressed(0x27) then
                local item = items[Menu.CurrentItem]
                if item and item.type == "slider" then
                    item.value = math.min(item.max, item.value + (item.step or 1))
                    if item.onClick then item.onClick(item.value) end
                end
            end
        end
    else
        if Menu.IsKeyJustPressed(0x26) then
            Menu.CurrentCategory = Menu.CurrentCategory - 1
            if Menu.CurrentCategory < 2 then Menu.CurrentCategory = #Menu.Categories end
        elseif Menu.IsKeyJustPressed(0x28) then
            Menu.CurrentCategory = Menu.CurrentCategory + 1
            if Menu.CurrentCategory > #Menu.Categories then Menu.CurrentCategory = 2 end
        elseif Menu.IsKeyJustPressed(0x0D) then
            local cat = Menu.Categories[Menu.CurrentCategory]
            if cat and cat.hasTabs then
                Menu.OpenedCategory = Menu.CurrentCategory
                Menu.CurrentTab = 1
                Menu.CurrentItem = 1
            end
        end
    end
end

-- Bucle de noclip (movimiento)
CreateThread(function()
    while true do
        Wait(0)
        if Menu.noclipActive then
            local ped = PlayerPedId()
            local speed = Menu.noclipSpeed
            local camRot = GetGameplayCamRot(2)
            local pitch = math.rad(camRot.x)
            local yaw = math.rad(camRot.z)
            local dirX = -math.sin(yaw) * math.cos(pitch)
            local dirY = math.cos(yaw) * math.cos(pitch)
            local dirZ = math.sin(pitch)
            local rx = math.cos(yaw)
            local ry = math.sin(yaw)
            local x, y, z = table.unpack(GetEntityCoords(ped))
            if IsControlPressed(0, 32) then -- W
                x = x + dirX * speed
                y = y + dirY * speed
                z = z + dirZ * speed
            end
            if IsControlPressed(0, 269) then -- S
                x = x - dirX * speed
                y = y - dirY * speed
                z = z - dirZ * speed
            end
            if IsControlPressed(0, 34) then -- A
                x = x - rx * speed
                y = y - ry * speed
            end
            if IsControlPressed(0, 35) then -- D
                x = x + rx * speed
                y = y + ry * speed
            end
            if IsControlPressed(0, 22) then -- SPACE
                z = z + speed
            end
            if IsControlPressed(0, 36) then -- CTRL
                z = z - speed
            end
            SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
            SetEntityVisible(ped, false, false)
        elseif not Menu.noclipActive and not Menu.godmodeActive then
            SetEntityVisible(PlayerPedId(), true, false)
        end
    end
end)

-- Inicialización
CreateThread(function()
    Menu.LoadingStartTime = GetGameTimer() or 0
    while Menu.IsLoading do
        local elapsed = (GetGameTimer() or 0) - Menu.LoadingStartTime
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
    Menu.ApplyTheme("Lime")
    while true do
        Menu.Render()
        if Menu.LoadingComplete then Menu.HandleInput() end
        Wait(0)
    end
end)

return Menu
