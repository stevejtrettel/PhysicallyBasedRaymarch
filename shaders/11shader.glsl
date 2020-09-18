//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------

//----remake using material and surface
vec3 ambLights(surfData surface, Material mat, bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4),mat);
    
    color+=dirLight(dirLight1,surface, mat,marchShadow);

    return color;
}


//----with material and surface

vec3 sceneLights(surfData surface, Material mat,bool marchShadow){
    
    vec3 color=vec3(0.);

    color+=pointLight(pointLight1,surface, mat,marchShadow);
    color+=pointLight(pointLight2,surface,mat,marchShadow);

    return color;
}





//----------------------------------------------------------------------------------------------------------------------
// Color from a reflection
//----------------------------------------------------------------------------------------------------------------------




//remake using the surface and material structs

vec3 surfaceColor(surfData surface, Material mat, bool marchShadow, inout float rayDistance, inout float refl){
   
    //surface and mat are the location we are currently at
    //rayDistance is the distance the ray has already traveled since it left the camera
    //refl keeps track of the amount of light left that still is reflected.
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    vec3 totalColor;
    
   
    if(mat.lightThis==0){//hit the background
        totalColor=refl*mat.color;//weight by amount of surviving light
    }
    else{
    amb=ambLights(surface, mat,marchShadow);
    scn=sceneLights(surface, mat, marchShadow);//add lights
    
    totalColor=amb+scn;
    //totalColor=skyFog(totalColor,rayDistance);
    totalColor*=refl*(1.-mat.reflect);//refl gives the orig amt of light, mat.reflect is the proportion reflected at this surface.
    
    }
    
    //after the color has been added, now update the amount of remaining light
    refl*=mat.reflect;
    
    return totalColor;
    
    
}










//--new version running with the structs.
vec3 getPixelColor(Vector rayDir){
    
    vec3 newColor=vec3(0.);
    vec3 totalColor=vec3(0.);
    
    float rayDistance=0.;
    float reflectedLight=1.;
    
    surfData surface;
    Material mat;
    
    //-----do the original raymarch
    raymarch(rayDir, stdRes);
    rayDistance+=distToViewer;
    //now that we are at a point, we can set the surface data and material properties
    setMaterial(mat, sampletv, hitWhich);
    setSurfData(surface, sampletv, mat, 1.);
    
    
    newColor=surfaceColor(surface, mat,true,rayDistance,reflectedLight);
    totalColor+=newColor;
    
    
    

    if(hitWhich!=0){
       nudge(surface.reflectedRay);//move the ray a little
       raymarch(surface.reflectedRay,reflRes);//do the reflection march
       setMaterial(mat, sampletv, hitWhich);
       setSurfData(surface, sampletv, mat, 1.);
     
        
    newColor=surfaceColor(surface, mat,true,rayDistance,reflectedLight);
    totalColor+=newColor;

    }
    

    
    return totalColor;
}



