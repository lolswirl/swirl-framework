local _, SF = ...
local C = SF.Components
local T, SetBackdrop = C.T, C.SetBackdrop

function C:ApplyScrollbar(scrollFrame, scrollChild, parent)
    local theme = T()
    local sbW   = theme.scrollbarWidth

    local track = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    track:SetWidth(sbW)
    track:SetPoint("TOPRIGHT",    parent, "TOPRIGHT",    0, 0)
    track:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    SetBackdrop(track, CreateColor(0.08, 0.08, 0.08, 0.6), theme.border.color)

    local thumb = CreateFrame("Frame", nil, track, "BackdropTemplate")
    thumb:SetWidth(sbW - 2)
    SetBackdrop(thumb, CreateColor(theme.accent.r, theme.accent.g, theme.accent.b, 0.75), CreateColor(0, 0, 0, 0))
    thumb:SetPoint("RIGHT", track, "RIGHT", -1, 0)

    local thumbTop = thumb:CreateTexture(nil, "OVERLAY")
    thumbTop:SetHeight(1)
    thumbTop:SetColorTexture(0, 0, 0, 1)
    thumbTop:SetPoint("TOPLEFT",  thumb, "TOPLEFT",  0, 0)
    thumbTop:SetPoint("TOPRIGHT", thumb, "TOPRIGHT", 0, 0)

    local thumbBot = thumb:CreateTexture(nil, "OVERLAY")
    thumbBot:SetHeight(1)
    thumbBot:SetColorTexture(0, 0, 0, 1)
    thumbBot:SetPoint("BOTTOMLEFT",  thumb, "BOTTOMLEFT",  0, 0)
    thumbBot:SetPoint("BOTTOMRIGHT", thumb, "BOTTOMRIGHT", 0, 0)

    track:Hide()

    local function UpdateThumb()
        local frameH = scrollFrame:GetHeight()
        local childH = scrollChild:GetHeight()
        if frameH == 0 or childH <= frameH + 0.5 then track:Hide(); return end
        track:Show()
        local trackH    = track:GetHeight()
        local ratio     = frameH / childH
        local thumbH    = math.max(20, trackH * ratio)
        thumb:SetHeight(thumbH)
        local scroll    = scrollFrame:GetVerticalScroll()
        local maxScroll = childH - frameH
        local offset    = (scroll / maxScroll) * (trackH - thumbH)
        thumb:ClearAllPoints()
        thumb:SetPoint("TOP",   track, "TOP",   0, -offset)
        thumb:SetPoint("RIGHT", track, "RIGHT", -1, 0)
    end

    scrollFrame:HookScript("OnScrollRangeChanged", UpdateThumb)
    scrollFrame:HookScript("OnVerticalScroll",     UpdateThumb)
    scrollChild:HookScript("OnSizeChanged",        UpdateThumb)

    thumb:EnableMouse(true)
    local dragging = false
    local hovered = false
    local dragStartY, dragStartScroll

    local IDLE_A, HOVER_A = 0.75, 1

    local thumbAG = thumb:CreateAnimationGroup()
    local thumbAnim = thumbAG:CreateAnimation("Animation")
    thumbAnim:SetDuration(0.18)
    local tFrom, tTo = {}, {}
    local tR, tG, tB, tA = theme.accent.r, theme.accent.g, theme.accent.b, IDLE_A

    thumbAG:SetScript("OnUpdate", function(ag)
        local p = ag:GetProgress() or 0
        tR = tFrom.r + (tTo.r - tFrom.r) * p
        tG = tFrom.g + (tTo.g - tFrom.g) * p
        tB = tFrom.b + (tTo.b - tFrom.b) * p
        tA = tFrom.a + (tTo.a - tFrom.a) * p
        thumb:SetBackdropColor(tR, tG, tB, tA)
    end)
    thumbAG:SetScript("OnFinished", function()
        thumb:SetBackdropColor(tTo.r, tTo.g, tTo.b, tTo.a)
        tR, tG, tB, tA = tTo.r, tTo.g, tTo.b, tTo.a
    end)

    local function AnimateThumb()
        thumbAG:Stop()
        tFrom.r, tFrom.g, tFrom.b, tFrom.a = tR, tG, tB, tA
        local ac = T().accent
        tTo.r, tTo.g, tTo.b = ac.r, ac.g, ac.b
        tTo.a = hovered and HOVER_A or IDLE_A
        thumbAG:Play()
    end

    thumb:SetScript("OnEnter", function() hovered = true;  AnimateThumb() end)
    thumb:SetScript("OnLeave", function() hovered = false; AnimateThumb() end)

    thumb:SetScript("OnMouseDown", function(_, btn)
        if btn ~= "LeftButton" then return end
        dragging        = true
        dragStartY      = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        dragStartScroll = scrollFrame:GetVerticalScroll()
    end)

    local updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function()
        if not dragging then return end
        local curY      = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        local delta     = dragStartY - curY
        local trackH    = track:GetHeight()
        local childH    = scrollChild:GetHeight()
        local frameH    = scrollFrame:GetHeight()
        local maxScroll = math.max(0, childH - frameH)
        local scrollDelta = delta * (maxScroll / (trackH - thumb:GetHeight()))
        scrollFrame:SetVerticalScroll(math.max(0, math.min(maxScroll, dragStartScroll + scrollDelta)))
        UpdateThumb()
    end)

    thumb:SetScript("OnMouseUp", function() dragging = false end)

    return track
