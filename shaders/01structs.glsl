#version 300 es
out vec4 out_FragColor;


//----------------------------------------------------------------------------------------------------------------------
// STRUCT Point
//----------------------------------------------------------------------------------------------------------------------
const float PI = 3.1415926538;


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



// return the cylinder coordinates (rho, theta, z) of the point in the form (rho^2, theta, z)
// avoid one square root computation
vec3 toCylSq(Point p) {
    return vec3(
    pow(p.coords.x, 2.) + pow(p.coords.y, 2.),
    atan(p.coords.y, p.coords.x),
    p.coords.z
    );
}

// return the cylinder coordinates (rho, theta, z) of the point
vec3 toCyl(Point p) {
    vec3 aux = toCylSq(p);
    return vec3(sqrt(aux.x), aux.yz);
}


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
    bool nil;// say if the element is known to belong to nil (the normal transitive subgroup)
};


// Method to unserialized isometries passed to the shader
Isometry unserializeIsom(mat4 data) {
    return Isometry(data, false);
}

const Isometry identity = Isometry(mat4(1), true);
const Isometry flip = Isometry(mat4(
0, 1, 0, 0,
1, 0, 0, 0,
0, 0, -1, 0,
0, 0, 0, 1
), false);

// return the rotation around the z-axis by an angle alpha
Isometry rotation(float angle){
    mat4 mat = mat4(
    cos(angle), sin(angle), 0, 0,
    -sin(angle), cos(angle), 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
    );
    return Isometry(mat, false);
}

// Return the isometry sending the origin to p
Isometry makeLeftTranslation(Point p) {
    // this is in COLUMN MAJOR ORDER so the things that LOOK LIKE ROWS are actually FUCKING COLUMNS!
    mat4 mat = mat4(
    1., 0., -p.coords.y / 2., 0.,
    0., 1., p.coords.x / 2., 0.,
    0., 0., 1., 0.,
    p.coords.x, p.coords.y, p.coords.z, 1.);
    return Isometry(mat, true);
}

// Return the isometry sending p to the origin
Isometry makeInvLeftTranslation(Point p) {
    mat4 mat = mat4(
    1., 0., p.coords.y / 2., 0.,
    0., 1., -p.coords.x / 2., 0.,
    0., 0., 1., 0.,
    -p.coords.x, -p.coords.y, -p.coords.z, 1.);
    return Isometry(mat, true);
}


// Product of two isometries (more precisely isom1 * isom2)
Isometry composeIsometry(Isometry isom1, Isometry isom2) {
    return Isometry(isom1.mat * isom2.mat, isom1.nil && isom2.nil);
}

// Return the inverse of the given isometry
Isometry getInverse(Isometry isom) {
    return Isometry(inverse(isom.mat), isom.nil);
}





Isometry translateByVector(vec3 dir) {
    //eventually replace wit the isometry which is exponential of dir in Lie algebra
return makeLeftTranslation(createPoint(dir.x,dir.y,dir.z));
}


Isometry translateByVector(Vector v) {
   return translateByVector(v.dir);
}



// Translate a point by the given isometry
Point translate(Isometry isom, Point p) {
    return Point(isom.mat * p.coords);
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
    // apply an isometry to the tangent vector (both the point and the direction)
    if (isom.nil) {
        return Vector(translate(isom, v.pos), v.dir);
    }
    else {
        Isometry shift = makeLeftTranslation(v.pos);
        Point target = translate(isom, v.pos);
        Isometry shiftInv = makeInvLeftTranslation(target);
        mat4 matDir = shiftInv.mat * isom.mat * shift.mat;
        vec3 newDir= (matDir * vec4(v.dir,0.)).xyz;
        return Vector(target,newDir);
    }
}




//possibly replace shift?!
Point smallShift(Point p, vec3 dp) {
    // direction at the origin
    vec4 dirAtOrigin = vec4(dp, 0);
    Isometry shift = makeLeftTranslation(p);
    vec4 dirAtP = shift.mat * dirAtOrigin;
    return Point(p.coords + dirAtP);
}







Vector rotateByFacing(mat4 facing, Vector tv){
    vec3 newDir=(facing*vec4(tv.dir,0.)).xyz;
    return Vector(tv.pos,newDir);
}





//----------------------------------------------------------------------------------------------------------------------
// STRUCTURES FOR SHADING / MARCHING
//----------------------------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------------------------
// Struct Light
//----------------------------------------------------------------------------------------------------------------------

struct Light{
    Point pos;//position of light (point source)
    vec3 dir;//direction to light (directional)
    vec3 color;//color of light
    float intensity;//intensity of light
    float radius;//radius of ball for point source
};

Light createPointLight(Point pos, vec3 color, float intensity, float radius){
    Light light;
    light.pos=pos;
    light.color=color;
    light.intensity=intensity;
    light.radius=radius;
    return light;
}


Light createDirLight(vec3 dir, vec3 color, float intensity){
    Light light;
    light.dir=dir;
    light.color=color;
    light.intensity=intensity;
    return light;
}

//----------------------------------------------------------------------------------------------------------------------
// Struct Accuracy
//----------------------------------------------------------------------------------------------------------------------



//Data type for storing the parameters that the raymarch needs to run (or other things, like shadows etc)


struct marchRes{
    float maxDist;
    int marchSteps;
    float threshhold;
    
    
};


marchRes stdRes=marchRes(40.,300,0.0001);

marchRes reflRes=marchRes(20.,100,0.0001);




//----------------------------------------------------------------------------------------------------------------------
// Struct Material Properties
//----------------------------------------------------------------------------------------------------------------------


struct Phong{
    float shiny;
    vec3 diffuse;
    vec3 specular;
};

//some default values
const Phong noPhong=Phong(1.,vec3(1.),vec3(1.));

//Data type for storing the parameters of a material: its index of refraction, reflectivity, transparency, color, etc.


struct Surface{
    vec3 color;
    Phong phong;
    float reflect;
    float opacity;
};

const Surface noSurface=Surface(vec3(0.),noPhong,0.,0.);

struct Volume{
    float refract;
    vec3 disperse;
    float translucent;
    vec3 absorb;
    vec3 emit;
    float opacity;
};

const Volume transparentVolume=Volume(1.,vec3(1.),0.,vec3(0.),vec3(0.),0.);


//materials have surface properties,
//and also volume properties.
struct Material{
    Surface surf;
    Volume vol;
};

Material air=Material(noSurface,transparentVolume);

//----------------------------------------------------------------------------------------------------------------------
// Struct Surface Data
//----------------------------------------------------------------------------------------------------------------------
    

//Local geometric data at a point on the surface. 
struct localData{
    
    Vector incident;
    Vector toViewer;
    Point pos;
    Vector normal;
    Vector reflectedRay;
    Vector refractedRay;
    float side;//inside or outside an object
    float reflect;//reflectivity of the surface we are currently at.
    bool hitSky;
    
};




//store data as we move along a path in the raymarch:
//instead of just tracking the tangent vector, we can keep one of these objects in tow;
struct Path{
    localData dat;
    
    //materials at our current location
    Material backMat;
    Material frontMat;
    
    float intensity;
    float dist;
    vec3 accColor;
    vec3 lightColor;
    
    bool keepGoing;//do we kill this ray?
};


void initializePath(inout Path path){
    path.dat.hitSky=false;
    //set the initial data
    path.frontMat=air;
    path.backMat=air;
    path.intensity=1.;
    path.dist=0.;
    path.accColor=vec3(1.);
    path.lightColor=vec3(1.);
    path.keepGoing=true;
}




