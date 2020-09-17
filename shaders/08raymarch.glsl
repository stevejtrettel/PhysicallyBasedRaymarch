


//----------------------------------------------------------------------------------------------------------------------
// DOING THE RAYMARCH
//----------------------------------------------------------------------------------------------------------------------


// raymarch algorithm
// each step is the march is made from the previously achieved position (useful later for Sol).
// done with general vectors



void raymarch(Vector rayDir,Accuracy res){
    hitWhich=0;
    distToViewer=0.;
    float marchStep = 0.;
    float depth=0.;
    Vector tv = rayDir;
    
    totalFixIsom = identity;

        for (int i = 0; i < res.marchSteps; i++){
            
                float localDist = sceneSDF(tv.pos);
                if (localDist < res.threshhold){
                    sampletv =tv;
                    distToViewer=depth;
                    //numSteps=float(i);
                    break;
                }
                marchStep = localDist;
               depth += marchStep;
            if(distToViewer>res.maxDist){
                hitWhich=0;
                distToViewer=res.maxDist;
                break;
            }
            tv = flow(tv, marchStep);
        }
}














void reflectmarch(Vector rayDir, Accuracy res){
    
    hitWhich=0;
    distToViewer=0.;
    float marchStep =0.;
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












