---@class SF
local SF = select(2, ...)
local C = SF.Components

function C:CreateEditBox(parent, labelText, initialValue, onChange)

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(36)

    local lbl = C.CreateLabel(row, labelText)

    local entry = C:CreateEntryBox(row, initialValue, onChange)
    entry:SetHeight(24)
    entry:SetPoint("TOPLEFT",  row, "TOPLEFT",  0, -14)
    entry:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, -14)

    function row:SetValue(val) entry:SetValue(val) end
    function row:GetValue()    return entry:GetValue() end

    function row:SetEnabled(enabled)
        entry:SetEnabled(enabled)
        lbl:SetAlpha(enabled and 1 or 0.4)
    end

    return row
end
