

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






//
vec3 cubeTexture(Vector tv){
    // vec3 color = vec3(0.5,0.5,0.5);
    vec3 color = texture(earthCubeTex, tv.dir.yzx).rgb;
return color;
}


vec3 skyTex(Vector tv){

vec2 angles=toSphCoords(tv.dir);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

return texture(tex,vec2(x,y)).rgb;

}

//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------

void setSkyMaterial(inout Material mat, Vector tv){
            mat=air;
            mat.bkgnd=true;
            mat.vol.opacity=1.;
            mat.surf.color=SRGBToLinear(skyTex(sampletv));
            mat.vol.absorb=vec3(0.);
}


//====update the material given a position and what you hit.
void updateMaterial(inout Material mat, Vector sampletv,float ep){

    //set hitWhich using our current location, to be the material directly in front of us in the direction of raymarching.
    setHitWhich(sampletv,ep);
    
    //now, set all of the material properties in terms of this result.
     switch(hitWhich){
             
        case 0://sky
            setSkyMaterial(mat, sampletv);
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









//----------------------------------------------------------------------------------------------------------------------
// Update Data
//----------------------------------------------------------------------------------------------------------------------



//calculate the reflectivity of a surface, with fresnel reflection
void updateReflect(inout localData dat, Material back, Material front){
    
    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    float n1=back.vol.refract;
    float n2=front.vol.refract;
    
    //what is the bigger reflectivity between the two surfaces at the interface?
    float refl=max(back.surf.reflect, front.surf.reflect);

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





void updateLocalData(inout localData dat, Vector tv, Material back,Material front){
    //update local data depending on the location tv;
    //update the refraction direction also using material in front and behind
      
    dat.incident=tv;
    dat.toViewer=turnAround(tv);
    dat.pos=tv.pos;
    
    Vector normal=getSurfaceNormal(tv);
    float side=-sign(tangDot(tv,normal));
    
    //make inward pointing normal if we are on the inside
    if(side==-1.){normal=turnAround(normal);}
    dat.normal=normal;
    dat.side=side;
    
    //this is enough to set the reflected ray direction
    dat.reflectedRay=reflectOff(tv,normal);
    

    //set refracted ray using the old and new material;
    dat.refractedRay=refractThrough(tv,normal,back.vol.refract,front.vol.refract);
    
    //update the reflectivity float in the local data: this tells us how much needs to be reflected at this given point!
    updateReflect(dat, back, front);

}





//====new function to update the local data: reflection refraction etc AND THE MATERIALS
void updatePath(inout Path path, Vector tv,bool isSky){
    
    if(isSky){//if we hit the sky; kill the path
        path.hitSky=true;
        setSkyMaterial(path.frontMat,tv);
        setSkyMaterial(path.backMat,tv);
        return;
    }
    
    //otherwise, sample the material in front and behind
    updateMaterial(path.backMat,tv,-0.01);
    updateMaterial(path.frontMat,tv,0.01);
    
    //update the direction vectors, and reflectivity
    updateLocalData(path.dat,tv,path.backMat,path.frontMat);
    
}
