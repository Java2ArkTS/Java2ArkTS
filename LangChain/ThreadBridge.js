"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.Syc = exports.SharedNumber = exports.SharedString = exports.SharedBoolean = exports.Thread = void 0;
exports.isMainThread = isMainThread;
exports.SynStart = SynStart;
exports.SynEnd = SynEnd;
exports.wait = wait;
exports.notify = notify;
exports.addFunc = addFunc;
var Output_1 = require("./Output");
var Thread = /** @class */ (function () {
    function Thread(runnableShared) {
        if (runnableShared === void 0) { runnableShared = null; }
        this.className = "Thread";
        if (runnableShared !== null) {
            this.runnableShared = runnableShared;
        }
        else {
            this.runnableShared = Thread.getThreadOwn(this);
        }
    }
    Thread.getThreadOwn = function (myClass) {
        return myClass;
    };
    Thread.prototype.start = function () {
        return __awaiter(this, void 0, void 0, function () {
            return __generator(this, function (_a) {
                return [2 /*return*/];
            });
        });
    };
    Thread.prototype.run = function () { };
    return Thread;
}());
exports.Thread = Thread;
function runThread(runnable) {
    (0, Output_1.sharedWash)(runnable);
}
function isMainThread() {
    // return process.pid == process.tid;
    return true;
}
var SharedBoolean = /** @class */ (function () {
    function SharedBoolean(b) {
        this.sharedArray = new Uint8Array([]);
        this.sharedArray[0] = 0;
        if (b !== undefined) {
            if (b === true) {
                this.sharedArray[0] = 1;
            }
        }
    }
    SharedBoolean.prototype.setValue = function (b) {
        if (b === true) {
            this.sharedArray[0] = 1;
        }
        else {
            this.sharedArray[0] = 0;
        }
    };
    SharedBoolean.prototype.getValue = function () {
        if (this.sharedArray[0] == 0) {
            return false;
        }
        return true;
    };
    return SharedBoolean;
}());
exports.SharedBoolean = SharedBoolean;
var SharedString = /** @class */ (function () {
    function SharedString(s) {
        this.sharedArray = new Uint8Array([]);
        if (s !== undefined) {
            this.setValue(s);
        }
    }
    SharedString.prototype.setValue = function (s) {
    };
    SharedString.prototype.getValue = function () {
        var receivedString = "";
        for (var i = 0; i < this.sharedArray.length && this.sharedArray[i] !== 0; i++) {
            receivedString += String.fromCharCode(this.sharedArray[i]);
        }
        return receivedString;
    };
    return SharedString;
}());
exports.SharedString = SharedString;
var SharedNumber = /** @class */ (function () {
    function SharedNumber(n) {
        this.sharedArray = new Float64Array([]);
        this.sharedArray[0] = 0;
        if (n !== undefined) {
            this.sharedArray[0] = n;
        }
    }
    SharedNumber.prototype.setValue = function (n) {
        this.sharedArray[0] = n;
    };
    SharedNumber.prototype.getValue = function () {
        return this.sharedArray[0];
    };
    return SharedNumber;
}());
exports.SharedNumber = SharedNumber;
var Syc = /** @class */ (function () {
    function Syc() {
        this.synArray = new Int32Array([]);
        this.wnSynArray = new Int32Array([]);
        this.synArray[0] = 1;
        this.wnSynArray[0] = 0;
    }
    return Syc;
}());
exports.Syc = Syc;
function SynStart(syc) {
}
function SynEnd(syc) {
}
function wait(syc) {
}
function notify(syc) {
}
function addFunc(runnableShared, archetype) {
}
