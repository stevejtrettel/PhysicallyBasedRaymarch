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
   for(int j=-2;j<2;j++){ 
       distance=min(distance,
                sphere(p,createPoint(2.*float(i),2.*float(j),-1.5),0.5));
   }
    }
    if(distance<EPSILON){
        hitWhich=3;
        return distance;
    }
    
      
      return distance;
   
}
