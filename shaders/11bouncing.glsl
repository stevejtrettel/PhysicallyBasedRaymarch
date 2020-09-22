
//----------------------------------------------------------------------------------------------------------------------
// Update Available Light
//----------------------------------------------------------------------------------------------------------------------


//after marching through volume "vol" for distance "dist", update the color multiplier you use on colors.
//this does NOT change the intensity in local data (the decrease is accounted for in "color")

////====old
//void updateColorMultiplier(inout vec3 color,Volume vol,float dist){
//    vec3 absorb=exp(vol.absorb*dist);
//    color*=absorb;
//    
//}
//
////=====OLD VERSIONS
////update the light intensity of a local data, depending on if we are continuing on for reflection or transmission
//void updateReflectIntensity(inout localData data, Material mat){
//    
//    //need to make sure the local 
//    data.intensity*=mat.reflect;
//    //amt left is determiend by reflectivity
//}
//
//void updateTransmitIntensity(inout localData data, Material mat, Volume entering){
//    data.intensity*=(1.-mat.reflect)*(1.-entering.opacity);
//    
//}
//
//



//=====NEW





//----------------------------------------------------------------------------------------------------------------------
// TotalInternalRefraction
//----------------------------------------------------------------------------------------------------------------------

//
////bounce around inside of an object until total internal refraction stops.  then you are at the surface of the object, and some of your ray will reflect and some will refract.
//float refract(inout localData data, Volume inside, Volume outside){
//    float dist=0.;
//    bool totalReflect;
//    int numReflect=-1;
//    
//    
//    //first refract through the surface and hit an inside wall
//    nudge(data.refractedRay);
//    raymarch(data.refractedRay,-1.,stdRes);
//    //we are refracting on the inside of an object.
//    dist+=distToViewer;//dist traveled inside ball
//    setLocalData(data,sampletv,inside,outside);
//    
//    //check if we have to continue totally reflecting internally
//    totalReflect=needTIR(data,inside,outside);
//    
//    while(totalReflect&&numReflect<10){
//    nudge(data.reflectedRay);
//    raymarch(data.reflectedRay,-1.,stdRes);
//    //we are refracting on the inside of an object.
//    dist+=distToViewer;
//    
//    setLocalData(data,sampletv,inside,outside);
//    //if we are totally internally reflecting; keep going
//    totalReflect=needTIR(data,inside,outside);
//    numReflect+=1;
//    }
//    
//    
//    
//    //dist is the total distance traveled inside the material
//    updateColorMultiplier(data.colorMultiplier,inside,dist);
//    return dist;//in future: make this void.
//
//   //when it leaves, local Data has been set to the parameters at the final intersection with the surface so we can start picking up colors again. 
//}
//
//



//float doTIR(inout localData data, Volume inside, Volume outside){
//    float dist=0.;
//    bool keepGoing=true;
//    int numReflect=-1;
//    
//    while(keepGoing&&numReflect<10){
//    nudge(data.reflectedRay);
//    raymarch(data.reflectedRay,-1.,stdRes);
//    //we are refracting on the inside of an object.
//    dist+=distToViewer;
//    
//    setLocalData(data,sampletv,inside,outside);
//    //if we are totally internally reflecting; keep going
//    keepGoing=needTIR(data,inside,outside);
//    numReflect+=1;
//    }
//    
//    //dist is the total distance traveled inside the material
//    return dist;
//
//   //when it leaves, local Data has been set to the parameters at the final intersection with the surface so we can start picking up colors again. 
//}





//=====NEW VERSIONS OF THE ABOVE!!


float doTIR(inout Path path, inout newMaterial currentMat, newMaterial outside){
    float dist=0.;
    bool keepGoing=true;
    int numReflect=-1;
    Vector marchDir;
    
    while(path.keepGoing&&numReflect<10){
    marchDir=path.dat.reflectedRay;
    nudge(marchDir);
    raymarch(marchDir,-1.,stdRes);
    dist+=distToViewer;
    
    updateLocalData(path,sampletv,currentMat, outside);//do not change materials, just update the path data.
        
    //if we are totally internally reflecting; keep going
    path.keepGoing=needTIR(path,currentMat,outside);
    numReflect+=1;
    }
    
    return dist;
    
}


//starting at the outside of a transparent surface, refract into it, bounce around via TIR if required, and stop when you reach the backside, with nonunity reflectivity.
void doRefract(inout Path path, inout newMaterial currentMat, newMaterial outside){
    float dist=0.;

    //refract through surface, and march to the next intersection point
    Vector marchDir=path.dat.refractedRay;
    nudge(marchDir);
    raymarch(marchDir,-1.,stdRes);//we are inside an object.
    
    dist+=distToViewer;//dist traveled inside ball
    //material has not changed: so do not update material
    updateLocalData(path,sampletv,currentMat,outside);
    
    //check if we have to continue totalfly reflecting internally
    path.keepGoing=needTIR(path,currentMat,outside);
    dist+=doTIR(path,currentMat,outside);
    
    //at the end here, update the distance traveled, and the accumulated color;
    updateAccColor(path,currentMat, dist);
    path.acc.dist+=dist;
    //how do we deal with the change in intensity correctly here?
    
    //should be set up for beamsplit now
}



//----------------------------------------------------------------------------------------------------------------------
// Color from a surface
//----------------------------------------------------------------------------------------------------------------------

