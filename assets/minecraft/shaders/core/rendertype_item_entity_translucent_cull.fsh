#version 150

#moj_import <minecraft:fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

out vec4 fragColor;

flat in int isLine;
flat in int shouldLineBypassFog;

void main() {
  if(isLine == 1) {
    // Wireframe behavior
    if(shouldLineBypassFog == 1) {
      fragColor = vertexColor;
    }
    else {
      fragColor = linear_fog(vertexColor, vertexDistance, FogStart, FogEnd, FogColor);
    }
  }
  else {
    // Vanilla behavior
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if(color.a < 0.1) {
      discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
  }
}
