

//start from the location stored in path: split along reflective and transmitted components, add up resulting colors.
//return both the final locations of transmitted and reflected rays, and set path to be the one with the most light left.
vec3 beamSplit(inout Path path,inout Path reflPath, inout Path transPath){
    
  
    
    
    vec3 totalColor=vec3(0.);
    Vector reflectDir;
    Vector transmitDir;
    
    
    //pick up color from path
    //return final data of dominant ray
    
    //picking up color 
    totalColor+=getSurfaceColor(path,path.frontMat,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    
    
    //make a copy of path to transmit, and to reflect:
    //we began in the air, and hit a surface, so the relevant material is path.frontMat
    reflPath=copyForReflect(path,path.frontMat);
    transPath=copyForTransmit(path,path.frontMat);
    
    
    
    if(reflPath.keepGoing){

    reflectDir=reflPath.dat.reflectedRay;
    //march in reflDir, then iteratively bounce until hitting a transparent surface.  Stop at this surface
    totalColor+=getReflect(reflPath,reflectDir);
    
    //update the keep going command; kill if too dim
    reflPath.keepGoing=reflPath.keepGoing&&(reflPath.intensity>0.01);
        
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    }
    

    
    if(transPath.keepGoing){
    //do the refraction through this transparent object, stop at the back side; pick up internal colors along the way
    totalColor+=getRefract(transPath);
    
    //march outwards in refracted direction, then iteratively reflect if need be.
    transmitDir=transPath.dat.refractedRay;
    totalColor+=getReflect(transPath,transmitDir);
    
    //update the keep going command
   transPath.keepGoing=transPath.keepGoing&&(transPath.intensity>0.01);
    
    }
    
    
    
    
    
    //NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.intensity>transPath.intensity){
        path=reflPath;
    }
    else{
        path=transPath; 
    }

    return totalColor;
    
}














//start from the location stored in path: split along reflective and transmitted components, add up resulting colors.
//return both the final locations of transmitted and reflected rays, and set path to be the one with the most light left.
vec3 beamSplitDispersion(inout Path path,inout Path reflPath, inout Path transPath){
    
    vec3 totalColor=vec3(0.);
    
    
    Vector reflectDir;
    Vector transmitDir;
    
    Path red;
    Path green;
    Path blue;
    
    //pick up color from path
    //return final data of dominant ray
    
    //picking up color 
    totalColor+=getSurfaceColor(path,path.frontMat,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    
    
    //make a copy of path to transmit, and to reflect:
    //we began in the air, and hit a surface, so the relevant material is path.frontMat
    reflPath=copyForReflect(path,path.frontMat);
    
    
    //make copies of the transmit path, adjusted for dispersion
    setDispersionPaths(path,red,green,blue);
    
    //all of the keepGoing booleans for the red, green,blue paths are the same here: so we can take any of them as our "KeepGoing"
    bool doTransmit=red.keepGoing;
    
    
    if(reflPath.keepGoing){

    reflectDir=reflPath.dat.reflectedRay;
    //march in reflDir, then iteratively bounce until hitting a transparent surface.  Stop at this surface
    totalColor+=getReflect(reflPath,reflectDir);
    
    //update the keep going command; kill if too dim
    reflPath.keepGoing=reflPath.keepGoing&&(reflPath.intensity>0.01);
        
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    }
    

    
    if(doTransmit){
    //do the refraction through this transparent object, stop at the back side; pick up internal colors along the way
    totalColor+=getRefract(red);
    totalColor+=getRefract(green);
    totalColor+=getRefract(blue);
    
    //march outwards in refracted direction, then iteratively reflect if need be.
    transmitDir=red.dat.refractedRay;
    totalColor+=getReflect(red,transmitDir);
    red.keepGoing=red.keepGoing&&(red.intensity>0.01);
        
    transmitDir=green.dat.refractedRay;
    totalColor+=getReflect(green,transmitDir);
    green.keepGoing=green.keepGoing&&(green.intensity>0.01);
        
    transmitDir=blue.dat.refractedRay;
    totalColor+=getReflect(blue,transmitDir);
    blue.keepGoing=blue.keepGoing&&(blue.intensity>0.01);
    
    }

    //kill the colored rays, take the middle one (green) and set to default transmission ray, return its color to white.
    transPath=green;
    transPath.lightColor=vec3(1.);
    
    
    
    //NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.intensity>transPath.intensity){
        path=reflPath;
    }
    else{
        path=transPath; 
    }
    
    
    

    return totalColor;
    
}




















vec3 getPixelColor(Vector rayDir){
    int numIterate=0;
    vec3 totalColor=vec3(0.);
    

    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    Path reflectedRay;
    Path transmittedRay;
    
    Path rP;//iterating reflection and transmission
    Path tP;//iterating reflection and transmission
    
    
    //-----do the original raymarch
    stepForward(rayDir,path,1.,stdRes);

    
    //====shorter compile time
    //====follow only the brightest initial ray
    while(path.keepGoing&&numIterate<5){    totalColor+=beamSplit(path,reflectedRay,transmittedRay);       numIterate+=1;
  }
//    
    
    
//    
//    
//    //======== follow both initial rays: longer compile time
//    
//    
    //now we are on the surface.  lets beamSplit! 
//    totalColor+=beamSplit(path,reflectedRay,transmittedRay);
//    
//    //now, follow each of these separately
//    while(reflectedRay.keepGoing&&numIterate<3){
//    totalColor+=beamSplit(reflectedRay,rP,tP);
//        numIterate+=1;
//    }
//    
//    while(transmittedRay.keepGoing&&numIterate<3){
//    totalColor+=beamSplit(transmittedRay,rP,tP);
//        numIterate+=1;
//    }
//    
    
    return totalColor;
    
}







vec3 getPixelColorDispersion(Vector rayDir){
    int numIterate=0;
    vec3 totalColor=vec3(0.);
    
  int ZERO=min(0,display);
    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    
    Path reflectedRay;
    Path transmittedRay;
    
    Path rP;//iterating reflection and transmission
    Path tP;//iterating reflection and transmission
    
    
    //-----do the original raymarch
    stepForward(rayDir,path,1.,stdRes);
    
   
//    //======== follow both initial rays: longer compile time
    
    
   // now we are on the surface.  lets beamSplit! 
    totalColor+=beamSplitDispersion(path,reflectedRay,transmittedRay);
    

    //now iterate the reflected ray and the prime ray
    //OR: JUST THE DOMINANT ONE!
//    numIterate=0;
//        while(path.keepGoing&&numIterate<3+ZERO){
//    totalColor+=beamSplit(path,rP,tP);
//        numIterate+=1;
//    }
    
   numIterate=0;
    while(reflectedRay.keepGoing&&numIterate<3+ZERO){
    totalColor+=beamSplit(reflectedRay,rP,tP);
        numIterate+=1;
    }
    
    numIterate=0;
   while(transmittedRay.keepGoing&&numIterate<3+ZERO){
    totalColor+=beamSplit(transmittedRay,rP,tP);
        numIterate+=1;
    }

    
    return totalColor;
    
}
