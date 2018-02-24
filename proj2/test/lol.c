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

 //import <grid>
// ---
// Importing from:
// /home/ssmit285/giua_cong_chung/bin/lib/grid.cns
// ---
//Import the C library version.
 #include "/home/ssmit285/giua_cong_chung/bin/lib/./c/cn_grid.h"
 #include "/home/ssmit285/giua_cong_chung/bin/lib/./c/cn_grid.c"

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

	grid_clear(grid* this) {
		cn_grid_clear(this->data);
	}

	grid_swap(grid* this, cng_uint x1, cng_uint y1, cng_uint x2, cng_uint y2) {
		cn_grid_swap(this->data, x1, y1, x2, y2);
	}

	grid_free(grid* this) {
		cn_grid_free(this->data);
	}

// ---
// End import from:
// /home/ssmit285/giua_cong_chung/bin/lib/grid.cns
// ---


main() {
	grid a;
	grid_init(&a, sizeof(int));

	grid_resize(&a, 2, 2);

	int* val = grid_at(&a, 0, 0);
	*val = 2;

	
		
		
	printf("Val = %d\n", *val);

	int x, y;
	for (y = 0; y < grid_size_y(&a); y++) {
		for (x = 0; x < grid_size_x(&a); x++) {
			val = grid_at(&a, x, y);
			printf("%d %d: %d\n", x, y, *val);
		}
	}
}
