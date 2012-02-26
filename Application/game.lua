-- Helper Variables
local screenW, screenH = display.contentWidth, display.contentHeight

-- Require these files
local storyboard = require "storyboard"
local physics = require "physics"
local Player = require "Player"
local Vector = require "Vector"
local Steering = require "Steering"
local Balloon = require "Balloon"
local Text = require "Text"

-- Start physics engine
physics.start()
physics.setGravity(0, 0)
physics.setScale(30) -- the optimal 0.1m to 10m range corresponds to visible sprites between 3 and 300 pixels in size
physics.setDrawMode("hybrid") -- debug, hybrid, normal
physics.setPositionIterations(8) -- iterate through X position approximations per frame for each object
physics.setVelocityIterations(3) -- iterate through X velocity approximations per frame for each object

local scene = storyboard.newScene()
local view, background, borderTop, borderBottom, borderLeft, borderRight, square, player

local function throwBalloon(releasePoint)
	local pull = Vector.subtract(releasePoint, player)
	local balloon = Balloon.new{time = 1.5, x = player.x, y = player.y, pull = pull, offset = 25}
	view:insert(balloon)
end

local function setTarget(event)
	local adjEvent = Vector.subtract(event, view) -- adjusted event postion based on view
	local distance = Vector.subtract(adjEvent, player)
	distance = Vector.magnitude(distance)
	if (event.phase == "began" and distance <= 32) then
		player.isThrowing = true
		player:setTarget(player)
		if (player.throwCircle) then player.throwCircle:removeSelf() end
		player.throwCircle = display.newCircle(view, player.x, player.y, .001)
		player.throwCircle.alpha = 0.25
	elseif (player.isThrowing) then
		if (event.phase == "moved") then
			distance = math.min(distance, 100)
			player.throwCircle.width = distance * 2
			player.throwCircle.height = player.throwCircle.width
		elseif (event.phase == "ended" or event.phase == "cancelled") then
			local distance = Vector.subtract(event, {x = event.xStart, y = event.yStart})
			distance = Vector.magnitude(distance)
			if (distance > 5) then throwBalloon(adjEvent) end
			player.isThrowing = false
			player.throwCircle:removeSelf()
			player.throwCircle = nil
		end
	else -- If distance > 50
		player:setTarget({x = adjEvent.x, y = adjEvent.y})
	end
end

local function updateView()
	local viewRange = 200
	local adjPlayer = Vector.add(player, view) -- adjusted player postion based on view
	view.x = math.min(screenW / 2 - player.x, 0)
	view.x = math.max(view.x, screenW - background.width)
	view.y = math.min(screenH / 2 - player.y, 0)
	view.y = math.max(view.y, screenH - background.height)
end

function scene:createScene( vent)
	-- Create a view group
	view = display.newGroup()
	self.view:insert(view)

	-- Create a background
	background = display.newRect(view, 0, 0, screenW * 2, screenH * 2)
	background:setFillColor(32, 32, 32)

	-- Create borders around the edges
	borderTop = display.newRect(view, 0, 0, background.contentWidth, 1)
	borderBottom = display.newRect(view, 0, background.contentHeight-1, background.contentWidth, 1)
	borderLeft = display.newRect(view, 0, 0, 1, background.contentHeight)
	borderRight = display.newRect(view, background.contentWidth-1, 1, 1, background.contentHeight)
	square = display.newRect(view, 300,300,50,10)

	
end

function scene:enterScene(event)
	-- remove previous scene's view
	local prevScene = storyboard.getPrevious()
	if (prevScene) then storyboard.purgeScene(prevScene) end

	-- add physics to the borders
	local borderBody = {friction=0.4, bounce=0.2}
	physics.addBody(borderTop, "static", borderBody)
	physics.addBody(borderBottom, "static", borderBody)
	physics.addBody(borderLeft, "static", borderBody)
	physics.addBody(borderRight, "static", borderBody)
	physics.addBody(square, "static", borderBody)

	-- Show level display
	local text = Text.newTitle{title = "Level 1: The Tutorial", time = 10000, fadeIn = 500, x = screenW / 2, y = screenH - 60, titleSize = 30,
		description = "Learn how to move around the level"}
	
	-- Create a player
	player = Player.new()
	view:insert(player)
	player = Steering.new{radius = 16, self = player, target = player}
	player.x, player.y = 100, 100
	player:setSteering("combine")

	for i = 1, 3 do
		local wanderer = Player.new()
		view:insert(wanderer)
		wanderer.x = math.random(10, screenW - 10)
		wanderer.y = math.random(10, screenH - 10)
		wanderer = Steering.new{radius = 16, self = wanderer, maxSpeed = 20}
		wanderer:setSteering("wander")
	end

	Runtime:addEventListener("touch", setTarget)
	Runtime:addEventListener("enterFrame", updateView)
end

function scene:exitScene(event)
	Runtime:removeEventListener("touch", setTarget)
	Runtime:removeEventListener("enterFrame", updateView)
end

scene:addEventListener( "createScene", scene ) -- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "enterScene", scene ) -- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "exitScene", scene ) -- "exitScene" event is dispatched before next scene's transition begins

return scene