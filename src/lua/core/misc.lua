-- Collision detection function; --credit to Love2D
function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2) --returns true if two boxes overlap, false if they don't
    return x1 < x2+w2 and
        x2 < x1+w1 and
        y1 < y2+h2 and
        y2 < y1+h1
end

function pol2binary(num) --returns 0 if negative, 1 if positive
    if num==0 then return 0
    else return ((num/math.abs(num))+1)/2
end end

function sign(num) --returns -1 if negative, 1 if positive
    if num==0 then return 1
    else return (num/math.abs(num))
end end

function timer2rainbow(gc, hue, speed)
    local saturation=0.7 local lightness=0.5
    local chroma = (1 - math.abs(2 * lightness - 1)) * saturation
    local h = ((hue*speed)%360)/60
    local x =(1 - math.abs(h % 2 - 1)) * chroma
    local r, g, b = 0, 0, 0
    if h < 1 then     r,g,b=chroma,x,0
    elseif h < 2 then r,g,b=x,chroma,0
    elseif h < 3 then r,g,b=0,chroma,x
    elseif h < 4 then r,g,b=0,x,chroma
    elseif h < 5 then r,g,b=x,0,chroma
    else r,g,b=chroma,0,x
    end
    local m = lightness - chroma/2
    gc:setColorRGB((r+m)*255,(g+m)*255,(b+m)*255)
end

function addZeros(input, length)
    return tostring(input):padStart(length, '0')
end

function toBinary(num,bits)
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {}    
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end return table.concat(t)
end

function switchTimer(state)
    if state==nil then --fallback, doubt however that it is (or ever will be) used :p
        switchTimer(not timerState)
    else
        if state==true and not timerState==true then --full speed
            timer.stop() timerState=state
            timer.start(0.04)
        elseif state==false and not timerState==false then --safe sleep mode
            timer.stop() timerState=state
            timer.start(0.15) --from my testing, this is slow enough to where the page doesnt freeze when turning off
        end
end end

--todo: replace this garbage with a class or something
function sTimer(time)  return playStage.framesPassed+time  end --set timer vars
function cTimer(timer) return timer-playStage.framesPassed end --calculate timer
function gTimer(timer) return (cTimer(timer)<0)            end --goal timer..? cant think of what to name it