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
local GetBulletIgnoreTable = require(ReplicatedStorage.Modules.Shared.GetBulletIgnoreTable)
local ClassifyMaterial = require(ReplicatedStorage.Modules.Shared.ClassifyMaterial)
local Characters

-- // bruh. syn v2 bugging and returning empty getsenv???
pcall(function()
    Characters = debug.getupvalue(getsenv(ReplicatedStorage.BAC.Characters).NewChar, 1)
end)
Characters = Characters or debug.getupvalue(debug.getupvalue(getrawmetatable(require(game.ReplicatedStorage.BAC.Characters)).__index, 1).GetCharacter, 1)

-- //
local AimingIgnored = Aiming.Ignored
local AimingSettings = Aiming.Settings
local AimingUtilities = Aiming.Utilities
AimingSettings.TargetPart = {"HumanoidRootPart", "Head", "LowerTorso", "UpperTorso"}
AimingSettings.WallbangParts = {}
AimingSettings.Wallbang = false

-- // Calculates which parts can be wallbanged through
function AimingUtilities.CalculateWallbang(ShouldSet)
    -- // Make sure is enabled
    if (not AimingSettings.Wallbang) then
        return {}
    end

    -- // Vars
    local WallbangParts = {}

    -- // Loop through the entire map
    for _, v in ipairs(MapFolder:GetDescendants()) do
        -- // Check if the material matches
        if (v:IsA("BasePart") and ClassifyMaterial(v)) then
            -- // Add it
            table.insert(WallbangParts, v)
        end
    end

    -- // Set
    if (ShouldSet) then
        AimingSettings.WallbangParts = WallbangParts
    end

    -- // Return
    return WallbangParts
end
AimingUtilities.CalculateWallbang(true)

-- // See when the map changes, then recalculate the wallbang parts
local function RecalculateOnChange(child)
    -- // Ignore player stuff
    if not (child:IsA("BasePart") and ClassifyMaterial(child)) then
        return
    end

    -- // Recalculate
    AimingUtilities.CalculateWallbang(true)
end
MapFolder.DescendantAdded:Connect(RecalculateOnChange)
MapFolder.DescendantRemoving:Connect(RecalculateOnChange)

-- // Character
function AimingUtilities.Character(Player)
    -- // Character exists for LocalPlayer
    if (Player == LocalPlayer) then
        return LocalPlayer.Character
    end

    -- // Everyone else
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
    local Ignored = {Character, CurrentCamera, Workspace.RaycastIgnore, Workspace.DroppedWeapons, MapFolder.Map.Ramps, MapFolder.Map.Walls.MapWalls, unpack(GetBulletIgnoreTable()), unpack(AimingSettings.WallbangParts)}

    return Ignored
end

-- // Return
return Aiming