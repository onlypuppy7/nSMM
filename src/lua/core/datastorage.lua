--PUBLIC LIBRARY FUNCTIONS (storing across multiple tns files)

function string2ext(name,data) --store data as public library function --huge thanks and credit to Adriweb for this solution!!
    _G[name]=data --store the data as lua var
    local bigStr = "Define LibPub "..name.."()=" .. "\nFunc\n:Return \"" .. _G[name] .. "\"\n:EndFunc" --basic string to save as public library function
    math.eval(bigStr) --execute it (save it)
end

function ext2string(document,var) --retrieve data from public library function
    if not document==false then return math.eval(document.."\\"..var.."()") --get from public library function
    else return math.eval(var.."()") --get it locally, for emu testing
    end
end

--DOCUMENT STORAGE FUNCTIONS (just for the one tns file)

function del(var) math.eval("DelVar "..var) end