//----------------------------------------------------------------------------------------------------------------------
// Raymarch Primitives
//----------------------------------------------------------------------------------------------------------------------


float halfSpaceY(Point p){
    return abs(p.coords.y)-0.1;
}

float halfSpaceX(Point p,float h){
    return abs(p.coords.y+h+0.1)-0.1;
}

float halfSpaceZ(Point p,float h){
   // return p.coords.z+h;
    return abs(p.coords.z+h+0.1)-0.1;
}

float sphere(Point p, Point center, float radius){
    return exactDist(p,center)-radius;
}
