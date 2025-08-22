--@ module = true

local Label = require('gui.widgets').Label

local floor = math.floor

local hotkey_pen = {
    fg = COLOR_GREEN,
    bg = COLOR_BLACK,
    bold = true,
}
local hotkey_pen_hover = {
    fg = COLOR_WHITE,
    bg = COLOR_BLACK,
    bold = true,
}
local empty_hotkey_pen = {
    fg = COLOR_GRAY,
    bg = COLOR_BLACK,
    bold = false,
}

function get_cell_frame(i, rows, cell_height, cell_width)
    return {
        t = (i % rows) * cell_height,
        l = floor(i / rows) * cell_width,
    }
end

BindingLabel = defclass(BindingLabel, Label)
BindingLabel.ATTRS {
    auto_width = true,
    auto_height = true,
    text_pen = hotkey_pen,
    text_hpen = hotkey_pen_hover,
    text_dpen = empty_hotkey_pen,
}

function BindingLabel:init(args)
    BindingLabel.super.init(self, args)
    if self.disabled == nil and self.enabled == nil then
        self.enabled = function() return self.text ~= no_hotkey_text end
    end
end

function BindingLabel:shouldHover()
    return true
end
