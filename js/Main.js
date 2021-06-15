import {
    Scene,
    WebGLRenderer,
    Vector2,
    OrthographicCamera,
    Mesh,
    PlaneBufferGeometry,
    ShaderMaterial
} from './lib/three.module.js';

import {
    setOrigin,
    createShaderUniforms,
    updateShaderUniforms
} from "./Uniforms.js";

import {
    createGui,
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
let camera;
let stats;
let canvas;


//----------------------------------------------------------------------------------------------------------------------
// Basic Components
//----------------------------------------------------------------------------------------------------------------------

function createStats(type) {

    var panelType = (typeof type !== 'undefined' && type) && (!isNaN(type)) ? parseInt(type) : 0;
    stats = new Stats();

    stats.showPanel(panelType); // 0: fps, 1: ms, 2: mb, 3+: custom
    document.body.appendChild(stats.dom);
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



function createControls(){
    globals.controls = new Controls();
    setOrigin();//sets the origin
}



function setup(){
    canvas = document.createElement('canvas');
    let context = canvas.getContext('webgl2');

    globals.renderer = new WebGLRenderer({
        canvas: canvas,
        context: context
    });
    document.body.appendChild(globals.renderer.domElement);

    globals.screenResolution = new Vector2(window.innerWidth, window.innerHeight);
    globals.effect = new renderEffect(globals.renderer);

}


//----------------------------------------------------------------------------------------------------------------------
//EFFECT
//----------------------------------------------------------------------------------------------------------------------

//this controls the effect part of the animate loop
let renderEffect = function (renderer, done) {

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





//----------------------------------------------------------------------------------------------------------------------
// Building the Shader out of the GLSL files
//----------------------------------------------------------------------------------------------------------------------

async function buildShader() {

    let newShader = '';

    const shaders = [] = [
        {
            file: './shaders/setup/uniforms.glsl'
        },
        {
            file: './shaders/setup/process.glsl'
        },
        {
            file: './shaders/trace/geometry.glsl'
        },
        {
            file: './shaders/render/physBased/Light.glsl'
        },
        {
            file: './shaders/render/physBased/Material.glsl'
        },
        {
            file: './shaders/render/physBased/Path.glsl'
        },
        {
            file: './shaders/trace/raymarch/objects.glsl'
        },
        {
            file: './shaders/trace/raymarch/sceneSDF.glsl'
        },
        {
            file: './shaders/trace/raymarch/stepForward.glsl'
        },
        {
            file: './shaders/render/physBased/getSurfaceColor.glsl'
        },
        {
            file: './shaders/render/physBased/getPixelColor.glsl'
        },
        {
            file: './shaders/main.glsl'
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
        vertexShader: document.getElementById('vertexShader').textContent,
        uniforms: createShaderUniforms(),
    });

    globals.effect.setSize(globals.screenResolution.x, globals.screenResolution.y);

    const screen=new Mesh(geom, mat);

    scene.add(screen);
}








//----------------------------------------------------------------------------------------------------------------------
// Main Functions
//----------------------------------------------------------------------------------------------------------------------

function main() {

    setup();

    createCamera();
    createControls();
    createGui();
    createStats();
    createScene();

    initEvents();

    animate();
}



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

main();


export {
    globals
};
