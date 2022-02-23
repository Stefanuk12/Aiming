--[[
    Information:

    - Frontlines (https://www.roblox.com/games/5938036553/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()
local AimingUtilities = Aiming.Utilities
local AimingChecks = Aiming.Checks

-- // Vars
local Globals = getrenv()._G.globals
local ModelInstances = Globals.gbl_sol_state.r15_models
local Teams = Globals.cli_teams
local CLIPlayers = Globals.cli_plrs
local AlivePlayers = Globals.alive_tpv_sol_ids

-- //
function AimingUtilities.Character(Player)
    -- // Get their id
    local id = table.find(CLIPlayers, Player)

    -- // Return their character
    return ModelInstances[id]
end

-- //
function AimingUtilities.TeamMatch(PlayerA, PlayerB)
    -- // Convert to ids
    local PlayerAId = table.find(CLIPlayers, PlayerA)
    local PlayerBId = table.find(CLIPlayers, PlayerB)

    -- // Make sure we have the ids
    if (not PlayerAId or not PlayerBId) then
        return false
    end

    -- // Check if team "number" matches
    return Teams[PlayerAId] == Teams[PlayerBId]
end

-- //
function AimingChecks.Health(Player)
    -- // Get id
    local PlayerId = table.find(CLIPlayers, Player)

    -- // Make sure we have the ids
    if (not PlayerId) then
        return false
    end

    -- // Check
    return table.find(AlivePlayers, PlayerId) ~= nil
end

-- // Return
return Aiming