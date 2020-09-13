

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
           return vec3(0.);
        
        case 1://Lightsource
            return vec3(0.8);
            
        case 3: //Local Tiling
           // return earthColor(sampletv);
                return surfaceColor(sampletv);
    
        case 5://debug
            return vec3(1.,0.,1.);
    }
}