local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("RAW_URL/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("RAW_URL/tabs/settings/main.lua"))()

local Window = Fluent:CreateWindow({
	Title = "PrimeXploit",
	SubTitle = "v1.0",
	TabWidth = 160,
	Size = UDim2.fromOffset(580, 460),
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "terminal" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

SaveManager:SetLibrary(Fluent)
SaveManager:SetFolder("PrimeXploit/Garden-Horizons")
SaveManager:IgnoreThemeSettings()

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("PrimeXploit")

loadstring(game:HttpGet("RAW_URL/tabs/main/main.lua"))(Tabs, Options, Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
	Title = "PrimeXploit",
	Content = "Script loaded successfully!",
	Duration = 5
})

SaveManager:LoadAutoloadConfig()