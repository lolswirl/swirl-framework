---@class SF
local SF = select(2, ...)

local C = SF.Components

function C.T() return SF.Theme end

function C.ApplyFont(fs, size)
    local font = C.T().font
    -- this is so silly but i am lazy
    local sz = type(size) == "number" and size
           or size == "xsmall" and font.size.small
           or size == "small" and font.size.normal
           or size == "large" and (font.size.normal + 2)
           or font.size.normal

    fs:SetFont(font.path, sz, "OUTLINE")
    fs:SetShadowOffset(0, 0)
    fs:SetShadowColor(0, 0, 0, 0)
end

function C.CreateLabel(parent, text)
    local theme = C.T()
    local lbl = parent:CreateFontString(nil, "OVERLAY")
    lbl:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 1)
    lbl:SetJustifyH("LEFT")
    C.ApplyFont(lbl, "small")
    lbl:SetText(text or "")
    local tc = theme.text.secondary
    lbl:SetTextColor(tc.r, tc.g, tc.b, 1)
    return lbl
end

function C.SetBackdrop(frame, bg, border)
    local theme = C.T()
    frame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = theme.border.size,
    })
    if bg then frame:SetBackdropColor(bg.r, bg.g, bg.b, bg.a) end
    if border then frame:SetBackdropBorderColor(border.r, border.g, border.b, border.a) end
end

-- Creates a border color animator on frame. Returns AnimBorder(toAccent).
function C.MakeBorderAnimator(frame, duration)
    local theme = C.T()
    local ag = frame:CreateAnimationGroup()
    local anim = ag:CreateAnimation("Animation")
    anim:SetDuration(duration or 0.15)

    local from = {}
    local to = {}
    local cr, cg, cb = theme.border.color.r, theme.border.color.g, theme.border.color.b

    ag:SetScript("OnUpdate", function(a)
        local p = a:GetProgress() or 0
        local r = from.r + (to.r - from.r) * p
        local g = from.g + (to.g - from.g) * p
        local b = from.b + (to.b - from.b) * p
        frame:SetBackdropBorderColor(r, g, b, 1)
        cr, cg, cb = r, g, b
    end)
    ag:SetScript("OnFinished", function()
        frame:SetBackdropBorderColor(to.r, to.g, to.b, 1)
        cr, cg, cb = to.r, to.g, to.b
    end)

    return function(toAccent)
        ag:Stop()
        from.r, from.g, from.b = cr, cg, cb
        local c = toAccent and C.T().accent or C.T().border.color
        to.r, to.g, to.b = c.r, c.g, c.b
        ag:Play()
    end
end
