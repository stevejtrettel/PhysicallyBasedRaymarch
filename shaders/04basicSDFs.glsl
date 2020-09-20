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


float cylBlock(Point p, Point center, float radius, float height){
    float d1=vertCyl(p,center,radius);
    float d2=slabZ(p,center.coords.z,height);
    return smax(d1,d2,0.1);
}



float sphere(Point p, Point center, float radius){
    return exactDist(p,center)-radius;
}






//====== build a cocktail glass!
float cocktailGlass(Point p){
    
    Point center1=createPoint(2.,1.,-1.);
    Point center2=createPoint(2.,1.,-1.45);
    Point center3=createPoint(2.,1.,-.8);
    float radius=1.;
    float height=1.;
    
    
    float cyl1=cylBlock(p,center1, radius, height);
    float cyl2=cylBlock(p,center2, 0.9*radius,height);
    
    float cup=smax(cyl1,-cyl2,0.1);
    
    float ball=sphere(p,center3,0.18);
    
    return smax(cup,-ball,0.2);
    
    
}




float liquid(Point p){
    
    
    Point center2=createPoint(2.,1.,-.1);

    float radius=0.89;
    float height=0.3;
    
    float cyl2=cylBlock(p,center2, radius,height);
    return cyl2;

}