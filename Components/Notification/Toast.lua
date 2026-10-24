---@class SF
local SF = select(2, ...)
local C = SF.Components
local N = C.Notification

local POPUP_W = 260
local POPUP_H = 52

local queue = {}
local active = false
local popup = nil

local function ShowNext()
    if active or #queue == 0 then return end
    if not popup then
        popup = N.BuildPanel("SF_NotificationPopup", POPUP_W, POPUP_H, "TOOLTIP")
        local msg = popup:CreateFontString(nil, "OVERLAY")
        msg:SetPoint("LEFT", popup, "LEFT", 14, 0)
        msg:SetPoint("RIGHT", popup, "RIGHT", -10, 0)
        msg:SetJustifyH("LEFT")
        msg:SetJustifyV("MIDDLE")
        C.ApplyFont(msg, "small")
        popup.msg = msg
    end
    active = true

    local item = table.remove(queue, 1)
    local dur = item.duration or 2
    local theme = C.T()

    C.SetBackdrop(popup, theme.bg.dark, theme.border.color)
    N.ApplyAccent(popup)
    popup.msg:SetText(item.text)
    popup:ClearAllPoints()
    popup:SetPoint("TOP", UIParent, "TOP", 0, -175)

    N.FadeIn(popup)
    C_Timer.After(N.FADE_TIME + dur, function()
        N.FadeOut(popup, function()
            active = false
            ShowNext()
        end)
    end)
end

function C.ShowToast(text, duration)
    table.insert(queue, { text = text, duration = duration })
    ShowNext()
end
