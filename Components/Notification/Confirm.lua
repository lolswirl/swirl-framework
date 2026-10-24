---@class SF
local SF = select(2, ...)
local C = SF.Components
local N = C.Notification

local CONFIRM_W = 220
local CONFIRM_H = 72
local BTN_W = 70
local BTN_H = 20

local confirm = nil
local dimOverlay = nil

local function GetDimOverlay()
    if not dimOverlay then
        dimOverlay = CreateFrame("Frame", nil, UIParent)
        dimOverlay:SetFrameStrata("DIALOG")
        dimOverlay:SetFrameLevel(1)
        dimOverlay:EnableMouse(true)
        local bg = dimOverlay:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.6)
        dimOverlay:Hide()
    end
    return dimOverlay
end

local function BuildConfirm()
    confirm = N.BuildPanel("SF_ConfirmPopup", CONFIRM_W, CONFIRM_H, "DIALOG")

    local msg = confirm:CreateFontString(nil, "OVERLAY")
    msg:SetPoint("TOPLEFT", confirm, "TOPLEFT", 14, -12)
    msg:SetPoint("TOPRIGHT", confirm, "TOPRIGHT", -10, -12)
    msg:SetJustifyH("LEFT")
    C.ApplyFont(msg, "small")
    confirm.msg = msg

    local okBtn = CreateFrame("Button", nil, confirm, "BackdropTemplate")
    local cancelBtn = CreateFrame("Button", nil, confirm, "BackdropTemplate")
    okBtn:SetSize(BTN_W, BTN_H)
    cancelBtn:SetSize(BTN_W, BTN_H)
    okBtn:SetPoint("BOTTOMRIGHT", confirm, "BOTTOM", -4, 10)
    cancelBtn:SetPoint("BOTTOMLEFT", confirm, "BOTTOM", 4, 10)

    local okLabel = okBtn:CreateFontString(nil, "OVERLAY")
    local cancelLabel = cancelBtn:CreateFontString(nil, "OVERLAY")
    okLabel:SetPoint("CENTER", okBtn, "CENTER")
    cancelLabel:SetPoint("CENTER", cancelBtn, "CENTER")
    C.ApplyFont(okLabel, "small")
    C.ApplyFont(cancelLabel, "small")
    okLabel:SetText("Confirm")
    cancelLabel:SetText("Cancel")
    confirm.okBtn = okBtn
    confirm.cancelBtn = cancelBtn
    confirm.okLabel = okLabel
    confirm.cancelLabel = cancelLabel

    okBtn:SetScript("OnEnter", function()
        local s = C.T().success
        okBtn:SetBackdropBorderColor(s.r, s.g, s.b, 1)
    end)
    okBtn:SetScript("OnLeave", function() okBtn:SetBackdropBorderColor(0, 0, 0, 1) end)
    cancelBtn:SetScript("OnEnter", function()
        local e = C.T().error
        cancelBtn:SetBackdropBorderColor(e.r, e.g, e.b, 1)
    end)
    cancelBtn:SetScript("OnLeave", function() cancelBtn:SetBackdropBorderColor(0, 0, 0, 1) end)
end

function C.ShowConfirm(text, onConfirm, onCancel, width, parent)
    if not confirm then BuildConfirm() end

    local theme = C.T()
    C.SetBackdrop(confirm, theme.bg.dark, theme.border.color)
    C.SetBackdrop(confirm.okBtn, theme.bg.med, theme.border.color)
    C.SetBackdrop(confirm.cancelBtn, theme.bg.med, theme.border.color)
    N.ApplyAccent(confirm)
    local s = theme.success
    confirm.okLabel:SetTextColor(s.r, s.g, s.b, 1)
    local e = theme.error
    confirm.cancelLabel:SetTextColor(e.r, e.g, e.b, 1)
    confirm:SetWidth(width or CONFIRM_W)
    confirm.msg:SetText(text)
    confirm:SetHeight(math.max(CONFIRM_H, confirm.msg:GetStringHeight() + 12 + BTN_H + 22))

    if onCancel == false then
        confirm.cancelBtn:Hide()
        confirm.okBtn:SetPoint("BOTTOMRIGHT", confirm, "BOTTOM", BTN_W / 2 + 4, 10)
    else
        confirm.cancelBtn:Show()
        confirm.okBtn:SetPoint("BOTTOMRIGHT", confirm, "BOTTOM", -4, 10)
    end

    if parent then
        local dim = GetDimOverlay()
        dim:SetAllPoints(parent)
        dim:SetParent(parent)
        dim:SetFrameLevel(parent:GetFrameLevel() + 10)
        dim:Show()
        confirm:SetParent(parent)
        confirm:SetFrameStrata(parent:GetFrameStrata())
        confirm:SetFrameLevel(parent:GetFrameLevel() + 20)
        confirm:ClearAllPoints()
        confirm:SetPoint("CENTER", parent, "CENTER", 0, 0)
    else
        confirm:SetParent(UIParent)
        confirm:SetFrameStrata("DIALOG")
        confirm:ClearAllPoints()
        confirm:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end

    local function dismiss(cb)
        if parent then GetDimOverlay():Hide() end
        if cb then cb() end
        N.FadeOut(confirm, nil)
    end

    confirm.okBtn:SetScript("OnClick", function()
        dismiss(onConfirm)
    end)
    confirm.cancelBtn:SetScript("OnClick", function()
        dismiss(onCancel)
    end)

    N.FadeIn(confirm)
end
