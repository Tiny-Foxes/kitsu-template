# Staging Notes

## Note-specific Mods
### May 14, 2021 6:45am
This actually wasn't hard to implement. A bit tricky, but most of the work involved making higher dimension table to hold all of the mods for all of the specified notes.

Some notes during the addition of notemod support:
1. Notemods seem to work very similar to normal mods in the sense of how easing can be applied to them.
1. Kid is correct; they are additive to notefield mods, but not column mods.
1. Since notepaths are column based, notemods do not affect the notepath at all.
1. All of the above may share the same reasoning as how the notemods are applied to the player.