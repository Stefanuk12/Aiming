--[[
    Information:

    - CS Prison Life (https://www.roblox.com/games/8278412720/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- // Vars
local LocalPlayer = Players.LocalPlayer
local Regions = Workspace.Regions

-- //
function Aiming.Settings.RaycastIgnore()
    local Base = Regions:GetChildren()
    table.insert(Base, AimingUtilities.Character(LocalPlayer))
    table.insert(Base, Workspace.CurrentCamera)
    return Base
end

-- //
return Aiming