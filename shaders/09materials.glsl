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













vec3 surfaceColor(Vector tv){
    
    float x=tv.pos.coords.x;
    float y=tv.pos.coords.y;
    float z=tv.pos.coords.x;
    
    return vec3(0.5)+abs(vec3(x,y,z));
    
    
}


//----------------------------------------------------------------------------------------------------------------------
// DECIDING BASE COLOR OF HIT OBJECTS, AND MATERIAL PROPERTIES
//----------------------------------------------------------------------------------------------------------------------


//given the value of hitWhich, decide the initial color assigned to the surface you hit, before any lighting calculations
//in the future, this function will also contain more data, like its rerflectivity etc

vec3 materialColor(int hitWhich){
    switch(hitWhich){
        case 0:// Didnt hit anything
           return vec3(0.5,0.6,0.7);//sky
        
        case 1://Lightsource
            return vec3(0.8);
            
        case 2://Plane
            return 0.2*surfaceNormal(sampletv).dir;
            
        case 3: //Local Tiling
                return 0.2*surfaceNormal(sampletv).dir;
    
        case 5://debug
            return vec3(1.,0.,1.);
    }
}