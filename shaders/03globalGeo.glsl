//-------------------------------------------------------
// AUXILIARY (NEWTON METHOD)
//-------------------------------------------------------


const int MAX_NEWTON_INIT_ITERATION = 50;
const int MAX_NEWTON_ITERATION = 50;
const float NEWTON_INIT_TOLERANCE = 0.001;
const float NEWTON_TOLERANCE = 0.0001;


// AUXILIARY COMPUTATION TO
// - COMPUTE THE EXACT DISTANCE
// - COMPUTE THE DIRECTION OF THE SHORTEST GEODESIC FROM THE ORIGIN TO A GIVEN POINT


// Auxiliary function.
// The geodesics joining to origin to the point with cylindrical coordiantes (rho, *,z)
// are in one-to-one correspondance with the zeros of chi (see paper)
// We pass the argument rho as rho^2
float chi(float rhoSq, float z, float phi) {
    float res = -z + phi;

    if (phi < 0.001) {
        // when phi is close to zero we replace the next term by an asymptotic expansion
        float phi2 = phi * phi;
        float phi4 = phi2 * phi2;
        res = res + rhoSq * phi * (phi2 + 30.) * (phi4 + 840.) / 302400.;
    }
    else {
        float sPhiOver2 = sin(0.5 * phi);
        res = res + rhoSq * (phi - sin(phi)) / (8. * sPhiOver2 * sPhiOver2);
    }
    return res;
}

// Derivative of chi
float dchi(float rhoSq, float z, float phi) {
    float res = 1.;

    if (phi < 0.001) {
        // when phi is close to zero we replace the next term by an asymptotic expansion
        float phi2 = phi * phi;
        float phi4 = phi2 * phi2;
        float phi6 = phi4 * phi2;
        res = res + rhoSq * (25200. + 2520. * phi2 + 150. * phi4 + 7. * phi6) / 302400.;
    }
    else {
        float cPhi = cos(0.5 * phi);
        float sPhi = sin(0.5 * phi);
        res =  res - rhoSq * (phi * cPhi - 2. * sPhi) / (8. * sPhi * sPhi * sPhi);
    }
    return res;
}


// initialization of the Newthon method to find the zeros of chi
// we look for a value of phi such that
// * phiMin < phi < phiMax
// * chi(phi) > 0
// * dchi(phi) has the same as s
float zero_chi_init(float rhoSq, float z, float phiMin, float phiMax, float s) {
    float bdy;
    if (s > 0.) {
        bdy = phiMax;
    }
    else {
        bdy = phiMin;
    }
    float aux = 0.5 * phiMin + 0.5 * phiMax;
    for (int i=0; i < MAX_NEWTON_INIT_ITERATION; i++){
        if (sign(dchi(rhoSq, z, aux)) == s && chi(rhoSq, z, aux) > 0.) {
            break;
        }
        aux = 0.5 * aux + 0.5 * bdy;
    }
    return aux;
}


// find a zero phi of chi such that
// * phiMin < phi < phiMax
// * chi(phi) = 0 (of course !)
// * dchi(phi) has the same as s
// Use the Newton method.
// if such a zero is found return true and update the value of phi
// otherwise return false
bool zero_chi(float rhoSq, float z, float phiMin, float phiMax, float s, out float phi) {
    float aux = -1.;
    phi = zero_chi_init(rhoSq, z, phiMin, phiMax, s);
    for (int i=0; i < MAX_NEWTON_ITERATION; i++){
        // backup of the previous value of phi
        aux = phi;
        // new value of phi
        phi = phi - chi(rhoSq, z, phi) / dchi(rhoSq, z, phi);
        if (phi < phiMin || phi > phiMax) {
            return false;
        }
        if (sign(dchi(rhoSq, z, phi)) != s) {
            return false;
        }
        if (abs(phi - aux) < NEWTON_TOLERANCE) {
            return true;
        }
    }
    return false;
}











//----------------------------------------------------------------------------------------------------------------------
// Global Tangent Directions, Distances Etc
//----------------------------------------------------------------------------------------------------------------------


float fakeHeightSq(Point p) {
    // square of the fake height.
    // fake height : bound on the height of the ball centered at the origin passing through p
    float z = abs(p.coords.z);

    if (z < sqrt(6.)){
        return z * z;
    }
    else if (z < 4. * sqrt(3.)){
        return 12. * (pow(0.75 * z, 2. / 3.) - 1.);
    }
    else {
        return 2. * sqrt(3.) * z;
    }
}

