//----------------------------------------------------------------------------------------------------------------------
// Lighting Functions
//----------------------------------------------------------------------------------------------------------------------


vec3 phong(Vector toLight, vec3 lightColor, Path path, vec3 color, float shiny){
    
    fromLight=turnAround(toLight);
    reflLight=reflectOff(fromLight,path.dat.normal);
    
    //diffuse lighting
    float nDotL = max(cosAng(path.dat.normal, toLight), 0.0);
    vec3 diffuse = nDotL*lightColor*color;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, path.dat.toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,shiny));
    specular=clamp(0.5*specular,0.,1.)*lightColor;
    
    return diffuse+specular;

}


vec3 pointLight(Light light, Path path, Material mat, bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //toLight, fromLight, distToLight are STILL GLOBALS...
    
    //set toLight and distToLight
    tangDirection(path.dat.pos,light.pos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,light.color,path,mat.surf.color,mat.surf.phong.shiny);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,50.);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*light.intensity/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph;
}






vec3 dirLight(Light light,Path path, Material mat,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(path.dat.pos,light.dir);
    
    //NEED TO DEAL WITH THE SHINYNESS IF WE GO THIS WAY
    //float shiny = max(surface.phong.shine/5.,2.);
    ph=phong(toSky,light.color,path, mat.surf.color,3.);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,20.,2.);
    }
    
     return light.intensity*sh*ph; 
    
}





vec3 ambientLight(vec4 lightColor,Path path,Material mat){
    return lightColor.w*lightColor.rgb*mat.surf.color;
}










//----------------------------------------------------------------------------------------------------------------------
// The Lights Which are Actually in the Scene
//----------------------------------------------------------------------------------------------------------------------




vec3 ambLights(Path path, Material mat,bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4),path,mat);
    
    color+=dirLight(dirLight1,path,mat, marchShadow);

    return color;
}



vec3 sceneLights(Path path,Material mat, bool marchShadow){
    
    vec3 color=vec3(0.);

    color+=pointLight(pointLight1,path,mat,marchShadow);
    color+=pointLight(pointLight2,path,mat,marchShadow);

    return color;
}











//----------------------------------------------------------------------------------------------------------------------
// Actually Lighting A Surface
//----------------------------------------------------------------------------------------------------------------------


vec3 getSurfaceColor(inout Path path,Material mat, bool marchShadow){
    vec3 totalColor;

   if(path.keepGoing){//return nothing if we are not to keep going
        
    if(path.dat.hitSky){//hit the background
        //kill the ray
        path.keepGoing=false;
        //weight by amount of surviving light and get out
        return (path.lightColor)*(path.accColor)*(path.intensity)*(mat.surf.color);
    }
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    
    //else
    amb=ambLights(path,mat, marchShadow);
    scn=sceneLights(path,mat, marchShadow);//add lights
    
    totalColor=amb+scn;
    

    float intensityFactor= path.intensity*(1.-path.dat.reflect) *mat.surf.opacity;
    
    totalColor*=path.accColor;//correct for absorbtion
    totalColor*=intensityFactor;//correct for intensity
    totalColor*=path.lightColor;//correct for color of light beam;
    }
    
    
    return totalColor;
}

