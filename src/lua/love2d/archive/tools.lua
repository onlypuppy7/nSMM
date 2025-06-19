class = function(prototype)
    local derived={}

 	if prototype then
		derived.__proto	= prototype
 		function derived.__index(t,key)
 			return rawget(derived,key) or prototype[key]
 		end
 	else
 		function derived.__index(t,key)
 			return rawget(derived,key)
 		end
 	end
 	
 	function derived.__call(proto,...)
 		local instance={}
 		setmetatable(instance,proto)
 		instance.__obj	= true
 		local init=instance.init
 		if init then
 			init(instance,...)
 		end
 		return instance
 	end
 	
 	setmetatable(derived,derived)
 	return derived
end


function string.uchar(c)
	c = c<256 and c or 100
	return string.char(c)
end

function string:ubyte(...)
	return string.byte(self, ...)
end

function string:usub(...)
	return string.sub(self, ...)
end



function string:split(pattern)
	self_type = type(self)
	pattern_type = type(pattern)
	if (self_type ~= 'string' and self_type ~= 'number') then
		buffer = [[bad argument #1 to 'split' (string expected, got ]] .. self_type .. [[)]]
		error(buffer)
	end
	if (pattern_type ~= 'string' and pattern_type ~= 'number' and pattern_type ~= 'nil') then
		buffer = [[bad argument #2 to 'split' (string expected, got ]] .. pattern_type .. [[)]]
		error(buffer)
	end
	
	pattern = pattern or '%s+'
	local start = 1
	local list = {}
	while true do
		local b, e = string.find(self, pattern, start)
		if b == nil then	
			list[#list+1] = string.sub(self, start)
			break
		end
		list[#list+1] = string.sub(self, start, b-1)
		start = e + 1
	end
	return list
end


function math.round(n)
	return math.floor(n+.5)
end
