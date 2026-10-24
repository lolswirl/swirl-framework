---@class SF
local SF = select(2, ...)
local C = SF.Components

function C:CreateXYPosition(parent, getX, setX, getY, setY)
    local GAP = 8

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(36)

    local xSlider = C:CreateSlider(row, "X", -2000, 2000, 1, getX, setX, { width = 0 })
    xSlider:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0)
    xSlider:SetPoint("TOPRIGHT", row, "TOP", -GAP / 2, 0)

    local ySlider = C:CreateSlider(row, "Y", -2000, 2000, 1, getY, setY, { width = 0 })
    ySlider:SetPoint("TOPLEFT", row, "TOP", GAP / 2, 0)
    ySlider:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)

    function row:Refresh()
        xSlider:SetVal(getX())
        ySlider:SetVal(getY())
    end

    function row:SetEnabled(enabled)
        xSlider:SetEnabled(enabled)
        ySlider:SetEnabled(enabled)
    end

    return row
end
