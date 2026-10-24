---@class SF
local SF = select(2, ...)
local C = SF.Components
local T = C.T

function C:CreateIconButton(parent, opts)
    opts = opts or {}
    local theme = T()
    local sz = opts.size or 24

    local normalColor = opts.normalColor or { r = 0.5, g = 0.5, b = 0.5, a = 1 }
    local hoverColor = opts.hoverColor or { r = 1, g = 1, b = 1, a = 1 }

    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(sz, sz)

    if opts.texture or opts.atlas then
        local tex = btn:CreateTexture(nil, "OVERLAY")
        if opts.atlas then
            tex:SetAtlas(opts.atlas)
        else
            tex:SetTexture(opts.texture)
        end
        tex:SetVertexColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
        tex:SetAllPoints()
        btn._iconTex = tex
        btn:SetScript("OnEnter", function()
            tex:SetVertexColor(hoverColor.r, hoverColor.g, hoverColor.b, hoverColor.a)
        end)
        btn:SetScript("OnLeave", function()
            tex:SetVertexColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
        end)
    else
        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER")
        lbl:SetJustifyV("MIDDLE")
        local fs = opts.fontSize or (theme.font.size.large + 6)
        lbl:SetFont(theme.font.path, fs, "OUTLINE")
        lbl:SetShadowColor(0, 0, 0, 0)
        lbl:SetText(opts.text or "")
        lbl:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
        btn._iconLbl = lbl
        btn:SetScript("OnEnter", function()
            lbl:SetTextColor(hoverColor.r, hoverColor.g, hoverColor.b, hoverColor.a)
        end)
        btn:SetScript("OnLeave", function()
            lbl:SetTextColor(normalColor.r, normalColor.g, normalColor.b, normalColor.a)
        end)
    end

    if opts.onClick then
        btn:SetScript("OnClick", opts.onClick)
    end

    return btn
end

function C:CreateCloseButton(parent, onClick, opts)
    local theme = T()
    opts = opts or {}
    return C:CreateIconButton(parent, {
        text = "×",
        size = opts.size or 26,
        normalColor = opts.normalColor or { r = 0.5, g = 0.5, b = 0.5, a = 1 },
        hoverColor = opts.hoverColor or theme.error,
        onClick = onClick,
    })
end
