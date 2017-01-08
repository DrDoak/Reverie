local ObjBase = require "ObjBase"

local FXReticle = Class.create("FXReticle", ObjBase)

function FXReticle:init(creator, target, reticleSprite)
	self:addModule(require "modules.ModDrawable")
	self:addModule(require "modules.ModReticle")
	self:setFollowTarget(target,0,16)
	self:setCreator(creator)
	self:addSpritePiece(require(reticleSprite or "assets.spr.scripts.SprReticle"))
end

return FXReticle