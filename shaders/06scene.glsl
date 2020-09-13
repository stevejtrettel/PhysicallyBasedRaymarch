//----------------------------------------------------------------------------------------------------------------------
// Scene Definitions
//----------------------------------------------------------------------------------------------------------------------

//scenes named by hitWhich










//----------------------------------------------------------------------------------------------------------------------
// Total Global Scene
//----------------------------------------------------------------------------------------------------------------------

float sceneSDF(Point p){
    float distance = MAX_DIST;
    
        //plane
    distance= halfSpaceZ(p,2.);
    if(distance<EPSILON){
        hitWhich=2;
        return distance;
    }
    
    //light
    distance=min(distance,sphere(p,createPoint(1.,1.,0.),0.2));
    if(distance<EPSILON){
        hitWhich=1;
        return distance;
    }
    

    for(int i=-2;i<2;i++){
    distance=min(distance,sphere(p,createPoint(float(i),float(i),-1.5),0.5));
    if(distance<EPSILON){
        hitWhich=3;
        return distance;
    }
    }
      
      return distance;
   
}
