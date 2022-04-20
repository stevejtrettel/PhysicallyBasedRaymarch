
//-------------------------------------------------
//The MATERIAL Struct
//every solid has a material, and an SDF
//-------------------------------------------------


struct Material{
    bool render;
    vec3 emitColor;
    vec3 diffuseColor;
    vec3 specularColor;
    float specularExponent;
    float specularProportion;

};


Material setMetal(vec3 color){
    Material mat;

    mat.render=true;
    mat.emitColor=vec3(0.);
    mat.diffuseColor=color;
    mat.specularColor=color;
    mat.specularExponent=15.;
    mat.specularProportion=0.5;

    return mat;
}

Material setDielectric(vec3 color){
    Material mat;

    mat.render=true;
    mat.emitColor=vec3(0.);
    mat.diffuseColor=color;
    mat.specularColor=vec3(1.);
    mat.specularExponent=5.;
    mat.specularProportion=0.3;

    return mat;
}





