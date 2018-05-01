/*
 * double Q1(double x, double y);
 * 
 * Arguments:
 *     x - Particle Coordinate on X-Axis
 *     y - Particle Coordinate on Y-Axis
 *
 * Description:
 *     An equation... Plug it into wolfram if you really wanted to see what it
 *     does.
 *
 * Equation Summary:
 *     100 * (1 - ((sqrt((x - 20)^2 + (y - 7)^2)/((sqrt(2 * (100^2)) / 2)))))
 */

var pdist, mdist;

pdist = sqrt(
    sqr(argument0 - obj_simulator.p_x) +
    sqr(argument1 - obj_simulator.p_y)
);
mdist = obj_simulator.mdist;

return 100 * (1 - (pdist / mdist));
