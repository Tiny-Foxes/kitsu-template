# Kitsu for NotITG API Reference
---
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
| printerr(msg: *string*): *function* - Print error to console |
| Mods.new(): *ModBranch (table)* - Creates and return a new ModBranch |
| Node.new(type: *string*): *Node (table)* - Creates and return a new Node |
| event: *InputEvent (table)* - Game input event |

## ModBranch

| InsertMod(start: *float*, len: *float*, ease: *function*, \{\{percent: *float*, mod: *string*\}, ...\}, \[offset\]: *float*, \[pn\]: *int*): *table* - Insert a mod into a ModBranch. Returns mod inserted. |
| MirinMod(\{start: *float*, len: *float*, ease: *function*, percent: *float*, mod: *string*, ...\}, \[offset\]: *float*, \[pn\]: *int*): *table* - Use Mirin style to insert mod. Returns mod inserted. |
| ExschMod(start: *float*, end: *float*, start_percent: *float*, end_percent: *float*, mod: *string*, timing: *string*, ease: *function*, \[pn\]: *int*): *table* - Use Exschwasion style to insert mod. Returns mod inserted. |
| AddToModTree() - Add a ModBranch to the mod tree. |

## Node

| AttachScript(path: *string*) - Attach a script to a Node. |
| SetReady(func: *function(self)*) - Set a Node's ready function to run when Node is ready. |
| SetUpdate(func: *function(self, dt)*) - Set a Node's update function to run on every update. |
| SetInput(func: *function(self, event)*) - Set a Node's input function to run on every `InputEvent`. |
| SetDraw(func: *function(self)*) - Set a Node's draw function to run on every draw. (untested!) |
| AddToNodeTree() - Add a Node to the node tree. |

## InputEvent

| button: *InputEventButton (string)* - Button pressed |
| type: *InputEventType (string)* - Button activation type |
| PlayerNumber: *int* - Player number (zero-index) |
| controller: *GameController (string)* - Game Controller |
| DeviceInput.level: *int* -  Analog input level |

## Enums
### InputEventButton

| "Left" - Left Button |
| "Down" - Left Button |
| "Up" - Left Button |
| "Right" - Left Button |
| "Start" - Start Button |
| "Back" - Back Button |

### InputEventType

| "InputEventType_FirstPress" - First Press |
| "InputEventType_Repeat" - Repeat |
| "InputEventType_Release" - Release |

### GameController

| "GameController_1" - Game Controller 1 |
| "GameController_2" - Game Controller 2 |

###### [Return to Home](/kitsu-template)
