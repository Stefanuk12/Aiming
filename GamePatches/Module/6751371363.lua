--[[
    Information:

    - Hood Duels (https://www.roblox.com/games/6751371363/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()

-- // Disable Team Check
Aiming.Settings.Ignored.IgnoreLocalTeam = false

-- // Return
return Aiming