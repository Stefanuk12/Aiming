if getgenv().AimingNPC then return getgenv().AimingNPC end

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
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local GetMouseLocation = UserInputService.GetMouseLocation
local CFramelookAt = CFrame.lookAt
local Vector2new = Vector2.new
local GetChildren = Instancenew("Part").GetChildren

-- // Vars
local AimingNPCSettings = {
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

    Ignored = {}
}
local AimingNPC = {
    ShowCredits = true,
    Settings = AimingNPCSettings,

    Signals = SignalManager.new(),

    Selected = {
        Instance = nil,
        Part = nil,
        Position = nil,
        OnScreen = false
    }
}
getgenv().AimingNPC = AimingNPC

-- // Get Settings
function AimingNPCSettings.Get(...)
    -- // Vars
    local args = {...}
    local argsCount = #args
    local Identifier = args[argsCount]

    -- // Navigate through settings
    local Found = AimingNPCSettings
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

    for _, SignalName in pairs(SignalNames) do
        AimingNPC.Signals:Create(SignalName)
    end
end

-- // Create circle
local circle = AimingNPCSettings.FOVSettings.Circle
circle.Transparency = 1
circle.Thickness = 2
circle.Color = AimingNPCSettings.FOVSettings.Colour
circle.Filled = false

-- // Update
function AimingNPC.UpdateFOV()
    -- // Make sure the circle exists
    if not (circle) then
        return
    end

    -- // Vars
    local MousePosition = GetMouseLocation(UserInputService)
    local Settings = AimingNPCSettings.FOVSettings

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
AimingNPC.Utilities = Utilities
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

    -- //
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
            local RaycastIgnore = AimingNPCSettings.RaycastIgnore
            raycastParams.FilterDescendantsInstances = (typeof(RaycastIgnore) == "function" and RaycastIgnore() or RaycastIgnore) or {Character, CurrentCamera}

            -- // Cast ray
            local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

            -- // Make sure we get a result
            if (Result) then
                -- // Vars
                local PartHit = Result.Instance

                -- //
                if (not PartHit) then
                    return false
                else
                    return IsDescendantOf(PartHit, PartDescendant)
                end
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

    -- //
    function Utilities.GetNPCs()
        return {} -- // e.g. workspace.NPCs:GetChildren()
    end
end

-- // Ignored
local Ignored = {}
AimingNPC.Ignored = Ignored
do
    -- // Vars
    local IgnoredSettings = AimingNPC.Settings.Ignored
end

-- // Checks
local Checks = {}
AimingNPC.Checks = Checks
do
    -- // Check Health
    function Checks.Health(NPC)
        -- // Get Humanoid
        local Humanoid = FindFirstChildWhichIsA(NPC, "Humanoid")

        -- // Get Health
        local Health = (Humanoid and Humanoid.Health or 0)

        -- //
        return Health > 0
    end

    -- // Custom Check Function
    function Checks.Custom(NPC)
        return true
    end

    -- // Check if the module is enabled and we have targets
    function Checks.IsAvailable()
        return (AimingNPC.Enabled == true and AimingNPC.Selected.Instance)
    end
end

-- // Get Closest Target Part
function AimingNPC.GetClosestTargetPartToCursor(NPC)
    local TargetParts = AimingNPCSettings.TargetPart

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
            TargetPart = FindFirstChild(NPC, TargetPart)
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
            -- // Loop through NPC children
            for _, v in pairs(GetChildren(NPC)) do
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
        for _, TargetPartName in pairs(TargetParts) do
            CheckTargetPart(TargetPartName)
        end
    end

    -- //
    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

-- //
function AimingNPC.GetClosestToCursor()
    -- // Vars
    local TargetPart = nil
    local ClosestInstance = nil
    local PartPosition = nil
    local PartOnScreen = nil
    local Chance = Utilities.CalculateChance(AimingNPCSettings.HitChance)
    local ShortestDistance = circle.Radius
    local AimingSelected = AimingNPC.Selected

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
    for _, NPC in pairs(Utilities.GetNPCs()) do
        -- // Make sure NPC exists
        if (NPC) then
            -- // Vars
            local TargetPartTemp, PartPositionTemp, PartPositionOnScreenTemp, Magnitude = AimingNPC.GetClosestTargetPartToCursor(NPC)

            -- // Check if part exists, health and custom
            if (TargetPartTemp and Checks.Health(NPC) and Checks.Custom(NPC)) then
                -- // Check if is in FOV
                if (Magnitude < ShortestDistance) then
                    -- // Check if Visible
                    if (AimingNPCSettings.VisibleCheck and not Utilities.IsPartVisible(TargetPartTemp, NPC)) then continue end

                    -- // Set vars
                    ClosestInstance = NPC
                    ShortestDistance = Magnitude
                    TargetPart = TargetPartTemp
                    PartPosition = PartPositionTemp
                    PartOnScreen = PartPositionOnScreenTemp
                end
            end
        end
    end

    -- // Firing changed signals
    if (AimingSelected.Instance ~= ClosestInstance) then
        AimingNPC.Signals:Fire("InstanceChanged", ClosestInstance)
    end
    if (AimingSelected.Part ~= TargetPart) then
        AimingNPC.Signals:Fire("PartChanged", TargetPart)
    end
    if (AimingSelected.Position ~= PartPosition) then
        AimingNPC.Signals:Fire("PartPositionChanged", PartPosition)
    end
    if (AimingSelected.OnScreen ~= PartOnScreen) then
        AimingNPC.Signals:Fire("OnScreenChanged", PartOnScreen)
    end

    -- // End
    AimingSelected.Instance = ClosestInstance
    AimingSelected.Part = TargetPart
    AimingSelected.Position = PartPosition
    AimingSelected.OnScreen = PartOnScreen
end

-- // Beizer Aim Curves
AimingNPC.BeizerCurve = {}
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
    AimingNPC.BeizerCurve.ManagerA = ManagerA
    AimingNPC.BeizerCurve.ManagerB = ManagerB

    AimingNPC.BeizerCurve.AimTo = function(...)
        ManagerA:ChangeData(...)
    end
    AimingNPC.BeizerCurve.AimToB = function(...)
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
    AimingNPC.UpdateFOV()
    AimingNPC.GetClosestToCursor()
end)

-- // Credits (by disabling this and not including your own way of crediting within the script, e.g. credits tab, is violating the license agreement. Beware!)
if (AimingNPC.ShowCredits) then
    messagebox("Thanks to Stefanuk12 for their Aiming Module (v2, NPC)", "Credits", 0)
end

-- //
return AimingNPC

-- // If you want the examples, look at the docs.