-- // Dependencies
local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Venyx-UI-Library/main/source2.lua"))()

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
local UI = Venyx.new({
    title = "Venyx"
})

-- // Themes
local Themes = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- // Aiming Page
local AimingPage = UI:addPage({
    title = "Aiming",
    icon = 5012544693
})

-- // Sections for Aiming Page
local MainSection = AimingPage:addSection({
    title = "Main"
})

-- // Aiming UI Elements
MainSection:addToggle({
    title = "Enabled",
    default = AimingSettings.Enabled,
    callback = function(value)
        AimingSettings.Enabled = value
    end
})

MainSection:addToggle({
    title = "Visible Check",
    default = AimingSettings.VisibleCheck,
    callback = function(value)
        AimingSettings.VisibleCheck = value
    end
})

MainSection:addSlider({
    title = "Hit Chance",
    default = AimingSettings.HitChance,
    min = 0,
    max = 100,
    callback = function(value)
        AimingSettings.HitChance = value
    end
})

-- // Target Part Section for Aiming Page
local TargetPartSection = AimingPage:addSection({
    title = "Target Part Management"
})

local TargetPartInputDrop = TargetPartSection:addDropdown({
    title = "Select Target Part",
    list = AimingSettings.TargetPart,
    default = AimingSettings.TargetPart[1],
    callback = function() end
})

TargetPartSection:addButton({
    title = "Add",
    callback = function()
        -- // Vars
        local TargetPart = TargetPartInputDrop.Options.title

        -- // Make sure does not exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (TargetPartI) then
            return UI:Notify({
                title = "Aiming: Target Part",
                context = "Already added"
            })
        end

        -- // Add
        table.insert(AimingSettings.TargetPart, TargetPart)

        -- // Update dropdown
        TargetPartInputDrop.Options:Update({
            list = AimingSettings.TargetPart
        })
    end
})
TargetPartSection:addButton({
    title = "Remove",
    callback = function()
        -- // Vars
        local TargetPart = TargetPartInputDrop.Options.title

        -- // Make sure does exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (not TargetPartI) then
            return UI:Notify({
                title = "Aiming: Target Part",
                context = "Not already added"
            })
        end

        -- // Add
        table.remove(AimingSettings.TargetPart, TargetPartI)

        -- // Update dropdown
        TargetPartInputDrop.Options:Update({
            list = AimingSettings.TargetPart
        })
    end
})

-- // Target Part Section for Aiming Page
local TargetPartCharacterSection = AimingPage:addSection({
    title = "Target Part (Character): Management"
})

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
    return Parts
end

-- //
local CharacterParts = AimingUtilities.ArrayToString(GetCharacterParts())
local TargetPartCharacterInput = TargetPartCharacterSection:addDropdown({
    title = "Select Target Part",
    list = CharacterParts,
    callback = function() end
})

TargetPartCharacterSection:addButton({
    title = "Add",
    callback = function()
        -- // Vars
        local TargetPart = TargetPartCharacterInput.Options.title

        -- // Make sure does not exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (TargetPartI) then
            return UI:Notify({
                title = "Aiming: Target Part",
                context = "Already added"
            })
        end

        -- // Add
        table.insert(AimingSettings.TargetPart, TargetPart)

        -- // Update dropdown
        TargetPartInputDrop.Options:Update({
            list = AimingSettings.TargetPart
        })
    end
})
TargetPartCharacterSection:addButton({
    title = "Remove",
    callback = function()
        -- // Vars
        local TargetPart = TargetPartCharacterInput.Options.title

        -- // Make sure does exist already
        local TargetPartI = table.find(AimingSettings.TargetPart, TargetPart)
        if (not TargetPartI) then
            return UI:Notify({
                title = "Aiming: Target Part",
                context = "Not already added"
            })
        end

        -- // Add
        table.remove(AimingSettings.TargetPart, TargetPartI)

        -- // Update dropdown
        TargetPartInputDrop.Options:Update({
            list = AimingSettings.TargetPart
        })
    end
})

-- // FOV Section for Aiming Page
local FOVSettingsSection = AimingPage:addSection({
    title = "FOV Management"
})

FOVSettingsSection:addToggle({
    title = "Enabled",
    default = AimingSettings.FOVSettings.Enabled,
    callback = function(value)
        AimingSettings.FOVSettings.Enabled = value
    end
})

FOVSettingsSection:addSlider({
    title = "Scale",
    default = AimingSettings.FOVSettings.Scale,
    min = 0,
    max = 360,
    callback = function(value)
        AimingSettings.FOVSettings.Scale = value
    end
})

FOVSettingsSection:addSlider({
    title = "Sides",
    default = AimingSettings.FOVSettings.Sides,
    min = 3,
    max = 55,
    callback = function(value)
        AimingSettings.FOVSettings.Sides = value
    end
})

FOVSettingsSection:addColorPicker({
    title = "Colour",
    default = AimingSettings.FOVSettings.Colour,
    callback = function(value)
        AimingSettings.FOVSettings.Colour = value
    end
})

-- // Tracer Section for Aiming Page
local TracerSettingsSection = AimingPage:addSection({
    title = "Tracer Management"
})

TracerSettingsSection:addToggle({
    title = "Enabled",
    default = AimingSettings.TracerSettings.Enabled,
    callback = function(value)
        AimingSettings.TracerSettings.Enabled = value
    end
})

TracerSettingsSection:addColorPicker({
    title = "Colour",
    default = AimingSettings.TracerSettings.Colour,
    callback = function(value)
        AimingSettings.TracerSettings.Colour = value
    end
})


-- // Ignored Player Section for Aiming Page
local IgnoredPlayerSection = AimingPage:addSection({
    title = "Ignored: Player"
})

