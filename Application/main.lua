-- ================================
-- Water Balloon Boyz
-- by ETdoFresh
-- Drag 'N' Dream LLC
-- for Techority 48 Hour Challenge 2012
-- ================================

display.setStatusBar( display.HiddenStatusBar )  -- hide the status bar

-- Global variables
screenW, screenH = display.contentWidth, display.contentHeight

-- Require these files
local physics = require "physics"
local Player = require "Player"
local Vector = require "Vector"
local Steering = require "Steering"
local Balloon = require "Balloon"

-- Start physics engine
physics.start()
physics.setGravity(0, 0)
physics.setScale(30) -- the optimal 0.1m to 10m range corresponds to visible sprites between 3 and 300 pixels in size
physics.setDrawMode("hybrid") -- debug, hybrid, normal
physics.setPositionIterations(8) -- iterate through X position approximations per frame for each object
physics.setVelocityIterations(3) -- iterate through X velocity approximations per frame for each object

-- Create a background
local background = display.newRect(0, 0, screenW, screenH)
background:setFillColor(32, 32, 32)

-- Create borders around the edges
local borderTop = display.newRect(0, 0, display.contentWidth, 1)
local borderBottom = display.newRect(0, display.contentHeight-1, display.contentWidth, 1)
local borderLeft = display.newRect(0, 0, 1, display.contentHeight)
local borderRight = display.newRect(display.contentWidth-1, 1, 1, display.contentHeight)
local square = display.newRect(300,300,50,10)

-- add physics to the borders
local borderBody = {friction=0.4, bounce=0.2}
physics.addBody(borderTop, "static", borderBody)
physics.addBody(borderBottom, "static", borderBody)
physics.addBody(borderLeft, "static", borderBody)
physics.addBody(borderRight, "static", borderBody)
physics.addBody(square, "static", borderBody)

-- Create a player
local player = Player.new()
player = Steering.new{radius = 16, self = player, target = player}
player.x, player.y = 100, 100
player:setSteering("combine")

for i = 1, 3 do
	local wanderer = Player.new()
	wanderer.x = math.random(10, screenW-10)
	wanderer.y = math.random(10, screenH-10)
	wanderer = Steering.new{radius = 16, self = wanderer, maxSpeed = 20}
	wanderer:setSteering("wander")
end

local function throwBalloon(releasePoint)
	local pull = Vector.subtract(releasePoint, player)
	local balloon = Balloon.new{time = 1.5, x = player.x, y = player.y, pull = pull, offset = 25}
end

local function setTarget(event)
	local distance = Vector.subtract(event, player)
	distance = Vector.magnitude(distance)
	if (event.phase == "began" and distance <= 32) then
		player.isThrowing = true
		player:setTarget(player)
		player.throwCircle = display.newCircle(player.x, player.y, .001)
		player.throwCircle.alpha = 0.25
	elseif (player.isThrowing) then
		if (event.phase == "moved") then
			distance = math.min(distance, 100)
			player.throwCircle.width = distance * 2
			player.throwCircle.height = player.throwCircle.width
		elseif (event.phase == "ended" or event.phase == "cancelled") then
			throwBalloon(event)
			player.isThrowing = false
			player.throwCircle:removeSelf()
		end
	else -- If distance > 50
		player:setTarget({x = event.x, y = event.y})
	end
end

Runtime:addEventListener("touch", setTarget)