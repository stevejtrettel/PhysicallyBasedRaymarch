//----------------------------------------------------------------------------------------------------------------------
// Scene Definitions
//----------------------------------------------------------------------------------------------------------------------


float lightSDF(Point p,Light light){
     float distance=sphere(p,light.pos,light.radius);
    if(distance<EPSILON){
        hitWhich=1;
        colorOfLight3=light.color;
    }
    return distance;
}






//----------------------------------------------------------------------------------------------------------------------
// Scene Components
//----------------------------------------------------------------------------------------------------------------------

//hitWhich =1 here
float sceneLights(Point p){
    float distance=MAX_DIST;
    float lightDist;
    
    //light
   lightDist=lightSDF(p,pointLight1);
    distance=min(distance,lightDist);
    
   lightDist=lightSDF(p,pointLight2);
    distance=min(distance,lightDist);
    
    return distance;
}



float sceneObjs(Point p){
    
    float distance = MAX_DIST;
    
    return distance;
}


//----------------------------------------------------------------------------------------------------------------------
// Total Scene
//----------------------------------------------------------------------------------------------------------------------


float sceneSDF(Point p){
        return fakeSphere(p,createPoint(0.5,0.5,-1.),.5);
    
    
//   float cup= max(fakeSphere(p,createPoint(0.5,0.5,-1.),.5),-fakeSphere(p,createPoint(0.5,0.5,-0.85),0.4));
//    
//
//    
//   return cup;
//    
}





//----------------------------------------------------------------------------------------------------------------------
// Setting InWhich
//----------------------------------------------------------------------------------------------------------------------



void setHitWhich(Vector tv,float ep){
    
    hitWhich=0;
    tv=flow(tv,ep);
    

    //glass surfaces
    if(sceneSDF(tv.pos)<0.){
        hitWhich=3;
        return;
    }
    

  
}
