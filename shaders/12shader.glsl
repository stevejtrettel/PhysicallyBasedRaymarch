





vec3 getPixelColorMirror(Vector rayDir){
    
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
    totalColor+=getOpaqueReflect(data,mat);
    
    return totalColor;
}





vec3 getPixelColorGlass(Vector rayDir){
    
    Volume airVol;
    Volume objVol;
    
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
    
    //now update their relative intensities:
    updateReflectIntensity(reflData,mat);
    updateTransmitIntensity(data,mat,objVol);
    
    //do the reflections first:
    totalColor+=getOpaqueReflect(reflData,mat);
    
    //now, run refractions until we are ready to leave the object
    if(objVol.opacity<1.){
       
        //do the refractions, record distance travelled
        refractDist=refract(data,objVol,airVol);
        updateColorMultiplier(colorMultiplier,objVol,refractDist);
        
        //we are at the back wall of the object now: time to reset the data
        setParameters(sampletv,data,mat,objVol,airVol); 
        //now we are about to enter the air;
        
        //again, we are at a junction where things split: reflection and transmission:
        
        reflData=data;//copy it again
        reflMat=mat;
      //  updateReflectIntensity(reflData,reflMat);
        //totalColor+=vec3(reflMat.reflect,0.,0.);
//        doTIR(reflData,objVol, airVol);
//        //now take the ray that leaves!
//        nudge(reflData.refractedRay);
//        raymarch(reflData.refractedRay,1.,stdRes);
//        setParameters(sampletv,reflData,reflMat,airVol,objVol);
//        totalColor+=colorMultiplier*getSurfaceColor(reflData,reflMat,objVol,true);
//         totalColor+=colorMultiplier*getOpaqueReflect(reflData,reflMat);
         
        
        
        //NOW DO THE SAME THING TO THE TRANSMITTED RAY
        
        //continue forwards out the back
        updateTransmitIntensity(data,mat,objVol);
       
        //now, refract out the backside!
        nudge(data.refractedRay);
        raymarch(data.refractedRay,1.,stdRes);
        //reset the parameters based on our new location
        setParameters(sampletv,data,mat,airVol,objVol); 
        
        reflData=data;//save a duplicate in case we must retransmit
        
        //add the resulting color:
        totalColor+=colorMultiplier*getSurfaceColor(data,mat,objVol,true);
        totalColor+=colorMultiplier*getOpaqueReflect(data,mat);
        
        data=reflData;//reset to orig data
        
        ////now what if the surface is transparent?!
         if(objVol.opacity<1.){
             
        //do the refractions, record distance travelled
        refractDist=refract(data,objVol,airVol);
        updateColorMultiplier(colorMultiplier,objVol,refractDist);
        
        //we are at the back wall of the object now: time to reset the data
        setParameters(sampletv,data,mat,objVol,airVol); 
        //continue forwards out the back
        updateTransmitIntensity(data,mat,objVol);
       
        //now, refract out the backside!
        nudge(data.refractedRay);
        raymarch(data.refractedRay,1.,stdRes);
        //reset the parameters based on our new location
        setParameters(sampletv,data,mat,airVol,objVol); 
             
        reflData=data;//save a duplicate in case we must retransmit
        
        //add the resulting color:
        totalColor+=colorMultiplier*getSurfaceColor(data,mat,objVol,true);
        totalColor+=colorMultiplier*getOpaqueReflect(data,mat);
         
        
        
        
        data=reflData;//reset to orig data
        
        
        
        
        
                ////now what if the surface is transparent?!
         if(objVol.opacity<1.){
             
        //do the refractions, record distance travelled
        refractDist=refract(data,objVol,airVol);
        updateColorMultiplier(colorMultiplier,objVol,refractDist);
        
        //we are at the back wall of the object now: time to reset the data
        setParameters(sampletv,data,mat,objVol,airVol); 
        //continue forwards out the back
        updateTransmitIntensity(data,mat,objVol);
       
        //now, refract out the backside!
        nudge(data.refractedRay);
        raymarch(data.refractedRay,1.,stdRes);
        //reset the parameters based on our new location
        setParameters(sampletv,data,mat,airVol,objVol); 
        
        //add the resulting color:
        totalColor+=colorMultiplier*getSurfaceColor(data,mat,objVol,true);
        totalColor+=colorMultiplier*getOpaqueReflect(data,mat);
         }
        
    }
        
    }
    
    return totalColor;
    
}




