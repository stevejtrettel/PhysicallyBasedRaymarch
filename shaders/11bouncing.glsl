

void stepForward(Vector direction, inout Path path,float side,marchRes res){
    
    if(path.keepGoing){//if we arent supposed to keep going, do nothing
        
    nudge(direction);//move the ray a little
    raymarch(direction,side,res);//march to next object
    updatePath(path,sampletv,isSky);//update the local data accordingly
    
    //update the distance travelled:
    path.acc.dist+=distToViewer;
    //path.backMat=material we just marched through
    //use this to update the accumulated color
    updateAccColor(path, path.backMat,distToViewer);
    }
}





//----------------------------------------------------------------------------------------------------------------------
// Refracting Inside a Transparent Material
//----------------------------------------------------------------------------------------------------------------------


void doTIR(inout Path path){

    int numReflect=0;
    Vector marchDir;
    
    while(path.dat.reflect==1.&&numReflect<20){
        
    marchDir=path.dat.reflectedRay;
    stepForward(marchDir,path,-1.,reflRes);  
    //stepping forward resets path reflectivity, taking Fresnel into account
    //thus, if TIR is in effect, path.dat.reflect=1 will hold
    numReflect+=1;
    }

    //when this stops: still inside material, at point where there is some transmission and some reflectance.
}



vec3 getInternalReflect(Path path){
    vec3 totalColor;
    //take a path, which starts inside a piece of glass where there is reflectivity but not total; and iteratively bounce around, shooting out the portions of rays which exit, and picking up color
    Path transmitPath;
    int numRefl=0;
    
    bool keepGoing=true;
    vec3 testColor=vec3(0.);
    

    while(keepGoing&&numRefl<10){
    //step forward one step along the reflection
    stepForward(path.dat.reflectedRay,path,-1.,reflRes);
    
    transmitPath=copyForTransmit(path,path.backMat);
    //decrease remaining intensity by what is left for reflection.
    updateReflectIntensity(path);

    stepForward(transmitPath.dat.refractedRay,transmitPath,1.,reflRes);
    //now get the color
    totalColor+=getSurfaceColor(transmitPath,false);
    
    numRefl+=1;
    keepGoing=(path.dat.reflect>0.)&&(path.acc.intensity>0.01);
   
}

    //picked up color from some number of bounces, but also some light "escapes" as we cut the bouncing short.  Brighten the color to make up for that:

return (1.+path.acc.intensity)*totalColor;
    
}




vec3 getRefract(inout Path path){
    
    Vector marchDir;
    vec3 totalColor;
    //refract through surface, and march to the next intersection point
    marchDir=path.dat.refractedRay; 
    stepForward(marchDir,path,-1.,stdRes);
    doTIR(path);//do the actual internal reflections
    
    //now we are positioned at the back wall of the surface, and the internal reflectivity is no longer 1
    //save this position; this is where we start the next march
    
    //if there's sufficient light intensity to warrant it; keep going:
    if(path.acc.intensity>0.1){
    //copy path for internal reflection:
    Path reflectPath=path;
    
    //get the color of the back surface from Phong?
    path.mat=path.backMat;
    totalColor+=getSurfaceColor(path,false);
    
    //update the path intensity, taking out the reflective comp
    //path.backmat is the glass we are inside of
    updateTransmitIntensity(path,path.backMat);
    
    //update the intensity for what is available for reflection still
    updateReflectIntensity(reflectPath);
    //get color from continuing the internal bounce and sampling whats outside.
    totalColor+=getInternalReflect(reflectPath);
    }
    
    //if the orig intensity wasn't very strong: the internal color collection doesn't run, so this adds nothing
    return totalColor;
    
    //the pathData is still at the first exit point from total internal refraction
}








//----------------------------------------------------------------------------------------------------------------------
// Reflecting through Air, hitting opaque materials.
//----------------------------------------------------------------------------------------------------------------------




vec3 getReflect(inout Path path,Vector initialDir){
    //start on a surface, where you have already grabbed the surface color (this surface may be partially transparent)
    int MAX_REFL=10;
    int numRefl=0;
    vec3 totalColor=vec3(0.);
    
    //march in initial direction from surface
    stepForward(initialDir,path,1.,reflRes);
    
    //we keep going if the material in front of us is not transparent
    //or if it is the sky, cuz we need to add the sky color
     bool keepGoing=path.keepGoing&&(path.hitSky||path.mat.vol.opacity==1.);
    
     while(keepGoing&&numRefl<MAX_REFL){
        
        //pick up the color
        path.mat=path.frontMat;
        totalColor+=getSurfaceColor(path,true);
        updateReflectIntensity(path);
         
         //reflect off the surface
        stepForward(path.dat.reflectedRay,path,1.,reflRes);
        
        //keep going if (1) not sky, and (2)object is opaque and (3)there's sufficient intensity to bother.
        keepGoing=path.keepGoing&&(path.hitSky||path.mat.vol.opacity==1.);
        
        numRefl+=1;
    }
    
    //right now, once we hit
    
    //reset path.keepGoing to quit if we did all 10 steps, or if the intensity is very low.
    path.keepGoing=path.keepGoing&&(numRefl<MAX_REFL)&&(path.acc.intensity>0.05);


    return totalColor;
    
}



