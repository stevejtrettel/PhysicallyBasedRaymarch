


//----------------------------------------------------------------------------------------------------------------------
// DOING THE RAYMARCH
//----------------------------------------------------------------------------------------------------------------------


// raymarch algorithm
// each step is the march is made from the previously achieved position (useful later for Sol).
// done with general vectors


int BINARY_SEARCH_STEPS=10;



void raymarchSimple(Vector rayDir, out Isometry totalFixIsom){
    hitWhich=0;
    distToViewer=0.;
    float marchStep = MIN_DIST;
    float depth=0.;
    Vector tv = rayDir;
    
    totalFixIsom = identity;

        for (int i = 0; i < MAX_MARCHING_STEPS; i++){
            
                float localDist = sceneSDF(tv.pos);
                if (localDist < EPSILON){
                    sampletv =tv;
                    distToViewer=depth;
                    numSteps=float(i);
                    break;
                }
                marchStep = localDist;
                depth += marchStep;
            if(depth>MAX_DIST){
                hitWhich=0;
                break;
            }
            tv = flow(tv, marchStep);
        }

}






//
//
////given two parallel planes, given by pushing the plane with normal n off the origin by +- n/2 
//float Slab(Vector tv, vec3 n, out int planeNum){
//    vec3 p=projModel(tv.pos);
//    vec3 v=tv.dir;
//   
//    float np=dot(n,p);
//    float nv=dot(n,v);
//    
//    float d=(0.5-np)/nv;
//    if(d>0.){
//        planeNum=0;
//        return d;
//    }
//    else{
//        planeNum=1;
//        return (-0.5-np)/nv;
//    }
//}
//
//void raymarchDomain(Vector rayDir, out Isometry totalFixIsom){
//    hitWhich=0;
//    distToViewer=0.;
//    float marchStep = MIN_DIST;
//    float depth=0.;
//    Vector tv = rayDir;
//    float d,d0,d1,d2;
//    int planeNum0,planeNum1,planeNum2;
//    
//    Isometry fixIsom;
//    totalFixIsom = identity;
//
//        for (int i = 0; i < MAX_MARCHING_STEPS; i++){
//            
//
//                float localDist = localSceneSDF(tv.pos);
//                if (localDist < EPSILON){
//                    sampletv =tv;
//                    distToViewer=depth;
//                    break;
//                }
//            
//            //if this is not the case, we need to flow by either localDist, OR the min dist to the walls of the domain.
//            d0=Slab(tv,nV[0],planeNum0);
//            d1=Slab(tv,nV[1],planeNum1);
//            d2=Slab(tv,nV[2],planeNum2);
//            
//            //if we do not leave the cube;
//            if(localDist<min(d0,min(d1,d2))){
//                d=localDist;
//                fixIsom=identity;
//                tv=flow(tv,d);
//            }
//            else {
//                if(d0<min(d1,d2)){//left through walls 0
//                d=d0;
//                fixIsom = Isometry(invGenerators[0+planeNum0]);
//            }
//            else if(d1<min(d0,d2)){//left through walls 1
//                d=d1;
//                fixIsom = Isometry(invGenerators[1+planeNum1]);
//                
//            }
//            else{//left through walls 2
//               d=d2;
//              fixIsom = Isometry(invGenerators[2+planeNum2]);
//            }
//                
//            
//         totalFixIsom=composeIsometry(fixIsom,totalFixIsom);
//         tv=flow(tv,d);
//         tv = translate(fixIsom, tv);
//        }
//    }
//}
//
//





void raymarch(Vector rayDir, out Isometry totalFixIsom){
   //raymarchDomain(rayDir, totalFixIsom);
    raymarchSimple(rayDir, totalFixIsom);
}











void reflectmarch(Vector rayDir, out Isometry totalFixIsom){
    
    hitWhich=0;
    distToViewer=0.;
    float marchStep = MIN_DIST;
    float depth=0.;
    Vector tv = rayDir;
    
    totalFixIsom = identity;

        for (int i = 0; i < MAX_MARCHING_STEPS; i++){
            
                float localDist = sceneSDF(tv.pos);
                if (localDist < EPSILON){
                    sampletv =tv;
                    distToViewer=depth;
                    numSteps=float(i);
                    break;
                }
                marchStep = localDist;
                depth += marchStep;
            if(depth>5.){//shorter distance 
                hitWhich=0;
                break;
            }
            tv = flow(tv, marchStep);
        }

    
    
    
    
    
}







//improving the shadows using some ideas of iq on shadertoy
float shadowmarch(in Vector toLight, float distToLight)
    {
    
    float k =40.; //parameter to determine softness of the shadows.
    
    float shade=1.;
    float localDist;
    float depth=0.;
    float marchStep;
    float newEp = EPSILON * 1.0;
    
    //start the march on the surface pointed at the light
    Vector localtv=flow(toLight,0.05);
    
    for (int i = 0; i < 40; i++){
        
            float localDist =sceneObjs(localtv.pos);
                  marchStep = 0.9*localDist;//make this distance your next march step
            depth += marchStep;//add this to the total distance traced so far
        
        localtv = flow(localtv, marchStep); 

  
            
             shade = min(shade, smoothstep(0.,1.,k*localDist/depth)); 
            //if you've hit something 
            if (localDist < newEp){//if you hit something
                return 0.;
            }
        
            if(depth>distToLight-0.1){
                break;
            }
    }    
    //at the end, return this value for the shadow deepness
    return clamp(shade,0.,1.); 
}












