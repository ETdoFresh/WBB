local scrW, scrH = display.contentWidth, display.contentHeight

local Text = require "Text"
local storyboard = require "storyboard"
local scene = storyboard.newScene()

local text, rect, rtext, atext

local function nextScene()
	storyboard.gotoScene("game", "crossFade", 1000)
end

function scene:createScene(event)
	local view = self.view
	
	local bg = display.newRect(view, 0, 0, display.contentWidth, display.contentHeight)
	bg:setFillColor(32, 32, 32)
	
	text = display.newText(view, "Water Gun Boyz", 0, 0, native.systemFontBold, 50)
	rect = display.newRect(view, 0, 0, 200, 100)
	rText = display.newText(view, "Start!", 0, 0, native.systemFontBold, 30)
	atext = display.newText(view, "Game by: ETdoFresh (E.T. Garcia)\nMusic by: KONOYARO (Shawn Lewis)\nSpecial Thx: Nobot (Bobby Benham)", 0, 0, native.systemFontBold, 16)
	local center = {x = scrW / 2, y = scrH / 2}
	
	text.x, text.y = center.x, 55
	rect.x, rect.y = center.x, center.y + 20
	rText.x, rText.y = center.x, center.y + 20
	atext.x, atext.y = center.x, center.y + 160
	rText:setTextColor(0)
end

function scene:enterScene(event)
	-- Setup next stage of music
	storyboard.musicNextFile = "level1intro.mp3"
	audio.loadStream(storyboard.musicNextFile)
	
	-- remove previous scene's view
	local prevScene = storyboard.getPrevious()
	if (prevScene) then storyboard.purgeScene(prevScene) end
	
	rect:addEventListener("tap", nextScene)
end

function scene:exitScene(event)
	rect:removeEventListener("tap", nextScene)
end

scene:addEventListener( "createScene", scene ) -- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "enterScene", scene ) -- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "exitScene", scene ) -- "exitScene" event is dispatched before next scene's transition begins

return scene