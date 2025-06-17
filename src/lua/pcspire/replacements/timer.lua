timer	= {}
timer.delay	= 0
timer.running	= false
timer.lastrun	= 0

function timer.start(t)
	PCspire.debuginfo("starting timer")
	if love.timer then
		if t<0.01 then error("argument needs to be >=0.01") end
		timer.delay	= t
		timer.running	= true
		timer.lastrun	= PCspire.getMicroTime()
	else
		error("Timer not initialized! This is a problem with PCspire, not you!")
	end
end

function timer.stop()
	timer.delay	= 0
	timer.running	= false
end

function timer.getMilliSecCounter()
	return PCspire.getMicroTime()*1000
end
