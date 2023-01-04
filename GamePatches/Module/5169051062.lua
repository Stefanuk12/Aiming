--[[
    Information:

    - Futuretops: Rework (https://www.roblox.com/games/5169051062/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingSettings = Aiming.Settings
local AimingUtilities = Aiming.Utilities

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- // Ignore
function AimingSettings.RaycastIgnore()
    local Character = AimingUtilities.Character(LocalPlayer)
    local Ignored = {Character, Workspace.CurrentCamera, Workspace:FindFirstChild("SpectateFolder")}

    return Ignored
end

-- // Return
return Aiming