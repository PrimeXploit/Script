local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker   = require(ReplicatedStorage.Packages.Networker)
local DataService = require(ReplicatedStorage.Packages.DataService).client
local Zones       = require(ReplicatedStorage.Source.Game.Items.Zones)

local networker = Networker.client.new("ZonesService", {})

local Buy = {}

local function getCoins()
	return tonumber(DataService:get("coins")) or 0
end

local function getMaxZone()
	return math.max(tonumber(DataService:get("maxZone")) or 1, 1)
end

local function fmt(n)
	if not n then return "?" end
	if n >= 1e12 then return ("%.2fT"):format(n / 1e12) end
	if n >= 1e9  then return ("%.2fB"):format(n / 1e9)  end
	if n >= 1e6  then return ("%.2fM"):format(n / 1e6)  end
	if n >= 1e3  then return ("%.2fK"):format(n / 1e3)  end
	return tostring(math.floor(n))
end

function Buy.info()
	local maxZone = getMaxZone()
	local nextId  = maxZone + 1
	local coins   = getCoins()

	if not Zones.hasZone(nextId) then
		return {
			maxZone = maxZone,
			nextId  = nextId,
			coins   = coins,
			maxed   = true,
		}
	end

	local zone = Zones.getZone(nextId)
	return {
		maxZone  = maxZone,
		nextId   = nextId,
		nextName = zone.name,
		price    = zone.price,
		coins    = coins,
		canBuy   = coins >= zone.price,
		maxed    = false,
	}
end

function Buy.check()
	local info = Buy.info()
	if info.maxed then
		print(("[ Zones ] Max zone unlocked (%d).  Coins = %s")
			:format(info.maxZone, fmt(info.coins)))
	elseif info.canBuy then
		print(("[ Zones ] Next: %s (id=%d)  -  cost %s coins  (have %s)  OK")
			:format(info.nextName, info.nextId, fmt(info.price), fmt(info.coins)))
	else
		print(("[ Zones ] Next: %s (id=%d)  -  cost %s coins  (have %s)  NEED %s more")
			:format(info.nextName, info.nextId, fmt(info.price),
			        fmt(info.coins), fmt(info.price - info.coins)))
	end
	return info
end

function Buy.next()
	local info = Buy.info()
	if info.maxed then
		return false, "All zones unlocked"
	end
	if not info.canBuy then
		return false, ("Not enough coins (need %s, have %s)")
			:format(fmt(info.price), fmt(info.coins))
	end

	local ok, err = networker:fetch("requestPurchaseZone")
	if ok then
		print(("[ Zones ] OK %s (id=%d, price=%s)")
			:format(info.nextName, info.nextId, fmt(info.price)))
	else
		warn(("[ Zones ] FAIL %s -> %s")
			:format(info.nextName or tostring(info.nextId), tostring(err)))
	end
	return ok, err
end

function Buy.all(delay)
	delay = delay or 0.25
	local total = 0

	while true do
		local info = Buy.info()
		if info.maxed then
			print(("[ Zones ] Done.  Reached max zone %d."):format(info.maxZone))
			break
		end
		if not info.canBuy then
			print(("[ Zones ] Stop: need %s coins for '%s', have %s")
				:format(fmt(info.price), info.nextName, fmt(info.coins)))
			break
		end

		local ok = Buy.next()
		if not ok then break end
		total = total + 1
		task.wait(delay)
	end

	return total
end

return Buy
