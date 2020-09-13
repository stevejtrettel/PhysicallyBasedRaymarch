/**
 * Representation of the position of the observer / an object
 * A position is given by
 * - a `boost` which is an Isometry moving the origin to the point where the observer is
 * - a `facing` which determines where the observer is looking at. It is a element of SO(3) encoded as a 4x4 matrix
 *
 * More abstractly there is a map from Isom(X) x SO(3) -> Frame bundle, sending (L, A) to  d_o L A f where
 * - o is the origin
 * - f is a fixed (reference) frame in the tangent space of X at o
 * Note that the point stabilizer G_o of o in Isom(X) acts on the set of positions as follows
 * (L, A) . U = (LU^{-1},  d_o U A)
 * The G_o -orbits of a position is exactly the fiber of the map Isom(X) x SO(3) -> Frame bundle
 *
 * @module Position
 * @todo Remove unnecessary reduceErrors (on the boost side)
 */


import {
    Matrix3,
    Matrix4,
    Vector4
} from "./module/three.module.js";

import {
    Point,
    Vector,
    Isometry
} from "./Geometry.js";


// Function for debugging

// Return a human-readable version of the matrix
Matrix4.prototype.toLog = function () {
    let res = '\r\n';
    for (let i = 0; i < 4; i++) {
        for (let j = 0; j < 4; j++) {
            if (j !== 0) {
                res = res + ",\t";
            }
            res = res + this.elements[i + 4 * j];
        }
        res = res + "\r\n";
    }
    return res;
}


// Return a human-readable version of the matrix
Matrix3.prototype.toLog = function () {
    let res = '\r\n';
    for (let i = 0; i < 3; i++) {
        for (let j = 0; j < 3; j++) {
            if (j !== 0) {
                res = res + ",\t";
            }
            res = res + this.elements[i + 3 * j];
        }
        res = res + "\r\n";
    }
    return res;
}


/**
 * Position
 *
 * A position is a pair (boost, facing) where
 * - boost is an isometry of X (associated to a point of X)
 * - the facing is an element of SO(3) (seen as 4x4 matrix)
 *
 * We identify the tangent space at the origin of X, with the Lie algebra of SL(2,R) in its hyperboloid model
 * A tangent vector is represented by a Vector3.
 * - the last coordinates corresponds to the fiber
 * - the other two correspond to the directions in H^2
 *
 * @class
 * @public
 *
 **/






class Position {

    /**
     * Create a position which representing the origin with the reference frame
     * @constructor
     */
    constructor() {
        /** @property {Isometry} boost - the isometry part of the position */
        this.boost = new Isometry();
        /** @property {Matrix4} facing - the facing part of the position */
        this.facing = new Matrix4();
    }

    /**
     * Set the boost of the position
     * @param {Isometry} boost - the new boost
     * @returns {Position} - the current position
     */
    setBoost(boost) {
        this.boost.copy(boost);
        return this;
    }

    /**
     * Set the facing of the position
     * @param {Matrix4} facing - the new facing
     * @returns {Position} - the current position
     */
    setFacing(facing) {
        this.facing.copy(facing);
        return this;
    }

    /**
     * Set the boost and facing of the position
     * @param {Isometry} boost - the new boost
     * @param {Matrix4} facing - the new facing
     * @returns {Position} - the current position
     */
    set(boost, facing) {
        this.setBoost(boost);
        this.setFacing(facing);
        return this;
    };

    /**
     * Translate the position by the given isometry
     * @param {Isometry} isom - the translation
     * @returns {Position} - the current position
     */
    translateBy(isom) {
        this.boost.premultiply(isom);
        this.reduceBoostError();
        return this;
    };

    /**
     * Translation from the origin:
     * if we are at boost of b, our position is b.0. We want to fly forward, and isom
     * tells me how to do this if I were at 0. So I want to apply b * isom * b^{-1} to b * 0, and I get b * isom * 0.
     * In other words, translate boost by the conjugate of isom by boost
     * @param {Isometry} isom - the translation (pulled by at the origin)
     * @returns {Position} - the current position
     */
    localTranslateBy(isom) {
        this.boost.multiply(isom);
        this.reduceBoostError();
        return this;
    }

