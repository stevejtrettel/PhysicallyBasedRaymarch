


import {
    globals
} from './Main.js';

//-------------------------------------------------------
// UI Variables
//-------------------------------------------------------

let guiInfo;
let capturer;


//What we need to init our dat GUI
let createGui = function () {
    guiInfo = { //Since dat gui can only modify object values we store variables here.
        toggleUI: true,
        keyboard: 'us',
        foggy: 0.5,
        recording: false
    };

    let gui = new dat.GUI();
    gui.close();

    let foggyController = gui.add(guiInfo, 'foggy', 0.0, 1.).name("Fog");

    let recordingController = gui.add(guiInfo, 'recording').name("Record video");

    foggyController.onChange(function (value) {
        globals.material.uniforms.foggy.value = value;
    });


    recordingController.onFinishChange(function (value) {
        if (value == true) {
            capturer = new CCapture({
                frramerate: 50,
                format: 'png',
                // timeLimit()
                //format: 'jpg'

            });
            capturer.start();
        } else {
            capturer.stop();
            capturer.save();
            // onResize(); //Resets us back to window size
        }
    });


};

export {
    createGui,
    guiInfo,
    capturer
}
