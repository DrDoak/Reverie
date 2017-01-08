local AIWeapons = Class.create("AIWeapons", Entity)

AIWeapons.trackFunctions = {"weaponThreatLevel"}

function AIWeapons:identifyTags( eventName, newTags, params )
	local tags = {}
	if params.other and params.other.currentEquip then--eventName == "characterDetected" or eventName == "characterChangeEquip" then
		local eqp = params.other.currentEquip
		if eqp then
			tags["threat"] = util.sum(self:weaponThreatLevel(eqp,params.other)) * 0.5
			if params.other.targeting == self then
				tags["threat"] = util.sum(self:calculateThreat(weapon))
			end
		end
	end
	return tags
end

function AIWeapons:weaponThreatLevel( weapon , user)
	local threat =  util.sum(self:calculateThreat(weapon)) * ( 1 - util.sum(self:calculateTrust(user)))
	return threat
end

return AIWeapons