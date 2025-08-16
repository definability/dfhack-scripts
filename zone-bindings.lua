local main_interface = df.global.game.main_interface

if main_interface.bottom_mode_selected ~= df.main_bottom_mode_type.ZONE then
    qerror(('The script must be called in ZONE mode (%d), but the current mode is %d'):format(df.main_bottom_mode_type.ZONE, main_interface.bottom_mode_selected))
    return
end

local zones = {
    ['meeting-area'] = df.civzone_type.MeetingHall,
    ['bedroom'] = df.civzone_type.Bedroom,
    ['dining-hall'] = df.civzone_type.DiningHall,
    ['pen-pasture'] = df.civzone_type.Pen,
    ['pit-pond'] = df.civzone_type.Pond,
    ['water-source'] = df.civzone_type.WaterSource,
    ['dungeon'] = df.civzone_type.Dungeon,
    ['fishing'] = df.civzone_type.FishingArea,
    ['sand'] = df.civzone_type.SandCollection,
    ['office'] = df.civzone_type.Office,
    ['dormitory'] = df.civzone_type.Dormitory,
    ['barracks'] = df.civzone_type.Barracks,
    ['archery-range'] = df.civzone_type.ArcheryRange,
    ['garbage-dump'] = df.civzone_type.Dump,
    ['animal-training'] = df.civzone_type.AnimalTraining,
    ['tomb'] = df.civzone_type.Tomb,
    ['gather-fruit'] = df.civzone_type.PlantGathering,
    ['clay'] = df.civzone_type.ClayCollection,
}

local args = {...}
if #args ~= 1 then
    qerror(('Single argument expected but %d arguments provided'):format(#args))
    return
end

local current_zone_type = zones[args[1]]
if not current_zone_type then
    qerror(('Unknown zone type %s'):format(args[1]))
    return
end

main_interface.civzone.adding_new_type = current_zone_type
main_interface.bottom_mode_selected = df.main_bottom_mode_type.ZONE_PAINT
