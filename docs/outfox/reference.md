# Kitsu for Outfox API Reference

---

| Global | |
|:--- |:--- |
| `print`(dbg: *string*): *function* | Prints debug message to console |
| `printerr`(err: *string*): *function* | Prints error message to console |
| `import`(path: *string*): *variant* | Loads and returns a library from the `lib` folder |
| `run`(path: *string*): *variant* | Loads and returns an arbitrary file from the current song directory |
| `FG`: *ActorFrame* | Returns the foreground layer that is returned by `mods.lua` |

---

| Kitsu Standard Library | |
|:--- |:--- |
| `songdir`: *string* | Current song directory |
| `SCREEN`: *ActorFrame* | Top screen |
| `SW`, `SH`: *float*, *float* | Screen width, screen height |
| `SCX`, `SCY`: *float*, *float* | Screen center X, screen center Y |
| `DT`(): *float* | Time since last update via frame |
| `TICK`(): *float* | Time since last update via ticks |
| `CONST_TICK`: *bool* | If mods and nodes should be processed by ticks instead of frames |
| `TICKRATE`: *int* | Rate at which mods and nodes are processed if `CONST_TICK` is true |
| `BEAT`(): *float* | Current beat in song |
| `BPS`(): *float* | Current beats per second |
| `BPM`(): *float* | Current beats per minute |
| `BPT`(): *float* | Current beats per tick |
| `SPB`(): *float* | Current seconds per beat |
| `TPB`(): *float* | Current ticks per beat |

---

| Konko Mods | |
|:--- |:--- |
| Mods:`Insert`(start: *float*, len: *float*, ease: *function*, \{\{percent: *float*, mod: *string*\}, ...\}, \[offset\]: *float*, \[pn\]: *int*): *Mods* | Insert a mod. Returns Mods object. |
| Mods:`Default`(\{\{percent: *float*, mod: *string*\}, ...\}): *Mods* | Insert default mods. Return Mods object. |
| Mods:`Mirin`(\{start: *float*, len: *float*, ease: *function*, percent: *float*, mod: *string*, ...\}, \[offset\]: *float*, \[pn\]: *int*): *Mods* | Insert a mod using Mirin template syntax. Returns Mods object. |
| Mods:`Exsch`(start: *float*, end: *float*, start_percent: *float*, end_percent: *float*, mod: *string*, timing: *string*, ease: *function*, \[pn\]: *int*): *Mods* | Insert a mod using Exschwasion template syntax. Returns Mods object. |

---

| Konko Node | |
|:--- |:--- |
| Node.`new`(type: *string*): *Node* | Create and return a new Node. |
| Node.`ease`(\{actor: *string, table*, start: *float*, len: *float*, ease: *function*, amp1: *float*, amp2: *float*, property: *string*\}): *function* | Ease `property` of `actor` at `start` from `amp1` to `amp2` for `len` beats using `ease` to calculate strength. Returns `Node.ease`. |
| Node.`func`(\{actor: *string, table*, start: *float*, len: *float*, ease: *function*, from: *float*, to: *float*, func: *function(self, p)*\}): *function* | Ease `function` passing `actor` as function's self at beat `start` from `amp1` to `amp2` for `len` beats using `ease` to calculate strength. `p` returns current amplitude. Returns `Node.ease`. |
| Node:`GetNodeTree`(): *table* | Returns the node tree. |
| Node:`AttachScript`(path: *string*): *Node* | Attach a script to a Node. Self-returns. |
| Node:`SetInit`(func: *function(self)*): *Node* | Set a function the Node will run when the Node is initialized. Self-returns. |
| Node:`SetReady`(func: *function(self)*): *Node* | Set a function the Node will run right after OnCommand is called. Self-returns. |
| Node:`SetUpdate`(func: *function(self, dt)*): *Node* | Set a function the Node will run on every update. Self-returns. |
| Node:`SetInput`(func: *function(self, event)*): *Node* | Set a function the Node will run on every `InputEvent`. Self-returns. |
| Node:`SetCommand`(name: *string*, func: *function*): *Node* | Set a custom Command on a Node. Self-returns. |
| Node:`SetMessage`(name: *string*, func: *function*): *Node* | Set a custom  MessageCommand on a Node. Self-returns. |
| Node.`AddToNodeTree`(\[name\]: *string*, \[index\]: *int*): *Node* | Add a Node to the node tree. Self-returns. |

---
###### [Return to Home](/kitsu-template)
