
//----------------------------------------------------------------------------------------------------------------------
// TotalInternalRefraction
//----------------------------------------------------------------------------------------------------------------------


//bounce around inside of an object until total internal refraction stops.  then you are at the surface of the object, and some of your ray will reflect and some will refract.
float refract(inout localData data, Volume inside, Volume outside){
    float dist=0.;
    bool totalReflect;
    int numReflect=-1;
    
    
    //first refract through the surface and hit an inside wall
    nudge(data.refractedRay);
    raymarch(data.refractedRay,-1.,stdRes);
    //we are refracting on the inside of an object.
    dist+=distToViewer;//dist traveled inside ball
    setLocalData(data,sampletv,inside,outside);
    
    //check if we have to continue totally reflecting internally
    totalReflect=TIR(data,inside,outside);
    
    while(totalReflect&&numReflect<10){
    nudge(data.reflectedRay);
    raymarch(data.reflectedRay,-1.,stdRes);
    //we are refracting on the inside of an object.
    dist+=distToViewer;
    
    setLocalData(data,sampletv,inside,outside);
    //if we are totally internally reflecting; keep going
    totalReflect=TIR(data,inside,outside);
    numReflect+=1;
    }
    
    
    //dist is the total distance traveled inside the material
    return dist;

   //when it leaves, local Data has been set to the parameters at the final intersection with the surface so we can start picking up colors again. 
}

float doTIR(inout localData data, Volume inside, Volume outside){
    float dist=0.;
    bool totalReflect=true;
    int numReflect=-1;
    
    while(totalReflect&&numReflect<10){
    nudge(data.reflectedRay);
    raymarch(data.reflectedRay,-1.,stdRes);
    //we are refracting on the inside of an object.
    dist+=distToViewer;
    
    setLocalData(data,sampletv,inside,outside);
    //if we are totally internally reflecting; keep going
    totalReflect=TIR(data,inside,outside);
    numReflect+=1;
    }
    
    
    //dist is the total distance traveled inside the material
    return dist;

   //when it leaves, local Data has been set to the parameters at the final intersection with the surface so we can start picking up colors again. 
}



//----------------------------------------------------------------------------------------------------------------------
// Color from a surface
//----------------------------------------------------------------------------------------------------------------------

//get the color at the surface location given by localData, weighted by the intensity of light left at this point
//then update the intensity remaining
vec3 getSurfaceColor(localData data, Material mat, Volume objVol,bool marchShadow){
    
    
    if(mat.lightThis==0){//hit the background
        return data.intensity*mat.color;//weight by amount of surviving light and get out
    }
    
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    vec3 totalColor;
    

    //else
    amb=ambLights(data, mat,marchShadow);
    scn=sceneLights(data, mat, marchShadow);//add lights
    
    totalColor=amb+scn;
    
    //data.intensity is how much light was left at this stage.
    //mat.reflect is reflectivity of surface.
    //objVol.opacity is the opacity of the object we struck
   
    totalColor*=data.intensity*(1.-mat.reflect)*objVol.opacity;
    return totalColor;
    
}




//----------------------------------------------------------------------------------------------------------------------
// Update Available Light
//----------------------------------------------------------------------------------------------------------------------


//after marching through volume "vol" for distance "dist", update the color multiplier you use on colors.
//this does NOT change the intensity in local data (the decrease is accounted for in "color")
void updateColorMultiplier(inout vec3 color,Volume vol,float dist){
    vec3 absorb=exp(vol.absorb*dist);
    color*=absorb;
    
}

//update the light intensity of a local data, depending on if we are continuing on for reflection or transmission
void updateReflectIntensity(inout localData data, Material mat){
    data.intensity*=mat.reflect;
    //amt left is determiend by reflectivity
}

void updateTransmitIntensity(inout localData data, Material mat, Volume entering){
    data.intensity*=(1.-mat.reflect)*(1.-entering.opacity);
    
}









//----------------------------------------------------------------------------------------------------------------------
// Iterative Reflections
//----------------------------------------------------------------------------------------------------------------------

//start where you are, and reflect around picking up colors
//stop when you hit a transparent object, or when you run out of light intensity, hit max reflections.
vec3 getOpaqueReflect(inout localData data,Material mat){
    int numRefl=0;
    Volume objVol;
    Volume airVol;
    
    //orig object is opaque
    objVol.opacity=1.;
    
    vec3 reflColor;
    vec3 totalColor=vec3(0.);
    
    
    //objVol.opacity==1.&&
    while(data.intensity>0.005&&numRefl<5){
        
        if(hitWhich==0){break;}//if your last pass hit the sky, stop.
        
        //if not, do a reflection.
        nudge(data.reflectedRay);//move the ray a little
        raymarch(data.reflectedRay,1.,reflRes);//do the reflection march
        setParameters(sampletv,data,mat,airVol,objVol);
        totalColor+=getSurfaceColor(data, mat,objVol,true);
        
        updateReflectIntensity(data,mat);
        
        numRefl+=1;
    }
    
    return totalColor;
}


vec3 getTransmitIterate(inout localData data, inout vec3 colorMultiplier, inout Material mat, inout Volume objVol, inout Volume airVol){
    
int numRefract=0;
vec3 totalColor=vec3(0.);
localData reflData;
float refractDist;
    
while(objVol.opacity<1.&&numRefract<7){
    
            //do the refractions, record distance travelled
        refractDist=refract(data,objVol,airVol);
        updateColorMultiplier(colorMultiplier,objVol,refractDist);
        
        //we are at the back wall of the object now: time to reset the data
        setParameters(sampletv,data,mat,objVol,airVol); 
        //continue forwards out the back
        updateTransmitIntensity(data,mat,objVol);
    
        //SHOULD ALSO CALCULATE THE REFLECTED RAY WHICH STAYS INSIDE THE GLASS HERE
       
        //now, refract out the backside!
        nudge(data.refractedRay);
        raymarch(data.refractedRay,1.,stdRes);
        //reset the parameters based on our new location
        setParameters(sampletv,data,mat,airVol,objVol); 
        
    reflData=data;//get the surface color and start bouncing around
    
        //add the resulting color by bouncing around
   totalColor+=colorMultiplier*getSurfaceColor(reflData,mat,objVol,true);
        totalColor+=colorMultiplier*getOpaqueReflect(reflData,mat);
    numRefract+=1;

}
    
   return totalColor; 

}