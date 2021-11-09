# Kitsu Template v3.1.0

## Changes
- Reformatted `mods.lua` to streamline mod implementation
- Added `bg.lua` and `fg.lua` for background and foreground actors
- Added `using` function to allow for scoping of namespaces (useful for repeated use of a library such as `mirin-syntax`)
- Fixed environment behavior to support `using`
- Reimplemented `mirin-syntax` as a built-in library (you may remove this if you wish)
- Configured `mods.lua` with `using 'mirin'` to streamline mod implementation (you may remove this if you wish)
- Edited `print` to support tables
- Edited chart to have appropriate BPM and time signatures
- Fixed broken functions in `konko-node` getting variables in wrong environment
- Fixed `run` and `import` using default `sudo` environment to load files
- Moved player proxies to `fg.lua`
- Created background for `bg.lua`
- Added default mods in `mods.lua`
