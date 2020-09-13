//----------------------------------------------------------------------------------------------------------------------
// Scene Definitions
//----------------------------------------------------------------------------------------------------------------------


int planeNumber;

float localSceneSDF(Point p){
    float distance = MAX_DIST;
    
         distance= sphere(p,Point(vec4(0.,0.,-1.,1.)),0.5);
    if(distance<EPSILON){
        hitWhich=3;
        planeNumber=2;
        return distance;
    }

//      
//     distance= halfSpace2(p);
//    if(distance<EPSILON){
//        hitWhich=3;
//        planeNumber=2;
//        return distance;
//    }
//    
//    distance=min(distance,halfSpace3(p));
//        if(distance<EPSILON){
//        hitWhich=3;
//        planeNumber=3;
//        return distance;
//    }
      
      return distance;
   
}
