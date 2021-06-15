
//----------------------------------------------------------------------------------------------------------------------
// Struct Surface Data
//----------------------------------------------------------------------------------------------------------------------


//Local geometric data at a point on the surface.
struct localData{

    Vector incident;
    Vector toViewer;
    Point pos;
    Vector normal;
    Vector reflectedRay;
    Vector refractedRay;
    float side;//inside or outside an object
    float reflect;//reflectivity of the surface we are currently at.
    vec3 absorb;//absorbtion of the material we are currently inside of
    bool hitSky;//did we hit the sky?
    Material frontMat;
    Material backMat;
};


//store data as we move along a path in the raymarch:
//instead of just tracking the tangent vector, we can keep one of these objects in tow;
struct Path{
    localData dat;

    float intensity;
    float dist;
    vec3 accColor;
    vec3 lightColor;

    bool keepGoing;//do we kill this ray?
};


void initializePath(inout Path path){
    path.dat.hitSky=false;
    path.dat.frontMat=air;
    path.dat.backMat=air;
    path.dat.absorb=vec3(0);

    //set the initial data
    path.intensity=1.;
    path.dist=0.;
    path.accColor=vec3(1.);
    path.lightColor=vec3(1.);
    path.keepGoing=true;
}























//----------------------------------------------------------------------------------------------------------------------
// Copying and Updating
//----------------------------------------------------------------------------------------------------------------------



//calculate the reflectivity of a surface, with fresnel reflection
void updateReflect(inout localData dat){

    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    float n1=dat.backMat.refract;
    float n2=dat.frontMat.refract;

    //what is the bigger reflectivity between the two surfaces at the interface?
    float refl=max(dat.backMat.reflect, dat.frontMat.reflect);

    // Schlick aproximation
    float r0 = (n1-n2) / (n1+n2);
    r0 *= r0;
    float cosX = -dot(dat.normal.dir,dat.incident.dir);
    if (n1 > n2)
    {
        float n = n1/n2;
        float sinT2 = n*n*(1.0-cosX*cosX);
        // Total internal reflection
        if (sinT2 > 1.0){
            dat.reflect= 1.;
            return;
        }
        cosX = sqrt(1.0-sinT2);
    }
    float x = 1.0-cosX;
    float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

    // adjust reflect multiplier for object reflectivity
    //
    dat.reflect= (refl + (1.-refl)*ret);

}







//update the light intensity of a local data, depending on if we are continuing on for reflection or transmission
void updateReflectIntensity(inout Path path){
    //need to make sure the reflectivity has been properly updated in path
    path.intensity*=path.dat.reflect;
    //current absorbtion remains back material
    path.dat.absorb=path.dat.backMat.absorb;
}


void updateTransmitIntensity(inout Path path,Material mat){
    //need to make sure the reflectivity has been properly updated in path
    path.intensity*=(1.-path.dat.reflect)*(1.-mat.opacity);
    //we switch the absorb parameter.
    path.dat.absorb=path.dat.frontMat.absorb;
}






//copy a path for transmission through a surface,
Path copyForTransmit(Path path, Material mat){
    //make the transmission data
    Path transPath=path;
    //make this true only if the is somewhat transparent
    transPath.keepGoing=transPath.keepGoing&&(mat.opacity<1.);
    //update the intensity of the light which gets transmitted
    updateTransmitIntensity(transPath,mat);
    return transPath;
}

//copy a path for reflection through a surface
Path copyForReflect(Path path, Material mat){
    //make the reflection data
    Path reflPath=path;
    //reset keepGoing to tell us if reflectivity>0
    reflPath.keepGoing=reflPath.keepGoing&&(reflPath.dat.reflect>0.);
    //keep only the amount of intensity which gets reflected.
    updateReflectIntensity(reflPath);
    return reflPath;
}









//----------------------------------------------------------------------------------------------------------------------
// Update Data
//----------------------------------------------------------------------------------------------------------------------


void accumulateAlongPath(inout Path path,float dist){
    path.dist+=dist;
    path.accColor *= exp(-path.dat.absorb*dist);
}

//====new function to update the local data: reflection refraction etc AND THE MATERIALS
//tv is current location;
//dist is the distance traveled to reach here;
void updatePath(inout Path path, Vector tv,float dist,bool isSky){

    //update the accumulation parameters:
    //using data from previous journey
    accumulateAlongPath(path,dist);

    if(isSky){//if we hit the sky; kill the path
        path.dat.hitSky=true;
        setSkyMaterial(path.dat.frontMat,tv);
        setSkyMaterial(path.dat.backMat,tv);
        return;
    }

    path.dat.incident=tv;
    path.dat.toViewer=turnAround(tv);
    path.dat.pos=tv.pos;
    //dat.normal was already set by SDF

    //this is enough to set the reflected ray direction
    path.dat.reflectedRay=reflectOff(tv,path.dat.normal);

    //set refracted ray using the old and new material;
    path.dat.refractedRay=refractThrough(tv,path.dat.normal,path.dat.backMat.refract,path.dat.frontMat.refract);

    //update the reflectivity float in the local data: this tells us how much needs to be reflected at this given point!
    updateReflect(path.dat);

}