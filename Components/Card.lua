local _, SF = ...
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

function C:CreateCard(parent, title)
    local theme = T()

    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    SetBackdrop(card, theme.bg.light, theme.border.color)
    card.contentHeight = 0
    card._lastWidget   = nil

    local headerH = 0
    if title and title ~= "" then
        headerH = 30
        local hdr = CreateFrame("Frame", nil, card, "BackdropTemplate")
        hdr:SetHeight(headerH)
        hdr:SetPoint("TOPLEFT",  card, "TOPLEFT",  0, 0)
        hdr:SetPoint("TOPRIGHT", card, "TOPRIGHT", 0, 0)
        SetBackdrop(hdr, theme.bg.med, theme.border.color)

        local titleFS = hdr:CreateFontString(nil, "OVERLAY")
        titleFS:SetPoint("LEFT", hdr, "LEFT", theme.padding.med, 0)
        ApplyFont(titleFS, "large")
        titleFS:SetText(title)
        titleFS:SetTextColor(theme.accent.r, theme.accent.g, theme.accent.b, 1)
        card.header    = hdr
        card.titleText = titleFS
    end

    card.innerTop = headerH

    function card:AddWidget(widget, topPad, widgetHeight)
        local theme2 = T()
        local pad    = topPad or theme2.padding.small
        local yOff   = -(self.innerTop + self.contentHeight + pad)
        widget:SetParent(self)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT",  self, "TOPLEFT",  theme2.padding.med, yOff)
        widget:SetPoint("TOPRIGHT", self, "TOPRIGHT", -theme2.padding.med, yOff)
        self.contentHeight = self.contentHeight + (widgetHeight or widget:GetHeight() or 20) + pad
        self:SetHeight(self.innerTop + self.contentHeight + theme2.padding.med)
        self._lastWidget = widget
        if self._headerGated then
            self._headerGated[#self._headerGated + 1] = widget
            if widget.SetEnabled and self.headerToggle then
                widget:SetEnabled(self.headerToggle:GetValue())
            end
        end
    end

    function card:AddSeparator()
        local theme2 = T()
        local sep = self:CreateTexture(nil, "ARTWORK")
        sep:SetHeight(1)
        local yOff = -(self.innerTop + self.contentHeight + theme2.padding.small)
        sep:SetPoint("TOPLEFT",  self, "TOPLEFT",  theme2.padding.med, yOff)
        sep:SetPoint("TOPRIGHT", self, "TOPRIGHT", -theme2.padding.med, yOff)
        sep:SetColorTexture(1, 1, 1, 0.08)
        self.contentHeight = self.contentHeight + 1 + theme2.padding.small
        self:SetHeight(self.innerTop + self.contentHeight + theme2.padding.med)
    end

    function card:AddLabel(text, color, textSize)
        local theme2 = T()
        local fs = self:CreateFontString(nil, "OVERLAY")
        ApplyFont(fs, textSize or "normal")
        local c = color or theme2.text.secondary
        fs:SetTextColor(c.r, c.g, c.b, c.a or 1)
        fs:SetJustifyH("LEFT")
        fs:SetWordWrap(true)

        local cardWidth = self:GetWidth()
        if cardWidth and cardWidth > 0 then
            fs:SetWidth(cardWidth - theme2.padding.med * 2)
        end
        fs:SetText(text or "")
        local yOff = -(self.innerTop + self.contentHeight + theme2.padding.small)
        fs:SetPoint("TOPLEFT",  self, "TOPLEFT",  theme2.padding.med, yOff)
        fs:SetPoint("TOPRIGHT", self, "TOPRIGHT", -theme2.padding.med, yOff)
        local h = math.max(14, fs:GetStringHeight())
        self.contentHeight = self.contentHeight + h + theme2.padding.small
        self:SetHeight(self.innerTop + self.contentHeight + theme2.padding.med)
        self:_GateText(fs)
        return fs
    end

    local blocker = CreateFrame("Frame", nil, card)
    blocker:SetAllPoints()
    blocker:SetFrameLevel(card:GetFrameLevel() + 100)
    blocker:EnableMouse(false)

    local _dependents = {}
    local _enableValue = nil

    function card:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        blocker:EnableMouse(not enabled)
    end

    function card:SetDependents(...)
        _dependents = { ... }
        if _enableValue ~= nil then
            for _, dep in ipairs(_dependents) do
                dep:SetEnabled(_enableValue)
            end
        end
    end

    function card:AddEnableToggle(label, initialValue, onChange, config)
        config = config or {}
        _enableValue = initialValue
        local toggle = C:CreateToggle(self, label, initialValue, function(val)
            _enableValue = val
            for _, dep in ipairs(_dependents) do
                dep:SetEnabled(val)
            end
            if onChange then onChange(val) end
        end)
        self:AddWidget(toggle, config.topPad, config.height or nil)
        return toggle
    end

    function card:AddHeaderToggle(initialValue, onChange)
        if not self.header then return end
        local theme2 = T()
        self._headerGated = {}
        local toggle = C:CreateToggle(self.header, "", initialValue, function(val)
            self:SetContentEnabled(val)
            if onChange then onChange(val) end
        end)
        toggle:ClearAllPoints()
        toggle:SetPoint("RIGHT", self.header, "RIGHT", -theme2.padding.med, 0)
        toggle:SetWidth(theme2.toggleWidth + 24 + theme2.padding.small)
        self.headerToggle = toggle
        return toggle
    end

    function card:_GateText(region)
        if not self._headerGated then return region end
        self._headerGatedText = self._headerGatedText or {}
        self._headerGatedText[#self._headerGatedText + 1] = region
        if self.headerToggle then
            region:SetAlpha(self.headerToggle:GetValue() and 1 or 0.4)
        end
        return region
    end

    function card:SetContentEnabled(enabled)
        for _, w in ipairs(self._headerGated or {}) do
            if w.SetEnabled then w:SetEnabled(enabled) end
        end
        for _, fs in ipairs(self._headerGatedText or {}) do
            fs:SetAlpha(enabled and 1 or 0.4)
        end
    end

    function card:AddSectionHeader(text, isFirst)
        local theme2 = T()
        local topPad = isFirst and theme2.padding.small or theme2.padding.large
        local yOff = -(self.innerTop + self.contentHeight + topPad)

        local fs = self:CreateFontString(nil, "OVERLAY")
        ApplyFont(fs, "normal")
        local c = theme2.accent
        fs:SetTextColor(c.r, c.g, c.b, 1)
        fs:SetJustifyH("LEFT")
        fs:SetText(text or "")
        fs:SetPoint("TOPLEFT", self, "TOPLEFT", theme2.padding.med, yOff)

        local line = self:CreateTexture(nil, "ARTWORK")
        line:SetHeight(1)
        line:SetColorTexture(c.r, c.g, c.b, 0.25)
        line:SetPoint("LEFT", fs, "RIGHT", theme2.padding.small, 0)
        line:SetPoint("RIGHT", self, "RIGHT", -theme2.padding.med, 0)

        local h = math.max(14, fs:GetStringHeight())
        self.contentHeight = self.contentHeight + h + topPad
        self:SetHeight(self.innerTop + self.contentHeight + theme2.padding.med)

        self:_GateText(fs)
        self:_GateText(line)

        return fs
    end

    card:SetHeight(headerH + theme.padding.med)
    return card
end

function C:CreateDivider(parent, text, fontSize)
    local theme = T()
    local container = CreateFrame("Frame", nil, parent)
    container:SetHeight(22)

    local lbl = container:CreateFontString(nil, "OVERLAY")
    ApplyFont(lbl, fontSize or "large")
    lbl:SetText(text or "")
    local color = theme.text.muted
    lbl:SetTextColor(color.r, color.g, color.b, 1)
    lbl:SetPoint("CENTER", container, "CENTER", 0, 0)
    container.label = lbl

    local lineL = container:CreateTexture(nil, "ARTWORK")
    lineL:SetColorTexture(1, 1, 1, 0.10)
    lineL:SetHeight(1)
    lineL:SetPoint("LEFT",  container, "LEFT",  0,  0)
    lineL:SetPoint("RIGHT", lbl,       "LEFT", -6,  0)

    local lineR = container:CreateTexture(nil, "ARTWORK")
    lineR:SetColorTexture(1, 1, 1, 0.10)
    lineR:SetHeight(1)
    lineR:SetPoint("LEFT",  lbl,       "RIGHT",  6, 0)
    lineR:SetPoint("RIGHT", container, "RIGHT",  0, 0)

    return container
end
