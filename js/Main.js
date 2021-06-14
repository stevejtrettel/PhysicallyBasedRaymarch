import {
    Scene,
    PlaneBufferGeometry,
    WebGLRenderer,
    Vector2,
    OrthographicCamera,
    BufferGeometry,
    BufferAttribute,
    Mesh, ShaderMaterial,
    LinearEncoding
} from './lib/three.module.js';

import {
    initGeometry,
    createShaderUniforms,
    updateShaderUniforms
} from "./Uniforms.js";

import {
    initGui,
    guiInfo,
    capturer
} from "./UI.js";
import {
    initEvents,
} from './Events.js';
import {
    Controls
} from './Controls.js';

//----------------------------------------------------------------------------------------------------------------------
// Global Variables
//----------------------------------------------------------------------------------------------------------------------


let globals = {
    effect: undefined,
    material: undefined,
    controls: undefined,
    position: undefined,
    renderer: undefined,
    screenResolution: undefined,
};

//----------------------------------------------------------------------------------------------------------------------
// Scene variables
//----------------------------------------------------------------------------------------------------------------------

let scene;
let mesh;
let camera;
let stats;
let canvas;
let renderer;




//Creating Basic Components
//=============================================


function createStats(type) {

    var panelType = (typeof type !== 'undefined' && type) && (!isNaN(type)) ? parseInt(type) : 0;
    var stats = new Stats();

    stats.showPanel(panelType); // 0: fps, 1: ms, 2: mb, 3+: custom
    document.body.appendChild(stats.dom);

    return stats;
}





function createRenderer() {
    renderer = new WebGLRenderer({
        canvas,
        alpha: true,
        //  premultipliedAlpha: true,
        //  preserveDrawingBuffer: true,
        depth: false,
        stencil: false
    });

    // set the gamma correction so that output colors look
    // correct on our screens
    //renderer.gammaFactor = 1.;
    renderer.outputEncoding = LinearEncoding;
    renderer.setSize(window.innerWidth, window.innerHeight);
}


function createCamera() {

    //make the one camera we will use for both renders
    camera = new OrthographicCamera(
        -1, // left
        1, // right
        1, // top
        -1, // bottom
        -1, // near,
        1, // far
    );

}



function render() {

    //render the actual scene to the camera using this
    renderer.render(scene, camera);

}


function resizeToDisplay() {
               canvas = renderer.domElement;
               const width = canvas.clientWidth;
               const height = canvas.clientHeight;
               const needResize = canvas.width !== width || canvas.height !== height;
               if (needResize) {
                   // renderer.setPixelRatio(window.devicePixelRatio);
                   renderer.setSize(window.innerWidth, window.innerHeight);
               }
    return needResize;
}

//
//
// function animate() {
//
//     requestAnimationFrame(animate);
//
//     //stats.begin();
//
//     //resizeToDisplay();
//
//     updateShaderUniforms();
//
//     globals.controls.update();
//
//     render();
//
//     //stats.end();
//
// }




async function main() {


    //Setup our THREE scene--------------------------------
    scene = new Scene();
    canvas = document.createElement('canvas');
    let context = canvas.getContext('webgl2');
    globals.renderer = new WebGLRenderer({
        canvas: canvas,
        context: context
    });
    document.body.appendChild(globals.renderer.domElement);
    globals.screenResolution = new Vector2(window.innerWidth, window.innerHeight);
    globals.effect = new rendererSetup(globals.renderer);
    camera = new OrthographicCamera(-1, 1, 1, -1, 1 / Math.pow(2, 53), 1);
    globals.controls = new Controls();
    initGeometry();

    createScene();


    //loadShaders();
    initEvents();
    initGui();
    stats = new Stats();
    stats.showPanel(1);
    stats.showPanel(2);
    stats.showPanel(0);
    document.body.appendChild(stats.dom);

    animate();


    //
    // initGeometry();
    //
    // globals.controls = new Controls();
    //
    // canvas = document.createElement('canvas');
    // let context = canvas.getContext('webgl2');
    // globals.renderer = new WebGLRenderer({
    //     canvas: canvas,
    //     context: context
    // });
    // document.body.appendChild(globals.renderer.domElement);
    // globals.screenResolution = new Vector2(window.innerWidth, window.innerHeight);
    //
    // stats = createStats();
    //
    // createRenderer();
    //
    // createCamera();
    //
    // await createScene();

    //animate();

}





//----------------------------------------------------------------------------------------------------------------------
// Sets up the scene
//----------------------------------------------------------------------------------------------------------------------

