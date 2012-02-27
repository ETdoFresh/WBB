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
physics.setDrawMode("normal") -- debug, hybrid, normal
physics.setPositionIterations(8) -- iterate through X position approximations per frame for each object
physics.setVelocityIterations(3) -- iterate through X velocity approximations per frame for each object

local scene = storyboard.newScene()
local view, background, borderTop, borderBottom, borderLeft, borderRight, player, tree, fountain
local statics, circles, waypoints

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
		player:setTarget(player)
		if (player.canThrow) then
			player.isThrowing = true
			if (player.throwCircle) then player.throwCircle:removeSelf() end
			player.throwCircle = display.newCircle(view, player.x, player.y, .001)
			player.throwCircle.alpha = 0.25
		end
	elseif (player.isThrowing) then
		if (event.phase == "moved") then
			distance = math.min(distance, 100)
			player.throwCircle.width = distance * 2
			player.throwCircle.height = player.throwCircle.width
		elseif (event.phase == "ended" or event.phase == "cancelled") then
			player.hasThrown = true
			local distance = Vector.subtract(event, {x = event.xStart, y = event.yStart})
			distance = Vector.magnitude(distance)
			if (distance > 5) then throwBalloon(adjEvent) end
			player.isThrowing = false
			player.throwCircle:removeSelf()
			player.throwCircle = nil
		end
	else -- If distance > 50
		player.hasMoved = true
		player:setTarget({x = adjEvent.x, y = adjEvent.y})
	end
end

local function updateView()
	local viewRange = 200
	local adjPlayer = Vector.add(player, view) -- adjusted player postion based on view
	view.x = math.min(screenW / 2 - player.x, 100)
	view.x = math.max(view.x, screenW - background.width + 100)
	view.y = math.min(screenH / 2 - player.y, 100)
	view.y = math.max(view.y, screenH - background.height + 100)
end

function scene:createScene( vent)
	-- Create a view group
	view = display.newGroup()
	view.x, view.y = 100, 100
	self.view:insert(view)

	-- Create a background
	background = display.newImageRect(view, "background.jpg", 1400, 1000)
	background.x, background.y = 600, 400

	statics = {}
	circles = {}
	waypoints = {}
	-- Create borders around the edges
	table.insert(statics, display.newRect(view, 0, -100, 1200, 100))
	table.insert(statics, display.newRect(view, 0, 800, 1200, 100))
	table.insert(statics, display.newRect(view, -100, -100, 100, 1000))
	table.insert(statics, display.newRect(view, 1200, -100, 100, 1000))
	-- House
	table.insert(statics, display.newRect(view, 250, 0, 50, 300))
	table.insert(statics, display.newRect(view, 300, 250, 600, 50))
	table.insert(statics, display.newRect(view, 900, 0, 50, 300))
	-- Deck
	table.insert(statics, display.newRect(view, 350, 300, 10, 200))
	table.insert(statics, display.newRect(view, 360, 490, 190, 10))
	table.insert(statics, display.newRect(view, 650, 490, 190, 10))
	table.insert(statics, display.newRect(view, 840, 300, 10, 200))
	-- Tree
	tree = display.newImageRect(view, "tree.png", 296, 290)
	tree.x, tree.y = 200, 635
	table.insert(circles, display.newCircle(view, 200, 635, 60))
	-- Fountain
	fountain = display.newImageRect(view, "fountain.png", 232, 232)
	fountain.x, fountain.y = 1000, 635
	table.insert(circles, display.newCircle(view, 1000, 635, 116))
	-- Waypoints
	table.insert(waypoints, display.newCircle(view, 200, 635, 150))
	table.insert(waypoints, display.newRect(view, 360, 300, 480, 190))
	table.insert(waypoints, display.newCircle(view, 1160, 40, 21))
	
	for i = 1, #statics do statics[i].isVisible = false end
	for i = 1, #circles do circles[i].isVisible = false end
	for i = 1, #waypoints do waypoints[i].isVisible = false end
end

