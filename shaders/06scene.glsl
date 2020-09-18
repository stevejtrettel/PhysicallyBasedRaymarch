//----------------------------------------------------------------------------------------------------------------------
// Scene Definitions
//----------------------------------------------------------------------------------------------------------------------


float lightSDF(Point p,Light light){
     float distance=sphere(p,light.pos,light.radius);
    if(distance<EPSILON){
        hitWhich=1;
        colorOfLight3=light.color;
        return distance;
    }
    return distance;
}










//----------------------------------------------------------------------------------------------------------------------
// Total Global Scene
//----------------------------------------------------------------------------------------------------------------------


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
    
        //plane
    distance= halfSpaceZ(p,2.);
    if(distance<EPSILON){
        hitWhich=2;
        return distance;
    }
    

    for(int i=-2;i<2;i++){
   for(int j=-2;j<2;j++){ 
       distance=min(distance,
                sphere(p,createPoint(1.5*float(i),1.5*float(j),-1.),0.5));
   }
    }
    if(distance<EPSILON){
        hitWhich=3;
        return distance;
    }
    
      return distance;
   
}


float sceneSDF(Point p){
    
    return min(sceneLights(p),sceneObjs(p));
    
}

