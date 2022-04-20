

vec3 getPixelColor(Vector rayDir){

    vec3 totalColor=vec3(0.);

    //buid a path object
    Path path = initializePath(rayDir);

    //-----do the original raymarch
    stepForward(path);

    if(path.dat.inVolumetric){
        totalColor += getVolumetricColor(path);
        stepForward(path);
    }

    //should not be the volumetric material this time?
    //get the color from this new material
    totalColor += getSolidColor(path);

    if(path.dat.hitSky){
        totalColor+=vec3(1,0,0);
    }

    return totalColor;
}



