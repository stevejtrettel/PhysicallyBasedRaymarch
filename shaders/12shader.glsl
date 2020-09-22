





vec3 getPixelColorMirror(Vector rayDir){
    bool keepGoing;
    
    Volume airVol;
    Volume objVol;
    
    localData data;
    resetIntensity(data);//make it so we start with intensity 1.
    
    Material mat;
    
    vec3 totalColor;
    
    //-----do the original raymarch
    raymarch(rayDir,1., stdRes);//start outside
    setParameters(sampletv,data,mat,airVol,objVol);
    
    
    totalColor=getSurfaceColor(data, mat,objVol,true);
    //now do reflections until you hit the sky or run out of light
    totalColor+=getOpaqueReflect(data,mat,objVol,keepGoing);
    
    return totalColor;
}





vec3 getPixelColorGlass(Vector rayDir){
    bool keepGoing;
    
    Volume airVol;
    Volume objVol;
    Volume reflVol;
    
    localData data;
    localData reflData;
    resetIntensity(data);//make it so we start with intensity 1.

    float refractDist;
    
    Material mat;
    Material reflMat;
    
    vec3 colorMultiplier=vec3(1.);

    vec3 totalColor;
    
    //-----do the original raymarch
    raymarch(rayDir,1., stdRes);//start outside
    setParameters(sampletv,data,mat,airVol,objVol);  
    totalColor+=getSurfaceColor(data,mat,objVol,true);
    
    
    //going to separate out and go two paths: reflection and transmission
    reflData=data;//this way we don't change the actual data.
    reflVol=objVol;
    //now update their relative intensities:
    updateReflectIntensity(reflData,mat);
    updateTransmitIntensity(data,mat,objVol);
    
        //now iteratively refract through the material(s)
 totalColor+=getTransmitIterate(data,colorMultiplier,mat,objVol,airVol,keepGoing);
    //if keepGoing is true here, you did a bunch of refracting about then after bouncing a bit hit a transparent thing again
    if(keepGoing){
        totalColor+=getTransmitIterate(data,colorMultiplier,mat,objVol,airVol,keepGoing);
    }
    
    
    //back from the original point; do the reflection pass
    totalColor+=getOpaqueReflect(reflData,mat,reflVol,keepGoing);
    
    if(keepGoing){
        //we hit a transparent surface, so march through this to pick up more colors!
        totalColor+=getTransmitIterate(reflData,colorMultiplier,mat,reflVol,airVol,keepGoing);
        
    }

    


    
    return totalColor;
    
}





vec3 followPrimeRay(){
    return vec3(0.);
    
    //instead of beam splitting, just figure out which intensity is greater and follow that ray.
    
    
    
}




vec3 beamSplit(inout localData data,inout Material mat, inout Volume objVol){
    return vec3(0.);
    
    
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
}







vec3 getPixelColor(Vector rayDir){
    return vec3(0.);
    
//first, raymarch from the inital location to a surface.
//get that surfaces color.
//
    
}