float fakeDistance(Point p, Point q){
    // measure the distance between two points in the geometry
    // fake distance

    Isometry shift = makeInvLeftTranslation(p);
    Point qOrigin = translate(shift, q);
    // we now need the distance between the origin and p
    float x = qOrigin.coords.x;
    float y = qOrigin.coords.y;
    float rhosq = x * x + y * y;
    float hsq = fakeHeightSq(qOrigin);

    return pow(0.2 * rhosq * rhosq + 0.8 * hsq * hsq, 0.25);
}

float fakeDistance(Vector u, Vector v){
    // overload of the previous function in case we work with tangent vectors
    return fakeDistance(u.pos, v.pos);
}

float ellipsoidDistance(Point p, Point q){
    // measure the distance between two points in the geometry
    // fake distance

    Isometry shift = makeInvLeftTranslation(p);
    Point qOrigin = translate(shift, q);
    // we now need the distance between the origin and p
    float x = qOrigin.coords.x;
    float y = qOrigin.coords.y;
    float rhosq = x * x + y * y;
    float hsq = fakeHeightSq(qOrigin);

    return pow(1. * pow(rhosq, 10.) + 1. * pow(hsq, 2.), 0.25);
}

float ellipsoidDistance(Vector u, Vector v){
    // overload of the previous function in case we work with tangent vectors
    return ellipsoidDistance(u.pos, v.pos);
}


// assume that a geodesic starting from the origin reach the point q
// after describing an angle phi (in the xy plane)
// return the length of this geodesic
// the point q is given in cylinder coordiantes (rho, theta, z)
// we assume that rho > 0 and z > 0
void _lengthFromPhi(float rhoSq, float z, float phi, out float len) {
    float sPhi = sin(0.5 * phi);
    float c = 2. * sPhi / sqrt(rhoSq + 4.0 * sPhi * sPhi);
    len = abs(phi / c);
}

// assume that a geodesic starting from the origin reach the point q
// after describing an angle phi (in the xy plane)
// return the unit tangent vector of this geodesic and its length
// the point q is given in cylinder coordiantes (rho, theta, z)
// we assume that rho > 0 and z > 0
void _dirLengthFromPhi(float rhoSq, float theta, float z, float phi, out Vector dir, out float len) {
    float sPhi = sin(0.5 * phi);
    float a = sqrt(rhoSq) / sqrt(rhoSq + 4. * sPhi * sPhi);
    float c = 2. * sPhi / sqrt(rhoSq + 4. * sPhi * sPhi);
    float alpha = - 0.5 * phi + theta;
    if (sPhi <  0.) {
        alpha = alpha + PI;
    }
    dir = Vector(ORIGIN, vec3(a * cos(alpha), a * sin(alpha), abs(c)));
    dir = tangNormalize(dir);
    len = abs(phi / c);
}


// Compute the exact distance between p and q
float exactDist(Point p, Point q) {
    // move p to the origin and q accordingly
    Isometry shift = makeInvLeftTranslation(p);
    Point qOrigin = translate(shift, q);

    // if needed we flip the point qOrigin so that its z-coordinates is positive.
    // this does not change its distance to the origin
    if (qOrigin.coords.z < 0.){
        qOrigin = translate(flip, qOrigin);
    }
    float x = qOrigin.coords.x;
    float y = qOrigin.coords.y;
    float z = qOrigin.coords.z;
    float rhoSq = x * x + y * y;

    if (z == 0.) {
        // qOrigin on the xy-plane
        return sqrt(rhoSq);
    }
    else if (rhoSq == 0.){
        // qOrigin on the z-axis
        if (z < 2. * PI) {
            return z;
        }
        else {
            return 2. * PI * sqrt(z / PI - 1.);
        }
    }
    else {
        // generic position for qOrigin
        float phi;
        float length;
        zero_chi(rhoSq, z, 0., 2. * PI, 1., phi);
        _lengthFromPhi(rhoSq, z, phi, length);
        return length;
    }
}

float exactDist(Vector u, Vector v){
    // overload of the previous function in case we work with tangent vectors
    return exactDist(u.pos, v.pos);
}
















//----------------------------------------------------------------------------------------------------------------------
// THESE STILL NEED TO BE REPLACED WITH THE CORRECT FUNCTIONS: FAKE FOR NOW
//----------------------------------------------------------------------------------------------------------------------


//returns unit tangent vector t
void tangDirection(Point p, Point q, out Vector tv, out float len){
    vec4 difference=q.coords-p.coords;
    len=length(difference);
    
    vec3 dir=normalize(difference.xyz);
        
    tv=Vector(p,dir);
}

