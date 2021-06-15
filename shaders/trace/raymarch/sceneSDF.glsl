


//object names

Sphere ball1;
Sphere ball2;
Box box1;

void buildScene(){

    //----------- BALL 1 -------------------------
    ball1.center=Point(vec4(-1,0,1,1));
    ball1.radius=1.;
    ball1.mat=setGlass();


    //----------- BALL 2 -------------------------
    ball2.center=Point(vec4(0,3,0,1));
    ball2.radius=0.55;
    ball2.mat=setGlass();

    box1.center=createPoint(0.,0.,-1.);
    box1.sides=vec3(1,0.5,0.25);
    box1.rounded=0.02;
    box1.mat=setGlass();

}



float sceneObjs(Vector tv, inout localData dat){
    float dist=1000.;

    dist=min(dist,sphereSDF(tv,ball1,dat));
    dist=min(dist,sphereSDF(tv,ball2,dat));
    //dist=min(dist,boxSDF(tv,box1,dat));
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