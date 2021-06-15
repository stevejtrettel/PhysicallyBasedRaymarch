
//----------------------------------------------------------------------------------------------------------------------
// Refracting Inside a Transparent Material
//----------------------------------------------------------------------------------------------------------------------


void doTIR(inout Path path){

    int numReflect=0;
    Vector marchDir;

    while(path.dat.reflect==1.&&numReflect<20){

        marchDir=path.dat.reflectedRay;
        stepForward(marchDir,path,-1.,reflRes);
        //stepping forward resets path reflectivity, taking Fresnel into account
        //thus, if TIR is in effect, path.dat.reflect=1 will hold
        numReflect+=1;
    }

    //when this stops: still inside material, at point where there is some transmission and some reflectance.
}



vec3 getInternalReflect(Path path){
    vec3 totalColor;
    //take a path, which starts inside a piece of glass where there is reflectivity but not total; and iteratively bounce around, shooting out the portions of rays which exit, and picking up color
    Path transmitPath;
    int numRefl=0;

    bool keepGoing=true;
    vec3 testColor=vec3(0.);


    while(keepGoing&&numRefl<10){
        //step forward one step along the reflection
        stepForward(path.dat.reflectedRay,path,-1.,reflRes);

        transmitPath=copyForTransmit(path,path.dat.backMat);
        //decrease remaining intensity by what is left for reflection.
        updateReflectIntensity(path);

        stepForward(transmitPath.dat.refractedRay,transmitPath,1.,reflRes);
        //now get the color
        totalColor+=getSurfaceColor(transmitPath,transmitPath.dat.frontMat,false);

        numRefl+=1;
        keepGoing=(path.dat.reflect>0.)&&(path.intensity>0.01);

    }

    //picked up color from some number of bounces, but also some light "escapes" as we cut the bouncing short.  Brighten the color to make up for that:

    return (1.+path.intensity)*totalColor;

}




vec3 getRefract(inout Path path){

    Vector marchDir;
    vec3 totalColor;
    //refract through surface, and march to the next intersection point
    marchDir=path.dat.refractedRay;
    stepForward(marchDir,path,-1.,stdRes);
    doTIR(path);//do the actual internal reflections

    //now we are positioned at the back wall of the surface, and the internal reflectivity is no longer 1

    //if there's sufficient light intensity to warrant it; keep going:
    if(path.intensity>0.1){
        //copy path for internal reflection:
        Path reflectPath=path;

        //get the color of the back surface from Phong?
        totalColor+=getSurfaceColor(path,path.dat.backMat,false);

        //update the path intensity, taking out the reflective comp
        //path.backmat is the glass we are inside of
        updateTransmitIntensity(path,path.dat.backMat);

        //update the intensity for what is available for reflection still
        updateReflectIntensity(reflectPath);
        //get color from continuing the internal bounce and sampling whats outside.
        totalColor+=getInternalReflect(reflectPath);
    }

    //if the orig intensity wasn't very strong: the internal color collection doesn't run, so this adds nothing
    return totalColor;

    //the pathData is still at the first exit point from total internal refraction
}












//----------------------------------------------------------------------------------------------------------------------
// Reflecting through Air, hitting opaque materials.
//----------------------------------------------------------------------------------------------------------------------




vec3 getReflect(inout Path path,Vector initialDir){
    //start on a surface, where you have already grabbed the surface color (this surface may be partially transparent)
    int MAX_REFL=10;
    int numRefl=0;
    vec3 totalColor=vec3(0.);

    //march in initial direction from surface
    stepForward(initialDir,path,1.,reflRes);

    //we keep going if the material in front of us is not transparent
    //or if it is the sky, cuz we need to add the sky color
    bool keepGoing=path.keepGoing&&(path.dat.hitSky||path.dat.frontMat.opacity==1.);

    while(keepGoing&&numRefl<MAX_REFL){

        //pick up the color
        totalColor+=getSurfaceColor(path,path.dat.frontMat,true);
        updateReflectIntensity(path);

        //reflect off the surface
        stepForward(path.dat.reflectedRay,path,1.,reflRes);

        //keep going if (1) not sky, and (2)object is opaque and (3)there's sufficient intensity to bother.
        keepGoing=path.keepGoing&&(!path.dat.hitSky)&&path.dat.frontMat.opacity==1.&&(path.intensity>0.01);

        numRefl+=1;
    }

    //right now, once we hit

    //reset path.keepGoing to quit if we did all 10 steps, or if the intensity is very low.
    path.keepGoing=path.keepGoing&&(numRefl<MAX_REFL)&&(path.intensity>0.05)&&(!path.dat.hitSky);


    return totalColor;

}









