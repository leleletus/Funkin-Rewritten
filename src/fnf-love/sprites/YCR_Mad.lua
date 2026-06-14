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


local YCR_Mad = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("YCR_Mad")),
	{
		{x = 73, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 1: just_die0000
		{x = 73, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 2: just_die0001
		{x = 1036, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 3: just_die0002
		{x = 1036, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 4: just_die0003
		{x = 1999, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 5: just_die0004
		{x = 1999, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 6: just_die0005
		{x = 2962, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 7: just_die0006
		{x = 2962, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 8: just_die0007
		{x = 3925, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 9: just_die0008
		{x = 3925, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 10: just_die0009
		{x = 4888, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 11: just_die0010
		{x = 4888, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 12: just_die0011
		{x = 5851, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 13: just_die0012
		{x = 5851, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 14: just_die0013
		{x = 6814, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 15: just_die0014
		{x = 6814, y = 73, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 16: just_die0015
		{x = 73, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 17: just_die0016
		{x = 73, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 18: just_die0017
		{x = 1036, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 19: just_die0018
		{x = 1036, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 20: just_die0019
		{x = 1999, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 21: just_die0020
		{x = 1999, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 22: just_die0021
		{x = 2962, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 23: just_die0022
		{x = 2962, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 24: just_die0023
		{x = 3925, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 25: just_die0024
		{x = 3925, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 26: just_die0025
		{x = 4888, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 27: just_die0026
		{x = 4888, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 28: just_die0027
		{x = 5851, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 29: just_die0028
		{x = 5851, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 30: just_die0029
		{x = 6814, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 31: just_die0030
		{x = 6814, y = 824, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 32: just_die0031
		{x = 73, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 33: just_die0032
		{x = 73, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 34: just_die0033
		{x = 1036, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 35: just_die0034
		{x = 1036, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 36: just_die0035
		{x = 1999, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 37: just_die0036
		{x = 1999, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 38: just_die0037
		{x = 2962, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 39: just_die0038
		{x = 2962, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 40: just_die0039
		{x = 3925, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 41: just_die0040
		{x = 3925, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 42: just_die0041
		{x = 4888, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 43: just_die0042
		{x = 4888, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 44: just_die0043
		{x = 5851, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 45: just_die0044
		{x = 5851, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 46: just_die0045
		{x = 6814, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 47: just_die0046
		{x = 6814, y = 1575, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 48: just_die0047
		{x = 73, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 49: just_die0048
		{x = 1036, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 50: just_die0049
		{x = 1999, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 51: just_die0050
		{x = 2962, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 52: just_die0051
		{x = 3925, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 53: just_die0052
		{x = 4888, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 54: just_die0053
		{x = 5851, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 55: just_die0054
		{x = 6814, y = 2326, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 56: just_die0055
		{x = 73, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 57: just_die0056
		{x = 73, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 58: just_die0057
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 59: just_die0058
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 60: just_die0059
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 61: just_die0060
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 62: just_die0061
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 63: just_die0062
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 64: just_die0063
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 65: just_die0064
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 66: just_die0065
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 67: just_die0066
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 68: just_die0067
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 69: just_die0068
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 70: just_die0069
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 71: just_die0070
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 72: just_die0071
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 73: just_die0072
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 74: just_die0073
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 75: just_die0074
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 76: just_die0075
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 77: just_die0076
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 78: just_die0077
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 79: just_die0078
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 80: just_die0079
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 81: just_die0080
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 82: just_die0081
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 83: just_die0082
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 84: just_die0083
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 85: just_die0084
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 86: just_die0085
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 87: just_die0086
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 88: just_die0087
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 89: just_die0088
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 90: just_die0089
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 91: just_die0090
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 92: just_die0091
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 93: just_die0092
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 94: just_die0093
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 95: just_die0094
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 96: just_die0095
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 97: just_die0096
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 98: just_die0097
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 99: just_die0098
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 100: just_die0099
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 101: just_die0100
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 102: just_die0101
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 103: just_die0102
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 104: just_die0103
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 105: just_die0104
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 106: just_die0105
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 107: just_die0106
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 108: just_die0107
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 109: just_die0108
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 110: just_die0109
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 111: just_die0110
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 112: just_die0111
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 113: just_die0112
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 114: just_die0113
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 115: just_die0114
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 116: just_die0115
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 117: just_die0116
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 118: just_die0117
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 119: just_die0118
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 120: just_die0119
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 121: just_die0120
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 122: just_die0121
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 123: just_die0122
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 124: just_die0123
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 125: just_die0124
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 126: just_die0125
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 127: just_die0126
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 128: just_die0127
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 129: just_die0128
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 130: just_die0129
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 131: just_die0130
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 132: just_die0131
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 133: just_die0132
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 134: just_die0133
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 135: just_die0134
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 136: just_die0135
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 137: just_die0136
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 138: just_die0137
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 139: just_die0138
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 140: just_die0139
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 141: just_die0140
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 142: just_die0141
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 143: just_die0142
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 144: just_die0143
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 145: just_die0144
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 146: just_die0145
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 147: just_die0146
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 148: just_die0147
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 149: just_die0148
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 150: just_die0149
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 151: just_die0150
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 152: just_die0151
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 153: just_die0152
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 154: just_die0153
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 155: just_die0154
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 156: just_die0155
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 157: just_die0156
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 158: just_die0157
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 159: just_die0158
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 160: just_die0159
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 161: just_die0160
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 162: just_die0161
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 163: just_die0162
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 164: just_die0163
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 165: just_die0164
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 166: just_die0165
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 167: just_die0166
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 168: just_die0167
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 169: just_die0168
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 170: just_die0169
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 171: just_die0170
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 172: just_die0171
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 173: just_die0172
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 174: just_die0173
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 175: just_die0174
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 176: just_die0175
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 177: just_die0176
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 178: just_die0177
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 179: just_die0178
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 180: just_die0179
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 181: just_die0180
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 182: just_die0181
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 183: just_die0182
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 184: just_die0183
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 185: just_die0184
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 186: just_die0185
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 187: just_die0186
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 188: just_die0187
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 189: just_die0188
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 190: just_die0189
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 191: just_die0190
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 192: just_die0191
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 193: just_die0192
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 194: just_die0193
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 195: just_die0194
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 196: just_die0195
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 197: just_die0196
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 198: just_die0197
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 199: just_die0198
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 200: just_die0199
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 201: just_die0200
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 202: just_die0201
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 203: just_die0202
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 204: just_die0203
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 205: just_die0204
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 206: just_die0205
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 207: just_die0206
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 208: just_die0207
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 209: just_die0208
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 210: just_die0209
		{x = 1036, y = 3077, width = 863, height = 651, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 211: just_die0210
		{x = 1999, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 212: laugh_Instance0000
		{x = 1999, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 213: laugh_Instance0001
		{x = 2668, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 214: laugh_Instance0002
		{x = 2668, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 215: laugh_Instance0003
		{x = 3337, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 216: laugh_Instance0004
		{x = 3337, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 217: laugh_Instance0005
		{x = 4006, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 218: laugh_Instance0006
		{x = 4006, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 219: laugh_Instance0007
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 220: laugh_Instance0008
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 221: laugh_Instance0009
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 222: laugh_Instance0010
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 223: laugh_Instance0011
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 224: laugh_Instance0012
		{x = 4675, y = 3077, width = 569, height = 598, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 225: laugh_Instance0013
		{x = 5344, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 226: mad_down0000
		{x = 5344, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 227: mad_down0001
		{x = 6025, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 228: mad_down0002
		{x = 6025, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 229: mad_down0003
		{x = 6706, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 230: mad_down0004
		{x = 6706, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 231: mad_down0005
		{x = 7387, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 232: mad_down0006
		{x = 7387, y = 3077, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 233: mad_down0007
		{x = 73, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 234: mad_down0008
		{x = 73, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 235: mad_down0009
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 236: mad_down0010
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 237: mad_down0011
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 238: mad_down0012
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 239: mad_down0013
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 240: mad_down0014
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 241: mad_down0015
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 242: mad_down0016
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 243: mad_down0017
		{x = 754, y = 3828, width = 581, height = 606, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 244: mad_down0018
		{x = 1435, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 245: mad_idle0000
		{x = 1435, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 246: mad_idle0001
		{x = 2044, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 247: mad_idle0002
		{x = 2044, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 248: mad_idle0003
		{x = 2653, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 249: mad_idle0004
		{x = 2653, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 250: mad_idle0005
		{x = 3262, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 251: mad_idle0006
		{x = 3262, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 252: mad_idle0007
		{x = 3871, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 253: mad_idle0008
		{x = 4480, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 254: mad_idle0009
		{x = 5089, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 255: mad_idle0010
		{x = 5698, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 256: mad_idle0011
		{x = 6307, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 257: mad_idle0012
		{x = 6916, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 258: mad_idle0013
		{x = 7525, y = 3828, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 259: mad_idle0014
		{x = 73, y = 4654, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 260: mad_idle0015
		{x = 682, y = 4654, width = 509, height = 726, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 261: mad_idle0016
		{x = 1291, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 262: mad_left0000
		{x = 1291, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 263: mad_left0001
		{x = 2116, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 264: mad_left0002
		{x = 2116, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 265: mad_left0003
		{x = 2941, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 266: mad_left0004
		{x = 2941, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 267: mad_left0005
		{x = 3766, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 268: mad_left0006
		{x = 3766, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 269: mad_left0007
		{x = 4591, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 270: mad_left0008
		{x = 4591, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 271: mad_left0009
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 272: mad_left0010
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 273: mad_left0011
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 274: mad_left0012
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 275: mad_left0013
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 276: mad_left0014
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 277: mad_left0015
		{x = 5416, y = 4654, width = 725, height = 689, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 278: mad_left0016
		{x = 6241, y = 4654, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 279: mad_right0000
		{x = 6241, y = 4654, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 280: mad_right0001
		{x = 7086, y = 4654, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 281: mad_right0002
		{x = 7086, y = 4654, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 282: mad_right0003
		{x = 73, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 283: mad_right0004
		{x = 73, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 284: mad_right0005
		{x = 918, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 285: mad_right0006
		{x = 918, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 286: mad_right0007
		{x = 1763, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 287: mad_right0008
		{x = 1763, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 288: mad_right0009
		{x = 2608, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 289: mad_right0010
		{x = 2608, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 290: mad_right0011
		{x = 3453, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 291: mad_right0012
		{x = 3453, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 292: mad_right0013
		{x = 3453, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 293: mad_right0014
		{x = 3453, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 294: mad_right0015
		{x = 3453, y = 5480, width = 745, height = 640, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 295: mad_right0016
		{x = 4298, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 296: mad_up0000
		{x = 4298, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 297: mad_up0001
		{x = 4942, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 298: mad_up0002
		{x = 4942, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 299: mad_up0003
		{x = 5586, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 300: mad_up0004
		{x = 5586, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 301: mad_up0005
		{x = 6230, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 302: mad_up0006
		{x = 6230, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 303: mad_up0007
		{x = 6874, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 304: mad_up0008
		{x = 6874, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 305: mad_up0009
		{x = 7518, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 306: mad_up0010
		{x = 7518, y = 5480, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 307: mad_up0011
		{x = 73, y = 6447, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 308: mad_up0012
		{x = 73, y = 6447, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 309: mad_up0013
		{x = 73, y = 6447, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 310: mad_up0014
		{x = 73, y = 6447, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 311: mad_up0015
		{x = 73, y = 6447, width = 544, height = 867, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 312: mad_up0016
		{x = 717, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 313: scream0000
		{x = 1665, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 314: scream0001
		{x = 2613, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 315: scream0002
		{x = 3561, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 316: scream0003
		{x = 4509, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 317: scream0004
		{x = 4509, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 318: scream0005
		{x = 5457, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 319: scream0006
		{x = 5457, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 320: scream0007
		{x = 6405, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 321: scream0008
		{x = 6405, y = 6447, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 322: scream0009
		{x = 73, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 323: scream0010
		{x = 73, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 324: scream0011
		{x = 1021, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 325: scream0012
		{x = 1021, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 326: scream0013
		{x = 1969, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 327: scream0014
		{x = 1969, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 328: scream0015
		{x = 2917, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 329: scream0016
		{x = 2917, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 330: scream0017
		{x = 3865, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 331: scream0018
		{x = 3865, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 332: scream0019
		{x = 4813, y = 7414, width = 848, height = 663, offsetX = 0, offsetY = 0, offsetWidth = 0, offsetHeight = 0}, -- 333: scream0020
	},
	{
		["right alt"] = {start = 1, stop = 211, speed = 24, offsetX = -10, offsetY = -10}, --bebe lloronazo
		["down alt"] = {start = 212, stop = 225, speed = 24, offsetX = 5, offsetY = -45}, --risita
		["down"] = {start = 226, stop = 244, speed = 24, offsetX = 0, offsetY = -35},
		["idle"] = {start = 245, stop = 261, speed = 24, offsetX = 0, offsetY = 0},
		["left"] = {start = 262, stop = 278, speed = 24, offsetX = 20, offsetY = -40},
		["right"] = {start = 279, stop = 295, speed = 24, offsetX = -100, offsetY = -40},
		["up"] = {start = 296, stop = 312, speed = 24, offsetX = -40, offsetY = 95},
		["up alt"] = {start = 313, stop = 333, speed = 24, offsetX = 200, offsetY = -20} -- bebe chillador
	},
	"idle"
)

return YCR_Mad
