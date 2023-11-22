//
//  Pixelate.metal
//  winston
//
//  Created by daniel on 22/11/23.
//

#include <metal_stdlib>
#include "SwiftUI/SwiftUI_Metal.h"
using namespace metal;

[[ stitchable ]] float2 pixelate(float2 position, float size) {
  float2 pixelatedPosition = round(position / size) * size;
  return pixelatedPosition;
}

