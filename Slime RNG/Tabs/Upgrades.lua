-- Tabs/Upgrades.lua
-- Fluent UI tab for checking + buying upgrades

local Upgrades = {}

function Upgrades.Init(tab, Options, Fluent, Window)
	-- Lazy-load Buy: its top-level require() calls demote the thread identity,
	-- which would make the Fluent AddSection calls below fail with
	-- "lacking capability Plugin".
	local Buy
	local function getBuy()
		Buy = Buy or loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/src/Slime%20RNG/Upgrades/Buy.lua"
		))()
		return Buy
	end

	local function notify(title, content)
		Fluent:Notify({ Title = title, Content = content, Duration = 4 })
	end

	-- ============== Check section ==============
	local checkSection = tab:AddSection("Check")

	checkSection:AddButton({
		Title = "Run Check",
		Description = "Print owned / purchasable / locked upgrades to console",
		Callback = function()
			-- Check.lua is a script, not a module — re-run each click for fresh data
			local fn = loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/src/Slime%20RNG/Upgrades/Check.lua"
			))
			local result = fn()
			notify("Upgrade Check",
				("Owned %d  /  Buy %d  /  Locked %d"):format(
					#result.owned, #result.canBuy, #result.locked))
		end
	})

	-- ============== Buy section ==============
	local buySection = tab:AddSection("Buy")

	local delaySlider = 0.1

	buySection:AddSlider("BuyDelay", {
		Title = "Delay between purchases (s)",
		Default = 0.1,
		Min = 0.05,
		Max = 1,
		Rounding = 2,
		Callback = function(v) delaySlider = v end,
	})

	buySection:AddButton({
		Title = "Buy Main Tree",
		Description = "Purchase everything affordable in 'main'",
		Callback = function()
			task.spawn(function()
				local n = getBuy().tree("main", delaySlider)
				notify("Buy Main", ("Purchased %d upgrades"):format(n))
			end)
		end
	})

	buySection:AddButton({
		Title = "Buy Loot Tree",
		Description = "Purchase everything affordable in 'lootTree'",
		Callback = function()
			task.spawn(function()
				local n = getBuy().tree("lootTree", delaySlider)
				notify("Buy Loot", ("Purchased %d upgrades"):format(n))
			end)
		end
	})

	buySection:AddButton({
		Title = "Buy Player Tree",
		Description = "Purchase everything affordable in 'playerTree'",
		Callback = function()
			task.spawn(function()
				local n = getBuy().tree("playerTree", delaySlider)
				notify("Buy Player", ("Purchased %d upgrades"):format(n))
			end)
		end
	})

	buySection:AddButton({
		Title = "Buy All Trees",
		Description = "Loop all trees until nothing is purchasable",
		Callback = function()
			task.spawn(function()
				local n = getBuy().all(delaySlider)
				notify("Buy All", ("Purchased %d upgrades total"):format(n))
			end)
		end
	})

	-- ============== Manual section ==============
	local manualSection = tab:AddSection("Manual")

	local manualId = ""

	manualSection:AddInput("ManualId", {
		Title = "Upgrade ID",
		Default = "",
		Placeholder = "e.g. backpack",
		Callback = function(v) manualId = v end,
	})

	manualSection:AddButton({
		Title = "Buy One",
		Description = "Purchase the upgrade by id",
		Callback = function()
			if manualId == "" then
				notify("Buy One", "Enter an ID first")
				return
			end
			task.spawn(function()
				local ok, err = getBuy().one(manualId)
				if ok then
					notify("Buy One", "OK: " .. manualId)
				else
					notify("Buy One", "FAIL: " .. tostring(err))
				end
			end)
		end
	})
end

return Upgrades
