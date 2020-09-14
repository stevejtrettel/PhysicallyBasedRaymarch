

//vec3 fresnel( vec3 F0, vec3 h, vec3 l ) {
//	return F0 + ( 1.0 - F0 ) * pow( clamp( 1.0 - dot( h, l ), 0.0, 1.0 ), 5.0 );
//}
//
//


//material properties are already set in the background
vec3 phong(Vector toLight, vec4 lightColor,float surfShine){
    
    fromLight=turnAround(toLight);
    reflLight=reflectOff(fromLight,surfNormal);
    
    //diffuse lighting
    float nDotL = max(cosAng(surfNormal, toLight), 0.0);
    vec3 diffuse = nDotL*lightColor.rgb*surfColor;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,surfShine));
    specular=clamp(specular,0.,1.)*lightColor.rgb;
    
    return diffuse+specular;

}



//do phong, do shadow, do everything for this light
vec3 pointLight(Point lightPos, vec4 lightColor,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    //set toLight and distToLight
    tangDirection(surfPos,lightPos,toLight,distToLight);
    fromLight=toLight;//doesnt matter here cuz isotropic
    
    ph=phong(toLight,lightColor,surfShine);
    
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toLight,distToLight,20.);
    }
    float intensity=1.;
    if(hitWhich!=1){
      intensity=3.*lightColor.w/areaDensity(distToLight,fromLight);
    }
    
    return intensity*sh*ph; 
}



vec3 dirLight(vec3 lightDir,vec4 lightColor,bool marchShadow){
    
    vec3 ph;
    float sh=1.;
    
    Vector toSky=Vector(surfPos,lightDir);
    
    Vector fromSky=turnAround(toSky);
    reflLight=reflectOff(fromSky,surfNormal);
    
    //diffuse lighting
    float nDotL = max(cosAng(surfNormal, toSky), 0.0);
    vec3 diffuse = nDotL*lightColor.rgb*surfColor;
    
    //Calculate Specular Component
    //should this be toViewer or reflectIncident?
    float rDotV = max(cosAng(reflLight, toViewer), 0.0);
    vec3 specular = vec3(pow(rDotV,surfShine));
    specular=clamp(specular,0.,1.)*surfColor;
    
    ph=diffuse+specular;
    
    ph=phong(toSky,lightColor,2.);
    if(marchShadow&&hitWhich!=1){//not the light scene
        sh=shadowmarch(toSky,100.,5.);
    }
    
     return lightColor.w*sh*ph; 
    
}



vec3 ambientLight(vec4 lightColor){
    return lightColor.w*lightColor.rgb*surfColor;
}


vec3 skyLight(vec3 lightDir, bool marchShadows){
    
   // vec4 skyColor=vec4(vec3(0.5,0.6,0.7),0.5);
    vec3 color=vec3(0.);
    
    color+=ambientLight(skyColor);
    color+=dirLight(lightDir,skyColor,false);
    return color;
}


//// phong shading
//vec3 shading( vec3 v, vec3 n, vec3 dir, vec3 eye ) {
//	// ...add lights here...
//	
//	float shininess = 16.0;
//	
//	vec3 final = vec3( 0.0 );
//	
//	vec3 ref = reflect( dir, n );
//    
//    vec3 Ks = vec3( 0.5 );
//    vec3 Kd = vec3( 1.0 );
//	
//	// light 0
//	{
//		vec3 light_pos   = vec3( 20.0, 20.0, 20.0 );
//		vec3 light_color = vec3( 1.0, 0.7, 0.7 );
//	
//		vec3 vl = normalize( light_pos - v );
//	
//		vec3 diffuse  = Kd * vec3( max( 0.0, dot( vl, n ) ) );
//		vec3 specular = vec3( max( 0.0, dot( vl, ref ) ) );
//		
//        vec3 F = fresnel( Ks, normalize( vl - dir ), vl );
//		specular = pow( specular, vec3( shininess ) );
//		
//		final += light_color * mix( diffuse, specular, F ); 
//	}
//	
//	// light 1
//	{
//		vec3 light_pos   = vec3( -20.0, -20.0, -30.0 );
//		vec3 light_color = vec3( 0.5, 0.7, 1.0 );
//	
//		vec3 vl = normalize( light_pos - v );
//	
//		vec3 diffuse  = Kd * vec3( max( 0.0, dot( vl, n ) ) );
//		vec3 specular = vec3( max( 0.0, dot( vl, ref ) ) );
//        
//        vec3 F = fresnel( Ks, normalize( vl - dir ), vl );
//		specular = pow( specular, vec3( shininess ) );
//		
//		final += light_color * mix( diffuse, specular, F );
//	}
//
//    final += texture( iChannel0, ref ).rgb * fresnel( Ks, n, -dir );
//    
//	return final;
//}
//
//
//
//
//
//
//


























vec3 basicFog( in vec3  pixelColor,      // original color of the pixel
               in float distance)// camera to point distane)  // sun light direction
{
    
    return pixelColor*exp(-distance/10.);
}


//
//vec3 skyFog( in vec3  pixelColor,      // original color of the pixel
//               in float distance, // camera to point distance
//               in Vector  rayDir,   // camera to point vector
//               in Vector sunDir )  // sun light direction
//{
//    
//    float a=0.05;
//    float b=0.05;
//    
//    float extinction = exp( -distance*a );
//    float inscatter =  1.0 - exp( -distance*b );
//    float sunAmount = max( dot( rayDir.dir, sunDir.dir ), 0.0 );
//    vec3  fogColor  = mix( vec3(0.5,0.6,0.7), // bluish
//                           vec3(1.0,0.9,0.7), // yellowish
//                           pow(sunAmount,8.0) );
//    return pixelColor*extinction + fogColor*inscatter;
//}



vec3 skyFog( in vec3  pixelColor,      // original color of the pixel
           in float distance// camera to point distance
           )  // sun light direction
{
    
    float a=60.;
    float b=60.;
    //vec3 skyColor=vec3(0.);
    
    
    float extinction = exp( -distance/a );
    float inscatter =  1.0 - exp( -distance/b );

    //return pixelColor;
    return pixelColor*extinction+ skyColor.w*skyColor.rgb*inscatter;
}








