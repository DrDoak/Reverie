local Shop = Class("Shop")
local DialogActive = require "mixin.DialogActive"
local TimedText = require("objects.TimedText")

function Shop.startShop( seller, buyer, items , shopName)
	lume.trace()
	local mShop = Shop.createShop(seller, buyer,items, shopName)
	Game.scene:insert(mShop)
	return mShop
end

function Shop.createShop( seller, buyer , items, shopName)
	lume.trace("Creating Dialog")
	local shopName = shopName or "Shop"
	local Items = {
		title = shopName .. "\nCurrent Money: "..buyer.money .. "\t\t\tCurrent Reals " .. buyer.reals,
		exit = 1+table.getn(items)
	}
	local dialog = {}
	for i,v in ipairs(items) do
		local newOptions = {
			text = v.name .. "\t--\tPrice: " .. v.price,
			action = function ()
				if buyer.money >= v.price then
					buyer.money = buyer.money - v.price
					buyer:setEquipCreateItem(v.item)
					local title = shopName .. "\nCurrent Money: "..buyer.money .. "\t\t\tCurrent Reals " .. buyer.reals
					dialog:setText(title)
					local tb = TimedText("Item Purchased", nil, nil, false)
					Game:add(tb)
					tb:setPosition(250,180)
					tb:setPtSize(30)
					return true
				else
					local title = shopName .. "\nCurrent Money: "..buyer.money .. "\t\t\tCurrent Reals " .. buyer.reals
					local tb = TimedText("Not Enough Money", nil, nil, false)
					Game:add(tb)
					tb:setPosition(250,180)
					tb:setPtSize(30)
					dialog:setText(title)
					return true
				end
			end,
		}
		table.insert(Items,newOptions)
	end
	local ending = {
			text = "Back",
			action = function ()
			end
		}
	table.insert(Items,ending)
	dialog = DialogActive(Items)
	return dialog
end

return Shop