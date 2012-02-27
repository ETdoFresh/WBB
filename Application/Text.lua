-- ================================
-- Text Class
-- ================================
local Text = {}

local screenW, screenH = display.contentWidth, display.contentHeight

function Text.newMessageBubble(param)
	local self = display.newGroup()
	
	local text = display.newText(param.text, 0, 0, native.systemFont, 16)
	text:setTextColor(0, 0, 0)
	text.x, text.y = 0, 0
	
	local rndRect = display.newRoundedRect(0, 0, text.width + 10, text.height + 10, 12)
	rndRect.strokeWidth = 1
	rndRect:setFillColor(255, 255, 255, 255)
	rndRect:setStrokeColor(0, 0, 0, 255)
	rndRect.x, rndRect.y = 0, 0
	
	local pointer = display.newImageRect("msgPoint.png", 11, 14)
	pointer.x, pointer.y = 10, rndRect.height / 2 + 5
	
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

function Text.newCC(param)
	local self = display.newGroup()
	
	-- Parameters
	local text = param.text
	local font = param.font or native.systemFont
	local size = param.size or 25
	param.color = param.color or {}
	local r = param.color[1] or 255
	local g = param.color[2] or 255
	local b = param.color[3] or 255
	local a = param.color[4] or 255
	local time = param.time or 1000
	local fadeIn = param.fadeIn or 500
	local fadeOut = param.fadeOut or fadeIn
	local pos = {x = param.x or 0, y = param.y or 0}
	local shadowOffset = param.shadowOffset or 2
	local onComplete = param.onComplete
	
	-- Creation
	local shadow = display.newText(self, text, 0, 0, font, size)
	local text = display.newText(self, text, 0, 0, font, size)
	
	-- Modification
	self.x, self.y = pos.x, pos.y
	self.alpha = 0
	text.x, text.y = 0, 0
	text:setTextColor(r, g, b, a)
	shadow.x, shadow.y = shadowOffset, shadowOffset
	if ((r + g + b) / 3 < 128) then shadow:setTextColor(255, 255, 255, 128)
	else shadow:setTextColor(0, 0, 0, 128) end
	
	-- Animation
	self.tween = transition.to(self, {delay = 0, time = fadeIn, alpha = 1, onComplete = function ()
		self.tween = transition.to(self, {delay = time, time = fadeOut, alpha = 0, onComplete = function ()
			if (onComplete) then onComplete() end
			self:removeSelf()
			self = nil
		end})
	end})
	
	return self
end

function Text.newTitle(param)
	local self = display.newGroup()
	
	-- Parameters
	local title = param.title
	local description = param.description
	local font = param.font or native.systemFont
	local titleSize = param.titleSize or 16
	local descriptionSize = param.descriptionSize or 16
	param.titleColor = param.titleColor or {}
	local tr = param.titleColor[1] or 255
	local tg = param.titleColor[2] or 255
	local tb = param.titleColor[3] or 255
	local ta = param.titleColor[4] or 255
	param.descriptionColor = param.descriptionColor or {}
	local dr = param.descriptionColor[1] or 0
	local dg = param.descriptionColor[2] or 0
	local db = param.descriptionColor[3] or 0
	local da = param.descriptionColor[4] or 255
	param.titleBgColor = param.titleBgColor or {}
	local tbr = param.titleBgColor[1] or 0
	local tbg = param.titleBgColor[2] or 0
	local tbb = param.titleBgColor[3] or 64
	local tba = param.titleBgColor[4] or 255
	param.descriptionBgColor = param.descriptionBgColor or {}
	local dbr = param.descriptionBgColor[1] or 255
	local dbg = param.descriptionBgColor[2] or 255
	local dbb = param.descriptionBgColor[3] or 255
	local dba = param.descriptionBgColor[4] or 255
	local time = param.time or 1000
	local fadeIn = param.fadeIn or 500
	local fadeOut = param.fadeOut or fadeIn
	local pos = {x = param.x or 0, y = param.y or 0}
	local shadowOffset = param.shadowOffset or 2
	local onComplete = param.onComplete
	
	-- Creation
	local titleShadow = display.newText(self, title, 0, 0, font, titleSize)
	local title = display.newText(self, title, 0, 0, font, titleSize)
	local titleBox = display.newRoundedRect(self, 0, 0, screenW - 20, title.height + 5, 12) 
	local titleBoxShadow = display.newRoundedRect(self, 0, 0, titleBox.width, titleBox.height, 12)
	
	-- Modification
	self.x, self.y = screenW, pos.y
	self.alpha = 0
	titleBox.x, titleBox.y = 20, 0
	titleBoxShadow.x, titleBoxShadow.y = titleBox.x - shadowOffset, titleBox.y + shadowOffset
	title.x, title.y = titleBox.x - titleBox.width / 2 + title.width / 2 + 20, titleBox.y
	titleShadow.x, titleShadow.y = title.x + shadowOffset, title.y + shadowOffset
	title:setTextColor(tr, tg, tb, ta)
	titleShadow:setTextColor(0, 0, 0, 128)
	titleBox:setFillColor(tbr, tbg, tbb, tba)
	titleBoxShadow:setFillColor(0, 0, 0, 128)
	
	-- Organization
	self:insert(titleBoxShadow)
	self:insert(titleBox)
	self:insert(titleShadow)
	self:insert(title)
	
	local descriptionShadow, descriptionBox, descriptionBoxShadow
	if (description) then
		-- More Creation
		descriptionShadow = display.newText(self, description, 0, 0, font, descriptionSize)
		description = display.newText(self, description, 0, 0, font, descriptionSize)
		descriptionBox = display.newRect(self, 0, 0, screenW - 40, description.height + 5)
		descriptionBoxShadow = display.newRect(self, 0, 0, descriptionBox.width, descriptionBox.height)
		-- More Modification
		descriptionBox.x, descriptionBox.y = 20, titleBox.height / 2 + descriptionBox.height / 2 + 5
		descriptionBoxShadow.x, descriptionBoxShadow.y = descriptionBox.x - shadowOffset, descriptionBox.y + shadowOffset
		description.x, description.y = descriptionBox.x - descriptionBox.width / 2 + description.width / 2 + 20, descriptionBox.y
		descriptionShadow.x, descriptionShadow.y = description.x + shadowOffset, description.y + shadowOffset
		description:setTextColor(dr, dg, db, da)
		descriptionShadow:setTextColor(0, 0, 0, 128)
		descriptionBox:setFillColor(dbr, dbg, dbb, dba)
		descriptionBoxShadow:setFillColor(0, 0, 0, 128)
		-- More Organization
		self:insert(descriptionBoxShadow)
		self:insert(descriptionBox)
		self:insert(descriptionShadow)
		self:insert(description)
	end
	
	-- Animation
	self.tween = transition.to(self, {delay = 0, time = fadeIn, x = pos.x, alpha = 1, onComplete = function ()
		self.tween = transition.to(self, {delay = time, time = fadeOut, x = screenW, alpha = 0, onComplete = function ()
			if (onComplete) then onComplete() end
			self:removeSelf()
			self = nil
		end})
	end})
	
	
	return self
end

return Text