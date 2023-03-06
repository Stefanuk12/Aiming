--[[
    Information:

    - Energy Assault (https://www.roblox.com/games/6172932937/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingSettings = Aiming.Settings

-- // Disable Team Check
AimingSettings.Ignored.IgnoreLocalTeam = false

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- // Vars
local LocalPlayer = Players.LocalPlayer

-- // Set RaycastIgnore
function AimingSettings.RaycastIgnore()
    local bulletsgothrough = Workspace:FindFirstChild("map") and Workspace.map:FindFirstChild("bulletsgothrough")
    return {Aiming.Utilities.Character(LocalPlayer), Aiming.Utilities.GetCurrentCamera(), bulletsgothrough}
end

-- // Return
return Aiming