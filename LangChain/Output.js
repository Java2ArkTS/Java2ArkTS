"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sharedWash = void 0;
var ThreadBridge_1 = require("./ThreadBridge");
function sharedWash(threadId) {
    var archetype = ThreadBridge_1.Thread.runnableList[threadId];
    archetype.run();
}
exports.sharedWash = sharedWash;
var MoneyCounter = /** @class */ (function () {
    function MoneyCounter() {
        this.moneyAvailable = (0, ThreadBridge_1.getClass)('number', 2000);
        this.synArray = (0, ThreadBridge_1.getSyc)();
        this.sharedType = "object";
    }
    MoneyCounter.prototype.useMoney = function (userName, numberOfMoney) {
        (0, ThreadBridge_1.SynStart)(1, this.synArray);
        if (numberOfMoney <= (0, ThreadBridge_1.getValues)(this.moneyAvailable)) {
            (0, ThreadBridge_1.setValues)(this.moneyAvailable, (0, ThreadBridge_1.getValues)(this.moneyAvailable) - numberOfMoney);
            console.log("".concat(userName, " used ").concat(numberOfMoney, " money. Money left: ").concat((0, ThreadBridge_1.getValues)(this.moneyAvailable)));
        }
        (0, ThreadBridge_1.SynEnd)(1, this.synArray);
    };
    MoneyCounter.prototype.getMoneyAvailable = function () {
        (0, ThreadBridge_1.SynStart)(2, this.synArray);
        var available = (0, ThreadBridge_1.getValues)(this.moneyAvailable);
        (0, ThreadBridge_1.SynEnd)(2, this.synArray);
        return available;
    };
    return MoneyCounter;
}());
var BuyBook = /** @class */ (function () {
    function BuyBook(moneyCounter, userName, price) {
        this.synArray = (0, ThreadBridge_1.getSyc)();
        this.sharedType = "object";
        this.moneyCounter = (0, ThreadBridge_1.getClass)('MoneyCounter', new MoneyCounter());
        this.userName = (0, ThreadBridge_1.getClass)('string', "User1");
        this.price = (0, ThreadBridge_1.getClass)('number', 5);
        (0, ThreadBridge_1.setValues)(this.moneyCounter, moneyCounter);
        (0, ThreadBridge_1.setValues)(this.userName, userName);
        (0, ThreadBridge_1.setValues)(this.price, price);
    }
    BuyBook.prototype.run = function () {
        while (true) {
            (0, ThreadBridge_1.getValues)(this.moneyCounter.useMoney((0, ThreadBridge_1.getValues)(this.userName), (0, ThreadBridge_1.getValues)(this.price)));
        }
    };
    return BuyBook;
}());
var BuyFood = /** @class */ (function () {
    function BuyFood(moneyCounter, userName, price) {
        this.synArray = (0, ThreadBridge_1.getSyc)();
        this.sharedType = "object";
        this.moneyCounter = (0, ThreadBridge_1.getClass)('MoneyCounter', new MoneyCounter());
        this.userName = (0, ThreadBridge_1.getClass)('string', "User2");
        this.price = (0, ThreadBridge_1.getClass)('number', 10);
        (0, ThreadBridge_1.setValues)(this.moneyCounter, moneyCounter);
        (0, ThreadBridge_1.setValues)(this.userName, userName);
        (0, ThreadBridge_1.setValues)(this.price, price);
    }
    BuyFood.prototype.run = function () {
        while (true) {
            (0, ThreadBridge_1.getValues)(this.moneyCounter.useMoney((0, ThreadBridge_1.getValues)(this.userName), (0, ThreadBridge_1.getValues)(this.price)));
        }
    };
    return BuyFood;
}());
var BuyTicket = /** @class */ (function () {
    function BuyTicket(moneyCounter, userName, price) {
        this.moneyCounter = (0, ThreadBridge_1.getClass)('MoneyCounter', new MoneyCounter());
        this.userName = (0, ThreadBridge_1.getClass)('string', "User3");
        this.price = (0, ThreadBridge_1.getClass)('number', 20);
        this.synArray = (0, ThreadBridge_1.getSyc)();
        this.sharedType = "object";
        (0, ThreadBridge_1.setValues)(this.moneyCounter, moneyCounter);
        (0, ThreadBridge_1.setValues)(this.userName, userName);
        (0, ThreadBridge_1.setValues)(this.price, price);
    }
    BuyTicket.prototype.run = function () {
        while (true) {
            (0, ThreadBridge_1.getValues)(this.moneyCounter.useMoney((0, ThreadBridge_1.getValues)(this.userName), (0, ThreadBridge_1.getValues)(this.price)));
        }
    };
    return BuyTicket;
}());
var UseMoneyTest = /** @class */ (function () {
    function UseMoneyTest() {
        this.synArray = (0, ThreadBridge_1.getSyc)();
        this.sharedType = "object";
    }
    UseMoneyTest.main = function (args) {
        var moneyCounter = new MoneyCounter();
        var thread1 = new ThreadBridge_1.Thread(new BuyBook(moneyCounter, "User1", 5));
        var thread2 = new ThreadBridge_1.Thread(new BuyFood(moneyCounter, "User2", 10));
        var thread3 = new ThreadBridge_1.Thread(new BuyTicket(moneyCounter, "User3", 20));
        (0, ThreadBridge_1.getValues)(thread1.start());
        (0, ThreadBridge_1.getValues)(thread2.start());
        (0, ThreadBridge_1.getValues)(thread3.start());
    };
    return UseMoneyTest;
}());
