if getgenv().Aiming then return getgenv().Aiming end

-- // Dependencies
local SignalManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua"))()
local BeizerManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/BeizerManager.lua"))()

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Vars
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- // Optimisation Vars (ugly)
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert
local GetMouseLocation = UserInputService.GetMouseLocation
local CFramelookAt = CFrame.lookAt
local Vector2new = Vector2.new
local GetChildren = Instancenew("Part").GetChildren

-- // Vars
local AimingSettings = {
    Enabled = true,
    VisibleCheck = true,
    HitChance = 100,
    TargetPart = {"Head", "HumanoidRootPart"},
    RaycastIgnore = nil,

    FOVSettings = {
        Circle = Drawingnew("Circle"),
        Enabled = true,
        Scale = 60,
        Sides = 12,
        Colour = Color3fromRGB(231, 84, 128)
    },

    Ignored = {
        Teams = {
            {
                Team = LocalPlayer.Team,
                TeamColor = LocalPlayer.TeamColor,
            },
        },
        IgnoreLocalTeam = true,

        Players = {
            LocalPlayer,
            91318356
        }
    }
}
local Aiming = {
    ShowCredits = true,
    Settings = AimingSettings,

    Signals = SignalManager.new(),

    Selected = {
        Instance = nil,
        Part = nil,
        Position = nil,
        OnScreen = false
    }
}
getgenv().Aiming = Aiming

-- // Get Settings
function AimingSettings.Get(...)
    -- // Vars
    local args = {...}
    local argsCount = #args
    local Identifier = args[argsCount]

    -- // Navigate through settings
    local Found = AimingSettings
    for i = 1, argsCount - 1 do
        -- // Vars
        local v = args[i]

        -- // Make sure it exists
        if (v) then
            -- // Set
            Found = Found[v]
        end
    end

    -- // Return
    return Found[Identifier]
end

-- // Create signals
do
    local SignalNames = {"InstanceChanged", "PartChanged", "PartPositionChanged", "OnScreenChanged"}

    for _, SignalName in ipairs(SignalNames) do
        Aiming.Signals:Create(SignalName)
    end
end

-- // Create circle
local circle = AimingSettings.FOVSettings.Circle
circle.Transparency = 1
circle.Thickness = 2
circle.Color = AimingSettings.FOVSettings.Colour
circle.Filled = false

-- // Update
function Aiming.UpdateFOV()
    -- // Make sure the circle exists
    if not (circle) then
        return
    end

    -- // Vars
    local MousePosition = GetMouseLocation(UserInputService)
    local Settings = AimingSettings.FOVSettings

    -- // Set Circle Properties
    circle.Visible = Settings.Enabled
    circle.Radius = (Settings.Scale * 3)
    circle.Position = MousePosition
    circle.NumSides = Settings.Sides
    circle.Color = Settings.Colour

    -- // Return circle
    return circle
end

