# Run Script for ACIA thingie

if [ ! -e "acia" ]; then
	# Program isn't compiled. So let's make it.
	make
fi

# Clean up
rm -f "frame"*".pgm"

# Run experiment
./acia "$@"

# Generate a GIF
if [ $? -eq 0 ]; then
	convert -loop 0 -delay 5 frame*.pgm result.gif
fi
