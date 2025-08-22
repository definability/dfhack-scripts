--@ module = true

local Panel = require('gui.widgets').Panel
local OverlayWidget = require('plugins.overlay').OverlayWidget
local helpers = reqscript('internal/visible-hotkeys/helpers')

local BindingLabel = helpers.BindingLabel
local get_cell_frame = helpers.get_cell_frame

local ceil = math.ceil

local function is_focus_building()
    local current_focus = dfhack.gui.getCurFocus()
    if #current_focus ~= 1 then
        return false
    end
    return current_focus[1] == 'dwarfmode/Building'
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
end

function BuildingBindingsOverlay:overlay_onupdate(viewscreen)
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

function BuildingBindingsOverlay:preUpdateLayout(parent_rect)
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
    local current_page = get_last_construction_page()
    if not current_page or not current_page.bb_button or #current_page.bb_button == 0 then
        return
    end

    -- `bb_button` is a C++ array, so the indexing is zero-based
    local grid_height = current_page.bb_button[0].grid_height

    local ey = current_page and current_page.last_main_ey or 0
    local ex = current_page and current_page.last_main_ex or 0

    local construction = df.global.game.main_interface.construction
    local rows = construction.max_height
    local full_l = ex - construction.total_width
    local height = (rows - 1) * grid_height + 1

    self.frame.t = ey - height
    self.frame.h = height
    self.frame.l = ceil(full_l / 2) - 1
    self.frame.w = construction.total_width
end
