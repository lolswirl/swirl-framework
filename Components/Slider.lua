---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

function C:CreateSlider(parent, labelText, minVal, maxVal, step, getVal, setVal, config)
    config = config or {}
    local theme = T()
    local stepperTexture = SF.MediaPath("UI\\Media\\Chevron.png")

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(36)
    if config.width then row:SetWidth(config.width) end

    local label = C.CreateLabel(row, labelText)
    row.label = label

    local sliderLeftOff = theme.toggleWidth + 20
    local sliderBG = CreateFrame("Frame", nil, row, "BackdropTemplate")
    sliderBG:SetHeight(8)
    sliderBG:SetPoint("TOPLEFT", row, "TOPLEFT", sliderLeftOff, -22)
    sliderBG:SetPoint("TOPRIGHT", row, "TOPRIGHT", -18, -22)
    SetBackdrop(sliderBG, theme.bg.med, theme.border.color)
    sliderBG:EnableMouse(false)

    local slider = CreateFrame("Slider", nil, row, "BackdropTemplate")
    slider:SetHeight(8)
    slider:SetPoint("TOPLEFT", row, "TOPLEFT", sliderLeftOff, -22)
    slider:SetPoint("TOPRIGHT", row, "TOPRIGHT", -18, -22)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(getVal())
    slider:SetHitRectInsets(-9, -9, -5, -5)
    SetBackdrop(slider, CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, 0))

    local fill = slider:CreateTexture(nil, "ARTWORK")
    fill:SetHeight(6)
    fill:SetPoint("LEFT", sliderBG, "LEFT", 0, 0)
    fill:SetColorTexture(theme.accent.r, theme.accent.g, theme.accent.b, 1)
    fill:SetTexelSnappingBias(0)
    fill:SetSnapToPixelGrid(false)

    local thumbFrameBG = CreateFrame("Frame", nil, slider, "BackdropTemplate")
    thumbFrameBG:SetSize(19, 12)
    SetBackdrop(thumbFrameBG, theme.accentDim, CreateColor(0, 0, 0, 0))

    local thumbFrame = CreateFrame("Frame", nil, slider, "BackdropTemplate")
    thumbFrame:SetSize(19, 12)
    local color = theme.text.secondary
    SetBackdrop(thumbFrame,
        CreateColor(color.r, color.g, color.b, 0.6),
        CreateColor(0, 0, 0, 1))

    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetColorTexture(0, 0, 0, 0)
    slider:SetThumbTexture(thumb)

    slider:HookScript("OnUpdate", function()
        if thumb:GetPoint() then
            thumbFrameBG:ClearAllPoints()
            thumbFrameBG:SetPoint("CENTER", thumb, "CENTER", 0, 0)
            thumbFrame:ClearAllPoints()
            thumbFrame:SetPoint("CENTER", thumb, "CENTER", 0, 0)
        end
    end)

    local thumbAG = slider:CreateAnimationGroup()
    local thumbAnim = thumbAG:CreateAnimation("Animation")
    thumbAnim:SetDuration(0.18)
    local tFrom = {}
    local tTo = {}
    local tR, tG, tB, tA = color.r, color.g, color.b, 0.6

    local function AnimateThumb(toHover, toDrag)
        thumbAG:Stop()
        tFrom.r, tFrom.g, tFrom.b, tFrom.a = tR, tG, tB, tA
        local ac = T().accent
        local ts = T().text.secondary
        if toDrag then
            tTo.r, tTo.g, tTo.b, tTo.a = ac.r, ac.g, ac.b, 1
        elseif toHover then
            tTo.r, tTo.g, tTo.b, tTo.a = ts.r, ts.g, ts.b, 1
        else
            tTo.r, tTo.g, tTo.b, tTo.a = ts.r, ts.g, ts.b, 0.6
        end
        thumbAG:Play()
    end

    thumbAG:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        local r = tFrom.r + (tTo.r - tFrom.r) * p
        local g = tFrom.g + (tTo.g - tFrom.g) * p
        local b = tFrom.b + (tTo.b - tFrom.b) * p
        local a = tFrom.a + (tTo.a - tFrom.a) * p
        thumbFrame:SetBackdropColor(r, g, b, a)
        tR, tG, tB, tA = r, g, b, a
    end)
    thumbAG:SetScript("OnFinished", function()
        thumbFrame:SetBackdropColor(tTo.r, tTo.g, tTo.b, tTo.a)
        tR, tG, tB, tA = tTo.r, tTo.g, tTo.b, tTo.a
    end)

    local function MakeStepper(anchor, anchorPoint, xOff, rotation, delta)
        local btn = CreateFrame("Button", nil, row)
        btn:SetSize(20, 20)
        btn:SetPoint(anchorPoint, sliderBG, anchor, xOff, 0)

        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetVertexColor(color.r, color.g, color.b, 1)
        icon:SetRotation(math.rad(rotation))
        icon:SetTexelSnappingBias(0)
        icon:SetSnapToPixelGrid(false)
        icon:SetTexture(stepperTexture)

        local sAG = btn:CreateAnimationGroup()
        local sAnim = sAG:CreateAnimation("Animation")
        sAnim:SetDuration(0.18)
        local sFrom = {}
        local sTo = {}
        local sR, sG, sB = color.r, color.g, color.b

        local function AnimateStepper(toAccent)
            sAG:Stop()
            sFrom.r, sFrom.g, sFrom.b = sR, sG, sB
            local c = toAccent and T().accent or T().text.secondary
            sTo.r, sTo.g, sTo.b = c.r, c.g, c.b
            sAG:Play()
        end

        sAG:SetScript("OnUpdate", function(ag)
            local p = ag:GetProgress() or 0
            local r = sFrom.r + (sTo.r - sFrom.r) * p
            local g = sFrom.g + (sTo.g - sFrom.g) * p
            local b = sFrom.b + (sTo.b - sFrom.b) * p
            icon:SetVertexColor(r, g, b, 1)
            sR, sG, sB = r, g, b
        end)
        sAG:SetScript("OnFinished", function()
            icon:SetVertexColor(sTo.r, sTo.g, sTo.b, 1)
            sR, sG, sB = sTo.r, sTo.g, sTo.b
        end)

        btn:SetScript("OnEnter", function() AnimateStepper(true)  end)
        btn:SetScript("OnLeave", function() AnimateStepper(false) end)
        btn:SetScript("OnClick", function()
            local mn, mx = slider:GetMinMaxValues()
            slider:SetValue(math.max(mn, math.min(mx, slider:GetValue() + delta)))
        end)

        return btn
    end

    MakeStepper("LEFT",  "RIGHT", 0, -90, -step)
    MakeStepper("RIGHT", "LEFT",  0,  90,  step)

    local valueContainer = CreateFrame("Frame", nil, slider, "BackdropTemplate")
    valueContainer:SetSize(theme.toggleWidth, 24)
    valueContainer:SetPoint("RIGHT", sliderBG, "LEFT", -20, 0)
    SetBackdrop(valueContainer, theme.bg.med, theme.border.color)

    local AnimateEditBorder = C.MakeBorderAnimator(valueContainer, 0.18)

    local valueEdit = CreateFrame("EditBox", nil, valueContainer)
    valueEdit:SetPoint("TOPLEFT", valueContainer, "TOPLEFT", 2, -2)
    valueEdit:SetPoint("BOTTOMRIGHT", valueContainer, "BOTTOMRIGHT", -2, 2)
    ApplyFont(valueEdit, "small")
    valueEdit:SetTextColor(theme.accent.r, theme.accent.g, theme.accent.b, 1)
    valueEdit:SetJustifyH("CENTER")
    valueEdit:SetAutoFocus(false)
    valueEdit:SetText(tostring(getVal()))
    row.valueEdit = valueEdit

    local isUpdating = false

    local function UpdateFill()
        local val = slider:GetValue()
        local mn, mx = slider:GetMinMaxValues()
        if mx == mn then return end
        local pct = (val - mn) / (mx - mn)
        local width = math.max(1, (slider:GetWidth() - 2) * pct)
        fill:SetWidth(width)
        if not isUpdating then
            isUpdating = true
            valueEdit:SetText(tostring(math.floor(val * 100 + 0.5) / 100))
            isUpdating = false
        end
    end

    slider:SetScript("OnValueChanged", function(_, val, userInput)
        UpdateFill()
        if userInput then setVal(val); SF.SettingsChanged = true end
    end)
    slider:SetScript("OnSizeChanged", UpdateFill)

    local function CommitEdit()
        local num = tonumber(valueEdit:GetText())
        if num then
            local mn, mx = slider:GetMinMaxValues()
            num = math.max(mn, math.min(mx, num))
            isUpdating = true
            slider:SetValue(num)
            setVal(num)
            SF.SettingsChanged = true
            isUpdating = false
        else
            UpdateFill()
        end
    end

    valueEdit:SetScript("OnEnterPressed", function(eb) eb:ClearFocus(); CommitEdit() end)
    valueEdit:SetScript("OnEscapePressed", function(eb) eb:ClearFocus(); UpdateFill() end)
    valueEdit:SetScript("OnEditFocusLost", CommitEdit)
    valueEdit:SetScript("OnEditFocusGained", function(eb)
        AnimateEditBorder(true)
        eb:HighlightText()
    end)
    valueEdit:SetScript("OnEnter", function(eb) if not eb:HasFocus() then AnimateEditBorder(true)  end end)
    valueEdit:SetScript("OnLeave", function(eb) if not eb:HasFocus() then AnimateEditBorder(false) end end)

    local curDrag = false
    slider:SetScript("OnMouseDown", function(_, btn)
        if btn == "LeftButton" then
            thumbAG:Stop()
            local ac = T().accent
            thumbFrame:SetBackdropColor(ac.r, ac.g, ac.b, 1)
            tR, tG, tB, tA = ac.r, ac.g, ac.b, 1
            curDrag = true
        end
    end)
    slider:SetScript("OnMouseUp", function(sl, btn)
        if btn == "LeftButton" then
            curDrag = false
            AnimateThumb(sl:IsMouseOver(), false)
        end
    end)
    slider:SetScript("OnEnter", function() if not curDrag then AnimateThumb(true,  false) end end)
    slider:SetScript("OnLeave", function() if not curDrag then AnimateThumb(false, false) end end)

    C_Timer.After(0, UpdateFill)

    function row:SetVal(val)
        isUpdating = true
        slider:SetValue(val)
        isUpdating = false
        UpdateFill()
    end
    function row:GetVal()      return slider:GetValue() end
    function row:SetEnabled(enabled)
        row:SetAlpha(enabled and 1 or 0.4)
        slider:EnableMouse(enabled)
        valueEdit:EnableMouse(enabled)
    end

    row.slider = slider
    return row
end
