
//----------------------------------------------------------------------------------------------------------------------
// Struct Material Properties
//----------------------------------------------------------------------------------------------------------------------

//Data type for storing the parameters of a material: its index of refraction, reflectivity, transparency, color, etc.

//materials have surface properties,
//and also volume properties.
struct Material{
    vec3 color;
    Phong phong;
    float reflect;
    float opacity;
    float refract;
    vec3 disperse;
    float translucent;
    vec3 absorb;
    vec3 emit;
};


//defining the constant material air:
Material air=Material(vec3(0),noPhong,0.,0.,1.,vec3(1.),1.,vec3(0),vec3(0));



Material setGlass(){
    Material mat;

    mat.color=vec3(0.05);
    mat.phong.shiny=15.;
    mat.reflect=0.08;
    mat.opacity=0.05;

    mat.refract=1.53;
    mat.disperse=vec3(1.51,1.52,1.53);
    mat.translucent=0.;
    mat.absorb=vec3(0.3,0.05,0.2);
    mat.emit=vec3(0.);
    return mat;

}


//----------------------------------------------------------------------------------------------------------------------
// Coloring functions
//----------------------------------------------------------------------------------------------------------------------

vec3 checkerboard(vec2 v){
    float x=mod(v.x,2.);
    float y=mod(v.y,2.);

    if(x<1.&&y<1.||x>1.&&y>1.){
        return vec3(0.7);
    }
    else return vec3(0.2);
}




vec2 toSphCoords(vec3 v){
    float theta=atan(v.y,v.x);
    float phi=acos(v.z);
    return vec2(theta,phi);
}



vec3 skyTex(Vector tv){

    vec2 angles=toSphCoords(tv.dir);
    float x=(angles.x+3.1415)/(2.*3.1415);
    float y=1.-angles.y/3.1415;

    //the vec00 are the derivative mappings: get rid of seam!
    return textureGrad(tex,vec2(x,y),vec2(0,0),vec2(0,0)).rgb;

}


void setSkyMaterial(inout Material mat, Vector tv){
    mat=air;
    //mat.surf.opacity=0.;
    mat.color=SRGBToLinear(skyTex(sampletv));
    mat.absorb=vec3(0.);
}









