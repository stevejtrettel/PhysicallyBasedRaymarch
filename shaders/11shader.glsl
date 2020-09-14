//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------
vec3 ambLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.4));
    
    color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.2),false);

    return color;
}





vec3 sceneLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=pointLight(createPoint(1.,1.,1.),vec4(1,1.,1.,1.),marchShadow);
    color+=pointLight(createPoint(-1.,-1.,0.),vec4(1.,1.,1.,1.),marchShadow);
    
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

    col0=ambLights(true);
    col0= skyFog(col0,rayDistance);
    ph0=sceneLights(true);//add lights
    ph0=skyFog(ph0,rayDistance);
    r0=refl;
    vec3 s0=normalize(surfColor);
    //distToLight and toLight are set already

    
    if(refl.x>0.01){
    //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    Vector reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
    
    col1=ambLights(true);
    col1=skyFog(col1,rayDistance);
        
    ph1=sceneLights(true);
    ph1=skyFog(ph1,rayDistance);    
    r1=refl;
    vec3 s1=normalize(vec3(0.1)+surfColor);
    
if(refl.x>0.01){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    col2=ambLights(false);
    col2=skyFog(col2,rayDistance);
    ph2=sceneLights(false); 
    ph2=skyFog(ph2,rayDistance);
    r2=refl;
    vec3 s2=normalize(vec3(0.1)+surfColor);
    
    if(refl.x>0.01){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    reflectmarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    col3=ambLights(false);
    col3=skyFog(col3,rayDistance);
    ph3=sceneLights(false);
    ph3=skyFog(ph3,rayDistance);
    
    totalColor=ph0+(r0.y*col0+s0*r0.x*(ph1+r1.y*col1+s1*r1.x*(ph2+r2.y*col2+s2*r2.x*(ph3+col3))));
    
    }
    
    
    else totalColor=ph0+(r0.y*col0+s0*r0.x*(ph1+r1.y*col1+s1*r1.x*(ph2+col2)));
}
        else totalColor=ph0+(r0.y*col0+s0*r0.x*(ph1+col1));
    }
    
    else  totalColor= ph0+col0;
    

    return totalColor;
}




