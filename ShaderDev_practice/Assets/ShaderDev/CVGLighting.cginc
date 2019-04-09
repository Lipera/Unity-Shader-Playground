#ifndef CVGLIGHTING
#define CVGLIGHTING

float3 normalFromColor(float4 colorVal) {
    #if defined(UNITY_NO_DXT5nm) // If there is no DXT comnpression return this result
        return colorVal.xyz * 2 - 1;
    #else
        //R => A
        //G
        //B => ignored
        float3 normalVal;
        normalVal = float3( colorVal.a * 2.0 - 1.0,
                            colorVal.g * 2.0 - 1.0,
                            0.0);
        normalVal.z = sqrt(1.0 - dot(normalVal, normalVal)); //inspect lecture 29 for explanation of equation
        return normalVal;
    #endif
}

float3 WorldNormalFromNormalMap(sampler2D normalMap, float2 normalTexCoord, float3 tangentWorld, float3 binormalWorld, float3 normalWorld) {
    //Color at Pixel which we read from Tangent space normal map
    float4 colorAtPixel = tex2D(normalMap, normalTexCoord);

    //Normal value converted from Color value
    float3 normalAtPixel = normalFromColor(colorAtPixel);

    //Compose TBN matrix
    float3x3 TBNWorld = float3x3(tangentWorld, binormalWorld, normalWorld);
    
    return normalize(mul(normalAtPixel, TBNWorld));                  
}

#endif