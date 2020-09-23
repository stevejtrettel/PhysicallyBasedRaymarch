




vec3 beamSplit(inout Path path){
    vec3 totalColor=vec3(0.);
    //pick up color from path
    //return final data of dominant ray
    //also return local data of weaker path in case we need it?
    
    //picking up color from path.mat right now...maybe I should set this
    path.mat=path.frontMat;//only if we started outside!
    totalColor+=getSurfaceColor(path,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    //now, copy the initial data in two, so we can split 
    Path reflPath=path;
    reflPath.mat=path.backMat;
    
    Path transPath=path;
    transPath.mat=path.frontMat;
    
    //from here on, don't use the original inputs until we set something equal to them back at the end.
    
    //step 1: do the first reflection
    nudge(reflPath.dat.reflectedRay);//move the ray a little
    raymarch(reflPath.dat.reflectedRay,stdRes);//do the reflection 
    updatePath(reflPath,sampletv);//update the local data accordingly
    
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
    totalColor+=getReflect(reflPath);
    
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    
    
    
    
    
    
    
    
    //step 2: do the refraction:
    doRefract(transPath);
    //now we are at the exit location to the material.  
    
    //Here we need to follow two rays!  The refraction through the surface and the further internal reflection
    //to do this, we need to duplicate the data again!  this will be SAVED FOR LATER: DON'T WANT TO MAKE THINGS TOO COMPLICATED RIGHT NOW!
    
    //so instead, we just focus on following the refracted ray.
    nudge(transPath.dat.refractedRay);//move the ray a little
    raymarch(transPath.dat.refractedRay,stdRes);//going outside the material
    updatePath(transPath,sampletv);//update the local data accordingly
    
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
    totalColor+=getReflect(transPath);
    
    //NOW: update the original data by the larger of the remaining intensities:
//    if(reflPath.acc.intensity>transPath.acc.intensity){
//        path=reflPath;
//    }
//    else{
//        path=transPath; 
//    }
    
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
    
    vec3 totalColor=vec3(0.);
    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    
    //-----do the original raymarch
    raymarch(rayDir,stdRes);//start outside
 
    updatePath(path,sampletv);//create local data at site
    //path.mat=path.frontMat;
    
    //now we are on the surface.  lets beamSplit!
    totalColor=getReflect(path);
    //totalColor+=beamSplit(path);

    return totalColor;
    
}
