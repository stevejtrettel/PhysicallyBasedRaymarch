

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




vec3 skyTex(Vector tv){

vec2 angles=toSphCoords(tv.dir);
float x=(angles.x+3.1415)/(2.*3.1415);
float y=1.-angles.y/3.1415;

    //the vec00 are the derivative mappings: get rid of seam!
return textureGrad(tex,vec2(x,y),vec2(0,0),vec2(0,0)).rgb;

}

//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------

void setSkyMaterial(inout Material mat, Vector tv){
            mat=air;
            //mat.surf.opacity=0.;
            mat.color=SRGBToLinear(skyTex(sampletv));
            mat.absorb=vec3(0.);
}

Material setGlass(){
    Material mat;
    
            mat.color=vec3(0.05);
            mat.phong.shiny=15.;
            mat.reflect=0.08;
            mat.opacity=0.05;
            
            mat.refract=1.53;
            mat.disperse=vec3(1.51,1.52,1.53);
            mat.translucent=0.;
            mat.absorb=vec3(0.3,0.05,0.2);
            mat.emit=vec3(0.);
    return mat;
    
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
            mat=setGlass();
            break;

        case 4:
         mat==setGlass();
         break;

        case 5://diamond
            mat=setGlass();
            break;

        
    }
    
}









//----------------------------------------------------------------------------------------------------------------------
// Update Data
//----------------------------------------------------------------------------------------------------------------------



//calculate the reflectivity of a surface, with fresnel reflection
void updateReflect(inout localData dat, Material back, Material front){
    
    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    float n1=back.refract;
    float n2=front.refract;
    
    //what is the bigger reflectivity between the two surfaces at the interface?
    float refl=max(back.reflect, front.reflect);

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
}


void updateTransmitIntensity(inout Path path,Material mat){
    //need to make sure the reflectivity has been properly updated in path
    path.intensity*=(1.-path.dat.reflect)*(1.-mat.opacity);
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
    dat.refractedRay=refractThrough(tv,normal,back.refract,front.refract);
    
    //update the reflectivity float in the local data: this tells us how much needs to be reflected at this given point!
    updateReflect(dat, back, front);

}





//====new function to update the local data: reflection refraction etc AND THE MATERIALS
//tv is current location;
//dist is the distance traveled to reach here;
void updatePath(inout Path path, Vector tv,float dist,bool isSky){
    
    if(isSky){//if we hit the sky; kill the path
        path.dat.hitSky=true;
        setSkyMaterial(path.dat.frontMat,tv);
        setSkyMaterial(path.dat.backMat,tv);
        return;
    }
    
    //otherwise, sample the material in front and behind
    updateMaterial(path.dat.backMat,tv,-0.01);
    updateMaterial(path.dat.frontMat,tv,0.01);
    
    //update the direction vectors, and reflectivity
    updateLocalData(path.dat,tv,path.dat.backMat,path.dat.frontMat);
    
    //update the accumulation parameters:
    path.dist+=dist;
    path.accColor *= exp(-path.dat.backMat.absorb*dist);
    
}
