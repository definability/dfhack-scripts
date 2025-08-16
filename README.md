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

[DFHack]: https://github.com/DFHack/dfhack/
[dfhack-steam]: https://store.steampowered.com/app/2346660/DFHack__Dwarf_Fortress_Modding_Engine/
[df]: https://www.bay12games.com/dwarves/
[df-steam]: https://store.steampowered.com/app/975370
[df-itch]: https://kitfoxgames.itch.io/dwarf-fortress
[docs/zone-bindings.rst]: docs/zone-bindings.rst
[zone-bindings.lua]: zone-bindings.lua
