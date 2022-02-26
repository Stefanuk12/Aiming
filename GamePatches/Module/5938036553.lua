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
local fpv_sol_instances = Globals.fpv_sol_instances

-- //
local function GrabPlayerId(Player)
    -- // Loop through all the players
    for i, v in pairs(CLIPlayers) do
        -- // See if the players match
        if (v == Player) then
            -- // Return their player id
            return i
        end
    end
end

-- //
function AimingUtilities.Character(Player)
    -- // Get their id
    local id = GrabPlayerId(Player)

    -- // Return their character
    return ModelInstances[id]
end

-- //
function AimingUtilities.TeamMatch(PlayerA, PlayerB)
    -- // Convert to ids
    local PlayerAId = GrabPlayerId(PlayerA)
    local PlayerBId = GrabPlayerId(PlayerB)

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
    local PlayerId = GrabPlayerId(Player)

    -- // Make sure we have the ids
    if (not PlayerId) then
        return false
    end

    -- // Check
    return table.find(AlivePlayers, PlayerId) ~= nil
end

-- //
function Aiming.BeizerCurve.ManagerB.Function(Pitch, Yaw)
    local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
    local Eye = fpv_sol_instances.eye
    Eye.CFrame = CFrame.new(Eye.CFrame.Position) * RotationMatrix
end

-- // Return
return Aiming