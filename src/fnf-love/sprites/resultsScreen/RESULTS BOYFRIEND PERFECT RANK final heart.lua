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

local RESULTS_BOYFRIEND_PERFECT_RANK_final_heart = graphics.newSprite(
	love.graphics.newImage(graphics.imagePath("resultsScreen/RESULTS BOYFRIEND PERFECT RANK final heart")),
	{
		{x = 0, y = 0, width = 12, height = 25, offsetX = -73, offsetY = -155, offsetWidth = 197, offsetHeight = 207}, -- 1: hearts full anim0000
		{x = 12, y = 0, width = 24, height = 11, offsetX = -72, offsetY = -154, offsetWidth = 197, offsetHeight = 207}, -- 2: hearts full anim0001
		{x = 12, y = 0, width = 24, height = 11, offsetX = -72, offsetY = -154, offsetWidth = 197, offsetHeight = 207}, -- 3: hearts full anim0002
		{x = 36, y = 0, width = 16, height = 18, offsetX = -76, offsetY = -147, offsetWidth = 197, offsetHeight = 207}, -- 4: hearts full anim0003
		{x = 36, y = 0, width = 16, height = 18, offsetX = -76, offsetY = -147, offsetWidth = 197, offsetHeight = 207}, -- 5: hearts full anim0004
		{x = 52, y = 0, width = 17, height = 16, offsetX = -77, offsetY = -145, offsetWidth = 197, offsetHeight = 207}, -- 6: hearts full anim0005
		{x = 52, y = 0, width = 17, height = 16, offsetX = -77, offsetY = -145, offsetWidth = 197, offsetHeight = 207}, -- 7: hearts full anim0006
		{x = 52, y = 0, width = 17, height = 16, offsetX = -77, offsetY = -145, offsetWidth = 197, offsetHeight = 207}, -- 8: hearts full anim0007
		{x = 69, y = 0, width = 22, height = 20, offsetX = -83, offsetY = -136, offsetWidth = 197, offsetHeight = 207}, -- 9: hearts full anim0008
		{x = 69, y = 0, width = 22, height = 20, offsetX = -83, offsetY = -136, offsetWidth = 197, offsetHeight = 207}, -- 10: hearts full anim0009
		{x = 69, y = 0, width = 22, height = 20, offsetX = -83, offsetY = -136, offsetWidth = 197, offsetHeight = 207}, -- 11: hearts full anim0010
		{x = 91, y = 0, width = 28, height = 25, offsetX = -85, offsetY = -127, offsetWidth = 197, offsetHeight = 207}, -- 12: hearts full anim0011
		{x = 91, y = 0, width = 28, height = 25, offsetX = -85, offsetY = -127, offsetWidth = 197, offsetHeight = 207}, -- 13: hearts full anim0012
		{x = 91, y = 0, width = 28, height = 25, offsetX = -85, offsetY = -127, offsetWidth = 197, offsetHeight = 207}, -- 14: hearts full anim0013
		{x = 119, y = 0, width = 31, height = 28, offsetX = -88, offsetY = -121, offsetWidth = 197, offsetHeight = 207}, -- 15: hearts full anim0014
		{x = 150, y = 0, width = 36, height = 47, offsetX = -88, offsetY = -121, offsetWidth = 197, offsetHeight = 207}, -- 16: hearts full anim0015
		{x = 186, y = 0, width = 49, height = 41, offsetX = -86, offsetY = -113, offsetWidth = 197, offsetHeight = 207}, -- 17: hearts full anim0016
		{x = 186, y = 0, width = 49, height = 41, offsetX = -86, offsetY = -113, offsetWidth = 197, offsetHeight = 207}, -- 18: hearts full anim0017
		{x = 235, y = 0, width = 49, height = 45, offsetX = -82, offsetY = -109, offsetWidth = 197, offsetHeight = 207}, -- 19: hearts full anim0018
		{x = 235, y = 0, width = 49, height = 45, offsetX = -82, offsetY = -109, offsetWidth = 197, offsetHeight = 207}, -- 20: hearts full anim0019
		{x = 284, y = 0, width = 58, height = 46, offsetX = -75, offsetY = -103, offsetWidth = 197, offsetHeight = 207}, -- 21: hearts full anim0020
		{x = 284, y = 0, width = 58, height = 46, offsetX = -75, offsetY = -103, offsetWidth = 197, offsetHeight = 207}, -- 22: hearts full anim0021
		{x = 342, y = 0, width = 66, height = 52, offsetX = -67, offsetY = -97, offsetWidth = 197, offsetHeight = 207}, -- 23: hearts full anim0022
		{x = 408, y = 0, width = 77, height = 48, offsetX = -67, offsetY = -97, offsetWidth = 197, offsetHeight = 207}, -- 24: hearts full anim0023
		{x = 485, y = 0, width = 84, height = 50, offsetX = -60, offsetY = -95, offsetWidth = 197, offsetHeight = 207}, -- 25: hearts full anim0024
		{x = 485, y = 0, width = 84, height = 50, offsetX = -60, offsetY = -95, offsetWidth = 197, offsetHeight = 207}, -- 26: hearts full anim0025
		{x = 569, y = 0, width = 104, height = 52, offsetX = -48, offsetY = -89, offsetWidth = 197, offsetHeight = 207}, -- 27: hearts full anim0026
		{x = 673, y = 0, width = 104, height = 105, offsetX = -48, offsetY = -89, offsetWidth = 197, offsetHeight = 207}, -- 28: hearts full anim0027
		{x = 777, y = 0, width = 111, height = 97, offsetX = -41, offsetY = -82, offsetWidth = 197, offsetHeight = 207}, -- 29: hearts full anim0028
		{x = 888, y = 0, width = 117, height = 97, offsetX = -41, offsetY = -82, offsetWidth = 197, offsetHeight = 207}, -- 30: hearts full anim0029
		{x = 1005, y = 0, width = 120, height = 103, offsetX = -38, offsetY = -76, offsetWidth = 197, offsetHeight = 207}, -- 31: hearts full anim0030
		{x = 1125, y = 0, width = 123, height = 103, offsetX = -38, offsetY = -76, offsetWidth = 197, offsetHeight = 207}, -- 32: hearts full anim0031
		{x = 1248, y = 0, width = 123, height = 105, offsetX = -38, offsetY = -70, offsetWidth = 197, offsetHeight = 207}, -- 33: hearts full anim0032
		{x = 1371, y = 0, width = 121, height = 105, offsetX = -38, offsetY = -70, offsetWidth = 197, offsetHeight = 207}, -- 34: hearts full anim0033
		{x = 1492, y = 0, width = 118, height = 110, offsetX = -41, offsetY = -65, offsetWidth = 197, offsetHeight = 207}, -- 35: hearts full anim0034
		{x = 1610, y = 0, width = 114, height = 105, offsetX = -41, offsetY = -65, offsetWidth = 197, offsetHeight = 207}, -- 36: hearts full anim0035
		{x = 1724, y = 0, width = 112, height = 112, offsetX = -43, offsetY = -58, offsetWidth = 197, offsetHeight = 207}, -- 37: hearts full anim0036
		{x = 1836, y = 0, width = 107, height = 112, offsetX = -43, offsetY = -58, offsetWidth = 197, offsetHeight = 207}, -- 38: hearts full anim0037
		{x = 1943, y = 0, width = 104, height = 113, offsetX = -46, offsetY = -53, offsetWidth = 197, offsetHeight = 207}, -- 39: hearts full anim0038
		{x = 0, y = 113, width = 105, height = 154, offsetX = -38, offsetY = -53, offsetWidth = 197, offsetHeight = 207}, -- 40: hearts full anim0039
		{x = 105, y = 113, width = 106, height = 145, offsetX = -37, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 41: hearts full anim0040
		{x = 211, y = 113, width = 99, height = 145, offsetX = -37, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 42: hearts full anim0041
		{x = 310, y = 113, width = 95, height = 144, offsetX = -41, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 43: hearts full anim0042
		{x = 405, y = 113, width = 91, height = 149, offsetX = -41, offsetY = -43, offsetWidth = 197, offsetHeight = 207}, -- 44: hearts full anim0043
		{x = 496, y = 113, width = 90, height = 145, offsetX = -42, offsetY = -43, offsetWidth = 197, offsetHeight = 207}, -- 45: hearts full anim0044
		{x = 586, y = 113, width = 89, height = 145, offsetX = -42, offsetY = -43, offsetWidth = 197, offsetHeight = 207}, -- 46: hearts full anim0045
		{x = 675, y = 113, width = 94, height = 150, offsetX = -42, offsetY = -38, offsetWidth = 197, offsetHeight = 207}, -- 47: hearts full anim0046
		{x = 769, y = 113, width = 88, height = 146, offsetX = -48, offsetY = -38, offsetWidth = 197, offsetHeight = 207}, -- 48: hearts full anim0047
		{x = 769, y = 113, width = 88, height = 146, offsetX = -48, offsetY = -38, offsetWidth = 197, offsetHeight = 207}, -- 49: hearts full anim0048
		{x = 857, y = 113, width = 96, height = 152, offsetX = -48, offsetY = -32, offsetWidth = 197, offsetHeight = 207}, -- 50: hearts full anim0049
		{x = 953, y = 113, width = 94, height = 148, offsetX = -50, offsetY = -32, offsetWidth = 197, offsetHeight = 207}, -- 51: hearts full anim0050
		{x = 1047, y = 113, width = 97, height = 148, offsetX = -50, offsetY = -32, offsetWidth = 197, offsetHeight = 207}, -- 52: hearts full anim0051
		{x = 1144, y = 113, width = 101, height = 153, offsetX = -50, offsetY = -27, offsetWidth = 197, offsetHeight = 207}, -- 53: hearts full anim0052
		{x = 1245, y = 113, width = 104, height = 149, offsetX = -48, offsetY = -27, offsetWidth = 197, offsetHeight = 207}, -- 54: hearts full anim0053
		{x = 1245, y = 113, width = 104, height = 149, offsetX = -48, offsetY = -27, offsetWidth = 197, offsetHeight = 207}, -- 55: hearts full anim0054
		{x = 1349, y = 113, width = 117, height = 150, offsetX = -42, offsetY = -22, offsetWidth = 197, offsetHeight = 207}, -- 56: hearts full anim0055
		{x = 1466, y = 113, width = 124, height = 150, offsetX = -35, offsetY = -22, offsetWidth = 197, offsetHeight = 207}, -- 57: hearts full anim0056
		{x = 1590, y = 113, width = 125, height = 147, offsetX = -34, offsetY = -22, offsetWidth = 197, offsetHeight = 207}, -- 58: hearts full anim0057
		{x = 1715, y = 113, width = 132, height = 138, offsetX = -34, offsetY = -31, offsetWidth = 197, offsetHeight = 207}, -- 59: hearts full anim0058
		{x = 1847, y = 113, width = 128, height = 135, offsetX = -38, offsetY = -31, offsetWidth = 197, offsetHeight = 207}, -- 60: hearts full anim0059
		{x = 1847, y = 113, width = 128, height = 135, offsetX = -38, offsetY = -31, offsetWidth = 197, offsetHeight = 207}, -- 61: hearts full anim0060
		{x = 0, y = 267, width = 143, height = 137, offsetX = -32, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 62: hearts full anim0061
		{x = 0, y = 267, width = 143, height = 137, offsetX = -32, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 63: hearts full anim0062
		{x = 143, y = 267, width = 150, height = 134, offsetX = -25, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 64: hearts full anim0063
		{x = 293, y = 267, width = 158, height = 139, offsetX = -25, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 65: hearts full anim0064
		{x = 451, y = 267, width = 170, height = 138, offsetX = -13, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 66: hearts full anim0065
		{x = 451, y = 267, width = 170, height = 138, offsetX = -13, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 67: hearts full anim0066
		{x = 621, y = 267, width = 184, height = 138, offsetX = -6, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 68: hearts full anim0067
		{x = 621, y = 267, width = 184, height = 138, offsetX = -6, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 69: hearts full anim0068
		{x = 805, y = 267, width = 187, height = 133, offsetX = -3, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 70: hearts full anim0069
		{x = 992, y = 267, width = 194, height = 139, offsetX = -3, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 71: hearts full anim0070
		{x = 1186, y = 267, width = 194, height = 137, offsetX = -3, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 72: hearts full anim0071
		{x = 1380, y = 267, width = 194, height = 137, offsetX = -3, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 73: hearts full anim0072
		{x = 1574, y = 267, width = 130, height = 91, offsetX = -6, offsetY = -52, offsetWidth = 197, offsetHeight = 207}, -- 74: hearts full anim0073
		{x = 1704, y = 267, width = 130, height = 128, offsetX = -6, offsetY = -52, offsetWidth = 197, offsetHeight = 207}, -- 75: hearts full anim0074
		{x = 1834, y = 267, width = 128, height = 113, offsetX = -8, offsetY = -52, offsetWidth = 197, offsetHeight = 207}, -- 76: hearts full anim0075
		{x = 0, y = 406, width = 137, height = 119, offsetX = -8, offsetY = -46, offsetWidth = 197, offsetHeight = 207}, -- 77: hearts full anim0076
		{x = 137, y = 406, width = 134, height = 119, offsetX = -11, offsetY = -46, offsetWidth = 197, offsetHeight = 207}, -- 78: hearts full anim0077
		{x = 271, y = 406, width = 134, height = 119, offsetX = -11, offsetY = -46, offsetWidth = 197, offsetHeight = 207}, -- 79: hearts full anim0078
		{x = 405, y = 406, width = 136, height = 120, offsetX = -15, offsetY = -41, offsetWidth = 197, offsetHeight = 207}, -- 80: hearts full anim0079
		{x = 541, y = 406, width = 136, height = 120, offsetX = -15, offsetY = -41, offsetWidth = 197, offsetHeight = 207}, -- 81: hearts full anim0080
		{x = 541, y = 406, width = 136, height = 120, offsetX = -15, offsetY = -41, offsetWidth = 197, offsetHeight = 207}, -- 82: hearts full anim0081
		{x = 677, y = 406, width = 148, height = 122, offsetX = -10, offsetY = -35, offsetWidth = 197, offsetHeight = 207}, -- 83: hearts full anim0082
		{x = 677, y = 406, width = 148, height = 122, offsetX = -10, offsetY = -35, offsetWidth = 197, offsetHeight = 207}, -- 84: hearts full anim0083
		{x = 825, y = 406, width = 155, height = 122, offsetX = -3, offsetY = -35, offsetWidth = 197, offsetHeight = 207}, -- 85: hearts full anim0084
		{x = 980, y = 406, width = 110, height = 92, offsetX = -3, offsetY = -61, offsetWidth = 197, offsetHeight = 207}, -- 86: hearts full anim0085
		{x = 1090, y = 406, width = 113, height = 99, offsetX = 0, offsetY = -54, offsetWidth = 197, offsetHeight = 207}, -- 87: hearts full anim0086
		{x = 1090, y = 406, width = 113, height = 99, offsetX = 0, offsetY = -54, offsetWidth = 197, offsetHeight = 207}, -- 88: hearts full anim0087
		{x = 1203, y = 406, width = 119, height = 101, offsetX = 0, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 89: hearts full anim0088
		{x = 1322, y = 406, width = 124, height = 121, offsetX = 0, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 90: hearts full anim0089
		{x = 1446, y = 406, width = 132, height = 111, offsetX = -3, offsetY = -43, offsetWidth = 197, offsetHeight = 207}, -- 91: hearts full anim0090
		{x = 1578, y = 406, width = 132, height = 111, offsetX = -3, offsetY = -43, offsetWidth = 197, offsetHeight = 207}, -- 92: hearts full anim0091
		{x = 1710, y = 406, width = 126, height = 118, offsetX = -5, offsetY = -36, offsetWidth = 197, offsetHeight = 207}, -- 93: hearts full anim0092
		{x = 1710, y = 406, width = 126, height = 118, offsetX = -5, offsetY = -36, offsetWidth = 197, offsetHeight = 207}, -- 94: hearts full anim0093
		{x = 1836, y = 406, width = 125, height = 118, offsetX = -8, offsetY = -31, offsetWidth = 197, offsetHeight = 207}, -- 95: hearts full anim0094
		{x = 1836, y = 406, width = 125, height = 118, offsetX = -8, offsetY = -31, offsetWidth = 197, offsetHeight = 207}, -- 96: hearts full anim0095
		{x = 0, y = 528, width = 121, height = 123, offsetX = -12, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 97: hearts full anim0096
		{x = 121, y = 528, width = 132, height = 119, offsetX = -12, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 98: hearts full anim0097
		{x = 253, y = 528, width = 132, height = 119, offsetX = -12, offsetY = -26, offsetWidth = 197, offsetHeight = 207}, -- 99: hearts full anim0098
		{x = 385, y = 528, width = 128, height = 124, offsetX = -16, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 100: hearts full anim0099
		{x = 513, y = 528, width = 136, height = 120, offsetX = -16, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 101: hearts full anim0100
		{x = 649, y = 528, width = 136, height = 173, offsetX = -16, offsetY = -21, offsetWidth = 197, offsetHeight = 207}, -- 102: hearts full anim0101
		{x = 785, y = 528, width = 132, height = 163, offsetX = -20, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 103: hearts full anim0102
		{x = 917, y = 528, width = 138, height = 163, offsetX = -20, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 104: hearts full anim0103
		{x = 1055, y = 528, width = 138, height = 163, offsetX = -20, offsetY = -16, offsetWidth = 197, offsetHeight = 207}, -- 105: hearts full anim0104
		{x = 1193, y = 528, width = 137, height = 169, offsetX = -24, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 106: hearts full anim0105
		{x = 1330, y = 528, width = 137, height = 165, offsetX = -24, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 107: hearts full anim0106
		{x = 1467, y = 528, width = 135, height = 165, offsetX = -24, offsetY = -10, offsetWidth = 197, offsetHeight = 207}, -- 108: hearts full anim0107
		{x = 1602, y = 528, width = 132, height = 170, offsetX = -27, offsetY = -5, offsetWidth = 197, offsetHeight = 207}, -- 109: hearts full anim0108
		{x = 1734, y = 528, width = 129, height = 165, offsetX = -27, offsetY = -5, offsetWidth = 197, offsetHeight = 207}, -- 110: hearts full anim0109
		{x = 1863, y = 528, width = 129, height = 165, offsetX = -27, offsetY = -5, offsetWidth = 197, offsetHeight = 207}, -- 111: hearts full anim0110
		{x = 0, y = 701, width = 120, height = 170, offsetX = -31, offsetY = 0, offsetWidth = 197, offsetHeight = 207}, -- 112: hearts full anim0111
		{x = 120, y = 701, width = 120, height = 166, offsetX = -31, offsetY = 0, offsetWidth = 197, offsetHeight = 207}, -- 113: hearts full anim0112
		{x = 240, y = 701, width = 112, height = 207, offsetX = -31, offsetY = 0, offsetWidth = 197, offsetHeight = 207}, -- 114: hearts full anim0113
		{x = 105, y = 113, width = 106, height = 145, offsetX = -37, offsetY = -48, offsetWidth = 197, offsetHeight = 207}, -- 115: hearts full anim0114
		{x = 211, y = 113, width = 99, height = 145, offsetX = -37, offsetY = -48, offsetWidth = 197, offsetHeight = 207} -- 116: hearts full anim0115
	},
	{
		["start"] = {start = 1, stop = 41, speed = 24, offsetX = 0, offsetY = 0},
		["idle"] = {start = 42, stop = 116, speed = 24, offsetX = 0, offsetY = 0}
	},
	"start"
)

return RESULTS_BOYFRIEND_PERFECT_RANK_final_heart
