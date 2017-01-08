local AIAlliances = Class.create("AIAlliances", Entity)
AIAlliances.trackFunctions = {"evaluateAllianceTrust"}

function AIAlliances( character )
	self.rememberedAlliances = self.rememberedAlliances or {}
end
function AIAlliances:evaluateAllianceTrust( character )
	local trust = 0
	local theirAlliance = self:identifyAlliance(character)
	if theirAlliance == self:identifyAlliance(self) then
		trust = trust + 50
	end
	return trust
end

function AIAlliances:identifyAlliance( character )
	local alliance = "none"
	if self.rememberedAlliances[character.name] then
		return self.rememberedAlliances[character.name]
	end
	for k,v in pairs(character.sprites) do
		lume.trace(v.imagename)
	end
	return alliance
end
return AIAlliances