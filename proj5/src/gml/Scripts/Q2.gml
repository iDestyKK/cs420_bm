/*
 * double Q2(double x, double y);
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
 *     9 * max(0, 10 - sqrt((x - 20)^2 + (y - 7)^2)^2) +
 *     10 * (1 - ((sqrt((x - 20)^2 + (y - 7)^2)/((sqrt(2 * (100^2)) / 2))))) +
 *     70 * ((sqrt((x + 20)^2 + (y + 7)^2)) / (sqrt(2 * (100^2)) / 2))
 */

var pdist, mdist, ndist;

pdist = sqrt(
    sqr(argument0 - obj_simulator.p_x) +
    sqr(argument1 - obj_simulator.p_y)
);
ndist = sqrt(
    sqr(argument0 + obj_simulator.p_x) +
    sqr(argument1 + obj_simulator.p_y)
);
mdist = obj_simulator.mdist;

return 
    9 * max(0, 10 - sqr(pdist)) + 
    10 * (1 - (pdist / mdist)) +
    70 * (1 - (ndist / mdist));
