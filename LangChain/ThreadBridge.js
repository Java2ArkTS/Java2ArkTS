"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SynEnd = exports.SynStart = exports.addFunc = exports.Thread = exports.getSyc = exports.getClass = exports.setValues = exports.getValues = void 0;
function booleanDecoder(sharedArray) {
    if (sharedArray[0] === 0) {
        return false;
    }
    return true;
}
function stringDecoder(sharedArray) {
    var receivedString = "";
    for (var i = 0; i < sharedArray.length && sharedArray[i] !== 0; i++) {
        receivedString += String.fromCharCode(sharedArray[i]);
    }
    return receivedString;
}
function getValues(code) {
    var type = code.sharedType;
    if (type === "number") {
        return code.sharedValue[0];
    }
    else if (type === "string") {
        return stringDecoder(code.sharedValue);
    }
    else if (type === "boolean") {
        return booleanDecoder(code.sharedValue);
    }
    else if (type === "bigint") {
        return code.sharedValue[0];
    }
    else if (type === "undefined") {
        return undefined;
    }
    else {
        var members = Object.getOwnPropertyNames(code);
        var result = {};
        for (var i = 0; i < members.length; i++) {
            if (members[i] !== "sharedType") {
                // result[members[i]] = getValues(code[members[i]]);
            }
        }
        return result;
    }
}
exports.getValues = getValues;
function booleanChanger(sharedArray, b) {
    sharedArray[0] = 0;
    if (b === true) {
        sharedArray[0] = 1;
    }
}
function stringChanger(sharedArray, s) {
    for (var i = 0; i < s.length; i++) {
        sharedArray[i] = s.charCodeAt(i);
    }
    sharedArray[s.length] = 0;
}
function setValues(obj, tmp) {
    var type = obj.sharedType;
    if (type === "number") {
        obj.sharedValue[0] = tmp;
    }
    else if (type === "string") {
        stringChanger(obj.sharedValue, tmp);
    }
    else if (type === "boolean") {
        booleanChanger(obj.sharedValue, tmp);
    }
    else if (type === "bigint") {
        obj.sharedValue[0] = tmp;
    }
    else if (type === "undefined") {
        return;
    }
    else if (type === "Function") {
        return;
    }
    else {
        var members = Object.getOwnPropertyNames(obj);
        for (var i = 0; i < members.length; i++) {
            if (members[i] !== "sharedType" && typeof obj[members[i]] != 'function') {
                setValues(obj[members[i]], tmp[members[i]]);
            }
        }
    }
}
exports.setValues = setValues;
function numberEncoder(n) {
    var buffer = new SharedArrayBuffer(8);
    var sharedArray = new Float64Array(buffer);
    sharedArray[0] = 0;
    if (n !== null) {
        // sharedArray[0] = n;
    }
    return { "sharedValue": sharedArray, "sharedType": "number" };
}
function bigIntEncoder(n) {
    var buffer = new SharedArrayBuffer(8);
    var sharedArray = new BigInt64Array(buffer);
    // if(n!==null){
    //   sharedArray[0] = n;
    // }
    return { "sharedValue": sharedArray, "sharedType": "number" };
}
function booleanEncoder(b) {
    var buffer = new SharedArrayBuffer(1);
    var sharedArray = new Uint8Array(buffer);
    sharedArray[0] = 0;
    if (b !== null) {
        if (b === true) {
            sharedArray[0] = 1;
        }
    }
    return { "sharedValue": sharedArray, "sharedType": "boolean" };
}
function stringEncoder(s) {
    var long = 0;
    if (s !== null) {
        // long = s.length + 3;
    }
    else {
        long = 1024;
    }
    var buffer = new SharedArrayBuffer(long);
    var sharedArray = new Uint8Array(buffer);
    if (s !== null) {
        // for(let i=0;i<s.length;i++){
        //   sharedArray[i] = s.charCodeAt(i);
        // }
        // sharedArray[s.length] = 0;
    }
    return { "sharedValue": sharedArray, "sharedType": "string" };
}
function getClass(type, inClass) {
    if (type === 'number') {
        return numberEncoder(inClass);
    }
    else if (type === 'boolean') {
        return booleanEncoder(inClass);
    }
    else if (type === 'string') {
        return stringEncoder(inClass);
    }
    else if (type === 'bigint') {
        return bigIntEncoder(inClass);
    }
    else if (type === 'undefined') {
        return { "sharedValue": undefined, "sharedType": "undefined" };
    }
    else {
        return inClass;
    }
}
exports.getClass = getClass;
function getSyc() {
    var syn = new SharedArrayBuffer(200);
    var synArray = new Int8Array(syn);
    for (var i = 0; i < 180; i++) {
        synArray[i] = 1;
    }
    return synArray;
}
exports.getSyc = getSyc;
var Thread = /** @class */ (function () {
    function Thread(runnableShared) {
        if (runnableShared === void 0) { runnableShared = null; }
        this.runnableShared = null;
        this.threadId = 0;
        if (runnableShared !== null) {
            this.runnableShared = runnableShared;
        }
        else {
            this.runnableShared = Thread.getThreadOwn(this);
        }
        this.threadId = Thread.runnableNum;
        Thread.runnableNum++;
        Thread.runnableList.push(this.runnableShared);
    }
    Thread.getThreadOwn = function (myClass) {
        return myClass;
    };
    Thread.prototype.start = function () {
        // taskpool.execute(threadStart, this.runnableShared, this.threadId);
    };
    Thread.runnableList = [];
    Thread.runnableNum = 0;
    return Thread;
}());
exports.Thread = Thread;
function addFunc(runnableShared, archetype) {
    if (runnableShared.sharedType === 'object') {
        var members = Object.getOwnPropertyNames(runnableShared);
        for (var i = 0; i < members.length; i++) {
            if (members[i] !== "sharedType") {
                addFunc(runnableShared[members[i]], archetype[members[i]]);
            }
        }
        var methodNames = Object.getOwnPropertyNames(archetype.__proto__).filter(function (name) { return typeof archetype.__proto__[name] === "function"; });
        for (var i = 0; i < methodNames.length; i++) {
            runnableShared[methodNames[i]] = archetype.__proto__[methodNames[i]];
        }
    }
    return;
}
exports.addFunc = addFunc;
// @Concurrent
function threadStart(runnableShared, threadId) {
    // sharedWash(runnableShared, threadId);
}
function SynStart(i, synArray) {
    var lockState = 0;
    do {
        lockState = Atomics.exchange(synArray, i, 0);
    } while (lockState !== 1);
}
exports.SynStart = SynStart;
function SynEnd(i, synArray) {
    Atomics.exchange(synArray, i, 1);
}
exports.SynEnd = SynEnd;
