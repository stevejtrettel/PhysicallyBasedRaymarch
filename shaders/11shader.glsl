

//----------------------------------------------------------------------------------------------------------------------
// Color at the end of a single raymarch
//----------------------------------------------------------------------------------------------------------------------
//getReflColor(Vector rayDir, int hitWhich){
//    if(hitWhich==0){
//        return 
//    }
//    
//    
//}
//
//
//







vec3 getPixelColor(Vector rayDir){
    
    vec3 baseColor;//color of the surface where it is struck
    vec3 reflectColor;
    vec3 reflectColor2;
    vec3 reflectColor3;
    float rayDistance=0.;//distance to viewer of the first march;

    //------ DOING THE RAYMARCH ----------
    raymarch(rayDir,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
    
    //------ Basic Surface Properties ----------

baseColor= skyFog(surfColor,rayDistance);
    
baseColor+=phong(createPoint(1.,1.,0.),vec4(1.));
     baseColor+=phong(createPoint(1.,-1.,0.),vec4(vec3(0.5,0.3,0.1),1.));
    
    if(hitWhich!=0){
    //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    Vector reflectedRay=flow(reflectIncident,0.1);
    
    raymarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled
        
    reflectColor=skyFog(surfColor,rayDistance);
    reflectColor+=phong(createPoint(1.,1.,0.),vec4(1.));
    reflectColor+=phong(createPoint(1.,-1.,0.),vec4(vec3(0.5,0.3,0.1),1.));
    
    
if(hitWhich!=0){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    raymarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    reflectColor2=skyFog(surfColor,rayDistance);
    reflectColor2+=phong(createPoint(1.,1.,0.),vec4(1.));
    reflectColor2+=phong(createPoint(1.,-1.,0.),vec4(vec3(0.5,0.3,0.1),1.));
    
    if(hitWhich!=0){
        //-----DO A REFLECTION
    //Vector surfNormal=surfaceNormal(sampletv);
    reflectedRay=flow(reflectIncident,0.1);
    
    raymarch(reflectedRay,totalFixIsom);
    surfaceData(sampletv,hitWhich);//set all the local data
    
    rayDistance+=distToViewer;//accumulate distance travelled

    reflectColor3=skyFog(surfColor,rayDistance);
    reflectColor3+=phong(createPoint(1.,1.,0.),vec4(1.));
    reflectColor3+=phong(createPoint(1.,-1.,0.),vec4(vec3(0.5,0.3,0.1),1.));
        
        return  0.5*baseColor+0.5*(0.5*reflectColor+0.5*(0.5*reflectColor2+0.5*reflectColor3));
                                   }
    
    
    
    else return 0.5*baseColor+0.5*(0.5*reflectColor+0.5*reflectColor2);
}
        else return  0.5*baseColor+0.5*reflectColor;
    }
    
    else return baseColor;
}
