local SettingsManager = {}

function SettingsManager.Init(Tabs, Options, Fluent, SaveManager, InterfaceManager)
	local section = Tabs.Settings:AddSection("About")

	section:AddParagraph({
		Title = "PrimeXploit v1.0",
		Content = "Developed by PrimeXploit Team.\nFluent UI Library by dawid."
	})

	SaveManager:SetLibrary(Fluent)
	InterfaceManager:SetLibrary(Fluent)
	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({})
	InterfaceManager:SetFolder("PrimeXploit")
	SaveManager:SetFolder("PrimeXploit/specific-game")

	InterfaceManager:BuildInterfaceSection(Tabs.Settings)
	SaveManager:BuildConfigSection(Tabs.Settings)
end

return SettingsManager