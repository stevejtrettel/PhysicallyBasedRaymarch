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
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------


//given the value of hitWhich, decide the initial color assigned to the surface you hit, before any lighting calculations
//in the future, this function will also contain more data, like its rerflectivity etc


//this sets a bunch of global parameters for materials;

void materialProperties(int hitWhich){
    switch(hitWhich){
        case 0:// Didnt hit anything
           surfColor=vec3(0.5,0.6,0.7);
            break;//sky
        
        case 1://Lightsource
            surfColor=vec3(0.8);
            break;
            
        case 2://Plane
            surfColor=vec3(0.1,0.35,0.2);
            break;
                //0.2*surfaceNormal(sampletv).dir;
            
        case 3: //Spheres
            surfColor=0.2*surfNormal.dir;
            break;

        case 5://debug
            surfColor=vec3(0.,0.,1.);
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
    reflectIncident=reflectOff(sampletv,surfNormal);
    
    //set the material colors, reflectivity etc
    materialProperties(hitWhich);
    
}


