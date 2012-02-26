-- ================================
-- MessageBubble Class
-- ================================
local MessageBubble = {}

function MessageBubble.new(param)
	local self = display.newGroup()
	
	local text = display.newText(param.text, 0, 0, native.systemFont, 16)
	text:setTextColor(0, 0, 0)
	text.x, text.y = 0, 0
	
	local rndRect = display.newRoundedRect(0, 0, text.width + 10, text.height + 10, 12)
	rndRect.x, rndRect.y = 0, 0
	
	local pointer = display.newImageRect("msgPoint.png", 11, 14)
	pointer.x, pointer.y = 10, rndRect.height / 2 + 6
	
	self:insert(rndRect)
	self:insert(pointer)
	self:insert(text)
	
	function self:setPosition(param)
		local offsetX = param.offsetX or 0
		local offsetY = param.offsetY or 0
		local isTop = param.top
		
	end
	
	return self
end

return MessageBubble