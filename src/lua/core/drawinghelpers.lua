function drawSlantedRect(gc,xyw) --this is literally only for the OP7 logo at startup...
    gc:drawLine(xyw[1],xyw[2]+xyw[3],xyw[1]+xyw[3],xyw[2]) --you thought i'd explain this??
    gc:drawLine(xyw[1]+xyw[3],xyw[2],xyw[1]+2*xyw[3],xyw[2]+xyw[3])
    gc:drawLine(xyw[1]+2*xyw[3],xyw[2]+xyw[3],xyw[1]+xyw[3],xyw[2]+2*xyw[3])
    gc:drawLine(xyw[1]+xyw[3],xyw[2]+2*xyw[3],xyw[1],xyw[2]+xyw[3])
end