# FAQ
## What can I use this for?
You should use this for anything "Aiming" based. Examples include silent aim and aimbot.

## Why should I use this?
Built in, there is "patches" for many games. This means it is very easy to make aiming scripts for many games. In addition, there is already pre-made features (e.g. FOV / Hit Chance) which allows you to create high-quality aiming scripts while minimising bugs and time taken.

## Can I contribute?
Of course, you can create pull requests for things such as Game Patches and additional features!

## Can I use this?
You are allowed to use this, but you must credit me - asper the license agreement.

# Usage
Simply load the script like this:
```lua
-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")
```

!!! warning
    **Please** use the loader, instead of directly using the module. In rare cases, load the game patch for the specific game - if you have to. This is because you miss out on the automatic patch apply!

## Loading Specific Game Patches
Some games like `Rush Point` may have multiple place ids. In order to load the correct patch, you can set the second argument as the name of the patch you want. For example:
```lua
-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module", "RushPoint")
```

## What does the first argument mean?
The first argument is the type of module you want. There are two types - `NPC` and `Module`. `NPC` is specifically designed to work with NPCs (but it requires configuration) and `Module` is specifically for Players.