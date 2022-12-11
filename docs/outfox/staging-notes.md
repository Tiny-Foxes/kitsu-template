# Staging Notes

### December 10, 2022 5:23pm
I realize the importance of the stable sort function. I still don't understand what it does but I understand that it works.

I was contemplating splitting `mods.lua` into three different pieces (`bg.lua`, `mods.lua`, and `fg.lua`), but I've decided against it for now. Maybe in a future release.

I'm going to need to update the docs to something that's more like a getting started guide than just a cold slate of function references. It's not very straightforward how the template works and I'm working on that. Although, to be honest, I'm hoping that by then I have at least one person who's willing to help me with writing documentation since I'm terrible with words and writing it myself would likely fail.

I also want to figure out some new libraries to write for this. I've been trying to think of problems that would need solutions so that I could just bang out a couple of libraries to shove in here. I don't want to include every library, but having several of them would be nice. I should really update the library list that I have on GitHub with the new ones I've been writing.

I think the next library will be for textboxes.

---

### August 29, 2022 7:07pm
Jesus Christ the docs are so out of date.

I did my best to fix up what I could with the README, but it's gonna take a while before I get to the API reference documentation. There's just a lot on my plate and it'll take a while for me to get through all of it.

I almost accidentally deleted the entire docs, by the way. What the hell is my goddamn problem.

---

### October 15, 2021 1:19am
I've finally gotten back into the swing of working on the template again. During the time I haven't been around this I've made [an entire theme](https://github.com/Tiny-Foxes/superuser-outfox "god it took forever to actually push myself to do this").

Massive changes this month. The mod loader and actor loader I wrote are completely different from how they started out. For one, they're actually libraries now, completely lacking in requirement. Even the *standard library* isn't required, someone could literally write their own `stdlib`. And I think that's pretty damn badass. Don't like my shit? Don't use it! You can use your own! Hell yeah.

I'm about to release v3.0.0 now, since this is actually going to break a ton of compatibility. But it's definitely worth it, it's *much* better this way.

---

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
1. Using notedata and notemods together is very powerful, and pretty much a necessity. Need good documentation on how to do both.
1. Calling a few `InsertNoteMod` functions is fine. Calling several `InsertNoteMod` can cause a hiccup at the beginning of the file.
1. In order to ease every note, we need a for-loop. In order to ease ANY note, we need to call `AddNoteMod` every frame that the ease is active. This can impact performance immensely right now.

---

###### [Return to Home](/kitsu-template)