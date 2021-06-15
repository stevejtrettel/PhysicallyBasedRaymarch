
//----------------------------------------------------------------------------------------------------------------------
// Struct Light
//----------------------------------------------------------------------------------------------------------------------

struct Light{
    Point pos;//position of light (point source)
    vec3 dir;//direction to light (directional)
    vec3 color;//color of light
    float intensity;//intensity of light
    float radius;//radius of ball for point source
};

Light createPointLight(Point pos, vec3 color, float intensity, float radius){
    Light light;
    light.pos=pos;
    light.color=color;
    light.intensity=intensity;
    light.radius=radius;
    return light;
}


Light createDirLight(vec3 dir, vec3 color, float intensity){
    Light light;
    light.dir=dir;
    light.color=color;
    light.intensity=intensity;
    return light;
}



Light pointLight1, pointLight2, dirLight1;

//--- build the lights
void createLights(){

    pointLight1=createPointLight(createPoint(3.,1.,1.),vec3(1.,1.,1.),1.,0.5);
    pointLight2=createPointLight(createPoint(-2.,2.,2.),vec3(1.,1.,1.),1.,0.5);

    dirLight1=createDirLight(vec3(0.,0.,1.),skyColor.rgb,skyColor.w);

}








//----------------------------------------------------------------------------------------------------------------------
// Struct Phong
//----------------------------------------------------------------------------------------------------------------------


struct Phong{
    float shiny;
    vec3 diffuse;
    vec3 specular;
};

//some default values
const Phong noPhong=Phong(1.,vec3(1.),vec3(1.));
const Phong defaultPhong=Phong(10.,vec3(1.),vec3(1.));



