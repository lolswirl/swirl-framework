local _, SF = ...
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

local ITEM_H = 22
local MAX_LIST_H = 300
local ANIM_DUR = 0.12

local overlay = CreateFrame("Frame", "SF_DropdownOverlay", UIParent)
overlay:SetAllPoints()
overlay:SetFrameStrata("TOOLTIP")
overlay:EnableMouse(false)

local _activeDropdown = nil
WorldFrame:HookScript("OnMouseDown", function()
    if _activeDropdown and _activeDropdown._isOpen then
        if not _activeDropdown._list:IsMouseOver() and not _activeDropdown._btn:IsMouseOver() then
            _activeDropdown:_close()
        end
    end
end)

function C:CreateDropdown(parent, labelText, options, initialValue, onChange)
    local theme = T()

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(36)

    local lbl = C.CreateLabel(row, labelText)

    local btn = CreateFrame("Button", nil, row, "BackdropTemplate")
    btn:SetHeight(24)
    btn:SetPoint("TOPLEFT",  row, "TOPLEFT",  0, -14)
    btn:SetPoint("TOPRIGHT", row, "TOPRIGHT",  0, -14)
    SetBackdrop(btn, theme.bg.med, theme.border.color)

    local selText = btn:CreateFontString(nil, "OVERLAY")
    selText:SetPoint("LEFT",  btn, "LEFT",   6, 0)
    selText:SetPoint("RIGHT", btn, "RIGHT", -20, 0)
    selText:SetJustifyH("LEFT")
    ApplyFont(selText, "small")
    local ac = theme.accent
    selText:SetTextColor(ac.r, ac.g, ac.b, 1)

    local arrow = btn:CreateTexture(nil, "ARTWORK")
    arrow:SetSize(14, 14)
    arrow:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
    arrow:SetTexture(SF.MediaPath("UI\\Media\\Chevron.png"))
    arrow:SetVertexColor(ac.r, ac.g, ac.b, 1)
    arrow:SetRotation(math.rad(90))
    arrow:SetTexelSnappingBias(0)
    arrow:SetSnapToPixelGrid(false)

    local AnimBorder = C.MakeBorderAnimator(btn)

    local list = CreateFrame("Frame", nil, overlay, "BackdropTemplate")
    list:Hide()
    list:SetFrameLevel(overlay:GetFrameLevel() + 10)
    list:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.border.size,
    })
    list:SetBackdropColor(theme.bg.med.r, theme.bg.med.g, theme.bg.med.b, 1)
    list:SetBackdropBorderColor(theme.border.color.r, theme.border.color.g, theme.border.color.b, 1)

    local sf = CreateFrame("ScrollFrame", nil, list)
    sf:SetPoint("TOPLEFT",     list, "TOPLEFT",     1, -1)
    sf:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -1,  1)
    sf:EnableMouseWheel(true)

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetWidth(1)
    sf:SetScrollChild(sc)

    sf:SetScript("OnMouseWheel", function(_, d)
        local contentH = sc:GetHeight()
        local viewH = sf:GetHeight()
        local maxScroll = math.max(0, contentH - viewH)
        local newScroll = math.max(0, math.min(maxScroll, sf:GetVerticalScroll() - d * ITEM_H))
        sf:SetVerticalScroll(newScroll)
    end)

    local oAG = list:CreateAnimationGroup()
    local oAnim = oAG:CreateAnimation("Animation")
    oAnim:SetDuration(ANIM_DUR)
    local oFrom, oTo = 0, 0
    oAG:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        list:SetHeight(oFrom + (oTo - oFrom) * p)
    end)
    oAG:SetScript("OnFinished", function()
        list:SetHeight(oTo)
        if oTo <= 1 then list:Hide() end
    end)

    local _options = {}
    local function ParseOptions(opts)
        for i = #_options, 1, -1 do _options[i] = nil end
        if not opts then return end
        for _, v in ipairs(opts) do
            if type(v) == "table" then
                _options[#_options+1] = { text = tostring(v.text), value = v.value }
            else
                _options[#_options+1] = { text = tostring(v), value = v }
            end
        end
    end
    ParseOptions(options)

    local currentValue = initialValue
    local itemBtns = {}

    local function TextForValue(val)
        for _, opt in ipairs(_options) do
            if opt.value == val then return opt.text end
        end
        return val ~= nil and tostring(val) or ""
    end

    local function SetSelectedText(val)
        selText:SetText(TextForValue(val))
    end
    SetSelectedText(currentValue)

    local function RebuildItems()
        for _, ib in ipairs(itemBtns) do ib:Hide() end
        itemBtns = {}
        local th = T()
        for i, opt in ipairs(_options) do
            local ib = CreateFrame("Button", nil, sc)
            ib:SetHeight(ITEM_H)
            ib:SetPoint("TOPLEFT",  sc, "TOPLEFT",  0, -(i-1)*ITEM_H)
            ib:SetPoint("TOPRIGHT", sc, "TOPRIGHT",  0, -(i-1)*ITEM_H)

            local hbg = ib:CreateTexture(nil, "BACKGROUND")
            hbg:SetAllPoints()
            hbg:SetColorTexture(th.accent.r, th.accent.g, th.accent.b, 0.15)
            hbg:Hide()

            local iText = ib:CreateFontString(nil, "OVERLAY")
            iText:SetPoint("LEFT",  ib, "LEFT",  6, 0)
            iText:SetPoint("RIGHT", ib, "RIGHT", -6, 0)
            iText:SetJustifyH("LEFT")
            ApplyFont(iText, "small")

            local function UpdateColor()
                local c = (currentValue == opt.value) and T().accent or T().text.secondary
                iText:SetTextColor(c.r, c.g, c.b, 1)
            end
            UpdateColor()
            iText:SetText(opt.text)

            ib:SetScript("OnEnter", function() hbg:Show(); iText:SetTextColor(1, 1, 1, 1) end)
            ib:SetScript("OnLeave", function() hbg:Hide(); UpdateColor() end)
            ib:SetScript("OnClick", function()
                currentValue = opt.value
                SetSelectedText(opt.value)
                for _, b in ipairs(itemBtns) do
                    if b._updateColor then b._updateColor() end
                end
                row:_close()
                if onChange then onChange(opt.value) end
            end)
            ib._updateColor = UpdateColor
            itemBtns[#itemBtns+1] = ib
        end
        sc:SetHeight(#_options * ITEM_H)
        sc:SetWidth(1)
    end

    local itemsBuilt = false

    function row:_close()
        if not self._isOpen then return end
        self._isOpen = false
        arrow:SetRotation(math.rad(90))
        oAG:Stop()
        oFrom = list:GetHeight()
        oTo = 1
        oAG:Play()
        if _activeDropdown == self then _activeDropdown = nil end
    end

    local function Open()
        if not itemsBuilt then RebuildItems(); itemsBuilt = true end
        if _activeDropdown and _activeDropdown ~= row then _activeDropdown:_close() end

        list:ClearAllPoints()
        list:SetPoint("TOPLEFT",  btn, "BOTTOMLEFT",  0, -2)
        list:SetPoint("TOPRIGHT", btn, "BOTTOMRIGHT", 0, -2)

        local contentH = #_options * ITEM_H
        local targetH = math.min(contentH + 2, MAX_LIST_H)
        sf:SetVerticalScroll(0)

        list:Show()
        oAG:Stop()
        oFrom = 1
        oTo = targetH
        list:SetHeight(1)
        oAG:Play()

        C_Timer.After(0, function()
            if row._isOpen then sc:SetWidth(list:GetWidth()) end
        end)

        arrow:SetRotation(math.rad(0))
        row._isOpen = true
        _activeDropdown = row
    end

    btn:SetScript("OnClick", function() if row._isOpen then row:_close() else Open() end end)
    btn:SetScript("OnEnter", function() AnimBorder(true)  end)
    btn:SetScript("OnLeave", function() AnimBorder(false) end)
    btn:SetScript("OnHide",  function() row:_close() end)

    row._btn = btn
    row._list = list
    row._isOpen = false

    function row:SetValue(val, silent)
        currentValue = val
        SetSelectedText(val)
        if itemsBuilt then
            for _, ib in ipairs(itemBtns) do
                if ib._updateColor then ib._updateColor() end
            end
        end
        if onChange and not silent then onChange(val) end
    end

    function row:GetValue() return currentValue end

    function row:SetOptions(opts)
        ParseOptions(opts)
        itemsBuilt = false
        SetSelectedText(currentValue)
        if row._isOpen then row:_close() end
    end

    function row:SetEnabled(enabled)
        btn:EnableMouse(enabled)
        btn:SetAlpha(enabled and 1 or 0.4)
        lbl:SetAlpha(enabled and 1 or 0.4)
        if not enabled and row._isOpen then row:_close() end
    end

    return row
end
