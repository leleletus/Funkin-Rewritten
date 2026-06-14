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

local Nene = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("weekend1/char/Nene")),
	{
		{x = 0, y = 0, width = 403, height = 446, offsetX = -8, offsetY = -25, offsetWidth = 462, offsetHeight = 476}, -- 1: Nene Hair Blowing0000
		{x = 403, y = 0, width = 403, height = 438, offsetX = -8, offsetY = -33, offsetWidth = 462, offsetHeight = 476}, -- 2: Nene Hair Blowing0001
		{x = 806, y = 0, width = 403, height = 447, offsetX = -8, offsetY = -25, offsetWidth = 462, offsetHeight = 476}, -- 3: Nene Hair Blowing0002
		{x = 1209, y = 0, width = 403, height = 452, offsetX = -8, offsetY = -20, offsetWidth = 462, offsetHeight = 476}, -- 4: Nene Hair Blowing0003
		{x = 1612, y = 0, width = 409, height = 461, offsetX = -2, offsetY = -15, offsetWidth = 462, offsetHeight = 476}, -- 5: Nene Hair Blowing0004
		{x = 1612, y = 0, width = 409, height = 461, offsetX = -2, offsetY = -15, offsetWidth = 462, offsetHeight = 476}, -- 6: Nene Hair Blowing0005
		{x = 2021, y = 0, width = 409, height = 463, offsetX = -2, offsetY = -13, offsetWidth = 462, offsetHeight = 476}, -- 7: Nene Hair Blowing0006
		{x = 2430, y = 0, width = 409, height = 463, offsetX = -2, offsetY = -13, offsetWidth = 462, offsetHeight = 476}, -- 8: Nene Hair Blowing0007
		{x = 2839, y = 0, width = 425, height = 469, offsetX = 0, offsetY = -6, offsetWidth = 462, offsetHeight = 476}, -- 9: Nene Hair Blowing0008
		{x = 3264, y = 0, width = 443, height = 475, offsetX = 0, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 10: Nene Hair Blowing0009
		{x = 3707, y = 0, width = 440, height = 475, offsetX = -3, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 11: Nene Hair Blowing0010
		{x = 4147, y = 0, width = 439, height = 474, offsetX = -3, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 12: Nene Hair Blowing0011
		{x = 4586, y = 0, width = 440, height = 474, offsetX = -4, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 13: Nene Hair Blowing0012
		{x = 4586, y = 0, width = 440, height = 474, offsetX = -4, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 14: Nene Hair Blowing0013
		{x = 5026, y = 0, width = 440, height = 474, offsetX = -4, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 15: Nene Hair Blowing0014
		{x = 5466, y = 0, width = 436, height = 474, offsetX = -10, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 16: Nene Hair Blowing0015
		{x = 5902, y = 0, width = 436, height = 471, offsetX = -10, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 17: Nene Hair Blowing0016
		{x = 6338, y = 0, width = 394, height = 394, offsetX = -67, offsetY = -17, offsetWidth = 462, offsetHeight = 476}, -- 18: Nene Hair Blowing0017
		{x = 6338, y = 0, width = 394, height = 394, offsetX = -67, offsetY = -17, offsetWidth = 462, offsetHeight = 476}, -- 19: Nene Hair Blowing0018
		{x = 6732, y = 0, width = 363, height = 361, offsetX = -99, offsetY = -18, offsetWidth = 462, offsetHeight = 476}, -- 20: Nene Hair Blowing0019
		{x = 6732, y = 0, width = 363, height = 361, offsetX = -99, offsetY = -18, offsetWidth = 462, offsetHeight = 476}, -- 21: Nene Hair Blowing0020
		{x = 7095, y = 0, width = 362, height = 353, offsetX = -99, offsetY = -16, offsetWidth = 462, offsetHeight = 476}, -- 22: Nene Hair Blowing0021
		{x = 7457, y = 0, width = 362, height = 353, offsetX = -99, offsetY = -16, offsetWidth = 462, offsetHeight = 476}, -- 23: Nene Hair Blowing0022
		{x = 7819, y = 0, width = 360, height = 352, offsetX = -99, offsetY = -14, offsetWidth = 462, offsetHeight = 476}, -- 24: Nene Hair Blowing0023
		{x = 0, y = 475, width = 348, height = 366, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 25: Nene Hair Blowing0024
		{x = 348, y = 475, width = 348, height = 366, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 26: Nene Hair Blowing0025
		{x = 696, y = 475, width = 348, height = 368, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 27: Nene Hair Blowing0026
		{x = 1044, y = 475, width = 347, height = 368, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 28: Nene Hair Blowing0027
		{x = 1044, y = 475, width = 347, height = 368, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 29: Nene Hair Blowing0028
		{x = 1391, y = 475, width = 347, height = 376, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 30: Nene Hair Blowing0029
		{x = 1738, y = 475, width = 346, height = 376, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 31: Nene Hair Blowing0030
		{x = 2084, y = 475, width = 346, height = 403, offsetX = -99, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 32: Nene Hair Blowing0031
		{x = 2430, y = 475, width = 321, height = 458, offsetX = -97, offsetY = -7, offsetWidth = 461, offsetHeight = 476}, -- 33: Nene Idle0000
		{x = 2430, y = 475, width = 321, height = 458, offsetX = -97, offsetY = -7, offsetWidth = 461, offsetHeight = 476}, -- 34: Nene Idle0001
		{x = 2751, y = 475, width = 406, height = 470, offsetX = -13, offsetY = -6, offsetWidth = 461, offsetHeight = 476}, -- 35: Nene Idle0002
		{x = 2751, y = 475, width = 406, height = 470, offsetX = -13, offsetY = -6, offsetWidth = 461, offsetHeight = 476}, -- 36: Nene Idle0003
		{x = 3157, y = 475, width = 414, height = 472, offsetX = -5, offsetY = -4, offsetWidth = 461, offsetHeight = 476}, -- 37: Nene Idle0004
		{x = 3571, y = 475, width = 414, height = 472, offsetX = -5, offsetY = -4, offsetWidth = 461, offsetHeight = 476}, -- 38: Nene Idle0005
		{x = 3985, y = 475, width = 424, height = 473, offsetX = 0, offsetY = -2, offsetWidth = 461, offsetHeight = 476}, -- 39: Nene Idle0006
		{x = 4409, y = 475, width = 441, height = 475, offsetX = 0, offsetY = 0, offsetWidth = 461, offsetHeight = 476}, -- 40: Nene Idle0007
		{x = 4850, y = 475, width = 439, height = 475, offsetX = -2, offsetY = 0, offsetWidth = 461, offsetHeight = 476}, -- 41: Nene Idle0008
		{x = 5289, y = 475, width = 439, height = 474, offsetX = -2, offsetY = 0, offsetWidth = 461, offsetHeight = 476}, -- 42: Nene Idle0009
		{x = 4586, y = 0, width = 440, height = 474, offsetX = -3, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 43: Nene Idle0010
		{x = 4586, y = 0, width = 440, height = 474, offsetX = -3, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 44: Nene Idle0011
		{x = 5026, y = 0, width = 440, height = 474, offsetX = -3, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 45: Nene Idle0012
		{x = 5466, y = 0, width = 436, height = 474, offsetX = -9, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 46: Nene Idle0013
		{x = 5902, y = 0, width = 436, height = 471, offsetX = -9, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 47: Nene Idle0014
		{x = 6338, y = 0, width = 394, height = 394, offsetX = -66, offsetY = -17, offsetWidth = 462, offsetHeight = 476}, -- 48: Nene Idle0015
		{x = 6338, y = 0, width = 394, height = 394, offsetX = -66, offsetY = -17, offsetWidth = 462, offsetHeight = 476}, -- 49: Nene Idle0016
		{x = 6732, y = 0, width = 363, height = 361, offsetX = -98, offsetY = -18, offsetWidth = 462, offsetHeight = 476}, -- 50: Nene Idle0017
		{x = 6732, y = 0, width = 363, height = 361, offsetX = -98, offsetY = -18, offsetWidth = 462, offsetHeight = 476}, -- 51: Nene Idle0018
		{x = 7095, y = 0, width = 362, height = 353, offsetX = -98, offsetY = -16, offsetWidth = 462, offsetHeight = 476}, -- 52: Nene Idle0019
		{x = 7457, y = 0, width = 362, height = 353, offsetX = -98, offsetY = -16, offsetWidth = 462, offsetHeight = 476}, -- 53: Nene Idle0020
		{x = 7819, y = 0, width = 360, height = 352, offsetX = -98, offsetY = -14, offsetWidth = 462, offsetHeight = 476}, -- 54: Nene Idle0021
		{x = 0, y = 475, width = 348, height = 366, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 55: Nene Idle0022
		{x = 348, y = 475, width = 348, height = 366, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 56: Nene Idle0023
		{x = 696, y = 475, width = 348, height = 368, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 57: Nene Idle0024
		{x = 1044, y = 475, width = 347, height = 368, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 58: Nene Idle0025
		{x = 1044, y = 475, width = 347, height = 368, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 59: Nene Idle0026
		{x = 1391, y = 475, width = 347, height = 376, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 60: Nene Idle0027
		{x = 1738, y = 475, width = 346, height = 376, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 61: Nene Idle0028
		{x = 2084, y = 475, width = 346, height = 403, offsetX = -98, offsetY = 0, offsetWidth = 462, offsetHeight = 476}, -- 62: Nene Idle0029
		{x = 5728, y = 475, width = 294, height = 434, offsetX = -16, offsetY = -56, offsetWidth = 313, offsetHeight = 496}, -- 63: combo celebration 1 nene0000
		{x = 6022, y = 475, width = 294, height = 446, offsetX = -16, offsetY = -44, offsetWidth = 313, offsetHeight = 496}, -- 64: combo celebration 1 nene0001
		{x = 6316, y = 475, width = 313, height = 452, offsetX = 0, offsetY = -44, offsetWidth = 313, offsetHeight = 496}, -- 65: combo celebration 1 nene0002
		{x = 6629, y = 475, width = 313, height = 476, offsetX = 0, offsetY = -20, offsetWidth = 313, offsetHeight = 496}, -- 66: combo celebration 1 nene0003
		{x = 6629, y = 475, width = 313, height = 476, offsetX = 0, offsetY = -20, offsetWidth = 313, offsetHeight = 496}, -- 67: combo celebration 1 nene0004
		{x = 6942, y = 475, width = 313, height = 479, offsetX = 0, offsetY = -17, offsetWidth = 313, offsetHeight = 496}, -- 68: combo celebration 1 nene0005
		{x = 6942, y = 475, width = 313, height = 479, offsetX = 0, offsetY = -17, offsetWidth = 313, offsetHeight = 496}, -- 69: combo celebration 1 nene0006
		{x = 7255, y = 475, width = 313, height = 489, offsetX = 0, offsetY = -7, offsetWidth = 313, offsetHeight = 496}, -- 70: combo celebration 1 nene0007
		{x = 7255, y = 475, width = 313, height = 489, offsetX = 0, offsetY = -7, offsetWidth = 313, offsetHeight = 496}, -- 71: combo celebration 1 nene0008
		{x = 7568, y = 475, width = 313, height = 494, offsetX = 0, offsetY = -2, offsetWidth = 313, offsetHeight = 496}, -- 72: combo celebration 1 nene0009
		{x = 7568, y = 475, width = 313, height = 494, offsetX = 0, offsetY = -2, offsetWidth = 313, offsetHeight = 496}, -- 73: combo celebration 1 nene0010
		{x = 0, y = 969, width = 313, height = 496, offsetX = 0, offsetY = 0, offsetWidth = 313, offsetHeight = 496}, -- 74: combo celebration 1 nene0011
		{x = 0, y = 969, width = 313, height = 496, offsetX = 0, offsetY = 0, offsetWidth = 313, offsetHeight = 496}, -- 75: combo celebration 1 nene0012
		{x = 313, y = 969, width = 313, height = 496, offsetX = 0, offsetY = 0, offsetWidth = 313, offsetHeight = 496}, -- 76: combo celebration 1 nene0013
		{x = 313, y = 969, width = 313, height = 496, offsetX = 0, offsetY = 0, offsetWidth = 313, offsetHeight = 496}, -- 77: combo celebration 1 nene0014
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 78: combo celebration 1 nene0015
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 79: combo celebration 1 nene0016
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 80: combo celebration 1 nene0017
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 81: combo celebration 1 nene0018
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 82: combo celebration 1 nene0019
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 83: combo celebration 1 nene0020
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 84: combo celebration 1 nene0021
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 85: combo celebration 1 nene0022
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 86: combo celebration 1 nene0023
		{x = 626, y = 969, width = 313, height = 438, offsetX = 0, offsetY = -58, offsetWidth = 313, offsetHeight = 496}, -- 87: combo celebration 1 nene0024
		{x = 939, y = 969, width = 418, height = 457, offsetX = 0, offsetY = -4, offsetWidth = 418, offsetHeight = 461}, -- 88: fawn nene0000
		{x = 939, y = 969, width = 418, height = 457, offsetX = 0, offsetY = -4, offsetWidth = 418, offsetHeight = 461}, -- 89: fawn nene0001
		{x = 1357, y = 969, width = 411, height = 451, offsetX = -5, offsetY = -1, offsetWidth = 418, offsetHeight = 461}, -- 90: fawn nene0002
		{x = 1357, y = 969, width = 411, height = 451, offsetX = -5, offsetY = -1, offsetWidth = 418, offsetHeight = 461}, -- 91: fawn nene0003
		{x = 1768, y = 969, width = 408, height = 452, offsetX = -7, offsetY = 0, offsetWidth = 418, offsetHeight = 461}, -- 92: fawn nene0004
		{x = 1768, y = 969, width = 408, height = 452, offsetX = -7, offsetY = 0, offsetWidth = 418, offsetHeight = 461}, -- 93: fawn nene0005
		{x = 1768, y = 969, width = 408, height = 452, offsetX = -7, offsetY = 0, offsetWidth = 418, offsetHeight = 461}, -- 94: fawn nene0006
		{x = 2176, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 95: knife high held0000
		{x = 2518, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 96: knife high held0001
		{x = 2518, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 97: knife high held0002
		{x = 2860, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 98: knife high held0003
		{x = 3202, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 99: knife high held0004
		{x = 3202, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 100: knife high held0005
		{x = 3544, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 101: knife high held0006
		{x = 3886, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 102: knife high held0007
		{x = 3886, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 103: knife high held0008
		{x = 2176, y = 969, width = 342, height = 525, offsetX = 0, offsetY = 0, offsetWidth = 342, offsetHeight = 525}, -- 104: knife high held0009
		{x = 4228, y = 969, width = 325, height = 507, offsetX = -13, offsetY = -18, offsetWidth = 364, offsetHeight = 525}, -- 105: knife high held hair blowing0000
		{x = 4553, y = 969, width = 332, height = 507, offsetX = 0, offsetY = -18, offsetWidth = 364, offsetHeight = 525}, -- 106: knife high held hair blowing0001
		{x = 4885, y = 969, width = 317, height = 508, offsetX = -15, offsetY = -17, offsetWidth = 364, offsetHeight = 525}, -- 107: knife high held hair blowing0002
		{x = 5202, y = 969, width = 318, height = 508, offsetX = -15, offsetY = -17, offsetWidth = 364, offsetHeight = 525}, -- 108: knife high held hair blowing0003
		{x = 5520, y = 969, width = 312, height = 523, offsetX = -20, offsetY = -2, offsetWidth = 364, offsetHeight = 525}, -- 109: knife high held hair blowing0004
		{x = 5520, y = 969, width = 312, height = 523, offsetX = -20, offsetY = -2, offsetWidth = 364, offsetHeight = 525}, -- 110: knife high held hair blowing0005
		{x = 5832, y = 969, width = 321, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 111: knife high held hair blowing0006
		{x = 5832, y = 969, width = 321, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 112: knife high held hair blowing0007
		{x = 6153, y = 969, width = 340, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 113: knife high held hair blowing0008
		{x = 6493, y = 969, width = 344, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 114: knife high held hair blowing0009
		{x = 6493, y = 969, width = 344, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 115: knife high held hair blowing0010
		{x = 6837, y = 969, width = 342, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 116: knife high held hair blowing0011
		{x = 6837, y = 969, width = 342, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 117: knife high held hair blowing0012
		{x = 6837, y = 969, width = 342, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 118: knife high held hair blowing0013
		{x = 6837, y = 969, width = 342, height = 525, offsetX = -20, offsetY = 0, offsetWidth = 364, offsetHeight = 525}, -- 119: knife high held hair blowing0014
		{x = 7179, y = 969, width = 341, height = 525, offsetX = -233, offsetY = 0, offsetWidth = 814, offsetHeight = 720}, -- 120: knife lower0000
		{x = 7520, y = 969, width = 343, height = 524, offsetX = -233, offsetY = -1, offsetWidth = 814, offsetHeight = 720}, -- 121: knife lower0001
		{x = 7520, y = 969, width = 343, height = 524, offsetX = -233, offsetY = -1, offsetWidth = 814, offsetHeight = 720}, -- 122: knife lower0002
		{x = 0, y = 1494, width = 342, height = 514, offsetX = -233, offsetY = -11, offsetWidth = 814, offsetHeight = 720}, -- 123: knife lower0003
		{x = 0, y = 1494, width = 342, height = 514, offsetX = -233, offsetY = -11, offsetWidth = 814, offsetHeight = 720}, -- 124: knife lower0004
		{x = 342, y = 1494, width = 341, height = 487, offsetX = -233, offsetY = -38, offsetWidth = 814, offsetHeight = 720}, -- 125: knife lower0005
		{x = 342, y = 1494, width = 341, height = 487, offsetX = -233, offsetY = -38, offsetWidth = 814, offsetHeight = 720}, -- 126: knife lower0006
		{x = 683, y = 1494, width = 410, height = 467, offsetX = -172, offsetY = -55, offsetWidth = 814, offsetHeight = 720}, -- 127: knife lower0007
		{x = 683, y = 1494, width = 410, height = 467, offsetX = -172, offsetY = -55, offsetWidth = 814, offsetHeight = 720}, -- 128: knife lower0008
		{x = 1093, y = 1494, width = 812, height = 651, offsetX = -2, offsetY = -69, offsetWidth = 814, offsetHeight = 720}, -- 129: knife lower0009
		{x = 1905, y = 1494, width = 812, height = 651, offsetX = -2, offsetY = -69, offsetWidth = 814, offsetHeight = 720}, -- 130: knife lower0010
		{x = 2717, y = 1494, width = 814, height = 650, offsetX = 0, offsetY = -70, offsetWidth = 814, offsetHeight = 720}, -- 131: knife lower0011
		{x = 3531, y = 1494, width = 445, height = 476, offsetX = 0, offsetY = -50, offsetWidth = 445, offsetHeight = 526}, -- 132: knife raise0000
		{x = 3531, y = 1494, width = 445, height = 476, offsetX = 0, offsetY = -50, offsetWidth = 445, offsetHeight = 526}, -- 133: knife raise0001
		{x = 3976, y = 1494, width = 398, height = 479, offsetX = -44, offsetY = -47, offsetWidth = 445, offsetHeight = 526}, -- 134: knife raise0002
		{x = 3976, y = 1494, width = 398, height = 479, offsetX = -44, offsetY = -47, offsetWidth = 445, offsetHeight = 526}, -- 135: knife raise0003
		{x = 4374, y = 1494, width = 342, height = 520, offsetX = -99, offsetY = -6, offsetWidth = 445, offsetHeight = 526}, -- 136: knife raise0004
		{x = 4374, y = 1494, width = 342, height = 520, offsetX = -99, offsetY = -6, offsetWidth = 445, offsetHeight = 526}, -- 137: knife raise0005
		{x = 4716, y = 1494, width = 342, height = 524, offsetX = -99, offsetY = -2, offsetWidth = 445, offsetHeight = 526}, -- 138: knife raise0006
		{x = 4716, y = 1494, width = 342, height = 524, offsetX = -99, offsetY = -2, offsetWidth = 445, offsetHeight = 526}, -- 139: knife raise0007
		{x = 5058, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 140: knife raise0008
		{x = 5058, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 141: knife raise0009
		{x = 5400, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 142: knife raise0010
		{x = 5400, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 143: knife raise0011
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 144: knife raise0012
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 145: knife raise0013
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 146: knife raise0014
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 147: knife raise0015
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 148: knife raise0016
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 149: knife raise0017
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 150: knife raise0018
		{x = 5742, y = 1494, width = 342, height = 526, offsetX = -99, offsetY = 0, offsetWidth = 445, offsetHeight = 526}, -- 151: knife raise0019
		{x = 6084, y = 1494, width = 345, height = 401, offsetX = 0, offsetY = -9, offsetWidth = 345, offsetHeight = 410}, -- 152: knife toss0000
		{x = 6084, y = 1494, width = 345, height = 401, offsetX = 0, offsetY = -9, offsetWidth = 345, offsetHeight = 410}, -- 153: knife toss0001
		{x = 6429, y = 1494, width = 310, height = 393, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 154: knife toss0002
		{x = 6429, y = 1494, width = 310, height = 393, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 155: knife toss0003
		{x = 6739, y = 1494, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 156: knife toss0004
		{x = 6739, y = 1494, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 157: knife toss0005
		{x = 7049, y = 1494, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 158: knife toss0006
		{x = 7359, y = 1494, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 159: knife toss0007
		{x = 7669, y = 1494, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 160: knife toss0008
		{x = 0, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 161: knife toss0009
		{x = 310, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 162: knife toss0010
		{x = 620, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 163: knife toss0011
		{x = 930, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 164: knife toss0012
		{x = 1240, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 165: knife toss0013
		{x = 1550, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 166: knife toss0014
		{x = 1860, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 167: knife toss0015
		{x = 1860, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 168: knife toss0016
		{x = 1860, y = 2145, width = 310, height = 396, offsetX = -32, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 169: knife toss0017
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 170: knife toss0018
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 171: knife toss0019
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 172: knife toss0020
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 173: knife toss0021
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 174: knife toss0022
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 175: knife toss0023
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 176: knife toss0024
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 177: knife toss0025
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 178: knife toss0026
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 179: knife toss0027
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 180: knife toss0028
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 181: knife toss0029
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 182: knife toss0030
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 183: knife toss0031
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 184: knife toss0032
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 185: knife toss0033
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 186: knife toss0034
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 187: knife toss0035
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 188: knife toss0036
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 189: knife toss0037
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 190: knife toss0038
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 191: knife toss0039
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 192: knife toss0040
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 193: knife toss0041
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 194: knife toss0042
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 195: knife toss0043
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 196: knife toss0044
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 197: knife toss0045
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 198: knife toss0046
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 199: knife toss0047
		{x = 2170, y = 2145, width = 0, height = 0, offsetX = 7, offsetY = 0, offsetWidth = 345, offsetHeight = 410}, -- 200: knife toss0048
		{x = 4312, y = 2145, width = 372, height = 439, offsetX = -4, offsetY = -4, offsetWidth = 481, offsetHeight = 492}, -- 201: laugh nene 0000
		{x = 4312, y = 2145, width = 372, height = 439, offsetX = -4, offsetY = -4, offsetWidth = 481, offsetHeight = 492}, -- 202: laugh nene 0001
		{x = 2170, y = 2145, width = 378, height = 443, offsetX = 0, offsetY = -1, offsetWidth = 378, offsetHeight = 445}, -- 203: laugh nene 0002
		{x = 2170, y = 2145, width = 378, height = 443, offsetX = 0, offsetY = -1, offsetWidth = 378, offsetHeight = 445}, -- 204: laugh nene 0003
		{x = 2548, y = 2145, width = 378, height = 445, offsetX = 0, offsetY = 0, offsetWidth = 378, offsetHeight = 445}, -- 205: laugh nene 0004
		{x = 2548, y = 2145, width = 378, height = 445, offsetX = 0, offsetY = 0, offsetWidth = 378, offsetHeight = 445}, -- 206: laugh nene 0005
		{x = 2926, y = 2145, width = 479, height = 452, offsetX = -2, offsetY = -40, offsetWidth = 481, offsetHeight = 492}, -- 207: laughing nene0000
		{x = 2926, y = 2145, width = 479, height = 452, offsetX = -2, offsetY = -40, offsetWidth = 481, offsetHeight = 492}, -- 208: laughing nene0001
		{x = 3405, y = 2145, width = 459, height = 447, offsetX = 0, offsetY = -34, offsetWidth = 481, offsetHeight = 492}, -- 209: laughing nene0002
		{x = 3405, y = 2145, width = 459, height = 447, offsetX = 0, offsetY = -34, offsetWidth = 481, offsetHeight = 492}, -- 210: laughing nene0003
		{x = 3864, y = 2145, width = 448, height = 435, offsetX = -11, offsetY = -36, offsetWidth = 481, offsetHeight = 492}, -- 211: laughing nene0004
		{x = 3864, y = 2145, width = 448, height = 435, offsetX = -11, offsetY = -36, offsetWidth = 481, offsetHeight = 492}, -- 212: laughing nene0005
		{x = 4312, y = 2145, width = 372, height = 439, offsetX = -44, offsetY = -4, offsetWidth = 481, offsetHeight = 492}, -- 213: laughing nene0006
		{x = 4312, y = 2145, width = 372, height = 439, offsetX = -44, offsetY = -4, offsetWidth = 481, offsetHeight = 492}, -- 214: laughing nene0007
		{x = 4684, y = 2145, width = 377, height = 444, offsetX = -40, offsetY = 0, offsetWidth = 481, offsetHeight = 492}, -- 215: laughing nene0008
		{x = 4684, y = 2145, width = 377, height = 444, offsetX = -40, offsetY = 0, offsetWidth = 481, offsetHeight = 492}, -- 216: laughing nene0009
		{x = 5061, y = 2145, width = 377, height = 445, offsetX = -40, offsetY = 0, offsetWidth = 481, offsetHeight = 492}, -- 217: laughing nene0010
		{x = 5061, y = 2145, width = 377, height = 445, offsetX = -40, offsetY = 0, offsetWidth = 481, offsetHeight = 492} -- 218: laughing nene0011
	},
	{
		["combo celebration 1 nene"] = {start = 63, stop = 87, speed = 24, offsetX = -50, offsetY = 30},
		["fawn nene"] = {start = 88, stop = 94, speed = 24, offsetX = -20, offsetY = 0},
		["hair blowing"] = {start = 1, stop = 32, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 33, stop = 62, speed = 24, offsetX = 0, offsetY = 0},
		["knife high held"] = {start = 95, stop = 104, speed = 24, offsetX = -40, offsetY = 27},
		["knife high held hair blowing"] = {start = 105, stop = 119, speed = 24, offsetX = -31, offsetY = 27},
		["knife lower"] = {start = 120, stop = 128, speed = 24, offsetX = -44, offsetY = -71},
		["knife raise"] = {start = 132, stop = 151, speed = 24, offsetX = 9, offsetY = 26},
		["knife toss"] = {start = 152, stop = 200, speed = 24, offsetX = -80, offsetY = 0},
		["sad"] = {start = 207, stop = 218, speed = 24, offsetX = 0, offsetY = 0}
	},
	"idle"
)

return Nene
