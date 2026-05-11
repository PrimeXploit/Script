local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker    = require(ReplicatedStorage.Packages.Networker)
local DataService  = require(ReplicatedStorage.Packages.DataService).client
local UpgradeTree  = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeTree)
local UpgradeUtils = require(ReplicatedStorage.Source.Features.Upgrades.UpgradeServiceUtils)

local ORIGIN = UpgradeUtils.enums.originDependency

local networker = Networker.client.new("UpgradeService", {})

local Buy = {}

local function getCurrency(name)
	return tonumber(DataService:get(name)) or 0
end

local function findUpgrade(id)
	for _, tree in pairs(UpgradeTree) do
		if tree[id] then return tree[id] end
	end
	return nil
end

local function canPurchase(upg, ownedTable)
	if not upg.cost then return false end
	if ownedTable[upg.id] then return false end
	if upg.dependency ~= ORIGIN and not ownedTable[upg.dependency] then
		return false
	end
	return getCurrency(upg.cost.currency) >= upg.cost.amount
end

function Buy.one(id)
	local upg = findUpgrade(id)
	if not upg then
		return false, "Upgrade not found"
	end

	local ok, err = networker:fetch("requestUnlock", id)
	if ok then
		print(("[ Buy ] OK %s (%s)"):format(upg.name or id, id))
	else
		warn(("[ Buy ] FAIL %s -> %s"):format(id, tostring(err)))
	end
	return ok, err
end

function Buy.tree(treeName, delay)
	local tree = UpgradeTree[treeName]
	if not tree then
		return 0
	end

	delay = delay or 0.1
	local total = 0

	while true do
		local upgrades = DataService:get("upgrades") or {}
		local list = {}

		for _, upg in pairs(tree) do
			if type(upg) == "table" and upg.id and canPurchase(upg, upgrades) then
				table.insert(list, upg)
			end
		end

		if #list == 0 then break end

		table.sort(list, function(a, b) return a.cost.amount < b.cost.amount end)

		local bought = false
		for _, upg in ipairs(list) do
			if Buy.one(upg.id) then
				total = total + 1
				bought = true
				task.wait(delay)
			end
		end

		if not bought then break end
	end

	return total
end

function Buy.all(delay)
	local total = 0
	for treeName in pairs(UpgradeTree) do
		total = total + Buy.tree(treeName, delay)
	end
	print(("[ Buy ] Purchased %d upgrades total"):format(total))
	return total
end

function Buy.list(ids, delay)
	delay = delay or 0.1
	local total = 0
	for _, id in ipairs(ids) do
		if Buy.one(id) then
			total = total + 1
			task.wait(delay)
		end
	end
	return total
end

return Buy