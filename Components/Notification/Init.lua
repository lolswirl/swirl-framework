---@class SF
local SF = select(2, ...)
local C = SF.Components

local FADE_TIME = 0.3
C.Notification = {}
local N = C.Notification

N.FADE_TIME = FADE_TIME

function N.BuildPanel(name, w, h, strata)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(w, h)
    f:SetPoint("TOP", UIParent, "TOP", 0, -175)
    f:SetFrameStrata(strata)
    f:SetAlpha(0)
    f:Hide()

    local bar = f:CreateTexture(nil, "OVERLAY")
    bar:SetWidth(3)
    bar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    bar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    f.accent = bar

    local ag = f:CreateAnimationGroup()
    local anim = ag:CreateAnimation("Alpha")
    anim:SetDuration(FADE_TIME)
    anim:SetSmoothing("IN_OUT")
    f.fadeAG = ag
    f.fadeAnim = anim

    return f
end

function N.FadeIn(f)
    f.fadeAG:Stop()
    f.fadeAnim:SetFromAlpha(0); f.fadeAnim:SetToAlpha(1)
    f.fadeAG:SetScript("OnFinished", function()
        f:SetAlpha(1)
        f.fadeAG:SetScript("OnFinished", nil)
    end)
    f:SetAlpha(0)
    f:Show()
    f.fadeAG:Play()
end

function N.FadeOut(f, cb)
    f.fadeAG:Stop()
    f.fadeAnim:SetFromAlpha(1); f.fadeAnim:SetToAlpha(0)
    f.fadeAG:SetScript("OnFinished", function()
        f:Hide()
        f:SetAlpha(0)
        f.fadeAG:SetScript("OnFinished", nil)
        if cb then cb() end
    end)
    f.fadeAG:Play()
end

function N.ApplyAccent(f)
    local ac = C.T().accent
    f.accent:SetColorTexture(ac.r, ac.g, ac.b, 1)
end