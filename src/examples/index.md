# Index Example
!!! warning "Compatibility warning"
    This will work on some games that **purely** use the Mouse's `Hit` and `Target` properties.

```lua
-- // Load Aiming Module
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()()
local AimingSelected = Aiming.Selected
local AimingChecks = Aiming.Checks

-- // Hook
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    -- // Check if it trying to get our mouse's hit or target
    if (t:IsA("Mouse") and (k == "Hit" or k == "Target")) then
        -- // If we can use the silent aim
        if (AimingChecks.IsAvailable()) then
            -- // Vars
            local TargetPart = AimingSelected.Part

            -- // Return modded val
            return (k == "Hit" and TargetPart.CFrame or TargetPart)
        end
    end

    -- // Return
    return __index(t, k)
end)
```