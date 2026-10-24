---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

function C:CreateTextArea(parent, initialValue, onChange)
    local theme = T()

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    SetBackdrop(container, theme.bg.med, theme.border.color)

    local AnimBorder = C.MakeBorderAnimator(container)

    local sf = CreateFrame("ScrollFrame", nil, container)
    sf:SetPoint("TOPLEFT", container, "TOPLEFT", 4, -4)
    sf:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -4, 4)
    sf:EnableMouseWheel(true)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(false)
    eb:SetMaxLetters(0)
    eb:SetWidth(1)
    ApplyFont(eb, "small")
    local ac = theme.accent
    eb:SetTextColor(ac.r, ac.g, ac.b, 1)
    eb:SetText(tostring(initialValue or ""))
    sf:SetScrollChild(eb)

    sf:SetScript("OnSizeChanged", function(_, w, h)
        eb:SetWidth(w)
    end)
    sf:SetScript("OnMouseWheel", function(_, d)
        local maxScroll = sf:GetVerticalScrollRange()
        sf:SetVerticalScroll(math.max(0, math.min(maxScroll, sf:GetVerticalScroll() - d * 20)))
    end)
    sf:SetScript("OnMouseDown", function() eb:SetFocus() end)

    eb:SetScript("OnEscapePressed", function(e) e:ClearFocus() end)
    eb:SetScript("OnEditFocusGained", function() AnimBorder(true) end)
    eb:SetScript("OnEditFocusLost", function() AnimBorder(false) end)
    eb:SetScript("OnCursorChanged", function(_, _, y, _, cursorH)
        local offset = -y
        local viewH = sf:GetHeight()
        local scroll = sf:GetVerticalScroll()
        if offset < scroll then
            sf:SetVerticalScroll(offset)
        elseif offset + cursorH > scroll + viewH then
            sf:SetVerticalScroll(offset + cursorH - viewH)
        end
    end)
    eb:SetScript("OnTextChanged", function(e, userInput)
        if onChange then onChange(e:GetText(), userInput) end
    end)

    function container:SetValue(val)
        eb:SetText(tostring(val or ""))
        eb:SetCursorPosition(0)
    end
    function container:GetValue() return eb:GetText() end
    function container:GetEditBox() return eb end

    function container:SetEnabled(enabled)
        eb:EnableMouse(enabled)
        eb:SetEnabled(enabled)
        self:SetAlpha(enabled and 1 or 0.4)
        if not enabled and eb:HasFocus() then eb:ClearFocus() end
    end

    return container
end
