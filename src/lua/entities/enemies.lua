--------------------------
-----GOOMBA FUNCTIONS----- OLD drawing format#################################################################
--------------------------
objGoomba=class(objAPI)

    function objGoomba:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("goomba77215",64,64,"goomba")
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true
    end

    function objGoomba:logic() --handle both movement and animation
        self:checkStuckInWall()
        self.doMovements=false
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            self:checkMarioCollision({"stomp",3})
            self.doMovements=true
        elseif self.status==4 then self:animateDeathFlyOffscreen() --fireball/flower
        elseif self.status==3 and (self.deathAnimTimer<playStage.framesPassed) then --stomped
            self:destroy()
        end
    end
    
    function objGoomba:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,4) end
    end

    function objGoomba:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE..(self.status or "1")],x,y)
    end

--------------------------
--PIRANHA PLANT FUNCTIONS- NEW drawing format
--------------------------
objPiranhaPlant=class(objAPI)

    function objPiranhaPlant:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("piranhaplant_1r2923",64,64,"piranhaplant_1",true)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},0,0)
        self.status=1 self.despawnable=false self.interactSpring=false
        self.moveTimer=50 --how far into the rising thing it is
        self.riseTimer=5 --frames to wait before rising
        local  TYPE=string.sub(self.TYPE,14,14) -- 1=up ↑ , 2=right → , 3=down ↓ , 4=left ←
        if     TYPE=="1" then self.move={"x",1,"y",-1}                  --up
        elseif TYPE=="2" then self.move={"y",1,"x",1}   self:moveY(-16) --right
        elseif TYPE=="3" then self.move={"x",-1,"y",1}  self:moveY(-16) --down
        elseif TYPE=="4" then self.move={"y",-1,"x",-1}                 --left
        end self:moveX(8) self:moveY(-10) self:determineHitbox()
    end

    function objPiranhaPlant:moveX(amount) self[self.move[1]]=self[self.move[1]]+self.move[2]*amount end --moves on the x axis, relative to the direction the plant is facing
    function objPiranhaPlant:moveY(amount) self[self.move[3]]=self[self.move[3]]+self.move[4]*amount end

    function objPiranhaPlant:determineHitbox()
        local  TYPE=string.sub(self.TYPE,14,14) --hardcoding is quicker, easier and more efficient than doing some cool code... i think
        if     TYPE=="1" then self.hitBoxSTOR={16,20,true,true,0,14} --up
        elseif TYPE=="2" then self.hitBoxSTOR={20,16,true,true,-4,0} --right
        elseif TYPE=="3" then self.hitBoxSTOR={16,20,true,true,0,-3} --down
        elseif TYPE=="4" then self.hitBoxSTOR={20,16,true,true,14,0} --left
        end self.hitBox=self.hitBoxSTOR
    end

    function objPiranhaPlant:logic() --handle both movement and animation
        if not self.dead then
    --CHECK IF MARIO COLLIDED
            if not (mario.starTimer>playStage.framesPassed) then
                local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
                if checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+2+self.hitBoxSTOR[5],self.y+2+self.hitBoxSTOR[6],self.hitBoxSTOR[1]-4,self.hitBoxSTOR[2]-4) then --hit mario (side)
                    mario:powerDownMario()
            end end
    --X/Y AXIS
            self.moveTimer=self.moveTimer+1
            if     self.moveTimer<=12 then self:moveY(2)
            elseif self.moveTimer<=36 then --stay put
            elseif self.moveTimer<=48 then self:moveY(-2)
            else self.hitBox=false self.riseTimer=self.riseTimer-1
                if (math.abs(mario.x-self.x))>=35 then
                    if self.riseTimer<=0 then
                        self.moveTimer=0 self.riseTimer=32 self.hitBox=self.hitBoxSTOR
            end end end
        else self:animateDeathFlyOffscreen()
    end end

    function objPiranhaPlant:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,1,"piranhaplant_3") end
    end

    function objPiranhaPlant:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            if isIcon then
                local offsets={
                    {0,-11},{-4,0},{0,-5},{-11,0}
                }
                offsets=offsets[tonumber(string.sub(TYPE,14,14))]
                gc:drawImage(texs[TYPE.."_1"],x+offsets[1],y+offsets[2])
            else
                if TYPE=="piranhaplant_2" then x=x-16 end
                if TYPE=="piranhaplant_3" then y=y-16 end
                gc:drawImage(texs[TYPE.."_1"],x,y)
            end
        else
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            gc:drawImage(texs[TYPE.."_"..self.status],x,y)
        end
    end


