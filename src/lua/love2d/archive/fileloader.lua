PCspire.loader	= {}

PCspire.loader.dir	= "scripts"

function uCol(t)
	return t[1], t[2], t[3]
end

function on.create()
	local dirList	= PCspire.getDirList(PCspire.loader.dir)
	local files	= {}
	local path	= PCspire.loader.dir .. "/"
	local name
	for _, file in ipairs(dirList) do
		if PCspire.isFile(path .. file) then
			name	= file:split("%.")
			if name[#name]	== "lua" then
				table.insert(files, file)
			end
		end
	end
		
	PCspire.loader.list	= sList()
	PCspire.loader.list.items	= files
	function PCspire.loader.list:action(n, src)
		sList	= nil
		uCol	= nil
		scrollBar	= nil
		on	= {}
		PCspire.scriptname	= "scripts/" .. src
		PCspire.init()
	end
end

function on.paint(gc)
	PCspire.loader.list:paint(gc)
end

function on.arrowKey(a)
	PCspire.loader.list:arrowKey(a)
	platform.window:invalidate()
end

function on.mouseUp(x, y)
	PCspire.loader.list:mouseUp(x, y)
	platform.window:invalidate()
end

function on.enterKey()
	PCspire.loader.list:enterKey()
	platform.window:invalidate()
end


sList	= class()

function sList:init()
	self.w	= platform.window:width()-10
	self.h	= platform.window:height()-10
	self.x	= 5
	self.y	= 5
	self.ih	= 18

	self.top	= 0
	self.sel	= 1
	
	self.font	= {"sansserif", "r", 10}
	self.colors	= {50,150,190}
	self.items	= {}
	
	self.scrollBar	= scrollBar(self.h, self.top, #self.items,#self.items, self.x + self.w - 15, self.y)
end

function sList:paint(gc)
	local x	= self.x
	local y	= self.y
	local w	= self.w
	local h	= self.h
	
	
	local ih	= self.ih   
	local top	= self.top		
	local sel	= self.sel		
		      
	local items	= self.items			
	local visible_items	= math.floor(h/ih)	
	gc:setColorRGB(255, 255, 255)
	gc:fillRect(x, y, w, h)
	gc:setColorRGB(0, 0, 0)
	gc:drawRect(x, y, w, h)
	gc:clipRect("set", x, y, w, h)
	gc:setFont(unpack(self.font))
	
	local label, item
	for i=1, math.min(#items-top, visible_items+1) do
		item	= items[i+top]
		label	= item
		
		if i+top == sel then
			gc:setColorRGB(unpack(self.colors))
			gc:fillRect(x+1, y + i*ih-ih + 1, w-(12 + 2 + 2), ih)
			
			gc:setColorRGB(255, 255, 255)
		end
		
		gc:drawString(label, x+5, y + i*ih-ih , "top")
		gc:setColorRGB(0, 0, 0)
	end
		
	gc:clipRect("reset")
	self.scrollBar:update(top, visible_items, #items)
	self.scrollBar:paint(gc)
end

function sList:arrowKey(arrow)	
	if arrow=="up" and self.sel>1 then
		self.sel	= self.sel - 1
		if self.top>=self.sel then
			self.top	= self.top - 1
		end
	end

	if arrow=="down" and self.sel<#self.items then
		self.sel	= self.sel + 1
		if self.sel>(self.h/self.ih)+self.top then
			self.top	= self.top + 1
		end
	end
end


function sList:mouseUp(x, y)
	if x>=self.x and x<self.x+self.w-16 and y>=self.y and y<self.y+self.h then
		
		local sel	= math.floor((y-self.y)/self.ih) + 1 + self.top
		if sel==self.sel then
			self:enterKey()
			return
		end
		self.sel=sel
		
		if self.sel>(self.h/self.ih)+self.top then
			self.top	= self.top + 1
		end
		if self.top>=self.sel then
			self.top	= self.top - 1
		end
						
	end 
end


function sList:enterKey()
	self:action(self.sel, self.items[self.sel])
end

function sList:action() end

scrollBar	= class()

function scrollBar:init(h, top, visible, total, x, y)
	self.color1	= {96, 100, 96}
	self.color2	= {184, 184, 184}
	
	self.h	= h or 100
	self.w = 14
	self.x	= x
	self.y	= y
	self.visible = visible or 10
	self.total   = total   or 15
	self.top     = top     or 4
end

function scrollBar:paint(gc)
	gc:setColorRGB(255,255,255)
	gc:setColorRGB(uCol(self.color1))
	
	if self.visible<self.total then
		local step	= (self.h)/self.total
		gc:fillRect(self.x + 3, self.y + 1  + step*self.top, 9, step*self.visible)
		gc:setColorRGB(uCol(self.color2))
		gc:fillRect(self.x + 2 , self.y + 1 + step*self.top, 1, step*self.visible)
		gc:fillRect(self.x + 12, self.y + 1 + step*self.top, 1, step*self.visible)
	end
end

function scrollBar:update(top, visible, total)
	self.top      = top     or self.top
	self.visible  = visible or self.visible
	self.total    = total   or self.total
end
