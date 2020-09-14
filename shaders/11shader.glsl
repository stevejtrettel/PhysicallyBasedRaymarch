//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------

vec3 lighting(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    //color+=0.2*ambientLight();
    
   // color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.1),false);
    color+=pointLight(createPoint(1.,1.,0.),vec4(1,1.,1.,0.5),marchShadow);
    color+=pointLight(createPoint(-1.,-1.,0.),vec4(1.,1.,1.,0.5),marchShadow);
    
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

    col0=skyLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.3),false);
    col0= skyFog(col0,rayDistance);
    ph0=lighting(true);//add lights
    r0=refl;
    //distToLight and toLight are set already

    
    if(refl.x>0.01){
    //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    Vector reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
    
    col1=skyLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.3),false);
    col1=skyFog(col1,rayDistance);
    ph1=lighting(false);
    r1=refl;
    
if(refl.x>0.01){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    col1=skyLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.3),false);
    col2=skyFog(col2,rayDistance);
    ph2=lighting(false); 
    r2=refl;
    
    totalColor=ph0+r0.y*col0+r0.x*(ph1+r1.y*col1+r1.x*(ph2+col2));
}
        else totalColor=ph0+(r0.y*col0+r0.x*(ph1+col1));
    }
    
    else  totalColor= ph0+col0;
    
    
    return totalColor;
}




