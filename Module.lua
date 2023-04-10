if getgenv().Aiming then return getgenv().Aiming end

-- // Dependencies (these take a long time to initially load due to the HttpGet, you can inline them for a faster, instant load time)
local function FastHttpGet(URL)
    if (syn and syn.request) then
        return syn.request({Url = URL}).Body
    end
    return game:HttpGet(URL)
end
local function FastLoadDependencies(...) -- credits to 735432575140757605
    -- // Vars
    local Loaded = {}
    local Arguments = {...}
    local Amount = #Arguments

    -- // Loop through each argument
    for i, v in pairs(Arguments) do
        -- // Load and set the loaded script
        task.spawn(function()
            Loaded[i] = loadstring(FastHttpGet(v))()
        end)
    end

    -- // Wait until we loaded each dependency
    repeat task.wait() until #Loaded == Amount

    -- // Return all of the dependencies as a tuple
    return table.unpack(Loaded)
end
local SignalManager, BeizerManager, KeybindHandler = FastLoadDependencies(
    "https://raw.githubusercontent.com/Stefanuk12/Signal/main/Manager.lua",
    "https://raw.githubusercontent.com/Stefanuk12/Aiming/main/BeizerManager.lua",
    "https://raw.githubusercontent.com/Stefanuk12/ROBLOX/master/Universal/KeybindHandler.lua"
)

-- // Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- // Vars
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer

-- // Optimisation Vars (ugly)
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Randomnew = Random.new
local mathfloor = math.floor
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local WorldToViewportPoint = Instancenew("Camera").WorldToViewportPoint
local IsAncestorOf = Instancenew("Part").IsAncestorOf
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
    InternalEnabled = false, -- // Do not modify, for internal use only
    GUIAutoShow = true,

    VisibleCheck = true,
    TeamCheck = true,
    PlayerCheck = true,
    FriendCheck = true,
    ForcefieldCheck = true,
    HealthCheck = true,
    InvisibleCheck = true,
    IgnoredCheck = true,

    HitChance = 100,
    TargetPart = {"Head", "HumanoidRootPart"},
    RaycastIgnore = nil,
    Offset = Vector2new(),
    MaxDistance = 1000,

    LockMode = {
        Enabled = false,

        InternalEnabled = false, -- // Do not modify, for internal use only
        LockedPlayer = nil, -- // Do not modify, for internal use only

        UnlockBind = Enum.KeyCode.X
    },

    FOVSettings = {
        Circle = Drawingnew("Circle"),
        Enabled = true,
        Visible = true,
        Type = "Static",
        Scale = 60,
        Sides = 12,
        Colour = Color3fromRGB(231, 84, 128),
        DynamicFOVConstant = 25,

        FollowSelected = false
    },

    DeadzoneFOVSettings = {
        Circle = Drawingnew("Circle"),
        Enabled = false,
        Visible = true,
        Scale = 10,
        Sides = 30,
        Colour = Color3fromRGB(83, 31, 46),
    },

    TracerSettings = {
        Tracer = Drawingnew("Line"),
        Enabled = true,
        Colour = Color3fromRGB(231, 84, 128)
    },

    Ignored = {
        WhitelistMode = {
            Players = false,
            Teams = false
        },

        Teams = {},
        IgnoreLocalTeam = true,

        Players = {
            LocalPlayer,
            91318356
        }
    }
}
local Aiming = {
    Loaded = false,
    ShowCredits = true,
    Settings = AimingSettings,

    Signals = SignalManager.new(),

    Selected = {
        Instance = nil,
        Part = nil,
        Position = nil,
        Velocity = nil, -- // You might need set the Y velocity to `0` or it bugs out /shrug
        OnScreen = false
    }
}
getgenv().Aiming = Aiming

-- // Set RaycastIgnore
function AimingSettings.RaycastIgnore()
    return {Aiming.Utilities.Character(LocalPlayer), Aiming.Utilities.GetCurrentCamera()}
