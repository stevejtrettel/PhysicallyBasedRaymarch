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





float planeDistance(Point p){
       return  halfSpaceZ(p,2.);
}


float glassDistance(Point p){
    
    //exterior of glass
float dist=cyl(p,createPoint(0.,5.,-0.5),1.3,2.5,0.2);
    
    //delete interior of glass
    dist=smax(dist,-cyl(p,createPoint(0.,5.,1.2),1.15,2.5,0.2),0.5);
    
    //delete ball undereneath glass
    dist=smax(dist,-sphere(p,createPoint(0.,5.,-2.65),0.75),0.3);
    
    
    
    return dist;
}



float mirrorDistance(Point p){
    
float distance=cyl(p,createPoint(0.,5.,-3.7),3.5,0.25,0.2);
    return distance;
}



float iceDistance(Point p){
    float distance=sdRoundBox( p, createPoint(0.,5.,0.),vec3(1.), 0.1 );
    return distance;
}


float liquidDistance(Point p){
    float distance=max(cyl(p,createPoint(0.,5.,-0.495),1.15,1.,0.0),-iceDistance(p));
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
    
    //    distance=min(distance,planeDistance(p));
    
    distance=min(distance, glassDistance(p));
    
   distance=min(distance, mirrorDistance(p));
    
    distance=min(distance, liquidDistance(p));
    
        distance=min(distance, iceDistance(p));
    
    return distance;
}


//----------------------------------------------------------------------------------------------------------------------
// Total Scene
//----------------------------------------------------------------------------------------------------------------------


float sceneSDF(Point p){
    
   // return min(sceneLights(p),sceneObjs(p));
    
    return sceneObjs(p);
}





//----------------------------------------------------------------------------------------------------------------------
// Setting InWhich
//----------------------------------------------------------------------------------------------------------------------



void setHitWhich(Vector tv,float ep){
    
    hitWhich=0;
    tv=flow(tv,ep);
    
//    if(planeDistance(p)<0.){
//        inWhich=2;
//        return;
//    }
    //glass surfaces
    if(glassDistance(tv.pos)<0.){
        hitWhich=3;
        return;
    }
    
        //mirrored surfaces
    else if(mirrorDistance(tv.pos)<0.){
        hitWhich=4;
        return;
    }
    
                    //ice cube
    else if(iceDistance(tv.pos)<0.){
        hitWhich=6;
        return;
    }
    
    
            //liquid
    else if(liquidDistance(tv.pos)<0.){
        hitWhich=5;
        return;
    }
    
    

    
    
    
  
}
