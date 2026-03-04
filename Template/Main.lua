local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
	Title = "PrimeXploit",
	SubTitle = "v1.0",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "home" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- Main
loadstring(game:HttpGet("https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/Garden%20Horizons/Tabs/Main.Lua"))().Init(Tabs.Main, Options, Fluent)

-- Settings
local SettingsManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/Garden%20Horizons/Tabs/Settings.lua"))()

SettingsManager:SetLibrary(Fluent)
SettingsManager:SetFolder("PrimeXploitSettings")
SettingsManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
	Title = "PrimeXploit",
	Content = "Script loaded successfully.",
	Duration = 5
})