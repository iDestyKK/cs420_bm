# 
# File concatenator
#
# Description:
#     Because I'm not doing this in shell script...
# 
# Author:
#     Clara Nguyen
#

import sys

flinelist = []

for x in range(0, len(sys.argv)):
	flinelist.append([])

# Read the files into arrays
topbar = ""
for i in range(1, len(sys.argv)):
	with open(sys.argv[i]) as fp:
		flinelist[i] = fp.readlines()
	flinelist[i] = [x.strip() for x in flinelist[i]]
	topbar = flinelist[i][0]
	flinelist[i] = flinelist[i][1:]
	for j in range(0, len(flinelist[i])):
		flinelist[i][j] = [float(x) for x in flinelist[i][j].split(',')]

# Compute average
flinelist[0] = flinelist[1]

for i in range(2, len(sys.argv)):
	for j in range(0, len(flinelist[i])):
		for k in range(0, len(flinelist[i][j])):
			flinelist[0][j][k] += flinelist[i][j][k]

print topbar
for j in range(0, len(flinelist[0])):
	for k in range(0, len(flinelist[0][j])):
		flinelist[0][j][k] /= (len(sys.argv) - 1)
		sys.stdout.write("%lg" % (flinelist[0][j][k]))
		if (k < len(flinelist[0][j]) - 1):
			sys.stdout.write(",");
		else:
			sys.stdout.write("\n");