end

-- // Keep track of current friends
local Friends = {}

-- // Loop through every player
for _, Player in ipairs(Players:GetPlayers()) do
    -- // If friends, add to table
    if (Player ~= LocalPlayer and LocalPlayer:IsFriendsWith(Player.UserId)) then
        table.insert(Friends, Player)
    end
end

-- // See when a new player joins
Players.PlayerAdded:Connect(function(Player)
    -- // If friends, add to table
    if (LocalPlayer:IsFriendsWith(Player.UserId)) then
        table.insert(Friends, Player)
    end
end)

-- // See when player leaves (not needed because of GC but just in case)
Players.PlayerRemoving:Connect(function(Player)
    -- // If in friends table, remove
    local i = table.find(Friends, Player)
    if (i) then
        table.remove(Friends, i)
    end
end)

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

    for _, SignalName in pairs(SignalNames) do
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
    local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
    local Settings = AimingSettings.FOVSettings

    -- // Set Circle Properties
    circle.Position = AimingSettings.FOVSettings.FollowSelected and Aiming.Selected.Position or MousePosition
    circle.NumSides = Settings.Sides
    circle.Color = Settings.Colour

    -- // Set radius based upon type
    circle.Visible = Settings.Enabled and Settings.Visible
    if (Settings.Type == "Dynamic") then
        -- // Check if we have a target
        if (not Aiming.Checks.IsAvailable()) then
            circle.Radius = (Settings.Scale * 3)
            return circle
        end

        -- // Grab which part we are going to use
        local TargetPart = Aiming.Selected.Part
        local PartInstance = Aiming.Utilities.Character(LocalPlayer)[TargetPart.Name]

        -- // Calculate distance, set
        local Distance = (PartInstance.Position - TargetPart.Position).Magnitude
        circle.Radius = math.round((Settings.DynamicFOVConstant / Distance) * 1000)
    else
        circle.Radius = (Settings.Scale * 3)
    end

    -- // Return circle
    return circle
end

-- // Update
local deadzonecircle = AimingSettings.DeadzoneFOVSettings.Circle
circle.Transparency = 1
circle.Thickness = 2
circle.Color = AimingSettings.DeadzoneFOVSettings.Colour
circle.Filled = false
function Aiming.UpdateDeadzoneFOV()
    -- // Make sure the circle exists
    if not (deadzonecircle) then
        return
    end

    -- // Vars
    local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
    local Settings = AimingSettings.DeadzoneFOVSettings

    -- // Set Circle Properties
    deadzonecircle.Visible = Settings.Enabled and Settings.Visible
    deadzonecircle.Radius = (Settings.Scale * 3)
    deadzonecircle.Position = MousePosition
    deadzonecircle.NumSides = Settings.Sides
    deadzonecircle.Color = Settings.Colour

    -- // Return circle
    return deadzonecircle
end

-- // Update
local tracer = AimingSettings.TracerSettings.Tracer
function Aiming.UpdateTracer()
    -- // Make sure the tracer exists
    if (not tracer) then
        return
    end

    -- // Vars
    local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
    local Settings = AimingSettings.TracerSettings

    local Position = Aiming.Selected.Position
    local IsValid = Aiming.Checks.IsAvailable()

    -- // Set Tracer Properties
    if (IsValid) then
        tracer.Visible = Settings.Enabled
        tracer.Color = Settings.Colour
        tracer.From = MousePosition
        tracer.To = Position
    else
        tracer.Visible = false
    end

    -- // Return tracer
    return tracer
end

