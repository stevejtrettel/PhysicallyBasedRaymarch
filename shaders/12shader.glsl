



vec3 beamSplit(inout Path path){
    vec3 totalColor=vec3(0.);
    //pick up color from path
    //return final data of dominant ray
    
    //picking up color from path.mat
    path.mat=path.frontMat;//only if we started outside!
    totalColor+=getSurfaceColor(path,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    
    
    //now, copy the initial data in two, so we can split 
    Path reflPath=path;
    //reset keepGoing to tell us if reflectivity>0
    reflPath.keepGoing=(reflPath.dat.reflect>0.);
    //keep only the amount of intensity which gets reflected.
    updateReflectIntensity(reflPath);
    
    
    
    Path transPath=path;
    transPath.mat=path.frontMat;
    //make this true only if the material lets some light through
    transPath.keepGoing=(transPath.mat.vol.opacity<1.);
    //update the intensity of the light which gets transmitted
    updateTransmitIntensity(transPath,transPath.frontMat);
    
    
    
    if(reflPath.keepGoing){

    Vector reflectDir=reflPath.dat.reflectedRay;
    //march in reflDir, then iteratively bounce until hitting a transparent surface.  Stop at this surface
    totalColor+=getReflect(reflPath,reflectDir);
    
    //update the keep going command; kill if too dim
    reflPath.keepGoing=reflPath.keepGoing&&(reflPath.acc.intensity>0.01);
        
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    }
    

    
    if(transPath.keepGoing){
    //do the refraction through this transparent object, stop at the back side
    totalColor+=getRefract(transPath);
        
    //we should split off two rays here, to do reflection and refraction at the back boundary.  NOT DOING YET
   
    
    //march outwards in refracted direction, then iteratively reflect if need be.
    Vector refractDir=transPath.dat.refractedRay;
    totalColor+=getReflect(transPath,refractDir);
    
    //update the keep going command
    transPath.keepGoing=transPath.keepGoing&&(transPath.acc.intensity>0.05);
    
    }
    
    
   // NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.acc.intensity>transPath.acc.intensity){
        path=reflPath;
    }
    else{
        path=transPath; 
    }

    
    return totalColor;
    
}








vec3 getPixelColor(Vector rayDir){
    int numSplit=0;
    vec3 totalColor=vec3(0.);
    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    
    //-----do the original raymarch
    stepForward(rayDir,path,1.,stdRes);

    //now we are on the surface.  lets beamSplit!   
    
    totalColor+=beamSplit(path);
//    if(path.keepGoing){
//        totalColor+=beamSplit2(path);
//        if(path.keepGoing){
//        totalColor+=beamSplit2(path);
//        }
//    }

    return totalColor;
    
}
