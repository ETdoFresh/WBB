-- ================================
-- Player Class
-- ================================
local Player = {}

-- ================================
-- Requirements
-- ================================
local Vector = require "Vector"
local Text = require "Text"

function Player.new(param)
	param = param or {}
	local image = param.type or "player"
	local self = display.newImageRect(image..".png", 61, 61)
	local wetness = 0
	local wetnessBar = display.newRect(self.parent, 0, 0, 60, 7)
	wetnessBar:setFillColor(0, 0, 0, 0)
	wetnessBar:setStrokeColor(255, 255, 255, 255)
	wetnessBar.strokeWidth = 1
	local wetnessFill = display.newRect(self.parent, 0, 0, 1, 7)
	wetnessFill:setFillColor(0, 0, 255, 255)
	self.maxWetness = 100
	
	local function onCollision(event)
		if (event.other.type == "explosion") then
			local direction = Vector.subtract(event.other, event.target)
			local distance = Vector.magnitude(direction)
			local wetnessText = " did not get wet"
			if (distance < 25) then 
				wetness = wetness + 80
				wetnessText = " got really wet!"
			elseif (distance < 50) then
				wetness = wetness + 35
				wetnessText = " got wet!"
			else
				wetness = wetness + 10
				wetnessText = " felt a trickle!"
			end
		end
	end
	
	local function update(event)
		if (wetnessBar.parent ~= self.parent) then
			self.parent:insert(wetnessFill)
			self.parent:insert(wetnessBar)
		end
		wetnessBar.x = self.x
		local width = wetnessBar.width * wetness / self.maxWetness + .01
		wetnessFill.width = math.min(width, wetnessBar.width)
		wetnessFill.x = wetnessBar.x - wetnessBar.width / 2 + wetnessFill.width / 2
		wetnessBar.y = self.y - self.height / 2 - 10
		wetnessFill.y = wetnessBar.y
		-- Remove
		if (wetness > self.maxWetness) then
			self:removeMe()
		end
	end
	
	local function dryOff(self,val)
		if (wetnessBar) then
			val = val or 1
			wetness = math.max(wetness - val, 0)
		else
			timer.cancel(event.source)
		end
	end
	
	function self:removeMe()
		Runtime:removeEventListener("enterFrame", update)
		wetnessBar:removeSelf()
		wetnessFill:removeSelf()
		self:removeEventListener("collision", onCollision)
		self:dispatchEvent{name = "die", target = self}
	end
	
	self:addEventListener("collision", onCollision)
	Runtime:addEventListener("enterFrame", update)
	timer.performWithDelay(500, dryOff, 0)
	
	return self
end

return Player