void tangDirection(Vector u, Vector v, out Vector tv, out float len){
    // overload of the previous function in case we work with tangent vectors
    tangDirection(u.pos, v.pos, tv, len);
}



















//----------------------------------------------------------------------------------------------------------------------
// THE GEODESIC FLOW
//----------------------------------------------------------------------------------------------------------------------



// flow the given vector during time t

Vector flow(Vector v, float t){
    // Follow the geodesic flow during a time t
    // If the tangent vector at the origin is too close to the XY plane,
    // we use an asymptotic expansion of the geodesics.
    // This help to get rid of the noise around the XY plane
    // The threshold is given by the tolerance parameter
    float tolerance = 0.1;


    // move p to the origin
    Isometry shift = makeLeftTranslation(v.pos);

    // vector at the origin
    Vector vOrigin = Vector(ORIGIN, v.dir);

    // solve the problem !
    float c = vOrigin.dir.z;
    float a = sqrt(1. - c * c);
    // float alpha = fixedatan(tvOrigin.dir.y, tvOrigin.dir.x);
    float alpha = atan(vOrigin.dir.y, vOrigin.dir.x);

    Vector achievedFromOrigin;

    if (abs(c * t) < tolerance){
        // use an asymptotic expansion (computed with SageMath)

        // factorize some computations...
        float cosa = cos(alpha);
        float sina = sin(alpha);
        float t1 = t;
        float t2 = t1 * t;
        float t3 = t2 * t;
        float t4 = t3 * t;
        float t5 = t4 * t;
        float t6 = t5 * t;
        float t7 = t6 * t;
        float t8 = t7 * t;
        float t9 = t8 * t;

        float c1 = c;
        float c2 = c1 * c;
        float c3 = c2 * c;
        float c4 = c3 * c;
        float c5 = c4 * c;
        float c6 = c5 * c;
        float c7 = c6 * c;



        achievedFromOrigin.pos = Point(vec4(
        a * t1 * cosa
        - (1. / 2.) * a * t2 * c1 * sina
        - (1. / 6.) * a * t3 * c2 * cosa
        + (1. / 24.) * a * t4 * c3 * sina
        + (1. / 120.) * a * t5 * c4 * cosa
        - (1. / 720.) * a * t6 * c5 * sina
        - (1. / 5040.) * a * t7 * c6 * cosa
        + (1. / 40320.) * a * t8 * c7 * sina,

        a * t * sina
        + (1. / 2.) * a * t2 * c1 * cosa
        - (1. / 6.) * a * t3 * c2 * sina
        - (1. / 24.) * a * t4 * c3 * cosa
        + (1. / 120.) * a * t5 * c4 * sina
        + (1. / 720.) * a * t6 * c5 * cosa
        - (1. / 5040.) * a * t7 * c6 * sina
        - (1. / 40320.) * a * t8 * c7 * cosa,

        (1. / 12.) * (a * a * t3 + 12. * t1) * c1
        - (1. / 240.) * a * a * t5 * c3
        + (1. / 10080.) * a * a * t7 * c5
        - (1. / 725760.) * a * a * t9 * c7,

        1));
    }

    /*
        For the record, the previous test without the asymptotic expansion

        if (c == 0.) {

            achievedFromOrigin.pos = Point(vec4(a * cos(theta) * t, a * sin(theta) * t, 0. , 1.));
            //achievedFromOrigin.dir = tvOrigin.dir;
    }
    */

    else {
        achievedFromOrigin.pos = Point(vec4(
        2. * (a / c) * sin(0.5 * c * t) * cos(0.5 * c * t + alpha),
        2. * (a / c) * sin(0.5 * c * t) * sin(0.5 * c * t + alpha),
        c * t + 0.5 * pow(a / c, 2.) * (c * t - sin(c * t)),
        1.
        ));
    }

    // there is case distinction for the direction (pulled back at the origin)
    achievedFromOrigin.dir = vec3(a * cos(c * t + alpha), a * sin(c * t + alpha), c);

    // move back to p
    return translate(shift, achievedFromOrigin);
}






//maybe this is too much work to do a flow here?
//replace with a fake thing?
void nudge(inout Vector v){
    v=flow(v,0.01);
}









//----------------------------------------------------------------------------------------------------------------------
// Area Density  (ALSO FAKE RIGHT NOW)
//----------------------------------------------------------------------------------------------------------------------


//takes in a tangent vector and a length
// returns the function A(r,u)



float areaDensity(float r,Vector u){
    
    float areaDensity=r*r;
    
    return areaDensity;
    
}




