--[[
    Information:

    - Ragdoll Universe (https://www.roblox.com/games/1466995005/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities

-- // Disable Team Check
local AimingIgnored = Aiming.Ignored
AimingIgnored.TeamCheck(false)

local AimingSettings = Aiming.Settings
AimingSettings.Ignored.IgnoreLocalTeam = false

-- // Services
local Teams = game:GetService("Teams")

-- // Enable custom team check
function AimingUtilities.TeamMatch(Player1, Player2)
    -- // Vars
    local Team1
    local Team2

    -- // Grabbing their teams
    for _, Team in ipairs(Teams:GetTeams()) do
        -- //
        local TeamPlayers = Team:GetPlayers()

        -- // Set their team, if found
        if (table.find(TeamPlayers, Player1)) then
            Team1 = Team
        elseif (table.find(TeamPlayers, Player2)) then
            Team2 = Team
        end
    end

    -- // Failsafing if a player is a taem
    if (Player1:IsA("Team")) then
        Team1 = Player1
    end
    if (Player2:IsA("Team")) then
        Team2 = Player2
    end

    -- // Failsafing for FFA gamemodes
    if (Team1 == nil or Team2 == nil) then
        return false
    end

    -- // Return
    return Team1.TeamColor == Team2.TeamColor
end

-- // Return
return Aiming