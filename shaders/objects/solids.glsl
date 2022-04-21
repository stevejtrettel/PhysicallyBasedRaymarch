





//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    vec3 center;
    float radius;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Sphere sphere ){
    //normalize position
    vec3 pos = p - sphere.center;

    //distance to closest point on the sphere
    return length(pos) - sphere.radius;
}

//overload of location booleans:
bool at( Vector tv, Sphere sphere){

    float d = distR3( tv.pos, sphere );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

//overload of sdf for a sphere
float sdf( Vector tv, Sphere sphere ){

    //distance to closest point on sphere
    float d=distR3(tv.pos, sphere);

    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos)>0.){return maxDist;}

    //otherwise return the actual distance
    return d;
}

//overload of normalVec for a sphere
Vector normalVec( Vector tv, Sphere sphere ){
    //position vector rel center
    vec3 dir = tv.pos-sphere.center;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}

//overload of setData for a sphere
void setData( inout Path path, Sphere sphere ){

    //if we are at the surface
    if(at(path.tv, sphere)){

        path.dat.hitSky = false;
        path.dat.inVolumetric = false;

        //store incident, and to-viewer vectors
        path.dat.incident = path.tv;
        path.dat.toViewer = turnAround(path.dat.incident);

        //compute the normal
        path.dat.normal = normalVec(path.tv,sphere);

        //set the material
        path.dat.mat = sphere.mat;

    }

}












//-------------------------------------------------
//The BOX sdf
//-------------------------------------------------



//the data of a sphere is its center and radius
struct Box{
    vec3 center;
    vec3 sides;
    float rounded;
    Material mat;
};


//overload of distR3: distance in R3 coordinates
float distR3( vec3 p, Box box ){
    //normalize position
    vec3 pos = p - box.center;

    vec3 q = abs(pos) - box.sides;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded;
}


//overload of location booleans:
bool at( Vector tv,Box box){

    float d = distR3( tv.pos, box );
    bool atSurf = ((abs(d) - AT_THRESH)<0.);
    return atSurf;
}

//overload of sdf for a sphere
float sdf( Vector tv, Box box ){

    //distance to closest point on sphere
    float d=distR3(tv.pos, box);
    //return the actual distance
    return d;
}


//overload of normalVec for a sphere
Vector normalVec( Vector tv, Box box ){

    vec3 pos=tv.pos;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=distR3( pos + e.xyy*ep, box);
    float vyyx=distR3( pos + e.yyx*ep, box);
    float vyxy=distR3( pos + e.yxy*ep, box);
    float vxxx=distR3( pos + e.xxx*ep, box);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    dir=normalize(dir);

    return Vector(tv.pos,dir);

}



//overload of setData for a sphere
void setData( inout Path path, Box box){

    //if we are at the surface
    if(at(path.tv, box)){

        path.dat.hitSky=false;
        path.dat.inVolumetric=false;

        //store incident, and to-viewer vectors
        path.dat.incident = path.tv;
        path.dat.toViewer = turnAround(path.dat.incident);

        //compute the normal
        path.dat.normal=normalVec(path.tv,box);

        //set the material
        path.dat.mat = box.mat;

    }

}























//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//the data of a plane is its normal and a constant:

struct Plane{
//a plane is given by a position and the unit normal at that point:
    Vector orientation;
    Material mat;
};



//overload of distR3
float distR3( vec3 pos, Plane plane ){

    //get position relative to point on plane
    vec3 relPos = pos - plane.orientation.pos;

    //project onto the normal vector
    return dot( relPos, plane.orientation.dir );

}


//overload of location booleans:
bool at( Vector tv, Plane plane){

    float d = distR3( tv.pos, plane );
    return  (abs(d) < AT_THRESH);

}

//overload of sdf
float sdf( Vector tv, Plane plane ){

    //if aimed away from plane:
   // if(dot(tv.dir,plane.orientation.dir)>0.){return maxDist;}

    //otherwise give distance
    return distR3(tv.pos, plane);
}

//overload of normalVec
Vector normalVec( Vector tv,Plane plane ){
    //the normal is just the plane's normal vector
    return Vector(tv.pos, plane.orientation.dir);
}

//overload of setData for a sphere
void setData( inout Path path, Plane plane ){

    //if we are at the surface
    if(at(path.tv, plane)){

        path.dat.hitSky=false;
        path.dat.inVolumetric=false;

        //store incident, and to-viewer vectors
        path.dat.incident = path.tv;
        path.dat.toViewer = turnAround(path.dat.incident);

        //compute the normal
        path.dat.normal=normalVec(path.tv,plane);

        //set the material
        path.dat.mat = plane.mat;

    }
}



