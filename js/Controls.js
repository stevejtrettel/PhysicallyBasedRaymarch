
import {
    Quaternion,
    Matrix4
} from "./lib/three.module.js";
import {
    Vector
} from "./Geometry.js";

import {
    globals
} from "./Main.js";




let Controls = function () {
    let translationSpeed = 0.5;
    let rotationSpeed = 0.2;

    this.manualRotateRate = new Float32Array([0.0, 0.0, 0.0]);
    this.manualMoveRate = new Float32Array([0.0, 0.0, 0.0]);
    this.updateTime = 0;

    let keyboardUS = {
        65: {
            index: 1,
            sign: 1,
            active: 0
        }, // a
        68: {
            index: 1,
            sign: -1,
            active: 0
        }, // d
        87: {
            index: 0,
            sign: 1,
            active: 0
        }, // w
        83: {
            index: 0,
            sign: -1,
            active: 0
        }, // s
        81: {
            index: 2,
            sign: -1,
            active: 0
        }, // q
        69: {
            index: 2,
            sign: 1,
            active: 0
        }, // e
        38: {
            index: 3,
            sign: 1,
            active: 0
        }, // up
        40: {
            index: 3,
            sign: -1,
            active: 0
        }, // down
        37: {
            index: 4,
            sign: -1,
            active: 0
        }, // left
        39: {
            index: 4,
            sign: 1,
            active: 0
        }, // right
        222: {
            index: 5,
            sign: 1,
            active: 0
        }, // single quote
        191: {
            index: 5,
            sign: -1,
            active: 0
        }, // fwd slash
    };


    this.manualControls = keyboardUS;


    this.update = function () {

        let oldTime = this.updateTime;
        let newTime = Date.now();
        this.updateTime = newTime;

        //--------------------------------------------------------------------
        // Translation
        //--------------------------------------------------------------------
        let deltaTime = (newTime - oldTime) * 0.001;
        let deltaPosition = new Vector().set(0, 0, 0);
        let deltaPositionNonZero = false;


        if (this.manualMoveRate[0] !== 0 || this.manualMoveRate[1] !== 0 || this.manualMoveRate[2] !== 0) {
            deltaPosition = deltaPosition.add(globals.position.getFwdVector().multiplyScalar(translationSpeed * deltaTime * this.manualMoveRate[0]));
            deltaPosition = deltaPosition.add(globals.position.getRightVector().multiplyScalar(translationSpeed * deltaTime * this.manualMoveRate[1]));
            deltaPosition = deltaPosition.add(globals.position.getUpVector().multiplyScalar(translationSpeed * deltaTime * this.manualMoveRate[2]));
            deltaPositionNonZero = true;
        }

        // do not flow if this is not needed !
        if (deltaPositionNonZero) {
            console.log('move');
            globals.position.flow(deltaPosition);
        }

        //--------------------------------------------------------------------
        // Rotation
        //--------------------------------------------------------------------

        let deltaRotation = new Quaternion();
        let deltaRotationNonZero = false;

        if (this.manualRotateRate[0] !== 0 || this.manualRotateRate[1] !== 0 || this.manualRotateRate[2] !== 0) {
            deltaRotation.set(
                this.manualRotateRate[0] * rotationSpeed * deltaTime,
                this.manualRotateRate[1] * rotationSpeed * deltaTime,
                this.manualRotateRate[2] * rotationSpeed * deltaTime,
                1.0
            );
            deltaRotationNonZero = true;
        }

        if (deltaRotationNonZero) {
            deltaRotation.normalize();
            let m = new Matrix4().makeRotationFromQuaternion(deltaRotation);
            globals.position.rotateFacingBy(m);
        }

    };


};

export {
    Controls
};
