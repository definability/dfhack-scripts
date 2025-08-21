--@ module = true

local Panel = require('gui.widgets').Panel
local OverlayWidget = require('plugins.overlay').OverlayWidget
local helpers = reqscript('internal/visible-hotkeys/helpers')

local BindingLabel = helpers.BindingLabel
local get_cell_frame = helpers.get_cell_frame

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
            frame = get_cell_frame(i - 1, row_count, item_height, item_width),
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

function ZoneBindingsOverlay:clear(zone_title)
    if type(zone_title) ~= "string" then
        qerror(('Zone title must be a string, but %s was provided'):format(type(zone_title)))
    end

    local current_zone = find_zone_by_title(zone_title)
    if not current_zone then
        qerror(('Cannot find zone "%s"'):format(zone_title))
    end

    self:change(current_zone, nil)
end

function ZoneBindingsOverlay:change(zone, hotkey)
    zone.hotkey = hotkey
    self.subviews[zone.title]:setText(zone.hotkey or no_hotkey_text)
end
