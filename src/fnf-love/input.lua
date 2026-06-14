--[[----------------------------------------------------------------------------
This file is part of Friday Night Funkin' Rewritten

Copyright (C) 2021  HTV04

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
------------------------------------------------------------------------------]]

local gameLeft
local gameDown
local gameUp
local gameRight

local player

if love.system.getOS() == "NX" then
	if settings.dfjk then
		gameLeft = {"axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:d", "key:left"}
		gameDown = {"axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:f", "key:down"}
		gameUp = {"axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:j", "key:up"}
		gameRight = {"axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:k", "key:right"}
	else
		gameLeft = {"axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x", "key:a", "key:left"}
		gameDown = {"axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a", "key:s", "key:down"}
		gameUp = {"axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y", "key:w", "key:up"}
		gameRight = {"axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b", "key:d", "key:right"}
	end

	player = baton.new {
		controls = {
			left = {"axis:leftx-", "button:dpleft", "key:left"},
			down = {"axis:lefty+", "button:dpdown", "key:down"},
			up = {"axis:lefty-", "button:dpup", "key:up"},
			right = {"axis:leftx+", "button:dpright", "key:right"},
			confirm = {"button:b", "key:return"},
			back = {"button:a", "key:escape"},
			space = {"key:space", "button:y"},

			pause = {"button:start","key:return"},

			gameLeft = gameLeft,
			gameDown = gameDown,
			gameUp = gameUp,
			gameRight = gameRight,
			gameBack = {"button:start", "key:escape"},
			pageup = {"button:leftshoulder"},
			pagedown = {"button:rightshoulder"},
			debug = {"button:back", "button:rightstick"},
		},
		joystick = love.joystick.getJoysticks()[1]
	}
else
	if settings.dfjk then
		gameLeft = {"key:d", "key:left", "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x"}
		gameDown = {"key:f", "key:down", "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a"}
		gameUp = {"key:j", "key:up", "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y"}
		gameRight = {"key:k", "key:right", "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b"}
	else
		gameLeft = {"key:a", "key:left", "axis:triggerleft+", "axis:leftx-", "axis:rightx-", "button:dpleft", "button:x"}
		gameDown = {"key:s", "key:down", "axis:lefty+", "axis:righty+", "button:leftshoulder", "button:dpdown", "button:a"}
		gameUp = {"key:w", "key:up", "axis:lefty-", "axis:righty-", "button:rightshoulder", "button:dpup", "button:y"}
		gameRight = {"key:d", "key:right", "axis:triggerright+", "axis:leftx+", "axis:rightx+", "button:dpright", "button:b"}
	end

	player = baton.new {
		controls = {
			left = {"key:left", "axis:leftx-", "button:dpleft"},
			down = {"key:down", "axis:lefty+", "button:dpdown"},
			up = {"key:up", "axis:lefty-", "button:dpup"},
			right = {"key:right", "axis:leftx+", "button:dpright"},
			confirm = {"key:return", "button:a"},
			back = {"key:escape", "button:b"},

			pause = {"button:start,key:return","key:escape"},

			gameLeft = gameLeft,
			gameDown = gameDown,
			gameUp = gameUp,
			gameRight = gameRight,
			gameBack = {"key:escape", "button:start"},

            debug = {"key:f1", "button:rightstick"},
            save = {"key:f2"},
			f1 = {"key:f1"},
            f2 = {"key:f2"},
            f3 = {"key:f3"},
            f4 = {"key:f4"},
            prevAnim = {"key:q"},
            nextAnim = {"key:e"},
			space = {"key:space"},
			num1 = {"key:1"},
            num2 = {"key:2"},
            num3 = {"key:3"},
			num4 = {"key:4"},
			num5 = {"key:5"},
			num6 = {"key:6"},
			num8 = {"key:8"},
			num9 = {"key:9"},
			s = {"key:s"},
			l = {"key:l"},
			m = {"key:m"},
			delete = {"key:delete"},
			a = {"key:a"},
			d = {"key:d"},
			w = {"key:w"},
			tab = {"key:tab"},
			h = {"key:h"},
			f = {"key:f"},
			g = {"key:g"},
			p = {"key:p"},
			r = {"key:r"},
			q = {"key:q"},
			t = {"key:t"},
			j = {"key:j"},
			z = {"key:z"},
			x = {"key:x"},
			v = {"key:v"},
			e = {"key:e"},
			r = {"key:r"},
			n = {"key:n"},
			c = {"key:c"},
			pageup = {"key:pageup"},
			pagedown = {"key:pagedown"},
			plus = {"key:=", "key:kp+"},
			minus = {"key:kp-"},
		},
		joystick = love.joystick.getJoysticks()[1]
	}
end

local Input = {}
Input.isMobile = (love.system.getOS() == "Android") or (love.system.getOS() == "iOS")
Input.VirtualPad = { pressed = {}, down = {}, released = {}, _pressedThisFrame = {}, _releasedThisFrame = {} }

function Input:update(dt)
	player:update()

	-- Taps iniciales de este frame
	for action, _ in pairs(self.VirtualPad._pressedThisFrame) do
		self.VirtualPad.pressed[action] = true
	end
	self.VirtualPad._pressedThisFrame = {}

	-- Release (soltadas) de este frame
	for action, _ in pairs(self.VirtualPad._releasedThisFrame) do
		self.VirtualPad.released[action] = true
	end
	self.VirtualPad._releasedThisFrame = {}
end

function Input:pressed(action)
	if self.VirtualPad.pressed[action] then
		self.VirtualPad.pressed[action] = false -- lo consumimos
		return true
	end
	return player:pressed(action)
end

function Input:down(action)
	return self.VirtualPad.down[action] or player:down(action)
end

function Input:released(action)
	if self.VirtualPad.released[action] then
		self.VirtualPad.released[action] = false
		return true
	end
	return player:released(action)
end

-- Delegar cualquier otra cosa (como obtener nombre de dispositivo) al player base
setmetatable(Input, { __index = player })

return Input
