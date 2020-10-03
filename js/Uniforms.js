import {
    Vector4,
    Matrix4,
    ShaderMaterial,
    CubeTextureLoader,
    TextureLoader
} from "./module/three.module.js";

import {
    globals
} from "./Main.js";

import {
    Point,
    Vector,
    Isometry,
    serializeIsoms,
    serializePoints
} from "./Geometry.js";

import {
    Position
} from "./Position.js";

import {
    //fixOutsideCentralCell,
    createGenerators,
    invGenerators,
    setGenVec,
    createProjDomain
} from "./Math.js";




//----------------------------------------------------------------------------------------------------------------------
//	Initialise things
//----------------------------------------------------------------------------------------------------------------------

const time0 = new Date().getTime();

/**
 * Initialize the globals variables related to the scene (position, cell position, lattice, etc).
 */
function initGeometry() {

    //globals.position = new Position();
    //make it so we start looking along y axis
    globals.position = new Position().rotateFacingBy(new Matrix4().set(1, 0, 0, 0, 0, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, 1));

    globals.cellPosition = new Position();
    globals.invCellPosition = new Position();
    globals.gens = createGenerators();
    globals.projDomain = createProjDomain();
    globals.invGens = invGenerators(globals.gens);

}




/**
 * Add a light to scene
 * @param {Vector} v - the position of the light is obtained by flowing v form the origin
 * @param {Vector3} colorInt - color of Light and Intensity
 */
function PointLightObject(v, colorInt) {
    let isom = new Position().flow(v).boost;
    let lp = new Point().translateBy(isom);
    globals.lightPositions.push(lp);
    globals.lightColors.push(colorInt);
}

/** @const {Vector4} lightColor1 - Color 1 (blue) */
const lightColor1 = new Vector4(68 / 256, 197 / 256, 203 / 256, 1.); // blue
/** @const {Vector4} lightColor2 - Color 2 (yellow) */
const lightColor2 = new Vector4(252 / 256, 227 / 256, 21 / 256, 1.); // yellow
/** @const {Vector4} lightColor3 - Color 3 (red)  */
const lightColor3 = new Vector4(245 / 256, 61 / 256, 82 / 256, 1.); // red
/** @const {Vector4} lightColor4 - Color 4 (purple) */
const lightColor4 = new Vector4(256 / 256, 142 / 256, 226 / 256, 1.); // purple


/**
 * Initialize the objects of the scene
 */
function initObjects() {

    PointLightObject(new Vector().set(1., 1., 0), lightColor1);
    PointLightObject(new Vector().set(-1., 1., 0), lightColor2);
    PointLightObject(new Vector().set(0, 0, 1.), lightColor3);
    PointLightObject(new Vector().set(1., -1., 1.), lightColor4);

    //    let p = new Point().set(0, 0, 0, 1.); //origin
    //    globals.globalObjectPosition = new Position().set(p.makeTranslation(), new Matrix4());
}

//----------------------------------------------------------------------------------------------------------------------
// Set up shader
//----------------------------------------------------------------------------------------------------------------------

var texture = new TextureLoader().load('images/sunset_fairway.jpg');


/**
 * Pass all the data to the shader
 * @param fShader
 */
function setupMaterial(fShader) {
    //console.log(globals.position.facing.toLog());
    globals.material = new ShaderMaterial({
        uniforms: {

            screenResolution: {
                type: "v2",
                value: globals.screenResolution
            },

            time: {
                type: "f",
                value: (new Date().getTime()) - time0
            },

            earthCubeTex: { //earth texture to global object
                type: "t",
                value: new CubeTextureLoader().setPath('images/SkyCube/')
                    .load([ //Cubemap derived from http://www.humus.name/index.php?page=Textures&start=120
                        'posx.jpg',
                        'negx.jpg',
                        'posy.jpg',
                        'negy.jpg',
                        'posz.jpg',
                        'negz.jpg'
                    ])
            },


            tex: { //earth texture to global object
                type: "t",
                value: texture
            },


            //--- geometry dependent stuff here ---//
            //--- lists of stuff that goes into each invGenerator
            invGenerators: {
                type: "m4",
                value: serializeIsoms(globals.invGens)
            },

            //Sending the normals to faces of fundamental domain
            pV: {
                type: "v3",
                value: globals.projDomain[0]
            },
            nV: {
                type: "v3",
                value: globals.projDomain[1]
            },
            //            //--- end of invGen stuff
            currentBoostMat: {
                type: "m4",
                value: globals.position.boost
            },
            facing: {
                type: "m4",
                value: globals.position.facing
            },
            cellBoostMat: {
                type: "m4",
                value: globals.cellPosition.boost
            },
            invCellBoostMat: {
                type: "m4",
                value: globals.invCellPosition.boost
            },
            cellFacing: {
                type: "m4",
                value: globals.cellPosition.facing
            },
            invCellFacing: {
                type: "m4",
                value: globals.invCellPosition.facing
            },

            //---uniforms for building the scene------
            lightPositions: {
                type: "v4",
                value: serializePoints(globals.lightPositions)
            },
            lightIntensities: {
                type: "v4",
                value: globals.lightIntensities
            },

            lightRad: {
                type: "float",
                value: globals.lightRad
            },

            //            globalObjectBoostMat: {
            //                type: "v4",
            //                value: globals.globalObjectPosition.boost.serialize()
            //            },
            //            globalSphereRad: {
            //                type: "f",
            //                value: 0.2
            //            },
            //

            display: {
                type: "int",
                value: globals.display
            },

            planes: {
                type: "float",
                value: globals.planes
            },


            // ----- uniforms for rendering the scene -----
            resol: {
                type: "int",
                value: globals.res
            },

            refl: {
                type: "float",
                value: globals.refl
            },
            foggy: {
                type: "float",
                value: globals.foggy
            },

        },

        vertexShader: document.getElementById('vertexShader').textContent,
        fragmentShader: fShader,
        transparent: true
    });
}

/**
 * Update the data passed to the shader.
 *seems to work fine as uniforms now...
 */
function updateMaterial() {
    //example of how this worked
    //globals.material.uniforms.currentBoostMat.value = globals.position.boostu

    globals.material.uniforms.lightRad.value = globals.lightRad;
    globals.material.uniforms.refl.value = globals.refl;
    globals.material.uniforms.display.value = globals.display;
    globals.material.uniforms.foggy.value = globals.foggy;
}



export {
    initGeometry,
    initObjects,
    setupMaterial,
    updateMaterial
};
