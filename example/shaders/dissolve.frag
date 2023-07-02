#version 460 core
precision mediump float;

#include <flutter/runtime_effect.glsl>

// background grid from https://www.shadertoy.com/view/XtBfzz

const float N = 2.0; // grid ratio
float gridTexture( in vec2 p )
{
    // coordinates
    vec2 i = step( fract(p), vec2(1.0/N) );
    //pattern
    //return (1.0-i.x)*(1.0-i.y);   // grid (N=10)
    
    // other possible patterns are these
    //return 1.0-i.x*i.y;           // squares (N=4)
    return 1.0-i.x-i.y+2.0*i.x*i.y; // checker (N=2)
}

#define mask_tile 0.3

uniform vec2 uSize;

uniform float t;                 // shader playback time (in seconds)
// The input image sampler the shader will be applied to
uniform sampler2D tInput;

// The input image sampler the shader will be applied to
uniform sampler2D tNoise;

// A 4-dimentional vector corresponding to the R,G, B, and A channels
// of the color to be returned from this shader for every pixel
out vec4 fragColor;

void main() {

    // The local position of the pixel being evaluated
    vec2 fragCoord = FlutterFragCoord().xy;

    // UVs of the main Color texture
	vec2 uv = fragCoord.xy/uSize.xy;

    // color textures
    vec4 clrA = texture(tInput, uv);
    
    // background grid
    vec4 clrBG = 0.2 * vec4(1., 1., 1., 1.) * gridTexture(fragCoord.xy/uSize.xx * vec2(5., 5.)) + 0.6;
    
	// set these to increase/decrease the edge width
    float edge_width_start = 0.15; // width at the start of the dissolve (alpha = 1)
    float edge_width_end = 0.05; // width at the end of the dissolve (alpha = 0)
    
    float edge_width = mix(edge_width_start, edge_width_end, smoothstep(0., 1., t)); // 
    
    // increase the alpha range by the edge width so we are not left with only glowy edges 
    float myAlpha = mix(0. - edge_width, 1., t); 
    
    // fade mask uv
    vec2 uv_mask = fragCoord.xy/uSize.xy;
    
    // fade mask texture
    // use a linear texture that has values between 0-1
    vec4 alphaTex = texture(tNoise, uv_mask * mask_tile);

    // alpha mask (1-bit)
    float a = step(alphaTex.r, myAlpha);

    // edge mask which is a slightly progressed version of the alpha
    // this mask doesn't need to be 1 bit as it will just be added to the color
    float edge = smoothstep(alphaTex.r - edge_width, alphaTex.r, myAlpha);

    vec4 edgeColor = vec4(0., 0.1, 1.0, 1.0);
    edgeColor *= edge * 10.;
    
    // add edge color to the color
    clrA += edgeColor;

    fragColor = mix(clrA, clrBG, a);
}