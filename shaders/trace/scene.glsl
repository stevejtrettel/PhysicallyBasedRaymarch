


//object names

Sphere ball1;
Sphere ball2;
Box box1;
Plane groundPlane;
Plane wall1;
Plane wall2;


void createSolids(){
//
//    ball1.center=vec3(0,1,1);
//    ball1.radius=0.2;
//    ball1.mat = setMetal(vec3(0.5,0.2,-3.));
//
//    ball1.center=vec3(-1,1,1);
//    ball1.radius=0.2;
//    ball1.mat = setDielectric(vec3(0.5,-1.,0.22));

    groundPlane.orientation=Vector(vec3(0,0,-1),vec3(0.,0,1));
    groundPlane.mat=setDielectric(vec3(0.1,0.1,0.2));

    wall1.orientation = Vector(vec3(-1,0,0),vec3(1,0,0));
    wall1.mat=setDielectric(vec3(0.2,0.1,0.1));

    wall2.orientation = Vector(vec3(0,2,0),vec3(0,-1,0));
    wall2.mat=setDielectric(vec3(0.1,0.2,0.1));

}



void createLights(){

}


void createVolumetrics(){

}



// overall SDF for the scene
float sdf(Vector tv){

    float dist = maxDist;

//    dist=min(dist,sdf(tv,ball1));
//    dist=min(dist,sdf(tv,ball2));

    dist=min(dist,sdf(tv,groundPlane));
    dist=min(dist,sdf(tv,wall1));
    dist=min(dist,sdf(tv,wall2));


   // dist=min(dist,sdf(tv,box1));

    return dist;
}




//overall setData for the scene
void setData(inout Path path){

    //assume we hit the sky unless we set it to false
    path.dat.hitSky=true;

//    setData(path,ball1);
//    setData(path,ball2);

    setData(path,groundPlane);
    setData(path,wall1);
    setData(path,wall2);

}
