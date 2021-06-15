


//-------------------------------------------------
//-------------------------------------------------
//=====useful
//====OPERATIONS
//-------------------------------------------------
//-------------------------------------------------


//get the input for a 2d sdf/normal from a 3d point
vec2 opRevolution( in vec3 p, float w )
{
    return vec2( length(p.xz) - w, p.y );
}

vec3 opRevolutionOutputNormal(in vec3 p, float w, vec2 n){

    //right now this STRAIGHT UP IGNORES W
    vec3 rVec=normalize(vec3(p.x,0,p.z));
    vec3 hVec=vec3(0,1,0);

    return n.x*rVec+n.y*hVec;
}



//smooth min of signed distance functions
float opMinDist(float distA, float distB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float m = 0.25*h*h/k;
    return min(distA,distB)-m;
}


//smooth min of two normal vectors
vec3 opMinVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    float h = max(k-abs(distA-distB),0.0);
    float n=0.5*h/k;
    float f=(distA<distB)?n:1.-n;
    return normalize(mix(nvecA, nvecB, f));
}



float opMaxDist( float a, float b, float k )
{
    return -opMinDist(-a,-b,k);
}

vec3 opMaxVec(float distA, vec3 nvecA, float distB, vec3 nvecB, float k){
    return opMinVec(-distA, nvecA,-distB, nvecB,k);
}


float opOnionDist(float dist, float thickness){
    return abs(dist)-thickness;
}


vec3 opOnionVec(float dist,vec3 nVec){
    return sign(dist)*nVec;
}




vec3 opTwist( vec3 p )
{
    float k =50.0; // or some other amount
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec2 rot=m*p.xz;
    vec3  q = vec3(rot.x,p.y,rot.y);
    return q;
}




//----------------------------------------------------------------------------------------------------------------------
// NEW STUFF
//----------------------------------------------------------------------------------------------------------------------



//if you hit an object which is not part of a compound, one side is the object (material) and the other side is air
//set your local data appropriately
void setObjectInAir(inout localData dat, float dist, Vector normal, Material mat){

    //set the material
    dat.hitSky=false;

    //we are inside, approaching air
    if(dist<0.){
        //normal is inward pointing;
        dat.normal=turnAround(normal);
        dat.backMat=mat;
        dat.frontMat=air;
    }

    else{
        //normal is outward pointing;
        dat.normal=normal;
        dat.backMat=air;
        dat.frontMat=mat;
    }

}




//-------------------------------------------------
//-------------------------------------------------
//=====distance to a
//========SPHERE
//-------------------------------------------------
//-------------------------------------------------


//-------------------------------------------------
//  Basic Functions
//-------------------------------------------------

float sphereDist(vec3 pos, float radius){

    return length(pos)-radius;
}


//the directed distance function: this can be improved with a better sphere locator test
float sphereDist(Vector tv, float radius){

    float d = sphereDist(tv.pos.coords.xyz, radius);

    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos.coords.xyz)>0.){return 10000.;}

    //otherwise return the actual distance
    return d;
}


//----normal vector
vec3 sphereGrad(vec3 pos,  float radius){
    return normalize(pos);
}

//----normal vector
vec3 sphereGrad(Vector tv,  float radius){
    return normalize(tv.pos.coords.xyz);
}






//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
    Material mat;
};

//----distance and normal functions

float sphereDistance(Vector tv, Sphere sph){

    tv.pos.coords-=sph.center.coords;
    tv.pos.coords+=vec4(0,0,0,1);

    return sphereDist(tv,sph.radius);
}

Vector sphereNormal(Vector tv, Sphere sph){
    tv.pos.coords-=sph.center.coords;
    tv.pos.coords+=vec4(0,0,0,1);
    vec3 dir=sphereGrad(tv,sph.radius);
    return Vector(tv.pos,dir);
}


//------sdf
float sphereSDF(Vector tv, Sphere sph,inout localData dat){

    //distance to closest point:
    float dist = sphereDistance(tv,sph);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=sphereNormal(tv,sph);

        //set the material
        setObjectInAir(dat,dist,normal,sph.mat);
    }

    return dist;
}









//-------------------------------------------------
//-------------------------------------------------
//=====distance to a
//========BOX
//-------------------------------------------------
//-------------------------------------------------

