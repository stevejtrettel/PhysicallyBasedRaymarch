


vec3 phong(LocalData dat, Vector toLight, float lightBrightness){

    //geometric Data:
    Vector reflectedLight = reflectOff(turnAround(toLight), dat.normal);

    float diffuseFactor = max(cosAng(toLight, dat.normal),0.);
    diffuseFactor *= (1.-dat.mat.specularProportion);
    diffuseFactor *= lightBrightness;

    float specularFactor = max(cosAng(reflectedLight, dat.toViewer),0.);
    specularFactor = pow(specularFactor, dat.mat.specularExponent);
    specularFactor *= dat.mat.specularProportion;
    specularFactor *= lightBrightness;

    vec3 ambient = ambientLight*dat.mat.diffuseColor;
    vec3 diffuse = diffuseFactor*dat.mat.diffuseColor;
    vec3 specular = specularFactor*dat.mat.specularColor;

    return ambient + diffuse + specular;
}





//return the color of the object,

vec3 getSolidColor(Path path){
    vec3 color;

    //inputs to phong model:
    vec3 lightDir=vec3(1.,-1.,1.);
    Vector toLight = Vector(path.dat.incident.pos, normalize(lightDir));

    color+=phong(path.dat, toLight,1.);

    return color;
}
