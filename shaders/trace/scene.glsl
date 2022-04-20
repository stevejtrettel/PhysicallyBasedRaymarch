


//object names

Sphere ball1;
Sphere ball2;
Box box1;



void createSolids(){

    ball1.center=vec3(0,1,1);
    ball1.radius=0.2;
    ball1.mat = setMetal(vec3(0.5,0.2,0.22));

    ball1.center=vec3(-1,1,1);
    ball1.radius=0.2;
    ball1.mat = setDielectric(vec3(0.5,0.2,0.22));

}



void createLights(){

}


void createVolumetrics(){

}



// overall SDF for the scene
float sdf(Vector tv){

    float dist = maxDist;

    dist=min(dist,sdf(tv,ball1));
    dist=min(dist,sdf(tv,ball2));
   // dist=min(dist,sdf(tv,box1));

    return dist;
}




//overall setData for the scene
void setData(inout Path path){

    //assume we hit the sky unless we set it to false
    path.dat.hitSky=true;

    setData(path,ball1);
    setData(path,ball2);

}
