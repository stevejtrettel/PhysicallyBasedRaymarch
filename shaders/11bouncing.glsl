

void stepForward(Vector direction, inout Path path,float side,marchRes res){
    
    if(path.keepGoing){//if we arent supposed to keep going, do nothing
        
    //so instead, we just focus on following the refracted ray.
    nudge(direction);//move the ray a little
    raymarch(direction,side,res);//going outside the material
    updatePath(path,sampletv,isSky);//update the local data accordingly
    
    //update the distance travelled:
    path.acc.dist+=distToViewer;
    //path.backMat=material we just marched through
    //use this to update the accumulated color
    updateAccColor(path, path.backMat,distToViewer);
    }
}





//----------------------------------------------------------------------------------------------------------------------
// Refracting Inside a Transparent Material
//----------------------------------------------------------------------------------------------------------------------


void doTIR(inout Path path){
    //float dist=0.;
    int numReflect=-1;
    Vector marchDir;
    
    while(path.dat.reflect==1.&&numReflect<10){
        
    marchDir=path.dat.reflectedRay;
    stepForward(marchDir,path,-1.,reflRes);  
    //stepping forward resets path reflectivity, taking Fresnel into account
    //thus, if TIR is in effect, path.dat.reflect=1 will hold
    numReflect+=1;
    }

}


//bounce around via internal reflections until the reflectivity is below some threshhold:
void doInternalReflect(inout Path path,float thresh){
    
    int numReflect=-1;
    Vector marchDir;
    
    while(path.dat.reflect>thresh&&numReflect<10){
        
    marchDir=path.dat.reflectedRay;
    stepForward(marchDir,path,-1.,reflRes);  
    //stepping forward resets path reflectivity, taking Fresnel into account
    numReflect+=1;
    }

}



//starting at the outside of a transparent surface, refract into it, bounce around via TIR if required, and stop when you reach the backside, with nonunity reflectivity.
void doRefract(inout Path path){
    
    //refract through surface, and march to the next intersection point
    Vector marchDir=path.dat.refractedRay; 
    stepForward(marchDir,path,-1.,stdRes);
    
    //check if we have to continue totally reflecting internally
    //path.keepGoing=needTIR(path);
    doTIR(path);//do the actual internal reflections
    
    //nothing here has changed intensity, so don't update path.keepGoing
}



vec3 getRefract(inout Path path){
    
    Vector marchDir;
    vec3 totalColor;
    //refract through surface, and march to the next intersection point
    marchDir=path.dat.refractedRay; 
    stepForward(marchDir,path,-1.,stdRes);
    
    doTIR(path);//do the actual internal reflections
    
    //now we are positioned at the back wall of the surface, and the internal reflectivity is no longer 1
    
    //split the light: refract thru surface, pick up color
//    Path refractPath=path;
//    marchDir=path.dat.refractedRay;
//    stepForward(marchDir,refractPath,1.,stdRes);
//    refractPath.mat=refractPath.frontMat;
//    //get the color of the surface here:
//    totalColor+=(1.-path.dat.reflect)*getSurfaceColor(refractPath,false);
//   
//    //totalColor+=path.dat.reflect*vec3(1.,0.,0.);
//    //now want to instead reflect again on the inside to pick up the other bit of color:
//    Path reflectPath=path;
//    doInternalReflect(reflectPath,0.8);
//    //now, get refracted color AND color the rest with "sky color"
//    marchDir=reflectPath.dat.refractedRay;
//    stepForward(marchDir,reflectPath,1.,stdRes);
//    reflectPath.mat=reflectPath.frontMat;
//    totalColor+=path.dat.reflect*(1.-reflectPath.dat.reflect)*getSurfaceColor(reflectPath,false);
//    totalColor+=path.dat.reflect*(1.-reflectPath.dat.reflect)*vec3(1.,0.,0.);
//    
//    
    
    return totalColor;
    
    //the pathData here is unchanged, still at the exit point;
}








//----------------------------------------------------------------------------------------------------------------------
// Reflecting through Air, hitting opaque materials.
//----------------------------------------------------------------------------------------------------------------------


//
//vec3 getReflect(inout Path path){
//    //start with path at a location you just arrived at, and HAVE NOT PICKED UP ANY COLOR YET.
//    int MAX_REFL=10;
//    int numRefl=0;
//    float dist=0.;
//    vec3 totalColor=vec3(0.);
//    
//    //set the material you care about to be the one in front of you
//    
//    path.mat=path.frontMat;
//    totalColor+=getSurfaceColor(path,true);//get the color of the surface
//    
//    
//    //THIS LINE WAS CAUSING THE MAIN PROBLEM
//    //updateReflectIntensity(path);
//    //then continue;
//
//    //we keep going if the material in front of us is not transparent
//     bool keepGoing=(path.keepGoing&&path.mat.vol.opacity==1.);
//    
//     while(keepGoing&&numRefl<MAX_REFL){
//         
//     
//        stepForward(path.dat.reflectedRay,path,1.,reflRes);
//        path.mat=path.frontMat;//we care about what's in front of us
//         
//        //make keep going true if you hit an opaque object, and its not the sky
//        keepGoing=(path.keepGoing&&path.mat.vol.opacity==1.&&path.acc.intensity>0.05);
//        numRefl+=1;
//         
//        //add the color from this surface
//            totalColor+=getSurfaceColor(path,true);
//        updateReflectIntensity(path);
//         
//
//    }
//
//    //reset path.keepGoing to quit if we did all 10 steps, or if the intensity is very low.
//    path.keepGoing=path.keepGoing&&(numRefl<MAX_REFL)&&(path.acc.intensity>0.05);
//
//    return totalColor;
//    
//}
//




vec3 getReflect2(inout Path path,Vector initialDir){
    //start on a surface, where you have already grabbed the surface color (this surface may be partially transparent)
    int MAX_REFL=10;
    int numRefl=0;
    vec3 totalColor=vec3(0.);
    
    //march in initial direction from surface
    stepForward(initialDir,path,1.,reflRes);
    
    //we keep going if the material in front of us is not transparent
    //or if it is the sky, cuz we need to add the sky color
     bool keepGoing=path.keepGoing&&(path.hitSky||path.mat.vol.opacity==1.);
    
     while(keepGoing&&numRefl<MAX_REFL){
        
        //pick up the color
        path.mat=path.frontMat;
        totalColor+=getSurfaceColor(path,true);
        updateReflectIntensity(path);
         
         //reflect off the surface
        stepForward(path.dat.reflectedRay,path,1.,reflRes);
        
        //keep going if (1) not sky, and (2)object is opaque and (3)there's sufficient intensity to bother.
        keepGoing=(path.keepGoing&&path.mat.vol.opacity==1.);
                   //&&path.acc.intensity>0.05)
        numRefl+=1;
    }
    
    //reset path.keepGoing to quit if we did all 10 steps, or if the intensity is very low.
   // path.keepGoing=path.keepGoing&&(numRefl<MAX_REFL)&&(path.acc.intensity>0.05);
    
//    if(!path.keepGoing){//if we hit the sky on our last pass through
//        totalColor+=getSurfaceColor(path,false);//sky
//    }


    return totalColor;
    
}



