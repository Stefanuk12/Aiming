--[[
    Information:

    - Inspired by https://github.com/Averiias/Universal-SilentAim/blob/main/main.lua

    You can combine methods. Simply seperate them with a comma. For example: "Target,UnitRay"
    -> Make sure you use the supported methods exactly (Capitalisation matters!)
]]

-- // Dependencies
local _, AimingPage, _ = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/GUI.lua"))()
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()("Module")
local AimingChecks = Aiming.Checks
local AimingSelected = Aiming.Selected
local AimingSettingsIgnored = Aiming.Settings.Ignored
local AimingSettingsIgnoredPlayers = Aiming.Settings.Ignored.Players
local AimingSettingsIgnoredWhitelistMode = AimingSettingsIgnored.WhitelistMode

-- // Services
local UserInputService = game:GetService("UserInputService")

-- // Config
local Configuration = {
    -- // The ones under this you may change - if you are a normal user
    Enabled = true,
    Method = "FindPartOnRay",
    FocusMode = false, -- // Stays locked on to that player only. If true then uses the silent aim keybind, if a input type is entered, then that is used
    ToggleBind = false, -- // true = Toggle, false = Hold (to enable)
    Keybind = Enum.UserInputType.MouseButton2, -- // You can also have Enum.KeyCode.E, etc.

    -- // Do not change anything below here - if you are not a normal user
    CurrentlyFocused = nil,

    MethodResolve = {
        -- // __namecall methods
        raycast = {
            Real = "Raycast",
            Metamethod = "__namecall",
            Aliases = {"raycast"}
        },
        findpartonray = {
            Real = "FindPartOnRay",
            Metamethod = "__namecall",
            Aliases = {"findPartOnRay"}
        },
        findpartonraywithwhitelist = {
            Real = "FindPartOnRayWithWhitelist",
            Metamethod = "__namecall",
            Aliases = {"findPartOnRayWithWhitelist"}
        },
        findpartonraywithignorelist = {
            Real = "FindPartOnRayWithIgnoreList",
            Metamethod = "__namecall",
            Aliases = {"findPartOnRayWithIgnoreList"}
        },

        -- // __index methods
        target = {
            Real = "Target",
            Metamethod = "__index",
            Aliases = {"target"}
        },
        hit = {
            Real = "Hit",
            Metamethod = "__index",
            Aliases = {"hit"}
        },
        x = {
            Real = "X",
            Metamethod = "__index",
            Aliases = {"x"}
        },
        y = {
            Real = "Y",
            Metamethod = "__index",
            Aliases = {"y"}
        },
        unitray = {
            Real = "UnitRay",
            Metamethod = "__index",
            Aliases = {"unitray"}
        },
    },

    ExpectedArguments = {
        FindPartOnRayWithIgnoreList = {
            ArgCountRequired = 3,
            Args = {
                "Instance", "Ray", "table", "boolean", "boolean"
            }
        },
        FindPartOnRayWithWhitelist = {
            ArgCountRequired = 3,
            Args = {
                "Instance", "Ray", "table", "boolean"
            }
        },
        FindPartOnRay = {
            ArgCountRequired = 2,
            Args = {
                "Instance", "Ray", "Instance", "boolean", "boolean"
            }
        },
        Raycast = {
            ArgCountRequired = 3,
            Args = {
                "Instance", "Vector3", "Vector3", "RaycastParams"
            }
        }
    }
}
local IsToggled = false
Aiming.SilentAim = Configuration

-- // Functions
local function CalculateDirection(Origin, Destination, Length)
    return (Destination - Origin).Unit * Length
end

-- // Validate arguments passed through namecall
local function ValidateArguments(Args, Method)
	--// Get Type Information from Method
	local TypeInformation = Configuration.ExpectedArguments[Method]
	if (not TypeInformation) then
        return false
    end

	--// Make new table for successful matches
	local Matches = 0

	-- // Go through every argument passed
	for ArgumentPosition, Argument in pairs(Args) do
		-- // Check if argument type is a certain type
		if (typeof(Argument) == TypeInformation.Args[ArgumentPosition]) then
			Matches = Matches + 1
		end
	end

	-- // Get information
	local ExpectedValid = #Args
	local GotValid = Matches

	-- // Return whether or not arguments are valid
	return ExpectedValid == GotValid
