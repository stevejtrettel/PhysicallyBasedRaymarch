


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
                    isSky=false;
                    distToViewer=depth;
                    break;
                }
                marchStep =localDist;
               depth += marchStep;
            if(depth>res.maxDist){
                sampletv=tv;
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

















//----------------------------------------------------------------------------------------------------------------------
// Marching Through NonConstant Media
//----------------------------------------------------------------------------------------------------------------------

void refractTrace(Vector tv){
    //raytrace until you are a certain distance from the original viewer, then stop and set sampletv
    
    //set dt
    float dt=0.01;
    //set number of steps
    int numSteps=500;
    
    //set initial conditions
    float x,y,z;//position
    float u,v,w;//direction
    
    vec3 p=tv.pos.coords.xyz;
    vec3 dir=tv.dir;    
    
    //first; maybe just raytrace a fixed number of steps:
    for(int k=0;k<numSteps;k++){
        
        //update the direction based on the position:
        p+=dt*dir;
        
        //update direction
        dir+=dt*gradN(p);
    }
    
    //after march; build final tangent vector
Vector finalV;
    finalV.pos.coords=vec4(p,1.);
    finalV.dir=dir;
    
    sampletv=finalV;
    distToViewer=float(numSteps)*dt;
    
}





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









