--@ enable = false
--@ module = true

Label = require('gui.widgets').Label
Panel = require('gui.widgets').Panel
OverlayWidget = require('plugins.overlay').OverlayWidget

local floor = math.floor
local ceil = math.ceil

local commands = {
    add = 'add',
    clear = 'clear',
}

zones = {
    { hotkey = 'm', title = "Meeting Area",    identifier = df.civzone_type.MeetingHall },
    { hotkey = 'b', title = "Bedroom",         identifier = df.civzone_type.Bedroom },
    { hotkey = 'h', title = "Dining Hall",     identifier = df.civzone_type.DiningHall },
    { hotkey = 'p', title = "Pen/Pasture",     identifier = df.civzone_type.Pen },
    { hotkey = 'P', title = "Pit/Pond",        identifier = df.civzone_type.Pond },
    { hotkey = 'r', title = "Water Source",    identifier = df.civzone_type.WaterSource },
    { hotkey = 'n', title = "Dungeon",         identifier = df.civzone_type.Dungeon },
    { hotkey = 'f', title = "Fishing",         identifier = df.civzone_type.FishingArea },
    { hotkey = 'N', title = "Sand",            identifier = df.civzone_type.SandCollection },

    { hotkey = 'o', title = "Office",          identifier = df.civzone_type.Office },
    { hotkey = 'y', title = "Dormitory",       identifier = df.civzone_type.Dormitory },
    { hotkey = 'B', title = "Barracks",        identifier = df.civzone_type.Barracks },
    { hotkey = 'Y', title = "Archery Range",   identifier = df.civzone_type.ArcheryRange },
    { hotkey = 'g', title = "Garbage Dump",    identifier = df.civzone_type.Dump },
    { hotkey = 'l', title = "Animal Training", identifier = df.civzone_type.AnimalTraining },
    { hotkey = 'T', title = "Tomb",            identifier = df.civzone_type.Tomb },
    { hotkey = 'F', title = "Gather Fruit",    identifier = df.civzone_type.PlantGathering },
    { hotkey = 'L', title = "Clay",            identifier = df.civzone_type.ClayCollection },
}
local no_hotkey_text = '*'

local vertical_offset = 24
local horizontal_offset = 7
local item_height = 3
local item_width = 19
local row_count = #zones / 2

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

local function characterToKeyName(character)
    if not character or type(character) ~= "string" then
        qerror(('Character expected, but %s was provided'):format(type(character)))
    end
    if not character:match('^%a$') then
        qerror(('An invalid character "%s" was provided'):format(character))
    end

    local key_end = string.upper(character)
    local use_shift = character == key_end

    return ('CUSTOM%s_%s'):format(use_shift and '_SHIFT' or '', key_end)
end

local function is_focus_zone()
    local current_focus = dfhack.gui.getCurFocus()
    if #current_focus ~= 1 then
        return false
    end
    return current_focus[1] == 'dwarfmode/Zone'
end

local function is_focus_building()
    local current_focus = dfhack.gui.getCurFocus()
    if #current_focus ~= 1 then
        return false
    end
    return current_focus[1] == 'dwarfmode/Building'
end

local function find_zone_by_title(zone_title)
    local current_zone
    for _, zone in ipairs(zones) do
        if zone.title == zone_title then
            current_zone = zone
            break
        end
    end
    return current_zone
end

local function on_zone_key(zone_identifier)
    local main_interface = df.global.game.main_interface

    if not is_focus_zone() then
        qerror('The script must be called in dwarfmode/Zone only')
    end

    main_interface.civzone.adding_new_type = zone_identifier
    main_interface.bottom_mode_selected = df.main_bottom_mode_type.ZONE_PAINT
end