end

-- // Additional checks you can add yourself, e.g. upvalue checks
function Configuration.AdditionalCheck(metamethod, method, callingscript, ...)
    return true
end

-- // Checks if a certain method is enabled
local stringsplit = string.split
local stringlower = string.lower
local tablefind = table.find
local function IsMethodEnabled(Method, Given, PossibleMethods)
    -- // Split it all up
    PossibleMethods = PossibleMethods or stringsplit(Configuration.Method, ",")
    Given = Given or Method

    -- // Vars
    local LoweredMethod = stringlower(Method)
    local MethodData = Configuration.MethodResolve[LoweredMethod]
    if (not MethodData) then
        return false, nil
    end

    -- //
    local Matches = LoweredMethod == stringlower(Given)
    local RealMethod = MethodData.Real
    local Found = tablefind(PossibleMethods, RealMethod)

    -- // Return
    return (Matches and Found), RealMethod
end

-- // Allows you to easily toggle multiple methods on and off
function Configuration.ToggleMethod(Method, State)
    -- // Vars
    local EnabledMethods = Configuration.Method:split(",")
    local FoundI = table.find(EnabledMethods, Method)

    -- //
    if (State) then
        if (not FoundI) then
            table.insert(EnabledMethods, Method)
        end
    else
        if (FoundI) then
            table.remove(EnabledMethods, FoundI)
        end
    end

    -- // Set
    Configuration.Method = table.concat(EnabledMethods, ",")
end

-- // Modify the position/cframe, add prediction yourself (use Aiming.Selected)
function Configuration.ModifyCFrame(OnScreen)
    return OnScreen and AimingSelected.Position or AimingSelected.Part.CFrame
end

-- // Focuses a player
local Backup = {table.unpack(AimingSettingsIgnoredPlayers)}
function Configuration.FocusPlayer(Player)
    table.insert(AimingSettingsIgnoredPlayers, Player)
    AimingSettingsIgnoredWhitelistMode.Players = true
end

-- // Unfocuses a player
function Configuration.Unfocus(Player)
    -- // Find it within ignored, and remove if found
    local PlayerI = table.find(AimingSettingsIgnoredPlayers, Player)
    if (PlayerI) then
        table.remove(AimingSettingsIgnoredPlayers, PlayerI)
    end

    -- // Disable whitelist mode
    AimingSettingsIgnoredWhitelistMode.Players = false
end

-- // Unfocuses everything
function Configuration.UnfocusAll(Replacement)
    Replacement = Replacement or Backup
    AimingSettingsIgnored.Players = Replacement
    AimingSettingsIgnoredWhitelistMode.Players = false
end

-- //
function Configuration.FocusHandler()
    if (Configuration.CurrentlyFocused) then
        Configuration.Unfocus(Configuration.CurrentlyFocused)
        Configuration.CurrentlyFocused = nil
        return
    end

    if (AimingChecks.IsAvailable()) then
        Configuration.FocusPlayer(AimingSelected.Instance)
        Configuration.CurrentlyFocused = AimingSelected.Instance
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
    local FocusMode = Configuration.FocusMode
    if (CheckInput(Input, Configuration.Keybind)) then
        if (Configuration.ToggleBind) then
            IsToggled = not IsToggled
        else
            IsToggled = true
        end

        if (FocusMode == true) then
            Configuration.FocusHandler()
        end
    end

    -- // FocusMode check
    if (typeof(FocusMode) == "Enum" and CheckInput(Input, FocusMode)) then
        Configuration.FocusHandler()
    end
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessedEvent)
    -- // Make sure is not processed
    if (GameProcessedEvent) then
        return
    end

    -- // Check if matches bind
    if (CheckInput(Input, Configuration.Keybind) and not Configuration.ToggleBind) then
        IsToggled = false
    end
