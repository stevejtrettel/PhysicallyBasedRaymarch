//----------------------------------------------------------------------------------------------------------------------
// The Lights in the Scene
//----------------------------------------------------------------------------------------------------------------------
vec3 ambLights(bool marchShadow){
    
    vec3 color=vec3(0.);
    
    color+=ambientLight(vec4(1.,1.,1.,0.7));
    
    color+=dirLight(vec3(0.,0.,1.),vec4(1.,1.,1.,0.2),true);

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
    
    vec3 totalColor;
    float rayDistance=0.;//distance to viewer of the first march;

    //------ DOING THE RAYMARCH ----------
    raymarch(rayDir,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
    
    //------ Basic Surface Properties ----------
    if(lightThis==0){
        totalColor=surfColor;
    }
    else{
    col0=ambLights(true);
    ph0=sceneLights(true);//add lights
    //r0=refl;
    //vec3 s0=normalize(surfColor);

    totalColor= ph0+col0;
    totalColor=skyFog(totalColor,distToViewer);
    }
    

    return totalColor;
}




