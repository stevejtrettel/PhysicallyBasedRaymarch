
//----------------------------------------------------------------------------------------------------------------------
// STRUCT Point
//----------------------------------------------------------------------------------------------------------------------

/*

    Data type for points in the space X
    A point x in X is represented by a pair (proj,fiber) where
    - proj is the projection of x to SL(2,R) seen as a vec4 (in the basis E)
    - fiber is the fiber coordinates (!)

    The goal of this choice is to perform as many computations in SL(2,R) rather than in X.
    Hopefully this will reduce numerical errors (no need to go back and forth between SL2 and X).

*/

struct Point {
    vec4 coords;// the point in R4
};

// origin of the space
const Point ORIGIN = Point(vec4(0, 0, 0, 1));


// unserialize the data received from the shader to create a point
Point unserializePoint(vec4 data) {
    return Point(data);
}

Point createPoint(float x, float y, float z){
    return Point(vec4(x,y,z,1.));
}

vec3 projModel(Point p){
    return p.coords.xyz;
}


Point shiftPoint(Point p, vec3 v, float ep){
    vec3 s=p.coords.xyz+ep*v;
    return createPoint(s.x,s.y,s.z);
}


//----------------------------------------------------------------------------------------------------------------------
// STRUCT Vector
//----------------------------------------------------------------------------------------------------------------------


/*
  Data type for manipulating points in the tangent bundle
  A Vector is given by
  - pos : a point in the space
  - dir: a tangent vector at pos

  Local direction are vec3 written in the orthonormal basis (e_x, e_y, e_phi) where
  . e_x is the direction of the x coordinate of H^2
  . e_y is the direction of the y coordinate in H^2
  . e_phi is the direction of the fiber

  Implement various basic methods to manipulate them

*/


struct Vector {
    Point pos;// position on the manifold
    vec3 dir;// pull back of the tangent vector at the origin written in the appropriate basis
};

Vector createVector(Point p, vec3 dp) {
    return Vector(p, dp);
}




//----------------------------------------------------------------------------------------------------------------------
// STRUCT Isometry
//----------------------------------------------------------------------------------------------------------------------

/*

  Data type for manipulating isometries of the space
  In this geometry we only consider as isometries the element of X acting on itself on the left.
  If x is a point of X, the isometry L_x sending the origin to x is represented by the point x

*/

struct Isometry {
    mat4 mat;// the image of the origin by this isometry.
};

Isometry identity=Isometry(mat4(1.));

// Method to unserialized isometries passed to the shader
Isometry unserializeIsom(vec4 data) {
    //THIS NEEDS TO BE UPDATED ON THE JS SIDE
    return identity;
}

// Product of two isometries (more precisely isom1 * isom2)
Isometry composeIsometry(Isometry isom1, Isometry isom2) {

    return Isometry(isom1.mat*isom2.mat);
}

// Return the inverse of the given isometry
Isometry getInverse(Isometry isom) {

    return Isometry(inverse(isom.mat));
}


Isometry makeLeftTranslation(Point pt) {
    vec4 p=pt.coords;
    mat4 matrix =  mat4(
    1, 0., 0., 0.,
    0., 1, 0., 0.,
    0., 0., 1., 0,
    p.x, p.y, p.z, 1.
    );
    return Isometry(matrix);
}

Isometry makeInvLeftTranslation(Point pt) {
    vec4 p=pt.coords;
    mat4 matrix =  mat4(
    1, 0., 0., 0.,
    0., 1, 0., 0.,
    0., 0., 1., 0,
    - p.x, - p.y, -p.z, 1.
    );
    return Isometry(matrix);
}






Isometry translateByVector(vec3 dir) {
    mat4 matrix =  mat4(
    1, 0., 0., 0.,
    0., 1, 0., 0.,
    0., 0., 1., 0,
    dir.x, dir.y, dir.z, 1.
    );
    return Isometry(matrix);
}


Isometry translateByVector(Vector v) {
    return translateByVector(v.dir);
}



Point translate(Isometry A, Point pt) {
    return Point(A.mat * pt.coords);
}




//----------------------------------------------------------------------------------------------------------------------
// Applying Isometries, Facings
//----------------------------------------------------------------------------------------------------------------------


// overlaod using Vector
Isometry makeLeftTranslation(Vector v) {
    return makeLeftTranslation(v.pos);
}

// overlaod using Vector
Isometry makeInvLeftTranslation(Vector v) {
    return makeInvLeftTranslation(v.pos);
}

// overload to translate a direction
//SHOULD THIS CHANGE THE DIRECTION?
Vector translate(Isometry isom, Vector v) {
    return Vector(
    translate(isom, v.pos),
    v.dir
    );
}


// apply a local rotation of the direction
Vector rotateByFacing(mat4 mat, Vector v){
    // notice that the facing is an element of SO(3) which refers to the basis (e_x, e_y, e_w).
    vec4 aux = vec4(v.dir, 0.);
    aux = mat * aux;

    return Vector(v.pos, aux.xyz);
}









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






//----------------------------------------------------------------------------------------------------------------------
// Area Density
//----------------------------------------------------------------------------------------------------------------------


//takes in a tangent vector and a length
// returns the function A(r,u)



float areaDensity(float r,Vector u){

    float areaDensity=r*r;

    return areaDensity;

}




//----------------------------------------------------------------------------------------------------------------------
// Geodesic Flow
//----------------------------------------------------------------------------------------------------------------------


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
// Initilize Screen With Geometry
//----------------------------------------------------------------------------------------------------------------------


Vector getRayPoint(vec2 resolution, vec2 fragCoord){ //creates a tangent vector for our ray

    vec2 xy = 0.2 * ((fragCoord - 0.5*resolution)/resolution.x);
    float z = 0.1 / tan(radians(fov * 0.5));
    // coordinates in the prefered frame at the origin
    vec3 dir = vec3(xy, -z);
    Vector tv = Vector(ORIGIN, dir);
    tv = tangNormalize(tv);
    return tv;
}



//----------------------------------------------------------------------------------------------------------------------
// FIND THE RIGHT HOME FOR THIS STUFF
//----------------------------------------------------------------------------------------------------------------------

//set by raymarch
Vector sampletv;

Vector toLight;
float distToLight;
Vector fromLight;
Vector reflLight;
Vector atLight;
vec4 colorOfLight;
vec3 colorOfLight3;

Isometry currentBoost;


