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








//----calculate Frensel reflection
//from https://www.shadertoy.com/view/4tyXDR
//============================================================
vec2 fresnelReflectUpdate(vec2 surfRefl, float n1, float n2, Vector normal, Vector incident)
{
    //n1=index of refraction you are currently inside of
    //n2=index of refraction you are entering
    
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal.dir,incident.dir);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (abs(sinT2) > 1.0){
               return vec2(0.,1.0);
            }
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = clamp(r0+(1.0-r0)*x*x*x*x*x,0.,1.);

        // adjust reflect multiplier for object reflectivity
        ret = (surfRefl.y + surfRefl.x* ret);
        return vec2(1.-ret,ret);
    
}



//================compute all the useful vectors for a surface
//update the reflectivity of the surface you are hitting
void setSurfData(inout surfData dat, Vector tv, inout Material enter,float currentRefract){
    dat.incident=tv;
    dat.toViewer=turnAround(tv);
    dat.pos=tv.pos;
    Vector normal=surfaceNormal(tv);
    dat.normal=normal;
    dat.reflectedRay=reflectOff(tv,normal);
    dat.refractedRay=refractThrough(tv,normal,currentRefract,enter.refract);
    
    //should I have this function update Material enter via frensel?
    enter.reflect=fresnelReflectUpdate(vec2(1.-enter.reflect,enter.reflect),currentRefract,enter.refract,normal,tv).y;
    
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
           mat.color=skyColor.rgb;
            mat.phong=noPhong;//noPhong
            mat.reflect=0.;
            mat.refract=1.;
            mat.opacity=1.;
            mat.lightThis=0;
            break;//sky
        
        case 1://Lightsource
            mat.color=vec3(.5);
            mat.phong.shiny=5.;
            mat.phong.diffuse=vec3(1.);
            mat.phong.specular=vec3(1.);
            mat.reflect=0.;
            mat.refract=1.;
            mat.opacity=1.;
            mat.absorb=vec3(0.);
            mat.lightThis=1;
            break;
            
        case 2://Plane
            mat.color=checkerboard(sampletv.pos.coords.xy);
            mat.phong.shiny=5.;
            mat.phong.diffuse=vec3(1.);
            mat.phong.specular=vec3(1.);
            mat.reflect=0.2;
            mat.refract=1.1;
            mat.opacity=1.;
            mat.absorb=vec3(0.);
            mat.lightThis=1;
            break;
            
        case 3: //Spheres
            mat.color=0.6*vec3(0.1,0.2,0.35);
            mat.phong.shiny=15.;
            mat.phong.diffuse=vec3(1.);
            mat.phong.specular=vec3(1.);
            mat.reflect=0.05;
            mat.refract=1.55;
            mat.opacity=0.;
            mat.absorb=vec3(8.0, 8.0, 3.0);
            mat.lightThis=1;
            break;


        case 5://debug
            mat.color=vec3(0.,0.,1.);
            mat.lightThis=0;
            break;
    }
}





