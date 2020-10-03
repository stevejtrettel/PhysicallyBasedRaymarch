

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

return SRGBToLinear(texture(tex,vec2(x,y)).rgb);

}

//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------

void setSkyMaterial(inout Material mat, Vector tv){
            mat=air;
            //mat.surf.opacity=0.;
            mat.surf.color=skyTex(sampletv);
            mat.vol.absorb=vec3(0.);
}

Material setGlass(){
    Material mat;
    
            mat.surf.color=vec3(0.05);
            mat.surf.phong.shiny=15.;
            mat.surf.reflect=0.08;
            mat.surf.opacity=0.05;
            
            mat.vol.refract=1.53;
            mat.vol.disperse=vec3(1.51,1.52,1.53);
            mat.vol.translucent=0.;
            mat.vol.absorb=vec3(0.3,0.05,0.2);
            mat.vol.emit=vec3(0.);
    return mat;
    
}

Material setDiamond(){
        Material mat;
            mat.surf.color=vec3(0.05);
            mat.surf.phong.shiny=15.;
            mat.surf.reflect=0.08;
            mat.surf.opacity=0.05;
            
            mat.vol.refract=1.53;
            mat.vol.disperse=vec3(2.4,2.42,2.46);
            mat.vol.translucent=0.;
            mat.vol.absorb=vec3(0.3,0.05,0.2);
            mat.vol.emit=vec3(0.);
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
            mat=setDiamond();
            break;

             
        case 4://mirror
            mat.surf.color=vec3(0.03,0.05,0.2);
            mat.surf.reflect=0.95;
            mat.surf.phong.shiny=15.;
            mat.surf.opacity=1.;
             
            
            mat.vol.refract=1.25;
            mat.vol.disperse=vec3(mat.vol.refract);
            mat.vol.translucent=1.;
            mat.vol.absorb=vec3(0.);
            mat.vol.emit=vec3(0.);

            break;
             
             
        case 5://diamond
            mat=setDiamond();
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







//update the light intensity of a local data, depending on if we are continuing on for reflection or transmission
void updateReflectIntensity(inout Path path){
    //need to make sure the reflectivity has been properly updated in path
    path.intensity*=path.dat.reflect;
}


void updateTransmitIntensity(inout Path path,Material mat){
    //need to make sure the reflectivity has been properly updated in path
    path.intensity*=(1.-path.dat.reflect)*(1.-mat.surf.opacity);
}






//copy a path for transmission through a surface,
Path copyForTransmit(Path path, Material mat){
     //make the transmission data
    Path transPath=path;
    //make this true only if the is somewhat transparent
    transPath.keepGoing=transPath.keepGoing&&(mat.surf.opacity<1.);
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



void setDispersionPaths(Path path, inout Path red, inout Path green, inout Path blue){
    
    //copy the red direction
    red=copyForTransmit(path,path.frontMat);
    //update the light color of this path
    red.lightColor=vec3(1.,0.,0.);
    //update the refract direction
red.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,path.backMat.vol.disperse.r,path.frontMat.vol.disperse.r);
    
    
        //copy the red direction
    green=copyForTransmit(path,path.frontMat);
    //update the light color of this path
    green.lightColor=vec3(0.,1.,0.);
    //update the refract direction
green.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,path.backMat.vol.disperse.g,path.frontMat.vol.disperse.g);
    
    
        //copy the red direction
    blue=copyForTransmit(path,path.frontMat);
    //update the light color of this path
    blue.lightColor=vec3(0.,0.,1.);
    //update the refract direction
blue.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,path.backMat.vol.disperse.b,path.frontMat.vol.disperse.b);
    
}


//void setDispersionSix(Path path, inout Path red, inout Path yellow, inout Path green, inout Path cyan,inout Path blue, inout Path magenta){
//    
//    float frontRef;
//    float backRef;
//    
//    //copy the red direction
//    red=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//    red.lightColor=vec3(.5,0.,0.);
//    backRef=path.backMat.vol.disperse.r;
//    frontRef=path.frontMat.vol.disperse.r;
//    //update the refract direction
//red.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef);
//    
//    
//        //copy for the yellow direction
//    yellow=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//    yellow.lightColor=vec3(.5,0.5,0.);
//    backRef=(path.backMat.vol.disperse.r+path.backMat.vol.disperse.g)/2.;
//    frontRef=(path.frontMat.vol.disperse.r+path.frontMat.vol.disperse.g)/2.;
//    //update the refract direction
//yellow.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef);
//    
//
//    
//    //copy the green direction
//    green=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//    green.lightColor=vec3(.5,0.,0.);
//    backRef=path.backMat.vol.disperse.g;
//    frontRef=path.frontMat.vol.disperse.g;
//    //update the refract direction
//green.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef); 
//    
//    
//    //copy for the cyan direction
//    cyan=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//   cyan.lightColor=vec3(0.,0.5,0.5);
//    backRef=(path.backMat.vol.disperse.g+path.backMat.vol.disperse.b)/2.;
//    frontRef=(path.frontMat.vol.disperse.g+path.frontMat.vol.disperse.b)/2.;
//    //update the refract direction
//cyan.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef);
//    
//    
//      //copy the blue direction
//    blue=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//    blue.lightColor=vec3(0.,0.,0.5);
//    backRef=path.backMat.vol.disperse.b;
//    frontRef=path.frontMat.vol.disperse.b;
//    //update the refract direction
//blue.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef); 
//    
//    
//    
//        //copy for the magenta direction
//    magenta=copyForTransmit(path,path.frontMat);
//    //update the light color of this path
//   magenta.lightColor=vec3(0.5,0.,0.5);
//    backRef=path.backMat.vol.disperse.b+2.*(path.backMat.vol.disperse.b-path.backMat.vol.disperse.g);
//    frontRef=path.frontMat.vol.disperse.b+2.*(path.frontMat.vol.disperse.b-path.frontMat.vol.disperse.g);
//    //update the refract direction
//magenta.dat.refractedRay=refractThrough(path.dat.incident,path.dat.normal,backRef,frontRef);
//    
//    
//    
//    
//}





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
//tv is current location;
//dist is the distance traveled to reach here;
void updatePath(inout Path path, Vector tv,float dist,bool isSky){
    
    if(isSky){//if we hit the sky; kill the path
        path.dat.hitSky=true;
        setSkyMaterial(path.frontMat,tv);
        setSkyMaterial(path.backMat,tv);
        return;
    }
    
    //otherwise, sample the material in front and behind
    updateMaterial(path.backMat,tv,-0.01);
    updateMaterial(path.frontMat,tv,0.01);
    
    //update the direction vectors, and reflectivity
    updateLocalData(path.dat,tv,path.backMat,path.frontMat);
    
    //update the accumulation parameters:
    path.dist+=dist;
    path.accColor *= exp(-path.backMat.vol.absorb*dist);
    
}
