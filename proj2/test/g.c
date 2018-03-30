 //import <io>
// ---
// Importing from:
// /home/ssmit285/giua_cong_chung/bin/lib/io.cns
// ---
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
// ---
// End import from:
// /home/ssmit285/giua_cong_chung/bin/lib/io.cns
// ---

 //import "grid.cns"
// ---
// Importing from:
// grid.cns
// ---
//Import the C library version.
 #include "../lib/handy/cnds/cn_grid.h"
 #include "../lib/handy/cnds/cn_grid.c"

typedef struct {
	//Variables
	CN_GRID data;
	
	//Functions
	} grid;grid_init(grid* this, cng_uint size) {
		this->data = cn_grid_init(size);
	}

	grid_init_size(grid* this, cng_uint size, cng_uint width, cng_uint height) {
		this->data = cn_grid_init_size(size, width, height);
	}

	grid_resize_x(grid* this, cng_uint w) {
		cn_grid_resize_x(this->data, w);
	}

	grid_resize_y(grid* this, cng_uint h) {
		cn_grid_resize_y(this->data, h);
	}

	grid_resize(grid* this, cng_uint w, cng_uint h) {
		cn_grid_resize(this->data, w, h);
	}

	cng_uint grid_size_x(grid* this) {
		return cn_grid_size_x(this->data);
	}

	cng_uint grid_size_y(grid* this) {
		return cn_grid_size_y(this->data);
	}

	cng_uint grid_size(grid* this) {
		return cn_grid_size(this->data);
	}

	void* grid_at(grid* this, cng_uint a, cng_uint b) {
		return cn_grid_at(this->data, a, b);
	}

// ---
// End import from:
// grid.cns
// ---


main() {
	CN_GRID a;
	CN_GRID_init(&a, sizeof(int));
}
