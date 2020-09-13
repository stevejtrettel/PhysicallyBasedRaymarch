


//----------------------------------------------------------------------------------------------------------------------
// Global Tangent Directions, Distances Etc
//----------------------------------------------------------------------------------------------------------------------


// distance between two points
float exactDist(Point p1, Point p2){
    vec3 difference=p1.coords.xyz-p2.coords.xyz;
    return length(difference);
}

// overload of the previous function in case we work with tangent vectors
float exactDist(Vector v1, Vector v2){
    return exactDist(v1.pos, v2.pos);
}

//returns unit tangent vector t
void tangDirection(Point p, Point q, out Vector tv, out float len){
    vec4 difference=q.coords-p.coords;
    len=length(difference);
    
    vec4 dir=normalize(difference);
        
    tv=Vector(p,dir.xyz);
}

void tangDirection(Vector u, Vector v, out Vector tv, out float len){
    // overload of the previous function in case we work with tangent vectors
    tangDirection(u.pos, v.pos, tv, len);
}





// flow the given vector during time t
Vector flow(Vector v, float t) {
    
    vec4 diff=t*vec4(v.dir,0.);
    
    Point newPos=Point(v.pos.coords+diff);
    
    return Vector(newPos,v.dir);
}














//----------------------------------------------------------------------------------------------------------------------
// Area Density
//----------------------------------------------------------------------------------------------------------------------


//takes in a tangent vector and a length
// returns the function A(r,u)



float AreaDensity(float r,Vector u){
    
    float areaDensity=r*r;
    
    return areaDensity;
    
}




