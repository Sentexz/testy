-- ============================================================
-- SENTEXMODZ LIBRARY v2.0 (Lime Green + custom banner)
-- Basado en el sistema original pero con dibujo compatible
-- ============================================================

local Menu = {}
Menu.Visible = false
Menu.CurrentCategory = 2
Menu.CurrentPage = 1
Menu.ItemsPerPage = 9
Menu.scrollbarY = nil
Menu.scrollbarHeight = nil
Menu.OpenedCategory = nil
Menu.CurrentItem = 1
Menu.CurrentTab = 1
Menu.ItemScrollOffset = 0
Menu.CategoryScrollOffset = 0
Menu.EditorDragging = false
Menu.EditorDragOffsetX = 0
Menu.EditorDragOffsetY = 0
Menu.EditorMode = false
Menu.ShowSnowflakes = false
Menu.SelectorY = 0
Menu.CategorySelectorY = 0
Menu.TabSelectorX = 0
Menu.TabSelectorWidth = 0
Menu.SmoothFactor = 0.2
Menu.GradientType = 1
Menu.ScrollbarPosition = 1
Menu.ShowKeybinds = false
Menu.CurrentTopTab = 1

-- Configuración de colores (VERDE LIMA)
Menu.Colors = {
    HeaderPink = { r = 50, g = 205, b = 50 },   -- lime
    SelectedBg = { r = 50, g = 205, b = 50 },
    TextWhite = { r = 255, g = 255, b = 255 },
    BackgroundDark = { r = 0, g = 0, b = 0 },
    FooterBlack = { r = 0, g = 0, b = 0 }
}
Menu.CurrentTheme = "Lime"

-- Banner
Menu.Banner = {
    enabled = true,
    imageUrl = "https://i.imgur.com/JV6Drrz.png",
    height = 100
}
Menu.bannerTexture = nil
Menu.bannerWidth = 0
Menu.bannerHeight = 0

-- Posición y tamaño (en píxeles, para que sea más fiable)
Menu.Position = {
    x = 50,
    y = 100,
    width = 360,
    itemHeight = 34,
    mainMenuHeight = 26,
    headerHeight = 100,
    footerHeight = 26,
    footerSpacing = 5,
    mainMenuSpacing = 5,
    footerRadius = 4,
    itemRadius = 4,
    scrollbarWidth = 12,
    scrollbarPadding = 3,
    headerRadius = 6
}
Menu.Scale = 1.0

-- Funciones de dibujo compatibles con Susano
function Menu.DrawRect(x, y, w, h, r, g, b, a)
    if Susano and Susano.DrawFilledRect then
        Susano.DrawFilledRect(x, y, w, h, r/255, g/255, b/255, a/255)
    elseif Susano and Susano.DrawRect then
        for i = 0, h-1 do
            Susano.DrawRect(x, y+i, w, 1, r/255, g/255, b/255, a/255)
        end
    else
        -- fallback nativo
        DrawRect(x, y, w, h, r, g, b, a)
    end
end

function Menu.DrawText(x, y, text, size, r, g, b, a)
    if Susano and Susano.DrawText then
        Susano.DrawText(x, y, text, size, r/255, g/255, b/255, a/255)
    else
        SetTextFont(0)
        SetTextScale(size/50, size/50)
        SetTextColour(r, g, b, a)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

function Menu.DrawRoundedRect(x, y, w, h, r, g, b, a, radius)
    -- versión simplificada (sin redondeo real, solo rectángulo)
    Menu.DrawRect(x, y, w, h, r, g, b, a)
end

-- Cargar textura del banner
function Menu.LoadBannerTexture(url)
    if not url or url == "" then return end
    if not Susano or not Susano.HttpGet or not Susano.LoadTextureFromBuffer then return end
    CreateThread(function()
        local status, body = Susano.HttpGet(url)
        if status == 200 and body and #body > 0 then
            local tex, w, h = Susano.LoadTextureFromBuffer(body)
            if tex and tex ~= 0 then
                Menu.bannerTexture = tex
                Menu.bannerWidth = w or 0
                Menu.bannerHeight = h or 0
            end
        end
    end)
end

-- Aplicar tema (por compatibilidad, solo lime)
function Menu.ApplyTheme(themeName)
    Menu.CurrentTheme = "Lime"
    Menu.Colors.HeaderPink = { r = 50, g = 205, b = 50 }
    Menu.Colors.SelectedBg = { r = 50, g = 205, b = 50 }
    if Menu.Banner.enabled and Menu.Banner.imageUrl then
        Menu.LoadBannerTexture(Menu.Banner.imageUrl)
    end
