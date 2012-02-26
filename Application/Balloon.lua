-- ================================
-- Balloon Class
-- ================================
local Balloon = {}

-- ================================
-- Requirements
-- ================================
local Vector = require "Vector"

function Balloon.new(param)
	local self = display.newImageRect("balloon.png", 19, 25)
	
	-- ================================
	-- Local Variables
	-- ================================
	local scale = param.scale or 1 -- scale of the Balloon
	local timeToImpact = (param.time or 2) * 1000 -- in seconds (converted to milliseconds)
	local offSet =  param.offSet or 25 -- how much to offSet position in pull direction
	local pull = param.pull or self -- Pull vector
	local maxPull = 100 -- Maximum amount of pull
	local hasExploded = false
	
	-- ================================
	-- Public Variables
	-- ================================
	self.x = param.x or 0
	self.y = param.y or 0
	self.xScale = scale
	self.yScale = scale
	
	-- ================================
	-- Public Functions
	-- ================================
	function self:explode()
		if (not(hasExploded)) then
			hasExploded = true
			local circle = display.newCircle(self.parent, self.x, self.y, .001)
			local function removeCircle() circle:removeSelf() end
			circle.type = "explosion"
			circle:setFillColor(0, 0, 255)
			transition.to(circle, {time = 500, alpha = 1, width = 100, height = 100})
			transition.to(circle, {delay = 500, time = 500, alpha = 0, onComplete=removeCircle})
			self:removeSelf()
			self:dispatchEvent{name = "exploded"}
			timer.performWithDelay(1, function() physics.addBody(circle, {radius = 50 * scale, isSensor = true}) end)
		end
	end
	
	local function onCollision(event)
		-- 90% chance of explosion if thrown hard
		if (event.force > .002 and math.random(0, 10) < 9) then self:explode() end
	end
	
	-- ================================
	-- Constructor
	-- ================================
	-- Add Physics
	physics.addBody(self, {radius = 5 * scale, bounce = 0})
	self.angularVelocity = math.random(-720, 720)
	-- Compute Vectors
	local distance = math.min(Vector.magnitude(pull), maxPull)
	if (distance > 0) then
		local direction = Vector.normalize(pull)
		-- Offset the object
		local offSetVect = Vector.multiply(direction, offSet)
		self.x = self.x - offSetVect.x
		self.y = self.y - offSetVect.y
		-- Set linear velocity
		local velocity = Vector.multiply(direction, distance)
		self:setLinearVelocity(-velocity.x, -velocity.y)
	end
	-- Explode after certain time
	self.timer = self.explode
	timer.performWithDelay(timeToImpact, self)
	self:addEventListener("postCollision", onCollision)
	return self
end

return Balloon