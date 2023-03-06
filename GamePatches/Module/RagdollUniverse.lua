--[[
    Information:

    - Ragdoll Universe (https://www.roblox.com/games/1466995005/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities
local AimingSettings = Aiming.Settings

-- // Disable Team Check
AimingSettings.Ignored.IgnoreLocalTeam = false

-- // Set targetpart
AimingSettings.TargetPart = {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}

-- // Enable custom team check
function AimingUtilities.TeamMatch(Player1, Player2)
    -- // Vars
    local Team1
    local Team2

    -- // Grabbing their teams
    if (Player1:IsA("Team")) then
        Team1 = Player1.Name
    else
        local Player1Character = AimingUtilities.Character(Player1)
        if (Player1Character and Player1Character:FindFirstChild("Team")) then
            Team1 = Player1Character.Team.Value
        end
    end

    if (Player2:IsA("Team")) then
        Team2 = Player2.Name
    else
        local Player2Character = AimingUtilities.Character(Player1)
        if (Player2Character and Player2Character:FindFirstChild("Team")) then
            Team2 = Player2Character.Team.Value
        end
    end

    -- // Return
    local NoneTeamFailsafe = (Team1 == "None" or Team2 == "None") or (Team1 == nil or Team2 == nil)
    local MainCheck = Team1 ~= Team2
    return not (NoneTeamFailsafe or MainCheck)
end

-- // Return
return Aiming