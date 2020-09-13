










vec3 basicFog( in vec3  pixelColor,      // original color of the pixel
               in float distance)// camera to point distane)  // sun light direction
{
    
    return pixelColor*exp(-distance/10.);
}



vec3 skyFog( in vec3  pixelColor,      // original color of the pixel
               in float distance, // camera to point distance
               in Vector  rayDir,   // camera to point vector
               in Vector sunDir )  // sun light direction
{
    
    float a=0.05;
    float b=0.05;
    
    float extinction = exp( -distance*a );
    float inscatter =  1.0 - exp( -distance*b );
    float sunAmount = max( dot( rayDir.dir, sunDir.dir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,0.7), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,8.0) );
    return pixelColor*extinction + fogColor*inscatter;
}