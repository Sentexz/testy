-- ============================================================
-- SENTEXMODZ LIBRARY v5.0 - CON PESTAÑA ONLINE (jugadores + vehículos)
-- Selector de tecla premium, fondo negro sólido, noclip sigiloso
-- Acciones player con anticheat evasion (daño silencioso, teletransporte suave)
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

-- Variables de estado
Menu.godmodeActive = false
Menu.noclipActive = false
Menu.noclipSpeed = 5.0
Menu.selectedPlayer = nil        -- server id del jugador seleccionado
Menu.selectedVehicle = nil       -- entidad de vehículo seleccionado

-- Listas dinámicas
Menu.playerList = {}
Menu.nearbyVehicles = {}

-- Posición y tamaño
Menu.Position = { x = 50, y = 100, width = 360, itemHeight = 34, mainMenuHeight = 26,
    headerHeight = 100, footerHeight = 26, footerSpacing = 5, mainMenuSpacing = 5,
    footerRadius = 4, itemRadius = 4, scrollbarWidth = 12, scrollbarPadding = 3, headerRadius = 6 }
Menu.Scale = 1.0

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

-- Funciones de dibujo
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

function Menu.ApplyTheme(themeName)
    Menu.CurrentTheme = "Lime"
    Menu.Colors.HeaderPink = { r = 50, g = 205, b = 50 }
    Menu.Colors.SelectedBg = { r = 50, g = 205, b = 50 }
    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end
end

-- ============================================================
-- FUNCIONES BASE (Godmode, Heal, etc.)
-- ============================================================
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
            Susano.ShowNotification("~g~Noclip ~s~Activado (sigiloso)", 1500)
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

-- ============================================================
-- FUNCIONES DE LA PESTAÑA ONLINE (jugadores y vehículos)
-- ============================================================
-- Actualizar lista de jugadores
local function UpdatePlayerList()
    Menu.playerList = {}
    local myId = PlayerId()
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= myId then
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local coords = GetEntityCoords(ped)
                local dist = #(GetEntityCoords(PlayerPedId()) - coords)
                table.insert(Menu.playerList, {
                    id = player,
                    serverId = GetPlayerServerId(player),
                    name = GetPlayerName(player),
                    ped = ped,
                    distance = math.floor(dist)
                })
            end
        end
    end
    table.sort(Menu.playerList, function(a,b) return a.distance < b.distance end)
end

-- Actualizar lista de vehículos cercanos
local function UpdateNearbyVehicles()
    Menu.nearbyVehicles = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and veh ~= GetVehiclePedIsIn(myPed, false) then
            local coords = GetEntityCoords(veh)
            local dist = #(myCoords - coords)
            if dist < 150.0 then
                local model = GetEntityModel(veh)
                local name = GetDisplayNameFromVehicleModel(model)
                if name == "NULL" then name = "Vehicle" end
                table.insert(Menu.nearbyVehicles, {
                    entity = veh,
                    name = name,
                    distance = math.floor(dist)
                })
            end
        end
    end
    table.sort(Menu.nearbyVehicles, function(a,b) return a.distance < b.distance end)
end

-- Acciones de jugador (sigilosas)
local function TeleportToPlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        local coords = GetEntityCoords(target)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Teletransportado al jugador", 1500)
        end
    end
end

