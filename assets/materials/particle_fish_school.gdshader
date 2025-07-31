// Animating thousands of fish with MultiMeshInstance3D on Godot 4.4 Documents Tutorial
// Controlling thousands of fish with Particles on Godot 4.4 Documents Tutuorial
shader_type spatial;
uniform float time_scale;
uniform float side_to_side;

void vertex(){
	float time = TIME * time_scale;
	VERTEX.x += cos(time) * side_to_side;
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
