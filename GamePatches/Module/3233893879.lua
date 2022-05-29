--[[
    Information:

    - Bad Business (https://www.roblox.com/games/3233893879/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities
local AimingChecks = Aiming.Checks

-- // Services
local Teams = game:GetService("Teams")

-- // Grabbing the character manager
local CharacterManager
for _, v in ipairs(getgc(true)) do
    if (typeof(v) == "table" and rawget(v, "InitProjectile") and rawget(v, "TS")) then
        CharacterManager = getupvalue(v.TS.Characters.GetCharacter, 1)
        break
    end
end

-- //
function AimingUtilities.Character(Player, Index)
    -- // Default
    Index = Index or "Body"

    -- // Get the character
    local Character = CharacterManager[Player]
    if (not Character) then return end

    -- // Return their body
    return Index == "Character" and Character or Character:FindFirstChild(Index)
end

-- //
function AimingUtilities.TeamMatch(Player1, Player2)
    -- // Getting their teams
    local Team1 = Teams:FindFirstChild(Player1.Name, true)
    local Team2 = Teams:FindFirstChild(Player2.Name, true)

    -- // Make sure we have their teams
    if not (Team1 or Team2) then
        return false
    end

    -- // Grab Team
    Team1 = Team1.Parent.Parent.Name
    Team2 = Team2.Parent.Parent.Name

    -- // FFA Check
    if (Team1 == "FFA" or Team2 == "FFA") then
        return false
    end

    -- // Return
    return Team1 == Team2
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