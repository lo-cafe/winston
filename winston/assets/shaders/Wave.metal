//
//  Wave.metal
//  NewScroll
//
//  Created by Astemir Eleev on 09/06/2023.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] float2 wave(float2 position, float time) {
    return position + float2(0, sin(time * 2 + position.x / 15)) * 5;
}

[[ stitchable ]] float2 wave2d(float2 position, float time) {
    float waveFrequency = 15.0;
    float waveAmplitude = 5.0;
    float2 wavePosition = position / waveFrequency;
    return position + waveAmplitude * float2(sin(time * 2 + wavePosition.x), sin(time * 1.5 + wavePosition.y));
}

[[ stitchable ]] float2 waveParamed(float2 position, float time, float speed, float frequency, float amplitude, float direction) {
    float f = (time * speed);
    float s = (position.x / frequency);
    float w = 0;
    if(direction == 1.0) {
        w = sin(f - s);
    } else {
        w = sin(f + s);
    }
    float positionY = position.y + w * amplitude;
    return float2(position.x, positionY);
}

[[ stitchable ]] float2 complexWave(float2 position, float time, float speed, float frequency, float strength, float2 size) {
    float2 normalizedPosition = position / size;
    float moveAmount = time * speed;

    position.x += sin((normalizedPosition.x + moveAmount) * frequency) * strength;
    position.y += cos((normalizedPosition.y + moveAmount) * frequency) * strength;

    return position;
}
