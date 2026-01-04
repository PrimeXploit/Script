local SettingsPlace = {
    ["71793674075007"] = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/PrimeXploit/script/refs/heads/main/script/kanom-tokyo.lua"))()'
}

local PlaceId = tostring(game.PlaceId)
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

if SettingsPlace[PlaceId] then
    loadstring(SettingsPlace[PlaceId])()
else
    Player:Kick("This script isn’t supported yet")
end
