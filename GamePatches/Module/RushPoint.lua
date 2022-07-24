--[[
    Information:

    - Rush Point (https://www.roblox.com/games/5993942214/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Vars
local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local MapFolder = Workspace.MapFolder
local GameStats = MapFolder.GameStats
local Characters = debug.getupvalue(getsenv(ReplicatedStorage.BAC.Characters).NewChar, 1)

-- //
local AimingIgnored = Aiming.Ignored
local AimingSettings = Aiming.Settings
local AimingUtilities = Aiming.Utilities
AimingSettings.TargetPart = {"HumanoidRootPart", "Head", "LowerTorso", "UpperTorso"}

-- // Character
function AimingUtilities.Character(Player)
    return Characters[Player]
end

-- // Team Check
function AimingIgnored.IsIgnoredTeam(Player)
    -- // Deathmatch check
    if (GameStats.GameMode.Value == "Deathmatch") then
        return false
    end

    -- //
    return (LocalPlayer.SelectedTeam.Value == Player.SelectedTeam.Value)
end

-- // Ignore
function AimingSettings.RaycastIgnore()
    local Character = AimingUtilities.Character(LocalPlayer)
    local Ignored = {Character, CurrentCamera, Workspace.RaycastIgnore, Workspace.DroppedWeapons, MapFolder.Map.Ramps, MapFolder.Map.Walls.MapWalls}

    return Ignored
end

-- // Return
return Aiming