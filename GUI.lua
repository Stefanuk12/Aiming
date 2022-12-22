-- // Dependencies
local LinoriaRepo = "https://raw.githubusercontent.com/Stefanuk12/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(LinoriaRepo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(LinoriaRepo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(LinoriaRepo .. "addons/SaveManager.lua"))()

local Aiming = getgenv().Aiming
if (not Aiming) then
    Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Load.lua"))()()
end
repeat wait() until Aiming.Loaded

local AimingSettings = Aiming.Settings
local AimingUtilities = Aiming.Utilities

-- // Services
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- // Initialising the UI
local Window = Library:CreateWindow({
    Title = "epic hax",
    Center = true,
    AutoShow = true
})

-- //
local AimingTab = Window:AddTab("Aiming")
do
    -- // Get some parts
    local function GetCharacterParts()
        -- // Vars
        local Parts = {}

        -- // Loop through Players
        for _, Player in ipairs(Players:GetPlayers()) do
            -- // Attempt to get their character
            local Character = AimingUtilities.Character(Player)
            if (not Character) then
                continue
            end

            -- //
            local CharacterParts = AimingUtilities.GetBodyParts(Character)
            if (#CharacterParts > 0) then
                Parts = CharacterParts
                break
            end
        end

        -- // Return
        table.insert(Parts, "All")
        return Parts
    end

    -- //
    local UniversalGroupBox = AimingTab:AddLeftGroupbox("Universal")
    UniversalGroupBox:AddToggle("AimingEnabled", {
        Text = "Enabled",
        Default = AimingSettings.Enabled,
        Tooltip = "Toggle the entirety of Aiming on and off",
        Callback = function(Value)
            AimingSettings.Enabled = Value
        end
    })
    UniversalGroupBox:AddToggle("AimingVisibleCheck", {
        Text = "Visibility Check",
        Default = AimingSettings.VisibleCheck,
        Tooltip = "Makes sure targets are within LoS",
        Callback = function(Value)
            AimingSettings.VisibleCheck = Value
        end
    })
    UniversalGroupBox:AddToggle("AimingVisibleCheck", {
        Text = "Player Check",
        Default = AimingSettings.VisibleCheck,
        Tooltip = "Toggle the player is ignored check",
        Callback = function(Value)
            AimingSettings.VisibleCheck = Value
        end
    })
    UniversalGroupBox:AddToggle("AimingVisibleCheck", {
        Text = "Team Check",
        Default = AimingSettings.VisibleCheck,
        Tooltip = "Toggle the team is ignored check",
        Callback = function(Value)
            AimingSettings.VisibleCheck = Value
        end
    })
    UniversalGroupBox:AddToggle("AimingVisibleCheck", {
        Text = "Ignored Check",
        Default = AimingSettings.VisibleCheck,
        Tooltip = "Toggle all ignored checks",
        Callback = function(Value)
            AimingSettings.VisibleCheck = Value
        end
    })
    UniversalGroupBox:AddSlider("AimingHitChance", {
        Text = "Hit Chance%",
        Tooltip = "The likelyhood of Aiming 'working'",
        Default = AimingSettings.HitChance,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            AimingSettings.HitChance = Value
        end
    })

    -- //
    local TargetPartBox = AimingTab:AddRightTabbox()
    local TargetPartSelected = TargetPartBox:AddTab("Selected")
    local TargetPartSelection = TargetPartBox:AddTab("Selection")

    -- //
    local TargetPartA = TargetPartSelected:AddDropdown("AimingTargetPartSelected", {
        Values = AimingSettings.TargetPart,
        Default = 1,
        Multi = false,
        Text = "Select Target Part",
        Tooltip = "These are the currently selected parts"
    })
    TargetPartSelected:AddButton("Add", function()
        -- // Vars
        local TargetPart = TargetPartA.Value

        -- // Make sure does not exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (TargetPartI) then
            return Library:Notify("Already added", 3)
        end

        -- // Add
        table.insert(AimingSettings.TargetPart, TargetPartI)

        -- // Update dropdown
        TargetPartA.Values = AimingSettings.TargetPart
        TargetPartA:SetValues()
    end):AddButton("Remove", function()
        -- // Vars
        local TargetPart = TargetPartA.Value

        -- // Make sure does exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (not TargetPartI) then
            return Library:Notify("Not already added", 3)
        end

        -- // Add
        table.remove(AimingSettings.TargetPart, TargetPartI)

        -- // Update dropdown
        TargetPartA.Values = AimingSettings.TargetPart
        TargetPartA:SetValues()
    end)

    -- //
    local CharacterParts = AimingUtilities.ArrayToString(GetCharacterParts())
    local TargetPartB = TargetPartSelection:AddDropdown("AimingTargetPartSelection", {
        Values = CharacterParts,
        Default = 1,
        Multi = false,
        Text = "Select Target Part",
        Tooltip = "These are the possible target parts"
    })
    TargetPartSelection:AddButton("Add", function()
        -- // Vars
        local TargetPart = TargetPartB.Value

        -- // Make sure does not exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (TargetPartI) then
            return Library:Notify("Already added", 3)
        end

        -- // Add
        table.insert(AimingSettings.TargetPart, TargetPart)

        -- // Update dropdown
        TargetPartA.Values = AimingSettings.TargetPart
        TargetPartA:SetValues()
    end):AddButton("Remove", function()
        -- // Vars
        local TargetPart = TargetPartB.Value

        -- // Make sure does exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (not TargetPartI) then
            return Library:Notify("Not already added", 3)
        end

        -- // Add
        table.remove(AimingSettings.TargetPart, TargetPartI)

        -- // Update dropdown
        TargetPartA.Values = AimingSettings.TargetPart
        TargetPartA:SetValues()
    end)

    -- //
    local DrawingManagementBox = AimingTab:AddLeftTabbox()
    local FOVManagement = DrawingManagementBox:AddTab("FOV Settings")
    local TracerManagement = DrawingManagementBox:AddTab("Tracer Settings")

    -- //
    FOVManagement:AddToggle("AimingFOVEnabled", {
        Text = "Enabled",
        Default = AimingSettings.FOVSettings.Enabled,
        Tooltip = "Toggle the FOV Circle on and off",
        Callback = function(Value)
            AimingSettings.FOVSettings.Enabled = Value
        end
    }):AddColorPicker("AimingFOVColour", {
        Text = "Colour",
        Default = AimingSettings.FOVSettings.Colour,
        Tooltip = "The colour of the FOV Circle",
        Callback = function(Value)
            AimingSettings.FOVSettings.Colour = Value
        end
    })
    FOVManagement:AddSlider("AimingFOVScale", {
        Text = "Scale",
        Tooltip = "The size of the FOV Circle",
        Default = AimingSettings.FOVSettings.Scale,
        Min = 0,
        Max = 360,
        Rounding = 1,
        Callback = function(Value)
            AimingSettings.FOVSettings.Scale = Value
        end
    })

    -- //
    TracerManagement:AddToggle("AimingTracerEnabled", {
        Text = "Enabled",
        Default = AimingSettings.TracerSettings.Enabled,
        Tooltip = "Toggle the tracer on and off",
        Callback = function(Value)
            AimingSettings.TracerSettings.Enabled = Value
        end
    }):AddColorPicker("AimingTracerColour", {
        Text = "Colour",
        Default = AimingSettings.TracerSettings.Colour,
        Tooltip = "The colour of the tracer",
        Callback = function(Value)
            AimingSettings.TracerSettings.Colour = Value
        end
    })

    -- //
    local IgnoredManagementBox = AimingTab:AddRightTabbox("Ignored Management")
    local PlayerManagement = IgnoredManagementBox:AddTab("Player")
    local TeamManagement = IgnoredManagementBox:AddTab("Team")

    -- //
    local PlayerDropdown = PlayerManagement:AddDropdown("AimingIgnoredPlayerDropdown", {
        Default = 2,
        Multi = false,
        Text = "Select Player",
        Tooltip = "These are the current players",
        SpecialType = "Player"
    })
    PlayerManagement:AddToggle("AimingIgnoreLocalTeam", {
        Text = "Ignore Friends",
        Default = AimingSettings.Ignored.IgnoreFriends,
        Tooltip = "Ignores your Roblox friends",
        Callback = function(Value)
            AimingSettings.Ignored.IgnoreFriends = Value
        end
    })
    PlayerManagement:AddButton("Ignore", function()
        -- // Vars
        local Player = Players:FindFirstChild(PlayerDropdown.Value)

        -- // Make sure we have the player
        if (not Player) then
            return Library:Notify("Player does not exist", 3)
        end

        -- // Make sure the player is not already ignored
        local PlayerI = table.find(AimingSettings.Ignored.Players, Player)
        if (PlayerI) then
            return Library:Notify("Player already ignored", 3)
        end

        -- //
        table.insert(AimingSettings.Ignored.Players, Player)
    end):AddButton("Unignore", function()
        -- // Vars
        local Player = Players:FindFirstChild(PlayerDropdown.Value)

        -- // Make sure we have the player
        if (not Player) then
            return Library:Notify("Player does not exist", 3)
        end

        -- // Make sure the player is not already ignored
        local PlayerI = table.find(AimingSettings.Ignored.Players, Player)
        if (not PlayerI) then
            return Library:Notify("Player not ignored", 3)
        end

        -- //
        table.remove(AimingSettings.Ignored.Players, PlayerI)
    end)

    -- //
    local TeamDropdown = TeamManagement:AddDropdown("AimingIgnoredTeamsDropdown", {
        Default = 1,
        Multi = false,
        Text = "Select Team",
        Tooltip = "These are the current teams",
        SpecialType = "Team"
    })
    TeamManagement:AddToggle("AimingIgnoreLocalTeam", {
        Text = "Ignore Local Team",
        Default = AimingSettings.Ignored.IgnoreLocalTeam,
        Tooltip = "Ignores the local team",
        Callback = function(Value)
            AimingSettings.Ignored.IgnoreLocalTeam = Value
        end
    })
    TeamManagement:AddButton("Ignore", function()
        -- // Vars
        local Team = Teams:FindFirstChild(TeamDropdown.Value)

        -- // Make sure we have the player
        if (not Team) then
            return Library:Notify("Team does not exist", 3)
        end

        -- // Make sure the player is not already ignored
        local TeamI = table.find(AimingSettings.Ignored.Teams, Team)
        if (TeamI) then
            return Library:Notify("Team already ignored", 3)
        end

        -- //
        table.insert(AimingSettings.Ignored.Teams, Team)
    end):AddButton("Unignore", function()
        -- // Vars
        local Team = Teams:FindFirstChild(TeamDropdown.Value)

        -- // Make sure we have the player
        if (not Team) then
            return Library:Notify("Team does not exist", 3)
        end

        -- // Make sure the player is not already ignored
        local TeamI = table.find(AimingSettings.Ignored.Teams, Team)
        if (not TeamI) then
            return Library:Notify("Team not ignored", 3)
        end

        -- //
        table.remove(AimingSettings.Ignored.Teams, TeamI)
    end)
end

-- //
local UISettingsTab = Window:AddTab("UI Settings")
UISettingsTab:SetLayoutOrder(69420) -- // so it sticks to the end
do
    local MenuGroup = UISettingsTab:AddLeftGroupbox("Menu Settings")

    MenuGroup:AddButton("Unload", function()
        Library:Unload()
    end)

    MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
        Default = "End",
        NoUI = true,
        Text = "Menu keybind"
    })

    Library.ToggleKeybind = Options.MenuKeybind
end

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:BuildConfigSection(UISettingsTab)
ThemeManager:ApplyToTab(UISettingsTab)

-- // Misc
Library:OnUnload(function()
    Library.Unloaded = true
end)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({"MenuKeybind"})

-- // Return
Aiming.GUI = {Library, AimingTab, UISettingsTab}
return Library, AimingTab, Window, UISettingsTab