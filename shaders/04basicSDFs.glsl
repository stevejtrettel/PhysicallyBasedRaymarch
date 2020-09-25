//----------------------------------------------------------------------------------------------------------------------
// Smooth Mins, Maxes
//----------------------------------------------------------------------------------------------------------------------



float smin( float a, float b, float k )
{
    float h = max( k-abs(a-b), 0.0 )/k;
    return min( a, b ) - h*h*h*k*(1.0/6.0);
}



float smax( float a, float b, float k )
{
    return -smin(-a,-b,k);
}









//----------------------------------------------------------------------------------------------------------------------
// Raymarch Primitives
//----------------------------------------------------------------------------------------------------------------------


float halfSpaceY(Point p,float h){
    return p.coords.y+h;
}

float halfSpaceX(Point p,float h){
    return p.coords.x+h;
}

float halfSpaceZ(Point p,float h){
   return p.coords.z+h;
}



float slabY(Point p,float offset, float width){
    return abs(p.coords.y+offset+width)-width;
}

float slabX(Point p,float offset, float width){
    return abs(p.coords.x+offset+width)-width;
}

float slabZ(Point p,float offset, float width){
    return abs(p.coords.z+offset+width)-width;
}


float vertCyl(Point p, Point center, float radius){
    return length(p.coords.xy-center.coords.xy)-radius;

}
float sphere(Point p, Point center, float radius){
    return exactDist(p,center)-radius;
}




//----------------------------------------------------------------------------------------------------------------------
// from  IQ: 
//https://iquilezles.org/www/articles/distfunctions/distfunctions.htm
//----------------------------------------------------------------------------------------------------------------------
float dot2( in vec2 v ) { return dot(v,v); }
float dot2( in vec3 v ) { return dot(v,v); }
float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }


float sdBox( Point pt, Point cent,vec3 b )
    {
    vec3 p=pt.coords.xyz-cent.coords.xyz;
    
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
    }



float sdRoundBox( Point pt, Point cent,vec3 b, float r )
    {
        vec3 p=pt.coords.xyz-cent.coords.xyz;
        vec3 q = abs(p) - b;
        return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
    }


float sdTorus( Point pt, Point cent, vec2 t )
{
    vec3 p=pt.coords.xyz-cent.coords.xyz;
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float sdRoundedCylinder( Point pt, Point cent,float ra, float rb, float h )
{vec3 p=pt.coords.xyz-cent.coords.xyz;
  vec2 d = vec2( length(p.xz)-2.0*ra+rb, abs(p.y) - h );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - rb;
}


float sdOctahedron( Point pt, Point cent,float s)
{ vec3 p=pt.coords.xyz-cent.coords.xyz;
  p = abs(p);
  return (p.x+p.y+p.z-s)*0.57735027;
}




float trueOctahedron( Point pt, Point cent,float s)
{
vec3 p=abs(pt.coords.xyz-cent.coords.xyz);
  float m = p.x+p.y+p.z-s;
  vec3 q;
       if( 3.0*p.x < m ) q = p.xyz;
  else if( 3.0*p.y < m ) q = p.yzx;
  else if( 3.0*p.z < m ) q = p.zxy;
  else return m*0.57735027;
    
  float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
  return length(vec3(q.x,q.y-s+k,q.z-k)); 
}
















float block(Point p, Point center, float x, float y, float z){

//make the slab
float distance;
distance=slabX(p,center.coords.x,x);
distance=smax(distance,slabY(p,center.coords.y,y),0.1);    
distance=smax(distance,slabZ(p,center.coords.z,z),0.1);      
return distance;
}

float cube(Point p, Point center, float s){
    return block(p,center,s,s,s);
}



