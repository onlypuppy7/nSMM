fonts	= {}
fonts.l	= "love2d/ttf/TINSSaRG.TTF"
fonts.b	= "love2d/ttf/TINSSaBD.TTF"
fonts.i	= "love2d/ttf/TINSSaIT.TTF"

local nf	= love.graphics.newFont

fonts["r"]	= {nf(fonts.l, 8), nf(fonts.l, 10), nf(fonts.l, 12), nf(fonts.l, 18)}
fonts["b"]	= {nf(fonts.b, 8), nf(fonts.b, 10), nf(fonts.b, 12), nf(fonts.b, 18)}
fonts["i"]	= {nf(fonts.i, 8), nf(fonts.i, 10), nf(fonts.i, 12), nf(fonts.i, 18)}

function fonts.setFont(s, style)
	style	= style or "r"
	s	= tonumber(s)
	if     s<=8  then s=1
	elseif s<=10 then s=2
	elseif s<=12 then s=3
	else   s=4   end

	love.graphics.setFont(fonts[style][s])
end