local _, SF = ...
local C = SF.Components
local T, SetBackdrop, ApplyFont = C.T, C.SetBackdrop, C.ApplyFont

function C:CreateToggle(parent, labelText, initialState, onChange)
    local theme = T()
    local TOGGLE_W = theme.toggleWidth
    local TOGGLE_H = 16
    local KNOB = TOGGLE_H - 4
    local PAD = 2
    local ANIM_DUR = 0.18
    local OFF_X = PAD
    local ON_X = TOGGLE_W - KNOB - PAD
    local WORD_W = 24

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(22)

    local toggle = CreateFrame("Frame", nil, row, "BackdropTemplate")
    toggle:SetSize(TOGGLE_W, TOGGLE_H)
    toggle:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    SetBackdrop(toggle, theme.bg.med, theme.border.color)

    local word = row:CreateFontString(nil, "OVERLAY")
    word:SetPoint("RIGHT", toggle, "LEFT", -theme.padding.small, 0)
    word:SetWidth(WORD_W)
    word:SetJustifyH("RIGHT")
    ApplyFont(word, "small")

    local lbl = C.CreateLabel(row, labelText)
    lbl:ClearAllPoints()
    lbl:SetPoint("LEFT", row, "LEFT", 0, 0)
    lbl:SetPoint("RIGHT", word, "LEFT", -theme.padding.small, 0)
    row.label = lbl

    local knob = CreateFrame("Frame", nil, toggle, "BackdropTemplate")
    knob:SetSize(KNOB, KNOB)
    knob:SetPoint("LEFT", toggle, "LEFT", OFF_X, 0)
    knob:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = -1, right = -1, top = 0, bottom = 0 },
    })
    knob:SetBackdropColor(0, 0, 0, 1)
    knob:SetBackdropBorderColor(0, 0, 0, 1)

    local knobTex = knob:CreateTexture(nil, "ARTWORK")
    knobTex:SetAllPoints()

    local function OnColor() return T().accent end
    local function OffColor() return T().text.muted end

    local slideGroup = knob:CreateAnimationGroup()
    local slideAnim = slideGroup:CreateAnimation("Translation")
    slideAnim:SetDuration(ANIM_DUR)
    slideAnim:SetSmoothing("OUT")

    local colorGroup = toggle:CreateAnimationGroup()
    colorGroup:SetLooping("NONE")
    local colorAnim = colorGroup:CreateAnimation("Animation")
    colorAnim:SetDuration(ANIM_DUR)
    local cFrom, cTo = {}, {}
    local knobR, knobG, knobB = OffColor().r, OffColor().g, OffColor().b

    colorGroup:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        toggle:SetBackdropColor(
            cFrom.bgR + (cTo.bgR - cFrom.bgR) * p,
            cFrom.bgG + (cTo.bgG - cFrom.bgG) * p,
            cFrom.bgB + (cTo.bgB - cFrom.bgB) * p, 1)
        knobR = cFrom.kr + (cTo.kr - cFrom.kr) * p
        knobG = cFrom.kg + (cTo.kg - cFrom.kg) * p
        knobB = cFrom.kb + (cTo.kb - cFrom.kb) * p
        knobTex:SetColorTexture(knobR, knobG, knobB, 1)
    end)
    colorGroup:SetScript("OnFinished", function()
        toggle:SetBackdropColor(cTo.bgR, cTo.bgG, cTo.bgB, 1)
        knobTex:SetColorTexture(cTo.kr, cTo.kg, cTo.kb, 1)
        knobR, knobG, knobB = cTo.kr, cTo.kg, cTo.kb
    end)

    local state = initialState or false
    local animating = false

    local function UpdateWord(toState)
        local c = toState and OnColor() or T().text.muted
        word:SetText(toState and "ON" or "OFF")
        word:SetTextColor(c.r, c.g, c.b, 1)
    end

    local function UpdateColors(toState, instant)
        local on, off = OnColor(), OffColor()
        local bgD = T().bg.med
        local bgA = CreateColor(on.r * 0.45, on.g * 0.45, on.b * 0.45, 1)
        local kc = toState and on or off
        if instant then
            toggle:SetBackdropColor(
                toState and bgA.r or bgD.r,
                toState and bgA.g or bgD.g,
                toState and bgA.b or bgD.b, 1)
            knobTex:SetColorTexture(kc.r, kc.g, kc.b, 1)
            knobR, knobG, knobB = kc.r, kc.g, kc.b
            return
        end
        colorGroup:Stop()
        cFrom.bgR, cFrom.bgG, cFrom.bgB = toggle:GetBackdropColor()
        cFrom.kr, cFrom.kg, cFrom.kb = knobR, knobG, knobB
        cTo.bgR = toState and bgA.r or bgD.r
        cTo.bgG = toState and bgA.g or bgD.g
        cTo.bgB = toState and bgA.b or bgD.b
        cTo.kr, cTo.kg, cTo.kb = kc.r, kc.g, kc.b
        colorGroup:Play()
    end

    local function AnimateTo(toState, instant)
        if animating and not instant then return end
        animating = true
        state = toState
        local targetX = toState and ON_X or OFF_X
        local currentX = select(4, knob:GetPoint()) or OFF_X
        local delta = targetX - currentX
        UpdateColors(toState, instant)
        UpdateWord(toState)
        if instant or math.abs(delta) < 1 then
            knob:ClearAllPoints()
            knob:SetPoint("LEFT", toggle, "LEFT", targetX, 0)
            animating = false
        else
            slideGroup:Stop()
            knob:ClearAllPoints()
            knob:SetPoint("LEFT", toggle, "LEFT", currentX, 0)
            slideAnim:SetOffset(delta, 0)
            slideGroup:SetScript("OnFinished", function()
                knob:ClearAllPoints()
                knob:SetPoint("LEFT", toggle, "LEFT", targetX, 0)
                animating = false
            end)
            slideGroup:Play()
        end
    end

    AnimateTo(state, true)

    local hover = row:CreateTexture(nil, "BACKGROUND")
    hover:SetPoint("TOPLEFT", row, "TOPLEFT", -theme.padding.small, 0)
    hover:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", theme.padding.small, 0)
    hover:SetColorTexture(1, 1, 1, 0.05)
    hover:Hide()

    local clickBtn = CreateFrame("Button", nil, row)
    clickBtn:SetAllPoints()
    clickBtn:SetFrameLevel(toggle:GetFrameLevel() + 10)
    clickBtn:RegisterForClicks("LeftButtonUp")
    clickBtn:SetScript("OnClick", function()
        if slideGroup:IsPlaying() or colorGroup:IsPlaying() then return end
        local newState = not state
        AnimateTo(newState, false)
        if onChange then
            C_Timer.After(ANIM_DUR, function() onChange(newState) end)
        end
    end)

    local kbAG = knob:CreateAnimationGroup()
    kbAG:SetLooping("NONE")
    local kbAnim = kbAG:CreateAnimation("Animation")
    kbAnim:SetDuration(0.15)
    local kbFrom, kbTo = {}, {}
    local kbR, kbG, kbB = theme.border.color.r, theme.border.color.g, theme.border.color.b

    kbAG:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        kbR = kbFrom.r + (kbTo.r - kbFrom.r) * p
        kbG = kbFrom.g + (kbTo.g - kbFrom.g) * p
        kbB = kbFrom.b + (kbTo.b - kbFrom.b) * p
        knob:SetBackdropBorderColor(kbR, kbG, kbB, 1)
    end)
    kbAG:SetScript("OnFinished", function()
        knob:SetBackdropBorderColor(kbTo.r, kbTo.g, kbTo.b, 1)
        kbR, kbG, kbB = kbTo.r, kbTo.g, kbTo.b
    end)

    local function AnimateKnobBorder(toAccent)
        kbAG:Stop()
        kbFrom.r, kbFrom.g, kbFrom.b = kbR, kbG, kbB
        local c = toAccent and T().accent or T().border.color
        kbTo.r, kbTo.g, kbTo.b = c.r, c.g, c.b
        kbAG:Play()
    end

    clickBtn:SetScript("OnEnter", function()
        hover:Show()
        local c = state and OnColor() or OffColor()
        knobTex:SetColorTexture(c.r * 1.25, c.g * 1.25, c.b * 1.25, 1)
        knobR, knobG, knobB = c.r * 1.25, c.g * 1.25, c.b * 1.25
        AnimateKnobBorder(true)
    end)
    clickBtn:SetScript("OnLeave", function()
        hover:Hide()
        local c = state and OnColor() or OffColor()
        knobTex:SetColorTexture(c.r, c.g, c.b, 1)
        knobR, knobG, knobB = c.r, c.g, c.b
        AnimateKnobBorder(false)
    end)

    function row:SetValue(value, instant)
        if value ~= state then AnimateTo(value, instant) end
    end
    function row:GetValue() return state end
    function row:SetEnabled(enabled)
        row:SetAlpha(enabled and 1 or 0.4)
        clickBtn:EnableMouse(enabled)
    end

    return row
end
