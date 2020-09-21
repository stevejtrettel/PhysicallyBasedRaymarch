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


float glassDistance(Point p){
    float distance=
         sphere(p,createPoint(-0.5,0.5,-1.),1.);
    distance=min(distance, vertCyl(p,createPoint(1.5,-0.5,-1.),0.5));
    
    distance=min(distance, cube(p,createPoint(2.,-3.,0.5),0.6));
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
//    distance=planeDistance(p);
//    if(distance<EPSILON){
//        hitWhich=2;
//        return distance;
//    }
//    

    distance=min(distance, glassDistance(p));
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
    
//    if(planeDistance(p)<0.){
//        inWhich=2;
//        return;
//    }
    //else
        if(glassDistance(p)<0.){
        inWhich=3;
        return;
    }
    //don't bother with the lights:
    else{
        inWhich=0;
    }
    
}