end

-- Obtener posición escalada (en píxeles)
function Menu.GetScaledPosition()
    local s = Menu.Scale
    return {
        x = Menu.Position.x,
        y = Menu.Position.y,
        width = Menu.Position.width * s,
        itemHeight = Menu.Position.itemHeight * s,
        mainMenuHeight = Menu.Position.mainMenuHeight * s,
        headerHeight = Menu.Position.headerHeight * s,
        footerHeight = Menu.Position.footerHeight * s,
        footerSpacing = Menu.Position.footerSpacing * s,
        mainMenuSpacing = Menu.Position.mainMenuSpacing * s,
        footerRadius = Menu.Position.footerRadius * s,
        itemRadius = Menu.Position.itemRadius * s,
        scrollbarWidth = Menu.Position.scrollbarWidth * s,
        scrollbarPadding = Menu.Position.scrollbarPadding * s,
        headerRadius = Menu.Position.headerRadius * s
    }
end

-- Dibujar cabecera con banner
function Menu.DrawHeader()
    local sp = Menu.GetScaledPosition()
    local x = sp.x
    local y = sp.y
    local w = sp.width - 1
    local h = sp.headerHeight
    local bh = Menu.Banner.height * Menu.Scale

    if Menu.Banner.enabled and Menu.bannerTexture and Susano.DrawImage then
        Susano.DrawImage(Menu.bannerTexture, x, y, w, bh, 1,1,1,1,0)
    else
        Menu.DrawRect(x, y, w, h, Menu.Colors.HeaderPink.r, Menu.Colors.HeaderPink.g, Menu.Colors.HeaderPink.b, 255)
        local logoX = x + w/2 - 60
        local logoY = y + h/2 - 15
        Menu.DrawText(logoX, logoY, "SENTEXMODZ", 28, 255,255,255,255)
    end
end

-- Dibujar scrollbar (simplificado)
function Menu.DrawScrollbar(x, startY, visibleHeight, selectedIndex, totalItems, isMainMenu, menuWidth)
    -- omitido por simplicidad, se puede añadir después
end

-- Dibujar pestañas
function Menu.DrawTabs(category, x, startY, width, tabHeight)
    if not category or not category.hasTabs or not category.tabs then return end
    local numTabs = #category.tabs
    local tabWidth = width / numTabs
    local currentX = x
    for i, tab in ipairs(category.tabs) do
        local tabX = currentX
        local isSelected = (i == Menu.CurrentTab)
        Menu.DrawRect(tabX, startY, tabWidth, tabHeight, 
            isSelected and Menu.Colors.SelectedBg.r or Menu.Colors.BackgroundDark.r,
            isSelected and Menu.Colors.SelectedBg.g or Menu.Colors.BackgroundDark.g,
            isSelected and Menu.Colors.SelectedBg.b or Menu.Colors.BackgroundDark.b,
            isSelected and 255 or 150)
        local textW = string.len(tab.name) * 9
        local textX = tabX + tabWidth/2 - textW/2
        Menu.DrawText(textX, startY + tabHeight/2 - 9, tab.name, 16, 255,255,255,255)
        currentX = currentX + tabWidth
    end
end

