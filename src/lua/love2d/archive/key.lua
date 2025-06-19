Keys	= {}

Keys['up'   ]	= function () if on.arrowKey then PCspire.callEvent(on.arrowKey, 'up'   ) else PCspire.callEvent(on.arrowUp   ) end end
Keys['down' ]	= function () if on.arrowKey then PCspire.callEvent(on.arrowKey, 'down' ) else PCspire.callEvent(on.arrowDown ) end end
Keys['left' ]	= function () if on.arrowKey then PCspire.callEvent(on.arrowKey, 'left' ) else PCspire.callEvent(on.arrowLeft ) end end
Keys['right']	= function () if on.arrowKey then PCspire.callEvent(on.arrowKey, 'right') else PCspire.callEvent(on.arrowRight) end end

Keys['escape' ]	= function () PCspire.callEvent(on.escapeKey) end
Keys['return' ]	= function () PCspire.callEvent(on.enterKey ) end
Keys['kpenter']	= function () PCspire.callEvent(on.returnKey) end
Keys['tab'    ]	= function () PCspire.callEvent(on.tabKey   ) end

Keys['backspace']	= function () PCspire.callEvent(on.backspaceKey) end
Keys['delete'   ]	= function () PCspire.callEvent(on.deleteKey   ) end

-- Keys['menu']	= function () toggleMenu() end

Keys['lctrl'   ]	= function (key, s) toggleMod(key, s) end
Keys['rctrl'   ]	= Keys['lctrl']
Keys['lshift'  ]	= function (key, s) toggleMod(key, s) end
Keys['rshift'  ]	= Keys['lshift']
Keys['capslock']	= function (key, s) toggleMod(key, s) end

ModKeys	= {}
ModKeys['shift'    ]	= false
ModKeys['ctrl'     ]	= false
ModKeys['capslock' ]	= false

ModKeysFilter	= {}
ModKeysFilter['lctrl' ]	= "ctrl"
ModKeysFilter['rctrl' ]	= "ctrl"
ModKeysFilter['ctrl'  ]	= "ctrl"
ModKeysFilter['lshift']	= "shift"
ModKeysFilter['rshift']	= "shift"
ModKeysFilter['shift' ]	= "shift"
ModKeysFilter['capslock']	= "capslock"

function toggleMod(key, state)
	key	= ModKeysFilter[key]
	ModKeys[key]	= state
	PCspire.debuginfo("Modifier " .. key .. (state and " pressed" or " released"))
end

function love.keypressed(key)

	if Keys[key] then
		Keys[key](key, true)
		PCspire.debuginfo("Non-Alpha key pressed")
	else
		local lock, shift, caps
		lock	= ModKeys['capslock']
		shift	= ModKeys['shift'   ]
		key	= (lock and shift) and key or (lock or shift) and key:upper() or key
		PCspire.debuginfo("Alpha key pressed")
		PCspire.callEvent(on.charIn, key)
	end
end

function love.keyreleased(key)
	if ModKeysFilter[key] then
		toggleMod(key, false)
	end
end
