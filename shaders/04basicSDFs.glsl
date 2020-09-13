//----------------------------------------------------------------------------------------------------------------------
// Raymarch Primitives
//----------------------------------------------------------------------------------------------------------------------


float halfSpaceY(Point p){
    return abs(p.coords.y)-0.1;
}

float sphere(Point p, Point center, float radius){
    return exactDist(p,center)-radius;
}
