# Definability Scripts for DFHack

Custom scripts to improve [Dwarf Fortress][df]
gameplay via [DFHack] modding engine.

Tip for beginners:
you can [download Dwarf Fortress][df] for free from the official website
or buy it on [Steam][df-steam] or [itch.io][df-itch] to get improved visuals and audio
and support developers.
DFHack is available for free on the [official GitHub page][DFHack]
and [Steam][dfhack-steam].

## Scripts

The repository contains the following scripts.
I plan to add more in the future.

### zone-bindings

Zones, unlike buildings, do not have key bindings in the vanilla version of the game.
When you are going to create multiple temples or guilds, using mouse becomes annoying.
This script allows you to remove this restriction with maximum customisation.

To activate it, copy [zone-bindings.lua] to your `hack/scripts` directory
and add the desired key bindings to `dfhack-config/init/dfhack.init`.

#### Recommended settings

In the following configuration example,
zones are sorted and grouped just like they appear in the game
for readability:
```
# zone painting, left column
keybinding add M@dwarfmode/Zone "zone-bindings meeting-area"
keybinding add B@dwarfmode/Zone "zone-bindings bedroom"
keybinding add H@dwarfmode/Zone "zone-bindings dining-hall"
keybinding add P@dwarfmode/Zone "zone-bindings pen-pasture"
keybinding add Shift-P@dwarfmode/Zone "zone-bindings pit-pond"
keybinding add R@dwarfmode/Zone "zone-bindings water-source"
keybinding add N@dwarfmode/Zone "zone-bindings dungeon"
keybinding add F@dwarfmode/Zone "zone-bindings fishing"
keybinding add Shift-N@dwarfmode/Zone "zone-bindings sand"
# zone painting, right column
keybinding add O@dwarfmode/Zone "zone-bindings office"
keybinding add Y@dwarfmode/Zone "zone-bindings dormitory"
keybinding add Shift-B@dwarfmode/Zone "zone-bindings barracks"
keybinding add Shift-Y@dwarfmode/Zone "zone-bindings archery-range"
keybinding add G@dwarfmode/Zone "zone-bindings garbage-dump"
keybinding add L@dwarfmode/Zone "zone-bindings animal-training"
keybinding add Shift-T@dwarfmode/Zone "zone-bindings tomb"
keybinding add Shift-F@dwarfmode/Zone "zone-bindings gather-fruit"
keybinding add Shift-L@dwarfmode/Zone "zone-bindings clay"
```

Read [docs/zone-bindings.rst]
if you want to understand the script usage a bit more.

### gui/visible-hotkeys

Zones, unlike buildings, do not have key bindings in the vanilla version of the game.
When you are going to create multiple temples or guilds, using mouse becomes annoying.
This script allows you to remove this restriction with maximum customisation.

To activate it, copy [gui/visible-hotkeys.lua] to your `hack/scripts/gui` directory
and enable the script and overlay by adding the following lines to your `dfhack-config/init/dfhack.init`:
```
# hack/scripts/gui

enable gui/visible-hotkeys
overlay enable gui/visible-hotkeys.zone-overlay
```

#### Default key bindings

The following hotkeys are available by default in zone selection menu
once you enable the script:

- Meeting Area: `m`
- Bedroom: `b`
- Dining Hall: `h`
- Pen/Pasture: `p`
- Pit/Pond: `P`
- Water Source: `r`
- Dungeon: `n`
- Fishing: `f`
- Sand: `N`
- Office: `o`
- Dormitory: `y`
- Barracks: `B`
- Archery Range: `Y`
- Garbage Dump: `g`
- Animal Training: `l`
- Tomb: `T`
- Gather Fruit: `F`
- Clay: `L`

Lowercase letters mean just pressing the key,
and uppercase letters mean holding the `Shift` button and pressing the key.

#### Custom key bindings

You can create your own assignments in `dfhack-config/init/onLoad.init`.
You must use this file to avoid known issues with incorrect keys displayed in the widget.
If your new key binding conflicts with any other hotkey managed by the script,
it will be unassigned first.

For example, the following code assigns `Shift-A` for painting a meeting area,
`O` (without `Shift`) for painting tomb,
and removes bindings for bedroom zone:
```
# dfhack-config/init/onLoad.init

:lua reqscript('gui/visible-hotkeys').add('Meeting Area', 'A')
:lua reqscript('gui/visible-hotkeys').add('Tomb', 'o')
:lua reqscript('gui/visible-hotkeys').clear('Bedroom')
```

By default, `o` is used for office,
so these commands will also remove the key bindings for office.

Read [docs/gui/visible-hotkeys.rst]
if you want to understand the script usage a bit more.

[DFHack]: https://github.com/DFHack/dfhack/
[dfhack-steam]: https://store.steampowered.com/app/2346660/DFHack__Dwarf_Fortress_Modding_Engine/
[df]: https://www.bay12games.com/dwarves/
[df-steam]: https://store.steampowered.com/app/975370
[df-itch]: https://kitfoxgames.itch.io/dwarf-fortress
[docs/gui/visible-hotkeys.rst]: docs/gui/visible-hotkeys.rst
[docs/zone-bindings.rst]: docs/zone-bindings.rst
[gui/visible-hotkeys.lua]: gui/visible-hotkeys.lua
[zone-bindings.lua]: zone-bindings.lua
