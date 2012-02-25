-- ================================
-- Player Class
-- ================================
local Player = {}

function Player.new()
	local self = display.newImageRect("player.png", 61, 61)

	
	return self
end

return Player