-- // Utilities
local Utilities = {}
Aiming.Utilities = Utilities
do
    -- // Chance
    function Utilities.CalculateChance(Percentage)
        -- // Floor the percentage
        Percentage = mathfloor(Percentage)

        -- // Get the chance
        local chance = mathfloor(Randomnew().NextNumber(Randomnew(), 0, 1) * 100) / 100

        -- // Return
        return chance <= Percentage / 100
    end

    -- // Get Character
    function Utilities.Character(Player)
        return Player.Character
    end

    -- // Check if a part is visible (to camera)
    function Utilities.IsPartVisible(Part, PartDescendant)
        -- // Vars
        local Character = Utilities.Character(LocalPlayer)
        local Origin = CurrentCamera.CFrame.Position
        local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)

        -- //
        if (OnScreen) then
            -- // Vars
            local raycastParams = RaycastParamsnew()
            raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
            local RaycastIgnore = AimingSettings.RaycastIgnore
            raycastParams.FilterDescendantsInstances = (typeof(RaycastIgnore) == "function" and RaycastIgnore() or RaycastIgnore) or {Character, CurrentCamera}

            -- // Cast ray
            local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

            -- // Make sure we get a result
            if (Result) then
                -- // Vars
                local PartHit = Result.Instance
                local Visible = PartHit == Part or IsDescendantOf(PartHit, PartDescendant)

                -- // Return
                return Visible
            end
        end

        -- // Return
        return false
    end

    -- // Get the Direction, Normal and Material
    function Utilities.Raycast(Origin, Destination, UnitMultiplier)
        if (typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3") then
            -- // Handling
            if (not UnitMultiplier) then UnitMultiplier = 1 end

            -- // Vars
            local Direction = (Destination - Origin).Unit * UnitMultiplier
            local Result = Raycast(Workspace, Origin, Direction)

            -- // Make sure we have a result
            if (Result) then
                local Normal = Result.Normal
                local Material = Result.Material

                return Direction, Normal, Material
            end
        end

        -- // Return
        return nil
    end

    -- //
    function Utilities.SetCameraCFrame(CFr)
        CurrentCamera.CFrame = CFr
    end

    -- //
    function Utilities.CameraLookAt(Position)
        local LookAt = CFramelookAt(CurrentCamera.CFrame.Position, Position)
        Utilities.SetCameraCFrame(LookAt)
    end
end

-- // Ignored
local Ignored = {}
Aiming.Ignored = Ignored
do
    -- // Vars
    local IgnoredSettings = Aiming.Settings.Ignored

    -- // Ignore player
    function Ignored.IgnorePlayer(Player)
        -- // Vars
        local IgnoredPlayers = IgnoredSettings.Players

        -- // Find player in table
        for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
            -- // Make sure player matches
            if (IgnoredPlayer == Player) then
                return false
            end
        end

        -- // Blacklist player
        tableinsert(IgnoredPlayers, Player)
        return true
    end

    -- // Unignore Player
    function Ignored.UnIgnorePlayer(Player)
        -- // Vars
        local IgnoredPlayers = IgnoredSettings.Players

        -- // Find player in table
        for i, IgnoredPlayer in ipairs(IgnoredPlayers) do
            -- // Make sure player matches
            if (IgnoredPlayer == Player) then
                -- // Remove from ignored
                tableremove(IgnoredPlayers, i)
                return true
            end
        end

        -- //
        return false
    end

    -- // Ignore team
    function Ignored.IgnoreTeam(Team, TeamColor)
        -- // Vars
        local IgnoredTeams = IgnoredSettings.Teams

        -- // Find team in table
        for _, IgnoredTeam in ipairs(IgnoredTeams) do
            -- // Make sure team matches
            if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
                return false
            end
        end

        -- // Ignore team
        tableinsert(IgnoredTeams, {Team, TeamColor})
        return true
    end

    -- // Unignore team
    function Ignored.UnIgnoreTeam(Team, TeamColor)
        -- // Vars
        local IgnoredTeams = IgnoredSettings.Teams

        -- // Find team in table
        for i, IgnoredTeam in ipairs(IgnoredTeams) do
            -- // Make sure team matches
            if (IgnoredTeam.Team == Team and IgnoredTeam.TeamColor == TeamColor) then
                -- // Remove
                tableremove(IgnoredTeams, i)
                return true
            end
        end

        -- // Return
        return false
    end

    -- // Check teams
    function Ignored.IsIgnoredTeam(Player)
        -- // Vars
        local IgnoredTeams = IgnoredSettings.Teams

        -- // Check for others
        if (Ignored.IgnoreLocalTeam) then
            return (LocalPlayer.Team == Player.Team and LocalPlayer.TeamColor == Player.TeamColor)
        end

        -- // Check if team is ignored
        for _, IgnoredTeam in ipairs(IgnoredTeams) do
            -- // Make sure team matches
            if (Player.Team == IgnoredTeam.Team and Player.TeamColor == IgnoredTeam.TeamColor) then
                return true
            end
        end

        -- // Return
        return false
    end

    -- // Check if player (and team) is ignored
    function Ignored.IsIgnored(Player)
        -- // Vars
        local IgnoredPlayers = IgnoredSettings.Players

        -- // Loop
        for _, IgnoredPlayer in ipairs(IgnoredPlayers) do
            -- // Check if Player Id
            if (typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer) then
                return true
            end

            -- // Normal Player Instance
            if (IgnoredPlayer == Player) then
                return true
            end
        end

        -- // Team check
        return Ignored.IsIgnoredTeam(Player)
    end

    -- // Toggle team check
    function Ignored.TeamCheck(Toggle)
        if (Toggle) then
            return Ignored.IgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
        end

        return Ignored.UnIgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
    end
end

-- // Checks
local Checks = {}
Aiming.Checks = Checks
do
    -- // Check Health
    function Checks.Health(Player)
        -- // Get Humanoid
        local Character = Utilities.Character(Player)
        local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

        -- // Get Health
        local Health = (Humanoid and Humanoid.Health or 0)

        -- //
        return Health > 0
    end

    -- // Custom Check Function
    function Checks.Custom(Player)
        return true
    end

    -- // Check if the module is enabled and we have targets
    function Checks.IsAvailable()
        return (AimingSettings.Enabled == true and Aiming.Selected.Instance)
    end
end

-- // Get Closest Target Part
function Aiming.GetClosestTargetPartToCursor(Character)
    local TargetParts = AimingSettings.TargetPart

    -- // Vars
    local ClosestPart = nil
    local ClosestPartPosition = nil
    local ClosestPartOnScreen = false
    local ClosestPartMagnitudeFromMouse = nil
    local ShortestDistance = 1/0

    -- //
    local function CheckTargetPart(TargetPart)
        -- // Convert string -> Instance
        if (typeof(TargetPart) == "string") then
            TargetPart = FindFirstChild(Character, TargetPart)
        end

        -- // Make sure we have a target
        if not (TargetPart) then
            return
        end

        -- // Get the length between Mouse and Target Part (on screen)
        local PartPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
        PartPos = Vector2new(PartPos.X, PartPos.Y)

        local MousePosition = GetMouseLocation(UserInputService)
        local GuiInset = GetGuiInset(GuiService)
        local AccountedPos = PartPos - GuiInset

        local Magnitude = (AccountedPos - MousePosition).Magnitude

        -- //
        if (Magnitude < ShortestDistance) then
            ClosestPart = TargetPart
            ClosestPartPosition = PartPos
            ClosestPartOnScreen = onScreen
            ClosestPartMagnitudeFromMouse = Magnitude
            ShortestDistance = Magnitude
        end
    end

    -- // String check
    if (typeof(TargetParts) == "string") then
        -- // Check if it all
        if (TargetParts == "All") then
            -- // Loop through character children
            for _, v in ipairs(GetChildren(Character)) do
                -- // See if it a part
                if (v:IsA("BasePart")) then
                    -- // Check it
                    CheckTargetPart(v)
                end
            end
        else
            -- // Individual
            CheckTargetPart(TargetParts)
        end
    end

    -- //
    if (typeof(TargetParts) == "table") then
        -- // Loop through all target parts and check them
        for _, TargetPartName in ipairs(TargetParts) do
            CheckTargetPart(TargetPartName)
        end
    end

    -- //
    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

-- //
function Aiming.GetClosestToCursor()
    -- // Vars
    local TargetPart = nil
    local ClosestPlayer = nil
    local PartPosition = nil
    local PartOnScreen = nil
    local Chance = Utilities.CalculateChance(AimingSettings.HitChance)
    local ShortestDistance = circle.Radius
    local AimingSelected = Aiming.Selected

    -- // See if it passed the chance
    if (not Chance) then
        -- // Set
        AimingSelected.Instance = LocalPlayer
        AimingSelected.Part = nil
        AimingSelected.Position = nil
        AimingSelected.OnScreen = false

        -- // Return
        return
    end

    -- // Loop through all players
    for _, Player in ipairs(GetPlayers(Players)) do
        -- // Get Character
        local Character = Utilities.Character(Player)

        -- // Make sure isn't ignored and Character exists
        if (Ignored.IsIgnored(Player) == false and Character) then
            -- // Vars
            local TargetPartTemp, PartPositionTemp, PartPositionOnScreenTemp, Magnitude = Aiming.GetClosestTargetPartToCursor(Character)

            -- // Check if part exists, health and custom
            if (TargetPartTemp and Checks.Health(Player) and Checks.Custom(Player)) then
                -- // Check if is in FOV
                if (Magnitude < ShortestDistance) then
                    -- // Check if Visible
                    if (AimingSettings.VisibleCheck and not Utilities.IsPartVisible(TargetPartTemp, Character)) then continue end

                    -- // Set vars
                    ClosestPlayer = Player
                    ShortestDistance = Magnitude
                    TargetPart = TargetPartTemp
                    PartPosition = PartPositionTemp
                    PartOnScreen = PartPositionOnScreenTemp
                end
            end
        end
    end

    -- // Firing changed signals
    if (AimingSelected.Instance ~= ClosestPlayer) then
        Aiming.Signals:Fire("InstanceChanged", ClosestPlayer)
    end
    if (AimingSelected.Part ~= TargetPart) then
        Aiming.Signals:Fire("PartChanged", TargetPart)
    end
    if (AimingSelected.Position ~= PartPosition) then
        Aiming.Signals:Fire("PartPositionChanged", PartPosition)
    end
    if (AimingSelected.OnScreen ~= PartOnScreen) then
        Aiming.Signals:Fire("OnScreenChanged", PartOnScreen)
    end

    -- // End
    AimingSelected.Instance = ClosestPlayer
    AimingSelected.Part = TargetPart
    AimingSelected.Position = PartPosition
    AimingSelected.OnScreen = PartOnScreen
end

-- // Beizer Aim Curves
Aiming.BeizerCurve = {}
do
    -- // Information
    --[[
        A deals with mouse movements
        B deals with custom movements, e.g. camera
    ]]

    -- // Vars
    local ManagerA = BeizerManager.new()
    local ManagerB = BeizerManager.new()

    -- // Functions
    Aiming.BeizerCurve.ManagerA = ManagerA
    Aiming.BeizerCurve.ManagerB = ManagerB

    Aiming.BeizerCurve.AimTo = function(...)
        ManagerA:ChangeData(...)
    end
    Aiming.BeizerCurve.AimToB = function(...)
        ManagerB:ChangeData(...)
    end

    -- // Convert B to Camera Mode
    ManagerB:CameraMode()

    -- // Convert function to use Aiming
    ManagerB.Function = function(Pitch, Yaw)
        local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
        Utilities.SetCameraCFrame(CFrame.new(CurrentCamera.CFrame.Position) * RotationMatrix)
    end

    -- // Start
    ManagerA:Start()
    ManagerB:Start()
end

-- // Heartbeat Function
Heartbeat:Connect(function()
    Aiming.UpdateFOV()
    Aiming.GetClosestToCursor()
end)

task.delay(1, function()
    -- // Credits (by disabling this and not including your own way of crediting within the script, e.g. credits tab, is violating the license agreement. Beware!)
    if (Aiming.ShowCredits) then
        messagebox("Thanks to Stefanuk12 for their Aiming Module (v2, Module)", "Credits", 0)
    end
end)

-- //
return Aiming

-- // If you want the examples, look at the docs.