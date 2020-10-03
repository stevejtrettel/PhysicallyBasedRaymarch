

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














vec3 getPixelColor(Vector rayDir){
    
    vec3 totalColor=vec3(0.);
    

  //  int numIterate=0;
//    Path path;
//    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
//    Path reflectedRay;
//    Path transmittedRay;
//    
//    Path rP;//iterating reflection and transmission
//    Path tP;//iterating reflection and transmission
//    
//    
//    
    
    refractTrace(rayDir);
    totalColor=skyTex(sampletv);
    
    
    //updatePath(path,sampletv,distToViewer,true);//update the local data accordingly
    //we hit the sky
    
    
    
    
    
    
    
//    
//    
//    //-----do the original raymarch
//    stepForward(rayDir,path,1.,stdRes);
//
//    
//    //====shorter compile time
//    //====follow only the brightest initial ray
//    while(path.keepGoing&&numIterate<5){    totalColor+=beamSplit(path,reflectedRay,transmittedRay);       numIterate+=1;
//  }
////    
    
    
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







