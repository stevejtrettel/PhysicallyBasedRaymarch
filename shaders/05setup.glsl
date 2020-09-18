//----------------------------------------------------------------------------------------------------------------------
// PARAMETERS
//----------------------------------------------------------------------------------------------------------------------
float test;
vec2 test2;
vec3 test3;
vec4 test4;
/*

Some parameters that can be changed to change the scence
*/

//----------------------------------------------------------------------------------------------------------------------
// "TRUE" CONSTANTS
//----------------------------------------------------------------------------------------------------------------------

const float PI = 3.1415926538;
const float sqrt3 = 1.7320508075688772;
const float sqrt2 = 1.4142135623730951;


//----------------------------------------------------------------------------------------------------------------------
// Global Constants
//----------------------------------------------------------------------------------------------------------------------
float MAX_DIST = 30.0;

void setResolution(int UIVar){
//use this to reset MAX MARCHING, etc...
}

const float EPSILON = 0.0001;
const float fov = 90.0;



//----------------------------------------------------------------------------------------------------------------------
// Global Variables
//----------------------------------------------------------------------------------------------------------------------

int hitWhich = 0;
Vector sampletv;
float distToViewer;



//----------------------------------------------------------------------------------------------------------------------
// Stuff For the Tiling
//----------------------------------------------------------------------------------------------------------------------

//Isometry gens[6];
//int numGens;
//
////normal vector to faces in the affine model fundamental domain
//uniform vec3 nV[3];
////face pairing in affine model fundamental domain
//uniform vec3 pV[3];
//
//








//----------------------------------------------------------------------------------------------------------------------
// Phong Shading Stuff
//----------------------------------------------------------------------------------------------------------------------

Vector toLight;
float distToLight;
Vector fromLight;
Vector reflLight;
Vector atLight;
vec4 colorOfLight;
vec3 colorOfLight3;







//----------------------------------------------------------------------------------------------------------------------
// Translation & Utility Variables
//----------------------------------------------------------------------------------------------------------------------
uniform vec2 screenResolution;
uniform mat4 invGenerators[6];//

uniform mat4 currentBoostMat;
uniform mat4 facing;

uniform mat4 cellBoostMat;
uniform mat4 invCellBoostMat;

Isometry currentBoost;
Isometry cellBoost;
Isometry invCellBoost;








//----------------------------------------------------------------------------------------------------------------------
// Lighting Variables & Global Object Variables
//----------------------------------------------------------------------------------------------------------------------
uniform vec4 lightPositions[4];
uniform vec4 lightIntensities[4];

//uniform mat4 globalObjectBoostMat;
//uniform float globalSphereRad;

uniform samplerCube earthCubeTex;
uniform float time;
//uniform float lightRad;
//uniform float refl;
uniform float foggy;
uniform int planes;
uniform int resol;

uniform int display;
//1=CorrLight;
//2=ConstIntensity;
//3=NoLight








//----------------------------------------------------------------------------------------------------------------------
// Re-packaging Light Sources
//----------------------------------------------------------------------------------------------------------------------


//color of the sky
//vec4 skyColor=vec4(0.,0.,0.,1.);
vec4 skyColor=vec4(0.5,0.6,0.7,.8);


Light pointLight1, pointLight2, dirLight1;



//----------------------------------------------------------------------------------------------------------------------
// Re-packaging Isometries and Positions
//----------------------------------------------------------------------------------------------------------------------


void setVariables(){
    
    currentBoost = Isometry(currentBoostMat);
    cellBoost = Isometry(cellBoostMat);
    invCellBoost = Isometry(invCellBoostMat);
    
}
    
    
    //--- build the lights
   void createLights(){
       pointLight1=createPointLight(createPoint(1.,1.,1.),vec3(1.,1.,1.),1.,0.2);
    pointLight2=createPointLight(createPoint(-1.,-1.,0.),vec3(1.,1.,1.),1.,0.2);
    
    dirLight1=createDirLight(vec3(0.,0.,1.),skyColor.rgb,skyColor.w);

   }


