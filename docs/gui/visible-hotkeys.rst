visible-hotkeys
=============

.. dfhack-tool::
    :summary: Module for assigning and visualising zone key bindings.
    :tags: fort productivity buildings

By default, users cannot assign key bindings to zones.
This script allows creating custom key bindings and shows them in the zone choice menu.

Usage
-----

Be careful and use the proper configuration files.
You should enable the script and widget in ``dfhack.init``
while key bindings reassignment should take place in ``onLoad.init``.
This issue is due to be investigated.

Add the following lines to your ``dfhack-config/init/dfhack.init`` configuration file
to enable hotkeys in zone selection window:

::
    enable gui/visible-hotkeys

Add the following lines to your ``dfhack-config/init/dfhack.init`` configuration file
to display the hotkeys assigned via this script in zone selection window:

::
    overlay enable gui/visible-hotkeys.zone-overlay

Add the following lines to your ``dfhack-config/init/onLoad.init`` configuration file
to modify key bindings.
The key must be a single lowercase or uppercase letter.
An uppercase letter means using the ``Shift`` key,
while a lowercase letter means pressing the key corresponding to the letter.
The quotes are necessary.
For multiple assignments, you must repeat the command with different zone titles.

::

    :lua reqscript('gui/visible-hotkeys').add('<zone title>', '<key>')

Add the following lines to your ``dfhack-config/init/onLoad.init`` configuration file
to remove key binding for the zone.
It is safe to clear when no bindings are assigned.

::

    :lua reqscript('gui/visible-hotkeys').clear('<zone title>')

Default hotkeys
----------------

The following hotkeys are available by default in zone selection menu
once you enable the script:

- Meeting Area: ``m``
- Bedroom: ``b``
- Dining Hall: ``h``
- Pen/Pasture: ``p``
- Pit/Pond: ``P``
- Water Source: ``r``
- Dungeon: ``n``
- Fishing: ``f``
- Sand: ``N``
- Office: ``o``
- Dormitory: ``y``
- Barracks: ``B``
- Archery Range: ``Y``
- Garbage Dump: ``g``
- Animal Training: ``l``
- Tomb: ``T``
- Gather Fruit: ``F``
- Clay: ``L``

The default bindings do not use `WASD` (camera movement) and `EC` (level change).
You can reassign them manually and use these keys if you wish.

Examples
--------

``enable gui/visible-hotkeys``
    Just enable the default hotkeys.

``overlay enable gui/visible-hotkeys.zone-overlay``
    Display hotkeys in zone selection menu.
    Keep in mind that this command does not enable the hotkeys,
    so you should also use ``enable gui/visible-hotkeys``.

``:lua reqscript('gui/visible-hotkeys').add('Archery Range', 'A')``
    Use ``Shift-A`` for "Archery Range" zone painting.
    After the script is enabled, you can modify the bindings.
    Keep in mind that such a binding disables using ``Shift-A``
    for moving the camera to the left when the zone choice window is visible.
    The old hotkey will be released.
    With the default configuration, this means ``A`` will override ``Y`` for "Archery Range",
    and pressing ``Shift-Y`` will not trigger "Archery Range" zone paint until reassigned.

``:lua reqscript('gui/visible-hotkeys').add('Gather Fruit', 'g')``
    Use ``G`` key for "Archery Range" zone painting.
    If the key is already in use, it will be unbound automatically from the previous action.
    For example, by default, ``g`` is used for the "Garbage Dump" zone.
    Thus, "Garbage Dump" loses its hotkey after being assigned ``g`` to "Gather Fruit."
    You can leave it as is or assign a new hotkey to "Garbage Dump" in this example.

Known issues
------------

The widget draws the default key bindings in the following cases:
- The bindings are specified in ``dfhack-config/init/dfhack.init`` rather then ``dfhack-config/init/onLoad.init``
  and the user reloads a saved game without exiting the Dwarf Fortress application.
- The bindings are specified during the game (in the game console, ``Ctrl-Shift-P``).

Workaround:

Set up the key bindings for this script only in ``dfhack-config/init/onLoad.init``.
Do not expect the overlay to display the correct information after modifying the bindings from DFHack console.