--------------------------
---BULLET BILL FUNCTIONS-- NEW drawing format(N/A)
--------------------------
objBulletBill=class(objAPI)

    function objBulletBill:setup(objectID,posX,posY,TYPE,despawnable,fromBlaster,arg2) --eg ("bullet_L8173831",64,64,"bullet_L",true)
        self:initObject(objectID,TYPE,fromBlaster and "inner" or "outer",{16,16,false,true},{posX,posY},true,0)
        self.status=1 self.despawnable=true self.interactSpring=false self.disableStarPoints=true
        self.vx=(self.TYPE=="bullet_L") and -3 or 3
        self.timer=fromBlaster and sTimer(5) or false
        if not fromBlaster then objAPI:transferLayer(self.objectID,"inner","outer") end
    end

    function objBulletBill:logic() --handle both movement and animation
        if not self.dead then
    --MARIO COLLISION, X AXIS
            self:checkMarioCollision({"dropkill"})
            self.x=self.x+self.vx
        else self:animateDeathFlyOffscreen()
        end
    --LAYER STUFF
        if self.timer and gTimer(self.timer) then
            objAPI:transferLayer(self.objectID,self.LEVEL,"outer")
            self.LEVEL="outer"
            self.timer=false
        end
    end

    function objBulletBill:hit(circumstance) --doesnt use standard function as not much needed
        if circumstance=="mario" then self.dead=true self.vy=0.5 end
    end

    function objBulletBill:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE],x,y)
    end


--------------------------
-----BLASTER FUNCTIONS---- NEW drawing format(N/A)
--------------------------
objBlaster=class(objAPI)

    function objBlaster:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --possible types: blaster_L blaster_R blaster_LR
        self:initObject(objectID,TYPE,"inner",nil,{posX,posY},true,0)
        self.despawnable=false self.timer=sTimer(30) self.interactSpring=false self.disableStarPoints=true
        local v=pixel2plot(self.x,self.y,true) plot2place(99,(v[1]+1),v[2]) --make block solid
    end

    function objBlaster:logic()
        if gTimer(self.timer) then
            if (math.abs(mario.x-self.x))>=48 then --mario distance
                if mario.x<self.x and (self.TYPE=="blaster_L" or self.TYPE=="blaster_LR") and pixel2solid(self.x-8,self.y+8,true)==false then --shoot left
                    objAPI:createObj("bullet_L",self.x,self.y,nil,true)
                    objAPI:sendToFront(self.objectID,self.LEVEL)
                    self.timer=sTimer(60)
                elseif mario.x>self.x and (self.TYPE=="blaster_R" or self.TYPE=="blaster_LR") and pixel2solid(self.x+20,self.y+8,true)==false then --shoot right
                    self.timer=sTimer(60)
                    objAPI:createObj("bullet_R",self.x,self.y,nil,true)
                    objAPI:sendToFront(self.objectID,self.LEVEL)
    end end end end

    function objBlaster:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs.blaster,x,y)
        if isEditor then
            local icon=(TYPE=="blaster_L") and "al" or TYPE=="blaster_R" and "ar" or "lx"
            gc:drawImage(texs["icon_"..icon],x,y)
    end end

--------------------------
------KOOPA FUNCTIONS----- OLD drawing format#################################################################
--------------------------
objKoopa=class(objAPI)

    function objKoopa:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},self.vx or true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true
        self.noFall=(self.TYPE=="koopa_R")
    end

    function objKoopa:logic() --handle both movement and animation
        -- self:checkStuckInWall()
        self.doMovements=false
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            self:checkMarioCollision({"transform","shell"..string.sub(self.TYPE,6,8),0,true,4})
            self.doMovements=true
            self:setNewPushV() self:checkFor()
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objKoopa:hit(circumstance)
        if not self.dead then
            if not (self.TYPE=="koopa_B" and circumstance=="fireball") then
                self:handleHitDefault(circumstance,3)
    end end end

    function objKoopa:draw(gc,x,y,TYPE,isEditor,isIcon)
        local offset=(TYPE=="koopa_B") and 0 or -16
        if isEditor then
            if isIcon and offset==-16 then
                gc:drawImage(texs["L_"..TYPE.."_2"],x,y-11)
            else
                gc:drawImage(texs["L_"..TYPE.."_2"],x,y+offset)
            end
        else
            if not (self.status==4 and self.dead) then
                local facing=(self.vx<0) and "L_" or "R_"
                gc:drawImage(texs[facing..TYPE.."_"..self.status],x,y+offset) --eg "L_koopa_G_1"
    end end end

