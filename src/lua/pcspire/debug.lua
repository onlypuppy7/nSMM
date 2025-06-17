-- lua.lua - Lua 5.1 interpreter (lua.c) reimplemented in Lua.
--
-- WARNING: This is not completed but was quickly done just an experiment.
-- Fix omissions/bugs and test if you want to use this in production.
-- Particularly pay attention to error handling.
--
-- (c) David Manura, 2008-08
-- Licensed under the same terms as Lua itself.
-- Based on lua.c from Lua 5.1.3.
-- Improvements by Shmuel Zeigerman.

-- Variables analogous to those in luaconf.h


-- Modified by Jim Bauwens for use in PCspire


local LUA_INIT = "LUA_INIT"
local LUA_PROGNAME = "lua"
local LUA_PROMPT   = "> "
local LUA_PROMPT2  = ">> "
local function LUA_QL(x) return "'" .. x .. "'" end

-- Variables analogous to those in lua.h
local LUA_RELEASE   = _VERSION
local LUA_COPYRIGHT = "PCspire debug console"


-- Note: don't allow user scripts to change implementation.
-- Check for globals with "cat lua.lua | luac -p -l - | grep ETGLOBAL"
local _G = _G
local assert = assert
local collectgarbage = collectgarbage
local loadfile = loadfile
local loadstring = loadstring
local pcall = pcall
local rawget = rawget
local select = select
local tostring = tostring
local type = type
local unpack = unpack
local xpcall = xpcall
local io_stderr = io.stderr
local io_stdout = io.stdout
local io_stdin = io.stdin
local string_format = string.format
local string_sub = string.sub
local os_getenv = os.getenv
local os_exit = os.exit


local progname = LUA_PROGNAME

-- Use external functions, if available
local lua_stdin_is_tty = function() return true end
local setsignal = function() end

local function l_message (pname, msg)
  if pname then io_stderr:write(string_format("%s: ", pname)) end
  io_stderr:write(string_format("%s\n", msg))
  io_stderr:flush()
end

local function report(status, msg)
  if not status and msg ~= nil then
    msg = (type(msg) == 'string' or type(msg) == 'number') and tostring(msg)
          or "(error object is not a string)"
    l_message(progname, msg);
  end
  return status
end

local function tuple(...)
  return {n=select('#', ...), ...}
end

local function traceback (message)
  local tp = type(message)
  if tp ~= "string" and tp ~= "number" then return message end
  local debug = _G.debug
  if type(debug) ~= "table" then return message end
  local tb = debug.traceback
  if type(tb) ~= "function" then return message end
  return tb(message, 2)
end

local function docall(f, ...)
  local tp = {...}  -- no need in tuple (string arguments only)
  local F = function() return f(unpack(tp)) end
  setsignal(true)
  local result = tuple(xpcall(F, traceback))
  setsignal(false)
  -- force a complete garbage collection in case of errors
  if not result[1] then collectgarbage("collect") end
  return unpack(result, 1, result.n)
end

local function dostring(s, name)
  local f, msg = loadstring(s, name)
  if f then f, msg = docall(f) end
  return report(f, msg)
end

local function print_version()
  l_message(nil, LUA_RELEASE .. "\n" .. LUA_COPYRIGHT)
end


