
bool isOutsideCell(Point p, out Isometry fixIsom){
    return false;
    
}

// overload of the previous method with tangent vector
bool isOutsideCell(Vector v, out Isometry fixIsom){
    
    vec3 p=projModel(v.pos);
    
     if (dot(p, nV[0]) > dot(pV[0],nV[0])) {
        fixIsom = Isometry(invGenerators[0]);
        return true;
    }
    if (dot(p, nV[0]) < -dot(pV[0],nV[0])) {
        fixIsom = Isometry(invGenerators[1]);
        return true;
    }
    if (dot(p, nV[1]) > dot(pV[1],nV[1])) {
        fixIsom = Isometry(invGenerators[2]);
        return true;
    }
    if (dot(p, nV[1]) < -dot(pV[1],nV[1])) {
        fixIsom = Isometry(invGenerators[3]);
        return true;
    }
    
    if (dot(p, nV[2]) > dot(pV[2],nV[2])) {
            fixIsom = Isometry(invGenerators[4]);
            return true;
        }
    if (dot(p, nV[2]) < -dot(pV[2],nV[2])) {
            fixIsom = Isometry(invGenerators[5]);
            return true;
        }
    return false;
    
   return isOutsideCell(v.pos, fixIsom);
}


//raytrace distance from tv to the plane with normal plane=(q,n)
float rayTracePlane(Vector tv, Vector plane){
    vec3 p=projModel(tv.pos);
    vec3 q=projModel(plane.pos);
    vec3 v=tv.dir;
    vec3 n=plane.dir;
    
    return dot(n,q-p)/dot(n,v);
    
}

//given two parallel planes, given by pushing the plane with normal n off the origin by +- n/2 
float rayTraceSlab(Vector tv, vec3 n, out int planeNum){
    vec3 p=projModel(tv.pos);
    vec3 v=tv.dir;
   
    float np=dot(n,p);
    float nv=dot(n,v);
    
    float d=(0.5-np)/nv;
    if(d>0.){
        planeNum=0;
        return d;
    }
    else{
        planeNum=1;
        return (-0.5-np)/nv;
    }
}