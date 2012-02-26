local storyboard = require "storyboard"
local scene = storyboard.newScene()

local background, clouds, logo, moon, center, presents

local function nextScene()
	storyboard.gotoScene("menu", "crossFade", 1000)
end

local function cancelAndFade()
	transition.cancel(logo.tween)
	transition.cancel(clouds.tween)
	transition.cancel(moon.tween)
	transition.cancel(presents.tween)
	clouds.tween = transition.to(clouds, {delay = 0, time = 500, alpha = 0, x = clouds.x - 10})
	moon.tween = transition.to(moon, {delay = 1000, time = 500, alpha = 0, onComplete = nextScene})
	logo.tween = transition.to(logo, {delay = 500, time = 500, alpha = 0})
end

local function onDrag(event)
	local moon = event.target
	if (event.phase == "began") then
		display.getCurrentStage():setFocus(moon)
		moon.isFocus = true
		moon.x, moon.y = event.x, event.y
	elseif (moon.isFocus) then
		if (event.phase == "moved") then
			moon.x, moon.y = event.x, event.y
		elseif (event.phase == "ended" or event.phase == "cancelled") then
			display.getCurrentStage():setFocus(nil)
			moon.isFocus = false
			if (event.x >= center.x - 47 - 24 and event.x <= center.x - 47 + 24)
			and (event.y >= center.y + 25 - 24 and event.y <= center.y + 25 + 24) then
				moon.x, moon.y = center.x - 47, center.y + 25
				moon:removeEventListener("touch", onDrag)
				cancelAndFade()
			end
		end
	end
end

local function enableDrag()
	moon:addEventListener("touch", onDrag)
end

local function disableDrag()
	moon:removeEventListener("touch", onDrag)
	moon.isFocus = false
	display.getCurrentStage():setFocus(nil)
end

function scene:createScene(event)
	local view = self.view
	background = display.newRect(view, 0, 0, display.contentWidth, display.contentHeight)
	background:setFillColor(0, 0, 0)

	clouds = display.newImageRect(view, "logo-02.png", 196, 26)
	logo = display.newImageRect(view, "logo-01.png", 214, 102)
	moon = display.newImageRect(view, "logo-03.png", 39, 52)
	center = {x = display.contentWidth / 2, y = display.contentHeight / 2}
	presents = display.newText(view, "P R E S E N T S", 0, 0, native.systemFontBold, 30)
	
	logo.x = center.x
	logo.y = center.y
	clouds.x = center.x + 125
	clouds.y = center.y
	moon.x = center.x - 70
	moon.y = center.y - 25
	presents.x = center.x
	presents.y = center.y

	logo.alpha = 0
	clouds.alpha = 0
	moon.alpha = 0
	presents.alpha = 0
end

function scene:enterScene(event)
	-- remove previous scene's view
	local prevScene = storyboard.getPrevious()
	if (prevScene) then storyboard.purgeScene(prevScene) end
	
	moon.tween = transition.to(moon, {delay = 0, time = 250, alpha = 1, onComplete = function()
		enableDrag()
		moon.tween = transition.to(moon, {delay = 6000, time = 500, alpha = 0})
	end})
	logo.tween = transition.to(logo, {delay = 0, time = 500, alpha = 1, onComplete = function()
		logo.tween = transition.to(logo, {delay = 5000, time = 500, alpha = 0})
	end})
	clouds.tween = transition.to(clouds, {delay = 500, time = 500, alpha = 1, x = clouds.x - 10, onComplete = function ()
		clouds.tween = transition.to(clouds, {delay = 0, time = 4000, x = clouds.x - 80, onComplete= function()
			disableDrag()
			clouds.tween = transition.to(clouds, {delay = 0, time = 500, alpha = 0, x = clouds.x - 10})
		end})
	end})
	presents.tween = transition.to(presents, {delay = 6750, time = 1500, alpha = 1, onComplete = function()
		presents.tween = transition.to(presents, {delay = 1500, time = 1500, alpha = 0, onComplete = nextScene})
	end})
end

function scene:exitScene( event )
	transition.cancel(logo.tween)
	transition.cancel(clouds.tween)
	transition.cancel(moon.tween)
	transition.cancel(presents.tween)
end

scene:addEventListener( "createScene", scene ) -- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "enterScene", scene ) -- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "exitScene", scene ) -- "exitScene" event is dispatched before next scene's transition begins

return scene