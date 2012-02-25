-- ================================
-- Balloon Class
-- ================================
local Balloon = {}

function Balloon.new(param)
	local self = display.newImageRect("balloon.png", 19, 25)
	self.rotation = math.random(360) % 360
	local timeToImpact = param.time or 5 -- in seconds
	timeToImpact = timeToImpact * 1000 -- convert to milliseconds
	
	function self:explode()
		local circle = display.newCircle(self.x, self.y, 50)
		circle:setFillColor(0, 0, 255)
	end
	
	return self
end

return Balloon