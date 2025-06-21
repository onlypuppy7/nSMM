local major, minor, revision, codename = love.getVersion()
print(string.format("LÖVE version: %d.%d.%d - %s", major, minor, revision, codename))

require("love2d.pc")

require("love2d.polyfill.all")
require("love2d.bindings")
require("love2d.ttf.fonts")
require("love2d.cursors.setup")