-- // Utilities
local Utilities = {}
Aiming.Utilities = Utilities
local GetCurrentCamera
do
    -- // You can replace this to make it work with NPCs
    function Utilities.GetPlayers()
        return GetPlayers(Players)
    end

    -- // Camera
    function Utilities.GetCurrentCamera()
        return Workspace.CurrentCamera
    end
    GetCurrentCamera = Utilities.GetCurrentCamera

    -- // Velocity
    function Utilities.CalculateVelocity(Before, After, deltaTime)
        -- // Vars
        local Displacement = (After - Before)
        local Velocity = Displacement / deltaTime

        -- // Return
        return Velocity
    end

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

    -- // Get Body Parts
    function Utilities.GetBodyParts(Character)
        -- // Vars
        local Parts = Character:GetChildren()

        -- // Check for non-baseparts and remove them
        for i = #Parts, 1, -1 do
            if (not Parts[i]:IsA("BasePart")) then
                table.remove(Parts, i)
            end
        end

        -- // Return
        return Parts
    end

    -- // Table to String
    function Utilities.ArrayToString(Array, Function)
        -- // Default
        Function = Function or tostring

        -- // Tostring everything in the array
        for i, v in pairs(Array) do
            Array[i] = Function(v)
        end

        -- // Return
        return Array
    end

    -- // Get team
    function Utilities.TeamMatch(Player1, Player2)
        -- // Converting to teams
        if (Player1:IsA("Player")) then
            Player1 = Player1.Team
        end
        if (Player2:IsA("Player")) then
            Player2 = Player2.Team
        end

        -- // Checking
        return Player1 == Player2
    end

    -- // Check if a part is visible (to camera)
    function Utilities.IsPartVisible(Part, PartAncestor)
        -- // Vars
        local Character = Utilities.Character(LocalPlayer)
        local Origin = GetCurrentCamera().CFrame.Position
        local _, OnScreen = WorldToViewportPoint(GetCurrentCamera(), Part.Position)

        -- //
        if (OnScreen) then
            -- // Vars
            local raycastParams = RaycastParamsnew()
            raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
            local RaycastIgnore = AimingSettings.RaycastIgnore
            raycastParams.FilterDescendantsInstances = (typeof(RaycastIgnore) == "function" and RaycastIgnore() or RaycastIgnore) or {Character, GetCurrentCamera()}

            -- // Cast ray
            local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)

            -- // Make sure we get a result
            if (Result) then
                -- // Vars
                local PartHit = Result.Instance
                local Visible = PartHit == Part or IsAncestorOf(PartAncestor, PartHit)

                -- // Return
                return Visible
            end
        end

        -- // Return
        return false
    end

    -- // Get the `Direction`, `Normal` and `Material`
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

    -- // Sets the camera's CFrame, used for aim lock
    function Utilities.SetCameraCFrame(CFr)
        GetCurrentCamera().CFrame = CFr
    end

    -- // Sets the camera to look at `Position`, used for aim lock
    function Utilities.CameraLookAt(Position)
        local LookAt = CFramelookAt(GetCurrentCamera().CFrame.Position, Position)
        Utilities.SetCameraCFrame(LookAt)
    end

    -- // Gets the closest point on an object. Origin Point **must** be lined up on the same plane as the object if `OriginPoint` is **not** a `Ray`
    function Utilities.ClosestPointOnObject(OriginPoint, Object)
        -- // Vars
        local ObjectPosition = Object.Position
        local ObjectSize = Object.Size

        -- // Resolving OriginPoint if is ray
        if (typeof(OriginPoint) == "Ray") then
            -- // Convert to Unit Ray, if it is not one
            if (OriginPoint.Direction.Magnitude ~= 1) then
                OriginPoint = OriginPoint.Unit
            end

            -- // Calculate the "lined up" point based upon the ray
            local Magnitude = (ObjectPosition - OriginPoint.Origin).Magnitude
            OriginPoint = OriginPoint.Origin + (OriginPoint.Direction * Magnitude)
        end

        -- // Matching the Y of Object to be same as Origin for later use as the Destination
        local MatchedY = ObjectPosition + Vector3.new(0, -ObjectPosition.Y + OriginPoint.Y, 0)

        -- // Working out the top and bottom so we can check if the point is in Y range
        local Top = ObjectPosition + ObjectSize / 2
        local Bottom = ObjectPosition - ObjectSize / 2

        -- // Working out what the destination is, based upon whether within Y range or not
        local Destination = (OriginPoint.Y >= Bottom.Y and OriginPoint.Y <= Top.Y) and MatchedY or ObjectPosition
        local Direction = (Destination - OriginPoint)

        -- // Casting a ray and getting the closest point on object
        local WhitelistParms = RaycastParams.new()
        WhitelistParms.FilterType = Enum.RaycastFilterType.Whitelist
        WhitelistParms.FilterDescendantsInstances = {Object}
        local RaycastResult = workspace:Raycast(OriginPoint, Direction, WhitelistParms)

        -- // Return
        return RaycastResult.Position
    end

    -- // mafss 4 prediction
    function Utilities.SolveProjectileTravelTime(Position, ProjSpeed, TargetPos, Gravity)
        -- // Vars
        local Direction = TargetPos - Position
        local DirectionXZ = Vector3.new(Direction.X, 0, Direction.Z)
        local Distance = DirectionXZ.Magnitude
        local ProjSpeed2 = ProjSpeed * ProjSpeed
        local ProjSpeed4 = ProjSpeed2 * ProjSpeed2
        local InitialHeight = Direction.Y
        local GD = Gravity * Distance

        local Root = ProjSpeed4 - Gravity * (Gravity * Distance * Distance + 2 * InitialHeight * ProjSpeed2)
        if (Root < 0) then
            return nil
        end
        Root = math.sqrt(Root)

        local AngleLaunch = math.atan2(ProjSpeed2 - Root, GD)
        local BulletDirection = DirectionXZ.Unit * math.cos(AngleLaunch) * ProjSpeed + Vector3.new(0, 1, 0) * math.sin(AngleLaunch) * ProjSpeed
        local Time = Distance / (math.cos(AngleLaunch) * ProjSpeed)

        -- // Return
        return BulletDirection, Time
    end

    function Utilities.SolvePrediction(Position, Velocity, Time)
        return Position + Velocity * Time
    end

    function Utilities.WorkoutDirection(Origin, Destination, PartVelocity, ProjSpeed, Gravity)
        local _, TimeA = Utilities.SolveProjectileTravelTime(Origin, ProjSpeed, Destination, Gravity)
        local SolvedPrediction = Utilities.SolvePrediction(Destination, PartVelocity, TimeA)
        local Direction = Utilities.SolveProjectileTravelTime(Origin, ProjSpeed, SolvedPrediction, Gravity)
        return Direction
    end

    -- // Updates the Friends table
    function Utilities.UpdateFriends()
        -- // Reset
        Friends = {}

        -- // Loop through every player
        for _, Player in ipairs(Players:GetPlayers()) do
            -- // If friends, add to table (and not already added)
            if (not table.find(Friends, Player)) and LocalPlayer:IsFriendsWith(Player.UserId) then
                table.insert(Friends, Player)
            end
        end

        -- // Return
        return Friends
    end

    -- // Merges table b onto table a. Only works with same keys
    function Utilities.MergeTables(a, b)
        -- // Default
        if (typeof(a) ~= "table" or typeof(b) ~= "table") then
            return a
        end

        -- // Loop through the first table
        for i, v in pairs(a) do
            -- // Make sure this exists in the other table
            local bi = b[i]
            if (not bi) then
                continue
            end

            -- // Recursive if a table
            if (typeof(v) == "table" and typeof(bi) == "table") then
                bi = Utilities.MergeTables(v, bi)
            end

            -- // Set
            a[i] = bi
        end

        -- // Return
        return a
    end
