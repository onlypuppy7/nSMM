--------------
-- Document --
--------------

document	= {}
document.changed	= false

function document.markChanged()
	document.changed	= true
	PCspire.setTitle("*PCspire - " .. PCspire.scripttitle)
end

function document.load()
	if love.filesystem.exists(PCspire.scripttitle ..".state") then
		local ok, chunk	= PCspire.loadFile(PCspire.scripttitle .. ".state")
		if ok then
			chunk()
			PCspire.debuginfo("Loaded script variables and state")
			return document.state
		else
			PCspire.debuginfo("Failed to load script variables and state!")
			var.symbols	= {}
		end
	else
		PCspire.debuginfo("Script has no save file")
		var.symbols	= {}
	end
end

function document.basicSerialize (o)
	if type(o) == "number" then
		return tostring(o)
	else
		return string.format("%q", o)
	end
end

function document.ser(name, value, saved)
	saved = saved or {}			 -- initial value
	document.write(name, " = ")
	if type(value) == "number" or type(value) == "string" then
		document.write(document.basicSerialize(value), "\n")
	elseif type(value) == "table" then
		if saved[value] then		-- value already saved?
			document.write(saved[value], "\n")	-- use its previous name
		else
			saved[value] = name	 -- save name for next time
			document.write("{}\n")		 -- create a new table
			for k,v in pairs(value) do			-- save its fields
				local fieldname = string.format("%s[%s]", name, document.basicSerialize(k))
				document.ser(fieldname, v, saved)
			end
		end
	else
		error("cannot save a " .. type(value))
	end
end

document.code	= ""
document.state	= nil

function document.write(...)
	local line	= ""
	local arg	= {...}
	for i, v in ipairs(arg) do
		line	= line .. tostring(v)
	end	
	document.code	= document.code .. line
end



function document.save(state)
	if state then
		document.markChanged()
		document.ser("document.state", state)
	end
	
	if document.changed then
		document.ser("var.symbols", var.symbols)
		love.filesystem.write(PCspire.scripttitle..".state", document.code)
	end
end