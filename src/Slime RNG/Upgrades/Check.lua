local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(ReplicatedStorage.Packages.DataService).client
local UpgradeTree = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeTree)
local UpgradeUtils = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeServiceUtils)

local ORIGIN = UpgradeUtils.enums.originDependency

local function getCurrency(name)
	return tonumber(DataService:get(name)) or 0
end

local function canPurchase(upg, ownedTable)
	if not upg.cost then return false end
	if ownedTable[upg.id] then return false end
	if upg.dependency ~= ORIGIN and not ownedTable[upg.dependency] then
		return false
	end
	return getCurrency(upg.cost.currency) >= upg.cost.amount
end

local function fmt(n)
	if not n then return "?" end
	if n >= 1e12 then return ("%.2fT"):format(n / 1e12) end
	if n >= 1e9  then return ("%.2fB"):format(n / 1e9)  end
	if n >= 1e6  then return ("%.2fM"):format(n / 1e6)  end
	if n >= 1e3  then return ("%.2fK"):format(n / 1e3)  end
	return tostring(math.floor(n))
end

local upgrades = DataService:get("upgrades") or {}

local owned, canBuy, locked = {}, {}, {}

for treeName, tree in pairs(UpgradeTree) do
	for id, upg in pairs(tree) do
		if type(upg) == "table" and upg.id then
			if upgrades[id] then
				table.insert(owned, { tree = treeName, id = id, name = upg.name })
			elseif upg.cost then
				local cost = upg.cost
				local have = getCurrency(cost.currency)
				local depOk = (upg.dependency == ORIGIN) or upgrades[upg.dependency] == true

				local entry = {
					tree = treeName,
					id = id,
					name = upg.name,
					currency = cost.currency,
					amount = cost.amount,
					have = have,
					dependency = upg.dependency,
				}

				if canPurchase(upg, upgrades) then
					table.insert(canBuy, entry)
				else
					if not depOk then
						entry.reason = ("requires '%s'"):format(tostring(upg.dependency))
					else
						entry.reason = ("need %s more %s"):format(fmt(cost.amount - have), cost.currency)
					end
					table.insert(locked, entry)
				end
			end
		end
	end
end

table.sort(canBuy, function(a, b) return a.amount < b.amount end)
table.sort(locked, function(a, b) return (a.amount or 0) < (b.amount or 0) end)

print(("Coins = %s  RollCurrency = %s  goop = %s  Rebirths = %s")
	:format(fmt(getCurrency("coins")), fmt(getCurrency("rollCurrency")),
	        fmt(getCurrency("goop")),  fmt(getCurrency("rebirths"))))

print("")
print(("[ Owned : %d ]"):format(#owned))
for _, e in ipairs(owned) do
	print(("  [ %s ] %s  (id=%s)"):format(e.tree, e.name or e.id, e.id))
end

print("")
print(("[ Purchasable : %d ]"):format(#canBuy))
for _, e in ipairs(canBuy) do
	print(("  [ %s ] %s  -  %s %s  (has %s)")
		:format(e.tree, e.name or e.id, fmt(e.amount), e.currency, fmt(e.have)))
end

print("")
print(("[ Locked : %d ]"):format(#locked))
for _, e in ipairs(locked) do
	print(("  [ %s ] %s  -  %s"):format(e.tree, e.name or e.id, e.reason or "?"))
end

return {
	owned = owned,
	canBuy = canBuy,
	locked = locked,
}