--[[
    Information:

    - Criminality (https://www.roblox.com/games/4588604953/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingSettings = Aiming.Settings

-- // Settings
AimingSettings.Ignored.IgnoreLocalTeam = false
AimingSettings.TargetPart = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Vars
local CharStats = ReplicatedStorage:WaitForChild("CharStats")

-- // Downed Check
local AimingChecks = Aiming.Checks
function AimingChecks.Custom(Character)
    -- // Get the downed boolval
    local Stats = CharStats:FindFirstChild(Character.Name)
    if not Stats then
        return false
    end
    local Downed = Stats:FindFirstChild("Downed")
    if not Downed then
        return false
    end

    -- // Return if they are downed
    return Downed.Value
end

-- // Return
return Aiming