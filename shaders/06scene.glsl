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





float planeDistance(Point p){
       return  halfSpaceZ(p,2.);
}


float sphereDistance(Point p){
    float distance=
         sphere(p,createPoint(-0.5,0.5,-1.),1.);
    distance=min(distance, sphere(p,createPoint(1.5,-0.5,-1.),0.5));
    return distance;
    
}






//----------------------------------------------------------------------------------------------------------------------
// Scene Components
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
    distance=planeDistance(p);
    if(distance<EPSILON){
        hitWhich=2;
        return distance;
    }
    

    distance=min(distance, sphereDistance(p));
    if(distance<EPSILON){
        hitWhich=3;
        return distance;
    }
    
      return distance;
   
}










//----------------------------------------------------------------------------------------------------------------------
// Total Scene
//----------------------------------------------------------------------------------------------------------------------


float sceneSDF(Point p){
    
    return min(sceneLights(p),sceneObjs(p));
    
}





//----------------------------------------------------------------------------------------------------------------------
// Setting InWhich
//----------------------------------------------------------------------------------------------------------------------


void setInWhich(Point p){
    
    if(planeDistance(p)<0.){
        inWhich=2;
        return;
    }
    else if(sphereDistance(p)<0.){
        inWhich=3;
        return;
    }
    //don't bother with the lights:
    else{
        inWhich=0;
    }
    
}

