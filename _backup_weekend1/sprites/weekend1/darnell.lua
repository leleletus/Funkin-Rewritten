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


local darnell = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/darnell")),
	{
		{x = 432, y = 921, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 1: Idle0001
		{x = 822, y = 927, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 2: Idle0002
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 3: Idle0003
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 4: Idle0004
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 5: Idle0005
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 6: Idle0006
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 7: Idle0007
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 8: Idle0008
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 9: Idle0009
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 10: Idle0010
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 11: Idle0011
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 12: Idle0012
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 13: Idle0013
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 14: Idle0014
		{x = 432, y = 921, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 15: Idle0015
		{x = 822, y = 927, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 16: Idle0016
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 17: Idle0017
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 18: Idle0018
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 19: Idle0019
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 20: Idle0020
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 21: Idle0021
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 22: Idle0022
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 23: Idle0023
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 24: Idle0024
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 25: Idle0025
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 26: Idle0026
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 27: Idle0027
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 28: Idle0028
		{x = 4322, y = 8, width = 419, height = 461, offsetX = -0, offsetY = -90, offsetWidth = 643, offsetHeight = 665}, -- 29: Pose Left0001
		{x = 8, y = 444, width = 419, height = 461, offsetX = -0, offsetY = -90, offsetWidth = 643, offsetHeight = 665}, -- 30: Pose Left0002
		{x = 2083, y = 450, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 31: Pose Left0003
		{x = 2507, y = 450, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 32: Pose Left0004
		{x = 2931, y = 450, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 33: Pose Left0005
		{x = 3355, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 34: Pose Left0006
		{x = 3779, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 35: Pose Left0007
		{x = 3779, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 36: Pose Left0008
		{x = 4203, y = 485, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 37: Pose Left0009
		{x = 4203, y = 485, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 38: Pose Left0010
		{x = 8, y = 921, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 39: Pose Left0011
		{x = 8, y = 921, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 40: Pose Left0012
		{x = 2931, y = 450, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 41: Left Flame Loop0001
		{x = 3355, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 42: Left Flame Loop0002
		{x = 3779, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 43: Left Flame Loop0003
		{x = 3779, y = 482, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 44: Left Flame Loop0004
		{x = 4203, y = 485, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 45: Left Flame Loop0005
		{x = 4203, y = 485, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 46: Left Flame Loop0006
		{x = 8, y = 921, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 47: Left Flame Loop0007
		{x = 8, y = 921, width = 408, height = 468, offsetX = -16, offsetY = -83, offsetWidth = 643, offsetHeight = 665}, -- 48: Left Flame Loop0008
		{x = 8, y = 8, width = 425, height = 420, offsetX = -35, offsetY = -115, offsetWidth = 643, offsetHeight = 665}, -- 49: Pose Down0001
		{x = 449, y = 8, width = 425, height = 420, offsetX = -35, offsetY = -115, offsetWidth = 643, offsetHeight = 665}, -- 50: Pose Down0002
		{x = 890, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 51: Pose Down0003
		{x = 1328, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 52: Pose Down0004
		{x = 1328, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 53: Pose Down0005
		{x = 1766, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 54: Pose Down0006
		{x = 1766, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 55: Pose Down0007
		{x = 2204, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 56: Pose Down0008
		{x = 2204, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 57: Pose Down0009
		{x = 2642, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 58: Pose Down0010
		{x = 2642, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 59: Pose Down0011
		{x = 3080, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 60: Pose Down0012
		{x = 1328, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 61: Down Flame Loop0001
		{x = 1766, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 62: Down Flame Loop0002
		{x = 1766, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 63: Down Flame Loop0003
		{x = 2204, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 64: Down Flame Loop0004
		{x = 2204, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 65: Down Flame Loop0005
		{x = 2642, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 66: Down Flame Loop0006
		{x = 2642, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 67: Down Flame Loop0007
		{x = 3080, y = 8, width = 422, height = 426, offsetX = -40, offsetY = -109, offsetWidth = 643, offsetHeight = 665}, -- 68: Down Flame Loop0008
		{x = 1211, y = 1921, width = 431, height = 487, offsetX = -40, offsetY = -66, offsetWidth = 643, offsetHeight = 665}, -- 69: Pose Right0001
		{x = 1658, y = 1922, width = 431, height = 487, offsetX = -40, offsetY = -66, offsetWidth = 643, offsetHeight = 665}, -- 70: Pose Right0002
		{x = 3591, y = 2468, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 71: Pose Right0003
		{x = 4029, y = 2469, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 72: Pose Right0004
		{x = 8, y = 2914, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 73: Pose Right0005
		{x = 446, y = 2914, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 74: Pose Right0006
		{x = 884, y = 2927, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 75: Pose Right0007
		{x = 884, y = 2927, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 76: Pose Right0008
		{x = 1322, y = 2928, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 77: Pose Right0009
		{x = 1322, y = 2928, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 78: Pose Right0010
		{x = 1760, y = 2929, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 79: Pose Right0011
		{x = 1760, y = 2929, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 80: Pose Right0012
		{x = 8, y = 2914, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 81: Right Flame Loop0001
		{x = 446, y = 2914, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 82: Right Flame Loop0002
		{x = 884, y = 2927, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 83: Right Flame Loop0003
		{x = 884, y = 2927, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 84: Right Flame Loop0004
		{x = 1322, y = 2928, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 85: Right Flame Loop0005
		{x = 1322, y = 2928, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 86: Right Flame Loop0006
		{x = 1760, y = 2929, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 87: Right Flame Loop0007
		{x = 1760, y = 2929, width = 422, height = 491, offsetX = -52, offsetY = -62, offsetWidth = 643, offsetHeight = 665}, -- 88: Right Flame Loop0008
		{x = 2952, y = 3493, width = 362, height = 553, offsetX = -47, offsetY = -0, offsetWidth = 643, offsetHeight = 665}, -- 89: Pose Up0001
		{x = 3330, y = 3500, width = 362, height = 553, offsetX = -47, offsetY = -0, offsetWidth = 643, offsetHeight = 665}, -- 90: Pose Up0002
		{x = 8, y = 3421, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 91: Pose Up0003
		{x = 376, y = 3421, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 92: Pose Up0004
		{x = 744, y = 3434, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 93: Pose Up0005
		{x = 1112, y = 3435, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 94: Pose Up0006
		{x = 1480, y = 3436, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 95: Pose Up0007
		{x = 1848, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 96: Pose Up0008
		{x = 2216, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 97: Pose Up0009
		{x = 2216, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 98: Pose Up0010
		{x = 2584, y = 3486, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 99: Pose Up0011
		{x = 2584, y = 3486, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 100: Pose Up0012
		{x = 744, y = 3434, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 101: Up Flame Loop0001
		{x = 1112, y = 3435, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 102: Up Flame Loop0002
		{x = 1480, y = 3436, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 103: Up Flame Loop0003
		{x = 1848, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 104: Up Flame Loop0004
		{x = 2216, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 105: Up Flame Loop0005
		{x = 2216, y = 3454, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 106: Up Flame Loop0006
		{x = 2584, y = 3486, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 107: Up Flame Loop0007
		{x = 2584, y = 3486, width = 352, height = 547, offsetX = -61, offsetY = -6, offsetWidth = 643, offsetHeight = 665}, -- 108: Up Flame Loop0008
		{x = 1622, y = 927, width = 390, height = 480, offsetX = -46, offsetY = -71, offsetWidth = 643, offsetHeight = 665}, -- 109: Laugh0001
		{x = 1622, y = 927, width = 390, height = 480, offsetX = -46, offsetY = -71, offsetWidth = 643, offsetHeight = 665}, -- 110: Laugh0002
		{x = 3497, y = 1460, width = 385, height = 486, offsetX = -49, offsetY = -65, offsetWidth = 643, offsetHeight = 665}, -- 111: Laugh0003
		{x = 3898, y = 1463, width = 385, height = 486, offsetX = -49, offsetY = -65, offsetWidth = 643, offsetHeight = 665}, -- 112: Laugh0004
		{x = 2105, y = 1923, width = 384, height = 487, offsetX = -49, offsetY = -64, offsetWidth = 643, offsetHeight = 665}, -- 113: Laugh0005
		{x = 2505, y = 1923, width = 384, height = 487, offsetX = -49, offsetY = -64, offsetWidth = 643, offsetHeight = 665}, -- 114: Laugh0006
		{x = 1622, y = 927, width = 390, height = 480, offsetX = -46, offsetY = -71, offsetWidth = 643, offsetHeight = 665}, -- 115: Laugh0007
		{x = 1622, y = 927, width = 390, height = 480, offsetX = -46, offsetY = -71, offsetWidth = 643, offsetHeight = 665}, -- 116: Laugh0008
		{x = 3497, y = 1460, width = 385, height = 486, offsetX = -49, offsetY = -65, offsetWidth = 643, offsetHeight = 665}, -- 117: Laugh0009
		{x = 3898, y = 1463, width = 385, height = 486, offsetX = -49, offsetY = -65, offsetWidth = 643, offsetHeight = 665}, -- 118: Laugh0010
		{x = 2105, y = 1923, width = 384, height = 487, offsetX = -49, offsetY = -64, offsetWidth = 643, offsetHeight = 665}, -- 119: Laugh0011
		{x = 2505, y = 1923, width = 384, height = 487, offsetX = -49, offsetY = -64, offsetWidth = 643, offsetHeight = 665}, -- 120: Laugh0012
		{x = 2475, y = 1428, width = 495, height = 479, offsetX = -69, offsetY = -135, offsetWidth = 643, offsetHeight = 665}, -- 121: Light Can0001
		{x = 2986, y = 1460, width = 495, height = 479, offsetX = -69, offsetY = -135, offsetWidth = 643, offsetHeight = 665}, -- 122: Light Can0002
		{x = 2028, y = 934, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 123: Light Can0003
		{x = 2543, y = 934, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 124: Light Can0004
		{x = 3058, y = 966, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 125: Light Can0005
		{x = 3573, y = 966, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 126: Light Can0006
		{x = 4088, y = 969, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 127: Light Can0007
		{x = 8, y = 1408, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 128: Light Can0008
		{x = 8, y = 1408, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 129: Light Can0009
		{x = 523, y = 1414, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 130: Light Can0010
		{x = 523, y = 1414, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 131: Light Can0011
		{x = 1038, y = 1414, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 132: Light Can0012
		{x = 1038, y = 1414, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 133: Light Can0013
		{x = 1960, y = 1428, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 134: Light Can0014
		{x = 1960, y = 1428, width = 499, height = 478, offsetX = -68, offsetY = -120, offsetWidth = 643, offsetHeight = 665}, -- 135: Light Can0015
		{x = 3930, y = 2976, width = 417, height = 510, offsetX = -38, offsetY = -54, offsetWidth = 643, offsetHeight = 665}, -- 136: Kick Up0001
		{x = 4363, y = 2976, width = 417, height = 510, offsetX = -38, offsetY = -54, offsetWidth = 643, offsetHeight = 665}, -- 137: Kick Up0002
		{x = 2198, y = 2929, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 138: Kick Up0003
		{x = 2631, y = 2961, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 139: Kick Up0004
		{x = 3064, y = 2968, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 140: Kick Up0005
		{x = 3064, y = 2968, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 141: Kick Up0006
		{x = 3064, y = 2968, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 142: Kick Up0007
		{x = 3497, y = 2975, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 143: Kick Up0008
		{x = 3497, y = 2975, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 144: Kick Up0009
		{x = 3497, y = 2975, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 145: Kick Up0010
		{x = 3497, y = 2975, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 146: Kick Up0011
		{x = 3497, y = 2975, width = 417, height = 509, offsetX = -45, offsetY = -59, offsetWidth = 643, offsetHeight = 665}, -- 147: Kick Up0012
		{x = 3518, y = 8, width = 386, height = 458, offsetX = -80, offsetY = -105, offsetWidth = 643, offsetHeight = 665}, -- 148: Knee Forward0001
		{x = 3920, y = 8, width = 386, height = 458, offsetX = -80, offsetY = -105, offsetWidth = 643, offsetHeight = 665}, -- 149: Knee Forward0002
		{x = 443, y = 444, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 150: Knee Forward0003
		{x = 443, y = 444, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 151: Knee Forward0004
		{x = 853, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 152: Knee Forward0005
		{x = 853, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 153: Knee Forward0006
		{x = 1263, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 154: Knee Forward0007
		{x = 1263, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 155: Knee Forward0008
		{x = 1263, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 156: Knee Forward0009
		{x = 1673, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 157: Knee Forward0010
		{x = 1673, y = 450, width = 394, height = 461, offsetX = -78, offsetY = -102, offsetWidth = 643, offsetHeight = 665}, -- 158: Knee Forward0011
		{x = 432, y = 921, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 159: Gets Pissed0001
		{x = 822, y = 927, width = 374, height = 471, offsetX = -44, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 160: Gets Pissed0002
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 161: Gets Pissed0003
		{x = 1212, y = 927, width = 394, height = 471, offsetX = -45, offsetY = -79, offsetWidth = 643, offsetHeight = 665}, -- 162: Gets Pissed0004
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 163: Gets Pissed0005
		{x = 1553, y = 1423, width = 391, height = 482, offsetX = -47, offsetY = -68, offsetWidth = 643, offsetHeight = 665}, -- 164: Gets Pissed0006
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 165: Gets Pissed0007
		{x = 4299, y = 1463, width = 388, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 166: Gets Pissed0008
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 167: Gets Pissed0009
		{x = 8, y = 1902, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 168: Gets Pissed0010
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 169: Gets Pissed0011
		{x = 409, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 170: Gets Pissed0012
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 171: Gets Pissed0013
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 172: Gets Pissed0014
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 173: Gets Pissed0015
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 174: Gets Pissed0016
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 175: Gets Pissed0017
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 176: Gets Pissed0018
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 177: Gets Pissed0019
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 178: Gets Pissed0020
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 179: Gets Pissed0021
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 180: Gets Pissed0022
		{x = 810, y = 1908, width = 385, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 181: Gets Pissed0023
		{x = 2905, y = 1955, width = 382, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 182: Gets Pissed0024
		{x = 3303, y = 1962, width = 382, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 183: Gets Pissed0025
		{x = 3701, y = 1965, width = 379, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 184: Gets Pissed0026
		{x = 4096, y = 1966, width = 379, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 185: Gets Pissed0027
		{x = 406, y = 2411, width = 387, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 186: Gets Pissed0028
		{x = 1207, y = 2424, width = 387, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 187: Gets Pissed0029
		{x = 1610, y = 2425, width = 387, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 188: Gets Pissed0030
		{x = 8, y = 2405, width = 382, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 189: Gets Pissed0031
		{x = 809, y = 2411, width = 382, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 190: Gets Pissed0032
		{x = 2013, y = 2426, width = 379, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 191: Gets Pissed0033
		{x = 2408, y = 2426, width = 379, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 192: Gets Pissed0034
		{x = 2803, y = 2458, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 193: Gets Pissed0035
		{x = 3197, y = 2465, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 194: Gets Pissed0036
		{x = 3197, y = 2465, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 195: Gets Pissed0037
		{x = 3197, y = 2465, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 196: Gets Pissed0038
		{x = 3197, y = 2465, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 197: Gets Pissed0039
		{x = 3197, y = 2465, width = 378, height = 487, offsetX = -47, offsetY = -63, offsetWidth = 643, offsetHeight = 665}, -- 198: Gets Pissed0040
	},
	{
		["Gets Pissed"] = {start = 159, stop = 198, speed = 24, offsetX = 0, offsetY = 0},
		["up alt"] = {start = 136, stop = 147, speed = 24, offsetX = 0, offsetY = 10},
		["right alt"] = {start = 148, stop = 158, speed = 24, offsetX = 35, offsetY = 0},
		["Laugh"] = {start = 109, stop = 120, speed = 24, offsetX = 0, offsetY = 0},
		["down alt"] = {start = 121, stop = 135, speed = 24, offsetX = 20, offsetY = 20},
		["down"] = {start = 49, stop = 60, speed = 24, offsetX = -5, offsetY = -10},
		["down flame loop"] = {start = 61, stop = 68, speed = 24, offsetX = -5, offsetY = -10},
		["idle"] = {start = 1, stop = 28, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 29, stop = 40, speed = 24, offsetX = 0, offsetY = 0},
		["left flame loop"] = {start = 41, stop = 48, speed = 24, offsetX = 0, offsetY = 0},
		["right"] = {start = 69, stop = 80, speed = 24, offsetX = 5, offsetY = 0},
		["right flame loop"] = {start = 81, stop = 88, speed = 24, offsetX = 5, offsetY = 0},
		["up"] = {start = 89, stop = 100, speed = 24, offsetX = 0, offsetY = 0},
		["up flame loop"] = {start = 101, stop = 108, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return darnell
