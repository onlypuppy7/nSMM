-- Donut on TI-Nspire with fillRect shading
local A, B = 0, 0

function on.paint(gc)
    local z = {}
    local buffer = {}
    local bwidth, bheight = 80, 45
    local scaleX, scaleY = 1, 1

    for i = 0, bwidth * bheight do
        z[i] = 0
        buffer[i] = 0 -- store shade here
    end

    for j = 0, 6.28, 0.07 do
        for i = 0, 6.28, 0.02 do
            local c = math.sin(i)
            local d = math.cos(j)
            local e = math.sin(A)
            local f = math.sin(j)
            local g = math.cos(A)
            local h = d + 2
            local D = 1 / (c * h * e + f * g + 5)
            local l = math.cos(i)
            local m = math.cos(B)
            local n = math.sin(B)
            local t = c * h * g - f * e
            local x = math.floor(bwidth / 2 + bwidth / 2 * D * (l * h * m - t * n))
            local y = math.floor(bheight / 2 + bheight / 2 * D * (l * h * n + t * m))
            local o = x + bwidth * y
            local N = math.floor(12 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))
            if x >= 0 and x < bwidth and y >= 0 and y < bheight and D > z[o] then
                z[o] = D
                buffer[o] = math.max(0, math.min(12, N + 6)) -- store clamped shade here
            end
        end
    end

    -- now draw once per pixel after loops
    for y = 0, bheight - 1 do
        for x = 0, bwidth - 1 do
            local o = x + bwidth * y
            local shade = buffer[o]
            if shade > 0 then
                gc:setColorRGB(15 * shade, 15 * shade, 15 * shade)
                gc:fillRect(x * scaleX, y * scaleY, scaleX + 1, scaleY + 1)
            end
        end
    end
end

function on.timer()
    A = A + 0.04
    B = B + 0.02
    platform.window:invalidate()
end

function on.construction()
    timer.start(0.05)
end