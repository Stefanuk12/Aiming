-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")

-- // Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Vars
local AimingSelected = Aiming.Selected
local AimingChecks = Aiming.Checks

Aiming.AimLock = {
    Enabled = true,
    Keybind = Enum.UserInputType.MouseButton2, -- // You can also have Enum.KeyCode.E, etc.
}
local Settings = Aiming.AimLock

-- //
function Settings.ShouldUseCamera()
    -- //
    return (UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter)
end

-- // Allows for custom
function Settings.AimLockPosition(CameraMode)
    local Position = CameraMode and AimingSelected.Part.Position or AimingSelected.Position
    return Position, {}
end

-- // Constantly run
local BeizerCurve = Aiming.BeizerCurve
RunService:BindToRenderStep("AimLockAiming", 0, function()
    -- // Vars
    local Keybind = Settings.Keybind
    local IsToggled = false

    -- // Check if toggled
    if (Keybind.EnumType == Enum.KeyCode) then
        IsToggled = UserInputService:IsKeyDown(Keybind)
    else
        IsToggled = UserInputService:IsMouseButtonPressed(Keybind)
    end

    -- // Vars
    local CameraMode = Settings.ShouldUseCamera()
    local Manager = CameraMode and BeizerCurve.ManagerB or BeizerCurve.ManagerA

    -- // Make sure key (or mouse button) is down
    if (Settings.Enabled and IsToggled and AimingChecks.IsAvailable()) then
        -- // Vars
        local Position, BeizerData = Settings.AimLockPosition(CameraMode)
        BeizerData.TargetPosition = Position

        -- // Aim
        Manager:ChangeData(BeizerData)
    else
        -- // Stop any aim
        Manager:StopCurrent()
    end
end)

-- //
return Aiming