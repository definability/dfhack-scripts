gui/visible-hotkeys
===================

.. dfhack-tool::
    :summary: Module for assigning and visualising zone key bindings.
    :tags: fort productivity buildings

By default, users cannot assign key bindings to zones.
This script allows creating custom key bindings and shows them in the zone choice menu.

Usage
-----

Add the following lines to your ``dfhack-config/init/dfhack.init`` configuration file.

Enable hotkeys in zone selection window
and display the hotkeys assigned via this script in zone selection window:

::

    overlay enable gui/visible-hotkeys.zone-overlay

Use the following command to modify key bindings.
The key must be a single lowercase or uppercase letter.
An uppercase letter means using the ``Shift`` key,
while a lowercase letter means pressing the key corresponding to the letter.
The quotes are necessary.
For multiple assignments, you must repeat the command with different zone titles.

::

    overlay trigger gui/visible-hotkeys.zone-overlay add <zone title> <key>

To remove a hotkey for a zone of your choice, use the following command:

::

    overlay trigger gui/visible-hotkeys.zone-overlay clear <zone title>

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

``overlay enable gui/visible-hotkeys.zone-overlay``
    Display hotkeys in zone selection menu and enable the default hotkeys.

``overlay trigger gui/visible-hotkeys.zone-overlay add Archery Range A``
    Use ``Shift-A`` for "Archery Range" zone painting.
    After the script is enabled, you can modify the bindings.
    Keep in mind that such a binding disables using ``Shift-A``
    for moving the camera to the left when the zone choice window is visible.
    The old hotkey will be released.
    With the default configuration, this means ``A`` will override ``Y`` for "Archery Range",
    and pressing ``Shift-Y`` will not trigger "Archery Range" zone paint until reassigned.

``overlay trigger gui/visible-hotkeys.zone-overlay add Gather Fruit g``
    Use ``G`` key for "Archery Range" zone painting.
    If the key is already in use, it will be unbound automatically from the previous action.
    For example, by default, ``g`` is used for the "Garbage Dump" zone.
    Thus, "Garbage Dump" loses its hotkey after being assigned ``g`` to "Gather Fruit."
    You can leave it as is or assign a new hotkey to "Garbage Dump" in this example.

``overlay trigger gui/visible-hotkeys.zone-overlay clear Pit/Pond``
    Remove a hotkey for pit/pond zone creation.
    It may be useful if you want to use only specific zones,
    and keep the other bindings active for other actions when the zone window is active.
    However, remember, the hotkeys do not have effect when you are not in zone type choice mode.
    The bindings are only active when you can see them in the corresponding tiles.
