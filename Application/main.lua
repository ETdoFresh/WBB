-- ================================
-- Water Balloon Boyz
-- by ETdoFresh
-- Drag 'N' Dream LLC
-- for Techority 48 Hour Challenge 2012
-- ================================

-- Global variables
screenW, screenH = display.contentWidth, display.contentHeight

-- Require these files
local physics = require "physics"
local Player = require "player"
local Vector = require "Vector"
local Steering = require "Steering"

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

-- Create a player
local player = Player.new()
player = Steering.new{radius = 16, self = player, target = player}
player.x, player.y = 100, 100
player:setSteering("combine")

local function setTarget(event)
	local distance = Vector.subtract(event, player)
	distance = Vector.magnitude(distance)
	if (event.phase == "began" and distance <= 50) then
		player.isThrowing = true
		player:setTarget(player)
		player.throwCircle = display.newCircle(player.x, player.y, .001)
	elseif (player.isThrowing) then
		if (event.phase == "moved") then
			player.throwCircle.width = distance * 2
			player.throwCircle.height = player.throwCircle.width
		elseif (event.phase == "ended" or event.phase == "cancelled") then
			player.isThrowing = false
			player.throwCircle:removeSelf()
		end
	else -- If distance > 50
		player:setTarget({x = event.x, y = event.y})
	end
end

Runtime:addEventListener("touch", setTarget)