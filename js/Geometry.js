/**
 * Module handling the given geometry.
 * Here : the universal cover of SL(2,R)
 *
 * @module Geometry.
 *
 */

import {
    Matrix3,
    Matrix4,
    Vector3,
    Vector4
} from "./module/three.module.js";


class Point extends Vector4 {

    translateBy(isom) {
        return this.applyMatrix4(isom);
    }


    makeTranslation() {
        let A = new Isometry().set(
            1, 0, 0, this.x,
            0, 1, 0, this.y,
            0, 0, 1, this.z,
            0, 0, 0, 1
        );
        return A;
    }


    /**
     * Correct the error to make sure that the point lies on the "hyperboloid"
     * @returns {SL2}
     */
    reduceError() {
        return this;
    }


    /**
     * Return an encoding of the point that can be passed to the shader
     */
    serialize() {
        return this;
    }

}

let ORIGIN_PT = new Point().set(0., 0., 0., 1.);

/**
 * Tangent vector at the origin of X

 * @class
 * @public
 */
class Vector extends Vector3 {

    /**
     * Apply the facing of a position to the current vector
     * @param {Position} position - the position giving the facing to apply
     * @returns {Vector} - the current vector
     */
    rotateByFacing(position) {
        let aux = new Matrix3().setFromMatrix4(position.facing);
        this.applyMatrix3(aux);
        return this;
    };
}






class Isometry extends Matrix4 {


    reduceError() {
        return this;
    }


    serialize() {
        return this;
    }



    makeLeftTranslation(v) {
        this.set(
            1, 0, 0, v.x,
            0, 1, 0, v.y,
            0, 0, 1, v.z,
            0, 0, 0, 1
        );
        return this;

    }

    makeInvLeftTranslation(v) {
        this.set(
            1, 0, 0, -v.x,
            0, 1, 0, -v.y,
            0, 0, 1, -v.z,
            0, 0, 0, 1
        );
        return this;

    }

}




/**
 * Serialize an array of Points
 *
 * @param {Array.<Point>} pointArr - the isometries to serialize
 * @returns {Array.<Vector4>} - the serialized isometries
 */
function serializePoints(pointArr) {
    return pointArr;
    //    return pointArr.map(function (point) {
    //        return point.serialize();
    //    });
}





/**
 * Serialize an array of isometries
 *
 * @param {Array.<Isometry>} isomArr - the isometries to serialize
 * @returns {Array.<Vector4>} - the serialized isometries
 */
function serializeIsoms(isomArr) {
    return isomArr;
    //    return isomArr.map(function (isom) {
    //        return isom.serialize();
    //    });
}



export {
    ORIGIN_PT,
    Point,
    Vector,
    Isometry,
    serializePoints,
    serializeIsoms

}
