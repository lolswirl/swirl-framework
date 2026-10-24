---@class SF
local SF = select(2, ...)

local T = {
    bg = {
        dark = CreateColorFromHexString("EB060808"),
        med = CreateColorFromHexString("991A1A19"),
        light = CreateColorFromHexString("EB080808"),
        hover = CreateColorFromHexString("CC2E2E2E"),
    },

    -- honestly i didn't feel like changing all refs for T.accent.dim etc
    accent = CreateColorFromHexString("FF7EE5FF"),
    accentDim = CreateColorFromHexString("FF4C8999"),
    accentFade = CreateColorFromHexString("337EE5FF"),

    border = {
        color = CreateColorFromHexString("FF000000"),
        size = 1,
    },

    text = {
        primary = CreateColorFromHexString("FFFFFFFF"),
        secondary = CreateColorFromHexString("FFCCCCCC"),
        muted = CreateColorFromHexString("FF8C8C8C"),
    },

    success = CreateColorFromHexString("FF49AF4C"),
    warning = CreateColorFromHexString("FFD8C45B"),
    error = CreateColorFromHexString("FFC63F3F"),
    orange = CreateColorFromHexString("FFFF6C31"),

    -- not sure where i'll use this, but matches waitimramping coloring
    rainbow = {
        CreateColorFromHexString("ff7ee5ff"),
        CreateColorFromHexString("ff89ff7f"),
        CreateColorFromHexString("ffffd700"),
        CreateColorFromHexString("ffff69b4"),
        CreateColorFromHexString("ffd0a3ff"),
    },

    font = {
        path = C_AddOns.DoesAddOnExist("SharedMedia_SwirlUI")
            and "Interface\\AddOns\\SharedMedia_SwirlUI\\font\\Swirl.ttf"
            or STANDARD_TEXT_FONT,
        size = {
            large = 18,
            normal = 12,
            small = 8,
        },
    },

    headerHeight = 36,
    footerHeight = 22,

    toggleWidth = 34,

    padding = {
        small = 6,
        med = 8,
        large = 12,
    },

    scrollbarWidth = 8,

    tabsWidth = 130,
    tabHeight = 28,
    tabSpacing = 2,
}

SF.Theme = T

function SF.InitTheme()
    local _, class = UnitClass("player")
    local cc = RAID_CLASS_COLORS[class]
    T.accent     = CreateColor(cc.r, cc.g, cc.b, 1)
    T.accentDim  = CreateColor(cc.r * 0.6, cc.g * 0.6, cc.b * 0.6, 1)
    T.accentFade = CreateColor(cc.r, cc.g, cc.b, 0.20)
end
