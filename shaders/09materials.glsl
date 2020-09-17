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


//this sets a bunch of global parameters for materials;

void materialProperties(int hitWhich){
    switch(hitWhich){
        case 0:// Didnt hit anything
           surfColor=skyColor.w*skyColor.rgb;
            surfRefl=vec2(1.,0.);
            lightThis=0;
            break;//sky
        
        case 1://Lightsource
            surfColor=vec3(.5);
            surfShine=5.;
            surfRefl=vec2(1.,0.);
            lightThis=1;
            break;
            
        case 2://Plane
            surfColor=checkerboard(sampletv.pos.coords.xy);
            surfShine=5.;
            surfRefl=vec2(0.8,0.2);
            lightThis=1;
            break;
                //0.2*surfaceNormal(sampletv).dir;
            
        case 3: //Spheres
            surfColor=0.6*vec3(0.1,0.2,0.35);
            surfShine=15.;
            surfRefl=vec2(0.5,0.5);
            lightThis=1;
            break;

        case 5://debug
            surfColor=vec3(0.,0.,1.);
            lightThis=0;
            break;
    }
}









//----------------------------------------------------------------------------------------------------------------------
// SETTING ALL THE LOCAL DATA
//----------------------------------------------------------------------------------------------------------------------



void surfaceData(Vector tv,int hitWhich){
    
    //set the local data once you hit a point on the surface
    toViewer=turnAround(tv);
    surfPos=tv.pos;
    surfNormal=surfaceNormal(tv);
    reflectedRay=reflectOff(tv,surfNormal);
    
    //set the material colors, reflectivity etc
    materialProperties(hitWhich);
    
}


