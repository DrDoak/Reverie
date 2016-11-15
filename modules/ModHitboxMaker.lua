local ModHitboxMaker = Class.create("ModHitboxMaker", Entity)
local ObjAttackHitbox = require "objects.ObjAttackHitbox"
ModHitboxMaker.trackFunctions = {"registerHit"}

function ModHitboxMaker:createHitbox(wth, hgt, XOffset, YOffset, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	local myWidth = wth
	local guardDamage
	local guardStun
	local unblockable
	local light
	local heavy, faction

	if type(wth) == "table" then
		myWidth = wth["width"] or 40
		hgt = wth["height"] or 40
		XOffset = wth["xOffset"] or 0
		YOffset = wth["yOffset"] or 0
		dmg = wth["damage"] or 10
		stn = wth["stun"] or 20
		pers = wth["persistence"] or 4
		Xforce = wth["xKnockBack"] or 3 * 32
		Yforce = wth["yKnockBack"] or 0
		elem = wth["element"] or "hit"
		deflect = wth["isDeflect"] or false
		guardDamage = wth["guardDamage"] or dmg
		guardStun = wth["guardStun"] or stn
		unblockable = wth["isUnblockable"] or false
		light = wth["isLight"] or false
		heavy = wth["heavy"] or false
		faction = wth["faction"] or self.faction
		-- lume.trace(guardDamage)
	end
	local x = self.x + (XOffset * self.dir)
	local y = self.y - YOffset
	Xforce = Xforce * self.dir
	local ObjAttackHitbox = ObjAttackHitbox(x, y, myWidth, hgt, self, dmg, stn, pers, Xforce, Yforce, elem, deflect)
	ObjAttackHitbox:setGuardDamage(guardDamage)
	ObjAttackHitbox:setGuardStun(guardStun)
	ObjAttackHitbox:setIsUnblockable(unblockable)
	ObjAttackHitbox:setIsLight(light)
	ObjAttackHitbox:setFaction(faction)
	ObjAttackHitbox:setFollow(self, XOffset,YOffset)
	ObjAttackHitbox:setHeavy(heavy)
	Game:add(ObjAttackHitbox)
	return ObjAttackHitbox
end

function ModHitboxMaker:registerHit(target, hitType, hitbox) end

function ModHitboxMaker:addToAttackList( prob,conditionCheck,funct,properties)
	local newList = {}
	newList.weight = prob
	newList.condition = conditionCheck
	newList.funct = funct
	newList.properties = {}
	if properties then
		for i,v in ipairs(properties) do
			newList.properties[v] = true
		end
	end
	table.insert(self.attackList,newList)
end

return ModHitboxMaker