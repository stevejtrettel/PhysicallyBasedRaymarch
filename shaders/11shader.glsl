



//----------------------------------------------------------------------------------------------------------------------
// TotalInternalRefraction
//----------------------------------------------------------------------------------------------------------------------


//bounce around inside of an object until total internal refraction stops.  then you are at the surface of the object, and some of your ray will reflect and some will refract.
float refract(inout localData data, Volume inside, Volume outside){
    float dist=0.;
    bool totalReflect=true;
    int numReflect=-1;
    
    while(totalReflect&&numReflect<10){
    nudge(data.refractedRay);
    raymarch(data.refractedRay,-1.,stdRes);
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
// Color from a raymarch
//----------------------------------------------------------------------------------------------------------------------

//get the color at the surface location given by localData, weighted by the intensity of light left at this point
//then update the intensity remaining
vec3 getSurfaceColor(localData data, Material mat, Volume objVol,bool marchShadow){
    
    vec3 amb;//ambient lighting
    vec3 scn;//lights in scene
    vec3 totalColor;
    
   
    if(mat.lightThis==0){//hit the background
        totalColor=mat.color;//weight by amount of surviving light
    }
    else{
    amb=ambLights(data, mat,marchShadow);
    scn=sceneLights(data, mat, marchShadow);//add lights
    
    totalColor=amb+scn;
        
    }
    
    //data.intensity is how much light was left at this stage.
    //mat.reflect is reflectivity of surface.
    //objVol.opacity is the opacity of the object we struck
    totalColor*=data.intensity*(1.-mat.reflect)*objVol.opacity;

    return totalColor;
    
}



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
    
    vec3 colorMultiplier=vec3(1.);

    vec3 totalColor;
    
    //-----do the original raymarch
    raymarch(rayDir,1., stdRes);//start outside
    setParameters(sampletv,data,mat,airVol,objVol);  
    if(hitWhich==0){
        return mat.color;
    }
    
    //add this bit of the color to the pixel
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
        
        //again, we are at a junction where things split: reflection adn transmission:
        
        //reflData=data;//copy it again
        //updateReflectIntensity(reflData,mat);
         //get the reflections
       // totalColor+=colorMultiplier*getOpaqueReflect(reflData,mat);
        totalColor+=vec3(mat.reflect,0.,0.);
        
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
    
    return totalColor;
    
}




