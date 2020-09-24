




vec3 beamSplit(inout Path path){
    vec3 totalColor=vec3(0.);
    float dist=0.;
    //pick up color from path
    //return final data of dominant ray
    //also return local data of weaker path in case we need it?
    
    //picking up color from path.mat right now...maybe I should set this
    path.mat=path.frontMat;//only if we started outside!
    totalColor+=getSurfaceColor(path,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    
    
    
    
    //now, copy the initial data in two, so we can split 
    Path reflPath=path;
    //reset keepGoing to tell us if the reflectivity is greater than 0.
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

    //we already picked up the surface color; so-to get started we need to step to the next surface.
    Vector reflectDir=reflPath.dat.reflectedRay;
    stepForward(reflectDir,reflPath,1.,stdRes);
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
    totalColor+=getReflect(reflPath);
    
    //update the keep going command
    reflPath.keepGoing=reflPath.keepGoing&&(reflPath.acc.intensity>0.05);
        
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    }
    
    
    
    
    
    
    if(transPath.keepGoing){
    
    //do the refraction through this transparent object, stop at the back side
    doRefract(transPath);
        
    //we should split off two rays here, to do reflection and refraction at the back boundary.
    updateTransmitIntensity(transPath, transPath.frontMat);
    
    
//    //so instead, we just focus on following the refracted ray.
//    nudge(transPath.dat.refractedRay);//move the ray a little
//    raymarch(transPath.dat.refractedRay,1.,stdRes);//going outside the material
//    updatePath(transPath,sampletv);//update the local data accordingly
    Vector refractDir=transPath.dat.refractedRay;
    stepForward(refractDir,transPath,1.,stdRes);
   
    
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
        
    totalColor+=getReflect(transPath);
    
    //update the keep going command
    transPath.keepGoing=transPath.keepGoing&&(transPath.acc.intensity>0.05);
    
        
        //=============
        
     //now do the glass reflections
     //nudge(glassRefl.dat.refractedRay);//move the ray a little
   
    


    }
    
    
    
    
    
   // NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.acc.intensity>transPath.acc.intensity){
        path=reflPath;
    }
    else{
        path=transPath; 
    }

    
    //this is the WRONG WAY TO DO THIS: how do we know when isSky was set?!
    if(isSky){path.keepGoing=false;}
    
    return totalColor;
    
}

//start at the point of the surface given by data.
//raymarch the reflected ray iteratively, until you hit another transparent surface or run out of iterates.
//get the color ready to return

//if the current surface is transparent, refract through (performing TIR if necessary) then upon exiting, iteratively reflect until hitting another transparent object.    
//get the color ready to return
    
    
//THIS PLAN SEEMS LIKE A LOT OF IF THEN STUFF WHICH WILL SLOW THE WORLD DOWNNNN
    
//compare the two remaining light intensities:
    //if both are small: set a boolean to stop
    
    //if not (and we are to continue from here)
    
    //POSSIBLY NOT DO THIS EXTRA MARCH, IF THE IF STATEMENT IS COSTLY AF IN COMPILE TIME?
    //take the smaller one; if it is still significant, carry out the next step, either iterating reflections, or refracting then iterating reflections.
    // then kill this ray.
    
    //set localData to the final position from which we should continue.
    //set all other data as well












vec3 getPixelColor(Vector rayDir){
    int numSplit=0;
    vec3 totalColor=vec3(0.);
    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    
    //-----do the original raymarch
    stepForward(rayDir,path,1.,stdRes);

    //now we are on the surface.  lets beamSplit!   
    
    totalColor+=beamSplit(path);


    return totalColor;
    
}
