// Animating thousands of fish with MultiMeshInstance3D on Godot 4.4 Documents Tutorial
// Controlling thousands of fish with Particles on Godot 4.4 Documents Tutuorial
shader_type spatial;
uniform float time_scale;
uniform float side_to_side;
uniform float pivot;
uniform float wave;
uniform float twist;
uniform float mask_black;
uniform float mask_white;

void vertex(){
	float time = TIME * time_scale;
	VERTEX.x += cos(time) * side_to_side; // Makes the fish move left and right on the X axis
	//angle is scaled by 0.1 so that the fish only pivots and doesn't rotate all the way around
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	//then apply it to the xz axis to have the effect
	VERTEX.xz = rotation_matrix * VERTEX.xz;
	// Creates an effect which looks like the fish is moving across a wave
	float body = (VERTEX.z + 1.0) / 2.0; //for a fish centered at (0, 0) with a length of 2
	VERTEX.x += cos(time + body) * wave;
	// makes a pivot across the fishes spine, simulating it roll
	float twist_angle = cos(time + body) * 0.3 * twist;
	mat2 twist_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	VERTEX.xy = twist_matrix * VERTEX.xy;
	// Applying a limit on how much the fish can move at it's head
	// Wave motion with mask
	float mask = smoothstep(mask_black, mask_white, 1.0 - body);
	VERTEX.x += cos(time + body) * mask * wave;
	// Twist motion with mask
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, mask);
}


//void process(){
	//VELOCITY.x = cos(TIME*time_scale);
	//
//}
////time_scale is a uniform float

//// Generation for a random number for the particles speeds.
//float rand_from_seed(in uint seed) {
  //int k;
  //int s = int(seed);
  //if (s == 0)
    //s = 305420679;
  //k = s / 127773;
  //s = 16807 * (s - k * 127773) - 2836 * k;
  //if (s < 0)
    //s += 2147483647;
  //seed = uint(s);
  //return float(seed % uint(65536)) / 65535.0;
//}
//
//uint hash(uint x) {
  //x = ((x >> uint(16)) ^ x) * uint(73244475);
  //x = ((x >> uint(16)) ^ x) * uint(73244475);
  //x = (x >> uint(16)) ^ x;
  //return x;
//}
//
//void start() {
//
////time_scale is a uniform float
////float time = TIME * time_scale;
//
////side_to_side is a uniform float
//VERTEX.x += cos(time) * side_to_side;
//
//// Generates a random number
	//uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
//uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
//uint alt_seed3 = hash(NUMBER + uint(43) + RANDOM_SEED);
//uint alt_seed4 = hash(NUMBER + uint(111) + RANDOM_SEED);
//
//// Generates 3 numbers for the position of the fish particles, and 1 for the offset of the swim cycle
//CUSTOM.x = rand_from_seed(alt_seed1);
//vec3 position = vec3(rand_from_seed(alt_seed2) * 2.0 - 1.0,
                     //rand_from_seed(alt_seed3) * 2.0 - 1.0,
                     //rand_from_seed(alt_seed4) * 2.0 - 1.0);
//
//// Holds the postion information
//TRANSFORM[3].xyz = position * 20.0;
//
//// Gives the fish a random velocity of 2 and 10
//VELOCITY.z = cos(TIME + CUSTOM.x * 6.28) * 4.0 + 6.0;
//}
//
//void process() {
	//// Called every frame on existing particles (according to the Fixed FPS property).
	//// Lets the fish particles change their velocity over time.
//CUSTOM.y = VELOCITY.z * 0.1;
//}
