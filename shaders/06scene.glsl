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
   return cocktailGlass(p);
}

float iceDistance(Point p){
    return cube(p,createPoint(-2.4,-1.4,-0.2),0.45)+0.01*sin(10.*p.coords.x+5.*p.coords.y-12.*p.coords.z);
}

float liquidDistance(Point p){
    return max(liquid(p),-iceDistance(p)+0.01);
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
    

    distance=min(distance, glassDistance(p));
    if(distance<EPSILON){
        hitWhich=3;
        return distance;
    }
    
        distance=min(distance, iceDistance(p));
    if(distance<EPSILON){
        hitWhich=4;
        return distance;
    }
    
            distance=min(distance, liquidDistance(p));
    if(distance<EPSILON){
        hitWhich=5;
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
    else if(glassDistance(p)<0.){
        inWhich=3;
        return;
    }
        else if(iceDistance(p)<0.){
        inWhich=4;
        return;
    }
    
            else if(liquidDistance(p)<0.){
        inWhich=5;
        return;
    }
    //don't bother with the lights:
    else{
        inWhich=0;
    }
    
}

