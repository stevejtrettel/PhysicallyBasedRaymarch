//----------------------------------------------------------------------------------------------------------------------
// Smooth Mins, Maxes
//----------------------------------------------------------------------------------------------------------------------

//float EPSILON=0.0001;

float smin( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}



float smax( float a, float b, float k )
{
    return -smin(-a,-b,k);
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


