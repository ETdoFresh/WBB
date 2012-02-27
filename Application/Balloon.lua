-- ================================
-- Balloon Class
-- ================================
local Balloon = {}

-- ================================
-- Requirements
-- ================================
local Vector = require "Vector"

function Balloon.new(param)
	local colors = {"Blue", "Green", "Red", "Yellow"}
	local colors = colors[math.random(4)]
	local self = display.newImageRect("balloon"..colors..".png", 19, 25)
	
	-- ================================
	-- Local Variables
	-- ================================
	local scale = param.scale or 1 -- scale of the Balloon
	local timeToImpact = (param.time or 2) * 1000 -- in seconds (converted to milliseconds)
	local offSet =  param.offSet or 25 -- how much to offSet position in pull direction
	local pull = param.pull or self -- Pull vector
	local maxPull = 100 -- Maximum amount of pull
	local hasExploded = false
	local explosion
	local eFrames = {"splash-08.png", "splash-09.png", "splash-10.png", "splash-11.png", "splash-12.png", "splash-13.png", "splash-14.png", "splash-15.png"}
	
	-- ================================
	-- Public Variables
	-- ================================
	self.x = param.x or 0
	self.y = param.y or 0
	self.xScale = scale
	self.yScale = scale
	
	local function nextFrame()
		local x, y = explosion.x, explosion.y
		local i = explosion.currentFrame + 1
		local parent = explosion.parent
		if (explosion) then explosion:removeSelf() end
		if (i > #eFrames) then return true end
		explosion = display.newImageRect(parent, eFrames[i], 101, 100)
		explosion.x, explosion.y = x, y
		explosion.currentFrame = i
		timer.performWithDelay(50, nextFrame)
	end
	
	-- ================================
	-- Public Functions
	-- ================================
	function self:explode()
		if (not(hasExploded)) then
			hasExploded = true
			explosion = display.newImageRect(self.parent, eFrames[1], 101, 100)
			explosion.x, explosion.y = self.x, self.y
			explosion.currentFrame = 1
			explosion.alpha = 0.5
			transition.to(explosion, {time = 50, alpha = 1, onComplete = nextFrame})
			local circle = display.newGroup()
			circle.x, circle.y = self.x, self.y
			circle.type = "explosion"
			timer.performWithDelay(1, function()
				physics.addBody(circle, {radius = 50 * scale, isSensor = true})
			end)
			timer.performWithDelay(600, function()
				circle:removeSelf()
			end)
			self:removeSelf()
			self:dispatchEvent{name = "exploded"}
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
	physics.addBody(self, {radius = 8 * scale, bounce = 0, filter = {categoryBits = 2, maskBits = 253}})
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