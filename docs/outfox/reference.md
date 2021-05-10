## Mods
| Methods | Description |
| --- | --- |
| InsertMod(*start*: float, *len*: float, *ease*: function, \{modpair, ...\}, *\[offset\]*: float, *\[pn\]*: int) | Inserts a mod into a branch |
| MirinMod(\{*start*: float, *len*: float, *ease*: function, *percent*: float, *mod*: string, ...\}, *\[offset\]*: float, *\[pn\]*: int) | Uses Mirin style to insert mod |
| ExschMod(*start*: float, *end*: float, *start_percent*: float, *end_percent*: float, *mod*: string, *timing*: string, *ease*: function, *\[pn\]*: int) | Uses Exschwasion style to insert mod |
| AddToModTree() | Add a mod branch to the mod tree |

## Node
| Methods | Description |
| --- | --- |
| AttachScript(*path*: string) | Attach a script to a node |
| SetReady(*func*: function) | Set a node's ready function |
| SetUpdate(*func*: function) | Set a node's update function |
| SetInput(*func*: function) | Set a node's input function |
| AddToNodeTree() | Add a node to the node tree |
