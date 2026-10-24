---@class SF
local SF = select(2, ...)
local C = SF.Components

SF.UI = SF.UI or {}
local UI = SF.UI

local function T() return SF.Theme end

local windows = {}

local function BuildWindow(frameType, opts)
    local theme = T()
    local globalName = "SF_" .. frameType

    local win = CreateFrame("Frame", globalName, UIParent, "BackdropTemplate")
    win:SetSize(opts.width, opts.height == "auto" and 100 or opts.height)
    win:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    win:SetFrameStrata(opts.strata or "HIGH")
    win:SetToplevel(true)
    win:SetClampedToScreen(true)
    win:SetMovable(true)
    win:EnableMouse(true)
    C.SetBackdrop(win, theme.bg.dark, theme.border.color)

    local header = CreateFrame("Frame", nil, win, "BackdropTemplate")
    header:SetHeight(theme.headerHeight)
    header:SetPoint("TOPLEFT", win, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", win, "TOPRIGHT", 0, 0)
    C.SetBackdrop(header, theme.bg.med, theme.border.color)
    win.header = header

    local hdrLine = win:CreateTexture(nil, "ARTWORK")
    hdrLine:SetHeight(1)
    hdrLine:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    hdrLine:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    hdrLine:SetColorTexture(1, 1, 1, 0.12)

    local icon = header:CreateTexture(nil, "OVERLAY")
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", header, "LEFT", theme.padding.med, 0)
    icon:SetTexture(opts.icon or "")

    local titleFS = header:CreateFontString(nil, "OVERLAY")
    C.ApplyFont(titleFS, "large")
    titleFS:SetText(opts.title or SF.addonName or "")
    titleFS:SetTextColor(theme.accent.r, theme.accent.g, theme.accent.b, 1)
    titleFS:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    win.titleFS = titleFS

    local pageFS = header:CreateFontString(nil, "OVERLAY")
    C.ApplyFont(pageFS, "normal")
    pageFS:SetPoint("CENTER", header, "CENTER", 0, 0)
    pageFS:SetJustifyH("CENTER")
    pageFS:SetWordWrap(false)
    local sec = theme.text.secondary
    pageFS:SetTextColor(sec.r, sec.g, sec.b, 1)
    win.pageFS = pageFS

    local closeBtn = C:CreateCloseButton(header, function() win:Hide() end)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)

    if opts.onGear then
        local gearBtn = C:CreateIconButton(header, {
            atlas = "OptionsIcon-Brown",
            size = 16,
            onClick = function()
                if win.onGear then win.onGear() end
            end,
        })
        gearBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)
    end

    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() win:StartMoving() end)
    header:SetScript("OnDragStop", function() win:StopMovingOrSizing() end)

    win:SetScript("OnHide", function()
        if SF.frame == win then
            SF.frame = nil
        end
        if win.onHide then win.onHide() end
    end)

    table.insert(UISpecialFrames, globalName)

    return win
end

function UI.AcquireWindow(frameType, opts)
    if SF.frame and SF.frame ~= windows[frameType] then
        SF.frame:Hide()
    end

    local win = windows[frameType]
    if not win then
        win = BuildWindow(frameType, opts)
        windows[frameType] = win
    end

    local autoHeight = opts.height == "auto"
    if not autoHeight then
        win:SetSize(opts.width, opts.height)
    else
        win:SetWidth(opts.width)
    end
    win.onHide = opts.onHide
    win.onGear = opts.onGear
    win.pageFS:SetText(opts.pageTitle or "")
    win.titleFS:SetText(opts.title or SF.addonName or "")

    win.FitToContent = autoHeight and function(contentH)
        local theme = T()
        -- header + 1px header line + scrollframe insets (1px top + 1px bottom) + content + 1px bottom margin
        win:SetHeight(theme.headerHeight + 1 + 2 + contentH + 1)
    end or nil

    if win.content then
        win.content:Hide()
        win.content:SetParent(nil)
    end
    local content = CreateFrame("Frame", nil, win)
    content:SetPoint("TOPLEFT", win.header, "BOTTOMLEFT", 0, -1)
    content:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", 0, 0)
    win.content = content

    SF.frame = win
    SF.frameType = frameType
    win:Show()
    win:Raise()

    return win, content
end

function UI.HideAll()
    local closedAny = false
    for _, win in pairs(windows) do
        if win:IsShown() then
            win:Hide()
            closedAny = true
        end
    end
    return closedAny
end
