


//object names

Sphere ball1;
Sphere ball2;


void buildScene(){

    //----------- BALL 1 -------------------------
    ball1.center=Point(vec4(-1,0,-4,1));
    ball1.radius=1.;
    ball1.mat=setGlass();


    //----------- BALL 2 -------------------------
    ball2.center=Point(vec4(0,1,-2,1));
    ball2.radius=0.55;
    ball2.mat=setGlass();

}



float sceneObjs(Vector tv, inout localData dat){
    float dist=1000.;

    dist=min(dist,sphereSDF(tv,ball1,dat));
    dist=min(dist,sphereSDF(tv,ball2,dat));
    return dist;

}

float sceneLights(Vector tv, inout localData dat){
    return 1000.;
}

float sceneSDF(Vector tv, inout localData dat){
    float dObj=sceneObjs(tv,dat);
    if(dObj<EPSILON){
        return dObj;
    }
    else return min(dObj,sceneLights(tv,dat));
}