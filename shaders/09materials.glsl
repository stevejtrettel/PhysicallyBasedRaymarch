

//----------------------------------------------------------------------------------------------------------------------
// Coloring functions
//----------------------------------------------------------------------------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(v.x,2.);
    float y=mod(v.y,2.);
    
    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(0.2);
    }
    else return vec3(0.01);
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


//given the value of hitWhich, decide the initial color assigned to the surface you hit, before any lighting calculations
//in the future, this function will also contain more data, like its rerflectivity etc



void setMaterial(inout Material mat, Vector sampletv, int hitWhich){
    switch(hitWhich){
        case 0:// Didnt hit anything
            mat.color=0.9*SRGBToLinear(rectTex(sampletv));
            mat.lightThis=0;
            mat.reflect=0.;
            break;//sky
        
        case 1://Lightsource
            mat.color=vec3(.5);
            mat.phong=defaultPhong;
            mat.reflect=0.02;
            mat.lightThis=1;
            break;
            
        case 2://Plane
            mat.color=checkerboard(sampletv.pos.coords.xy);
            mat.reflect=0.02;
            mat.phong=defaultPhong;
            mat.lightThis=1;
            break;
            
        case 3: //Cocktail Glass
            mat.color=0.6*vec3(0.1,0.2,0.35);
            mat.reflect=0.1;
            mat.phong.shiny=15.;
            mat.lightThis=1;
            break;

        case 4: //Ice
            mat.color=vec3(1.);
            mat.reflect=0.1;
            mat.phong.shiny=5.;
            mat.lightThis=1;
            break;  

        case 5: //Negroni,Champagne
            mat.color=vec3(1.);
            mat.reflect=0.1;
            mat.phong.shiny=15.;
            mat.lightThis=1;
            break;  
            
        case 6: //Negroni,Champagne
            mat.color=vec3(1.);
            mat.reflect=0.1;
            mat.phong.shiny=15.;
            mat.lightThis=1;
            break; 
            
        case 7: //StrawMetal
            mat.color=vec3(0.);
            mat.reflect=0.5;
            mat.phong.shiny=15.;
            mat.lightThis=1;
            break; 
            
            
        case 8: //StrawGlass
            mat.color=vec3(0.);
            mat.reflect=0.1;
            mat.phong.shiny=15.;
            mat.lightThis=1;
            break; 
}
}




void setVolume(inout Volume vol, int inWhich){
    
     switch(inWhich){
        case 0:// in the air
            vol.refract=1.;
            vol.opacity=0.9;
            break;//sky
        
        case 2://Plane
            vol.refract=1.;
            vol.opacity=1.;
            //opaque material
            break;
             

            
        case 3: //Glass
            vol.refract=1.55;
            vol.opacity=0.05;
            vol.absorb=vec3(0.3,0.05,0.2);
            break;
             
        case 4: //Ice
            vol.refract=1.31;
            vol.opacity=0.1;
            vol.absorb=vec3(0.3,0.05,0.2);
            break;
             
        case 5: //Negroni
            vol.refract=1.33;
            vol.opacity=0.;
            vol.absorb=3.*vec3(0.05,0.7,0.5);
            break;
             
        case 6: //Champagne
            vol.refract=1.;
            vol.opacity=0.;
            vol.absorb=2.*(vec3(1.)-vec3(0.4,0.34,0.95));
            break;
             
             
        case 7: //StrawMetal
            vol.refract=1.55;
            vol.opacity=0.75;
            vol.absorb=vec3(2.,2.,2.);
            break;
             
             
        case 8: //StrawGlass
            vol.refract=1.55;
            vol.opacity=1.;
            vol.absorb=vec3(0.3,0.05,0.2);
            break;

    }
    
}






//----------------------------------------------------------------------------------------------------------------------
// Setting materials, volumes etc.
//----------------------------------------------------------------------------------------------------------------------

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
void setLocalData(inout localData dat, Vector tv, Volume currentVol, Volume outerVol){
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
    
    //don't update the intensity!
    //dat.intensity=1.;
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


//decide if we are totally internally reflecting
bool TIR(localData dat,Volume inside, Volume outside){
    
        float cosX = -dot(dat.normal.dir,dat.incident.dir);
        float n = inside.refract/outside.refract;
        float sinT2 = n*n*(1.0-cosX*cosX);
    
            if (abs(sinT2) > 1.0 ){
                return true;
            }
    else{return false;}
}























void setBehindVolume(inout Volume vol,Vector sampletv){
    
    //tv starts at the surface you just reached, facing forward.
    Vector tv=turnAround(sampletv);
    nudge(tv);//back up a little bit
    Point p=tv.pos;
    setInWhich(p);
    
    setVolume(vol,inWhich);
    
}




void setInFrontVolume(inout Volume vol,Vector sampletv){
    
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
        setBehindVolume(curVol,sampletv);
        setInFrontVolume(outVol,sampletv);
        setLocalData(data, sampletv, curVol,outVol);
        updateReflectivity(data,mat,curVol,outVol);

}
