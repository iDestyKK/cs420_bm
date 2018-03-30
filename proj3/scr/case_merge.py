# Merges CSV files that are listed in the parameters.

import sys

flinelist = []

for x in range(0, len(sys.argv)):
	flinelist.append([])

for i in range(1, len(sys.argv)):
	with open(sys.argv[i]) as fp:
		flinelist[i] = fp.readlines()

	flinelist[i] = [x.strip() for x in flinelist[i]]
	topbar = flinelist[i][0]
	flinelist[i] = flinelist[i][1:]
	for j in range(0, len(flinelist[i])):
		flinelist[i][j] = [float(x) for x in flinelist[i][j].split(',')]

# Compute total
for i in range(2, len(sys.argv)):
	for j in range(0, len(flinelist[i])):
		for k in range(1, len(flinelist[i][j])):
			flinelist[1][j][k] += flinelist[i][j][k];

# Compute the average
for i in range(0, len(flinelist[1])):
	for j in range(1, len(flinelist[1][i])):
		flinelist[1][i][j] /= (len(sys.argv) - 1)

print topbar
for i in range(0, len(flinelist[1])):
	for j in range(0, len(flinelist[1][i])):
		sys.stdout.write("%lg" % (flinelist[1][i][j]))
		if (j < len(flinelist[1][i]) - 1):
			sys.stdout.write(",")
		else:
			sys.stdout.write("\n")
