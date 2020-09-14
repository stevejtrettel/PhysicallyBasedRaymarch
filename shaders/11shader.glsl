//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------

vec3 lighting(){
    vec3 color=vec3(0.);
    color+=phong(createPoint(1.,1.,0.),vec4(1.));
    color+=phong(createPoint(-1.,-1.,0.),vec4(1.));
    return color;
}





//----------------------------------------------------------------------------------------------------------------------
// Color from a reflection
//----------------------------------------------------------------------------------------------------------------------
//getReflColor(Vector rayDir, int hitWhich){
//    if(hitWhich==0){
//        return 
//    }
//    
//    
//}







vec3 getPixelColor(Vector rayDir){
    
    
    vec3 col0;
    vec3 ph0;
    vec2 r0;
    
    vec3 col1;
    vec3 ph1;
    vec2 r1;
    
    vec3 col2;
    vec3 ph2;
    vec2 r2;
    
    vec3 col3;
    vec3 ph3;
    
    vec3 totalColor;
    float rayDistance=0.;//distance to viewer of the first march;

    //------ DOING THE RAYMARCH ----------
    raymarch(rayDir,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
    
    //------ Basic Surface Properties ----------

    col0= skyFog(surfColor,rayDistance);
    ph0=lighting();//add lights
    r0=refl;
    
    if(refl.x>0.01){
    //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    Vector reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
        
    col1=skyFog(surfColor,rayDistance);
    ph1=lighting();
    r1=refl;
    
if(refl.x>0.01){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    col2=skyFog(surfColor,rayDistance);
    ph2=lighting(); 
    r2=refl;
    
    if(refl.x>0.01){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    col3=skyFog(surfColor,rayDistance);
    ph3=lighting();
  
        
        return  ph0+r0.y*col0+r0.x*(ph1+r1.y*col1+r1.x*(ph2+r2.y*col2+r2.x*(ph3+col3)));
                                   }
    
    
    
    else return ph0+r0.y*col0+r0.x*(ph1+r1.y*col1+r1.x*(ph2+col2));
}
        else return  ph0+(r0.y*col0+r0.x*(ph1+col1));
    }
    
    else return ph0+col0;
}
