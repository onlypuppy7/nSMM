local A, B = 0, 0

while true do
    local z = {}
    local b = {}

    for i = 0, 1760 do
        z[i] = 0
        b[i] = (i % 80 == 79) and "\n" or " "
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
            local x = math.floor(40 + 30 * D * (l * h * m - t * n))
            local y = math.floor(12 + 15 * D * (l * h * n + t * m))
            local o = x + 80 * y
            local N = math.floor(8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n))
            if 0 <= y and y < 22 and 0 <= x and x < 80 and D > z[o] then
                z[o] = D
                local lum = ".,-~:;=!*#$@"
                b[o] = lum:sub(math.max(1, math.min(#lum, N + 1)), math.max(1, math.min(#lum, N + 1)))
            end
        end
    end

    io.write("\027[H") -- ANSI escape to go to top of screen
    for i = 0, 1760 do
        io.write(b[i])
    end

    A = A + 0.04
    B = B + 0.02
end