local function GetPlayersString()
    -- // Vars
    local AllPlayers = Players:GetPlayers()

    -- // Loop through each player
    for i = 1, #AllPlayers do
        -- // Set
        AllPlayers[i] = tostring(AllPlayers[i])
    end

    -- // Return
    return AllPlayers
end
local PlayerDropdown = IgnoredPlayerSection:addDropdown({
    title = "Select Player",
    list = GetPlayersString(),
    default = GetPlayersString()[1]
})

Players.PlayerAdded:Connect(function()
    PlayerDropdown.Options:Update({
        list = GetPlayersString()
    })
end)
Players.PlayerRemoving:Connect(function()
    PlayerDropdown.Options:Update({
        list = GetPlayersString()
    })
end)

IgnoredPlayerSection:addButton({
    title = "Ignore Player",
    callback = function()
        -- // Vars
        local Player = Players:FindFirstChild(PlayerDropdown.Options.title)

        -- // Make sure we have the player
        if (not Player) then
            return UI:Notify({
                title = "Aiming: Ignore Player",
                context = "Player does not exist"
            })
        end

        -- // Make sure the player is not already ignored
        local PlayerI = table.find(AimingSettings.Ignored.Players, Player)
        if (PlayerI) then
            return UI:Notify({
                title = "Aiming: Ignore Player",
                context = "Player already ignored"
            })
        end

        -- //
        table.insert(AimingSettings.Ignored.Players, Player)
    end
})
IgnoredPlayerSection:addButton({
    title = "Unignore Player",
    callback = function()
        -- // Vars
        local Player = Players:FindFirstChild(PlayerDropdown.Options.title)

        -- // Make sure we have the player
        if (not Player) then
            return UI:Notify({
                title = "Aiming: Unignore Player",
                context = "Player does not exist"
            })
        end

        -- // Make sure the player is already ignored
        local PlayerI = table.find(AimingSettings.Ignored.Players, Player)
        if (not PlayerI) then
            return UI:Notify({
                title = "Aiming: Unignore Player",
                context = "Player not ignored"
            })
        end

        -- //
        table.remove(AimingSettings.Ignored.Players, PlayerI)
    end
})

-- // Ignored Team Section for Aiming Page
local IgnoredTeamSection = AimingPage:addSection({
    title = "Ignored: Team"
})

IgnoredTeamSection:addToggle({
    title = "Ignore Local Team",
    default = AimingSettings.Ignored.IgnoreLocalTeam,
    callback = function(value)
        AimingSettings.Ignored.IgnoreLocalTeam = value
    end
})

local function GetTeamsString()
    -- // Vars
    local AllTeams = Teams:GetTeams()

    -- // Loop through each player
    for i = 1, #AllTeams do
        -- // Set
        AllTeams[i] = tostring(AllTeams[i])
    end

    -- // Return
    return AllTeams
end
local TeamDropdown = IgnoredTeamSection:addDropdown({
    title = "Select Team",
    list = GetTeamsString()
})

IgnoredTeamSection:addButton({
    title = "Ignore Team",
    callback = function()
        -- // Vars
        local Team = Teams:FindFirstChild(TeamDropdown.Options.title)

        -- // Make sure we have the player
        if (not Team) then
            return UI:Notify({
                title = "Aiming: Ignore Team",
                context = "Team does not exist"
            })
        end

        -- // Make sure the player is not already ignored
        local TeamI = table.find(AimingSettings.Ignored.Teams, Team)
        if (TeamI) then
            return UI:Notify({
                title = "Aiming: Ignore Team",
                context = "Team already ignored"
            })
        end

        -- //
        table.insert(AimingSettings.Ignored.Teams, Team)
    end
})
IgnoredTeamSection:addButton({
    title = "Unignore Team",
    callback = function()
        -- // Vars
        local Team = Teams:FindFirstChild(TeamDropdown.Options.title)

        -- // Make sure we have the player
        if (not Team) then
            return UI:Notify({
                title = "Aiming: Unignore Team",
                context = "Team does not exist"
            })
        end

        -- // Make sure the player is already ignored
        local TeamI = table.find(AimingSettings.Ignored.Teams, Team)
        if (not TeamI) then
            return UI:Notify({
                title = "Aiming: Unignore Team",
                context = "Team not ignored"
            })
        end

        -- //
        table.remove(AimingSettings.Ignored.Teams, TeamI)
    end
})

Teams.ChildAdded:Connect(function()
    TeamDropdown.Options:Update({
        list = GetTeamsString()
    })
end)
Teams.ChildRemoved:Connect(function()
    TeamDropdown.Options:Update({
        list = GetTeamsString()
    })
end)

-- // Settings Page
local Settings = UI:addPage({
    title = "Settings",
    icon = 5012544693
})

-- // Settings
local SettingsSection = Settings:addSection({
    title = "Settings"
})

SettingsSection:addKeybind({
    title = "Toggle GUI",
    key = Enum.KeyCode.LeftControl,
    callback = function()
        UI:toggle()
    end
})

-- // Section for the Colour Theme Customisation Page
local Colours = Settings:addSection({
    title = "Colours"
})

-- // Adding a colour picker for each type of theme customisable
for theme, colour in pairs(Themes) do
    Colours:addColorPicker({
        title = theme,
        default = colour,
        callback = function(colour3)
            UI:setTheme({
                theme = theme,
                color3 = colour3
            })
        end
    })
end

-- // Load
UI:SelectPage({
    page = UI.pages[1],
    toggle = true
})

-- //
Aiming.GUI = {UI, AimingPage, Settings}
return UI, AimingPage, Settings