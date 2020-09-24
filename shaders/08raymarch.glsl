


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

    distToViewer=0.;
    float marchStep = 0.;
    float depth=0.;

        for (int i = 0; i < res.marchSteps; i++){
            
                float localDist = side*sceneSDF(tv.pos);
            //this could be negative; side sets this.
                if (localDist < res.threshhold){
                    sampletv =tv;
                    distToViewer=depth;
                    break;
                }
                marchStep =localDist;
               depth += marchStep;
            if(depth>res.maxDist){
                sampletv=tv;
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








