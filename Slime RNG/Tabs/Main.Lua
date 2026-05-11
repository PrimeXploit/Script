local MainManager = {}

local CLICK_BUTTON_URL = "https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/src/ClickButton.lua"
local ROLL_BUTTON_PATH = "PlayerGui.Root.BottomBar.ButtonRow.RollButton.IconButton"

local ClickButton

local function loadClickButton()
	if ClickButton then return ClickButton end
	local ok, result = pcall(function()
		local source = (game :: any):HttpGet(CLICK_BUTTON_URL)
		local chunk = (loadstring :: any)(source)
		return chunk()
	end)
	if ok and type(result) == "table" then
		ClickButton = result
		return ClickButton
	end
	return nil, result
end

function MainManager.Init(Tabs, Options, Fluent, Window)
	local section = Tabs:AddSection("Text Printer")

	section:AddButton({
		Title = "Click Roll Button",
		Description = "Triggers a click on the in-game Roll button",
		Callback = function()
			local module, err = loadClickButton()
			if not module then
				Fluent:Notify({
					Title = "PrimeXploit",
					Content = "Failed to load ClickButton: " .. tostring(err),
					Duration = 4
				})
				return
			end

			local ok, clickErr = module.Click(ROLL_BUTTON_PATH)
			if ok then
				Fluent:Notify({
					Title = "PrimeXploit",
					Content = "Clicked RollButton",
					Duration = 2
				})
			else
				Fluent:Notify({
					Title = "PrimeXploit",
					Content = "Click failed: " .. tostring(clickErr),
					Duration = 4
				})
			end
		end
	})

    section:AddButton({
        Title = "Button",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            print("Confirmed the dialog.")
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })

	section:AddInput("PrintInput", {
		Title = "Message",
		Default = "",
		Placeholder = "Type your message here...",
		Numeric = false,
		Finished = false,
		Callback = function(Value) end
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