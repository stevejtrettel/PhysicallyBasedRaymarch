

//----------------------------------------------------------------------------------------------------------------------
// Coloring functions
//----------------------------------------------------------------------------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(v.x,2.);
    float y=mod(v.y,2.);
    
    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(0.7);
    }
    else return vec3(0.2);
}




vec2 toSphCoords(vec3 v){
float theta=atan(v.y,v.x);
float phi=acos(v.z);
return vec2(theta,phi);
}

vec3 rectTex(Vector tv){

vec2 angles=toSphCoords(tv.dir);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

return texture(tex,vec2(x,y)).rgb;

}





vec3 skyTexture(Vector tv){

    // vec3 color = vec3(0.5,0.5,0.5);
    vec3 color = texture(earthCubeTex, tv.dir.yzx).rgb;
return color;
}


//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------


//====update the material given a position and what you hit.
void updateMaterial(inout Material mat, Vector sampletv,float ep){

    //set hitWhich using our current location, to be the material directly in front of us in the direction of raymarching.
    setHitWhich(sampletv,ep);
    
    //now, set all of the material properties in terms of this result.
     switch(hitWhich){
             
        case 0://sky
            mat=air;
            mat.bkgnd=true;
            mat.surf.color=SRGBToLinear(rectTex(sampletv));
            mat.vol.absorb=vec3(0.);
            break;
        
             
         case 3://glass
            mat.bkgnd=false;
             
            mat.surf.color=vec3(0.05);
            mat.surf.phong.shiny=15.;
            mat.surf.reflect=0.02;
            
            mat.vol.refract=1.55;
            mat.vol.opacity=0.05;
            mat.vol.absorb=vec3(0.3,0.05,0.2);
            mat.vol.emit=vec3(0.);

            break;

             
        case 4://mirror
            mat.bkgnd=false;
             
            mat.surf.color=vec3(0.03,0.05,0.2);
            mat.surf.reflect=0.95;
            mat.surf.phong.shiny=15.;
             
             
            mat.vol.opacity=1.;
            mat.vol.refract=1.25;
            mat.vol.absorb=vec3(0.);
            mat.vol.emit=vec3(0.);

            break;

        
    }
    
}



//----------------------------------------------------------------------------------------------------------------------
// Getting Normals, Reflectivities, etc.
//----------------------------------------------------------------------------------------------------------------------

Vector getSurfaceNormal(Point p){
    float ep=5.*EPSILON;
    vec3 bx = vec3(1.,0.,0.);
    vec3 by = vec3(0.,1.,0.);
    vec3 bz  = vec3(0.,0.,1.);
    
    float dx=sceneSDF(shiftPoint(p,bx,ep))-sceneSDF(shiftPoint(p,bx,-ep));
    float dy=sceneSDF(shiftPoint(p,by,ep))-sceneSDF(shiftPoint(p,by,-ep));
    float dz=sceneSDF(shiftPoint(p,bz,ep))-sceneSDF(shiftPoint(p,bz,-ep));
    
    vec3 n=dx*bx+dy*by+dz*bz;
    
    Vector normal=Vector(p,n);

    return tangNormalize(normal);

    
}

Vector getSurfaceNormal(Vector tv){
    Point p=tv.pos;
    return getSurfaceNormal(p);
}







//decide if we are totally internally reflecting
bool needTIR(Path path){
    
    //path.mat or path.reflMat are the side we are on
    //path.transMat is the other side
    float n1=path.backMat.vol.refract;
    float n2=path.frontMat.vol.refract;
    
    float cosX = -dot(path.dat.normal.dir,path.dat.incident.dir);
    float n = n1/n2;
    float sinT2 = n*n*(1.0-cosX*cosX);
    
            if (abs(sinT2) > 1.0 ){
                return true;
            }
    else{return false;}
}






//----------------------------------------------------------------------------------------------------------------------
// Update Data
//----------------------------------------------------------------------------------------------------------------------



//calculate the reflectivity of a surface, with fresnel reflection
void updateReflect(inout Path path){
    
    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    float n1=path.backMat.vol.refract;
    float n2=path.frontMat.vol.refract;
    
    //what is the bigger reflectivity between the two surfaces at the interface?
    float refl=max(path.backMat.surf.reflect, path.frontMat.surf.reflect);

        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(path.dat.normal.dir,path.dat.incident.dir);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (sinT2 > 1.0){
               path.dat.reflect= 1.;
                return;
            }
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

        // adjust reflect multiplier for object reflectivity
        //
        path.dat.reflect= (refl + (1.-refl)*ret);
    
}








//======new version==========
void updateAccColor(inout Path path, Material mat, float dist){
    path.acc.color *= exp(-mat.vol.absorb*dist);
}


//update the light intensity of a local data, depending on if we are continuing on for reflection or transmission
void updateReflectIntensity(inout Path path){
    //need to make sure the reflectivity has been properly updated in path
    path.acc.intensity*=path.dat.reflect;
}


void updateTransmitIntensity(inout Path path,Material mat){
    //need to make sure the reflectivity has been properly updated in path
    path.acc.intensity*=(1.-path.dat.reflect)*(1.-mat.vol.opacity);
}








//====new function to update the local data: reflection refraction etc AND THE MATERIALS
void updatePath(inout Path path, Vector tv,bool isSky){
    
    if(isSky){
        path.keepGoing=false;
        updateMaterial(path.backMat,tv,-0.01);
        path.frontMat=path.backMat;
        return;
    }
    
    updateMaterial(path.backMat,tv,-0.01);
    updateMaterial(path.frontMat,tv,0.01);
    
//    if(path.frontMat.bkgnd){//hit the sky
//    path.keepGoing=false;
//    return;
//    }
    
    //update all of our local tangent vector data based on this location.
    path.dat.incident=tv;
    path.dat.toViewer=turnAround(tv);
    path.dat.pos=tv.pos;
    
    Vector normal=getSurfaceNormal(tv);
    float side=-sign(tangDot(tv,normal));
    
    //make inward pointing normal if we are on the inside
    if(side==-1.){normal=turnAround(normal);}
    path.dat.normal=normal;
    path.dat.side=side;
    
    //this is enough to set the reflected ray direction
    path.dat.reflectedRay=reflectOff(tv,normal);
    

    //set refracted ray using the old and new material;
    float currentR=path.backMat.vol.refract;
    float otherSideR=path.frontMat.vol.refract;
    path.dat.refractedRay=refractThrough(tv,normal,currentR,otherSideR);
    
    //update the reflectivity float in the local data: this tells us how much needs to be reflected at this given point!
    updateReflect(path);
    
}