//get the color at the surface location given by localData, weighted by the intensity of light left at this point
//then update the intensity remaining
//======old version 
//vec3 getSurfaceColor(localData data, Material mat, Volume objVol,bool marchShadow){
//    
//    
//    if(mat.lightThis==0){//hit the background
//        return data.intensity*mat.color;//weight by amount of surviving light and get out
//    }
//    
//    
//    vec3 amb;//ambient lighting
//    vec3 scn;//lights in scene
//    vec3 totalColor;
//    
//
//    //else
//    amb=ambLights(data, mat,marchShadow);
//    scn=sceneLights(data, mat, marchShadow);//add lights
//    
//    totalColor=amb+scn;
//    
//    //data.intensity is how much light was left at this stage.
//    //mat.reflect is reflectivity of surface.
//    //objVol.opacity is the opacity of the object we struck
//   
//    totalColor*=data.intensity*(1.-mat.reflect)*objVol.opacity;
//    return totalColor;
//    
//}













//----------------------------------------------------------------------------------------------------------------------
// Iterative Reflections
//----------------------------------------------------------------------------------------------------------------------

//start where you are, and reflect around picking up colors
//stop when you hit a transparent object, or when you run out of light intensity, hit max reflections.
//======old version
//vec3 getOpaqueReflect(inout localData data,Material mat, inout Volume objVol,inout bool keepGoing){
//    int numRefl=0;
//    //Volume objVol;
//    Volume airVol;
//    
//    vec3 reflColor;
//    vec3 totalColor=vec3(0.);
//    
//    int MAX_REFL=10;
//    keepGoing=false;
//    //objVol.opacity==1.&&
//    while(data.intensity>0.005&&numRefl<MAX_REFL){
//        
//        if(hitWhich==0){break;}//if your last pass hit the sky, stop.
//        
//        //if not, do a reflection.
//        nudge(data.reflectedRay);//move the ray a little
//        raymarch(data.reflectedRay,1.,reflRes);//do the reflection march
//        setParameters(sampletv,data,mat,airVol,objVol);
//        
//        if(objVol.opacity!=1.){
//            keepGoing=true;
//            break;}//get out of loop if you should transmit light as well as reflect at the next step.
//        
//        totalColor+=getSurfaceColor(data, mat,objVol,true);
//        updateReflectIntensity(data,mat);
//        
//        numRefl+=1;
//    }
//    
//    return totalColor;
//}
////returns a color: final position of objVol, mat, data is set up right at the surface of a transparent object whose (need to pick up surface, color, as well as reflect and refract color next.)


//======new version
vec3 getReflect(inout Path path, inout newMaterial mat, newMaterial outside){
    //start with path at a location you just arrived at, and HAVE NOT PICKED UP ANY COLOR YET.
    //first determine if the surface is reflective:
    int numRefl=0;
    float dist=0.;
    vec3 totalColor=vec3(0.);

    path.keepGoing=(mat.vol.opacity==1.);
    
     while(path.keepGoing&&numRefl<10){//we do absolutely NOTHING if the surface is transparent!
    
         //otherwise, we add the color from this surface
        totalColor+=getSurfaceColor(path,mat,true);
        updateReflectIntensity(path);
        
        //then we reflect off of it, and continue on our way
        nudge(path.dat.reflectedRay);//move the ray a little
        raymarch(path.dat.reflectedRay,1.,reflRes);//do the reflection 
        updateNewMaterial(mat,sampletv, hitWhich);//set material to what was just impacted
        updateLocalData(path,sampletv,outside,mat);//update the local data accordingly
        
        //make keep going true if you hit an opaque object, and its not the sky
        path.keepGoing=(mat.vol.opacity==1.&&hitWhich!=0);
        numRefl+=1;
    }

    
    //update distance traveled along path
    //update color absorbed
    //what to do about intensity? (Nothing because taken care of by color multiplier?)
    path.acc.dist+=dist;
    updateAccColor(path, outside, dist);
    
   // path.acc.color*totalColor;
    return totalColor;
    
}






//
//
////====old, will be replaced by beamsplit
//vec3 getTransmitIterate(inout localData data, inout vec3 colorMultiplier, inout Material mat, inout Volume objVol, inout Volume airVol,inout bool keepGoing){
//    
//int numRefract=0;
//vec3 totalColor=vec3(0.);
//localData reflData;
//float refractDist;
//
//    
//while(objVol.opacity<1.&&numRefract<10){
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
//    //add the contribution of the next surface's color.
//   totalColor+=colorMultiplier*getSurfaceColor(reflData,mat,objVol,true);
//    
//    //add the resulting color by bouncing around the reflected component
//    
//        totalColor+=colorMultiplier*getOpaqueReflect(reflData,mat,objVol,keepGoing);
//    //this resets keepGoing to be true if the final surface is transparent.
//    numRefract+=1;
//
//}
//
//if(keepGoing){
//    data=reflData;
//}
//   return totalColor; 
//
//}
////returns a color.  When process terminates, you have either run out of iterates, or impacted an opaque object (where you got its surface color, and its reflectivity - so you should be good?!)
////GUESS THE WORRY CASE IS AFTER DOING THESE OPAQUE REFLECT FUNCTIONS, YOU END UP HITTING SOMEMTHING TRANSPARENT YOU NEED TO THEN MARCH THROUGH?
//
//
//
//