--------------------------
----PARAKOOPA FUNCTIONS--- NEW drawing format
--------------------------
objKoopaPara=class(objAPI)

    function objKoopaPara:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,true,true},{posX,posY},true,0)
        self.status=1 self.despawnable=false --for now, unless pipe spawning added
        self.turnAround=true self.doesBounce=(self.TYPE=="Pkoopa_G")
        local config=self.TYPE:split("_")
        self.facing="L_"
        if config[2]=="R" then self.interactSpring=false
            self.count=23 --half of 44, which is the total number of frames, add one for some reason (idk dont ask)
            if config[3]=="V" then      self.config={nil,2.774444}        --vertical (all values are precalculated from the calcHeight.tns tool)
            elseif config[3]=="H" then  self.config={2.774444,nil}        --horizontal
            elseif config[3]=="HV" then self.config={2.774444,2.55195,10} --horizontal and vertical (vertical loop is purposely offset)
            else                        self.config={nil,nil}             --stationary
    end end end

    function objKoopaPara:logic() --handle both movement and animation
        self.doMovements=false
        if not self.dead then
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkMarioCollision({"transform",string.sub(self.TYPE,2,8),0,true,4})
            if self.TYPE=="Pkoopa_G" then --bouncing koopa
                self.facing=(self.vx>0) and "R_" or "L_"
            else --flying koopa
                local function calc(top,HV) return math.round((math.sin(((self.count-(HV and 17 or 0))*(180/(HV or 44)))/57.296))*top) end --44 is the total frames of the loop
                self.vx=(self.config[1]) and -calc(self.config[1]) or 0 --important! value here is inversed so they fly *up* when loaded
                self.vy=(self.config[2]) and calc(self.config[2],self.config[3]) or 0
                if self.config[1] then self.facing=(self.count%88)<=44 and "L_" or "R_"
                else self.facing=(mario.x>self.x) and "R_" or "L_" end
                self.count=self.count+1
            end
            self.doMovements=true
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objKoopaPara:hit(circumstance)
        if not self.dead then self:handleHitDefault(circumstance,3) end
    end

    function objKoopaPara:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            if isIcon then
                gc:drawImage(texs["L_"..string.sub(TYPE,1,8).."_2"],x,y-11)
            else              gc:drawImage(texs["L_"..string.sub(TYPE,1,8).."_2"],x,y-16) end
            if string.sub(TYPE,1,8)=="Pkoopa_R" then
                local params=TYPE:split("_")
                local config,icon=params[3]
                if config=="V"      then icon="ly"
                elseif config=="H"  then icon="lx"
                elseif config=="HV" then icon="m1"
                else                     icon="m0"
                end gc:drawImage(texs["icon_"..icon],x+8,y)
            end
        else
            if not self.dead then 
                self.status=((math.ceil((playStage.framesPassed/4)))%2)+1
            end
            gc:drawImage(texs[self.facing..string.sub(TYPE,1,8).."_"..self.status],x,y-16)
    end end

