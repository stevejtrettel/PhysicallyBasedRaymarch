

//----------------------------------------------------------------------------------------------------------------------
// DOING THE RAYMARCH
//----------------------------------------------------------------------------------------------------------------------


void raymarch(inout Vector tv){

    float marchStep = 0.;
    float depth=0.;

    for (int i = 0; i < 100; i++){

        float localDist = sdf(tv);

        if (localDist < EPSILON){
            break;
        }

        marchStep = localDist;
        depth+=marchStep;

        if(depth>maxDist){
            break;
        }

        tv = flow(tv, marchStep);
    }

}




//
//void raymarch(inout Vector tv, inout dist){
//
//    float marchStep = 0.;
//    float depth=0.;
//
//    for (int i = 0; i < 100.; i++){
//
//        float localDist = sdf(tv);
//
//        if (localDist < res.threshhold){
//            break;
//        }
//
//        marchStep = localDist;
//        depth += marchStep;
//
//        if(depth>maxDist){
//            break;
//        }
//
//        tv = flow(tv, marchStep);
//    }
//
//    dist=depth;
//}
//






void stepForward(inout Path path){

    if(path.keepGoing){//if we arent supposed to keep going, do nothing

        nudge(path.tv);//move the ray a little
        raymarch(path.tv);//march to next object
        setData(path);//set the local data at the new location

    }

}

