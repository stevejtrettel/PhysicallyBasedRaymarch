//----------------------------------------------------------------------------------------------------------------------
// PARAMETERS
//----------------------------------------------------------------------------------------------------------------------

/*

Some parameters that can be changed to change the scence
*/

//----------------------------------------------------------------------------------------------------------------------
// "TRUE" CONSTANTS
//----------------------------------------------------------------------------------------------------------------------

const float PI = 3.1415926538;
const float sqrt3 = 1.7320508075688772;
const float sqrt2 = 1.4142135623730951;

vec3 debugColor = vec3(0.5, 0, 0.8);



//----------------------------------------------------------------------------------------------------------------------
// Global Constants
//----------------------------------------------------------------------------------------------------------------------
int MAX_MARCHING_STEPS =  400;
const float MIN_DIST = 0.0;
float MAX_DIST = 200.0;


void setResolution(int UIVar){
//use this to reset MAX MARCHING, etc...
}

const float EPSILON = 0.0001;
const float fov = 90.0;



//----------------------------------------------------------------------------------------------------------------------
// Global Variables
//----------------------------------------------------------------------------------------------------------------------

int hitWhich = 0;
bool isLocal=true;




Vector N;//normal vector
Vector sampletv;
vec4 globalLightColor;
Isometry currentBoost;
Isometry cellBoost;
Isometry invCellBoost;
Isometry globalObjectBoost;


Isometry gens[11];
int numGens;

Point surfacePosition;
Vector toLight;
Vector atLight;
Vector toViewer;
Vector surfNormal;
float surfRefl;
Isometry totalFixIsom;
float distToViewer;
float distToLight;

//----------------------------------------------------------------------------------------------------------------------
// Translation & Utility Variables
//----------------------------------------------------------------------------------------------------------------------
uniform vec2 screenResolution;
uniform vec4 invGenerators[10];//

uniform mat4 currentBoostMat;
uniform mat4 facing;

uniform mat4 cellBoostMat;
uniform mat4 invCellBoostMat;

//----------------------------------------------------------------------------------------------------------------------
// Lighting Variables & Global Object Variables
//----------------------------------------------------------------------------------------------------------------------
uniform vec4 lightPositions[4];
uniform vec4 lightIntensities[4];

uniform mat4 globalObjectBoostMat;
uniform float globalSphereRad;

uniform samplerCube earthCubeTex;
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
// Re-packaging isometries, facings in the shader
//----------------------------------------------------------------------------------------------------------------------


//adding one local light (more to follow)
Point localLightPos;
vec4 localLightColor=vec4(1., 1., 1., 0.2);

//variable which sets the light colors for drawing in hitWhich 1
vec3 colorOfLight=vec3(1., 1., 1.);




void setVariables(){
     
   totalFixIsom=identity;
    currentBoost = Isometry(currentBoostMat);
    cellBoost = Isometry(cellBoostMat);
    invCellBoost = Isometry(invCellBoostMat);
    globalObjectBoost = Isometry(globalObjectBoostMat);
}

