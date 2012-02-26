-- ================================
-- Player Class
-- ================================
local Player = {}

-- ================================
-- Requirements
-- ================================
local Vector = require "Vector"
local MessageBubble = require "MessageBubble"

function Player.new()
	local self = display.newImageRect("player.png", 61, 61)
	
	local function onCollision(event)
		if (event.other.type == "explosion") then
			local direction = Vector.subtract(event.other, event.target)
			local distance = Vector.magnitude(direction)
			local wetness = " did not get wet"
			if (distance < 25) then 
				wetness = " got really wet!"
			elseif (distance < 50) then
				wetness = " got wet!"
			else
				wetness = " felt a trickle!"
			end
			local newText = MessageBubble.new{text = wetness}
			self.parent:insert(newText)
			newText.x, newText.y = event.target.x, event.target.y
			newText.alpha = 1
			transition.to(newText, {delay = 2500, time = 500, alpha = 0, onComplete = function () newText:removeSelf() end})
		end
	end
	
	self:addEventListener("collision", onCollision)
	
	return self
end

return Player