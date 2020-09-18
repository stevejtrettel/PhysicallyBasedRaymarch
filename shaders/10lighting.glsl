

//----NEW PHONG USING MATERIAL
//material properties are already set in the background
vec3 phong(Vector toLight, vec4 lightColor, surfData surface, Material mat){
    
    fromLight=turnAround(toLight);
    reflLight=reflectOff(fromLight,surface.normal);
    
    //diffuse lighting
    float nDotL = max(cosAng(surface.normal, toLight), 0.0);
    vec3 diffuse = nDotL*lightColor.rgb*mat.color;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, surface.toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,mat.phong.shiny));
    specular=clamp(specular,0.,1.)*lightColor.rgb;
    
    return diffuse+specular;

}






//----- NEW POINT LIGHT USING MATERIAL

//do phong, do shadow, do everything for this light
vec3 pointLight(Point lightPos, vec4 lightColor, surfData surface,Material mat,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //toLight, fromLight, distToLight are STILL GLOBALS...
    
    //set toLight and distToLight
    tangDirection(surfPos,lightPos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,lightColor,surface,mat);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,50.);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*lightColor.w/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph;
}





//---- new DIR LIGHT USING MATERIAL
vec3 dirLight(vec3 lightDir,vec4 lightColor,surfData surface, Material mat,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(surface.pos,lightDir);
    
    //NEED TO DEAL WITH THE SHINYNESS IF WE GO THIS WAY
    //float shiny = max(surface.phong.shine/5.,2.);
    ph=phong(toSky,lightColor,surface, mat);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,20.,2.);
    }
    
     return lightColor.w*sh*ph; 
    
}




//----NEW AMBIENT USING MATERIAL
vec3 ambientLight(vec4 lightColor,Material mat){
    return lightColor.w*lightColor.rgb*mat.color;
}















//----THESE DON'T NEED ANY CHANGES!




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








