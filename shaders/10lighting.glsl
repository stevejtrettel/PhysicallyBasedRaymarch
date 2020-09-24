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


vec3 pointLight(Light light, Path path, bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //toLight, fromLight, distToLight are STILL GLOBALS...
    
    //set toLight and distToLight
    tangDirection(path.dat.pos,light.pos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,light.color,path,path.mat.surf.color,path.mat.surf.phong.shiny);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,50.);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*light.intensity/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph;
}






vec3 dirLight(Light light,Path path,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(path.dat.pos,light.dir);
    
    //NEED TO DEAL WITH THE SHINYNESS IF WE GO THIS WAY
    //float shiny = max(surface.phong.shine/5.,2.);
    ph=phong(toSky,light.color,path, path.mat.surf.color,3.);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,20.,2.);
    }
    
     return light.intensity*sh*ph; 
    
}





vec3 ambientLight(vec4 lightColor,Path path){
    return lightColor.w*lightColor.rgb*path.mat.surf.color;
}










//----------------------------------------------------------------------------------------------------------------------
// The Lights Which are Actually in the Scene
//----------------------------------------------------------------------------------------------------------------------




vec3 ambLights(Path path, bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4),path);
    
    color+=dirLight(dirLight1,path, marchShadow);

    return color;
}



vec3 sceneLights(Path path, bool marchShadow){
    
    vec3 color=vec3(0.);

    color+=pointLight(pointLight1,path,marchShadow);
    color+=pointLight(pointLight2,path,marchShadow);

    return color;
}











//----------------------------------------------------------------------------------------------------------------------
// Actually Lighting A Surface
//----------------------------------------------------------------------------------------------------------------------


vec3 getSurfaceColor(inout Path path, bool marchShadow){
    //path.mat is the material we are coloring
    
    if(path.mat.bkgnd){//hit the background
        path.keepGoing=false;
        return (path.acc.color)*(path.acc.intensity)*(path.mat.surf.color);
        //weight by amount of surviving light and get out
    }
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    vec3 totalColor;
    
    //else
    amb=ambLights(path, marchShadow);
    scn=sceneLights(path, marchShadow);//add lights
    
    totalColor=amb+scn;
    

    float intensityFactor= path.acc.intensity*(1.-path.dat.reflect) *path.mat.vol.opacity;
    
    totalColor*=path.acc.color;//correct for absorbtion
    totalColor*=intensityFactor;//correct for intensity
    
    return totalColor;
 
}

