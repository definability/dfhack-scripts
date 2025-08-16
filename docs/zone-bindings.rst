zone-bindings
=============

.. dfhack-tool::
    :summary: Script for zone key bindings.
    :tags: fort productivity buildings

By default, users cannot assign key bindings to zones.
This script removes this restriction and works only in ``dwarfmode/Zone`` context.
Simply speaking, you add the appropriate key bindings to your configuration file
and use them after clicking `z` when playing in Fortress mode.

Usage
-----

Standalone script

::

    zone-bindings [<zone identifier>]

Configuration file entry

::

    keybinging add <hotkey>@dwarfmode/Zone "zone-bindings [<zone identifier>]"

Examples
--------

``zone-bindings dormitory``
    A very basic example.
    This script switches the game to dormitory zone painting mode when in zone mode.

``keybinding add B@dwarfmode/Zone "zone-bindings bedroom"``
    Example line for adding a key binding to `dfhack-config/init/dfhack.init`.
    `dwarfmode/Zone` context ensures the key binding does not override keys when you are not in zone context.

``keybinding add Shift-D@dwarfmode/Zone "zone-bindings dining-hall"``
    Zone identifier is a lowercase zone title with dashes instead of spaces and slashes.

``keybinding add M@dwarfmode/Zone "zone-bindings meeting-area"``

``keybinding add B@dwarfmode/Zone "zone-bindings bedroom"``

``keybinding add H@dwarfmode/Zone "zone-bindings dining-hall"``

``keybinding add P@dwarfmode/Zone "zone-bindings pen-pasture"``

``keybinding add Shift-P@dwarfmode/Zone "zone-bindings pit-pond"``

``keybinding add R@dwarfmode/Zone "zone-bindings water-source"``

``keybinding add N@dwarfmode/Zone "zone-bindings dungeon"``

``keybinding add F@dwarfmode/Zone "zone-bindings fishing"``

``keybinding add Shift-N@dwarfmode/Zone "zone-bindings sand"``

``keybinding add O@dwarfmode/Zone "zone-bindings office"``

``keybinding add Y@dwarfmode/Zone "zone-bindings dormitory"``

``keybinding add Shift-B@dwarfmode/Zone "zone-bindings barracks"``

``keybinding add Shift-Y@dwarfmode/Zone "zone-bindings archery-range"``

``keybinding add G@dwarfmode/Zone "zone-bindings garbage-dump"``

``keybinding add L@dwarfmode/Zone "zone-bindings animal-training"``

``keybinding add Shift-T@dwarfmode/Zone "zone-bindings tomb"``

``keybinding add Shift-F@dwarfmode/Zone "zone-bindings gather-fruit"``

``keybinding add Shift-L@dwarfmode/Zone "zone-bindings clay"``
    Configuration file entries with non-interfering naming that respect `WASD` (camera movement) and `EC` (level change).

Zone identifiers
----------------

``meeting-area``
    Meeting Area.
``bedroom``
    Bedroom.
``dining-hall``
    Dining hall.
``pen-pasture``
    Pen/Pasture.
``pit-pond``
    Pit/Pond.
``water-source``
    Water Source.
``dungeon``
    Dungeon.
``fishing``
    Fishing.
``sand``
    Sand.
``office``
    Office.
``dormitory``
    Dormitory.
``barracks``
    Barracks.
``archery-range``
    Archery Range.
``garbage-dump``
    Garbage Dump.
``animal-training``
    Animal Training.
``tomb``
    Tomb.
``gather-fruit``
    Gather Fruit.
``clay``
    Clay.
