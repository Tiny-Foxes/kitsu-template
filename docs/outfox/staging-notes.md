# Staging Notes

### May 14, 2021 6:45am
Note-specific mod support actually wasn't hard to implement. A bit tricky, but most of the work involved making higher dimension table to hold all of the mods for all of the specified notes.

Some notes during the addition of notemod support:
1. Notemods seem to work very similar to normal mods in the sense of how easing can be applied to them.
1. Kid is correct; they are additive to notefield mods, but not column mods.
1. Since notepaths are column based, notemods do not affect the notepath at all.
1. All of the above may share the same reasoning as how the notemods are applied to the player.
1. If we are able to obtain notedata from the game through Lua, adding beat-specific activated notemods would be as easy as a for-loop.  
[![remember to brush your notes kids](http://img.youtube.com/vi/fuzIcjOU-n4/0.jpg)](http://www.youtube.com/watch?v=fuzIcjOU-n4 "remember to brush your notes kids")
1. There's probably a lot of things that don't require extra players anymore.
