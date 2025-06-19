PCspire	= {}

--------------------
-- Load libraries --
--------------------

-- This is the only function that should be changed when porting to a different platform
function PCspire.loadFile(file)
	return pcall(love.filesystem.load, file)
	-- Returns true and a function if valid
	-- Returns false and a error message if not valid
	
	-- loadFile should check in the PCspire directory and in the PCspire save file directory
end

-- Load the libraries
function PCspire.loadLibs()
	-- Names of libs to load
	local libs	= {'unimplemented.lua','bindings.lua','tools.lua','platform.lua','timer.lua','locale.lua','var.lua','fonts.lua','image.lua','key.lua','mouse.lua','debug.lua','fileloader.lua'}
	local ok,chunk
	for _, lib in ipairs(libs) do
		ok, chunk = PCspire.loadFile(lib)
		if ok and chunk then
			chunk()
		else
			error("Fatal error loading required library " .. lib .. " (" .. chunk .. ")")
		end
	end
end

on	= {}
PCspire.loadLibs()


-------------------
-- Call an event --
-------------------

function PCspire.callEvent(f, ...)
	if f then
		return f(...)
	end
end

-------------------
-- Start PCspire --
-------------------

function PCspire.run()
	-- Dump current variables; for debugging
	PCspire.debugVars()
	
	-- Try to start the user script
	PCspire.ERROR	= true
	while PCspire.ERROR and PCspire.CONTINUE do
		PCspire.ERROR	= false
		xpcall(PCspire.init, PCspire.error)
	end
	
	-- Start the main loop
	PCspire.ERROR	= false
	while PCspire.CONTINUE do
		xpcall(PCspire.main, PCspire.error)
	end
end
	
function PCspire.init()
	print("Starting")
	
	-- Setup keyboard
	PCspire.setUpKeyboard()
	
	-- Load the user script, if any
	PCspire.loadUserScript()
	
	-- Call on.activate (window object is not yet ready!)
	PCspire.callEvent(on.activate)

	-- Create the window object if it doesn't exist yet
	if not platform.window then
		PCspire.debuginfo("Creating Window object")
		platform.window	= Window(PCspire.getWidth(), PCspire.getHeight())
	else
		platform.window:update()
	end
	
	-- Call on.create and on.paint for the first time
	PCspire.debuginfo("Succesfully launched user script")
	PCspire.callEvent(on.create, platform.window.gc)
	platform.window.invalidated	= false
	PCspire.callEvent(on.paint, platform.window.gc)
end

function PCspire.main()

	-----------
	-- Timer --
	-----------
	
	local tm	= PCspire.getMicroTime()
	if timer.running and tm >= timer.delay + timer.lastrun then
		timer.lastrun	= tm
		PCspire.callEvent(on.timer)
	end

	--------------
	-- Graphics --
	--------------

	if platform.window.invalidated then
		local id	=	platform.window.invaliddata
		if id == 0 then
			love.graphics.clear()
		else
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.rectangle("fill", id[1], id[2],id[3],id[4])
		end
		
		PCspire.debuginfo("Window is invalidated, redrawing..")	
		platform.window.gc:default()
		PCspire.callEvent(on.paint, platform.window.gc)
		platform.window.invalidated	= false
		platform.window.invaliddata	= 0				
	end

	---------------------------------------------------------------------------------------
	-- Other events (this is very platform dependent, so it's configured in bindings.lua)--
	---------------------------------------------------------------------------------------
	
	PCspire.platformLoop()
	
	-- Sleep for a little while
	PCspire.sleep(1)
end

function PCspire.loadUserScript()	
	-- PCspire arguments
	for k,v in pairs(arg) do
		if v == "-s" then
			PCspire.scriptname	= arg[k+1]
		elseif v == "-v" then
			PCspire.doDebug	= true
		end
	end

	if PCspire.scriptname then
		-- Set script title
		PCspire.scripttitle	= PCspire.scriptname:gsub("\\","/"):split("/")
		PCspire.scripttitle	= PCspire.scripttitle[#PCspire.scripttitle]
		PCspire.setTitle("PCspire - " .. PCspire.scripttitle)
		
		-- Try to load script
		local ok, chunk	= PCspire.loadFile(PCspire.scriptname)
		if ok then
			-- Loading the document variables and state
			PCspire.debuginfo("Loading script state/variables")
			local state	= document.load()
			
			-- Call the script
			PCspire.debuginfo("Loading script")
			chunk()
			
			-- Pass saved state to on.restore
			PCspire.callEvent(on.restore, state)
		end
	end
end