end

function C:CreateTabScroller(tabFrame)
    local theme = T()
    local sbW   = theme.scrollbarWidth + 2

    local scrollFrame = CreateFrame("ScrollFrame", nil, tabFrame)
    scrollFrame:SetPoint("TOPLEFT",     tabFrame, "TOPLEFT",      1, -1)
    scrollFrame:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -1,  1)
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(sf, delta)
        local cur  = sf:GetVerticalScroll()
        local maxS = sf:GetVerticalScrollRange()
        sf:SetVerticalScroll(delta > 0 and math.max(cur - 40, 0) or math.min(cur + 40, maxS))
    end)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    local scrollbarVisible = false

    local function UpdateScrollChildWidth()
        local w = scrollFrame:GetWidth()
        if w > 0 then
            scrollChild:SetWidth(scrollbarVisible and (w - sbW) or w)
        end
    end

    local function UpdateScrollBarVisibility()
        local contentH = scrollChild:GetHeight()
        local frameH   = scrollFrame:GetHeight()
        scrollbarVisible = contentH > frameH + 0.5
        UpdateScrollChildWidth()
    end

    scrollFrame:HookScript("OnScrollRangeChanged", UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged",         UpdateScrollBarVisibility)
    scrollChild:HookScript("OnSizeChanged",         UpdateScrollBarVisibility)
    scrollFrame:HookScript("OnSizeChanged",          UpdateScrollChildWidth)

    local track = C:ApplyScrollbar(scrollFrame, scrollChild, tabFrame)

    track:HookScript("OnShow", function() scrollbarVisible = true;  UpdateScrollChildWidth() end)
    track:HookScript("OnHide", function() scrollbarVisible = false; UpdateScrollChildWidth() end)

    local _yOff = theme.padding.small
    local _cardCount = 0

    function scrollChild:PlaceCard(card, yOffset)
        card:SetPoint("TOPLEFT", self, "TOPLEFT", theme.padding.small, -yOffset)
        card:SetPoint("RIGHT", self, "RIGHT", -theme.padding.small, 0)
        return yOffset
    end

    function scrollChild:AddCard(card)
        local offset = _yOff
        if _cardCount > 0 then
            offset = _yOff + theme.padding.small
        end
        self:PlaceCard(card, offset)
        _yOff = offset + card:GetHeight()
        _cardCount = _cardCount + 1
        return card
    end

    function scrollChild:Commit(yOffset, onSized)
        local h = yOffset or _yOff
        local totalH = h + theme.padding.small
        C_Timer.After(0, function()
            self:SetHeight(totalH)
            if onSized then onSized(totalH) end
            C_Timer.After(0, function()
UpdateScrollBarVisibility()
            end)
        end)
    end

    scrollChild.scrollFrame = scrollFrame

    C_Timer.After(0, UpdateScrollChildWidth)

    return scrollChild
end