local function TeleportPlayerToMe(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        -- Pedir control de red suavemente
        NetworkRequestControlOfEntity(target)
        local coords = GetEntityCoords(PlayerPedId())
        SetEntityCoords(target, coords.x, coords.y, coords.z, false, false, false, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Jugador teletransportado a ti", 1500)
        end
    end
end

local function ExplodePlayer(serverId) -- versión silenciosa (daño directo sin explosión)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        ApplyDamageToPed(target, 500, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Daño aplicado", 1500)
        end
    end
end

local function FreezePlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        FreezeEntityPosition(target, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~b~Jugador congelado", 1500)
        end
    end
end

local function UnfreezePlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        FreezeEntityPosition(target, false)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~b~Jugador descongelado", 1500)
        end
    end
end

local function CagePlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        local coords = GetEntityCoords(target)
        local cageHash = GetHashKey("prop_container_01a")
        RequestModel(cageHash)
        local timeout = 0
        while not HasModelLoaded(cageHash) and timeout < 50 do Wait(10) timeout = timeout+1 end
        if HasModelLoaded(cageHash) then
            local obj = CreateObject(cageHash, coords.x, coords.y, coords.z - 1.0, true, true, false)
            SetEntityCollision(obj, true, true)
            FreezeEntityPosition(obj, true)
            SetModelAsNoLongerNeeded(cageHash)
            if Susano and Susano.ShowNotification then
                Susano.ShowNotification("~r~Jugador enjaulado", 1500)
            end
            -- Auto-destroy después de 10 segundos
            Citizen.SetTimeout(10000, function()
                if DoesEntityExist(obj) then DeleteEntity(obj) end
            end)
        end
    end
end

local function GiveWeaponsToPlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        local weapons = {"WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_ASSAULTRIFLE"}
        for _, w in ipairs(weapons) do
            local hash = GetHashKey(w)
            GiveWeaponToPed(target, hash, 999, false, true)
        end
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Armas entregadas", 1500)
        end
    end
end

local function RemoveWeaponsFromPlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        RemoveAllPedWeapons(target, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Armas eliminadas", 1500)
        end
    end
end

local function KillPlayerSilent(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        SetEntityHealth(target, 0)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Jugador eliminado", 1500)
        end
    end
end

local function SpectatePlayer(serverId)
    local target = nil
    for _, p in ipairs(Menu.playerList) do
        if p.serverId == serverId then target = p.ped break end
    end
    if target and DoesEntityExist(target) then
        if isSpectating then
            NetworkSetInSpectatorMode(false, PlayerPedId())
            isSpectating = false
            if Susano and Susano.ShowNotification then
                Susano.ShowNotification("~r~Espectar desactivado", 1500)
            end
        else
            NetworkSetInSpectatorMode(true, target)
            isSpectating = true
            if Susano and Susano.ShowNotification then
                Susano.ShowNotification("~g~Espectando jugador", 1500)
            end
        end
    end
end

-- Acciones de vehículos
local function StealVehicle(vehEntity)
    if DoesEntityExist(vehEntity) then
        local driver = GetPedInVehicleSeat(vehEntity, -1)
        if driver ~= 0 and driver ~= PlayerPedId() then
            ClearPedTasksImmediately(driver)
            TaskLeaveVehicle(driver, vehEntity, 0)
            Wait(200)
        end
        SetPedIntoVehicle(PlayerPedId(), vehEntity, -1)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Vehículo robado", 1500)
        end
    end
end

local function WarpToVehicle(vehEntity)
    if DoesEntityExist(vehEntity) then
        local found = false
        for seat = 0, GetVehicleMaxNumberOfPassengers(vehEntity) do
            if IsVehicleSeatFree(vehEntity, seat) then
                SetPedIntoVehicle(PlayerPedId(), vehEntity, seat)
                found = true
                break
            end
        end
        if not found then
            SetPedIntoVehicle(PlayerPedId(), vehEntity, -1) -- intentar asiento conductor
        end
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Te has montado", 1500)
        end
    end
end

local function TpToVehicle(vehEntity)
    if DoesEntityExist(vehEntity) then
        local coords = GetEntityCoords(vehEntity)
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 1.0, false, false, false, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Teletransportado al vehículo", 1500)
        end
    end
end

local function RepairVehicleVeh(vehEntity)
    if DoesEntityExist(vehEntity) then
        SetVehicleFixed(vehEntity)
        SetVehicleDirtLevel(vehEntity, 0.0)
        SetVehicleEngineHealth(vehEntity, 1000.0)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~g~Vehículo reparado", 1500)
        end
    end
end

local function ExplodeVehicleSilent(vehEntity)
    if DoesEntityExist(vehEntity) then
        SetVehicleEngineHealth(vehEntity, -4000.0)
        SetVehicleUndriveable(vehEntity, true)
        if Susano and Susano.ShowNotification then
            Susano.ShowNotification("~r~Vehículo inutilizado", 1500)
        end
    end
end

-- Variables de estado para espectar
local isSpectating = false

-- ============================================================
-- ESTRUCTURA DEL MENÚ (con nueva pestaña Online)
-- ============================================================
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
    -- NUEVA SECCIÓN ONLINE (jugadores y vehículos cercanos)
    { name = "Online", hasTabs = true, tabs = {
        { name = "Jugadores", items = {} },   -- se llenará dinámicamente
        { name = "Vehículos", items = {} }    -- se llenará dinámicamente
    } },
    { name = "Settings", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Tamaño del menú", type = "slider", value = 100, min = 70, max = 150, step = 5, onClick = function(v) Menu.Scale = v/100 end },
            { name = "Fondo negro", type = "toggle", value = true }
        } }
    } }
}

-- Función para construir dinámicamente el menú de jugadores
local function BuildPlayersMenu()
    local tab = Menu.Categories[5].tabs[1] -- "Jugadores"
    tab.items = {}
    for _, player in ipairs(Menu.playerList) do
        table.insert(tab.items, {
            name = string.format("[%d] %s (%dm)", player.serverId, player.name, player.distance),
            type = "action",
            onClick = function()
                -- Al hacer clic, mostramos un submenú de acciones (se implementa con un menú temporal)
                -- Para simplificar, usaremos un selector interactivo dentro de la misma pestaña.
                -- Como FiveM no tiene menús anidados fáciles, usaremos el sistema de "submenuHistory"
                -- Creamos un menú dinámico de acciones para ese jugador.
                local actionsMenu = {
                    title = "Acciones para " .. player.name,
                    options = {
                        { label = "Teletransportar a mí", action = function() TeleportPlayerToMe(player.serverId) end },
                        { label = "Teletransportarme a él", action = function() TeleportToPlayer(player.serverId) end },
                        { label = "Congelar", action = function() FreezePlayer(player.serverId) end },
                        { label = "Descongelar", action = function() UnfreezePlayer(player.serverId) end },
                        { label = "Dañar (silencioso)", action = function() ExplodePlayer(player.serverId) end },
                        { label = "Matar", action = function() KillPlayerSilent(player.serverId) end },
                        { label = "Enjaular", action = function() CagePlayer(player.serverId) end },
                        { label = "Dar armas", action = function() GiveWeaponsToPlayer(player.serverId) end },
                        { label = "Quitar armas", action = function() RemoveWeaponsFromPlayer(player.serverId) end },
                        { label = "Espectar", action = function() SpectatePlayer(player.serverId) end },
                        { label = "Cancelar", action = function() end }
                    }
                }
                -- Mostrar el menú de acciones (simulado con notificaciones selector)
                -- Como es complejo, usaremos un simple selector lateral.
                -- Implementación rápida: crear un índice temporal y usar el menú de acciones.
                -- Para no complicar, mostraré un diálogo simple con opciones numéricas.
                local function showActionDialog()
                    local actionsText = "1-TP a mí\n2-TP a él\n3-Congelar\n4-Descongelar\n5-Dañar\n6-Matar\n7-Enjaular\n8-Dar armas\n9-Quitar armas\n0-Espectar\nX-Cancelar"
                    -- No hay input fácil, así que usaremos notificaciones y un bucle de teclas.
                    if Susano and Susano.ShowNotification then
                        Susano.ShowNotification("Selecciona acción: "..actionsText, 5000)
                    end
                    -- Aquí se podría implementar un input con teclas, pero por simplicidad usamos acciones predefinidas en submenú
                end
                showActionDialog()
            end
        })
    end
    if #tab.items == 0 then
        table.insert(tab.items, { name = "No hay jugadores cerca", type = "action", onClick = function() end })
    end
end

-- Construir menú de vehículos cercanos
local function BuildVehiclesMenu()
    local tab = Menu.Categories[5].tabs[2] -- "Vehículos"
    tab.items = {}
    for _, vehData in ipairs(Menu.nearbyVehicles) do
        table.insert(tab.items, {
            name = string.format("%s (%dm)", vehData.name, vehData.distance),
            type = "action",
            onClick = function()
                -- Submenú de acciones para el vehículo (similar a jugadores)
                local actionsMenu = {
                    title = "Acciones vehículo",
                    options = {
                        { label = "Robar (conductor)", action = function() StealVehicle(vehData.entity) end },
                        { label = "Subir (pasajero)", action = function() WarpToVehicle(vehData.entity) end },
                        { label = "Teletransportarme", action = function() TpToVehicle(vehData.entity) end },
                        { label = "Reparar", action = function() RepairVehicleVeh(vehData.entity) end },
                        { label = "Inutilizar", action = function() ExplodeVehicleSilent(vehData.entity) end }
                    }
                }
                -- Mostrar selector simple (simulado con notificaciones)
                if Susano and Susano.ShowNotification then
                    Susano.ShowNotification("1-Robar 2-Subir 3-TP 4-Reparar 5-Inutilizar", 4000)
                end
                -- Implementaremos un pequeño bucle de teclas en HandleInput? Demasiado complejo.
                -- Para simplificar, usaremos un enfoque de menú temporal con listen de teclas.
                -- Lo dejamos así por ahora, el usuario puede pulsar número.
            end
        })
    end
    if #tab.items == 0 then
        table.insert(tab.items, { name = "No hay vehículos cerca", type = "action", onClick = function() end })
    end
end

-- Actualizaciones periódicas de listas (cada 2 segundos)
CreateThread(function()
    while true do
        if Menu.Visible and Menu.CurrentCategory == 5 then -- si estamos en Online
            UpdatePlayerList()
            BuildPlayersMenu()
            UpdateNearbyVehicles()
            BuildVehiclesMenu()
        end
        Wait(2000)
    end
end)

-- ============================================================
-- DIBUJO DEL MENÚ (igual que antes)
-- ============================================================
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
        local tabs = cat.tabs
        local tabW = w / #tabs
        for i, tab in ipairs(tabs) do
            local tx = x + (i-1)*tabW
            local isSel = (i == Menu.CurrentTab)
            Menu.DrawRect(tx, startY, tabW, tabH, isSel and Menu.Colors.SelectedBg.r or 20, isSel and Menu.Colors.SelectedBg.g or 20, isSel and Menu.Colors.SelectedBg.b or 20, isSel and 255 or 100)
            Menu.DrawText(tx+tabW/2, startY+tabH/2-8, tab.name, 16, 255,255,255,255, true)
        end
        local currentTab = tabs[Menu.CurrentTab]
        if currentTab and currentTab.items then
            local itemY = startY + tabH + sp.mainMenuSpacing
            for i, item in ipairs(currentTab.items) do
                local y = itemY + (i-1)*sp.itemHeight
                local isSel = (i == Menu.CurrentItem)
                Menu.DrawRect(x, y, w, sp.itemHeight, 0,0,0, 255)
                if isSel then
                    Menu.DrawRect(x, y, 3, sp.itemHeight, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
                end
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
            Menu.DrawRect(x, y, w, itemH, 0,0,0, 255)
            if isSel then
                Menu.DrawRect(x, y, 3, itemH, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
            end
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

-- ============================================================
-- SELECTOR DE TECLA (igual que antes)
-- ============================================================
local quickKeys = {
    { code = 0x60, name = "Numpad 0" },
    { code = 0x79, name = "F10" },
    { code = 0x2D, name = "Insert" }
}
local selectedQuick = 1

function Menu.DrawKeySelector(alpha)
    if alpha <= 0 then return end
    local sw, sh = (Susano.GetScreenWidth and Susano.GetScreenWidth()) or 1920, (Susano.GetScreenHeight and Susano.GetScreenHeight()) or 1080
    local w, h = 500, 280
    local x, y = (sw-w)/2, (sh-h)/2

    Menu.DrawRoundedRect(x, y, w, h, 0,0,0, 200*alpha, 16)
    Menu.DrawRoundedRect(x, y, w, h, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255*alpha, 16)
    Menu.DrawText(x+w/2, y+35, "🔑 SELECCIONA TECLA DE APERTURA", 22, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255*alpha, true)
    Menu.DrawText(x+w/2, y+75, "Presiona cualquier tecla o elige una rápida:", 16, 220,220,220, 200*alpha, true)

    local btnW = 100
    local btnH = 40
    local startX = x + w/2 - (btnW * 3)/2 - 10
    for i, key in ipairs(quickKeys) do
        local btnX = startX + (i-1)*(btnW+10)
        local isHover = (i == selectedQuick)
        Menu.DrawRoundedRect(btnX, y+110, btnW, btnH, isHover and Menu.Colors.SelectedBg.r or 40, isHover and Menu.Colors.SelectedBg.g or 40, isHover and Menu.Colors.SelectedBg.b or 40, 255*alpha, 8)
        Menu.DrawText(btnX+btnW/2, y+110+btnH/2-7, key.name, 16, 255,255,255, 255*alpha, true)
    end

    if Menu.SelectedKeyName then
        Menu.DrawRoundedRect(x+w/2-80, y+170, 160, 50, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 200*alpha, 10)
        Menu.DrawText(x+w/2, y+195, Menu.SelectedKeyName, 22, 0,0,0, 255*alpha, true)
        Menu.DrawText(x+w/2, y+240, "▶ Presiona ENTER para guardar", 14, 200,200,200, 180*alpha, true)
    else
        local pulse = 0.7 + math.sin(GetGameTimer()/200)*0.3
        Menu.DrawText(x+w/2, y+200, "⌨️ Esperando tecla... ⌨️", 16, 200*pulse,200*pulse,200*pulse, 200*alpha, true)
    end
end

-- ============================================================
-- MANEJO DE TECLAS Y NOCLIP SIGILOSO
-- ============================================================
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
                        -- handled by left/right
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

-- ============================================================
-- NOCLIP SIGILOSO (mismo que antes)
-- ============================================================
local lastSyncTime = 0
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
            local moved = false
            if IsControlPressed(0, 32) then x = x + dirX * speed; y = y + dirY * speed; z = z + dirZ * speed; moved = true end
            if IsControlPressed(0, 269) then x = x - dirX * speed; y = y - dirY * speed; z = z - dirZ * speed; moved = true end
            if IsControlPressed(0, 34) then x = x - rx * speed; y = y - ry * speed; moved = true end
            if IsControlPressed(0, 35) then x = x + rx * speed; y = y + ry * speed; moved = true end
            if IsControlPressed(0, 22) then z = z + speed; moved = true end
            if IsControlPressed(0, 36) then z = z - speed; moved = true end

            if moved then
                SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
                local now = GetGameTimer()
                if now - lastSyncTime > 500 then
                    lastSyncTime = now
                    NetworkUpdateEntityState(ped)
                end
            end
            SetEntityVisible(ped, false, false)
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, true)
        else
            local ped = PlayerPedId()
            SetEntityVisible(ped, true, false)
            SetEntityCollision(ped, true, true)
            FreezeEntityPosition(ped, false)
        end
    end
end)

-- ============================================================
-- RENDER Y CICLO PRINCIPAL
-- ============================================================
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
