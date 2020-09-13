

//----------------------------------------------------------------------------------------------------------------------
// Color at the end of a single raymarch
//----------------------------------------------------------------------------------------------------------------------


vec3 getPixelColor(Vector rayDir){
    
    Isometry fixPosition=identity;
    
    vec3 baseColor;//color of the surface where it is struck

    //------ DOING THE RAYMARCH ----------
    raymarch(rayDir,totalFixIsom);
    
    //------ Basic Surface Properties ----------
    baseColor=materialColor(hitWhich);  
    
    
    
    
    //apply fog
    return skyFog(baseColor,distToViewer,turnAround(sampletv),Vector(sampletv.pos,vec3(0.,0.,1.)));
    //return basicFog(baseColor,distToViewer);
    //return exp(-distToViewer/5.)*baseColor+(1.-exp(-distToViewer/5.))*vec3(0.5,0.6,0.7);
}
