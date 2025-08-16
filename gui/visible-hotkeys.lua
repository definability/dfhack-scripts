--@ enable = true
--@ module = true

Label = require('gui.widgets.labels.label')
OverlayWidget = require('plugins.overlay').OverlayWidget

local zones = {
    { hotkey = 'm', title = "Meeting Area", identifier = df.civzone_type.MeetingHall },
    { hotkey = 'b', title = "Bedroom", identifier = df.civzone_type.Bedroom },
    { hotkey = 'h', title = "Dining hall", identifier = df.civzone_type.DiningHall },
    { hotkey = 'p', title = "Pen/Pasture", identifier = df.civzone_type.Pen },
    { hotkey = 'P', title = "Pit/Pond", identifier = df.civzone_type.Pond },
    { hotkey = 'r', title = "Water Source", identifier = df.civzone_type.WaterSource },
    { hotkey = 'n', title = "Dungeon", identifier = df.civzone_type.Dungeon },
    { hotkey = 'f', title = "Fishing", identifier = df.civzone_type.FishingArea },
    { hotkey = 'N', title = "Sand", identifier = df.civzone_type.SandCollection },

    { hotkey = 'o', title = "Office", identifier = df.civzone_type.Office },
    { hotkey = 'y', title = "Dormitory", identifier = df.civzone_type.Dormitory },
    { hotkey = 'B', title = "Barracks", identifier = df.civzone_type.Barracks },
    { hotkey = 'Y', title = "Archery Range", identifier = df.civzone_type.ArcheryRange },
    { hotkey = 'g', title = "Garbage Dump", identifier = df.civzone_type.Dump },
    { hotkey = 'l', title = "Animal Training", identifier = df.civzone_type.AnimalTraining },
    { hotkey = 'T', title = "Tomb", identifier = df.civzone_type.Tomb },
    { hotkey = 'F', title = "Gather Fruit", identifier = df.civzone_type.PlantGathering },
    { hotkey = 'L', title = "Clay", identifier = df.civzone_type.ClayCollection },
}

local vertical_offset = 24
local horizontal_offset = 7
local item_height = 3
local item_width = 19
local row_count = #zones / 2

local function hotkey_character_to_binding(hotkey)
    if not hotkey then
        qerror("An invalid hotkey was provided")
    end

    local hotkey_end = string.upper(hotkey)
    local use_shift = hotkey == hotkey_end
    if use_shift then
        return ('Shift-%s@dwarfmode/Zone'):format(hotkey_end)
    else
        return ('%s@dwarfmode/Zone'):format(hotkey_end)
    end
end

local function unbind_key(zone)
    if not zone then
        qerror("An invalid zone was provided")
    end

    local hotkey = zone.hotkey
    if not hotkey then
        return
    end

    dfhack.run_command_silent(('keybinding clear %s'):format(hotkey_character_to_binding(hotkey)))
    zone.hotkey = nil
end

local function bind_key(zone)
    if not zone then
        qerror("An invalid zone was provided")
    end

    local hotkey = zone.hotkey
    if not hotkey then
        return
    end

    dfhack.run_command_silent(('keybinding add %s "gui/visible-hotkeys %d"'):format(hotkey_character_to_binding(hotkey), zone.identifier))
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
        key_labels[i] = Label {
            view_id = zone.title,
            frame = {
                t = ((i - 1) % row_count) * item_height,
                l = (i <= row_count) and 0 or item_width,
            },
            text = zone.hotkey or '',
            text_pen = {
                fg = COLOR_GREEN,
                bg = COLOR_BLACK,
                bold = true,
            },
        }
    end
    if #key_labels > 0 then
        self:addviews(key_labels)
    end
end

function ZoneBindingsOverlay:render(painter)
    if df.global.game.main_interface.bottom_mode_selected ~= df.main_bottom_mode_type.ZONE then
        return
    end
    ZoneBindingsOverlay.super.render(self, painter)
end

function bind(zone_title, hotkey)
    if type(hotkey) ~= "string" then
        qerror(('Hotkey must be a string, but %s was provided'):format(type(hotkey)))
    end
    if not hotkey:match("^%a$") then
        qerror(('Hotkey must be a single small or capital letter, but "%s" was provided'):format(hotkey))
    end

    local current_zone
    for _, zone in ipairs(zones) do
        if zone.title == zone_title then
            current_zone = zone
            break
        end
    end
    if not current_zone then
        qerror(('Cannot find zone "%s"'):format(zone_title))
    end

    -- Use a separate loop for unbinding for the case the title is not found
    for _, zone in ipairs(zones) do
        if zone.hotkey == hotkey then
            unbind_key(zone)
        end
    end

    unbind_key(current_zone)
    current_zone.hotkey = hotkey
    bind_key(current_zone)
end

function on_zone_key(zone_identifier)
    local main_interface = df.global.game.main_interface

    if main_interface.bottom_mode_selected ~= df.main_bottom_mode_type.ZONE then
        qerror(('The script must be called in ZONE mode (%d), but the current mode is %d')
                :format(df.main_bottom_mode_type.ZONE, main_interface.bottom_mode_selected))
    end

    main_interface.civzone.adding_new_type = zone_identifier
    main_interface.bottom_mode_selected = df.main_bottom_mode_type.ZONE_PAINT
end

function start()
    for _, zone in ipairs(zones) do
        bind_key(zone)
    end
end

function stop()
    for _, zone in ipairs(zones) do
        unbind_key(zone)
    end
end

OVERLAY_WIDGETS = { ['zone-overlay'] = ZoneBindingsOverlay }

enabled = enabled or false
function isEnabled()
    return enabled
end

if dfhack_flags.enable then
    if dfhack_flags.enable_state then
        start()
        enabled = true
    else
        stop()
        enabled = false
    end
end

if not dfhack_flags.module then
    local args = { ... }
    if #args == 1 then
        on_zone_key(args[1])
    end
end
