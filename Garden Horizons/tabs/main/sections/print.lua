local Tabs, Options, Fluent = ...

local section = Tabs.Main:AddSection("Print")

section:AddInput("MessageInput", {
	Title = "Message",
	Default = "",
	Placeholder = "Type your message here...",
	Numeric = false,
	Finished = false,
	Callback = function() end
})

section:AddButton({
	Title = "Print Message",
	Description = "Click to print the message to output",
	Callback = function()
		local text = Options.MessageInput.Value
		if text and text ~= "" then
			print("[PrimeXploit]:", text)
			Fluent:Notify({
				Title = "PrimeXploit",
				Content = "Printed: " .. text,
				Duration = 3
			})
		else
			Fluent:Notify({
				Title = "PrimeXploit",
				Content = "Please enter a message first",
				Duration = 3
			})
		end
	end
})