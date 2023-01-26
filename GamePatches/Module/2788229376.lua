--[[
    Information:

    - Da Hood (https://www.roblox.com/games/2788229376/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()

-- // Disable Team Check
Aiming.Settings.Ignored.IgnoreLocalTeam = false

-- // Downed Check
local AimingChecks = Aiming.Checks
function AimingChecks.Custom(Character)
    -- // Check if downed
    local KOd = Character:WaitForChild("BodyEffects"):FindFirstChild("K.O")
    local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    -- // Check B
    if ((KOd and KOd.Value) or Grabbed) then
        return false
    end

    -- //
    return true
end

-- // Return
return Aiming