





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
    

    
    //now iteratively refract through the material(s)

    totalColor+=getTransmitIterate(data,colorMultiplier,mat,objVol,airVol);
//    
//        int numRefract=0;
//while(objVol.opacity<1.&&numRefract<7){
//    
//            //do the refractions, record distance travelled
//        refractDist=refract(data,objVol,airVol);
//        updateColorMultiplier(colorMultiplier,objVol,refractDist);
//        
//        //we are at the back wall of the object now: time to reset the data
//        setParameters(sampletv,data,mat,objVol,airVol); 
//        //continue forwards out the back
//        updateTransmitIntensity(data,mat,objVol);
//    
//        //SHOULD ALSO CALCULATE THE REFLECTED RAY WHICH STAYS INSIDE THE GLASS HERE
//       
//        //now, refract out the backside!
//        nudge(data.refractedRay);
//        raymarch(data.refractedRay,1.,stdRes);
//        //reset the parameters based on our new location
//        setParameters(sampletv,data,mat,airVol,objVol); 
//        
//    reflData=data;//get the surface color and start bouncing around
//    
//        //add the resulting color by bouncing around
//   totalColor+=colorMultiplier*getSurfaceColor(reflData,mat,objVol,true);
//        totalColor+=colorMultiplier*getOpaqueReflect(reflData,mat);
//    numRefract+=1;
//    
//}
    

    
    return totalColor;
    
}




