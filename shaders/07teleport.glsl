
bool isOutsideCell(Point p, out Isometry fixIsom){
    return false;
    
}

// overload of the previous method with tangent vector
bool isOutsideCell(Vector v, out Isometry fixIsom){
    
   return isOutsideCell(v.pos, fixIsom);
}

