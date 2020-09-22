






//
//
//vec3 getPixelColorGlass(Vector rayDir){
//    bool keepGoing;
//    
//    Volume airVol;
//    Volume objVol;
//    Volume reflVol;
//    
//    localData data;
//    localData reflData;
//    resetIntensity(data);//make it so we start with intensity 1.
//
//    float refractDist;
//    
//    Material mat;
//    Material reflMat;
//    
//    vec3 colorMultiplier=vec3(1.);
//
//    vec3 totalColor;
//    
//    //-----do the original raymarch
//    raymarch(rayDir,1., stdRes);//start outside
//    setParameters(sampletv,data,mat,airVol,objVol);  
//    totalColor+=getSurfaceColor(data,mat,objVol,true);
//    
//    
//    //going to separate out and go two paths: reflection and transmission
//    reflData=data;//this way we don't change the actual data.
//    reflVol=objVol;
//    //now update their relative intensities:
//    updateReflectIntensity(reflData,mat);
//    updateTransmitIntensity(data,mat,objVol);
//    
//        //now iteratively refract through the material(s)
// totalColor+=getTransmitIterate(data,colorMultiplier,mat,objVol,airVol,keepGoing);
//    //if keepGoing is true here, you did a bunch of refracting about then after bouncing a bit hit a transparent thing again
//    if(keepGoing){
//        totalColor+=getTransmitIterate(data,colorMultiplier,mat,objVol,airVol,keepGoing);
//    }
//    
//    
//    //back from the original point; do the reflection pass
//    totalColor+=getOpaqueReflect(reflData,mat,reflVol,keepGoing);
//    
//    if(keepGoing){
//        //we hit a transparent surface, so march through this to pick up more colors!
//        totalColor+=getTransmitIterate(reflData,colorMultiplier,mat,reflVol,airVol,keepGoing);
//        
//    }
//
//    
//
//
//    
//    return totalColor;
//    
//}






vec3 beamSplit(inout Path path,inout newMaterial mat,newMaterial outside){
    vec3 totalColor=vec3(0.);
    //pick up color from path
    //return final data of dominant ray
    //also return local data of weaker path in case we need it?
    
    totalColor+=getSurfaceColor(path,mat,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky
    
    //now, copy the initial data in two, so we can split 
    Path reflPath=path;
    newMaterial reflMat=mat;
    
    Path transPath=path;
    newMaterial transMat=mat;
    
    //from here on, don't use the original inputs until we set something equal to them back at the end.
    
    
    //step 1: do the first reflection
    nudge(reflPath.dat.reflectedRay);//move the ray a little
    raymarch(reflPath.dat.reflectedRay,1.,stdRes);//do the reflection 
    updateNewMaterial(reflMat,sampletv, hitWhich);//set material to what was just impacted
    updateLocalData(reflPath,sampletv,outside,reflMat);//update the local data accordingly
    
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
    totalColor+=getReflect(reflPath,reflMat,outside);
    
    //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    
    
    
    
    
    
    
    
    //step 2: do the refraction:
    doRefract(transPath,transMat,outside);
    //now we are at the exit location to the material.  Here we need to follow two rays!  The refraction through the surface and the further internal reflection
    
    //to do this, we need to duplicate the data again!  this will be SAVED FOR LATER: DON'T WANT TO MAKE THINGS TOO COMPLICATED RIGHT NOW!
    //so instead, we just focus on following the refracted ray.
    nudge(transPath.dat.refractedRay);//move the ray a little
    raymarch(transPath.dat.refractedRay,1.,stdRes);//going outside the material
    updateNewMaterial(transMat,sampletv, hitWhich);//set material to what was just impacted
    updateLocalData(transPath,sampletv,transMat,outside);//update the local data accordingly
    
    //now, run the reflection iterator: it will accumulate colors and stop upon impacting a transparent surface;
    totalColor+=getReflect(transPath,transMat,outside);
    
    
    //NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.acc.intensity>transPath.acc.intensity){
        path=reflPath;
        mat=reflMat;
    }
    else{
        path=transPath;
        mat=transMat;
    }
    
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
    
    newMaterial outside=airMaterial;
    newMaterial mat;
    
    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing to true
    
    //-----do the original raymarch
    raymarch(rayDir,1., stdRes);//start outside
    updateNewMaterial(mat,sampletv, hitWhich);//set material to impact site
    updateLocalData(path,sampletv,outside,mat);//create local data at site
    
    //now we are on the surface.  lets beamSplit!
    totalColor+=beamSplit(path,mat,outside);

    return totalColor;
    
}
