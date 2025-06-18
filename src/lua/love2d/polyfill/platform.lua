platform	=	{}

platform._hwLevel	= 5
platform.apiLevel	= '1.5'


function platform.hw()
	return platform._hwLevel
end

function platform.isColorDisplay()
	return true
end

function platform.isDeviceModeRendering()
	return true
end

-------------------
-- Platform menu --
-------------------

_menuState	= false
function toggleMenu()
	error("fake error, triggered")
	_menuState	= not _menuState
	if _menuState then
		
	end
end
