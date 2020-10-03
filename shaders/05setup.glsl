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

int inWhich=0;
int hitWhich = 0;

//set by raymarch
Vector sampletv;
float distToViewer;
bool isSky=false;


float side;
//remember which side of the object youre on when the raymarch ends


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
// materials and paths
//----------------------------------------------------------------------------------------------------------------------

//in case you need to save something 
Path extraPath;
Material extraMat;

//make our functions not have to carry around the outside material?
Material outsideMat;



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
uniform sampler2D tex;




uniform float time;

uniform float lightRad;
uniform float refl;
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

Phong defaultPhong;

Light pointLight1, pointLight2, dirLight1;



//----------------------------------------------------------------------------------------------------------------------
// Re-packaging Isometries and Positions
//----------------------------------------------------------------------------------------------------------------------


void setVariables(){
    
    currentBoost = Isometry(currentBoostMat);
    cellBoost = Isometry(cellBoostMat);
    invCellBoost = Isometry(invCellBoostMat);
    
    //nice to have a default phong value to set
    defaultPhong=Phong(10.,vec3(1.),vec3(1.));
    
}
    
    
    //--- build the lights
   void createLights(){
       
       
       
       pointLight1=createPointLight(createPoint(3.,1.,1.),vec3(1.,1.,1.),1.,0.5);
    pointLight2=createPointLight(createPoint(-2.,2.,2.),vec3(1.,1.,1.),1.,0.5);
    
    dirLight1=createDirLight(vec3(0.,0.,1.),skyColor.rgb,skyColor.w);

   }



















//----------------------------------------------------------------------------------------------------------------------
// Post-Processing Color Functions
//----------------------------------------------------------------------------------------------------------------------




vec3 LessThan(vec3 f, float value)
{
    return vec3(
        (f.x < value) ? 1.0f : 0.0f,
        (f.y < value) ? 1.0f : 0.0f,
        (f.z < value) ? 1.0f : 0.0f);
}
 
vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
     
    return mix(
        pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
        rgb * 12.92f,
        LessThan(rgb, 0.0031308f)
    );
}
 
vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);
     
    return mix(
        pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
        rgb / 12.92f,
        LessThan(rgb, 0.04045f)
    );
}



//TONE MAPPING
//takes linear color -> linear color
//call in post processing before conversion to sRGB, gamma
// ACES tone mapping curve fit to go from HDR to LDR
//https://knarkowicz.wordpress.com/2016/01/06/aces-filmic-tone-mapping-curve/
vec3 ACESFilm(vec3 x)
{
    float a = 2.51f;
    float b = 0.03f;
    float c = 2.43f;
    float d = 0.59f;
    float e = 0.14f;
    return clamp((x*(a*x + b)) / (x*(c*x + d) + e), 0.0f, 1.0f);
}


