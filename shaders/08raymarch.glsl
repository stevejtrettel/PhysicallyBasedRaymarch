


//----------------------------------------------------------------------------------------------------------------------
// DOING THE RAYMARCH
//----------------------------------------------------------------------------------------------------------------------


// raymarch algorithm
// each step is the march is made from the previously achieved position (useful later for Sol).
// done with general vectors


//sets the side of the surface youy are CURRENTLY on 
//1=on the outside of an object
//-1=on the inside of an object



// raymarch algorithm
// each step is the march is made from the previously achieved position (useful later for Sol).
// done with general vectors


//sets the side of the surface youy are CURRENTLY on 
//1=on the outside of an object
//-1=on the inside of an object


void raymarch(Vector tv,float side, marchRes res){
    Vector starttv=tv;
    distToViewer=0.;
    float marchStep = 0.;
    float depth=0.;

        for (int i = 0; i < res.marchSteps; i++){
            
                float localDist = side*sceneSDF(tv.pos);
            //this could be negative; side sets this.
                if (localDist < res.threshhold){
                    sampletv =tv;
                    isSky=false;
                    distToViewer=depth;
                    break;
                }
                marchStep =localDist;
               depth += marchStep;
            if(depth>res.maxDist){
                //set sampletv to what happens if you march orig TV by maxDist;
                sampletv=flow(starttv,10.);
                isSky=true;
                distToViewer=res.maxDist;
                break;
            }
            tv = flow(tv, marchStep);
        }
}











//improving the shadows using some ideas of iq on shadertoy
float shadowmarch(in Vector toLight, float distToLight,float k)
    {
    
   // float k =40.; //parameter to determine softness of the shadows.
    
    float shade=1.;
    float localDist;
    float depth=0.;
    float marchStep;
    float newEp = EPSILON * 1.0;
    
    //start the march on the surface pointed at the light
    Vector localtv=flow(toLight,0.05);
    
    for (int i = 0; i < 40; i++){
        
            float localDist =sceneObjs(localtv.pos);//exclude lights
                  marchStep = 0.9*localDist;//make this distance your next march step
            depth += marchStep;//add this to the total distance traced so far
        
        localtv = flow(localtv, marchStep); 

  
            
             shade = min(shade, smoothstep(0.,1.,k*localDist/depth)); 
            //if you've hit something 
            if (localDist < newEp){//if you hit something
                return 0.;
            }
        
            if(depth>distToLight-0.1||depth>MAX_DIST){
                break;
            }
    }    
    //at the end, return this value for the shadow deepness
    return clamp(shade,0.,1.); 
}










//
//
//
//
//
//
////takes a tangent vector and an interval; flows by half that interval, and checks which side of the xy plane you're on.  Updates interval accordingly.
//void bisect1(inout float march,inout float dist,inout Vector tv){
//    //this is to be run when tv is above the plane, but after flowing by march you are below the plane.
//    march=march/2.;//cut the flow distance in half
//    Vector testtv=flow(tv,march);//march by half the distance
//    if(testtv.pos.coords.z>-2.){//using global sphere rad as the slider that controls plane height
//        //if hasn't reached the xy plane by time you march to the midpoint
//        tv=testtv;
//        dist=dist+march;
//    }
//    //if you pass the xy plane by the midpoint, nothing else to do: you've already cut the interval in half.
//}
//
//
//
//// one plane
//void raytrace1(Vector rayDir){
//    
//    hitWhich=0;
//    Vector tv=rayDir;
//    Vector testtv;
//    
//    float maxFlow=1.;
//    float tolerance=EPSILON;
//    float maxDist=40.;
//
//    bool overShoot;
//    
//    for (int i = 0; i < 100; i++){
//        testtv=flow(tv,maxFlow);//move the tangent vector ahead by our marching step
//        
//     
//        if(testtv.pos.coords.z>-2.){//if you didn't hit the plane yet
//            tv=testtv;
//            distToViewer+=maxFlow;
//            //march forward to testtv and keep going
//        }
//        else{//if you passed the plane, initiate a binary search
//            //sampletv=testtv;
//           // hitWhich=3;
//            //return;
//            
//            float binaryStepSize=maxFlow;
//            testtv=tv;//reset testtv back to where it was one step ago,before the plane
//            
//            for(int k=0;k<25;k++){//iteratively apply the bisection to get closer
//                
//            bisect1(binaryStepSize,distToViewer,testtv);//cut the interval size in half, move testtv to be on the side still not quite reaching the plane.
//            
//            if(abs(testtv.pos.coords.z+2.)<tolerance){//if you hit the xy plane 
//                sampletv=testtv;//store the final location
//                //distToViewer=0;//NEED TO MAKE THIS STILL
//                hitWhich=3;//let us know you hit the plane
//                return;//exit
//            }
//          //if you are not close enough yet, stay in the loop and keep going
//                
//            }
//        }
//        
//    }
//
//    
//}
//
////++++++++++++++++++++++++++++++++++++++++++++++++++++
////NORMAL FUNCTION FOR XY PlANE
////++++++++++++++++++++++++++++++++++++++++++++++++++++
//Vector planeNormal(Point p) {
//    
//    Isometry trans=makeInvLeftTranslation(p);//pulls p to the origin.
//    //translate the xy plane vectors to the origin:
//    vec4 vX=trans.mat*vec4(1.,0.,0.,0.);
//    vec4 vY=trans.mat*vec4(0.,1.,0.,0.);
//    
//    //find the normal to these two at the origin:
//    //here the metric is the usual one, so we can take the cross product
//    vec3 normal=cross(vX.xyz,vY.xyz);
//    normal=normalize(normal);
//    
//    //THIS IS CUSTOM ONLY FOR THE XY PLANE
//
//    Vector n=createVector(p,normal);
//   // n = tangNormalize(n);
//   // vec4 dir = n.dir;
//    return n;
//}
//
//












//----------------------------------------------------------------------------------------------------------------------
// Getting Normals, Reflectivities, etc.
//----------------------------------------------------------------------------------------------------------------------

Vector getSurfaceNormal(Point p){
    float ep=5.*EPSILON;
    vec3 bx = vec3(1.,0.,0.);
    vec3 by = vec3(0.,1.,0.);
    vec3 bz  = vec3(0.,0.,1.);
    
    float dx=sceneSDF(shiftPoint(p,bx,ep))-sceneSDF(shiftPoint(p,bx,-ep));
    float dy=sceneSDF(shiftPoint(p,by,ep))-sceneSDF(shiftPoint(p,by,-ep));
    float dz=sceneSDF(shiftPoint(p,bz,ep))-sceneSDF(shiftPoint(p,bz,-ep));
    
    vec3 n=dx*bx+dy*by+dz*bz;
    
    Vector normal=Vector(p,n);

    return tangNormalize(normal);

    
}

Vector getSurfaceNormal(Vector tv){
    Point p=tv.pos;
    return getSurfaceNormal(p);
}









