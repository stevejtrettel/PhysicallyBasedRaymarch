import {
    ShaderMaterial,
    TextureLoader
} from "./lib/three.module.js";

import {
    globals
} from "./Main.js";

import {
    Position
} from "./Geometry.js";




//----------------------------------------------------------------------------------------------------------------------
//	Initialise things
//----------------------------------------------------------------------------------------------------------------------

const time0 = new Date().getTime();

/**
 * Initialize the globals variables related to the scene (position, cell position, lattice, etc).
 */
function setOrigin() {
    globals.position = new Position();
}



//----------------------------------------------------------------------------------------------------------------------
// Set up shader
//----------------------------------------------------------------------------------------------------------------------

var texture = new TextureLoader().load('images/sunset_fairway.jpg');

function createShaderUniforms(){
    return {
        screenResolution: {
            type: "v2",
                value: globals.screenResolution
        },

        time: {
            type: "f",
                value: (new Date().getTime()) - time0
        },

        tex: { //sky
            type: "t",
                value: texture
        },
        currentBoostMat: {
            type: "m4",
                value: globals.position.boost
        },
        facing: {
            type: "m4",
                value: globals.position.facing
        },
    }
};


/**
 * Update the data passed to the shader.
 *seems to work fine as uniforms now...
 */
function updateShaderUniforms() {
    //example of how this worked
    // globals.material.uniforms.currentBoostMat.value = globals.position.boost;
    // globals.material.uniforms.facing.value = globals.position.facing;
}



export {
    setOrigin,
    createShaderUniforms,
    updateShaderUniforms
};