end

-- // Ignored
local Ignored = {}
Aiming.Ignored = Ignored
do
    -- // Vars
    local IgnoredSettings = Aiming.Settings.Ignored
    local WhitelistMode = IgnoredSettings.WhitelistMode

    -- // Ignore player
    function Ignored.IgnorePlayer(Player)
        -- // Vars
        local IgnoredPlayers = IgnoredSettings.Players

        -- // Find player in table
        for _, IgnoredPlayer in pairs(IgnoredPlayers) do
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
        for i, IgnoredPlayer in pairs(IgnoredPlayers) do
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
        for _, IgnoredTeam in pairs(IgnoredTeams) do
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
        for i, IgnoredTeam in pairs(IgnoredTeams) do
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
        -- // Check
        if (not AimingSettings.TeamCheck) then
            return false
        end

        -- // Vars
        local IgnoredTeams = IgnoredSettings.Teams

        -- // Check for others
        if (IgnoredSettings.IgnoreLocalTeam and Utilities.TeamMatch(LocalPlayer, Player)) then
            return true
        end

        -- // Check if team is ignored
        for _, IgnoredTeam in pairs(IgnoredTeams) do
            -- // Make sure team matches
            if (Utilities.TeamMatch(Player, IgnoredTeam)) then
                return not WhitelistMode.Teams
            end
        end

        -- // Return
        return false
    end

    -- // Check if player is ignored
    function Ignored.IsIgnoredPlayer(Player)
        -- // Check
        if (not AimingSettings.PlayerCheck) then
            return false
        end

        -- // Friend check
        if (AimingSettings.FriendCheck and table.find(Friends, Player)) then
            return true
        end

        -- // Vars
        local IgnoredPlayers = IgnoredSettings.Players

        -- // Loop
        for _, IgnoredPlayer in pairs(IgnoredPlayers) do
            -- // Vars
            local Return = WhitelistMode.Players

            -- // Check if Player Id
            if (typeof(IgnoredPlayer) == "number" and Player.UserId == IgnoredPlayer) then
                return not Return
            end

            -- // Normal Player Instance
            if (IgnoredPlayer == Player) then
                return not Return
            end
        end

        -- // Check if whitelist mode is on
        if (WhitelistMode.Players) then
            return true
        end

        -- // Default
        return false
    end

    -- // Check if a player is ignored
    function Ignored.IsIgnored(Player)
        -- // Check
        if (not AimingSettings.IgnoredCheck) then
            return false
        end

        -- // Return
        return Ignored.IsIgnoredPlayer(Player) or Ignored.IsIgnoredTeam(Player)
    end

    -- // Toggle team check (use IgnoreLocalTeam setting instead)
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
    function Checks.Health(Character, Player)
        -- // Get Humanoid
        Character = Character or Utilities.Character(Player)
        local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")

        -- // Get Health
        local Health = (Humanoid and Humanoid.Health or 0)

        -- //
        return Health > 0
    end

    -- // Checks for a force field
    function Checks.Forcefield(Character, Player)
        -- // Get character
        Character = Character or Utilities.Character(Player)
        local Forcefield = FindFirstChildWhichIsA(Character, "ForceField")

        -- // Return
        return Forcefield == nil
    end

    -- // Checks if a part is invisible
    function Checks.Invisible(Part)
        return Part.Transparency == 1
    end

    -- // Custom Check Function
    function Checks.Custom(Character, Player)
        return true
    end

    -- // Check if the module is enabled and we have targets
    function Checks.IsAvailable()
        -- // Check enabled
        if not (AimingSettings.InternalEnabled and AimingSettings.Enabled == true and Aiming.Selected.Instance ~= nil) then
            return false
        end

        -- // Check if FOV
        if (AimingSettings.FOVSettings.FollowSelected) then
            local MousePosition = GetMouseLocation(UserInputService)
            return (MousePosition - circle.Position).Magnitude < circle.Radius
        end

        -- // Available
        return true
    end
