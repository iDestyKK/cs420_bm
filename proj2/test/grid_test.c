//C Includes
#include <stdio.h>
#include <stdlib.h>

//CNDS (Clara Nguyen's Data Structures)
#include "lib/handy/cnds/cn_grid.h"

typedef struct LOL_YES {
	int    a;
	char   b;
	double c;
} lol_yes;

main() {
	CN_GRID g = cn_grid_init_size(lol_yes, 2, 2);
	lol_yes* ptr;

	ptr = cn_grid_at(g, 0, 0);
	ptr->a = 1;
	ptr->b = 'y';
	ptr->c = 3.14;

	ptr = cn_grid_at(g, 1, 0);
	ptr->a = 2;
	ptr->b = 'z';
	ptr->c = 7.123;

	ptr = cn_grid_at(g, 1, 0);
	printf("%d %c %lg\n", ptr->a, ptr->b, ptr->c);
}
