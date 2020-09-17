//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------
vec3 ambLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.7));
    
    color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.2),true);

    return color;
}





vec3 sceneLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=pointLight(createPoint(1.,1.,1.),vec4(1,1.,1.,1.),marchShadow);
    color+=pointLight(createPoint(-1.,-1.,0.),vec4(1.,1.,1.,1.),marchShadow);
    
    return color;
}





//----------------------------------------------------------------------------------------------------------------------
// Color from a reflection
//----------------------------------------------------------------------------------------------------------------------


vec3 surfaceColor(bool marchShadows, inout float rayDistance, inout float refl){
    //sampletv is a point in the scene.
    //hitWhich determines the properties of the material at that point
    
    //rayDistance is the distance the ray has already traveled since it left the camera
    //refl keeps track of the amount of light left that still is reflected.
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    vec3 totalColor;
    
    surfaceData(sampletv,hitWhich);//set all the local data
    rayDistance+=distToViewer;//accumulate distance travelled
   
    if(lightThis==0){//hit the background
        totalColor=refl*surfColor;//weight by amount of surviving light
    }
    else{
    amb=ambLights(marchShadows);
    scn=sceneLights(marchShadows);//add lights
    
    totalColor=amb+scn;
    //totalColor=skyFog(totalColor,rayDistance);
    totalColor*=refl*surfRefl.x;//refl gives the orig amt of light, surfRefl.x is proportion not reflected.
    
    }
    
    //after the color has been added, now update the amount of remaining light
    refl*=surfRefl.y;
    
    return totalColor;
    
    
}




vec3 getPixelColor(Vector rayDir){
    
    vec3 currentSurface;
    
    vec3 newColor=vec3(0.);
    vec3 totalColor=vec3(0.);
    
    float rayDistance=0.;
    float reflectedLight=1.;
    
    //-----do the original raymarch
    raymarch(rayDir, totalFixIsom);
    currentSurface=surfColor;
    totalColor+=surfaceColor(true,rayDistance,reflectedLight);
    
    while(reflectedLight>0.005){
    //-----now do a reflection
    //surfaceData, which runs in the function above, sets all the surface properties, including reflecting the incident ray
    reflectedRay=flow(reflectedRay,0.1);//push it off a little
    reflectmarch(reflectedRay,totalFixIsom);//do the reflection march
    
    //calculate the reflected color
    newColor=surfaceColor(false,rayDistance,reflectedLight);
    newColor=(vec3(0.3)+currentSurface)*newColor;//STILL HAVE TO WEIGHT THIS BY THE COLOR OF THE SURFACE ITS REFLECTING OFF OF
    totalColor+=newColor;
        
    }
    
    return totalColor;
}