--------------------------
------SHELL FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objShell=class(objAPI)

    function objShell:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("shell_g77215",64,64,"shell_g",-4,false)
        self:initObject(objectID,string.sub(TYPE,1,7),"inner",{16,16,true,true},{posX,posY},arg1 or 0,0)
        local params=TYPE:split("_")
        self.status=1 self.despawnable=false self.vx=tonumber(params[3] or self.vx)
        self.koopaTimer=arg2 and playStage.framesPassed+200 or false
        self.fromKoopa=arg2 or false self.hitTimer=0 self.hitCount=0
        self.canHitSide=true self.turnAround=true
    end

    function objShell:logic() --handle both movement and animation
        self:checkStuckInWall()
        self.doMovements=false
        if not self.dead then
    --MARIO COLLISION, SHELL BOUNDARY, X AXIS, Y AXIS + PLATFORMS
            if self.hitTimer-playStage.framesPassed<=0 then self:checkMarioCollision({"shell"},true) end
            if self.vx~=0 then objAPI:addHitBox(self.objectID,self.x,self.y,16,16,"shell") self.canCollectCoins=true
            else self.canCollectCoins=false end
            self.doMovements=true
    --ANIMATION
            if not self.dead then
                if self.koopaTimer==false then self.status=1
                elseif self.fromKoopa then
                    if self.koopaTimer<playStage.framesPassed then
                        objAPI:createObj("koopa"..string.sub(self.TYPE,6,8),self.x,self.y)
                        self:destroy() self.status=0
                    elseif (self.koopaTimer-7<playStage.framesPassed) then self.status=2
                    elseif (self.koopaTimer-45<playStage.framesPassed) then
                        local animOption=((math.ceil((playStage.framesPassed)))%4)
                        self.status=(animOption==0 or animOption==2) and 1 or (animOption==1) and 4 or 5
                    else self.status=1
                    end
                else self.koopaTimer=false
            end end
        elseif self.dead then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objShell:handleShellPoints()
        self.hitCount=self.hitCount+1
        if self.hitCount~=0 then
            if self.hitCount<(#hitProgressionKoopa+1) then objAPI:addStats("points",hitProgressionKoopa[self.hitCount],self.x,self.y+16)
            else objAPI:addStats("1up",1,self.x,self.y+16)
    end end end

    function objShell:hit(circumstance)
        if not self.dead then
            if not (self.TYPE=="shell_B" and circumstance=="fireball") then
                self:handleHitDefault(circumstance,3)
    end end end

    function objShell:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            gc:drawImage(texs[string.sub(TYPE,1,7).."_1"],x,y)--"shell_R_1"
            local config=TYPE:split("_")
            local icon=tonumber(config[3])
            if     icon==-4 then icon="al"
            elseif icon==4  then icon="ar"
            elseif icon==-6 then icon="a2"
            elseif icon==6  then icon="a1"
            else icon=false end
            if icon then gc:drawImage(texs["icon_"..icon],x,y) end
        else
            if self.status~=0 then
                local offsetY=0 if not studentSoftware and (self.status==4 or self.status==5) then offsetY=-2 end
                gc:drawImage(texs[TYPE.."_"..self.status],x,y+offsetY)--"shell_R_1"
    end end end

--------------------------
-----BOWSER FUNCTIONS----- NEW drawing format
--------------------------
objBowser=class(objAPI)

    function objBowser:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("goomba77215",64,64,"goomba")
        self:initObject(objectID,TYPE,"inner",{32,32,true,true,0,-16},{posX,posY,32},1,0)
        self.status=1 self.despawnable=false
        self.turnAround=true self.hp=5 self.destroyShell=true
        self.jumpCountdown=-1
        self.fireCountdown=-100
        self.turnCountdown=120
        self.maxRange={posX-64,posX+64}
    end

    function objBowser:logic() --handle both movement and animation
        self:checkStuckInWall()
        if not self.dead then
            self.jumpCountdown=self.jumpCountdown-1
            self.fireCountdown=self.fireCountdown-1
            self.turnCountdown=self.turnCountdown-1
            if self.jumpCountdown<1 then
                if self.jumpCountdown==0 and self.vy==0 then
                    self.vy=12
                end
                self.jumpCountdown=math.random(20,75)
            end
            if mario.x>self.x then
                self.vx=1.5 self.fireCountdown=70
            else
                self.vx=sign(self.vx)
                if     self.x<self.maxRange[1] then self.vx=1
                elseif self.x>self.maxRange[2] then self.vx=-1
                elseif self.turnCountdown<1 and (self.x>(self.maxRange[1]+16)) and (self.x<(self.maxRange[2]-16)) then
                    self.vx=-self.vx
                    self.turnCountdown=math.random(100,280)
            end end
            if self.vy==0 then self.lastY=pixel2snapgrid(0,self.y,16,16,false)[2] end
            --table.insert(debugBoxes,{self.x-16,self.lastY,24,16})
            --table.insert(debugBoxes,{self.x-16,self.lastY-16,24,16})
            --table.insert(debugBoxes,{self.x-16,self.lastY-16-16,24,16})
    --ANIMATION, MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkMarioCollision({false},true,-16)
            self:aggregateCheckX(self.px,true)
            if self.fireCountdown>1 then
                self:aggregateCheckX(self.vx)
            elseif self.fireCountdown<-10 then
                objAPI:createObj("flame_L",self.x-20,self.y-16,nil,self.lastY-math.random(0,2)*16)
                self.fireCountdown=math.random(10,120)
            end despook=self.turnCountdown
            self:calculateAccelerationY(1.03,-4.5)
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
            self.facing=(mario.x>self.x) and "R" or "L"
        elseif self.status==3 then self:animateDeathFlyOffscreen() --fireball/flower
        end
    end

    function objBowser:hit(circumstance)
        -- if not self.dead then self:handleHitDefault(circumstance,4) end
        if not self.dead then
            if circumstance=="fireball" or circumstance=="shell" then
                self.hp=self.hp-1
                if self.hp<=0 then self:hit("mario") end
            elseif circumstance=="mario" then
                self:handleHitDefault(circumstance,3)
            end
        end
    end

    function objBowser:draw(gc,x,y,TYPE,isEditor,isIcon)
        local offsets={
            ["L"]={{8,-8},{16,8},{0,-16}},
            ["R"]={{0,-8},{0,8},{16,-16}}
        }
        local dir,status,hp,mouth=self.facing or "L",(not isEditor) and ((math.ceil((playStage.framesPassed/4)))%2)+1 or 1,self.hp or 100 --[[big value]],(self.fireCountdown and self.fireCountdown<1) and 2 or 1
        if isIcon then
            gc:drawImage(texs["bowser_mouth_1_L"],x,y)
        else
            local facingOffset=(dir=="L") and -3 or 3
            gc:drawImage(texs["bowser_body_"..dir],x+offsets[dir][1][1]+facingOffset,y+offsets[dir][1][2])
            gc:drawImage(texs["bowser_walk_"..status.."_"..dir],x+offsets[dir][2][1]+facingOffset,y+offsets[dir][2][2])
            gc:drawImage(texs["bowser_mouth_"..mouth.."_"..dir],x+offsets[dir][3][1]+facingOffset,y+offsets[dir][3][2])
            if hp<5 and hp>0 then
                gc:setColorRGB(255,255,255)
                gc:fillRect(x+8+facingOffset,y-16,16,2)
                gc:setColorRGB(255,0,0)
                gc:fillRect(x+8+facingOffset,y-16,16*(hp/5),2)
    end end end

    -- gc:drawImage(texs["bowser_body_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][1][1],EDITOR[2]+8+offsets[dir][1][2])
    -- gc:drawImage(texs["bowser_walk_1_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][2][1],EDITOR[2]+8+offsets[dir][2][2])
    -- gc:drawImage(texs["bowser_mouth_1_"..dir],EDITOR[1]-editor.cameraOffset+offsets[dir][3][1],EDITOR[2]+8+offsets[dir][3][2])

--------------------------
---BOWSER FLAME FUNCTIONS-- NEW drawing format
--------------------------
objBowserFlame=class(objAPI)

    function objBowserFlame:setup(objectID,posX,posY,TYPE,despawnable,moveToY,arg2)
        self:initObject(objectID,TYPE,"inner",{16,4,false,false},{posX,math.round(posY+4)},true,0)
        self.status=1 self.despawnable=true self.interactSpring=false
        self.vx=(self.TYPE=="flame_L") and -3 or 3
        self.moveToY=moveToY and math.round(moveToY+4) or self.y
        self.disableStarPoints=true
    end

    function objBowserFlame:logic() --handle both movement and animation
        self:checkMarioCollision({"fire"},true)
        self.x=self.x+self.vx
        if self.y~=self.moveToY then
            self.y=self.y+sign(self.moveToY-self.y)
    end end

    function objBowserFlame:hit(circumstance) --no interaction
    end

    function objBowserFlame:draw(gc,x,y,TYPE,isEditor,isIcon)
        if isEditor then
            local offset=(TYPE=="flame_L") and -8 or 0
            gc:drawImage(texs[TYPE.."_1"],x+offset,y+4)
        else
            gc:drawImage(texs[TYPE.."_"..((math.ceil((playStage.framesPassed/3)))%2)+1],x,y)
        end
    end