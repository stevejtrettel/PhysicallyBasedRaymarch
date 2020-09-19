//----------------------------------------------------------------------------------------------------------------------
// Tangent Space Functions
//----------------------------------------------------------------------------------------------------------------------

Vector getRayPoint(vec2 resolution, vec2 fragCoord){ //creates a tangent vector for our ray

    vec2 xy = 0.2 * ((fragCoord - 0.5*resolution)/resolution.x);
    float z = 0.1 / tan(radians(fov * 0.5));
    // coordinates in the prefered frame at the origin
    vec3 dir = vec3(xy, -z);
    Vector tv = Vector(ORIGIN, dir);
    tv = tangNormalize(tv);
    return tv;
}




//----------------------------------------------------------------------------------------------------------------------
// Setup
//----------------------------------------------------------------------------------------------------------------------


Vector setRayDir(){


    Vector rayDir = getRayPoint(screenResolution, gl_FragCoord.xy);

        rayDir = rotateByFacing(facing, rayDir);
        rayDir = translate(currentBoost, rayDir);


return rayDir;
}









//----------------------------------------------------------------------------------------------------------------------
// Main
//----------------------------------------------------------------------------------------------------------------------


void main(){

     
    
    setVariables();
    createLights();
    
    //generators(display,gens);
   // setResolution(resol);
    
    Vector rayDir=setRayDir();
    
    
//do the first raymarch and get the color
    vec3 pixelColor=getPixelColorGlass(rayDir);
   
   //do the post processing: gamma correction
   pixelColor= pow( pixelColor, vec3(1.0/2.2) );
   
    out_FragColor=vec4(pixelColor,1.);
    

}