-- // Services
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- // Vars
local CurrentCamera = Workspace.CurrentCamera
local RenderStepped = RunService.RenderStepped

-- //
local function MouseOffsetFunction(self, X, Y)
    local Offset = (typeof(self.Offset) == "function" and self.Offset() or self.Offset)
    local NewPosition = Vector2.new(X, Y) + Offset
    mousemoveabs(NewPosition.X, NewPosition.Y)
end

-- // Combine two tables
local function CombineTables(Base, ToAdd)
    -- // Default
    Base = Base or {}
    ToAdd = ToAdd or {}

    -- // Loop through data we want to add
    for i, v in pairs(ToAdd) do
        -- // Recursive
        local BaseValue = Base[i] or false
        if (typeof(v) == "table" and typeof(BaseValue) == "table") then
            CombineTables(BaseValue, v)
            continue
        end

        -- // Set
        Base[i] = v
    end

    -- // Return
    return Base
end

-- // Deep copying
local function DeepCopy(Original)
    -- // Assert
    assert(typeof(Original) == "table", "invalid type for Original (expected table)")

    -- // Vars
    local Copy = {}

    -- // Loop through original
    for i, v in pairs(Original) do
        -- // Recursion if table
        if (typeof(v) == "table") then
            v = DeepCopy(v)
        end

        -- // Set
        Copy[i] = v
    end

    -- // Return the copy
    return Copy
end

