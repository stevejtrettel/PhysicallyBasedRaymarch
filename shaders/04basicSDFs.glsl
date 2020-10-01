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

//
//float halfSpaceY(Point p,float h){
//    return p.coords.y+h;
//}
//
//float halfSpaceX(Point p,float h){
//    return p.coords.x+h;
//}
//
//float halfSpaceZ(Point p,float h){
//   return p.coords.z+h;
//}
//
//
//
//float slabY(Point p,float offset, float width){
//    return abs(p.coords.y+offset+width)-width;
//}
//
//float slabX(Point p,float offset, float width){
//    return abs(p.coords.x+offset+width)-width;
//}
//
//float slabZ(Point p,float offset, float width){
//    return abs(p.coords.z+offset+width)-width;
//}
//
//
//float vertCyl(Point p, Point center, float radius){
//    return length(p.coords.xy-center.coords.xy)-radius;
//
//}


float fakeSphere(Point p, Point center, float radius){
     float fakeDist = fakeDistance(p, center); 
    return fakeDist - radius;
}

bool FAKE_DIST_SPHERE=false;

float sphere(Point p, Point center, float radius){
    // more precise computation
    float fakeDist = fakeDistance(p, center);

    if (FAKE_DIST_SPHERE) {
        return fakeDist - radius;
    }
    else {
        if (fakeDist > 10. * radius) {
            return fakeDist - radius;
        }
        else {
            return exactDist(p, center) - radius;
        }
    }
}

float ellipsoidSDF(Point p, Point center, float radius){
    return ellipsoidDistance(p, center)-radius;
}


float hSpaceY(Point p, float offset, float thickness){
    
    return abs(p.coords.y-offset+thickness)-thickness;
}




