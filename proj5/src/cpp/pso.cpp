#include "pso.hpp"

namespace skills {
	double random_double(double r1, double r2) {
		double v = static_cast<double>(rand()) / numeric_limits<int>::max();

		//Linear Interpolation
		return r1 + (r2 - r1) * v;
	}

	double fsqr(double r) {
		return r * r;
	}
}

//Structs/Classes
vec2::vec2() {
	x = y = 0.0;
}

vec2::vec2(double _x, double _y) {
	x = _x;
	y = _y;
}

particle::particle() {
	pos = velocity = personal_best = vec2(0, 0);
}

simulation::simulation() {
	iterations = size = particle_num = 0;
	max_velocity = inertia = cognition = social = 0.0;
	p1 = p2 = global_best = vec2();
}

void simulation::prepare() {
	//Set up the bounds.
	p1 = vec2(-size / 2, -size / 2);
	p2 = vec2( size / 2,  size / 2);

	obj.clear();
	obj.resize(particle_num);

	//Distribute the particles into random locations
	for (int i = 0; i < obj.size(); i++) {
		particle& _REF = obj[i];
		_REF.pos.x = skills::random_double(-size / 2, size / 2);
		_REF.pos.y = skills::random_double(-size / 2, size / 2);
		//printf("%d - %lg %lg\n", i, _REF.pos.x, _REF.pos.y);
	}
}

void simulation::update() {
	//Update each particle
	for (int i = 0; i < obj.size(); i++) {
		particle& _REF = obj[i];
		double r1 = skills::random_double(0.0, 1.0),
		       r2 = skills::random_double(0.0, 1.0),
			   sqrchk[3];

		//Compute Velocity
		_REF.velocity.x =
			inertia * _REF.velocity.x + cognition * r1 *
			(_REF.personal_best.x - _REF.pos.x) +
			social * r2 *
			(global_best.x - _REF.pos.x);

		_REF.velocity.y =
			inertia * _REF.velocity.y + cognition * r1 *
			(_REF.personal_best.y - _REF.pos.y) +
			social * r2 *
			(global_best.y - _REF.pos.y);

		//Normalise to conform to maximum velocity
		sqrchk[0] = skills::fsqr(_REF.velocity.x);
		sqrchk[1] = skills::fsqr(_REF.velocity.y);
		sqrchk[2] = skills::fsqr(max_velocity);
		if (sqrchk[0] + sqrchk[1] > sqrchk[2]) {
			_REF.velocity.x *= (max_velocity / sqrt(sqrchk[0] + sqrchk[1]));
			_REF.velocity.y *= (max_velocity / sqrt(sqrchk[0] + sqrchk[1]));
		}

		printf("%d - %lg %lg\n", i, _REF.velocity.x, _REF.velocity.y);

		//Update position
		_REF.pos.x += _REF.velocity.x;
		_REF.pos.y += _REF.velocity.y;
	}
}
