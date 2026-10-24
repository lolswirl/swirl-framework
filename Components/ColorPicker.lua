---@class SF
local SF = select(2, ...)
local C = SF.Components
local T, SetBackdrop = C.T, C.SetBackdrop

function C:CreateColorPicker(parent, labelText, initialColor, onChange)
    local theme = T()

    local color = initialColor or CreateColor(1, 1, 1, 1)

    local row = CreateFrame("Frame", nil, parent)
    row:SetHeight(36)

    local lbl = C.CreateLabel(row, labelText)

    local swatch = CreateFrame("Button", nil, row, "BackdropTemplate")
    swatch:SetSize(theme.toggleWidth, 24)
    swatch:SetPoint("TOPLEFT", row, "TOPLEFT", 0, -14)
    SetBackdrop(swatch, color, theme.border.color)
    local AnimSwatchBorder = C.MakeBorderAnimator(swatch)
    swatch:SetScript("OnEnter", function() AnimSwatchBorder(true)  end)
    swatch:SetScript("OnLeave", function() AnimSwatchBorder(false) end)

    local swatchTex = swatch:CreateTexture(nil, "ARTWORK")
    swatchTex:SetPoint("TOPLEFT",     swatch, "TOPLEFT",     1, -1)
    swatchTex:SetPoint("BOTTOMRIGHT", swatch, "BOTTOMRIGHT", -1, 1)
    swatchTex:SetColorTexture(color.r, color.g, color.b, 1)

    local hexEntry

    local function ApplyColor(c)
        color = c
        swatchTex:SetColorTexture(color.r, color.g, color.b, 1)
        hexEntry:SetValue(color:GenerateHexColorNoAlpha())
        if onChange then onChange(color) end
    end

    hexEntry = C:CreateEntryBox(row, color:GenerateHexColorNoAlpha(), function(val)
        val = val:gsub("^#", "")
        local c = #val == 6 and CreateColorFromHexString("FF" .. val)
        if c then
            ApplyColor(c)
        else
            hexEntry:SetValue(color:GenerateHexColorNoAlpha())
        end
    end)
    hexEntry:SetHeight(24)
    hexEntry:SetPoint("LEFT", swatch, "RIGHT", 4, 0)
    hexEntry:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    hexEntry:SetPoint("TOP", swatch, "TOP", 0, 0)

    swatch:SetScript("OnClick", function()
        local function OnChange()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = 1 - ColorPickerFrame:GetColorAlpha()
            ApplyColor(CreateColor(r, g, b, a))
        end

        local function OnCancel(prev)
            ApplyColor(CreateColor(prev.r, prev.g, prev.b, prev.a))
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow({
                r = color.r, g = color.g, b = color.b, opacity = 1 - color.a,
                hasOpacity = true,
                previousValues = { r = color.r, g = color.g, b = color.b, a = color.a },
                swatchFunc  = OnChange,
                opacityFunc = OnChange,
                cancelFunc  = OnCancel,
            })
        else
            ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
            ColorPickerFrame.hasOpacity     = true
            ColorPickerFrame.opacity        = 1 - color.a
            ColorPickerFrame.previousValues = { r = color.r, g = color.g, b = color.b, a = color.a }
            ColorPickerFrame.func           = OnChange
            ColorPickerFrame.opacityFunc    = OnChange
            ColorPickerFrame.cancelFunc     = OnCancel
            ColorPickerFrame:Hide()
            ColorPickerFrame:Show()
        end
    end)

    function row:SetColor(c) ApplyColor(c) end
    function row:GetColor() return color end

    function row:SetEnabled(enabled)
        swatch:EnableMouse(enabled)
        swatch:SetAlpha(enabled and 1 or 0.4)
        hexEntry:SetEnabled(enabled)
        lbl:SetAlpha(enabled and 1 or 0.4)
    end

    return row
end
