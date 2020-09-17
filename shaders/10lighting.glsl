

//vec3 fresnel( vec3 F0, vec3 h, vec3 l ) {
//	return F0 + ( 1.0 - F0 ) * pow( clamp( 1.0 - dot( h, l ), 0.0, 1.0 ), 5.0 );
//}
//
//


//material properties are already set in the background
vec3 phong(Vector toLight, vec4 lightColor,float surfShine){
    
    fromLight=turnAround(toLight);
    reflLight=reflectOff(fromLight,surfNormal);
    
    //diffuse lighting
    float nDotL = max(cosAng(surfNormal, toLight), 0.0);
    vec3 diffuse = nDotL*lightColor.rgb*surfColor;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,surfShine));
    specular=clamp(specular,0.,1.)*lightColor.rgb;
    
    return diffuse+specular;

}



//do phong, do shadow, do everything for this light
vec3 pointLight(Point lightPos, vec4 lightColor,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //set toLight and distToLight
    tangDirection(surfPos,lightPos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,lightColor,surfShine);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,surfShine);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*lightColor.w/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph; 
}



vec3 dirLight(vec3 lightDir,vec4 lightColor,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(surfPos,lightDir);
    
    float shiny = max(surfShine/5.,2.);
    ph=phong(toSky,lightColor,shiny);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,20.,2.);
    }
    
     return lightColor.w*sh*ph; 
    
}



vec3 ambientLight(vec4 lightColor){
    return lightColor.w*lightColor.rgb*surfColor;
}


























vec3 basicFog( in vec3  pixelColor,      // original color of the pixel
               in float distance)// camera to point distane)  // sun light direction
{
    
    return pixelColor*exp(-distance/10.);
}



vec3 skyFog( in vec3  pixelColor,      // original color of the pixel
           in float distance// camera to point distance
           )  // sun light direction
{
    
    float a=20.*20.;
    float b=20.*20.;
    //vec3 skyColor=vec3(0.);
    
    
    float extinction = exp( -distance*distance/a );
    float inscatter =  1.0 - exp( -distance*distance/b );

    //return pixelColor;
    return pixelColor*extinction+ skyColor.w*skyColor.rgb*inscatter;
}








