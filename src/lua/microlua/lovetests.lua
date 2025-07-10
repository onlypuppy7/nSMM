-- Donut on TI-Nspire with fillRect shading
local A, B = 0, 0

function on.paint(gc)
    A = (A + 4) % 100
    B = (B + 2) % 100
    gc:setColorRGB(255, 0, 0)
    gc:fillRect(A, B, 10, 10)
    print(A, B, 10, 10)
end