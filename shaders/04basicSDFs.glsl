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


float vertCyl(Point p, Point center, float radius){
    return length(p.coords.xy-center.coords.xy)-radius;

}
float sphere(Point p, Point center, float radius){
    return exactDist(p,center)-radius;
}
