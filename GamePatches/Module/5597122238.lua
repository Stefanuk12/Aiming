--[[
    Information:

    - Quarantine-Z (https://www.roblox.com/games/4923599624/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities

-- // Vars
local PlayerList = getrenv()._G.PlayerList

-- // Getting Character
function AimingUtilities.Character(Player)
    return PlayerList[Player]
end