local tab, InterfaceManager = ...
local Library = InterfaceManager.Library
local Settings = InterfaceManager.Settings

local section = tab:AddSection("Interface")

local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
	Title = "Theme",
	Description = "Changes the interface theme.",
	Values = Library.Themes,
	Default = Settings.Theme,
	Callback = function(Value)
		Library:SetTheme(Value)
		Settings.Theme = Value
		InterfaceManager:SaveSettings()
	end
})

InterfaceTheme:SetValue(Settings.Theme)

section:AddToggle("TransparentToggle", {
	Title = "Transparency",
	Description = "Makes the interface transparent.",
	Default = Settings.Transparency,
	Callback = function(Value)
		Library:ToggleTransparency(Value)
		Settings.Transparency = Value
		InterfaceManager:SaveSettings()
	end
})

local MenuKeybind = section:AddKeybind("MenuKeybind", {
	Title = "Minimize Bind",
	Default = Settings.MenuKeybind
})
MenuKeybind:OnChanged(function()
	Settings.MenuKeybind = MenuKeybind.Value
	InterfaceManager:SaveSettings()
end)
Library.MinimizeKeybind = MenuKeybind