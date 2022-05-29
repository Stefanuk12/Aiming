--[[
    Information:

    - Bad Business (https://www.roblox.com/games/3233893879/)
]]

-- // Dependencies
local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/Stefanuk12/Aiming/main/Module.lua"))()

-- // Grabbing the character manager
local CharacterManager
for _, v in ipairs(getgc(true)) do
    if (typeof(v) == "table" and rawget(v, "InitProjectile") and rawget(v, "TS")) then
        CharacterManager = getupvalue(v.TS.Characters.GetCharacter, 1)
        break
    end
end

-- //
function Aiming.Utilities.Character(Player)
    return (CharacterManager[Player] or {}).Body
end

-- // Return
return Aiming