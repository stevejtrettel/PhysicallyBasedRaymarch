



//----------------------------------------------------------------------------------------------------------------------
// Lighting the material surfaces.
//----------------------------------------------------------------------------------------------------------------------

//material properties are already set in the background
vec3 phong(Vector toLight, vec3 lightColor, localData surface, vec3 color, float shiny){
    
    fromLight=turnAround(toLight);
    reflLight=reflectOff(fromLight,surface.normal);
    
    //diffuse lighting
    float nDotL = max(cosAng(surface.normal, toLight), 0.0);
    vec3 diffuse = nDotL*lightColor*color;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, surface.toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,shiny));
    specular=clamp(0.5*specular,0.,1.)*lightColor;
    
    return diffuse+specular;

}


//do phong, do shadow, do everything for this light
vec3 pointLight(Light light, localData surface,Material mat,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //toLight, fromLight, distToLight are STILL GLOBALS...
    
    //set toLight and distToLight
    tangDirection(surface.pos,light.pos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,light.color,surface,mat.color,mat.phong.shiny);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,50.);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*light.intensity/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph;
}





vec3 dirLight(Light light,localData surface, Material mat,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(surface.pos,light.dir);
    
    //NEED TO DEAL WITH THE SHINYNESS IF WE GO THIS WAY
    //float shiny = max(surface.phong.shine/5.,2.);
    ph=phong(toSky,light.color,surface, mat.color,3.);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,20.,2.);
    }
    
     return light.intensity*sh*ph; 
    
}




//----NEW AMBIENT USING MATERIAL
vec3 ambientLight(vec4 lightColor,Material mat){
    return lightColor.w*lightColor.rgb*mat.color;
}















//----------------------------------------------------------------------------------------------------------------------
// Volumetric Fog (this will go away, and be replaced with beers law in materials)
//----------------------------------------------------------------------------------------------------------------------



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


















//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------


vec3 ambLights(localData data, Material mat, bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4),mat);
    
    color+=dirLight(dirLight1,data, mat,marchShadow);

    return color;
}



vec3 sceneLights(localData data, Material mat,bool marchShadow){
    
    vec3 color=vec3(0.);

    color+=pointLight(pointLight1,data, mat,marchShadow);
    //color+=pointLight(pointLight2,data,mat,marchShadow);

    return color;
}




