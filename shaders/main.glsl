
//----------------------------------------------------------------------------------------------------------------------
// Setup
//----------------------------------------------------------------------------------------------------------------------

Vector setRayDir(){

    Isometry currentBoost=Isometry(currentBoostMat);
    Vector rayDir = getRayPoint(screenResolution, gl_FragCoord.xy);

        rayDir = rotateByFacing(facing, rayDir);
        rayDir = translate(currentBoost, rayDir);

return rayDir;

}



//----------------------------------------------------------------------------------------------------------------------
// Main
//----------------------------------------------------------------------------------------------------------------------


void main(){
    
    Vector rayDir=setRayDir();

    createLights();
    buildScene();
    
    //do the first raymarch and get the color
    vec3 pixelColor=getPixelColor(rayDir);
    pixelColor=postProcess(pixelColor,1.25);

    out_FragColor=vec4(pixelColor,1.);

}