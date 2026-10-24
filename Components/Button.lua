---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, ApplyFont, SetBackdrop = C.T, C.ApplyFont, C.SetBackdrop

function C:CreateButton(parent, labelText, config)
    config = config or {}
    local theme = T()
    local width = config.width or 120
    local height = config.height or 24
    local callback = config.callback or function() end
    local tooltip = config.tooltip
    local font = config.font or "normal"

    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    SetBackdrop(btn, theme.bg.med, theme.border.color)

    local AnimBorder = C.MakeBorderAnimator(btn)

    local label = btn:CreateFontString(nil, "OVERLAY")
    ApplyFont(label, font)
    label:SetText(labelText or "")
    label:SetTextColor(theme.accent.r, theme.accent.g, theme.accent.b, 1)
    label:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btn.label = label

    btn:SetScript("OnEnter", function()
        AnimBorder(true)
        if tooltip then
            GameTooltip:SetOwner(btn, "ANCHOR_TOP")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        AnimBorder(false)
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", callback)

    function btn:SetLabel(text)  label:SetText(text) end
    function btn:SetCallback(fn) btn:SetScript("OnClick", fn) end
    function btn:SetEnabled(enabled)
        if enabled then btn:Enable(); btn:SetAlpha(1)
        else btn:Disable(); btn:SetAlpha(0.4) end
    end

    return btn
end
