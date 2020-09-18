//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------
vec3 ambLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4));
    
    color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.2),marchShadow);

    return color;
}



//----remake using material and surface
vec3 ambLights(surfData surface, Material mat, bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4),mat);
    
    color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.2),surface, mat,marchShadow);

    return color;
}





vec3 sceneLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=pointLight(createPoint(1.,1.,1.),vec4(1,1.,1.,1.),marchShadow);
    color+=pointLight(createPoint(-1.,-1.,0.),vec4(1.,1.,1.,1.),marchShadow);
    
    return color;
}

//----with material and surface

vec3 sceneLights(surfData surface, Material mat,bool marchShadow){
    
    vec3 color=vec3(0.);
    
    Point lightPos1=createPoint(1.,1.,1.);
    vec4 lightColor1=vec4(1,1.,1.,1.);
    Point lightPos2=createPoint(-1.,-1.,0.);
    vec4 lightColor2=vec4(1,1.,1.,1.);
    
    color+=pointLight(lightPos1,lightColor1,surface, mat,marchShadow);
    color+=pointLight(lightPos2,lightColor2,surface,mat,marchShadow);

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









vec3 getPixelColor(Vector rayDir){
    
    vec3 currentSurface;
    
    vec3 newColor=vec3(0.);
    vec3 totalColor=vec3(0.);
    
    int numRefl=0;
    float rayDistance=0.;
    float reflectedLight=1.;
    
    //-----do the original raymarch
    raymarch(rayDir, stdRes);
    currentSurface=surfColor;
    newColor=surfaceColor(true,rayDistance,reflectedLight);
    totalColor+=newColor;
    

//    while(reflectedLight>0.005&&numRefl<5){
//        
//        if(hitWhich==0){break;}//if your last pass hit the sky, stop.
//        
//    //-----now do a reflection
//    //surfaceData, which runs in the function above, sets all the surface properties, including reflecting the incident ray
//    reflectedRay=flow(reflectedRay,0.1);//push it off a little
//   raymarch(reflectedRay,reflRes);//do the reflection march
//    
//    //calculate the reflected color
//    newColor=surfaceColor(false,rayDistance,reflectedLight);
//    newColor=(vec3(0.3)+currentSurface)*newColor;//STILL HAVE TO WEIGHT THIS BY THE COLOR OF THE SURFACE ITS REFLECTING OFF OF
//    totalColor+=newColor;
//        
//    numRefl+=1;
//    }
 
    
    return totalColor;
}




//--new version running with the structs.
vec3 getPixelColorNew(Vector rayDir){
    
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