end)

-- // Hooks
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    -- // Vars
    local callingscript = getcallingscript()

    -- // Make sure everything is in order
    if (t:IsA("Mouse") and not checkcaller() and IsToggled and Configuration.Enabled and AimingChecks.IsAvailable()) then
        -- // Vars
        local MethodEnabled, RealMethod = IsMethodEnabled(k)

        -- // Make sure everything is in order 2
        if not (MethodEnabled and Configuration.AdditionalCheck("__index", nil, callingscript, t, RealMethod)) then
            return __index(t, k)
        end

        -- // Target
        if (RealMethod == "Target") then
            return AimingSelected.Part
        end

        -- // Hit
        if (RealMethod == "Hit") then
            return Configuration.ModifyCFrame(false)
        end

        -- // X/Y
        if (RealMethod == "X" or RealMethod == "Y") then
            return Configuration.ModifyCFrame(true)[k]
        end

        -- // UnitRay
        if (RealMethod == "UnitRay") then
            local Origin = __index(t, k).Origin
            local Direction = CalculateDirection(Origin, Configuration.ModifyCFrame(false).Position)
            return Ray.new(Origin, Direction)
        end
    end

    -- // Return
    return __index(t, k)
end)

local __namecall
__namecall = hookmetamethod(game, "__namecall", function(...)
    -- // Vars
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()
    local callingscript = getcallingscript()

    -- // Make sure everything is in order
    if (self == workspace and not checkcaller() and IsToggled and Configuration.Enabled and AimingChecks.IsAvailable()) then
        -- // Vars
        local MethodEnabled, RealMethod = IsMethodEnabled(method)

        -- // Make sure all is in order 2
        if not (MethodEnabled and ValidateArguments(args, RealMethod) and Configuration.AdditionalCheck("__namecall", RealMethod, callingscript, ...)) then
            return __namecall(...)
        end

        -- // Raycast
        if (RealMethod == "Raycast") then
            -- // Modify args
            args[3] = CalculateDirection(args[2], Configuration.ModifyCFrame(false).Position, 1000)

            -- // Return
            return __namecall(unpack(args))
        end

        -- // The rest pretty much, modify args
        local Origin = args[2].Origin
        local Direction = CalculateDirection(Origin, __index(AimingSelected.Part, "Position"), 1000)
        args[2] = Ray.new(Origin, Direction)

        -- // Return
        return __namecall(unpack(args))
    end

    -- //
    return __namecall(...)
end)


-- // GUI
local SilentAimSection = AimingPage:addSection({
    title = "Silent Aim"
})

SilentAimSection:addToggle({
    title = "Enabled",
    default = Configuration.Enabled,
    callback = function(value)
        Configuration.Enabled = value
    end
})

SilentAimSection:addToggle({
    title = "Focus Mode",
    default = Configuration.FocusMode,
    callback = function(value)
        Configuration.FocusMode = value
    end
})

SilentAimSection:addToggle({
    title = "Toggle Bind",
    default = Configuration.ToggleBind,
    callback = function(value)
        Configuration.ToggleBind = value
    end
})

SilentAimSection:addKeybind({
    title = "Keybind",
    default = Configuration.Keybind,
    changedCallback = function(value)
        Configuration.Keybind = value
    end
})

SilentAimSection:addToggle({
    title = "Focus Mode (Uses Keybind)",
    default = Configuration.FocusMode,
    callback = function(value)
        Configuration.FocusMode = value
    end
})
SilentAimSection:addKeybind({
    title = "Focus Mode (Custom Bind)",
    changedCallback = function(value)
        Configuration.FocusMode = value
    end
})

-- // Adding each method
local SilentAimMethodsSection = AimingPage:addSection({
    title = "Silent Aim: Methods"
})

for _, method in pairs(Configuration.MethodResolve) do
    SilentAimMethodsSection:addToggle({
        title = method.Real,
        default = IsMethodEnabled(method.Real),
        callback = function(value)
            Configuration.ToggleMethod(method.Real, value)
        end
    })
end