function init() {
    //Setup our THREE scene--------------------------------
    scene = new Scene();
    canvas = document.createElement('canvas');
    let context = canvas.getContext('webgl2');
    globals.renderer = new WebGLRenderer({
        canvas: canvas,
        context: context
    });
    document.body.appendChild(globals.renderer.domElement);
    globals.screenResolution = new Vector2(window.innerWidth, window.innerHeight);
    globals.effect = new rendererSetup(globals.renderer);
    camera = new OrthographicCamera(-1, 1, 1, -1, 1 / Math.pow(2, 53), 1);
    globals.controls = new Controls();
    initGeometry();

    createScene();
    //loadShaders();
    initEvents();
    initGui();
    stats = new Stats();
    stats.showPanel(1);
    stats.showPanel(2);
    stats.showPanel(0);
    document.body.appendChild(stats.dom);
}




//----------------------------------------------------------------------------------------------------------------------
// Building the Shader out of the GLSL files
//----------------------------------------------------------------------------------------------------------------------




async function buildShader() {

    let newShader = '';


    const shaders = [] = [
        {
            file: './shaders/01structs.glsl'
        },
        {
            file: './shaders/02localGeo.glsl'
        },
        {
            file: './shaders/04basicSDFs.glsl'
        },
        {
            file: './shaders/05setup.glsl'
        },
        {
            file: './shaders/06scene.glsl'
        },
        {
            file: './shaders/08raymarch.glsl'
        },
        {
            file: './shaders/09materials.glsl'
        },
        {
            file: './shaders/10lighting.glsl'
        },
        {
            file: './shaders/11bouncing.glsl'
        },
        {
            file: './shaders/12shader.glsl'
        },
        {
            file: './shaders/13main.glsl'
        },
    ];


    //loop over the list of files
    let response, text;
    for (const shader of shaders) {
        response = await fetch(shader.file);
        text = await response.text();
        newShader = newShader + text;
    }

    return newShader;

}


async function createScene() {

    let shaderCode=await buildShader();

    //make the actual scene, and the buffer Scene
    scene = new Scene();

    //make the plane we draw on
    const geom = new PlaneBufferGeometry(2, 2);

    const mat = new ShaderMaterial({
        fragmentShader: shaderCode,
        //vertexShader: document.getElementById('vertexShader').textContent,
        uniforms: createShaderUniforms(),
    });

    const screen=new Mesh(geom, mat);

    scene.add(screen);
}



//
//
// async function loadShaders() {
//
//     let shaderCode=await buildShader();
//
//         globals.material = new ShaderMaterial({
//             uniforms:createShaderUniforms(),
//             vertexShader: document.getElementById('vertexShader').textContent,
//             fragmentShader: shaderCode,
//             transparent: true
//     });
//
//         globals.effect.setSize(globals.screenResolution.x, globals.screenResolution.y);
//
//                                                             //Setup a "quad" to render on-------------------------
//                                                             let geom = new BufferGeometry();
//                                                             let vertices = new Float32Array([
//                                                                 -1.0, -1.0, 0.0,
//                                                                 1.0, -1.0, 0.0,
//                                                                 1.0, 1.0, 0.0,
//
//                                                                 -1.0, -1.0, 0.0,
//                                                                 1.0, 1.0, 0.0,
//                                                                 -1.0, 1.0, 0.0
//                                                             ]);
//                                                             geom.setAttribute('position', new BufferAttribute(vertices, 3));
//                                                             mesh = new Mesh(geom, globals.material);
//                                                             scene.add(mesh);
//                                                             animate();
// }
//


//----------------------------------------------------------------------------------------------------------------------
// Where our scene actually renders out to screen
//----------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------
// Renderer
//----------------------------------------------------------------------------------------------------------------------

// //this controls the effect part of the animate loop
let rendererSetup = function (renderer, done) {

    this._renderer = renderer;

    this.render = function (scene, camera, animate) {
        let renderer = this._renderer;

        requestAnimationFrame(animate);

        renderer.render.apply(this._renderer, [scene, camera]);
        if (guiInfo.recording === true) {
            capturer.capture(canvas);
        }
    };
    this.setSize = function (width, height) {
        renderer.setSize(width, height);
    };
};




function animate() {
    stats.begin();
    globals.controls.update();
    updateShaderUniforms();
    globals.effect.render(scene, camera, animate);
    stats.end();
}

//----------------------------------------------------------------------------------------------------------------------
// Where the magic happens
//----------------------------------------------------------------------------------------------------------------------

//init();
main();


export {
    globals,
    canvas
};
