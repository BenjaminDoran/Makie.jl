{{GLSL_VERSION}}

struct Nothing{ //Nothing type, to encode if some variable doesn't contain any data
    bool _; //empty structs are not allowed
};

uniform vec3 ambient;
uniform vec3 diffuse;
uniform vec3 specular;
uniform float shininess;

in vec3 o_normal;
in vec3 o_lightdir;
in vec3 o_camdir;
in vec4 o_color;
in vec2 o_uv;
flat in uvec2 o_id;

{{image_type}} image;
{{color_range_type}} color_range;

vec4 get_color(Nothing image, vec2 uv, Nothing color_range){
    return o_color;
}

vec4 get_color(sampler2D color, vec2 uv, Nothing color_range){
    return texture(color, uv);
}

vec4 get_color(sampler1D color, vec2 uv, vec2 color_range){
    float value = (uv.y - color_range.x) / (color_range.y - color_range.x);
    return texture(color, value);
}

vec3 blinnphong(vec3 N, vec3 V, vec3 L, vec3 color){
    float diff_coeff = max(dot(L, N), 0.0);

    // specular coefficient
    vec3 H = normalize(L + V);

    float spec_coeff = pow(max(dot(H, N), 0.0), shininess);

    // final lighting model
    return vec3(
        ambient * color +
        diffuse * diff_coeff * color +
        specular * spec_coeff
    );
}

void write2framebuffer(vec4 color, uvec2 id, vec3 normal);

void main(){
    vec4 color = get_color(image, o_uv, color_range);
    {{light_calc}}
    write2framebuffer(color, o_id, normalize(o_normal)); //, normalize(o_normal)
}
