function PCspire.setTitle(t)
	love.graphics.setCaption(t)
end

function PCspire.setUpKeyboard()
	love.keyboard.setKeyRepeat(10, 150)
end

function PCspire.getHeight()
	return love.graphics.getHeight()
end

function PCspire.getWidth()
	return love.graphics.getWidth()
end

function PCspire.getMicroTime()
	return love.timer.getMicroTime()
end

function PCspire.sleep(t)
	love.timer.sleep(t)
end

function PCspire.getDirList(dir)
	return love.filesystem.enumerate(dir)
end

function PCspire.isDir(dir)
	return love.filesystem.isDirectory(dir)
end

function PCspire.isFile(file)
	return love.filesystem.isFile(file)
end

----------------------------------
-- Platform specific event code --
----------------------------------

function PCspire.platformLoop()
	PCspire.mouseLoop()

	-------------------------
	-- Process love events --
	-------------------------
	
	if love.event then
		for e,a,b,c in love.event.poll() do
			if e == "q" then
				if not love.quit or not love.quit() then
					return
				end
			end
			love.handlers[e](a,b,c)
		end
	end

	love.graphics.present()
end

function love.focus(f)
	if not f then
		PCspire.debuginfo("Lost focus, calling on.deactivate and on.loseFocus")
		PCspire.callEvent(on.deactivate)
		PCspire.callEvent(on.loseFocus)
	else
		PCspire.debuginfo("Gained focus, calling on.getFocus and invalidating the screen")
		PCspire.callEvent(on.getFocus)
		platform.window:invalidate()
	end
end

function love.quit()
	PCspire.debuginfo("Calling on.save")
	PCspire.CONTINUE	= false
	local retvalue	= PCspire.callEvent(on.save)
	document.save(retvalue)
	print("Quiting")
end


function love.mousepressed(...)
	PCspire.mousepressed(...)
end

function love.mousereleased(...)
	PCspire.mousereleased(...)
end

function PCspire.getMousePos()
	return love.mouse.getPosition()
end 

-------------------
-- Start PCspire --
-------------------

function love.run()
	PCspire.run()
end
