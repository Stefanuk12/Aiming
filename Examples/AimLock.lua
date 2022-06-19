-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected
local AimingSettingsIgnored = Aiming.Settings.Ignored
local AimingSettingsIgnoredPlayers = Aiming.Settings.Ignored.Players
local AimingSettingsIgnoredWhitelistMode = AimingSettingsIgnored.WhitelistMode

-- // Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Vars
Aiming.AimLock = {
    Enabled = true,
    FocusMode = false, -- // Stays locked on to that player only. If true then uses the aim lock keybind, if a input type is entered, then that is used
    CurrentlyFocused = nil,
    ToggleBind = false, -- // true = Toggle, false = Hold (to enable)
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

-- // Focuses a player
local Backup = {table.unpack(AimingSettingsIgnoredPlayers)}
function Settings.FocusPlayer(Player)
    table.insert(AimingSettingsIgnoredPlayers, Player)
    AimingSettingsIgnoredWhitelistMode.Players = true
end

-- // Unfocuses a player
function Settings.Unfocus(Player)
    -- // Find it within ignored, and remove if found
    local PlayerI = table.find(AimingSettingsIgnoredPlayers, Player)
    if (PlayerI) then
        table.remove(AimingSettingsIgnoredPlayers, PlayerI)
    end

    -- // Disable whitelist mode
    AimingSettingsIgnoredWhitelistMode.Players = false
end

-- // Unfocuses everything
function Settings.UnfocusAll(Replacement)
    Replacement = Replacement or Backup
    AimingSettingsIgnored.Players = Replacement
    AimingSettingsIgnoredWhitelistMode.Players = false
end

-- //
function Settings.FocusHandler()
    if (Settings.CurrentlyFocused) then
        Settings.Unfocus(Settings.CurrentlyFocused)
        Settings.CurrentlyFocused = nil
        return
    end

    if (AimingChecks.IsAvailable()) then
        Settings.FocusPlayer(AimingSelected.Instance)
        Settings.CurrentlyFocused = AimingSelected.Instance
    end
end

-- // For the toggle and stuff
local function CheckInput(Input, Expected)
    local InputType = Expected.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType"
    return Input[InputType] == Expected
end

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
    -- // Make sure is not processed
    if (GameProcessedEvent) then
        return
    end

    -- // Check if matches bind
    local FocusMode = Settings.FocusMode
    if (CheckInput(Input, Settings.Keybind)) then
        if (Settings.ToggleBind) then
            IsToggled = not IsToggled
        else
            IsToggled = true
        end

        if (FocusMode == true) then
            Settings.FocusHandler()
        end
    end

    -- // FocusMode check
    if (typeof(FocusMode) == "Enum" and CheckInput(Input, FocusMode)) then
        Settings.FocusHandler()
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

-- // Check if GUI exists
if (Aiming.GUI) then
    -- // Vars
    local UI = Aiming.GUI[1]

    -- //
    local AimLockPage = UI:addPage({
        title = "Aim Lock",
        icon = 5012544693
    })
    AimLockPage:setOrderPos(2)

    -- //
    local MainSection = AimLockPage:addSection({
        title = "Main"
    })

    MainSection:addToggle({
        title = "Enabled",
        default = Settings.Enabled,
        callback = function(value)
            Settings.Enabled = value
        end
    })

    MainSection:addKeybind({
        title = "Keybind",
        default = Settings.Keybind,
        changedCallback = function(value)
            Settings.Keybind = value
        end
    })

    MainSection:addToggle({
        title = "Focus Mode (Uses Keybind)",
        default = Settings.FocusMode,
        callback = function(value)
            Settings.FocusMode = value
        end
    })
    MainSection:addKeybind({
        title = "Focus Mode (Custom Bind)",
        changedCallback = function(value)
            Settings.FocusMode = value
        end
    })

    MainSection:addToggle({
        title = "Toggle Bind",
        default = Settings.ToggleBind,
        callback = function(value)
            Settings.ToggleBind = value
        end
    })

    -- //
    local BeizerA = AimLockPage:addSection({
        title = "Beizer A: Mouse"
    })

    BeizerA:addSlider({
        title = "Smoothness",
        min = 0,
        max = 1,
        precision = 4,
        default = BeizerCurve.ManagerA.Smoothness,
        callback = function(value)
            BeizerCurve.ManagerA.Smoothness = value
        end
    })

    BeizerA:addToggle({
        title = "Draw Path",
        default = BeizerCurve.ManagerA.DrawPath,
        callback = function(value)
            BeizerCurve.ManagerA.DrawPath = value
        end
    })

    local function AddCurvePointSliders(Section, ManagerName)
        -- // Vars
        local CurvePoints = BeizerCurve["Manager" .. ManagerName].CurvePoints

        -- //
        local function AddSliderXY(i)
            -- // Vars
            local PointName = "Point " .. (i == 1 and "A" or "B")

            -- // X Slider
            Section:addSlider({
                title = PointName .. ": X",
                min = 0,
                max = 1,
                precision = 2,
                default = CurvePoints[i].X,
                callback = function(value)
                    CurvePoints[i] = Vector2.new(value, CurvePoints[i].Y)
                end
            })

            -- // Y Slider
            Section:addSlider({
                title = PointName .. ": Y",
                min = 0,
                max = 1,
                precision = 2,
                default = CurvePoints[i].Y,
                callback = function(value)
                    CurvePoints[i] = Vector2.new(CurvePoints[i].X, value)
                end
            })
        end

        AddSliderXY(1)
        AddSliderXY(2)
    end

    AddCurvePointSliders(BeizerA, "A")

    -- //
    local BeizerB = AimLockPage:addSection({
        title = "Beizer B: Camera"
    })

    BeizerB:addSlider({
        title = "Smoothness",
        min = 0,
        max = 1,
        precision = 4,
        default = BeizerCurve.ManagerB.Smoothness,
        callback = function(value)
            BeizerCurve.ManagerB.Smoothness = value
        end
    })

    AddCurvePointSliders(BeizerB, "B")
end

-- //
return Aiming