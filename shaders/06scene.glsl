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
    
    float distance=
         sphere(p,createPoint(-5.,3.,0.),1.5);
    


       distance=min(distance, sdTorus(p,createPoint(0.,2.,0.),vec2(1.5,0.8)));
    
     distance=min(distance, sdRoundBox(p, createPoint(5.,3.,0.),vec3(1.,1.,1.), 0.1 ));
    // distance=min(distance,
//                  sdRoundedCylinder(p,createPoint(7.,7.,7.),1.,1.,0.5));  
//  distance=min(distance, trueOctahedron(p,createPoint(-5.,-5.,1.),1.)-0.05);

    return distance;
}



float mirrorDistance(Point p){
    
     float distance= sphere(p,createPoint(3.5,1.5,-1.),1.5);
     distance=min(distance, cube(p,createPoint(2.,-3.,0.5),0.6));
    distance=min(distance, block(p,createPoint(-2.,3.,-3.5),6.,0.5,6.));
    distance=min(distance, 
    block(p,createPoint(-2.,-7.,-3.5),6.,0.5,6.));
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
    
   // distance=min(distance, mirrorDistance(p));
    
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
    
      //  mirrored surfaces
//    else if(mirrorDistance(tv.pos)<0.){
//        hitWhich=4;
//        return;
//    }
  
}






//----------------------------------------------------------------------------------------------------------------------
// NON-CONSTANT MEDIA
//----------------------------------------------------------------------------------------------------------------------

//the index of refraction of a varying medium is determined by a vector field
vec3 gradN(vec3 p){
    
    vec3 cent=vec3(0.,2.,0.);
    
    vec3 v=p-cent;
    vec3 n=normalize(v);
    float dist=length(v);
    
    //lightRad is a uniform controlling the size of the disturbance
    float mag=1.-smoothstep(0.,lightRad,dist);

//refl is a uniform controling the magnitude of the disturbance
    return -refl*mag*n; 
}


vec3 gradN(Point p){
    
    return gradN(p.coords.xyz);
}

vec3 gradN(Vector tv){
    return gradN(tv.pos);
}

