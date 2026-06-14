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

local pico_loss_final = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("pico loss final")),
	{
		{x = 0, y = 0, width = 1222, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 1: pico loss rank0000
		{x = 1222, y = 0, width = 1225, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 2: pico loss rank0001
		{x = 1222, y = 0, width = 1225, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 3: pico loss rank0002
		{x = 2447, y = 0, width = 1222, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 4: pico loss rank0003
		{x = 2447, y = 0, width = 1222, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 5: pico loss rank0004
		{x = 3669, y = 0, width = 2105, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 6: pico loss rank0005
		{x = 3669, y = 0, width = 2105, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 7: pico loss rank0006
		{x = 5774, y = 0, width = 1222, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 8: pico loss rank0007
		{x = 5774, y = 0, width = 1222, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 9: pico loss rank0008
		{x = 0, y = 737, width = 1232, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 10: pico loss rank0009
		{x = 0, y = 737, width = 1232, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 11: pico loss rank0010
		{x = 1232, y = 737, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 12: pico loss rank0011
		{x = 1232, y = 737, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 13: pico loss rank0012
		{x = 2467, y = 737, width = 1241, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 14: pico loss rank0013
		{x = 2467, y = 737, width = 1241, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 15: pico loss rank0014
		{x = 3708, y = 737, width = 1244, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 16: pico loss rank0015
		{x = 3708, y = 737, width = 1244, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 17: pico loss rank0016
		{x = 4952, y = 737, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 18: pico loss rank0017
		{x = 4952, y = 737, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 19: pico loss rank0018
		{x = 6201, y = 737, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 20: pico loss rank0019
		{x = 6201, y = 737, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 21: pico loss rank0020
		{x = 0, y = 1473, width = 1273, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 22: pico loss rank0021
		{x = 0, y = 1473, width = 1273, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 23: pico loss rank0022
		{x = 1273, y = 1473, width = 1259, height = 705, offsetX = 0, offsetY = -32, offsetWidth = 2105, offsetHeight = 737}, -- 24: pico loss rank0023
		{x = 1273, y = 1473, width = 1259, height = 705, offsetX = 0, offsetY = -32, offsetWidth = 2105, offsetHeight = 737}, -- 25: pico loss rank0024
		{x = 2532, y = 1473, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 26: pico loss rank0025
		{x = 2532, y = 1473, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 27: pico loss rank0026
		{x = 3774, y = 1473, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 28: pico loss rank0027
		{x = 3774, y = 1473, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 29: pico loss rank0028
		{x = 5020, y = 1473, width = 1243, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 30: pico loss rank0029
		{x = 5020, y = 1473, width = 1243, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 31: pico loss rank0030
		{x = 0, y = 0, width = 1222, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 32: pico loss rank0031
		{x = 0, y = 0, width = 1222, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 33: pico loss rank0032
		{x = 6263, y = 1473, width = 1225, height = 724, offsetX = 0, offsetY = -13, offsetWidth = 2105, offsetHeight = 737}, -- 34: pico loss rank0033
		{x = 6263, y = 1473, width = 1225, height = 724, offsetX = 0, offsetY = -13, offsetWidth = 2105, offsetHeight = 737}, -- 35: pico loss rank0034
		{x = 0, y = 2197, width = 1222, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 36: pico loss rank0035
		{x = 0, y = 2197, width = 1222, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 37: pico loss rank0036
		{x = 1222, y = 2197, width = 1232, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 38: pico loss rank0037
		{x = 1222, y = 2197, width = 1232, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 39: pico loss rank0038
		{x = 2454, y = 2197, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 40: pico loss rank0039
		{x = 2454, y = 2197, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 41: pico loss rank0040
		{x = 3689, y = 2197, width = 1241, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 42: pico loss rank0041
		{x = 3689, y = 2197, width = 1241, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 43: pico loss rank0042
		{x = 4930, y = 2197, width = 1244, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 44: pico loss rank0043
		{x = 4930, y = 2197, width = 1244, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 45: pico loss rank0044
		{x = 4930, y = 2197, width = 1244, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 46: pico loss rank0045
		{x = 6174, y = 2197, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 47: pico loss rank0046
		{x = 6174, y = 2197, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 48: pico loss rank0047
		{x = 0, y = 2934, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 49: pico loss rank0048
		{x = 0, y = 2934, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 50: pico loss rank0049
		{x = 1247, y = 2934, width = 1273, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 51: pico loss rank0050
		{x = 1247, y = 2934, width = 1273, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 52: pico loss rank0051
		{x = 2520, y = 2934, width = 1259, height = 705, offsetX = 0, offsetY = -32, offsetWidth = 2105, offsetHeight = 737}, -- 53: pico loss rank0052
		{x = 2520, y = 2934, width = 1259, height = 705, offsetX = 0, offsetY = -32, offsetWidth = 2105, offsetHeight = 737}, -- 54: pico loss rank0053
		{x = 3779, y = 2934, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 55: pico loss rank0054
		{x = 3779, y = 2934, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 56: pico loss rank0055
		{x = 3779, y = 2934, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 57: pico loss rank0056
		{x = 5021, y = 2934, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 58: pico loss rank0057
		{x = 5021, y = 2934, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 59: pico loss rank0058
		{x = 5021, y = 2934, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 60: pico loss rank0059
		{x = 6267, y = 2934, width = 1223, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 61: pico loss rank0060
		{x = 0, y = 3670, width = 1223, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 62: pico loss rank0061
		{x = 1223, y = 3670, width = 1197, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 63: pico loss rank0062
		{x = 1223, y = 3670, width = 1197, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 64: pico loss rank0063
		{x = 2420, y = 3670, width = 1191, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 65: pico loss rank0064
		{x = 2420, y = 3670, width = 1191, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 66: pico loss rank0065
		{x = 2420, y = 3670, width = 1191, height = 737, offsetX = 0, offsetY = 0, offsetWidth = 2105, offsetHeight = 737}, -- 67: pico loss rank0066
		{x = 3611, y = 3670, width = 1177, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 68: pico loss rank0067
		{x = 3611, y = 3670, width = 1177, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 69: pico loss rank0068
		{x = 3611, y = 3670, width = 1177, height = 736, offsetX = 0, offsetY = -1, offsetWidth = 2105, offsetHeight = 737}, -- 70: pico loss rank0069
		{x = 4788, y = 3670, width = 1200, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 71: pico loss rank0070
		{x = 4788, y = 3670, width = 1200, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 72: pico loss rank0071
		{x = 4788, y = 3670, width = 1200, height = 732, offsetX = 0, offsetY = -5, offsetWidth = 2105, offsetHeight = 737}, -- 73: pico loss rank0072
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 74: pico loss rank0073
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 75: pico loss rank0074
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 76: pico loss rank0075
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 77: pico loss rank0076
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 78: pico loss rank0077
		{x = 5988, y = 3670, width = 1177, height = 584, offsetX = 0, offsetY = -153, offsetWidth = 2105, offsetHeight = 737}, -- 79: pico loss rank0078
		{x = 0, y = 4407, width = 1177, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 80: pico loss rank0079
		{x = 0, y = 4407, width = 1177, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 81: pico loss rank0080
		{x = 0, y = 4407, width = 1177, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 82: pico loss rank0081
		{x = 0, y = 4407, width = 1177, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 83: pico loss rank0082
		{x = 1177, y = 4407, width = 1178, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 84: pico loss rank0083
		{x = 1177, y = 4407, width = 1178, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 85: pico loss rank0084
		{x = 2355, y = 4407, width = 1178, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 86: pico loss rank0085
		{x = 2355, y = 4407, width = 1178, height = 583, offsetX = 0, offsetY = -154, offsetWidth = 2105, offsetHeight = 737}, -- 87: pico loss rank0086
		{x = 3533, y = 4407, width = 1179, height = 587, offsetX = 0, offsetY = -150, offsetWidth = 2105, offsetHeight = 737}, -- 88: pico loss rank0087
		{x = 4712, y = 4407, width = 1179, height = 587, offsetX = 0, offsetY = -150, offsetWidth = 2105, offsetHeight = 737}, -- 89: pico loss rank0088
		{x = 5891, y = 4407, width = 1218, height = 578, offsetX = 0, offsetY = -159, offsetWidth = 2105, offsetHeight = 737}, -- 90: pico loss rank0089
		{x = 0, y = 4994, width = 1218, height = 578, offsetX = 0, offsetY = -159, offsetWidth = 2105, offsetHeight = 737}, -- 91: pico loss rank0090
		{x = 1218, y = 4994, width = 1323, height = 578, offsetX = 0, offsetY = -159, offsetWidth = 2105, offsetHeight = 737}, -- 92: pico loss rank0091
		{x = 2541, y = 4994, width = 1645, height = 698, offsetX = 0, offsetY = -39, offsetWidth = 2105, offsetHeight = 737}, -- 93: pico loss rank0092
		{x = 4186, y = 4994, width = 1349, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 94: pico loss rank0093
		{x = 5535, y = 4994, width = 1345, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 95: pico loss rank0094
		{x = 0, y = 5692, width = 1336, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 96: pico loss rank0095
		{x = 1336, y = 5692, width = 1365, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 97: pico loss rank0096
		{x = 2701, y = 5692, width = 1365, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 98: pico loss rank0097
		{x = 4066, y = 5692, width = 1365, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 99: pico loss rank0098
		{x = 4066, y = 5692, width = 1365, height = 579, offsetX = 0, offsetY = -158, offsetWidth = 2105, offsetHeight = 737}, -- 100: pico loss rank0099
		{x = 5431, y = 5692, width = 1352, height = 586, offsetX = 0, offsetY = -151, offsetWidth = 2105, offsetHeight = 737}, -- 101: pico loss rank0100
		{x = 6783, y = 5692, width = 1352, height = 586, offsetX = 0, offsetY = -151, offsetWidth = 2105, offsetHeight = 737}, -- 102: pico loss rank0101
		{x = 0, y = 6278, width = 1354, height = 585, offsetX = 0, offsetY = -152, offsetWidth = 2105, offsetHeight = 737}, -- 103: pico loss rank0102
		{x = 0, y = 6278, width = 1354, height = 585, offsetX = 0, offsetY = -152, offsetWidth = 2105, offsetHeight = 737}, -- 104: pico loss rank0103
		{x = 1354, y = 6278, width = 1343, height = 590, offsetX = 0, offsetY = -147, offsetWidth = 2105, offsetHeight = 737}, -- 105: pico loss rank0104
		{x = 2697, y = 6278, width = 1343, height = 590, offsetX = 0, offsetY = -147, offsetWidth = 2105, offsetHeight = 737}, -- 106: pico loss rank0105
		{x = 4040, y = 6278, width = 1334, height = 593, offsetX = 0, offsetY = -144, offsetWidth = 2105, offsetHeight = 737}, -- 107: pico loss rank0106
		{x = 5374, y = 6278, width = 1334, height = 593, offsetX = 0, offsetY = -144, offsetWidth = 2105, offsetHeight = 737}, -- 108: pico loss rank0107
		{x = 6708, y = 6278, width = 1334, height = 598, offsetX = 0, offsetY = -139, offsetWidth = 2105, offsetHeight = 737}, -- 109: pico loss rank0108
		{x = 6708, y = 6278, width = 1334, height = 598, offsetX = 0, offsetY = -139, offsetWidth = 2105, offsetHeight = 737}, -- 110: pico loss rank0109
		{x = 0, y = 6876, width = 1327, height = 601, offsetX = 0, offsetY = -136, offsetWidth = 2105, offsetHeight = 737}, -- 111: pico loss rank0110
		{x = 1327, y = 6876, width = 2105, height = 601, offsetX = 0, offsetY = -136, offsetWidth = 2105, offsetHeight = 737}, -- 112: pico loss rank0111
		{x = 3432, y = 6876, width = 2105, height = 603, offsetX = 0, offsetY = -134, offsetWidth = 2105, offsetHeight = 737}, -- 113: pico loss rank0112
		{x = 5537, y = 6876, width = 2105, height = 603, offsetX = 0, offsetY = -134, offsetWidth = 2105, offsetHeight = 737}, -- 114: pico loss rank0113
		{x = 0, y = 7479, width = 1330, height = 608, offsetX = 0, offsetY = -129, offsetWidth = 2105, offsetHeight = 737}, -- 115: pico loss rank0114
		{x = 0, y = 7479, width = 1330, height = 608, offsetX = 0, offsetY = -129, offsetWidth = 2105, offsetHeight = 737}, -- 116: pico loss rank0115
		{x = 1330, y = 7479, width = 1344, height = 611, offsetX = 0, offsetY = -126, offsetWidth = 2105, offsetHeight = 737}, -- 117: pico loss rank0116
		{x = 1330, y = 7479, width = 1344, height = 611, offsetX = 0, offsetY = -126, offsetWidth = 2105, offsetHeight = 737}, -- 118: pico loss rank0117
		{x = 2674, y = 7479, width = 1332, height = 615, offsetX = 0, offsetY = -122, offsetWidth = 2105, offsetHeight = 737}, -- 119: pico loss rank0118
		{x = 4006, y = 7479, width = 1332, height = 615, offsetX = 0, offsetY = -122, offsetWidth = 2105, offsetHeight = 737}, -- 120: pico loss rank0119
		{x = 5338, y = 7479, width = 1337, height = 619, offsetX = 0, offsetY = -118, offsetWidth = 2105, offsetHeight = 737}, -- 121: pico loss rank0120
		{x = 6675, y = 7479, width = 1337, height = 619, offsetX = 0, offsetY = -118, offsetWidth = 2105, offsetHeight = 737}, -- 122: pico loss rank0121
		{x = 1232, y = 737, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 123: pico loss rank0153
		{x = 1232, y = 737, width = 1235, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737}, -- 124: pico loss rank0154
		{x = 4952, y = 737, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 125: pico loss rank0159
		{x = 4952, y = 737, width = 1249, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 126: pico loss rank0160
		{x = 6201, y = 737, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 127: pico loss rank0161
		{x = 6201, y = 737, width = 1247, height = 702, offsetX = 0, offsetY = -35, offsetWidth = 2105, offsetHeight = 737}, -- 128: pico loss rank0162
		{x = 2532, y = 1473, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 129: pico loss rank0167
		{x = 2532, y = 1473, width = 1242, height = 699, offsetX = 0, offsetY = -38, offsetWidth = 2105, offsetHeight = 737}, -- 130: pico loss rank0168
		{x = 3774, y = 1473, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 131: pico loss rank0169
		{x = 3774, y = 1473, width = 1246, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 132: pico loss rank0170
		{x = 5020, y = 1473, width = 1243, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 133: pico loss rank0171
		{x = 5020, y = 1473, width = 1243, height = 700, offsetX = 0, offsetY = -37, offsetWidth = 2105, offsetHeight = 737}, -- 134: pico loss rank0172
		{x = 0, y = 0, width = 1222, height = 697, offsetX = 0, offsetY = -40, offsetWidth = 2105, offsetHeight = 737} -- 135: pico loss rank0173
	},
	{
		["pico loss rank"] = {start = 1, stop = 135, speed = 24, offsetX = 0, offsetY = 0}
	},
	"pico loss rank"
)

return pico_loss_final
