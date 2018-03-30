# Run Script for AICA thingie

if [ ! -e "aica" ]; then
	# Program isn't compiled. So let's make it.
	make
fi

# Clean up
rm -f "frame"*".pgm"

# Run experiment
./aica "$@"

# Generate a GIF
if [ $? -eq 0 ]; then
	convert -loop 0 -delay 10 frame*.pgm -filter box -resize 800% result.gif
fi

# Clean up (Yes, twice)
rm -f "frame"*".pgm"
