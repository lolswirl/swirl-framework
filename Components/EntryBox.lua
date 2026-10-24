---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

local _focused = nil
WorldFrame:HookScript("OnMouseDown", function()
    if _focused and _focused:HasFocus() and not _focused:IsMouseOver() then
        _focused:ClearFocus()
    end
end)

function C:CreateEntryBox(parent, initialValue, onChange)
    local theme = T()

    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    SetBackdrop(container, theme.bg.med, theme.border.color)

    local AnimBorder = C.MakeBorderAnimator(container)

    local eb = CreateFrame("EditBox", nil, container)
    eb:SetPoint("TOPLEFT",     container, "TOPLEFT",      4, -2)
    eb:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -4,  2)
    ApplyFont(eb, "small")
    local ac = theme.accent
    eb:SetTextColor(ac.r, ac.g, ac.b, 1)
    eb:SetJustifyH("LEFT")
    eb:SetAutoFocus(false)
    eb:SetText(tostring(initialValue or ""))

    local function Commit()
        if onChange then onChange(eb:GetText()) end
    end

    eb:SetScript("OnEnterPressed",  function(e) e:ClearFocus(); Commit() end)
    eb:SetScript("OnEscapePressed", function(e) e:ClearFocus() end)
    eb:SetScript("OnEditFocusLost", Commit)
    eb:SetScript("OnEditFocusGained", function(e)
        _focused = e
        AnimBorder(true)
        e:HighlightText()
    end)
    eb:SetScript("OnEnter", function(e) if not e:HasFocus() then AnimBorder(true)  end end)
    eb:SetScript("OnLeave", function(e) if not e:HasFocus() then AnimBorder(false) end end)

    function container:SetValue(val)
        eb:SetText(tostring(val or ""))
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
