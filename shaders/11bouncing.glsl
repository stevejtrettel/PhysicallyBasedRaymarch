//----------------------------------------------------------------------------------------------------------------------
// Refracting Inside a Transparent Material
//----------------------------------------------------------------------------------------------------------------------


float doTIR(inout Path path, inout Material currentMat, Material outside){
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
void doRefract(inout Path path, inout Material currentMat, Material outside){
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
// Reflecting through Air, hitting opaque materials.
//----------------------------------------------------------------------------------------------------------------------



vec3 getReflect(inout Path path, inout Material mat, Material outside){
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