-- //
local BeizerManager = {}
BeizerManager.__index = BeizerManager
do
    -- // Default Data
    BeizerManager.DefaultData = {
        CurrentMode = "Mouse",
        t = 0,
        tThreshold = 0.99995,
        StartPoint = Vector2.new(),
        EndPoint = Vector2.new(),
        CurvePoints = {
            Vector2.new(1, 1),
            Vector2.new(1, 1)
        },
        Active = false,
        Smoothness = 0.0025,
        DrawPath = false,
        Function = MouseOffsetFunction,
        Offset = function() return Vector2.new() end, -- // can be static too,
        Started = false,
    }

    -- // Constructor
    function BeizerManager.new(Data)
        -- // Initialise object
        local self = setmetatable({}, BeizerManager)

        -- // Initialise defaults
        Data = CombineTables(DeepCopy(BeizerManager.DefaultData), Data)
        CombineTables(self, Data)

        -- // Return Object
        return self
    end

    -- // Aim to
    function BeizerManager:ChangeData(Data)
        -- // Vars
        self.StartPoint = (self.GetStartPoint() or Data.StartPoint)
        self.EndPoint = self.ModifyEndPoint(Data.TargetPosition)
        self.Smoothness = Data.Smoothness or self.Smoothness
        self.CurvePoints = Data.CurvePoints or self.CurvePoints
        self.DrawPath = Data.DrawPath or self.DrawPath

        -- // Set Active
        self.t = 0
        self.Active = true
    end

    -- // Do
    function BeizerManager.CubicCurve(t, StartPoint, EndPoint, ControlPointA, ControlPointB)
        local t1 = (1 - t)

        local A = t1^3 * StartPoint
        local B = 3 * t1^2 * t * ControlPointA
        local C = 3 * t1 * t^2 * ControlPointB
        local D = t^3 * EndPoint

        return A + B + C + D
    end

    -- //
    function BeizerManager.DoControlPoint(StartPoint, EndPoint, ControlPointA, ControlPointB)
        -- //
        local Change = (EndPoint - StartPoint)

        -- // Calculate the control points - relative to the start and end points
        local A = StartPoint + (Change * ControlPointA)
        local B = StartPoint + (Change * ControlPointB)

        -- //
        return A, B
    end

    -- // Draw path
    function BeizerManager.DrawPathFunc(CurvePosition, A, B)
        local Path = Drawing.new("Circle")
        Path.Radius = 2
        Path.Color = Color3.fromRGB(255, 150, 150)
        Path.Visible = true
        Path.Position = CurvePosition
        task.delay(1, function()
            Path:Remove()
        end)

        local ControlPointA = Drawing.new("Circle")
        ControlPointA.Radius = 5
        ControlPointA.Color = Color3.fromRGB(225, 150, 255)
        ControlPointA.Visible = true
        ControlPointA.Position = A
        task.delay(1, function()
            ControlPointA:Remove()
        end)

        local ControlPointB = Drawing.new("Circle")
        ControlPointB.Radius = 5
        ControlPointB.Color = Color3.fromRGB(225, 150, 255)
        ControlPointB.Visible = true
        ControlPointB.Position = B
        task.delay(1, function()
            ControlPointB:Remove()
        end)
    end

    -- //
    function BeizerManager:DoIteration()
        -- // Make sure is active
        if (not self.Active) then
            return
        end

        -- // Vars
        local BeizerCurve = self.CubicCurve
        local t = self.t

        -- // I have to do it this way because a for loop stops before hand
        while (t <= 1 and self.Active) do RenderStepped:Wait()
            -- // Increment
            t = t + self.Smoothness

            -- // If past threshold, then do regular smoothing
            if (t >= self.tThreshold) then
                -- // Regular smoothing
                local clampedT = math.clamp(t, 0, 1)
                local New = self.StartPoint:Lerp(self.EndPoint, clampedT)

                -- //
                self:Function(New.X, New.Y)
            else
                -- // Work out X, Y based upon the curve
                local A, B = self.DoControlPoint(self.StartPoint, self.EndPoint, unpack(self.CurvePoints))
                local CurvePosition = BeizerCurve(t, self.StartPoint, self.EndPoint, A, B)

                -- // Create Circle [Debugging]
                if (self.DrawPath) then
                    BeizerManager.DrawPathFunc(CurvePosition, A, B)
                end

                -- //
                self:Function(CurvePosition.X, CurvePosition.Y)
            end
        end

        -- // Reset
        self.Active = false
    end

    -- // Get Start Point
    function BeizerManager.GetStartPoint()
        return UserInputService:GetMouseLocation()
    end

    -- // Modify end point
    function BeizerManager.ModifyEndPoint(EndPoint)
        return EndPoint
    end

    -- // Start
    function BeizerManager:Start()
        self.Started = true

        local thread = task.spawn(function()
            while (self.Started) do RenderStepped:Wait()
                self:DoIteration()
            end
        end)

        return thread
    end

    -- // Stop
    function BeizerManager:Stop()
        self.Started = false
    end

    -- //
    function BeizerManager:StopCurrent()
        self.Active = false
        self.t = 0
    end

    -- // Switch to "Camera" Mode
    function BeizerManager:CameraMode()
        -- // Ignore if already mode
        if (self.Mode == "Camera") then
            return
        end
        self.Mode = "Camera"

        -- // Override get starting point
        self.GetStartPoint = function()
            local Pitch, Yaw, _ = CurrentCamera.CFrame:ToEulerAnglesYXZ()
            local StartPoint = Vector2.new(Pitch, Yaw)
            return StartPoint
        end

        -- // Override modifying the point so it now accepts a vector3
        self.ModifyEndPoint = function(EndPoint)
            local LookAtEndPoint = CFrame.lookAt(CurrentCamera.CFrame.Position, EndPoint)
            local Pitch, Yaw, _ = LookAtEndPoint:ToEulerAnglesYXZ()

            EndPoint = Vector2.new(Pitch, Yaw)
            return EndPoint
        end

        -- // Override the camera move function
        self.Function = function(self, Pitch, Yaw)
            local RotationMatrix = CFrame.fromEulerAnglesYXZ(Pitch, Yaw, 0)
            CurrentCamera.CFrame = CFrame.new(CurrentCamera.CFrame.Position) * RotationMatrix
        end

        -- // Override draw path func
        self.DrawPathFunc = function()
            -- // Too complicated to create in camera mode, would have to do what self.Function does then convert to ScreenPort or whatever then draw that. Well, it's not that complicated, I just rather not do it. Also, it might be resource intensive idk.
        end
    end

    -- // Switch back to "Mouse" Mode
    function BeizerManager.MouseMode(self)
        -- // Ignore if already mode
        if (self.Mode == "Mouse") then
            return
        end
        self.Mode = "Mouse"

        -- // Set
        self.GetStartPoint = BeizerManager.GetStartPoint
        self.ModifyEndPoint = BeizerManager.ModifyEndPoint
        self.Function = MouseOffsetFunction
        self.DrawPathFunc = BeizerManager.DrawPathFunc
    end

    -- // Aims to target position with mouse
    function BeizerManager:AimToMouse(TargetPosition)
        -- // Check if target position matches
        if (typeof(TargetPosition) == "Vector3") then
            TargetPosition = CurrentCamera:WorldToViewportPoint(TargetPosition)
            TargetPosition = Vector2.new(TargetPosition.X, TargetPosition.Y)
        end

        -- // Set mode
        self:MouseMode()

        -- // Aim
        return self:ChangeData({
            TargetPosition = TargetPosition
        })
    end

    -- // Aims to target position with camera
    function BeizerManager:AimToCamera(TargetPosition)
        -- // Check if target position matches
        if (typeof(TargetPosition) == "Vector2") then
            TargetPosition = CurrentCamera:ViewportPointToRay(TargetPosition.X, TargetPosition.Y, 0).Origin
        end

        -- // Set mode
        self:CameraMode()

        -- // Aim
        return self:ChangeData({
            TargetPosition = TargetPosition
        })
    end

    -- // Dynamic Aim To
    function BeizerManager:AimTo(TargetPosition, PreferMode, Data)
        CombineTables(self, Data)

        -- // Prefer mode
        if (PreferMode) then
            if (PreferMode == "Camera") then
                return self:AimToCamera(TargetPosition)
            elseif (PreferMode == "Mouse") then
                return self:AimToMouse(TargetPosition)
            end
        end

        -- // Vars
        local IsZoomed = (CurrentCamera.CFrame.Position - CurrentCamera.Focus.Position).Magnitude < 0.7
        local MouseLockedCenter = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter
        local HoldingRightClick = UserInputService.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition

        -- // Use mouse
        if not (IsZoomed or MouseLockedCenter or HoldingRightClick) then
            return self:AimToMouse(TargetPosition)
        end

        -- // Use camera
        return self:AimToCamera(TargetPosition)
    end
end

-- // Return
-- getgenv().BeizerManager = BeizerManager
return BeizerManager