end

-- // Configs
local Config = {}
Aiming.Config = Config
do
    -- // Grabs a directory's files
    local function GetDirectoryDescendants(Folder, Descendants)
        Descendants = Descendants or {}

        for _, Path in listfiles(Folder) do
            if (not isfolder(Path)) then
                table.insert(Descendants, Path)
                continue
            end

            for i, PathDescendant in GetDirectoryDescendants(Path) do
                table.insert(Descendants, PathDescendant)
            end
        end

        return Descendants
    end

    -- // Grab the current configs
    function Config.Grab(AllPlaces)
        -- // Configs
        local Configurations = {
            Universal = {
                Default = table.clone(Aiming.Settings)
            }
        }

        -- // Make sure the Aiming folder exists
        if (not isfolder("Aiming")) then
            return Configurations
        end

        -- // Loop through each file
        for _, directory in GetDirectoryDescendants("Aiming") do
            -- // JSON decode and such
            local DirectorySplit = directory:split("\\")
            local _, Type, FileName = unpack(DirectorySplit)
            local Configuration = HttpService:JSONDecode(readfile(directory))

            -- // Ensure valid types (only Universal and place ids)
            local TypeNumber = tonumber(Type)
            if (Type ~= "Universal" and TypeNumber == nil) then
                continue
            end

            -- // Only grab current place id
            if (not AllPlaces and TypeNumber ~= nil and TypeNumber ~= game.PlaceId) then
                continue
            end

            -- // Add it
            if (not Configurations[Type]) then
                Configurations[Type] = {}
            end
            Configurations[Type][FileName] = Configuration
        end

        -- //
        return Configurations
    end

    -- // Add a config
    function Config.Add(Type, Name, config)
        assert(Type ~= "Universal" and tonumber(Type), "invalid type, only number (game place) or Universal")
        config = config or Aiming.Settings

        local JSONConfig = HttpService:JSONEncode(config)
        local Path = "Aiming/" .. Type
        makefolder(Path)
        writefile(Path .. "/" .. Name .. ".json", JSONConfig)
    end

    -- // Load a config
    function Config.Load(Type, Name)
        Type = Type or "Universal"
        Name = Name or "Default"
        local Configurations = Config.Grab()

        if (Configurations[Type] and Configurations[Type][Name]) then
            Utilities.MergeTables(Aiming.Settings, Configurations[Type][Name])
        end
    end
