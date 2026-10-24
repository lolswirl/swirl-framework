---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

function C.CreateVerticalTabs(parent, tabs)
    local theme  = T()
    local stripW = theme.tabsWidth

    local strip = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    strip:SetPoint("TOPLEFT",    parent, "TOPLEFT",    0, 0)
    strip:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    strip:SetWidth(stripW)
    SetBackdrop(strip, theme.bg.med, theme.border.color)

    local function MakeLine(w, h, r, g, b, a)
        local t = parent:CreateTexture(nil, "OVERLAY")
        if w then t:SetWidth(w) else t:SetHeight(h) end
        t:SetColorTexture(r, g, b, a)
        return t
    end

    local stTop = MakeLine(nil, 1, 1, 1, 1, 0.12)
    stTop:SetPoint("TOPLEFT",  strip, "TOPLEFT",  0, 0)
    stTop:SetPoint("TOPRIGHT", strip, "TOPRIGHT", 0, 0)

    local stBot = MakeLine(nil, 1, 1, 1, 1, 0.08)
    stBot:SetPoint("BOTTOMLEFT",  strip, "BOTTOMLEFT",  0, 0)
    stBot:SetPoint("BOTTOMRIGHT", strip, "BOTTOMRIGHT", 0, 0)

    local vSep = MakeLine(1, nil, 1, 1, 1, 0.12)
    vSep:SetPoint("TOPLEFT",    strip, "TOPRIGHT",    0, 0)
    vSep:SetPoint("BOTTOMLEFT", strip, "BOTTOMRIGHT", 0, 0)

    local contentHost = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    contentHost:SetPoint("TOPLEFT",     strip,  "TOPRIGHT",    1, 0)
    contentHost:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    SetBackdrop(contentHost, CreateColor(0, 0, 0, 0), theme.border.color)

    local chTop = MakeLine(nil, 1, 1, 1, 1, 0.12)
    chTop:SetPoint("TOPLEFT",  contentHost, "TOPLEFT",  0, 0)
    chTop:SetPoint("TOPRIGHT", contentHost, "TOPRIGHT", 0, 0)

    local chBot = MakeLine(nil, 1, 1, 1, 1, 0.08)
    chBot:SetPoint("BOTTOMLEFT",  contentHost, "BOTTOMLEFT",  0, 0)
    chBot:SetPoint("BOTTOMRIGHT", contentHost, "BOTTOMRIGHT", 0, 0)

    local tabs_data   = {}
    local keyToIndex  = {}
    local selectedKey = nil

    local function SetTabSelected(data, isSelected)
        local btn = data.btn
        if isSelected then
            btn.indicator:Show()
            btn.bg:SetColorTexture(T().accent.r * 0.15, T().accent.g * 0.15, T().accent.b * 0.15, 1)
            btn.label:SetTextColor(1, 1, 1, 1)
        else
            btn.indicator:Hide()
            btn.bg:SetColorTexture(0, 0, 0, 0)
            local color = T().text.secondary
            btn.label:SetTextColor(color.r, color.g, color.b, 1)
        end
    end

    local controller = {}

    function controller.Select(key)
        if selectedKey == key then return end
        selectedKey = key
        for _, d in ipairs(tabs_data) do
            local isSel = (d.key == key)
            SetTabSelected(d, isSel)
            d.content:SetShown(isSel)
            if isSel and d.onSelect then d.onSelect(d.content) end
        end
    end

    function controller.GetContent(key)
        local i = keyToIndex[key]
        return i and tabs_data[i] and tabs_data[i].content
    end

    local prev = nil
    for i, def in ipairs(tabs) do
        local btn = CreateFrame("Button", nil, strip, "BackdropTemplate")
        btn:SetHeight(theme.tabHeight)
        btn:ClearAllPoints()
        if not prev then
            btn:SetPoint("TOPLEFT",  strip, "TOPLEFT",  1, -1)
            btn:SetPoint("TOPRIGHT", strip, "TOPRIGHT", -1, -1)
        else
            btn:SetPoint("TOPLEFT",  prev,  "BOTTOMLEFT",  0, -theme.tabSpacing)
            btn:SetPoint("TOPRIGHT", strip, "TOPRIGHT",   -1, 0)
        end
        prev = btn

        SetBackdrop(btn, CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, 0))

        local bg = btn:CreateTexture(nil, "ARTWORK")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0)
        btn.bg = bg

        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetWidth(3)
        indicator:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0, 0)
        indicator:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 0)
        indicator:SetColorTexture(T().accent.r, T().accent.g, T().accent.b, 1)
        indicator:Hide()
        btn.indicator = indicator

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        ApplyFont(lbl, "normal")
        lbl:SetText(def.title or def.key)
        lbl:SetPoint("LEFT", btn, "LEFT", 10, 0)
        local color = T().text.secondary
        lbl:SetTextColor(color.r, color.g, color.b, 1)
        btn.label = lbl

        btn:SetScript("OnEnter", function()
            if selectedKey ~= def.key then bg:SetColorTexture(1, 1, 1, 0.04) end
        end)
        btn:SetScript("OnLeave", function()
            if selectedKey ~= def.key then bg:SetColorTexture(0, 0, 0, 0) end
        end)

        local content = CreateFrame("Frame", nil, contentHost)
        content:SetAllPoints(contentHost)
        content:Hide()

        tabs_data[i]        = { key = def.key, btn = btn, content = content, onSelect = def.onSelect }
        keyToIndex[def.key] = i

        btn:SetScript("OnClick", function() controller.Select(def.key) end)
    end

    if tabs_data[1] then controller.Select(tabs_data[1].key) end

    return strip, contentHost, controller
end
