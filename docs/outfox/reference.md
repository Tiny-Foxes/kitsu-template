## Global

| SCREEN: *ActorFrame* - Top screen |
| SW, SH: *float*, *float* - Screen width, screen height |
| SCX, SCY: *float*, *float* - Screen center X, screen center Y |
| DT: *float* - Time since last update via frame |
| TICK: *float* - Time since last update via ticks |
| CONST_TICK: *bool* - If mods and nodes should be processed by ticks instead of delta |
| TICKRATE: *int* - Rate at which mods and nodes are processed |
| BEAT: *float* - Current beat in song |
| BPS: *float* - Current beats per second |
| BPM: *float* - Current beats per minute |
| BPT: *float* - Current beats per tick |
| SPB: *float* - Current seconds per beat |
| TPB: *float* - Current ticks per beat |
| CENTER_PLAYERS: *bool* - If players should be centered on the screen |
| SRT_STYLE: *bool* - If file should hide screen elements and leave only playfields |
| printerr - Print error to console |
| Mods.new() - Create a new mod branch |
| Node.new() - Create a new node |



## Mods

| InsertMod(start: *float*, len: *float*, ease: *function*, \{modpair, ...\}, \[offset\]: *float*, \[pn\]: *int*) - Insert a mod into a branch |
| MirinMod(\{start: *float*, len: *float*, ease: *function*, percent: *float*, mod: *string*, ...\}, \[offset\]: *float*, \[pn\]: *int*) - Use Mirin style to insert mod |
| ExschMod(start: *float*, end: *float*, start_percent: *float*, end_percent: *float*, mod: *string*, timing: *string*, ease: *function*, \[pn\]: *int*) - Use Exschwasion style to insert mod |
| AddToModTree() - Add a mod branch to the mod tree |

## Node

| AttachScript(path: *string*) - Attach a script to a node |
| SetReady(func: *function*) - Set a node's ready function |
| SetUpdate(func: *function*) - Set a node's update function |
| SetInput(func: *function*) - Set a node's input function |
| SetDraw(func: *function*) - Set a node's draw function (untested!) |
| AddToNodeTree() - Add a node to the node tree |


