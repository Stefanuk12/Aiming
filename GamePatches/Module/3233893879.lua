--[[
    Information:

    - Bad Business (https://www.roblox.com/games/3233893879/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities
local AimingChecks = Aiming.Checks

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

-- // Vars
local TS = require(ReplicatedStorage.TS)
local Characters = debug.getupvalue(TS.Characters.GetCharacter, 1)

-- //
local IsPartVisible = AimingUtilities.IsPartVisible
function AimingUtilities.IsPartVisible(Part, PartDescendant)
    if (PartDescendant and PartDescendant.Parent) then
        PartDescendant = PartDescendant.Parent
    end

    return IsPartVisible(Part, PartDescendant)
end

-- //
function AimingUtilities.Character(Player, Index)
    -- // Default
    Index = Index or "Body"

    -- // Get the character
    local Character = Characters[Player]
    if (not Character) then
        return
    end

    -- // Return their body
    return Index == "Character" and Character or Character:FindFirstChild(Index)
end

-- //
local function GetTeam(Player)
    for _, v in ipairs(Teams:GetChildren()) do
        if (v.Players:FindFirstChild(Player.Name)) then
            return v.Name
        end
    end
end
function AimingUtilities.TeamMatch(Player1, Player2)
    -- // Grab their teams
    local Player1Team = GetTeam(Player1)
    local Player2Team = GetTeam(Player2)

    -- // FFA Check
    if (Player1Team == "FFA" or Player2Team == "FFA") then
        return false
    end

    -- // Return
    return Player1Team == Player2Team
end

-- //
function AimingChecks.Health(Player)
    -- // Get Character
    local Health = AimingUtilities.Character(Player, "Health")
    if (not Health) then
        return false
    end

    -- //
    return Health.Value > 0
end

-- // Return
return Aiming