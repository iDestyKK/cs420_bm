precision mediump float;

varying vec3 frag_colour;
varying vec3 vec_posv;

float Q1() {
	//Equation 1
	float pdist = sqrt(pow(vec_posv.x - 20.0, 2.0) + pow(vec_posv.y - 7.0, 2.0));
	float mdist = sqrt(2.0 * pow(100.0, 2.0)) / 2.0;
	return 100.0 * (1.0 - (pdist / mdist));
}

void main() {
	float val = Q1();
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
