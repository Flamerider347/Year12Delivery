shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0);
uniform bool reverse = true;

void fragment() {
	if(UV.x + UV.y > progress * 4.0){
		if(!reverse){
			discard;
		}
	}
	else if(reverse){
		discard;
	}
}
