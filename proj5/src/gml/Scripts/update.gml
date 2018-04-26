/*
 * void update();
 * 
 * Arguments:
 *     n/a
 *
 * Description:
 *     Called by obj_simulator to update all particles in the simulation by
 *     a single step.
 */

var SIM, TOTAL, RES1, RES2, RES3, i, r1, r2, SCR;
SIM = obj_simulator;

SIM.error_x = 0;
SIM.error_y = 0;

for (i = 0; i < SIM.particles; i += 1) {
    //Give me 2 random numbers.
    r1 = random(1);
    r2 = random(1);
    
    //Compute X Velocity
    SIM.particle[i].velocity_x =
        SIM.inertia * SIM.particle[i].velocity_x + SIM.cognition * r1 *
        (SIM.particle[i].personal_best_x - SIM.particle[i].x) +
        SIM.social * r2 *
        (SIM.global_best_x - SIM.particle[i].x);
        
    //Compute Y Velocity
    SIM.particle[i].velocity_y =
        SIM.inertia * SIM.particle[i].velocity_y + SIM.cognition * r1 *
        (SIM.particle[i].personal_best_y - SIM.particle[i].y) +
        SIM.social * r2 *
        (SIM.global_best_y - SIM.particle[i].y);
        
    //Normalise
    TOTAL = sqr(SIM.particle[i].velocity_x) + sqr(SIM.particle[i].velocity_y);
    if (TOTAL > SIM.max_velocity) {
        SIM.particle[i].velocity_x *= (SIM.max_velocity / sqrt(TOTAL));
        SIM.particle[i].velocity_y *= (SIM.max_velocity / sqrt(TOTAL));
    }
    
    //Update Position
    SIM.particle[i].x += SIM.particle[i].velocity_x;
    SIM.particle[i].y += SIM.particle[i].velocity_y;
    
    //Compute with Q
    //Function Pointer
    SCR = Q1;
    
    //Get the values
    RES1 = script_execute(SCR, 
        SIM.particle[i].x, SIM.particle[i].y);
    RES2 = script_execute(SCR,
        SIM.particle[i].personal_best_x, SIM.particle[i].personal_best_y);
    RES3 = script_execute(SCR,
        SIM.global_best_x, SIM.global_best_y);
    
    //Personal Best
    if (RES1 > RES2) {
        SIM.particle[i].personal_best_x = SIM.particle[i].x;
        SIM.particle[i].personal_best_y = SIM.particle[i].y;
    }
    
    //Global Best
    if (RES1 > RES3) {
        SIM.global_best_x = SIM.particle[i].x;
        SIM.global_best_y = SIM.particle[i].y;
    }
    
    //Update the error
    SIM.error_x += sqr(SIM.particle[i].x - SIM.global_best_x);
    SIM.error_y += sqr(SIM.particle[i].y - SIM.global_best_y);
}

//Normalise
SIM.error_x = sqrt((1 / (2 * SIM.particles)) * SIM.error_x);
SIM.error_y = sqrt((1 / (2 * SIM.particles)) * SIM.error_y);
