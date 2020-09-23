//----------------------------------------------------------------------------------------------------------------------
// Refracting Inside a Transparent Material
//----------------------------------------------------------------------------------------------------------------------


float doTIR(inout Path path){
    float dist=0.;
    int numReflect=-1;
    Vector marchDir;
    
    //path.mat is the material we are inside of (glass)
    //path.transmat is whatever is outside of it
    
    while(path.keepGoing&&numReflect<10){
    marchDir=path.dat.reflectedRay;
    nudge(marchDir);
    raymarch(marchDir,reflRes);
    dist+=distToViewer;
    
    updatePath(path,sampletv);
    //now set the material we are inside of back to the reflecting one
    path.mat=path.backMat;
        
    //if we are totally internally reflecting; keep going
    path.keepGoing=needTIR(path);
    numReflect+=1;
    }
    
    return dist;
    
}


//starting at the outside of a transparent surface, refract into it, bounce around via TIR if required, and stop when you reach the backside, with nonunity reflectivity.
void doRefract(inout Path path){
    float dist=0.;

    //refract through surface, and march to the next intersection point
    Vector marchDir=path.dat.refractedRay;
    nudge(marchDir);
    raymarch(marchDir,stdRes);//we are inside an object.
    dist+=distToViewer;//dist traveled inside ball
    
    //now we are at the back wall
    updatePath(path,sampletv);
    //frontMat=outside, backMat=inside
    path.mat=path.backMat;
    
    //check if we have to continue totally reflecting internally
    path.keepGoing=needTIR(path);
    dist+=doTIR(path);
    
    //at the end here, update the distance traveled, and the accumulated color;
    updateAccColor(path, dist);
    path.acc.dist+=dist;
    //how do we deal with the change in intensity correctly here?
    
    //should be set up for beamsplit now
}










//----------------------------------------------------------------------------------------------------------------------
// Reflecting through Air, hitting opaque materials.
//----------------------------------------------------------------------------------------------------------------------



vec3 getReflect(inout Path path){
    //start with path at a location you just arrived at, and HAVE NOT PICKED UP ANY COLOR YET.
    
    //set the material you care about to be the one in front of you
    path.mat=path.frontMat;
    
    int numRefl=0;
    float dist=0.;
    vec3 totalColor=vec3(0.);

    //we keep going if the material in front of us is not transparent
    path.keepGoing=(path.mat.vol.opacity==1.);
    
     while(path.keepGoing&&numRefl<3){
         
         //otherwise, we add the color from this surface
        totalColor+=getSurfaceColor(path,true);
        updateReflectIntensity(path);
        
        //then we reflect off of it, and continue on our way
        nudge(path.dat.reflectedRay);//move the ray a little
        raymarch(path.dat.reflectedRay,reflRes);//do the reflection 
       
        //update the material to the new location
        updatePath(path,sampletv);
        path.mat=path.frontMat;//we care about what's in front of us
        
        //make keep going true if you hit an opaque object, and its not the sky
        path.keepGoing=(path.keepGoing&&path.mat.vol.opacity==1.);
        numRefl+=1;
    }

    
    //update distance traveled along path
    //update color absorbed
    //what to do about intensity? (Nothing because taken care of by color multiplier?)
    path.acc.dist+=dist;
    
    //need to think about how this should work!
    //updateAccColor(path, dist);
    
    //and then make this work accordingly
   // path.acc.color*totalColor;
    return totalColor;
    
}









