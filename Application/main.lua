-- ================================
-- Water Balloon Boyz
-- by ETdoFresh
-- Drag 'N' Dream LLC
-- for Techority 48 Hour Challenge 2012
-- ================================

display.setStatusBar( display.HiddenStatusBar )  -- hide the status bar

-- Requirements
local storyboard = require "storyboard"
-- Load up some music
audio.reserveChannels(1)
storyboard.musicFile = "level1intro.mp3"
storyboard.musicNextFile = "level1intro.mp3"
storyboard.musicHandle = audio.loadSound(storyboard.musicNextFile)
function storyboard.musicFunction()
	if (storyboard.musicNextFile ~= storyboard.musicFile) then
		storyboard.musicHandle = audio.loadStream(storyboard.musicNextFile)
		storyboard.musicFile = storyboard.musicNextFile
	end
	storyboard.music = audio.play(storyboard.musicHandle, {channel=1, loops=0, onComplete = function () storyboard.musicFunction() end})
end
storyboard.musicFunction()
-- Play
storyboard.gotoScene("logo")

