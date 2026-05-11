-- Tabs/Zones.lua
-- Fluent UI tab for checking + buying zones

local Zones = {}

function Zones.Init(tab, Options, Fluent, Window)
	-- Lazy-load Buy: top-level require() in the module demotes thread identity,
	-- which would make Fluent AddSection calls fail with "lacking capability Plugin".
	local Buy
	local function getBuy()
		Buy = Buy or loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/PrimeXploit/Script/refs/heads/main/src/Slime%20RNG/Zones/Buy.lua"
		))()
		return Buy
	end

	local function notify(title, content)
		Fluent:Notify({ Title = title, Content = content, Duration = 4 })
	end

	local function fmt(n)
		if not n then return "?" end
		if n >= 1e12 then return ("%.2fT"):format(n / 1e12) end
		if n >= 1e9  then return ("%.2fB"):format(n / 1e9)  end
		if n >= 1e6  then return ("%.2fM"):format(n / 1e6)  end
		if n >= 1e3  then return ("%.2fK"):format(n / 1e3)  end
		return tostring(math.floor(n))
	end

	-- ============== Check section ==============
	local checkSection = tab:AddSection("Check")

	checkSection:AddButton({
		Title = "Run Check",
		Description = "Print current zone, next zone price, and your coins",
		Callback = function()
			local info = getBuy().check()
			if info.maxed then
				notify("Zones", ("Maxed at zone %d"):format(info.maxZone))
			elseif info.canBuy then
				notify("Zones", ("Next: %s  (%s coins)  OK")
					:format(info.nextName, fmt(info.price)))
			else
				notify("Zones", ("Next: %s  need %s more")
					:format(info.nextName, fmt(info.price - info.coins)))
			end
		end
	})

	-- ============== Buy section ==============
	local buySection = tab:AddSection("Buy")

	local delaySlider = 0.25

	buySection:AddSlider("ZoneBuyDelay", {
		Title = "Delay between purchases (s)",
		Default = 0.25,
		Min = 0.1,
		Max = 2,
		Rounding = 2,
		Callback = function(v) delaySlider = v end,
	})

	buySection:AddButton({
		Title = "Buy Next Zone",
		Description = "Unlock the next zone (checks coins first)",
		Callback = function()
			task.spawn(function()
				local ok, err = getBuy().next()
				if ok then
					notify("Buy Zone", "Unlocked next zone")
				else
					notify("Buy Zone", "FAIL: " .. tostring(err))
				end
			end)
		end
	})

	buySection:AddButton({
		Title = "Buy All Affordable",
		Description = "Keep buying zones while you have enough coins",
		Callback = function()
			task.spawn(function()
				local n = getBuy().all(delaySlider)
				notify("Buy Zones", ("Unlocked %d zones"):format(n))
			end)
		end
	})
end

return Zones
