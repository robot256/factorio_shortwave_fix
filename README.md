# Factorio Mod: Shortwave for 1.1

Hotfix for dorfl's Shortwave mod (https://mods.factorio.com/mod/shortwave) in Factorio 1.1. Also fixes some potential compatibility issues with Space Exploration and Creative Mod, and better pipette behavior using the helper function in Robot256Lib. Feel free to use these changes when the main mod updates!

Connect or separate circuit networks via shortwave radio channels.
UPS-friendly and real-time activity -- no on-tick Lua required.
Usage
Build and place a shortwave radio pack.
Set the radio channel using the large dial knob (selection box on lower-right). Channels take the signal count into account, so IronPlate(2) is different to IronPlate(17).
Connect the radio to a local circuit network (selection box on upper-left). Local signals will be transmitted to other radios tuned to the same channel, and vice-versa.