    /**
     * Apply the given matrix (on the right) to the current facing and return the new result
     * @param {Matrix4} rotation - the rotation to apply
     * @returns {Position} - the current position
     */
    rotateFacingBy(rotation) {
        this.facing.multiply(rotation);
        this.reduceFacingError();
        return this;
    }

    /**
     * Move the position following the geodesic flow.
     
     * @todo Move the code of the flow in the Geometry.js file, to make the Position.js file geometry independent ?
     * Another is to define an abstract class, where the flow will be overwritten for each geometry
     * @returns {Position} - the current position
     */
    flow(v) {

        let A = new Matrix4().set(
            1, 0, 0, v.x,
            0, 1, 0, v.y,
            0, 0, 1, v.z,
            0, 0, 0, 1
        );

        this.boost.premultiply(A);
        //do nothing to the facing
        return this;

    }

    /**
     * Set the current position to the position that can bring back the passed position to the origin position
     * @param {Position} position - the position to inverse
     * @returns {Position} - the current position
     */
    getInverse(position) {
        this.boost.getInverse(position.boost);
        this.facing.getInverse(position.facing);
        this.reduceError();
        return this;
    }

    /**
     * Return the vector of length t moving forward (taking into account the facing)
     * @param {number} t - the length of the vector
     * @returns {Vector} - the forward vector
     */
    getFwdVector(t = 1) {
        return new Vector().set(0, 0, -t).rotateByFacing(this);
    };

    /**
     * Return the vector of length t moving right (taking into account the facing)
     * @param {number} t - the length of the vector
     * @returns {Vector} - the right vector
     */
    getRightVector(t = 1) {
        return new Vector().set(t, 0, 0).rotateByFacing(this);
    };

    /**
     * Return the vector of length t moving up (taking into account the facing)
     * @param {number} t - the length of the vector
     * @returns {Vector} - the upward vector
     */
    getUpVector(t = 1) {
        return new Vector().set(0, t, 0).rotateByFacing(this);
    };

    /**
     * Correct the errors in the boost part
     * @returns {Position} - the current position
     */
    reduceBoostError() {
        this.boost.reduceError();
        return this;
    };

    /**
     * Correct the errors in the facing part (Gram-Schmidt)
     * @returns {Position} - the current position
     */
    reduceFacingError() {
        // Gram-Schmidt
        let col0 = new Vector4(1, 0, 0, 0).applyMatrix4(this.facing);
        let col1 = new Vector4(0, 1, 0, 0).applyMatrix4(this.facing);
        let col2 = new Vector4(0, 0, 1, 0).applyMatrix4(this.facing);

        col0.normalize();

        let aux10 = col0.clone().multiplyScalar(col0.dot(col1));
        col1.sub(aux10).normalize();

        let aux20 = col0.clone().multiplyScalar(col0.dot(col2));
        let aux21 = col1.clone().multiplyScalar(col1.dot(col2));
        col2.sub(aux20).sub(aux21).normalize();

        this.facing.set(
            col0.x, col1.x, col2.x, 0.,
            col0.y, col1.y, col2.y, 0.,
            col0.z, col1.z, col2.z, 0.,
            0., 0., 0., 1.
        );
        return this;
    };



    /**
     * Correct the errors in the boost and the facing
     * @returns {Position} - the current position
     */
    reduceError() {
        this.reduceBoostError();
        this.reduceFacingError();
        return this;
    };

    /**
     * Test if two instances of Position represents the same position
     * @param {Position} position - an other position
     * @returns {boolean} - true if the positions are the same, and false otherwise
     */
    equals(position) {
        return (this.boost.equals(position.boost) && this.facing.equals(position.facing));
    };

    /**
     * Return a copy of the current position
     * @returns {Position} - the copy of the current position
     */
    clone() {
        return new Position().set(this.boost, this.facing);
    };

}


export {
    Position
}