//start from the location stored in path: split along reflective and transmitted components, add up resulting colors.
//return both the final locations of transmitted and reflected rays, and set path to be the one with the most light left.
vec3 beamSplit(inout Path path,inout Path reflPath, inout Path transPath){




    vec3 totalColor=vec3(0.);
    Vector reflectDir;
    Vector transmitDir;


    //pick up color from path
    //return final data of dominant ray

    //picking up color
    totalColor+=getSurfaceColor(path,path.dat.frontMat,true);
    if(!path.keepGoing){return totalColor;}//stop if you are at the sky



    //make a copy of path to transmit, and to reflect:
    //we began in the air, and hit a surface, so the relevant material is path.frontMat
    reflPath=copyForReflect(path,path.dat.frontMat);
    transPath=copyForTransmit(path,path.dat.frontMat);



    if(reflPath.keepGoing){

        reflectDir=reflPath.dat.reflectedRay;
        //march in reflDir, then iteratively bounce until hitting a transparent surface.  Stop at this surface
        totalColor+=getReflect(reflPath,reflectDir);

        //update the keep going command; kill if too dim
        reflPath.keepGoing=reflPath.keepGoing&&(reflPath.intensity>0.01);

        //when this stops; reflPath has either run out of steam, or impacted a transparent surface.
    }



    if(transPath.keepGoing){
        //do the refraction through this transparent object, stop at the back side; pick up internal colors along the way
        totalColor+=getRefract(transPath);

        //march outwards in refracted direction, then iteratively reflect if need be.
        transmitDir=transPath.dat.refractedRay;
        totalColor+=getReflect(transPath,transmitDir);

        //update the keep going command
        transPath.keepGoing=transPath.keepGoing&&(transPath.intensity>0.01);

    }





    //NOW: update the original data by the larger of the remaining intensities:
    if(reflPath.intensity>transPath.intensity){
        path=reflPath;
    }
    else{
        path=transPath;
    }

    return totalColor;

}










vec3 getPixelColor(Vector rayDir){
    int numIterate=0;
    vec3 totalColor=vec3(0.);



    Path path;
    initializePath(path);//set the intensity to 1, accumulated color to 0, distance traveled to 0., set keepGoing=true, path.mat=air
    Path reflectedRay;
    Path transmittedRay;

    Path rP;//iterating reflection and transmission
    Path tP;//iterating reflection and transmission


    //-----do the original raymarch
    stepForward(rayDir,path,1.,stdRes);


    //====shorter compile time
    //====follow only the brightest initial ray
    while(path.keepGoing&&numIterate<5){    totalColor+=beamSplit(path,reflectedRay,transmittedRay);       numIterate+=1;
    }
    //


    //
    //
    //    //======== follow both initial rays: longer compile time
    //
    //
    //now we are on the surface.  lets beamSplit!
    //    totalColor+=beamSplit(path,reflectedRay,transmittedRay);
    //
    //    //now, follow each of these separately
    //    while(reflectedRay.keepGoing&&numIterate<3){
    //    totalColor+=beamSplit(reflectedRay,rP,tP);
    //        numIterate+=1;
    //    }
    //
    //    while(transmittedRay.keepGoing&&numIterate<3){
    //    totalColor+=beamSplit(transmittedRay,rP,tP);
    //        numIterate+=1;
    //    }
    //

    return totalColor;

}



