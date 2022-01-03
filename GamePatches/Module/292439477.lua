--[[
    Information:

    - Phantom Forces (https://www.roblox.com/games/292439477/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local ClientManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Games/Phantom%20Forces/ClientManager.lua"))()

-- //
local AimingSettings = Aiming.Settings
AimingSettings.TargetPart = {"Head", "Torso"}
local Client = ClientManager.new()

-- // Overwrites // --
local AimingUtilities = Aiming.Utilities
function AimingUtilities.Character(Player)
    local Parts = Client.Characters[Player]
    return Parts and Parts.torso.Parent or nil
end

function AimingUtilities.CameraLookAt(Position)
    local ClientCamera = Client.camera

    local LookAt = CFrame.lookAt(ClientCamera.cframe.Position, Position)
    local Angles = Vector3.new(LookAt:ToOrientation())

    ClientCamera.angles = Angles
end

local AimingChecks = Aiming.Checks
function AimingChecks.Health(Player)
    local Health, MaxHealth = Client.hud:getplayerhealth(Player)
    return Health > 0
end

-- //
return Aiming, Client