-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected

-- // Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Vars
Aiming.AimLock = {
    Enabled = true,
    Keybind = Enum.UserInputType.MouseButton2, -- // You can also have Enum.KeyCode.E, etc.
}
local IsToggled = false
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

-- // For the toggle and stuff
local function CheckInput(Input, Expected)
    if (not Input or not Expected) then
        return false
    end

    local InputType = Expected.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType"
    return Input[InputType] == Expected
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    -- // Make sure is not processed
    if (GameProcessedEvent) then
        return
    end

    -- // Check if matches bind
    if (CheckInput(Input, Settings.Keybind)) then
        if (Settings.ToggleBind) then
            IsToggled = not IsToggled
        else
            IsToggled = true
        end
    end
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
    -- // Make sure is not processed
    if (GameProcessedEvent) then
        return
    end

    -- // Check if matches bind
    if (CheckInput(Input, Settings.Keybind) and not Settings.ToggleBind) then
        IsToggled = false
    end
end)

-- // Constantly run
local BeizerCurve = Aiming.BeizerCurve
RunService:BindToRenderStep("AimLockAiming", 0, function()
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

-- // Check if GUI exists (for Linoria)
if (Aiming.GUI) then
    -- // Vars
    local AimingTab = Aiming.GUI[2]

    -- //
    local AimLockGroupBox = AimingTab:AddRightTabbox("Aim Lock")
    local MainTab = AimLockGroupBox:AddTab("Main")
    local MouseTab = AimLockGroupBox:AddTab("Mouse")
    local CameraTab = AimLockGroupBox:AddTab("Camera")

    -- //
    MainTab:AddToggle("AimLockEnabled", {
        Text = "Enabled",
        Default = Settings.Enabled,
        Tooltip = "Toggle the Aim Lock on and off",
        Callback = function(Value)
            Settings.Enabled = Value
        end
    }):AddKeyPicker("AimLockEnabledKey", {
        Default = Settings.Keybind,
        SyncToggleState = false,
        Mode = Settings.ToggleBind and "Toggle" or "Hold",
        Text = "Aim Lock",
        NoUI = false,
        Callback = function(State)
            IsToggled = State
        end
    })
    Settings.Keybind = nil

    -- //
    MouseTab:AddSlider("AimLockMouseSmoothness", {
        Text = "Smoothness",
        Tooltip = "How smooth and fast the Mouse lock is",
        Default = BeizerCurve.ManagerA.Smoothness,
        Min = 0,
        Max = 1,
        Rounding = 4,
        Callback = function(Value)
            BeizerCurve.ManagerA.Smoothness = Value
        end
    })

    MouseTab:AddToggle("AimLockMouseDrawPath", {
        Text = "Draw Path",
        Default = BeizerCurve.ManagerA.DrawPath,
        Tooltip = "Draw the aim curve when activated",
        Callback = function(Value)
            BeizerCurve.ManagerA.DrawPath = Value
        end
    })

    local function AddCurvePointSliders(Tab, ManagerName)
        -- // Vars
        local CurvePoints = BeizerCurve["Manager" .. ManagerName].CurvePoints

        -- //
        local function AddSliderXY(i)
            -- // Vars
            local PointName = "Point " .. (i == 1 and "A" or "B")
            local PointNumber = i == 1 and "first" or "second"

            -- // X Slider
            Tab:AddSlider("AimingCurvePointX" .. tostring(i), {
                Text = PointName .. ": X",
                Tooltip = "The X position of the " .. PointNumber .. " point",
                Default = CurvePoints[i].X,
                Min = 0,
                Max = 1,
                Rounding = 2,
                Callback = function(Value)
                    CurvePoints[i] = Vector2.new(Value, CurvePoints[i].Y)
                end
            })

            -- // Y Slider
            Tab:AddSlider("AimingCurvePointY" .. tostring(i), {
                Text = PointName .. ": Y",
                Tooltip = "The Y position of the " .. PointNumber .. " point",
                Default = CurvePoints[i].Y,
                Min = 0,
                Max = 1,
                Rounding = 2,
                Callback = function(Value)
                    CurvePoints[i] = Vector2.new(CurvePoints[i].X, Value)
                end
            })
        end

        AddSliderXY(1)
        AddSliderXY(2)
    end

    AddCurvePointSliders(MouseTab, "A")

    -- //
    CameraTab:AddSlider("AimLockCameraSmoothness", {
        Text = "Smoothness",
        Tooltip = "How smooth and fast the Camera lock is",
        Default = BeizerCurve.ManagerB.Smoothness,
        Min = 0,
        Max = 1,
        Rounding = 4,
        Callback = function(Value)
            BeizerCurve.ManagerB.Smoothness = Value
        end
    })

    AddCurvePointSliders(CameraTab, "B")
end

-- //
return Aiming