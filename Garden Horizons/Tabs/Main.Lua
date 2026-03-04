local httpService = game:GetService("HttpService")

local MainManager = {}

local SAVE_PATH = "PrimeXploit/Garden-Horizons"
local TABS_FILE = SAVE_PATH .. "/Tabs.json"

-- Default settings for Main tab (เพิ่ม key ใหม่ที่นี่เมื่อมีฟังก์ชั่นใหม่)
local Defaults = {
	Main = {
		PrintInput = ""
	}
}

local function buildFolder()
	if not isfolder("PrimeXploit") then
		makefolder("PrimeXploit")
	end
	if not isfolder(SAVE_PATH) then
		makefolder(SAVE_PATH)
	end
end

local function loadTabs()
	buildFolder()
	local data = {}

	-- Deep copy defaults
	for tab, settings in next, Defaults do
		data[tab] = {}
		for key, value in next, settings do
			data[tab][key] = value
		end
	end

	if isfile(TABS_FILE) then
		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(TABS_FILE))
		if success and type(decoded) == "table" then
			-- Merge: เอาค่าที่บันทึกไว้ และเพิ่ม key ใหม่จาก Defaults ถ้ายังไม่มี
			for tab, settings in next, Defaults do
				if type(decoded[tab]) == "table" then
					for key, value in next, settings do
						if decoded[tab][key] == nil then
							decoded[tab][key] = value
						end
					end
					data[tab] = decoded[tab]
				end
			end
		end
	end

	return data
end

local function saveTabs(data)
	buildFolder()
	writefile(TABS_FILE, httpService:JSONEncode(data))
end

function MainManager.Init(tab, Options, Fluent)
	local tabsData = loadTabs()
	local settings = tabsData.Main

	local section = tab:AddSection("Text Printer")

	section:AddInput("PrintInput", {
		Title = "Message",
		Default = settings.PrintInput,
		Placeholder = "Type your message here...",
		Numeric = false,
		Finished = false,
		Callback = function(Value)
			settings.PrintInput = Value
			saveTabs(tabsData)
		end
	})

	section:AddButton({
		Title = "Print Message",
		Description = "Print the message to the console",
		Callback = function()
			local text = Options.PrintInput.Value
			if text and text ~= "" then
				print("[ PrimeXploit ]:", text)
				Fluent:Notify({
					Title = "PrimeXploit",
					Content = "Printed : " .. text,
					Duration = 3
				})
			else
				Fluent:Notify({
					Title = "PrimeXploit",
					Content = "Please enter a message first.",
					Duration = 3
				})
			end
		end
	})
end

return MainManager
