import {
    Vector3,
    Vector4,
    Matrix4
} from "./module/three.module.js";

import {
    globals
} from "./Main.js";

import {
    ORIGIN_PT,
    Point,
    Vector,
    Isometry
} from "./Geometry.js";

import {
    Position
} from "./Position.js";




//----------------------------------------------------------------------------------------------------------------------
//	Geometry Of the Model and Projective Model
//----------------------------------------------------------------------------------------------------------------------



function projPoint(pt) {
    //euclidean space is affine; is its own model
    return new Vector3(pt.x, pt.y, pt.z);
}







//----------------------------------------------------------------------------------------------------------------------
//  Tiling Generators Constructors
//----------------------------------------------------------------------------------------------------------------------

/*

Moves the generators in the 'Geometry.js' file (or another geometry dependent file)?
Maybe create a class "lattice" to would store
- the generators
- the test function 'is inside fundamental domain ?'

 */

function setGenVec() {

    let G1 = new Vector4(1, 0, 0., 0.);
    let G2 = new Vector4(0, 1, 0., 0.);
    let G3 = new Vector4(0., 0., 1, 0.);
    return [G1, G2, G3]
}


/**
 * Create the generators of a lattice and their inverses
 * The (2i+1)-entry of the output is the inverse of the (2i)-entry.
 * @returns {Array.<Isometry>} - the list of generators
 */
function createGenerators() {

    let GenVec = setGenVec();

    const gen0 = new Isometry().makeLeftTranslation(GenVec[0]);
    const gen1 = new Isometry().makeInvLeftTranslation(GenVec[0]);
    const gen2 = new Isometry().makeLeftTranslation(GenVec[1]);
    const gen3 = new Isometry().makeInvLeftTranslation(GenVec[1]);
    const gen4 = new Isometry().makeLeftTranslation(GenVec[2]);
    const gen5 = new Isometry().makeInvLeftTranslation(GenVec[2]);

    return [gen0, gen1, gen2, gen3, gen4, gen5];


}

/**
 * Return the inverses of the generators
 *
 * @param {Array.<Isometry>} genArr - the isom
 * @returns {Array.<Isometry>} - the inverses
 */
function invGenerators(genArr) {

    return [
            genArr[1],
            genArr[0],
            genArr[3],
            genArr[2],
            genArr[5],
            genArr[4],
            genArr[7],
            genArr[6],
            genArr[9],
            genArr[8]
        ];
}







function createProjDomain() {

    let Generators = setGenVec();

    //the vectors of half the length determine transformations taking the origin to the faces of the fundamental domain
    let V1 = Generators[0].clone().multiplyScalar(0.5);
    let V2 = Generators[1].clone().multiplyScalar(0.5);
    let V3 = Generators[2].clone().multiplyScalar(0.5);

    //what we actually need is the image of these in the projective models, as this tells us where the faces of the fundamental domains are


    //The three vectors specifying the directions / lengths of the generators of the lattice  IN THE PROJECTIVE MODEL
    //length of each vector is the HALF LENGTH of the generator: its the length needed to go from the center to the face
    const pV1 = projPoint(ORIGIN_PT.clone().translateBy(new Isometry().makeLeftTranslation(V1)));
    const pV2 = projPoint(ORIGIN_PT.clone().translateBy(new Isometry().makeLeftTranslation(V2)));
    const pV3 = projPoint(ORIGIN_PT.clone().translateBy(new Isometry().makeLeftTranslation(V3)));

    //create a list of these vectors
    let pVs = [pV1, pV2, pV3];

    //also need a list of the unit normal vectors to each face of the fundamental domain.
    //Assume a positively oriented list of basis vectors, so that the normal done in order always points "inward"
    const nV1 = pV2.clone().cross(pV3).normalize();
    const nV2 = pV3.clone().cross(pV1).normalize();
    const nV3 = pV1.clone().cross(pV2).normalize();

    let nVs = [nV1, nV2, nV3];

    //return the side pairings in the affine model, and the unit normals to the faces of the fundamental domain in that model
    return [pVs, nVs];

}





//----------------------------------------------------------------------------------------------------------------------
//	Teleporting back to central cell
//----------------------------------------------------------------------------------------------------------------------


/**
 * @todo Change this to a method of the class Position
 */
function fixOutsideCentralCell(position) {

    let bestIndex = -1;
    //    let p = new Point().translateBy(position.boost);
    //    let klein = p.toKlein();
    //
    //
    //    const sqrt2 = Math.sqrt(2);
    //    const auxSurfaceM = Math.sqrt(sqrt2 - 1.);
    //    const threshold = sqrt2 * auxSurfaceM;
    //
    //    let nh = new Vector4().set(1, 0, 0, 0);
    //    let nv = new Vector4().set(0, 1, 0, 0);
    //    let nd1 = new Vector4().set(0.5 * sqrt2, 0.5 * sqrt2, 0, 0);
    //    let nd2 = new Vector4().set(-0.5 * sqrt2, 0.5 * sqrt2, 0, 0);
    //    let nfiber = new Vector4().set(0, 0, 0, 1);
    //
    //
    //
    //    if (klein.dot(nh) > threshold) {
    //        bestIndex = 1;
    //    }
    //    if (klein.dot(nd1) > threshold) {
    //        bestIndex = 5;
    //    }
    //    if (klein.dot(nv) > threshold) {
    //        bestIndex = 0;
    //    }
    //    if (klein.dot(nd2) > threshold) {
    //        bestIndex = 4;
    //    }
    //    if (klein.dot(nh) < -threshold) {
    //        bestIndex = 3;
    //    }
    //    if (klein.dot(nd1) < -threshold) {
    //        bestIndex = 7;
    //    }
    //    if (klein.dot(nv) < -threshold) {
    //        bestIndex = 2;
    //    }
    //    if (klein.dot(nd2) < -threshold) {
    //        bestIndex = 6;
    //    }
    //    if (klein.dot(nfiber) > Math.PI) {
    //        bestIndex = 9;
    //    }
    //    if (klein.dot(nfiber) < -Math.PI) {
    //        bestIndex = 8;
    //    }
    //
    //
    //    if (bestIndex !== -1) {
    //        position.translateBy(globals.gens[bestIndex]);
    //        return bestIndex;
    //    } else {
    return -1;
    // }
}





export {
    setGenVec,
    createProjDomain,
    fixOutsideCentralCell,
    createGenerators,
    invGenerators
};