end

-- // Get Closest Target Part
local InstanceCache = setmetatable({}, {__mode = "k"})
function Aiming.GetClosestTargetPartToCursor(Character)
    -- // Make sure character exists
    if (not Character) then
        return
    end

    local TargetParts = AimingSettings.TargetPart

    -- // Get the cache
    local CharacterCache = InstanceCache[Character]
    if (not CharacterCache) then
        InstanceCache[Character] = {}
        CharacterCache = InstanceCache[Character]
    end

    -- // Vars
    local ClosestPart = nil
    local ClosestPartPosition = nil
    local ClosestPartOnScreen = false
    local ClosestPartMagnitudeFromMouse = 1/0
    local ShortestDistance = 1/0

    -- //
    local function CheckTargetPart(TargetPart)
        -- // Convert string -> Instance
        if (typeof(TargetPart) == "string") then
            local CachedPart = CharacterCache[TargetPart]
            TargetPart = (CachedPart and CachedPart.Parent) and CachedPart or FindFirstChild(Character, TargetPart)
        end

        -- // Make sure we have a target
        if not (TargetPart) then
            return
        end

        -- // Add to cache
        CharacterCache[TargetPart.Name] = TargetPart

        -- // Make sure is visible
        if (AimingSettings.InvisibleCheck and Checks.Invisible(TargetPart)) then
            return
        end

        -- // Get the length between Mouse and Target Part (on screen)
        local PartPos, onScreen = WorldToViewportPoint(GetCurrentCamera(), TargetPart.Position)
        PartPos = Vector2new(PartPos.X, PartPos.Y)

        local MousePosition = GetMouseLocation(UserInputService) + AimingSettings.Offset
        local Magnitude = (PartPos - MousePosition).Magnitude

        -- //
        local OurPart = Utilities.Character(LocalPlayer):FindFirstChild(TargetPart.Name) or TargetPart
        local Distance = (OurPart.Position - TargetPart.Position).Magnitude
        if (Magnitude < ShortestDistance and onScreen and Distance < AimingSettings.MaxDistance) then
            ClosestPart = TargetPart
            ClosestPartPosition = PartPos
            ClosestPartOnScreen = onScreen
            ClosestPartMagnitudeFromMouse = Magnitude
            ShortestDistance = Magnitude
        end
    end

    -- //
    local function CheckAll()
        -- // Loop through character children
        for _, v in pairs(GetChildren(Character)) do
            -- // See if it a part
            if (v:IsA("BasePart")) then
                -- // Check it
                CheckTargetPart(v)
            end
        end
    end

    -- // String check
    if (typeof(TargetParts) == "string") then
        -- // Check if it all
        if (TargetParts == "All") then
            CheckAll()
        else
            -- // Individual
            CheckTargetPart(TargetParts)
        end
    end

    if (typeof(TargetParts) == "table") then
        -- // Check if All is included
        if (table.find(TargetParts, "All")) then
            CheckAll()
        else
            -- // Loop through all target parts and check them
            for _, TargetPartName in pairs(TargetParts) do
                CheckTargetPart(TargetPartName)
            end
        end
    end

    -- //
    return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

