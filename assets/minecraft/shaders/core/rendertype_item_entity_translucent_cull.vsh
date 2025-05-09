#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

flat out int isLine;
flat out int shouldLineBypassFog;

const float VIEW_SHRINK = 1. - (1. / 256.);
const mat4 VIEW_SCALE = mat4(
  VIEW_SHRINK, 0., 0., 0.,
  0., VIEW_SHRINK, 0., 0.,
  0., 0., VIEW_SHRINK, 0.,
  0., 0., 0., 1.
);

void main() {
  // Workaround for a weird bug in 1.21.5 on Intel integrated GPU
  // Access default uniforms once to suppress error spam
  FogShape;
  Light0_Direction;
  Light1_Direction;
  Sampler2;

  vec4 color = textureLod(Sampler0, UV0, 0);
  float lineWidth = 2.5;
  isLine = 0;
  if(int(round(color.a * 255.)) == 251) {
    // Wireframe behavior
    isLine = 1;

    ivec2 coords = ivec2(UV0 * textureSize(Sampler0, 0));

    vec4 widthColor = texelFetch(Sampler0, coords + ivec2(2, 0), 0);
    if(widthColor.a > 0.5) {
      lineWidth = dot(widthColor.rgb, vec3(1., 1./256., 1./65536.)) * 255.;
    }

    shouldLineBypassFog = 0;
    vec4 fogCodeColor = texelFetch(Sampler0, coords + ivec2(4, 0), 0);
    if(fogCodeColor.a > 0.5) {
      shouldLineBypassFog = 1;
    }

    vec3 N = (color.rgb - 127./255.) * 2.;
    if(abs(N.y) < 0.1) {
      N = vec3(-Normal.z, 0., Normal.x);
    }
    vec4 linePosStart = ProjMat * VIEW_SCALE * ModelViewMat * vec4(Position, 1.);
    vec4 linePosEnd = ProjMat * VIEW_SCALE * ModelViewMat * vec4(Position + N, 1.);

    vec3 ndc1 = linePosStart.xyz / linePosStart.w;
    vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;

    vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * ScreenSize);
    vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * lineWidth / ScreenSize;

    float topDownZ = dot(vec2(-ModelViewMat[2][0], ModelViewMat[0][0]), Position.xz);
    if((topDownZ > 0.) ^^ (lineOffset.x < 0.)) {
      lineOffset *= -1.;
    }

    bool dir =
      (abs(N.y) > 0.1 && gl_VertexID % 4 == 2 || gl_VertexID % 4 == 3) ||
      (abs(N.x) > 0.1 && gl_VertexID % 4 == 0 || gl_VertexID % 4 == 3) ||
      (abs(N.z) > 0.1 && gl_VertexID % 4 == 0 || gl_VertexID % 4 == 3);
    if(dir) {
      gl_Position = vec4((ndc1 + vec3(lineOffset, 0.)) * linePosStart.w, linePosStart.w);
    }
    else {
      gl_Position = vec4((ndc1 - vec3(lineOffset, 0.)) * linePosStart.w, linePosStart.w);
    }

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color;
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
  }
  else {
    // Vanilla behavior
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
  }
}
