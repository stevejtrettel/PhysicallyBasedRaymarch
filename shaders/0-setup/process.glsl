
//----------------------------------------------------------------------------------------------------------------------
// Post-Processing Color Functions
//----------------------------------------------------------------------------------------------------------------------




vec3 LessThan(vec3 f, float value)
{
    return vec3(
    (f.x < value) ? 1.0f : 0.0f,
    (f.y < value) ? 1.0f : 0.0f,
    (f.z < value) ? 1.0f : 0.0f);
}

vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
    rgb * 12.92f,
    LessThan(rgb, 0.0031308f)
    );
}

vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
    rgb / 12.92f,
    LessThan(rgb, 0.04045f)
    );
}



//TONE MAPPING
//takes linear color -> linear color
//call in post processing before conversion to sRGB, gamma
// ACES tone mapping curve fit to go from HDR to LDR
//https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}




vec3 postProcess(vec3 pixelColor, float exposure){
    pixelColor*=exposure;

    pixelColor = ACESFilm(pixelColor);

    //do the gamma correction
    //pixelColor= pow( pixelColor, vec3(1.0/2.2) );
    pixelColor=LinearToSRGB(pixelColor);

    return pixelColor;
}