-- Dibujar un elemento (toggle, selector, etc, simplificado)
function Menu.DrawItem(x, y, w, h, item, isSelected)
    Menu.DrawRect(x, y, w, h, 30,30,30, 200)
    if isSelected then
        Menu.DrawRect(x, y, 3, h, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
    end
    Menu.DrawText(x+10, y+h/2-8, item.name, 16, 255,255,255,255)
    if item.type == "toggle" then
        local tw = 36
        local th = 16
        local tx = x + w - tw - 10
        local ty = y + h/2 - th/2
        Menu.DrawRect(tx, ty, tw, th, 100,100,100, 150)
        if item.value then
            Menu.DrawRect(tx+2, ty+2, tw-4, th-4, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
        end
    elseif item.type == "selector" and item.options then
        local selected = item.options[item.selected] or ""
        local txt = "< " .. selected .. " >"
        local tw = string.len(txt) * 8
        Menu.DrawText(x + w - tw - 10, y+h/2-8, txt, 16, 200,200,200,255)
    elseif item.type == "slider" then
        -- slider simplificado
        local sw = 80
        local sh = 8
        local sx = x + w - sw - 10
        local sy = y + h/2 - sh/2
        Menu.DrawRect(sx, sy, sw, sh, 80,80,80,255)
        local percent = (item.value - item.min) / (item.max - item.min)
        Menu.DrawRect(sx, sy, sw * percent, sh, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
    end
end

-- Dibujar categorías (menú principal)
function Menu.DrawCategories()
    if Menu.OpenedCategory then
        local category = Menu.Categories[Menu.OpenedCategory]
        if not category or not category.hasTabs then
            Menu.OpenedCategory = nil
            return
        end
        local sp = Menu.GetScaledPosition()
        local x = sp.x
        local startY = sp.y + sp.headerHeight
        local w = sp.width
        local tabH = sp.mainMenuHeight
        Menu.DrawTabs(category, x, startY, w, tabH)
        local currentTab = category.tabs[Menu.CurrentTab]
        if currentTab and currentTab.items then
            local itemY = startY + tabH + sp.mainMenuSpacing
            local visible = math.min(#currentTab.items, Menu.ItemsPerPage)
            for i = 1, visible do
                local idx = i + Menu.ItemScrollOffset
                if idx <= #currentTab.items then
                    local item = currentTab.items[idx]
                    local isSel = (idx == Menu.CurrentItem)
                    Menu.DrawItem(x, itemY + (i-1)*sp.itemHeight, w, sp.itemHeight, item, isSel)
                end
            end
        end
        return
    end

    -- Vista de categorías
    local sp = Menu.GetScaledPosition()
    local x = sp.x
    local bannerH = (Menu.Banner.enabled and Menu.Banner.height or sp.headerHeight) * Menu.Scale
    local startY = sp.y + bannerH
    local w = sp.width
    local itemH = sp.itemHeight
    local mainH = sp.mainMenuHeight
    local spacing = sp.mainMenuSpacing

    -- Barra principal (top tabs)
    if Menu.TopLevelTabs then
        local tabCount = #Menu.TopLevelTabs
        local tabW = w / tabCount
        for i, tab in ipairs(Menu.TopLevelTabs) do
            local tx = x + (i-1)*tabW
            local isSel = (i == Menu.CurrentTopTab)
            Menu.DrawRect(tx, startY, tabW, mainH, 
                isSel and Menu.Colors.SelectedBg.r or 20,
                isSel and Menu.Colors.SelectedBg.g or 20,
                isSel and Menu.Colors.SelectedBg.b or 20, 255)
            local textW = string.len(tab.name) * 9
            Menu.DrawText(tx + tabW/2 - textW/2, startY + mainH/2 - 9, tab.name, 16, 255,255,255,255)
        end
    end

    local categories = {}
    for i = 2, #Menu.Categories do table.insert(categories, Menu.Categories[i]) end
    for i, cat in ipairs(categories) do
        local y = startY + mainH + spacing + (i-1)*itemH
        local isSel = (i+1 == Menu.CurrentCategory)
        Menu.DrawRect(x, y, w, itemH, 30,30,30, 200)
        if isSel then
            Menu.DrawRect(x, y, 3, itemH, Menu.Colors.SelectedBg.r, Menu.Colors.SelectedBg.g, Menu.Colors.SelectedBg.b, 255)
        end
        Menu.DrawText(x+10, y+itemH/2-8, cat.name, 16, 255,255,255,255)
        Menu.DrawText(x+w-30, y+itemH/2-8, ">", 16, 200,200,200,255)
    end
end

-- Pie de página
function Menu.DrawFooter()
    local sp = Menu.GetScaledPosition()
    local bannerH = (Menu.Banner.enabled and Menu.Banner.height or sp.headerHeight) * Menu.Scale
    local headH = bannerH
    local mainH = sp.mainMenuHeight
    local spacing = sp.mainMenuSpacing
    local categoriesCount = #Menu.Categories - 1
    local visible = math.min(categoriesCount, Menu.ItemsPerPage)
    local totalH = headH + mainH + spacing + visible * sp.itemHeight + sp.footerSpacing
    local y = sp.y + totalH
    Menu.DrawRect(sp.x, y, sp.width-1, sp.footerHeight, 0,0,0, 255)
    Menu.DrawText(sp.x+10, y+sp.footerHeight/2-8, "SENTEXMODZ .gg/JAjYK5Aa", 13, 150,150,150,255)
    local posText = string.format("%d/%d", Menu.CurrentCategory-1, categoriesCount)
    local posW = string.len(posText) * 8
    Menu.DrawText(sp.x+sp.width-20-posW, y+sp.footerHeight/2-8, posText, 13, 150,150,150,255)
end

-- Fondo y partículas
Menu.Particles = {}
function Menu.DrawBackground()
    -- fondo negro transparente opcional
end

-- Render principal
function Menu.Render()
    if not (Susano and Susano.BeginFrame) then return end
    Susano.BeginFrame()
    if Menu.Visible then
        Menu.DrawBackground()
        Menu.DrawHeader()
        Menu.DrawCategories()
        Menu.DrawFooter()
    end
    if Menu.OnRender then pcall(Menu.OnRender) end
    Susano.SubmitFrame()
end

-- Manejo de teclas (simplificado basado en el original)
Menu.KeyStates = {}
function Menu.IsKeyJustPressed(key)
    if not Susano or not Susano.GetAsyncKeyState then return false end
    local down, pressed = Susano.GetAsyncKeyState(key)
    local was = Menu.KeyStates[key] or false
    Menu.KeyStates[key] = down
    return (pressed == true) or (down and not was)
end

function Menu.HandleInput()
    if not Menu.Visible then return end
    local toggleKey = Menu.SelectedKey or 0x31 -- tecla '1'
    if Menu.IsKeyJustPressed(toggleKey) then
        Menu.Visible = false
        if Susano and Susano.ResetFrame then Susano.ResetFrame() end
        return
    end

    if Menu.OpenedCategory then
        local cat = Menu.Categories[Menu.OpenedCategory]
        if not cat then Menu.OpenedCategory = nil return end
        local tab = cat.tabs[Menu.CurrentTab]
        if tab and tab.items then
            if Menu.IsKeyJustPressed(0x26) then -- up
                Menu.CurrentItem = Menu.CurrentItem - 1
                if Menu.CurrentItem < 1 then Menu.CurrentItem = #tab.items end
            elseif Menu.IsKeyJustPressed(0x28) then -- down
                Menu.CurrentItem = Menu.CurrentItem + 1
                if Menu.CurrentItem > #tab.items then Menu.CurrentItem = 1 end
            elseif Menu.IsKeyJustPressed(0x08) then -- backspace
                Menu.OpenedCategory = nil
            elseif Menu.IsKeyJustPressed(0x0D) then -- enter
                local item = tab.items[Menu.CurrentItem]
                if item and item.type == "toggle" then
                    item.value = not item.value
                    if item.onClick then item.onClick(item.value) end
                elseif item and item.type == "action" then
                    if item.onClick then item.onClick() end
                end
            end
        end
    else
        if Menu.IsKeyJustPressed(0x26) then -- up
            Menu.CurrentCategory = Menu.CurrentCategory - 1
            if Menu.CurrentCategory < 2 then Menu.CurrentCategory = #Menu.Categories end
        elseif Menu.IsKeyJustPressed(0x28) then -- down
            Menu.CurrentCategory = Menu.CurrentCategory + 1
            if Menu.CurrentCategory > #Menu.Categories then Menu.CurrentCategory = 2 end
        elseif Menu.IsKeyJustPressed(0x0D) then -- enter
            local cat = Menu.Categories[Menu.CurrentCategory]
            if cat and cat.hasTabs then
                Menu.OpenedCategory = Menu.CurrentCategory
                Menu.CurrentTab = 1
                Menu.CurrentItem = 1
            end
        end
    end
end

-- Inicialización
CreateThread(function()
    Menu.ApplyTheme("Lime")
    while true do
        Menu.Render()
        if Menu.LoadingComplete then
            Menu.HandleInput()
        end
        Wait(0)
    end
end)

-- Variables de ejemplo para que no falle
Menu.TopLevelTabs = {
    { name = "MAIN", categories = {}, autoOpen = false }
}
Menu.Categories = {
    { name = "MAIN" },
    { name = "Player", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Godmode", type = "toggle", value = false, onClick = function(v) print("Godmode", v) end },
            { name = "Noclip", type = "toggle", value = false },
            { name = "Heal", type = "action", onClick = function() print("Healed") end }
        } }
    } },
    { name = "Settings", hasTabs = true, tabs = {
        { name = "General", items = {
            { name = "Menu Size", type = "slider", value = 100, min = 50, max = 200, onClick = function(v) Menu.Scale = v/100 end },
            { name = "Black Background", type = "toggle", value = true }
        } }
    } }
}
Menu.LoadingComplete = true
Menu.LoadingBarAlpha = 0

return Menu
