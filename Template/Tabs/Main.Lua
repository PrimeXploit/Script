local MainManager = {}

function MainManager.Init(Tabs, Options, Fluent)
	local section = Tabs:AddSection("Text Printer")

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