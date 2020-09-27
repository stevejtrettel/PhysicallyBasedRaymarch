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



float glassDistance(Point p,Point cent){
    Point c1=translatePoint(vec3(0.,0.,-0.5),cent);
     Point c2=translatePoint(vec3(0.,0.,1.2),cent);
     Point c3=translatePoint(vec3(0.,0.,-2.65),cent);
    
    
    
    //exterior of glass
    float dist=roundedCyl(p,c1,1.3,2.5,0.2);
    
    //delete interior of glass
    dist=smax(dist,-roundedCyl(p,c2,1.15,2.5,0.),0.1);
    
    //delete ball undereneath glass
    dist=smax(dist,-sphere(p,c3,0.75),0.3);

    return dist;
}


//<<<<<<< HEAD
//=======
//       distance=min(distance, sdTorus(p,createPoint(0.,2.,0.),vec2(1.5,0.8)));
//    
//     distance=min(distance, sdRoundBox(p, createPoint(5.,3.,0.),vec3(1.,1.,1.), 0.1 ));
//    // distance=min(distance,
////                  sdRoundedCylinder(p,createPoint(7.,7.,7.),1.,1.,0.5));  
////  distance=min(distance, trueOctahedron(p,createPoint(-5.,-5.,1.),1.)-0.05);
//>>>>>>> glass

float tableDistance(Point p,Point cent){
//shift down
Point q=translatePoint(vec3(0.,0.,-3.7),cent);
    
float distance=roundedCyl(p,q,3.5,0.25,0.2);
    return distance;
}



float iceDistance(Point p,Point cent){
    //shift down
    Point q=translatePoint(vec3(0.,0.,-0.2),cent);
    
    float distance=sdRoundBox(p, q,vec3(1.), 0.1 )+0.1*sin(1.*p.coords.x+1.5*p.coords.y-2.*p.coords.z)*sin(.5*p.coords.x+1.*p.coords.y-.5*p.coords.z)*sin(3.*p.coords.x)*sin(2.*p.coords.y);
    return distance;
}


float liquidDistance(Point p,Point cent){
    
    
    //shift down
    Point q=translatePoint(vec3(0.,0.,-0.475),cent);
    
    float distance=roundedCyl(p,q,1.1495,0.8,0.0);
    return distance;
}




float cocktailDistance(Point p,Point cent){
    
//float ice=iceDistance(p,cent);
float liquid=liquidDistance(p,cent);
float glass=glassDistance(p,cent);
float dist;

    return min(liquid,glass);
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
    
    Point tableCent=createPoint(0.,5.,0.);
    Point cocktail1Cent=createPoint(1.,4.,0.);
    
    return min(cocktailDistance(p,cocktail1Cent),tableDistance(p,tableCent));
}


//----------------------------------------------------------------------------------------------------------------------
// Total Scene
//----------------------------------------------------------------------------------------------------------------------


float sceneSDF(Point p){
    
   // return min(sceneLights(p),sceneObjs(p));
    
    return sceneObjs(p);
}





//----------------------------------------------------------------------------------------------------------------------
// Setting hitWhich
//----------------------------------------------------------------------------------------------------------------------



void setHitWhich(Vector tv,float ep){
    
    Point tableCent=createPoint(0.,5.,0.);
    Point cocktail1Cent=createPoint(1.,4.,0.);
    Point cocktail2Cent=createPoint(-1.,6.,0.);;
    
    hitWhich=0;
    tv=flow(tv,ep);
    
//    if(planeDistance(p)<0.){
//        inWhich=2;
//        return;
//    }

    
        //mirrored surfaces
   if(tableDistance(tv.pos,tableCent)<0.){
        hitWhich=4;
        return;
    }
    
            //liquids
    else if(liquidDistance(tv.pos,cocktail1Cent)<0.){
        hitWhich=5;
        return;
    }
    
    //glass surfaces
    else if(glassDistance(tv.pos,cocktail1Cent)<0.){
        hitWhich=3;
        return;
    }
 
    
  
}
