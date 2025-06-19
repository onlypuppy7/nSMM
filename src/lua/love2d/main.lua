require("polyfill.all")
require("bindings")

var.store("x", 42)
print(var.recall("x")) -- 42

var.makeNumericList("numlist")
var.storeAt("numlist", 10, 1)
var.storeAt("numlist", 20, 2)

local v, err = var.recallAt("numlist", 2)
print(v, err) -- 20

print(table.concat(var.list(), ", "))


-- require("polyfill.cursor")

function on.charIn(key)
    -- print("Key pressed: " .. key)
    if key == "h" then
        cursor.hide()
    elseif key == "s" then
        cursor.show()
    elseif key == "d" then
        cursor.set("default")
    elseif key == "c" then
        cursor.set("crosshair")
    end
end

-- require("polyfill.d2editor")

print(D2Editor.newRichText())

-- require("polyfill.clipboard")
-- require("polyfill.locale")

function love.load()
    cursor.set("hand pointer")

    clipboard.addText("Hello, world!")
    print(clipboard.getText()) -- Hello, world!

    print(locale.name()) -- en

    print(string.uchar(44)) -- en
end