--FIX? readline support
local history = {}
local function saveline(s)
--  if #s > 0 then
--    history[#history+1] = s
--  end
end


local function get_prompt (firstline)
  -- use rawget to play fine with require 'strict'
  local pmt = rawget(_G, firstline and "_PROMPT" or "_PROMPT2")
  local tp = type(pmt)
  if tp == "string" or tp == "number" then
    return tostring(pmt)
  end
  return firstline and LUA_PROMPT or LUA_PROMPT2
end


local function incomplete (msg)
  if msg then
    local ender = LUA_QL("<eof>")
    if string_sub(msg, -#ender) == ender then
      return true
    end
  end
  return false
end


local function pushline (firstline)
  local prmt = get_prompt(firstline)
  io_stdout:write(prmt)
  io_stdout:flush()
  local b = io_stdin:read'*l'
  if not b then return end -- no input
  if firstline and string_sub(b, 1, 1) == '=' then
    return "return " .. string_sub(b, 2)  -- change '=' to `return'
  else
    return b
  end
end


local function loadline ()
  local b = pushline(true)
  if not b then return -1 end  -- no input
  local f, msg
  while true do  -- repeat until gets a complete line
    f, msg = loadstring(b, "=stdin")
    if not incomplete(msg) then break end  -- cannot try to add lines?
    local b2 = pushline(false)
    if not b2 then -- no more input?
      return -1
    end
    b = b .. "\n" .. b2 -- join them
  end

  saveline(b)
  return f, msg
end


function dotty ()
  local oldprogname = progname
  progname = nil
  while true do
    local result
    local status, msg = loadline()
    if status == -1 then break end
    if status then
      result = tuple(docall(status))
      status, msg = result[1], result[2]
    end
    report(status, msg)
    if status and result.n > 1 then  -- any result to print?
      status, msg = pcall(_G.print, unpack(result, 2, result.n))
      if not status then
        l_message(progname, string_format(
            "error calling %s (%s)",
            LUA_QL("print"), msg))
      end
    end
    if not PCspire.CONTINUE then break end
  end
  io_stdout:write"\n"
  io_stdout:flush()
  progname = oldprogname
end



local function handle_luainit()
  local init = os_getenv(LUA_INIT)
  if init == nil then
    return  -- status OK
  elseif string_sub(init, 1, 1) == '@' then
    dofile(string_sub(init, 2))
  else
    dostring(init, "=" .. LUA_INIT)
  end
end

function exit()
	print("Leaving debugger and script")
	PCspire.CONTINUE	= false
end

function PCspire.error(err)
	print("Error: ", err)
	print("Dropping to lua console")
	print("\nPress CTRL-D to continue and exit() to quit")
	dotty()
	if PCspire.CONTINUE then print("Continuing script...") end
	PCspire.ERROR	= true
end

PCspire.CONTINUE	= true
PCspire.ERROR		= false


function PCspire.debugVars()
	PCspire.oldvars	= {}
	for k, v in pairs(_G) do
		PCspire.oldvars[k]	= true
	end
end

function classis(obj, class)
  return obj.__index == class.__index
end

function isproto(subclass, class)
  return subclass.__proto == class
end

function ObjClassTest(class, objects)
	local out	= {}
	for oi, ob in ipairs(objects) do
		if classis(class, ob[2]) then
			table.insert(out, ob)
			table.remove(objects, oi)
		end
	end
	return out
end

function isSub(class, classes)
	for ci, cl in ipairs(classes) do
		if isproto(class[2], cl[2]) and class[2]~=cl[2] then
			return true, cl
		end
	end
	return false
end

local classStructure	= {}

function gvars()
	local mt, classes, objects = {},{},{}
	for k, v in pairs(_G) do
		if not PCspire.oldvars[k] then
			if type(v) == "table" and v.init then
				if v.__obj then
					table.insert(objects, {k, v})
				else
					table.insert(classes, {k, v, {}})
				end
			end
		end
	end
	
	local is, pr
	local struct	= {}
	for ci, cl in ipairs(classes) do
		is, pr 	= isSub(cl, classes)
		if is then
			table.insert(pr[3], cl)
		else
			table.insert(struct, cl)
		end
	end
	
	for ci, cl in ipairs(struct) do
		printstruct(cl, 0, objects)
	end
end

function printstruct(class, t, objects)
	local tabs	= string.rep("\t",t)
	print(tabs .. "[" .. class[1] .. "]")
	for i, ob in ipairs(ObjClassTest(class[2], objects)) do
		print(tabs .. "\t" .. ob[1])
	end
	for i, cl in ipairs(class[3]) do
		printstruct(cl, t+1, objects)
	end
end


PCspire.doDebug	= false
function PCspire.debuginfo(...)
	if PCspire.doDebug then
		print(...)
	end
end
