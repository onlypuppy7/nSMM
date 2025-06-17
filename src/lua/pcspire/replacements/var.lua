var	= {}

function var.list()
	local out = {}
	for k, v in pairs(var.symbols) do
		table.insert(out, k)
	end
	
	return out
end	

function var.monitor()   end
function var.unmonitor() end

function var.recall(v)
	if var.symbols[v] then
		return var.symbols[v]
	else
		return nil, "Symbol " .. v .. " does not exist in this document"
	end	
end

function var.recallstr(v)
	if var.symbols[v] then
		return tostring(var.symbols[v])
	else
		return nil, "Symbol " .. v .. " does not exist in this document"
	end	
end

var.recallStr	= var.recallstr

function var.store(v, d)
	document.markChanged()
	if not v or c=="" then
		error("Empty variable name!")
	end
	if not d then
		error("No data specified!")
	end
	if type(d) == "string" then
		d= "\"" .. d .. "\""
	end
	var.symbols[v]	= d
end

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