local function get_last_construction_page()
    local page = df.global.game.main_interface.construction.page
    if not page or #page == 0 then
        return nil
    end
    -- `page` is a C++ array, so the indexing is zero-based,
    -- and the last element has index `#pages - 1`
    return page[#page - 1]
end

local function get_last_page_offset_left()
    local pages = df.global.game.main_interface.construction.page
    if not pages or #pages == 0 then
        return 0
    end

    -- Consider single-column vertical separators between each page
    local left_offset = #pages - 1

    if #pages == 1 then
        -- `pages` is a C++ array, so the indexing is zero-based
        return left_offset
    end

    -- Found experimentally. May be incorrect in Premium graphics mode.
    local icon_width = 5
    for i = 0, #pages - 2 do
        local page = pages[i]
        local status = df.construction_interface_page_status_type[page.page_status]
        if status == 'FULL' then
            left_offset = left_offset + page.number_of_columns * page.column_width
        elseif status == 'ICONS_ONLY' then
            left_offset = left_offset + page.number_of_columns * icon_width
        elseif status == 'OFF' then
        else
            qerror(('Unexpected status %s (%d)'):format(status, page.page_status))
        end
    end
    return left_offset
end

local function get_frame_size()
    local current_page = get_last_construction_page()
    if not current_page or not current_page.bb_button or #current_page.bb_button == 0 then
        return nil
    end

    -- `bb_button` is a C++ array, so the indexing is zero-based
    local grid_height = current_page.bb_button[0].grid_height

    local ey = current_page and current_page.last_main_ey or 0
    local ex = current_page and current_page.last_main_ex or 0

    local construction = df.global.game.main_interface.construction
    local rows = construction.max_height
    local full_l = ex - construction.total_width
    local height = (rows - 1) * grid_height + 1

    return {
        width = construction.total_width,
        height = height,
        left = ceil(full_l / 2) - 1,
        top = ey - height,
    }
end

local function get_page_size()
    local current_page = get_last_construction_page()
    if not current_page or not current_page.bb_button or #current_page.bb_button == 0 then
        return nil
    end

    -- `bb_button` is a C++ array, so the indexing is zero-based
    local grid_height = current_page.bb_button[0].grid_height
    return {
        cell_height = grid_height,
        cell_width = current_page.column_width,
        rows = current_page.column_height,
        columns = current_page.number_of_columns,
    }
end

local function is_page_visible(category)
    return function()
        local last_page = get_last_construction_page()
        return last_page and category == last_page.category
    end
end

local function get_cell_frame(i, rows, cell_height, cell_width)
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

function BindingLabel:is_enabled_callback()
    return function() return self.text ~= no_hotkey_text end
end

ZoneBindingsOverlay = defclass(ZoneBindingsOverlay, OverlayWidget)
ZoneBindingsOverlay.ATTRS {
    viewscreens = { 'dwarfmode/Zone' },
    default_pos = {
        x = horizontal_offset,
        y = vertical_offset,
    },
    frame = {
        w = item_width + 1,
        h = row_count * item_height,
    },
    default_enabled = true,
    desc = 'Display hotkeys for Zone choice menu',
}

function ZoneBindingsOverlay:init()
    local key_labels = {}
    for i, zone in ipairs(zones) do
        key_labels[i] = BindingLabel {
            view_id = zone.title,
            frame = {
                t = ((i - 1) % row_count) * item_height,
                l = (i <= row_count) and 0 or item_width,
            },
            text = zone.hotkey or no_hotkey_text,
        }
    end
    self:addviews{
        Panel {
            visible = is_focus_zone,
            subviews = key_labels,
        },
    }
end

function ZoneBindingsOverlay:change(zone, hotkey)
    zone.hotkey = hotkey
    self.subviews[zone.title]:setText(zone.hotkey or no_hotkey_text)
end

function ZoneBindingsOverlay:add(zone_title, hotkey)
    if type(zone_title) ~= "string" then
        qerror(('Zone title must be a string, but %s was provided'):format(type(zone_title)))
    end
    if type(hotkey) ~= "string" then
        qerror(('Hotkey must be a string, but %s was provided'):format(type(hotkey)))
    end
    if not hotkey:match("^%a$") then
        qerror(('Hotkey must be a single small or capital letter, but "%s" was provided'):format(hotkey))
    end

    local current_zone = find_zone_by_title(zone_title)
    if not current_zone then
        qerror(('Cannot find zone "%s"'):format(zone_title))
    end

    -- Use a separate loop for unbinding for the case the title is not found
    for _, zone in ipairs(zones) do
        if zone.hotkey == hotkey then
            self:change(zone, nil)
        end
    end

    self:change(current_zone, hotkey)
end

function ZoneBindingsOverlay:clear(zone_title, hotkey)
    if type(zone_title) ~= "string" then
        qerror(('Zone title must be a string, but %s was provided'):format(type(zone_title)))
    end

    local current_zone = find_zone_by_title(zone_title)
    if not current_zone then
        qerror(('Cannot find zone "%s"'):format(zone_title))
    end

    self:change(current_zone, nil)
end

function ZoneBindingsOverlay:overlay_trigger(...)
    local args = {...}
    if #args < 2 then
        qerror('At least two arguments are expected')
    end

    if args[1] == commands.add then
        local zone_title_words = {}
        for i = 2, #args - 1 do
            zone_title_words[i - 1] = args[i]
        end
        local zone_title = table.concat(zone_title_words, ' ')
        self:add(zone_title, args[#args])
    elseif args[1] == commands.clear then
        local zone_title_words = {}
        for i = 2, #args do
            zone_title_words[i - 1] = args[i]
        end
        local zone_title = table.concat(zone_title_words, ' ')
        self:clear(zone_title)
    end
end

function ZoneBindingsOverlay:onInput(keys)
    if not keys then
        return
    end

    for _, zone in ipairs(zones) do
        if zone.hotkey and keys[characterToKeyName(zone.hotkey)] then
            on_zone_key(zone.identifier)
            return true
        end
    end
end

BuildingBindingsOverlay = defclass(BuildingBindingsOverlay, OverlayWidget)
BuildingBindingsOverlay.ATTRS {
    viewscreens = { 'dwarfmode/Building' },
    overlay_onupdate_max_freq_seconds = 0.1,
    default_enabled = true,
    desc = 'Display hotkeys for Building choice menu',
}

function BuildingBindingsOverlay:init()
    local construction_types = df.construction_category_type
    local panels = {}
    for i, type in ipairs(construction_types) do
        panels[i + 1] = Panel {
            view_id = type,
            frame = {
                w = 0,
                h = 0,
                t = 0,
                l = 0,
            },
            visible = is_page_visible(i),
        }
    end

    self:addviews{
        Panel {
            view_id = 'building_bindings_panel',
            visible = is_focus_building,
            subviews = panels,
        },
    }

    self:populate_current_page()
end

function BuildingBindingsOverlay:overlay_onupdate(viewscreen)
     self:populate_current_page()
end

function BuildingBindingsOverlay:preUpdateLayout(parent_rect)
    self:resize()
end

function BuildingBindingsOverlay:resize()
    local page = get_page_size()
    if not page then
        return
    end

    self:update_frame_size()
    local panel = self:get_current_panel()

    -- The panel should not be displayed or was not loaded yet
    if not panel or #panel.subviews == 0 then
        return
    end

    local panel_width = (page.columns - 1) * page.cell_width + 1
    local panel_height = page.rows * page.cell_height
    panel.frame.l = get_last_page_offset_left() --or (self.frame.w - panel_width)
    -- The size is the same, no changes needed
    if panel.frame.w == panel_width and panel.frame.h == panel_height then
        return
    end

    panel.frame.w = panel_width
    panel.frame.h = panel_height

    for i, subview in ipairs(panel.subviews) do
        subview.frame = get_cell_frame(i - 1, page.rows, page.cell_height, page.cell_width)
    end
end

function BuildingBindingsOverlay:populate_current_page()
    local page = get_page_size()
    local last_page = get_last_construction_page()
    if not page or not last_page then
        return
    end

    self:update_frame_size()
    local panel = self:get_current_panel()

    -- The panel should not be displayed or is already populated
    if not panel or #panel.subviews == #last_page.bb_button then
        return
    end

    panel.frame.w = (page.columns - 1) * page.cell_width + 1
    panel.frame.h = page.rows * page.cell_height
    panel.frame.l = get_last_page_offset_left() -- or (self.frame.w - panel.frame.w)

    local items = {}
    for i, button in ipairs(last_page.bb_button) do
        -- bb_button is a C++ array, so the indexing is zero-based
        items[i + 1] = BindingLabel {
            view_id = ('%s.%s'):format(category_name, button.str),
            frame = get_cell_frame(i, page.rows, page.cell_height, page.cell_width),
            text = dfhack.screen.getKeyDisplay(button.hotkey),
        }
    end
    panel:addviews(items)
end

function BuildingBindingsOverlay:get_current_panel()
    local last_page = get_last_construction_page()
    if not last_page then
        return
    end

    local category_name = df.construction_category_type[last_page.category]
    local panel = self.subviews[category_name]
    if not panel then
        qerror(('Cannot find panel %s (%d)'):format(category_name, last_page.category))
    end

    return panel
end

function BuildingBindingsOverlay:update_frame_size()
    local frame = get_frame_size()
    if not frame then
        return
    end

    self.frame.t = frame.top
    self.frame.h = frame.height
    self.frame.l = frame.left
    self.frame.w = frame.width
end

OVERLAY_WIDGETS = {
    ['zone-overlay'] = ZoneBindingsOverlay,
    ['building-overlay'] = BuildingBindingsOverlay,
}
