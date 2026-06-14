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

local RESULTS_BOYFRIEND_EXCELLENT_RANK_final_v2 = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("resultsScreen/RESULTS BOYFRIEND EXCELLENT RANK final v2")),
	{
		{x = 0, y = 0, width = 430, height = 497, offsetX = -253, offsetY = -164, offsetWidth = 783, offsetHeight = 1327}, -- 1: start0000
		{x = 0, y = 0, width = 430, height = 497, offsetX = -253, offsetY = -354, offsetWidth = 783, offsetHeight = 1327}, -- 2: start0001
		{x = 430, y = 0, width = 335, height = 605, offsetX = -287, offsetY = -474, offsetWidth = 783, offsetHeight = 1327}, -- 3: start0002
		{x = 765, y = 0, width = 566, height = 299, offsetX = -150, offsetY = -872, offsetWidth = 783, offsetHeight = 1327}, -- 4: start0003
		{x = 765, y = 0, width = 566, height = 299, offsetX = -150, offsetY = -872, offsetWidth = 783, offsetHeight = 1327}, -- 5: start0004
		{x = 1331, y = 0, width = 517, height = 362, offsetX = -184, offsetY = -807, offsetWidth = 783, offsetHeight = 1327}, -- 6: start0005
		{x = 1331, y = 0, width = 517, height = 362, offsetX = -184, offsetY = -807, offsetWidth = 783, offsetHeight = 1327}, -- 7: start0006
		{x = 1848, y = 0, width = 482, height = 387, offsetX = -196, offsetY = -780, offsetWidth = 783, offsetHeight = 1327}, -- 8: start0007
		{x = 2330, y = 0, width = 507, height = 511, offsetX = -180, offsetY = -660, offsetWidth = 783, offsetHeight = 1327}, -- 9: start0008
		{x = 2330, y = 0, width = 507, height = 511, offsetX = -180, offsetY = -660, offsetWidth = 783, offsetHeight = 1327}, -- 10: start0009
		{x = 2837, y = 0, width = 514, height = 507, offsetX = -168, offsetY = -662, offsetWidth = 783, offsetHeight = 1327}, -- 11: start0010
		{x = 2837, y = 0, width = 514, height = 507, offsetX = -168, offsetY = -662, offsetWidth = 783, offsetHeight = 1327}, -- 12: start0011
		{x = 2837, y = 0, width = 514, height = 507, offsetX = -168, offsetY = -662, offsetWidth = 783, offsetHeight = 1327}, -- 13: start0012
		{x = 3351, y = 0, width = 572, height = 1169, offsetX = -110, offsetY = 0, offsetWidth = 783, offsetHeight = 1327}, -- 14: start0013
		{x = 3923, y = 0, width = 514, height = 1131, offsetX = -168, offsetY = -38, offsetWidth = 783, offsetHeight = 1327}, -- 15: start0014
		{x = 4437, y = 0, width = 570, height = 670, offsetX = -90, offsetY = -506, offsetWidth = 783, offsetHeight = 1327}, -- 16: start0015
		{x = 5007, y = 0, width = 663, height = 484, offsetX = -8, offsetY = -728, offsetWidth = 783, offsetHeight = 1327}, -- 17: start0016
		{x = 5007, y = 0, width = 663, height = 484, offsetX = -8, offsetY = -728, offsetWidth = 783, offsetHeight = 1327}, -- 18: start0017
		{x = 5670, y = 0, width = 613, height = 500, offsetX = -63, offsetY = -722, offsetWidth = 783, offsetHeight = 1327}, -- 19: start0018
		{x = 5670, y = 0, width = 613, height = 500, offsetX = -63, offsetY = -722, offsetWidth = 783, offsetHeight = 1327}, -- 20: start0019
		{x = 5670, y = 0, width = 613, height = 500, offsetX = -63, offsetY = -722, offsetWidth = 783, offsetHeight = 1327}, -- 21: start0020
		{x = 6283, y = 0, width = 515, height = 655, offsetX = -153, offsetY = -635, offsetWidth = 783, offsetHeight = 1327}, -- 22: start0021
		{x = 6283, y = 0, width = 515, height = 655, offsetX = -153, offsetY = -635, offsetWidth = 783, offsetHeight = 1327}, -- 23: start0022
		{x = 6798, y = 0, width = 640, height = 646, offsetX = -143, offsetY = -607, offsetWidth = 783, offsetHeight = 1327}, -- 24: start0023
		{x = 6798, y = 0, width = 640, height = 646, offsetX = -143, offsetY = -607, offsetWidth = 783, offsetHeight = 1327}, -- 25: start0024
		{x = 7438, y = 0, width = 677, height = 759, offsetX = 0, offsetY = -568, offsetWidth = 783, offsetHeight = 1327}, -- 26: start0025
		{x = 0, y = 1169, width = 677, height = 759, offsetX = 0, offsetY = -568, offsetWidth = 783, offsetHeight = 1327}, -- 27: start0026
		{x = 677, y = 1169, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 28: start0027
		{x = 1357, y = 1169, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 29: start0028
		{x = 2037, y = 1169, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 30: start0029
		{x = 2718, y = 1169, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 31: start0030
		{x = 3399, y = 1169, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 32: start0031
		{x = 4079, y = 1169, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 33: start0032
		{x = 4759, y = 1169, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 34: start0033
		{x = 5431, y = 1169, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 35: start0034
		{x = 6103, y = 1169, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 36: start0035
		{x = 6775, y = 1169, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 37: start0036
		{x = 7447, y = 1169, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 38: start0037
		{x = 0, y = 1928, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 39: start0038
		{x = 671, y = 1928, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 40: start0039
		{x = 1341, y = 1928, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 41: start0040
		{x = 2011, y = 1928, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 42: start0041
		{x = 2685, y = 1928, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 43: start0042
		{x = 3359, y = 1928, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 44: start0043
		{x = 4035, y = 1928, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 45: start0044
		{x = 1357, y = 1169, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 46: start0045
		{x = 4711, y = 1928, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 47: start0046
		{x = 5391, y = 1928, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 48: start0047
		{x = 6072, y = 1928, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 49: start0048
		{x = 6753, y = 1928, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 50: start0049
		{x = 7433, y = 1928, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 51: start0050
		{x = 0, y = 2680, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 52: start0051
		{x = 672, y = 2680, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 53: start0052
		{x = 1344, y = 2680, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 54: start0053
		{x = 2016, y = 2680, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 55: start0054
		{x = 2688, y = 2680, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 56: start0055
		{x = 3359, y = 2680, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 57: start0056
		{x = 4030, y = 2680, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 58: start0057
		{x = 4700, y = 2680, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 59: start0058
		{x = 5370, y = 2680, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 60: start0059
		{x = 6044, y = 2680, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 61: start0060
		{x = 6718, y = 2680, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 62: start0061
		{x = 7394, y = 2680, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 63: start0062
		{x = 0, y = 3432, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 64: start0063
		{x = 680, y = 3432, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 65: start0064
		{x = 1360, y = 3432, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 66: start0065
		{x = 1360, y = 3432, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 67: start0066
		{x = 2041, y = 3432, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 68: start0067
		{x = 2721, y = 3432, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 69: start0068
		{x = 3401, y = 3432, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 70: start0069
		{x = 4073, y = 3432, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 71: start0070
		{x = 4745, y = 3432, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 72: start0071
		{x = 5417, y = 3432, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 73: start0072
		{x = 6089, y = 3432, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 74: start0073
		{x = 6760, y = 3432, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 75: start0074
		{x = 7431, y = 3432, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 76: start0075
		{x = 0, y = 4184, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 77: start0076
		{x = 670, y = 4184, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 78: start0077
		{x = 1344, y = 4184, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 79: start0078
		{x = 2018, y = 4184, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 80: start0079
		{x = 2694, y = 4184, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 81: start0080
		{x = 3370, y = 4184, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 82: start0081
		{x = 3370, y = 4184, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 83: start0082
		{x = 4050, y = 4184, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 84: start0083
		{x = 4050, y = 4184, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 85: start0084
		{x = 4731, y = 4184, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 86: start0085
		{x = 5411, y = 4184, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 87: start0086
		{x = 6091, y = 4184, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 88: start0087
		{x = 6763, y = 4184, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 89: start0088
		{x = 7435, y = 4184, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 90: start0089
		{x = 0, y = 4936, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 91: start0090
		{x = 672, y = 4936, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 92: start0091
		{x = 1343, y = 4936, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 93: start0092
		{x = 2014, y = 4936, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 94: start0093
		{x = 2684, y = 4936, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 95: start0094
		{x = 3354, y = 4936, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 96: start0095
		{x = 4028, y = 4936, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 97: start0096
		{x = 4702, y = 4936, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 98: start0097
		{x = 5378, y = 4936, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 99: start0098
		{x = 6054, y = 4936, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 100: start0099
		{x = 6054, y = 4936, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 101: start0100
		{x = 6734, y = 4936, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 102: start0101
		{x = 6734, y = 4936, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 103: start0102
		{x = 7415, y = 4936, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 104: start0103
		{x = 0, y = 5688, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 105: start0104
		{x = 680, y = 5688, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 106: start0105
		{x = 1352, y = 5688, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 107: start0106
		{x = 2024, y = 5688, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 108: start0107
		{x = 2696, y = 5688, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 109: start0108
		{x = 3368, y = 5688, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 110: start0109
		{x = 4039, y = 5688, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 111: start0110
		{x = 4710, y = 5688, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 112: start0111
		{x = 5380, y = 5688, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 113: start0112
		{x = 6050, y = 5688, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 114: start0113
		{x = 6724, y = 5688, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 115: start0114
		{x = 7398, y = 5688, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 116: start0115
		{x = 0, y = 6440, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 117: start0116
		{x = 676, y = 6440, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 118: start0117
		{x = 676, y = 6440, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 119: start0118
		{x = 1356, y = 6440, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 120: start0119
		{x = 2037, y = 6440, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 121: start0120
		{x = 2718, y = 6440, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 122: start0121
		{x = 3398, y = 6440, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 123: start0122
		{x = 4078, y = 6440, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 124: start0123
		{x = 4750, y = 6440, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 125: start0124
		{x = 5422, y = 6440, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 126: start0125
		{x = 6094, y = 6440, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 127: start0126
		{x = 6766, y = 6440, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 128: start0127
		{x = 7437, y = 6440, width = 671, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 129: start0128
		{x = 0, y = 7192, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 130: start0129
		{x = 670, y = 7192, width = 670, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 131: start0130
		{x = 1340, y = 7192, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 132: start0131
		{x = 2014, y = 7192, width = 674, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 133: start0132
		{x = 2688, y = 7192, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 134: start0133
		{x = 3364, y = 7192, width = 676, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 135: start0134
		{x = 4040, y = 7192, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 136: start0135
		{x = 4720, y = 7192, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 137: start0136
		{x = 2037, y = 6440, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 138: start0137
		{x = 5400, y = 7192, width = 681, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 139: start0138
		{x = 6081, y = 7192, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 140: start0139
		{x = 6761, y = 7192, width = 680, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327}, -- 141: start0140
		{x = 7441, y = 7192, width = 672, height = 752, offsetX = -8, offsetY = -571, offsetWidth = 783, offsetHeight = 1327} -- 142: start0141
	},
	{
		["start"] = {start = 1, stop = 27, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 28, stop = 142, speed = 24, offsetX = 0, offsetY = 0}
	},
	"start"
)

return RESULTS_BOYFRIEND_EXCELLENT_RANK_final_v2
