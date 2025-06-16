--ui
taskbar=image.new(_R.IMG.cursor2)

text=0
storTime=0
objs=1
fps=0
delta=0
n1=0
n2=0
frames=0
detectTime=0

function inRange(i, min, max)
    return i and (i >= min and i <= max)
end

function inRect(p, r)    --p=point={x,y}, r=rectangle={x,y,w,h}
    return (inRange(p[1],r[1],r[1]+r[3]) and inRange(p[2],r[2],r[2]+r[4]))
end

function on.timer()
    on.charIn()
    platform.window:invalidate()
end

function on.charIn(chr)
    if chr ~= nil then objs=objs+1 end
    if chr=="1" then n1=1 else n1=0 end
    if chr=="2" then n2=2 else n2=0 end
end

function on.escapeKey()
    objs=0
end

function on.arrowUp()
    objs=objs+10
end

timer.start(0.01)

function on.paint(gc)
    --gc:drawImage(_G["wallpaper1"], 0, 0)
    for i=1,objs do 
        gc:drawImage(taskbar, ((2*i))%300, 190-12*(-1+math.ceil(i/150)))
    end
    text=text%100+delta
    frames=frames+1
    gc:drawString("FPS: "..fps.." Objects: "..objs.." Speed: "..delta.." SDrawtime: "..(timer.getMilliSecCounter()-storTime)/1000, 0, 0, top)
    gc:drawString(timer.getMilliSecCounter(), 0, 14, top)
    gc:drawString("Key=AddObj ESC=ClearObjs ", text, 100, top)
    gc:drawString(storTime, 50, 60, top)
    gc:drawString(frames, 150, 60, top)
    gc:drawString(detectTime, 170, 60, top)
    if timer.getMilliSecCounter()-storTime>1000 then
        detectTime=timer.getMilliSecCounter()-storTime
        fps=math.ceil(frames*(timer.getMilliSecCounter()-storTime)/1000)
        frames=0
        storTime=timer.getMilliSecCounter()
        delta=(math.ceil((60/fps)*100))/100
    end
end

