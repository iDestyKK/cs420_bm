<!--
 * CN_GL Demo - Particle Swarm Optimisation
 *
 * Description:
 *     This does stuff... I think I'll fill this out later.
 *
 *     This engine was only written to aid me in CS456's final project. Since
 *     I wrote everything in it, only I am entitled to use it for educational
 *     purposes.
 * 
 * Author:
 *     Clara Nguyen
 *
-->

<?php
//Initialise CN_GL Engine
require_once("CN_GL/cn_gl.php");

//Initialise CN_GL
cn_gl_init();
?>

<script type = "text/javascript">
	var gl, camera, cube_model, cube_object, shaderProgram, fS, vS, tri1, tri2, angle;
	var object_list  = [];
	var model_list   = {};
	var texture_list = {};
	var program_list = {};

	var CN_TRIANGLE_SHADER_PROGRAM;
	var yy = 0;
	var angle = 0;

	function init() {
		console.log(gl);
		//Basic WebGL Properties
		gl.clearColor(0.0, 0.0, 0.0, 1);
		gl.clearDepth(1.0);
		gl.enable(gl.DEPTH_TEST);
		gl.depthFunc(gl.LEQUAL);

		//Create shader programs
		program_list["SHADER_GENERIC"] = cn_gl_create_shader_program(
			cn_gl_get_shader("CN_TRIANGLE_FRAGMENT"),
			cn_gl_get_shader("CN_TRIANGLE_VERTEX")
		);

		//Create a camera
		camera = new CN_CAMERA();
		camera.set_projection_ext(2, 2, 2, 0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);

		//Load a cube model
		model_list["MDL_CRYSTAL"] = new CN_MODEL("model/obj/crystal.obj");

		//Create a cube instance
		for (let i = 0; i < 50; i++) {
			object_list.push(new CN_INSTANCE(
				Math.random() * 10 - 5, Math.random() * 10 - 5, 0,
				model_list["MDL_CRYSTAL"],
				undefined,
				program_list["SHADER_GENERIC"]
			));

			//Make them spikey
			object_list[object_list.length - 1].set_scale(0.1, 0.1, 0.25);
		}

		//Start the draw event.
		draw();
	}

	function draw() {
		resize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

		gl.clear(gl.CLEAR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

		camera.set_projection_ext(Math.cos(angle) * 2, -Math.sin(angle) * 2, 2, 0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);
		angle += 0.01;

		//Draw every particle
		var prev_program = null;
		for (var i = 0; i < object_list.length; i++) {
			if (prev_program != object_list[i].program) {
				gl.useProgram(object_list[i].program);
				camera.push_matrix_to_shader(
					object_list[i].program,
					"uPMatrix",
					"uMVMatrix"
				);
			}
			object_list[i].draw();
		}

		yy += 0.1;
		if (yy > 1)
			yy = 0;

		window.requestAnimationFrame(draw);
	}

	//Resize function to make sure that the canvas is the same size as the page.
	function resize(canvasID) {
		var retina = window.devicePixelRatio;
		if (retina / 2 > 1) {
			//Some devices may not be able to take drawing high resolution
			//Half the retina if it can be halved, but it can't go under 1x.
			retina /= 2;
		}
		canvasID.width  = canvasID.clientWidth  * retina;
		canvasID.height = canvasID.clientHeight * retina;
	}
</script>

<html>
	<head>
		<title>CN_GL Demo: CS456 Final Project</title>
		<?php
			//Call to CN_GL to include all needed JS files.
			cn_gl_inject_js();
		?>
	</head>
	<style type = "text/css">
		html, body {
			margin: 0px;
		}
	</style>
	<body onload = "cn_gl_init_gl('glCanvas', init)">
		<?php
			//Setup our 3D view
			cn_gl_create_canvas("glCanvas", "100vw", "100vh");

			//CN Generic Shaders for "draw_shapes"
			cn_gl_load_fragment_shader("CN_TRIANGLE_FRAGMENT", "shader/simple.frag");
			cn_gl_load_vertex_shader  ("CN_TRIANGLE_VERTEX", "shader/simple.vert");
		?>
	</body>
</html>
