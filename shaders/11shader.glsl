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
    color+=pointLight(pointLight2,data,mat,marchShadow);

    return color;
}





//----------------------------------------------------------------------------------------------------------------------
// Color from a reflection
//----------------------------------------------------------------------------------------------------------------------


vec3 surfaceColor(localData data, Material mat, bool marchShadow, inout float rayDistance, inout float refl){
   
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
    amb=ambLights(data, mat,marchShadow);
    scn=sceneLights(data, mat, marchShadow);//add lights
    
    totalColor=amb+scn;
    //totalColor=skyFog(totalColor,rayDistance);
    totalColor*=refl*(1.-mat.reflect);//refl gives the orig amt of light, mat.reflect is the proportion reflected at this surface.
    
    }
    
    //after the color has been added, now update the amount of remaining light
    refl*=mat.reflect;
    
    return totalColor;
    
    
}








vec3 getPixelColorNew(Vector rayDir){
    Volume curVol;
    Volume outVol;
    
    vec3 newColor=vec3(0.);
    vec3 totalColor=vec3(0.);
    
    float rayDistance=0.;
    float reflectedLight=1.;
    
    localData data;
    Material mat;
    
    int numRefl=0;
    
    //-----do the original raymarch
    raymarch(rayDir,1., stdRes);//start outside
    rayDistance+=distToViewer;
    //now that we are at a point, we can set the surface data and material properties
    setParameters(sampletv,data,mat,curVol,outVol);
        
    
    newColor=surfaceColor(data, mat,true,rayDistance,reflectedLight);
    totalColor+=newColor;
    
    
    //----do recursive reflections
    while(reflectedLight>0.005&&numRefl<5){
        
        if(hitWhich==0){break;}//if your last pass hit the sky, stop.
        
    //-----now do a reflection
        nudge(data.reflectedRay);//move the ray a little
       raymarch(data.reflectedRay,data.side,reflRes);//do the reflection march
   
        setParameters(sampletv,data,mat,curVol,outVol);
        
   
    newColor=surfaceColor(data, mat,true,rayDistance,reflectedLight);
    totalColor+=newColor;
        
    numRefl+=1;
    }
    
    
    
    return totalColor;
}



