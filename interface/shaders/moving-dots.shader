shader_type canvas_item;
uniform float variant = 1.1;
uniform float distortion=1;
uniform float seed=0.01;
uniform vec3 stretch=vec3(3.0,3.0,3.0);
uniform float pattern=5.0;
uniform float blur =2;
float random (in float x) { return fract(cos(x) * distortion); }
float random2(in vec2 xy, in float seedparam) {
    return fract(tan(distance(xy*variant, xy)*seedparam)*xy.x);
}
vec3 _cell_noise_hash(in vec3 p, in vec3 limit, in float seedparam) {
    p = mod(p, limit);
    float x = random2(p.xy + p.zz, seedparam);
    float y = random(x - p.y + seedparam);
	return vec3(x, y, 1.0 - x);
}
vec2 cell_noise(in vec3 p, in vec3 frequency, in vec3 limit, in float seedparam) {
	p *= frequency;
    vec3 n = floor(p);
	float d = 1.0e10;
    vec2 id = vec2(0.05);
	for (int xo = -1; xo <= 1; xo++) {
		for (int yo = -1; yo <= 1; yo++) {
            for (int zo = -1; zo <= 1; zo++) {
			    vec3 tp = n + vec3(float(xo), float(yo), float(zo));
                vec3 o = _cell_noise_hash(tp, limit * frequency, seed);
			    tp = p - tp - o;
                float dtp = min(dot(tp, tp),1.0);
			    d = min(d, dtp);
                float w = pow(1.0-dtp,100.0-blur*10.0);
                id += vec2(o.y*w, w);
            }
		}
	}
	return 2.0 * vec2(d, id.x/id.y) - 1.0;
}
void fragment() {
    vec2 uv = UV;
    float c = cell_noise(vec3(uv * 10.0, TIME * 0.08), stretch, vec3(pattern,pattern,pattern), seed).y * 0.5 + 0.5;
    c = c * c;
	COLOR = vec4(c, c, c , 1.0);
}