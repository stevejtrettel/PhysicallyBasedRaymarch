Vector surfaceNormal(Point p){
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

Vector surfaceNormal(Vector tv){
    Point p=tv.pos;
    return surfaceNormal(p);
}










//================compute all the useful vectors for a surface
//update the reflectivity of the surface you are hitting
void setLocalData(inout localData dat, Vector tv, inout Material mat, Volume currentVol, Volume outerVol){
    dat.incident=tv;
    dat.toViewer=turnAround(tv);
    dat.pos=tv.pos;
    
    Vector normal=surfaceNormal(tv);
    float side=-sign(tangDot(tv,normal));
    
    //make inward pointing normal if we are on the inside
    if(side==-1.){normal=turnAround(normal);}
    
    dat.reflectedRay=reflectOff(tv,normal);

    dat.refractedRay=refractThrough(tv,normal,currentVol.refract,outerVol.refract);
    
    dat.normal=normal;
    dat.side=side;
}


//----- calculate fresnel reflectivity
void updateReflectivity(localData dat, inout Material mat, Volume currentVol, Volume outerVol){
    
    
    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    float n1=currentVol.refract;
    float n2=outerVol.refract;
    
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(dat.normal.dir,dat.incident.dir);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (abs(sinT2) > 1.0){
               mat.reflect=1.;
            }
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

        // adjust reflect multiplier for object reflectivity
        mat.reflect=(mat.reflect + (1.-mat.reflect)*ret);
    
    
    
     //fresnelReflectUpdate(mat.reflect,currentVol.refract,outerVol.refract,dat.normal,dat.incident);
    
}


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


//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------


//given the value of hitWhich, decide the initial color assigned to the surface you hit, before any lighting calculations
//in the future, this function will also contain more data, like its rerflectivity etc



void setMaterial(inout Material mat, Vector sampletv, int hitWhich){
    switch(hitWhich){
        case 0:// Didnt hit anything
            mat.color=0.4*skyColor.rgb;
            mat.lightThis=0;
            break;//sky
        
        case 1://Lightsource
            mat.color=vec3(.5);
            mat.phong=defaultPhong;
            mat.reflect=0.;
            mat.lightThis=1;
            break;
            
        case 2://Plane
            mat.color=checkerboard(sampletv.pos.coords.xy);
            mat.reflect=0.2;
            mat.phong=defaultPhong;
            mat.lightThis=1;
            break;
            
        case 3: //Spheres
            mat.color=0.6*vec3(0.1,0.2,0.35);
            mat.reflect=0.05;
            mat.phong.shiny=15.;
            mat.phong.diffuse=vec3(1.);
            mat.phong.specular=vec3(1.);
            mat.lightThis=1;
            break;


        case 5://debug
            mat.color=vec3(0.,0.,1.);
            mat.lightThis=0;
            break;
    }
}







//----------------------------------------------------------------------------------------------------------------------
// DECIDING WHICH VOLUME YOU ARE INSIDE OF
//----------------------------------------------------------------------------------------------------------------------




void setVolume(inout Volume vol, int inWhich){
    
     switch(inWhich){
        case 0:// in the air
            vol.refract=1.;
            vol.opacity=1.;
            break;//sky
        
        case 2://Plane
            vol.refract=1.;
            vol.opacity=1.;
            //opaque material
            break;
            
        case 3: //Spheres
            vol.refract=1.25;
            vol.opacity=0.1;
            vol.absorb=vec3(8.,3.,3.);
            break;
    }
    
}


void setCurrentVolume(inout Volume vol,Vector sampletv){
    
    //tv starts at the surface you just reached, facing forward.
    Vector tv=turnAround(sampletv);
    nudge(tv);//back up a little bit
    Point p=tv.pos;
    setInWhich(p);
    
    setVolume(vol,inWhich);
    
}




void setOuterVolume(inout Volume vol,Vector sampletv){
    
    //tv starts at the surface you just reached, facing forward.
    Vector tv=sampletv;
    nudge(tv);//move forward a little bit
    Point p=tv.pos;
    setInWhich(p);
    
    setVolume(vol,inWhich);
    
}







//----------------------------------------------------------------------------------------------------------------------
// SET PARAMETERS
//----------------------------------------------------------------------------------------------------------------------

void setParameters(Vector sampletv,inout localData data, inout Material mat, inout Volume curVol, inout Volume outVol){
    
        setMaterial(mat, sampletv, hitWhich);
        setCurrentVolume(curVol,sampletv);
        setOuterVolume(outVol,sampletv);
        setLocalData(data, sampletv, mat, curVol,outVol);
        updateReflectivity(data,mat,curVol,outVol);

}
