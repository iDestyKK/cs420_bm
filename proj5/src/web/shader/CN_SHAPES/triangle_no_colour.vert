precision mediump float;

attribute vec3 vec_pos;

uniform mat4 uMVMatrix;
uniform mat4 uPMatrix;
uniform vec3 transform;

void main() {
	gl_Position = uPMatrix * uMVMatrix * vec4((vec_pos + transform), 1.0);
}
