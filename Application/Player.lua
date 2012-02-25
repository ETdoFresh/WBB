-- ================================
-- Player Class
-- ================================
local Player = {}

-- ================================
-- Requirements
-- ================================
local Vector = require "Vector"

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
			local newText = display.newText(self.parent, wetness, 0, 0, native.systemFont, 16)
			newText.x, newText.y = event.target.x, event.target.y
			newText.alpha = 1
			transition.to(newText, {time = 3000, alpha = 0, onComplete = function () newText:removeSelf() end})
		end
	end
	
	self:addEventListener("collision", onCollision)
	
	return self
end

return Player