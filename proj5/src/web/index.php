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
	var keymap       = {};

	var player = {
		'x'      : 0,
		'y'      : 0,
		'z'      : 0,
		'xydir'  : 0,
		'zdir'   : 0,
		'spawned': false,
		'first'  : true
	};

	var conf = {
		'iterations'      :  20.00, /* Max number of iterations (unused)  */
		'iteration'       :   0.00, /* Iteration Count                    */
		'size'            : 100.00, /* Size of grid on one dimension      */
		'particle_num'    :  50.00, /* Number of Particles                */
		'particle_num_old':  50.00, /* Previous Number of Particles       */
		'inertia'         :   0.99, /* Self-explanatory                   */
		'cognition'       :   0.10, /* Ditto...                           */
		'social'          :   0.10, /* Ditto...                           */
		'max_velocity'    :   0.20, /* Maximum Velocity a particle can go */
		'export_data'     : [],     /* Object to hold export data         */
		'global_best'     : {
			'x': 0,
			'y': 0
		},
		'error'           : {
			'x': 0,
			'y': 0
		},
		'mdist': 0.0,
		'particles': [],
		'Q1': function(x, y) {
			let pdist = Math.sqrt(
				Math.pow(x - 20, 2) +
				Math.pow(y -  7, 2)
			);

			return 100 * (1 - (pdist / conf.mdist));
		},
		'Q2': function(x, y) {
			let pdist = Math.sqrt(
				Math.pow(x - 20, 2) +
				Math.pow(y -  7, 2)
			);
			let ndist = Math.sqrt(
				Math.pow(x + 20, 2) +
				Math.pow(y +  7, 2)
			);

			return (9.0 * Math.max(0, 10.0 - Math.pow(pdist, 2))) +
				(10.0 * (1.0 - (pdist / conf.mdist))) +
				(70.0 * (1.0 - (ndist / conf.mdist)));
		},
		'Q3': function(x, y) {
			return Math.cos(Math.sqrt(Math.abs(Math.pow(x, 2) + Math.pow(y, 2) + Math.sin(10.0 - x)))) * Math.sqrt(Math.abs(Math.pow(x, 2) + Math.pow(y, 2)));
		},
		'func': function(x, y) { return 0; },
		'update': function() {
			let r1, r2, pobj;
			conf.mdist = Math.sqrt(2 * Math.pow(conf.size, 2)) / 2;

			conf.error.x = 0;
			conf.error.y = 0;

			for (let i = 0; i < conf.particle_num_old; i++) {
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

				if (TOTAL > Math.pow(conf.max_velocity, 2)) {
					pobj.velocity.x *= (conf.max_velocity / Math.sqrt(TOTAL));
					pobj.velocity.y *= (conf.max_velocity / Math.sqrt(TOTAL));
				}

				//Update Position
				pobj.obj.set_position(
					pobj.obj.x + pobj.velocity.x,
					pobj.obj.y + pobj.velocity.y,
					pobj.obj.z
				);

				if (pobj.html_unloaded == true) {
					pobj.html_elem = document.getElementById(pobj.html_elem);
					pobj.html_unloaded = false;
				}
				var lpos = 150 + (pobj.obj.x * (150 / (conf.size / 2)));
				var tpos = 150 - (pobj.obj.y * (150 / (conf.size / 2)));
				pobj.html_elem.style.left = "" + lpos;
				pobj.html_elem.style.top = "" + tpos;

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

				//Update the error
				conf.error.x += Math.pow(pobj.obj.x - conf.global_best.x, 2);
				conf.error.y += Math.pow(pobj.obj.y - conf.global_best.y, 2);
			}

			//Normalise
			conf.error.x *= Math.sqrt(1 / (2 * conf.particle_num));
			conf.error.y *= Math.sqrt(1 / (2 * conf.particle_num));

			//Push data into new object for CSV Export
			if (conf.iteration < conf.iterations) {
				conf.export_data.push({
					'iteration': conf.iteration + 1,
					'error_x'  : conf.error.x,
					'error_y'  : conf.error.y,
					'gbest_x'  : conf.global_best.x,
					'gbest_y'  : conf.global_best.y
				});

				//Update the simulation string
				document.getElementById("status_str").innerHTML =
					"Simulation Status: " + (conf.iteration + 1) + "/" + conf.iterations;
			}

			conf.iteration++;
		}
	};

	conf.func = conf.Q1;

	//Floor Object gets priority
	var floor_obj;

	var CN_TRIANGLE_SHADER_PROGRAM;
	var yy = 0;
	var angle = 0;

	//Class for particles
	class particle {
		constructor() {
			this.obj       = undefined;
			this.html_elem = undefined;
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

	function reset_sim() {
		let GRID = document.getElementsByClassName("grid")[0];
		GRID.innerHTML = "";

		conf.size         = document.getElementById("grid_size"     ).value;
		conf.particle_num = document.getElementById("particles"     ).value;
		conf.inertia      = document.getElementById("inertia"       ).value;
		conf.cognition    = document.getElementById("cognition"     ).value;
		conf.social       = document.getElementById("social"        ).value;
		conf.max_velocity = document.getElementById("max_velocity"  ).value;
		conf.iterations   = document.getElementById("max_iterations").value;
		conf.iteration    = 0;

		conf.global_best.x = 0;
		conf.global_best.y = 0;

		object_list           = [];
		conf.particles        = [];
		conf.export_data      = [];
		conf.particle_num_old = conf.particle_num;

		//Create the floor
		floor_obj = new CN_INSTANCE(
			0, 0, 0,
			model_list["MDL_FLOOR"],
			undefined,
			program_list["SHADER_FLOOR1"]
		);

		object_list.push(floor_obj);

		set_equation();

		//Make the floor span the simulation
		floor_obj.set_scale(conf.size / 2, conf.size / 2, 0);

		let htmlstr = "<div class = \"h-axis\"></div><div class = \"v-axis\"></div>";

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
			htmlstr += "<div class = \"particle\" id = \"particle" + i + "\"></div>";

			p.html_elem = "particle" + i;
			p.html_unloaded = true;
		}

		GRID.innerHTML = htmlstr;
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

		program_list["SHADER_FLOOR3"] = cn_gl_create_shader_program(
			cn_gl_get_shader("CN_FLOOR_FRAGMENT3"),
			cn_gl_get_shader("CN_FLOOR_VERTEX")
		);

		//Create a camera
		camera = new CN_CAMERA();
		camera.set_projection_ext(2, 2, 2, 0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);

		//Load a cube model
		model_list["MDL_CRYSTAL"] = new CN_MODEL("model/obj/crystal.obj");
		model_list["MDL_FLOOR"  ] = new CN_MODEL("model/obj/floor.obj");

		reset_sim();

		//Start the draw event.
		draw();
	}

	function draw() {
		resize(gl.canvas);
		gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

		gl.clear(gl.CLEAR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

		//Act upon key presses
		if (keymap[87] != undefined && keymap[87] == true) {
			player.x += Math.cos(player.xydir) * Math.cos(player.zdir) / 4;
			player.y -= Math.sin(player.xydir) * Math.cos(player.zdir) / 4;
			player.z += Math.sin(player.zdir ) / 4;
		}
		if (keymap[83] != undefined && keymap[83] == true) {
			player.x -= Math.cos(player.xydir) * Math.cos(player.zdir) / 4;
			player.y += Math.sin(player.xydir) * Math.cos(player.zdir) / 4;
			player.z -= Math.sin(player.zdir ) / 4;
		}
		if (keymap[65] != undefined && keymap[65] == true) {
			player.x += Math.cos(player.xydir - Math.PI * 0.5) / 4;
			player.y -= Math.sin(player.xydir - Math.PI * 0.5) / 4;
		}
		if (keymap[68] != undefined && keymap[68] == true) {
			player.x += Math.cos(player.xydir + Math.PI * 0.5) / 4;
			player.y -= Math.sin(player.xydir + Math.PI * 0.5) / 4;
		}
		if (keymap[27] != undefined && keymap[27] == true) {
			despawn();
			//show_menu();
		}

		if (player.first) {
			player.x = Math.cos(angle) * 15;
			player.y = -Math.sin(angle) * 15;
			player.z = 15;
			//0, 0, 0, 0, 0, 1, 75, gl.canvas.clientWidth / gl.canvas.clientHeight, 0.1, 4096.0);

			player.xydir = angle + 3.14159265;
			player.zdir  = -0.785398163;
		}

		camera.set_projection_ext(
			player.x,
			player.y,
			player.z,
			player.x + (Math.cos(player.xydir) * Math.cos(player.zdir)),
			player.y - (Math.sin(player.xydir) * Math.cos(player.zdir)),
			player.z + Math.sin(player.zdir),
			0, 0, 1,
			75,
			gl.canvas.clientWidth / gl.canvas.clientHeight,
			0.1,
			4096.0
		);
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
		if (value == "Q1") {
			floor_obj.program = program_list["SHADER_FLOOR1"];
			conf.func = conf.Q1;
		}
		if (value == "Q2") {
			floor_obj.program = program_list["SHADER_FLOOR2"];
			conf.func = conf.Q2;
		}
		if (value == "Q3") {
			floor_obj.program = program_list["SHADER_FLOOR3"];
			conf.func = conf.Q3;
		}
	}

	function mouse_rotate(e) {
		player.xydir += e.movementX / 150;
		player.zdir -= e.movementY  / 150;
		if (player.zdir >= Math.PI / 2)
			player.zdir = Math.PI / 2 - 0.01;
		if (player.zdir <= -Math.PI / 2)
			player.zdir = -Math.PI / 2 + 0.01;
	}

	function key_pressed(e, bool) {
		console.log(e);
		keymap[e.keyCode] = bool;
	}

	//Handling spawning and despawning
	function spawn() {
		player.spawned = true;

		//Lock the pointer
		var element = document.body;
		element.requestPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock;
		element.requestPointerLock();
		document.addEventListener("mousemove", mouse_rotate, false);

		//Add events to ensure that it works right
		document.addEventListener('pointerlockchange', check_spawn, false);
		document.addEventListener('mozpointerlockchange', check_spawn, false);
		document.addEventListener('webkitpointerlockchange', check_spawn, false);

		player.first = false;
	}

	function despawn() {
		player.spawned = false;

		//Unlock the pointer
		var element = document.body;
		//element.exitPointerLock = element.requestPointerLock || element.mozRequestPointerLock || element.webkitRequestPointerLock;
		//element.exitPointerLock();
		document.removeEventListener("mousemove", mouse_rotate, false);
	}

	function check_spawn(requestedElement) {
		console.log("Triggered");
		console.log(requestedElement);
		console.log(document.pointerLockElement);
		console.log(document.mozPointerLockElement);
		console.log(document.webkitPointerLockElement);
		if ((document.pointerLockElement === null || document.pointerLockElement === undefined) &&
			(document.mozPointerLockElement === null || document.mozPointerLockElement === undefined) && 
			(document.webkitPointerLockElement === null || document.webkidPointerLockElement === undefined)) {
			despawn();
			//show_menu();
		}
	}

	despawn();
	document.addEventListener("keydown", function(event) {
		key_pressed(event, true);
	});
	document.addEventListener("keyup", function(event) {
		key_pressed(event, false);
	});


	//Function to export data of the simulation to a file
	function export_csv() {
		//Generate string of data
		let data = "";

		//Top Row
		data = "\"Epoch\",\"Error X\",\"Error Y\",\"Global Best X\",\"Global Best Y\"\n";

		//Generate the other rows
		for (let i = 0; i < conf.export_data.length; i++) {
			data += conf.export_data[i].iteration + "," +
				conf.export_data[i].error_x + "," +
				conf.export_data[i].error_y + "," +
				conf.export_data[i].gbest_x + "," +
				conf.export_data[i].gbest_y + "\n";
		}

		//Force a download of the CSV
		var a = document.createElement("a");
		a.setAttribute("style", "display: none;");
		document.body.appendChild(a);
		var blob = new Blob([data], { type: 'text/csv' });
		var url  = window.URL.createObjectURL(blob);
		a.href = url;
		a.download = "run.csv";
		a.click();
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
			right           : 0px;
			top             : 0px;
			width           : 320px;
			height          : 100%;
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
			font-weight     : bold;
			padding         : 8px;
		}

		.properties input[type="button"]:hover {
			background-color: #FFF;
			color           : #000;
		}

		.properties select {
			width           : 100%;
			background-color: transparent;
			color           : #FFF;
			font-size       : 100%;
			border          : 0px solid transparent;
			border-bottom   : 2px solid white;
		}

		.properties option {
			background-color: #000;
			color           : #FFF;
		}

		.properties input[type="value"] {
			width           : 100%;
			border          : 0px solid transparent;
			border-bottom   : 2px solid #FFF;
			background-color: transparent;
			color           : white;
			font-family     : inherit;
			font-size       : 100%;
		}

		.properties table td {
			white-space: nowrap;
		}

		.bottom {
			position: absolute;
			bottom  : 8px;
			left    : 8px;
			right   : 8px;
		}

		.bottom .grid {
			width : 300px;
			height: 300px;
			background-color: white;
			position: relative;
		}

		.bottom .grid .particle {
			width: 2px;
			height: 2px;
			background-color: black;
			border-radius: 2px;
			position: absolute;
			left: 0px;
			top: 0px;
		}

		.bottom .grid .h-axis {
			background-color: black;
			position        : absolute;
			left: 0px;
			right: 0px;
			top: 50%;
			height: 1px;
		}

		.bottom .grid .v-axis {
			background-color: black;
			position        : absolute;
			top   : 0px;
			bottom: 0px;
			left  : 50%;
			width : 1px;
		}

		.properties .scrollmenu {
			position: relative;
			height  : calc(100% - 598px);
			overflow-y: auto;
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
			cn_gl_load_fragment_shader("CN_FLOOR_FRAGMENT3", "shader/floor_Q3.frag");
			cn_gl_load_vertex_shader  ("CN_FLOOR_VERTEX"   , "shader/floor.vert");
		?>

		<!-- Normal HTML Elements -->
		<div class = "properties">
			<div class = "top">
				Properties
			</div>

			<!-- Button for Camera Mode -->
			<input type = "button"
				   value = "Camera Mode"
				   onclick = "javascript:spawn();"
			>

			</br>
			</br>

			<div class = "scrollmenu">
				<table width = "100%" style = "color: inherit;">
					<!-- Equation -->
					<tr>
						<td>
							<span class = "name">
								Equation:
							</span>
						</td>
						<td width = "100%">
							<select id = "equation">
								<option value = "Q1">Q1</option>
								<option value = "Q2">Q2</option>
								<option value = "Q3">Q3</option>
							</select>
						</td>
					</tr>

					<!-- Grid Size -->
					<tr>
						<td>
							<span class = "name">
								Grid Size:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "grid_size" value = "100">
						</td>
					</tr>

					<!-- Particles -->
					<tr>
						<td>
							<span class = "name">
								Particles:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "particles" value = "50">
						</td>
					</tr>

					<!-- Inertia -->
					<tr>
						<td>
							<span class = "name">
								Inertia:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "inertia" value = "0.99">
						</td>
					</tr>

					<!-- Cognition -->
					<tr>
						<td>
							<span class = "name">
								Cognition:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "cognition" value = "0.10">
						</td>
					</tr>

					<!-- Social -->
					<tr>
						<td>
							<span class = "name">
								Social:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "social" value = "0.10">
						</td>
					</tr>

					<!-- Max Velocity -->
					<tr>
						<td>
							<span class = "name">
								Max Velocity:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "max_velocity" value = "0.10">
						</td>
					</tr>

					<!-- Max Iterations -->
					<tr>
						<td>
							<span class = "name">
								Max Iterations:
							</span>
						</td>
						<td width = "100%">
							<input type = "value" id = "max_iterations" value = "100">
						</td>
					</tr>
				</table>
			</div>
			</br>

			<!-- Simulation Status -->
			<p id = "status_str">Simulation Status: </p>

			<!-- Button to run simulation with the current config set -->
			<input type = "button"
				   value = "Run Simulation!"
				   onclick = "javascript:reset_sim();"
			>

			<!-- Button to export simulation data as CSV -->
			<input type = "button"
				   value = "Export CSV"
				   onclick = "javascript:export_csv();"
			>

			<div class = "bottom">
				<b>Simulation Grid:</b>

				<div class = "grid">
					<div class = "h-axis"></div>
					<div class = "v-axis"></div>
				</div>
			</div>
		</div>
	</body>
</html>