-- //
local PreviousPosition = nil
local LockMode = AimingSettings.LockMode
local AimingSelected = Aiming.Selected
local AimingSettingsFOVSettings = AimingSettings.FOVSettings
local AimingSettingsDeadzoneFOVSettings = AimingSettings.DeadzoneFOVSettings
function Aiming.GetClosestToCursor(deltaTime)
    -- // Vars
    local TargetPart = nil
    local ClosestPlayer = nil
    local PartPosition = nil
    local PartVelocity = nil
    local PartOnScreen = nil
    local Chance = Utilities.CalculateChance(AimingSettings.HitChance)
    local ShortestDistance = AimingSettingsFOVSettings.Enabled and circle.Radius or 1/0
    ShortestDistance = AimingSettingsFOVSettings.FollowSelected and 1/0 or ShortestDistance

    -- // See if it passed the chance or is not enabled
    if (not Chance or not AimingSettings.Enabled) then
        -- // Set
        AimingSelected.Instance = nil
        AimingSelected.Part = nil
        AimingSelected.Position = nil
        PreviousPosition = nil
        AimingSelected.Velocity = nil
        AimingSelected.OnScreen = false

        -- // Return
        return
    end

    -- // Ensure we can get our own character
    local LocalCharacter = Utilities.Character(LocalPlayer)

    -- // Loop through all players
    for _, Player in pairs(Utilities.GetPlayers()) do
        -- // Check our local character
        if (not LocalCharacter) then
            break
        end

        -- // Check
        if (LockMode.Enabled and LockMode.InternalEnabled and Player ~= LockMode.LockedPlayer) then
            continue
        end

        -- // Get Character
        local Character = Utilities.Character(Player)

        -- // Make sure isn't ignored and Character exists
        if (not Character or Ignored.IsIgnored(Player)) then
            continue
        end

        -- // Checks, seperate for ultimate efficiency
        if (AimingSettings.ForcefieldCheck and not Checks.Forcefield(Character, Player)) then
            continue
        end

        if (AimingSettings.HealthCheck and not Checks.Health(Character, Player)) then
            continue
        end

        -- // Vars
        local TargetPartTemp, PartPositionTemp, PartPositionOnScreenTemp, Magnitude = Aiming.GetClosestTargetPartToCursor(Character)

        -- // Check if part exists, and custom. PartPositionOnScreenTemp IS ALWAYS TRUE, KEPT IN FOR REDUDANCY SAKE - MAY REMOVE LATER
        if (not PartPositionOnScreenTemp or not TargetPartTemp or not Checks.Custom(Character, Player)) then
            continue
        end

        -- // Check if is in FOV
        if (Magnitude > ShortestDistance) then
            continue
        end

        -- // Check if Visible
        if (AimingSettings.VisibleCheck and not Utilities.IsPartVisible(TargetPartTemp, Character)) then
            continue
        end

        -- // Set vars
        ClosestPlayer = Player
        ShortestDistance = Magnitude
        TargetPart = TargetPartTemp
        PartPosition = PartPositionTemp
        PartOnScreen = PartPositionOnScreenTemp

        -- // Velocity calculations
        if (not PreviousPosition) then
            PreviousPosition = TargetPart.Position
        end
        PartVelocity = Utilities.CalculateVelocity(PreviousPosition, TargetPart.Position, deltaTime)
        PreviousPosition = TargetPart.Position
    end

    -- // Check if within deadzone
    AimingSettings.InternalEnabled = not (AimingSettingsDeadzoneFOVSettings.Enabled and ShortestDistance <= deadzonecircle.Radius)

    -- // Firing changed signals
    if (AimingSelected.Instance ~= ClosestPlayer) then
        Aiming.Signals:Fire("InstanceChanged", ClosestPlayer)
    end
    if (AimingSelected.Part ~= TargetPart) then
        AimingSelected.Velocity = nil
        PreviousPosition = nil
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
    AimingSelected.Velocity = PartVelocity
    AimingSelected.OnScreen = PartOnScreen

    -- // Check
    if (LockMode.Enabled and ClosestPlayer and not LockMode.InternalEnabled) then
        LockMode.InternalEnabled = true
        LockMode.LockedPlayer = ClosestPlayer
    end
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

    local function Offset()
        return AimingSettings.Offset
    end
    ManagerA.Offset = Offset
    ManagerB.Offset = Offset

    Aiming.BeizerCurve.AimTo = function(...)
        ManagerA:ChangeData(...)
    end
    Aiming.BeizerCurve.AimToB = function(...)
        ManagerB:ChangeData(...)
    end

    -- // Convert B to Camera Mode
    ManagerB:CameraMode()

    -- // Convert function to use Aiming
    ManagerB.Function = function(self, Pitch, Yaw)
        local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
        Utilities.SetCameraCFrame(CFrame.new(GetCurrentCamera().CFrame.Position) * RotationMatrix)
    end

    -- // Start
    ManagerA:Start()
    ManagerB:Start()
end

-- // Heartbeat Function
Heartbeat:Connect(function(deltaTime)
    Aiming.UpdateFOV()
    Aiming.UpdateDeadzoneFOV()
    Aiming.UpdateTracer()
    Aiming.GetClosestToCursor(deltaTime)

    Aiming.Loaded = true
end)

-- //
KeybindHandler.CreateBind({
    Keybind = function() return LockMode.UnlockBind end,
    ProcessedCheck = true,
    State = LockMode.InternalEnabled,
    Callback = function(State)
        LockMode.InternalEnabled = false
        LockMode.LockedPlayer = nil
    end,
    Hold = false
})

-- // Other stuff
task.spawn(function()
    -- // Repeat every secodn
    while true do wait(10)
        -- // Update the friends list
        Aiming.Utilities.UpdateFriends()
    end
end)

-- // Credits
task.delay(1, function()
    -- // Credits (by disabling this and not including your own way of crediting within the script, e.g. credits tab, is violating the license agreement. Beware!)
    if (Aiming.ShowCredits) then
        messagebox("Thanks to Stefanuk12 for their Aiming Module (v2, Module)", "Credits", 0)
    end
end)

-- //
return Aiming

-- // If you want the examples, look at the docs.