float boxDist(vec3 pos,vec3 sides,float rounded){

    vec3 q=abs(pos)-sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - rounded;
}


vec3 boxGrad(vec3 pos, vec3 sides, float rounded){

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=boxDist( pos + e.xyy*ep,sides,rounded);
    float vyyx=boxDist( pos + e.yyx*ep,sides,rounded);
    float vyxy=boxDist( pos + e.yxy*ep,sides, rounded);
    float vxxx=boxDist( pos + e.xxx*ep,sides, rounded);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return normalize(dir);

}




//-------------------------------------------------
//The BOX sdf
//-------------------------------------------------

//the data of a box is its center, side lengths and roundedness
struct Box{
    Point center;
    vec3 sides;
    float rounded;
    Material mat;
};

//----distance and normal functions

float boxDistance(Vector tv, Box box){

    vec3 p= tv.pos.coords.xyz-box.center.coords.xyz;

    return boxDist(p,box.sides,box.rounded);
}

Vector boxNormal(Vector tv, Box box){
    vec3 p=tv.pos.coords.xyz-box.center.coords.xyz;
    vec3 dir=boxGrad(p,box.sides,box.rounded);
    return Vector(tv.pos,dir);
}


//------sdf
float boxSDF(Vector tv, Box box,inout localData dat){

    //distance to closest point:
    float dist = boxDistance(tv,box);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=boxNormal(tv,box);

        //set the material
        setObjectInAir(dat,dist,normal,box.mat);
    }

    return dist;
}































//-------------------------------------------------
//-------------------------------------------------
//=====distance to an
//=======CYLINDER
//==from rotating a box
//-------------------------------------------------
//-------------------------------------------------


//from https://www.iquilezles.org/www/articles/distgradfunctions2d/distgradfunctions2d.htm
//get the distnance as .x and the 2d normal as .yz
vec3 sdgBox( in vec2 p, in vec2 b )
{
    vec2 w = abs(p)-b;
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l  :g,
    s*((g>0.0)?q/l:((w.x>w.y)?vec2(1,0):vec2(0,1))));
}



float cylinderDist(vec3 pos, float radius, float height, float rounded){

    vec2 p=opRevolution(pos,0.);
    //the box we rotate about its central axis has width 2rad and height = 2height.
    vec2 b=vec2(radius-rounded, height);

    vec2 w = abs(p)-b;
    float g = max(w.x,w.y);
    vec2  q = max(w,0.0);
    float l = length(q);

    float dist= (g>0.0) ?  l  :g;
    return dist-rounded;
}


vec3 cylinderGrad(vec3 pos, float radius, float height,float rounded){

    //roundedness plays no part in the calculation of the cylinder's gradient as it is just an offset.

    vec2 p=opRevolution(pos,0.);
    vec2 b=vec2(radius-rounded, height);

    //this gives distance and normal information
    vec3 ret=sdgBox(p,b);
    //second two coordinates are the 2d normal
    vec2 n=ret.yz;

    vec3 dir=opRevolutionOutputNormal(pos, 0., n);
    return dir;
    //return normalize(dir);
}


//-------------------------------------------------
//The CYLINDER sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Cylinder{
    Point center;
    float radius;
    float height;
    float rounded;
    Material mat;
};

//----distance and normal functions

float cylinderDistance(Vector tv, Cylinder cyl){

    vec3 pos=tv.pos.coords.xyz-cyl.center.coords.xyz;

    return cylinderDist(pos,cyl.radius,cyl.height, cyl.rounded);
}



Vector cylinderNormal(Vector tv, Cylinder cyl){

    vec3 pos=tv.pos.coords.xyz-cyl.center.coords.xyz;

    vec3 dir=cylinderGrad(pos,cyl.radius,cyl.height,cyl.rounded);

    return Vector(Point(vec4(pos,1)),dir);
}



//------sdf
float cylinderSDF(Vector tv, Cylinder cyl,inout localData dat){

    //distance to closest point:
    float dist = cylinderDistance(tv,cyl);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=cylinderNormal(tv,cyl);

        //set the material
        setObjectInAir(dat,dist,normal,cyl.mat);
    }

    return dist;
}


