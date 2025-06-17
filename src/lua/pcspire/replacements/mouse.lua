function PCspire.mousepressed(x, y, button)
	if button == 'l' then
		PCspire.callEvent(on.mouseDown, x, y)
	elseif button == 'r' then
		PCspire.callEvent(on.rightMouseDown, x, y)
	end
end

function PCspire.mousereleased(x, y, button)
	if button == 'l' then
		PCspire.callEvent(on.mouseUp, x, y)
	elseif button == 'r' then
		PCspire.callEvent(on.rightMouseUp, x, y)
	end
end

PCspire.mouseX	= 0
PCspire.mouseY	= 0

function PCspire.mouseLoop()
	local x, y	= PCspire.getMousePos()
	if x~=PCspire.mouseX or y~=PCspire.mouseY then
		PCspire.mouseX	= x
		PCspire.mouseY	= y
		PCspire.callEvent(on.mouseMove, x, y)
	end
end
