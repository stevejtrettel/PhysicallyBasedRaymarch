//----------------------------------------------------------------------------------------------------------------------
// LOCAL GEOMETRY
//----------------------------------------------------------------------------------------------------------------------

/*
  Methods perfoming computations in the tangent space at a given point.
*/


// Add two tangent vector at the same point (return v1 + v2)
Vector add(Vector v1, Vector v2) {
    // return the added vectors
    return Vector(v1.pos, v1.dir + v2.dir);
}

// subtract two tangent vector at the same point (return v1 - v2)
Vector sub(Vector v1, Vector v2) {
    // return the added vectors
    return Vector(v1.pos, v1.dir - v2.dir);
}

// scalar multiplication of a tangent vector (return a * v)
Vector scalarMult(float a, Vector v) {
    return Vector(v.pos, a * v.dir);
}


// dot product of the two vectors
float tangDot(Vector v1, Vector v2){
    return dot(v1.dir, v2.dir);
}

// calculate the length of a tangent vector
float tangNorm(Vector v){
    return sqrt(tangDot(v, v));
}

// create a unit tangent vector (in the tangle bundle)
// when possible use the normalization method below
Vector tangNormalize(Vector v){
    // length of the vector
    float length = tangNorm(v);
    return Vector(v.pos, v.dir / length);
}


// cosAng between two vector in the tangent bundle
float cosAng(Vector v1, Vector v2){
    return tangDot(v1, v2);
}

Vector turnAround(Vector v){
    return Vector(v.pos, -v.dir);
}


//reflect the unit tangent vector u off the surface with unit normal n
Vector reflectOff(Vector v, Vector n){
    return add(scalarMult(-2.0 * tangDot(v, n), n), v);
}


//refract the vector v through the surface with normal vector n, coming from a material with refactive index n1 and entering a material with index n2.
Vector refractThrough(Vector v, Vector n, float n1, float n2){
   
    float r=n1/n2;
    float cosI=-tangDot(n,v);
    float sinT2=r*r* (1.0 - cosI * cosI);
    if(sinT2>1.){return Vector(v.pos,vec3(0.,0.,0.));}//TIR  
    //if we are not in this case, then refraction actually occurs
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=r*v.dir+(r * cosI - cosT) * n.dir;
    return Vector(v.pos, dir);
}












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

    vec3 dir=normalize(difference.xyz);

    tv=Vector(p,dir);
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




void nudge(inout Vector v){
    v=flow(v,0.01);
}









//----------------------------------------------------------------------------------------------------------------------
// Area Density
//----------------------------------------------------------------------------------------------------------------------


//takes in a tangent vector and a length
// returns the function A(r,u)



float areaDensity(float r,Vector u){

    float areaDensity=r*r;

    return areaDensity;

}





