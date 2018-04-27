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

	var conf = {
		'iterations'  :  20.00,
		'size'        : 100.00,
		'particle_num': 250.00,
		'inertia'     :   0.99,
		'cognition'   :   0.10,
		'social'      :   0.10,
		'max_velocity':   0.10,
		'global_best' : {
			'x': 0,
			'y': 0
		},
		'mdist': 0.0,
		'particles': [],
		'func': function(x, y) {
			let pdist = Math.sqrt(
				Math.pow(x - 20, 2) +
				Math.pow(y -  7, 2)
			);

			return 100 * (1 - (pdist / conf.mdist));
		},
		'update': function() {
			let r1, r2, pobj;
			conf.mdist = Math.sqrt(2 * Math.pow(conf.size, 2)) / 2;

			for (let i = 0; i < conf.particle_num; i++) {
				r1 = Math.random();
				r2 = Math.random();

				pobj = conf.particles[i];

				pobj.velocity.x =
					conf.inertia * pobj.velocity.x + conf.cognition * r1 *
					(pobj.personal_best.x - pobj.obj.x) +
					conf.social * r2 *
					(conf.global_best.x - pobj.obj.x);

				pobj.velocity.y =
					conf.inertia * pobj.velocity.y + conf.cognition * r1 *
					(pobj.personal_best.y - pobj.obj.y) +
					conf.social * r2 *
					(conf.global_best.y - pobj.obj.y);

				//Normalise
				let TOTAL =
					Math.pow(pobj.velocity.x, 2) +
					Math.pow(pobj.velocity.y, 2);

				if (TOTAL > conf.max_velocity) {
					pobj.velocity.x *= (conf.max_velocity / Math.sqrt(TOTAL));
					pobj.velocity.y *= (conf.max_velocity / Math.sqrt(TOTAL));
				}

				//Update Position
				pobj.obj.set_position(
					pobj.obj.x + pobj.velocity.x,
					pobj.obj.y + pobj.velocity.y,
					pobj.obj.z
				);

				//Compute Q stuff
				let RES1, RES2, RES3;

				RES1 = conf.func(pobj.obj.x, pobj.obj.y);
				RES2 = conf.func(pobj.personal_best.x, pobj.personal_best.y);
				RES3 = conf.func(conf.global_best.x, conf.global_best.y);

				//Personal Best
				if (RES1 > RES2) {
					pobj.personal_best.x = pobj.obj.x;
					pobj.personal_best.y = pobj.obj.y;
				}

				//Global Best
				if (RES1 > RES3) {
					conf.global_best.x = pobj.obj.x;
					conf.global_best.y = pobj.obj.y;
				}
			}
		}
	};

	//Floor Object gets priority
	var floor_obj;

	var CN_TRIANGLE_SHADER_PROGRAM;
	var yy = 0;
	var angle = 0;

	//Class for particles
	class particle {
		constructor() {
			this.obj = undefined;
			this.velocity = {
				'x': 0,
				'y': 0
			};
			this.personal_best = {
				'x': 0,
				'y': 0
			};
		}
	}

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

		program_list["SHADER_FLOOR1"] = cn_gl_create_shader_program(
			cn_gl_get_shader("CN_FLOOR_FRAGMENT1"),
			cn_gl_get_shader("CN_FLOOR_VERTEX")
		);

		program_list["SHADER_FLOOR2"] = cn_gl_create_shader_program(
			cn_gl_get_shader("CN_FLOOR_FRAGMENT2"),
			cn_gl_get_shader("CN_FLOOR_VERTEX")
		);

		//Create a camera
		camera = new CN_CAMERA();
		camera.set_projection_ext(2, 2, 2, 0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);

		//Load a cube model
		model_list["MDL_CRYSTAL"] = new CN_MODEL("model/obj/crystal.obj");
		model_list["MDL_FLOOR"  ] = new CN_MODEL("model/obj/floor.obj");

		//Create the floor
		floor_obj = new CN_INSTANCE(
			0, 0, 0,
			model_list["MDL_FLOOR"],
			undefined,
			program_list["SHADER_FLOOR1"]
		);

		object_list.push(floor_obj);

		//Make the floor span the simulation
		floor_obj.set_scale(conf.size, conf.size, 0);

		//Create a cube instance
		for (let i = 0; i < conf.particle_num; i++) {
			object_list.push(new CN_INSTANCE(
				(Math.random() * conf.size) - (conf.size / 2), (Math.random() * conf.size) - (conf.size / 2), 0,
				model_list["MDL_CRYSTAL"],
				undefined,
				program_list["SHADER_GENERIC"]
			));

			//Make them spikey
			object_list[object_list.length - 1].set_scale(0.25, 0.25, 0.5);

			//Add them to the particles list too
			let p = new particle();
			p.obj = object_list[object_list.length - 1];
			conf.particles.push(p);
		}

		//Start the draw event.
		draw();
	}

	function draw() {
		resize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

		gl.clear(gl.CLEAR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

		camera.set_projection_ext(Math.cos(angle) * 15, -Math.sin(angle) * 15, 15, 0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);
		angle += 0.0025;

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

		conf.update();
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

	//Function to handle equation changes
	function set_equation() {
		let value = $("#equation")[0].value;

		//Change equation depending on the value of the dropdown.
		if (value == "Q1")
			floor_obj.program = program_list["SHADER_FLOOR1"];
		if (value == "Q2")
			floor_obj.program = program_list["SHADER_FLOOR2"];
	}
</script>

<html>
	<head>
		<title>CN_GL Demo: Particle Swarm Optimisation (COSC 420)</title>
		<?php
			//Call to CN_GL to include all needed JS files.
			cn_gl_inject_js();
		?>
	</head>
	<style type = "text/css">
		/* PAGE PROPERTIES */
		html, body {
			margin: 0px;
		}

		/* OPTIONS */
		.properties {
			background-color: rgba(0, 0, 0, 0.75);
			position        : fixed;
			right           : 16px;
			top             : 16px;
			max-height      : calc(100% - 32px);
			width           : 320px;
			height          : 720px;
			border          : 2px solid #444;
			color           : #FFF;
			box-sizing      : border-box;
			padding         : 8px;
		}

		.properties .top {
			width        : 100%;
			text-align   : center;
			font-size    : 150%;
			border-bottom: 2px solid #444;
			margin-bottom: 8px;
		}

		.properties span.name {
			font-weight: bold;
		}

		.properties input[type="button"] {
			width           : 100%;
			background-color: transparent;
			border          : 2px solid #FFF;
			color           : #FFF;
			font-size       : 100%;
		}

		.properties select {
			width           : 100%;
			background-color: transparent;
			color           : #FFF;
			font-size       : 100%;
		}

		.properties option {
			background-color: #000;
			color           : #FFF;
		}
	</style>
	<body onload = "cn_gl_init_gl('glCanvas', init)">
		<?php
			//Setup our 3D view
			cn_gl_create_canvas("glCanvas", "100vw", "100vh");

			//CN Generic Shaders for "draw_shapes"
			cn_gl_load_fragment_shader("CN_TRIANGLE_FRAGMENT", "shader/simple.frag");
			cn_gl_load_vertex_shader  ("CN_TRIANGLE_VERTEX"  , "shader/simple.vert");

			//For the floor
			cn_gl_load_fragment_shader("CN_FLOOR_FRAGMENT1", "shader/floor_Q1.frag");
			cn_gl_load_fragment_shader("CN_FLOOR_FRAGMENT2", "shader/floor_Q2.frag");
			cn_gl_load_vertex_shader  ("CN_FLOOR_VERTEX"   , "shader/floor.vert");
		?>

		<!-- Normal HTML Elements -->
		<div class = "properties">
			<div class = "top">
				Properties
			</div>

			
			<input type = "button"
				   value = "Reset"
				   onclick = "javascript:reset_sim();"
			>
			</br>
			</br>

			<table width = "100%" style = "color: inherit;">
				<tr>
					<td>
						<span class = "name">
							Equation:
						</span>
					</td>
					<!--<td>
						<input type = "button"
							   value = "Q1"
							   onclick = "javascript:floor_obj.program = program_list['SHADER_FLOOR1'];"
						>
					</td>
					<td>
						<input type = "button"
							   value = "Q2"
							   onclick = "javascript:floor_obj.program = program_list['SHADER_FLOOR2'];"
						>
					</td>-->
					<td>
						<select id = "equation" onchange = "set_equation();">
							<option value = "Q1">Q1</option>
							<option value = "Q2">Q2</option>
						</select>
					</td>
		</div>
	</body>
</html>