function scene:enterScene(event)
	-- Setup next stage of music
	storyboard.musicNextFile = "level1noball.mp3"
	audio.loadStream(storyboard.musicNextFile)
	
	-- remove previous scene's view
	local prevScene = storyboard.getPrevious()
	if (prevScene) then storyboard.purgeScene(prevScene) end

	-- add physics to the borders
	local borderBody = {friction=0.4, bounce=0.2, filter = {categoryBits = 1, maskBits = 253}}
	-- Loops
	for i = 1, #statics do physics.addBody(statics[i], "static", borderBody) end
	for i = 1, #circles do
		borderBody.filter = nil
		borderBody.radius = circles[i].width / 2
		physics.addBody(circles[i], "static", borderBody)
	end
	for i = 1, #waypoints do
		borderBody.radius = nil
		borderBody.isSensor = true
		physics.addBody(waypoints[i], borderBody)
	end

	-- Create a player
	player = Player.new()
	view:insert(player)
	player = Steering.new{radius = 16, self = player, target = player}
	player.x, player.y = 100, 100
	player:setSteering("combine")

	-- The mission
	---------------
	local missionText
	local mission = 1
	local missionComplete = false
	local currentWaypoint = 0
	local paintBucket = display.newImageRect(view, "bucket.png", 73, 109)
	local enemies = {}
	paintBucket.x, paintBucket.y = 1160, 40
	paintBucket.xScale, paintBucket.yScale = 0.5, 0.5
	paintBucket.isVisible = false
	local function nextMission()
		if (missionComplete) then
			missionComplete = false
			mission = mission + 1
			if (missionText) then transition.to(missionText, {time = 250, alpha = 0}) end			
		end
		if (mission == 1) then
			missionText = Text.newCC{text = "Tap a destination to move there.", time = 500, fadeIn = 250, x = screenW / 2, y = screenH - 30, onComplete = function ()
				if (player.hasMoved) then missionComplete = true end
				nextMission()
			end}
		elseif (mission == 2) then
			currentWaypoint = 1
			missionText = Text.newCC{text = "Move under the tree below.", time = 8000, fadeIn = 500, x = screenW / 2, y = screenH - 30}
		elseif (mission == 3) then
			missionText = Text.newCC{text = "Notice you can keep your finger on\nthe screen and steer your charater.\nGet to the deck!", time = 10000, fadeIn = 500, x = screenW / 2, y = screenH - 50}
		elseif (mission == 4) then
			missionText = Text.newCC{text = "Alright, you seem ready!\nFind the bucket full of waterballoons!\nDon't splash yourself!", time = 10000, fadeIn = 500, x = screenW / 2, y = screenH - 50}
			paintBucket.isVisible = true
		elseif (mission == 5) then
			storyboard.musicNextFile = "level1ball.mp3"
			audio.loadStream(storyboard.musicNextFile)
			player.canThrow = true
			paintBucket.isVisible = false
			missionText = Text.newCC{text = "Touch and drag back on yourself to fling water ballons!", time = 500, fadeIn = 250, x = screenW / 2, y = screenH - 50, onComplete = function ()
				if (player.hasThrown) then missionComplete = true end
				nextMission()
				currentWaypoint = 2
			end}
		elseif (mission == 6) then
			missionText = Text.newCC{text = "The bar above signifies how wet you are.\nIf it fills up, Game Over!\nNow, get back to the deck!", time = 10000, fadeIn = 500, x = screenW / 2, y = screenH - 50}
		elseif (mission == 7) then
			storyboard.musicNextFile = "level2.mp3"
			audio.loadStream(storyboard.musicNextFile)
			missionText = Text.newTitle{title = "Level 2: The Encounter", time = 8000, fadeIn = 500, x = screenW / 2, y = screenH - 60, titleSize = 30,
			description = "Enemies approach!", onComplete = function ()
				missionComplete = true
				nextMission()
			end}
		elseif (mission == 8) then
			missionText = Text.newCC{text = "Use waterballoons to kill all enemies", time = 10000, fadeIn = 500, x = screenW / 2, y = screenH - 50}
			table.insert(enemies, Player.new{type = "npc"})
			table.insert(enemies, Player.new{type = "npc"})
			table.insert(enemies, Player.new{type = "npc"})
			table.insert(enemies, Player.new{type = "npc"})
			table.insert(enemies, Player.new{type = "npc"})
			enemies[1].x, enemies[1].y = 850, 220
			enemies[2].x, enemies[2].y = 520, 380
			enemies[3].x, enemies[3].y = 670, 380
			enemies[4].x, enemies[4].y = 125, 125
			enemies[5].x, enemies[5].y = 275, 520
			local function onEnemyDie(event)
				for i = #enemies, 1, -1 do
					if (event.target == enemies[i]) then table.remove(enemies, i) end
				end
				event.target:die()
				if (#enemies == 0) then
					missionComplete = true
					mission = 99
					nextMission()
				end
			end
			for i = 1, #enemies do
				view:insert(enemies[i])
				enemies[i].rotation = math.random(360)
				enemies[i] = Steering.new{radius = 16, self = enemies[i], maxSpeed = 20}
				enemies[i]:setSteering("wander")
				enemies[i]:addEventListener("die", onEnemyDie)
			end
			enemies[1]:setTarget(player)
			enemies[1]:setSteering("face")
			view:insert(tree)
		elseif (mission > 50) then
			missionText = Text.newTitle{title = "Congratulations!", time = 8000, fadeIn = 500, x = screenW / 2, y = screenH - 60, titleSize = 30,
			description = "You win!", onComplete = function ()
				player:removeMe()
			end}
		end
	end
	
	-- Show level display
	local text = Text.newTitle{title = "Level 1: The Tutorial", time = 8000, fadeIn = 500, x = screenW / 2, y = screenH - 60, titleSize = 30,
		description = "Getting a feel for the game", onComplete = nextMission}
	
	local function checkWaypoint(event)
		if (waypoints[currentWaypoint] == event.other) then
			missionComplete = true
			nextMission()
			currentWaypoint = currentWaypoint + 1
		end
	end
	
	player:addEventListener("collision", checkWaypoint)
	
	view:insert(tree)
	view:insert(fountain)
	
	Runtime:addEventListener("touch", setTarget)
	Runtime:addEventListener("enterFrame", updateView)
	
	local function onPlayerDie()
		player:die()
		storyboard.gotoScene("menu", "crossFade", 2500)
	end
	
	player:addEventListener("die", onPlayerDie)
end

function scene:exitScene(event)
	Runtime:removeEventListener("touch", setTarget)
	Runtime:removeEventListener("enterFrame", updateView)
end

scene:addEventListener( "createScene", scene ) -- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "enterScene", scene ) -- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "exitScene", scene ) -- "exitScene" event is dispatched before next scene's transition begins

return scene