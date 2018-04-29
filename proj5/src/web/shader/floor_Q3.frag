precision mediump float;

varying vec3 frag_colour;
varying vec3 vec_posv;

float Q3() {
	//Equation 3
	return cos(
		sqrt(abs(pow(vec_posv.x, 2.0) + pow(vec_posv.y, 2.0) - sin(10.0 - vec_posv.x)))
	) *
	sqrt(abs(pow(vec_posv.x, 2.0) + pow(vec_posv.y, 2.0)));
}

void main() {
	float val = Q3();
	val /= 100.0;

	//Make it so that 0.1 is the lowest that "val" can be.
	val = (val * 0.9) + 0.1;

	//Set the colour to the Z value (the value the equation spits out)
	gl_FragColor = vec4(vec3(val), 1.0);

	//Draw Grid Lines if necessary
	if (
		abs(vec_posv.x - float(int(vec_posv.x))) < 0.05 ||
		abs(vec_posv.y - float(int(vec_posv.y))) < 0.05
	) {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
}
