# Run Script for Genetic Algorithms thingie

if [ ! -e "src/ga.js" ]; then
	# Program isn't compiled. So let's make it.
	printf "[ERROR] \"scr/ga.js\" doesn't exist!\n"
	exit 1
fi

# Run experiment
type node > /dev/null 2> /dev/null
retval1=$?
type nodejs > /dev/null 2> /dev/null
retval2=$?
type js > /dev/null 2> /dev/null
retval3=$?

if [ $retval1 -eq 0 ]; then
	# Try "node"
	node src/ga.js "$@"
elif [ $retval2 -eq 0 ]; then
	# Try "nodejs"
	nodejs src/ga.js "$@"
elif [ $retval3 -eq 0 ]; then
	# Try "js"
	js src/ga.js "$@"
else
	# If on Hydra, it's in a specific path.
	/opt/rh/rh-nodejs8/root/usr/bin/node src/ga.js "$@"
fi
