
//---------LocalData-------------
//-- store local data at the intersection point along a path
//-------------------------------

struct LocalData{

    bool hitSky;
    bool inVolumetric;
    Material mat;
    Vector incident;
    Vector normal;
    Vector toViewer;

};


LocalData initializeData(){
    LocalData dat;
    dat.hitSky=false;
    dat.inVolumetric=false;
    //the rest are undefined right now
    return dat;
}



//---------Path-------------
//-- store information needed for tracing along a path
//-------------------------------

struct Path{
    Vector tv;
    LocalData dat;
    bool keepGoing;

};


Path initializePath( Vector rayDir){
    Path path;

    path.keepGoing=true;
    path.tv=rayDir;
    path.dat=initializeData();
    return path;
}
