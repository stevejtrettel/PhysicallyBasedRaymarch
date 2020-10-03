import {
    globals
} from './Main.js';

//-------------------------------------------------------
// UI Variables
//-------------------------------------------------------

let guiInfo;
let capturer;

// Inputs are from the UI parameterizations.
// gI is the guiInfo object from initGui


//What we need to init our dat GUI
let initGui = function () {
    guiInfo = { //Since dat gui can only modify object values we store variables here.
        GetHelp: function () {
            window.open('https://github.com/henryseg/non-euclidean_VR');
        },
        toggleUI: true,
        keyboard: 'us',
        display: 1,
        planes: 1,
        res: 2,
        lightRad: 1.,
        refl: 0.5,
        foggy: 0.5,
        recording: false
    };

    let gui = new dat.GUI();
    gui.close();

    let keyboardController = gui.add(guiInfo, 'keyboard', {
        QWERTY: 'us',
        AZERTY: 'fr'
    }).name("Keyboard");
    globals.controls.setKeyboard(guiInfo.keyboard);

    //    let resController = gui.add(guiInfo, 'res', {
    //        Low: '1',
    //        Med: '2',
    //        High: '3'
    //    });
    //
    //    let planesController = gui.add(guiInfo, 'planes', {
    //        Both: '1',
    //        Rust: '2',
    //        Turquoise: '3',
    //    }).name("Planes");

    //    let displayController = gui.add(guiInfo, 'display', {
    //        Sphere: '1',
    //        Torus: '2',
    //    }).name("Shape");



    //using to control sphere size
    let lightRadController = gui.add(guiInfo, 'lightRad', 0.0, 2.).name("Size");

    //using to control size of the change in index of refraction
    let reflController = gui.add(guiInfo, 'refl', 0., 3.).name("Refractivity");

    //
    //    //using to control how quickly the index grows?
    //    let foggyController = gui.add(guiInfo, 'foggy', 0.0, 1.).name("Fog");



    //    let recordingController = gui.add(guiInfo, 'recording').name("Record video");


    keyboardController.onChange(function (value) {
        globals.controls.setKeyboard(value);
    });

    //    displayController.onChange(function (value) {
    //        globals.display = value;
    //    });

    //    resController.onChange(function (value) {
    //        globals.res = value;
    //    });
    //
    //    planesController.onChange(function (value) {
    //        globals.material.uniforms.planes.value = value;
    //    });
    lightRadController.onChange(function (value) {
        globals.lightRad = value;
    });

    reflController.onChange(function (value) {
        globals.refl = value;
    });

    //    foggyController.onChange(function (value) {
    //        globals.foggy = value;
    //    });

    //
    //
    //    recordingController.onFinishChange(function (value) {
    //        if (value == true) {
    //            capturer = new CCapture({
    //                format: 'jpg'
    //            });
    //            capturer.start();
    //        } else {
    //            capturer.stop();
    //            capturer.save();
    //            // onResize(); //Resets us back to window size
    //        }
    //    });

};

export {
    initGui,
    guiInfo,
    capturer
}
