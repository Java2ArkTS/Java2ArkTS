import { sharedWash } from "./Output"

export interface Runnable{
  className: string;
  run(): void;
}

export class Thread implements Runnable{
  private runnableShared: Runnable;
  public className: string = "Thread";

  static getThreadOwn(myClass: Runnable):  Runnable{
    return myClass;
  }

  public async start(){
    // if (isMainThread()) {
    // await taskpool.execute(runThread, this.runnableShared);
    // }
  }

  public run() {}

  constructor(runnableShared: Runnable | null = null) {
    if(runnableShared !== null){
      this.runnableShared = runnableShared;
    }
    else{
      this.runnableShared = Thread.getThreadOwn(this);
    }
  }
}

function runThread(runnable: Runnable) {
  sharedWash(runnable);
}

export function isMainThread(): boolean {
  // return process.pid == process.tid;
    return true
}


export class SharedBoolean{
  private sharedArray: Uint8Array = new Uint8Array([]);

  constructor(b ?: boolean) {
    this.sharedArray[0] = 0;
    if(b !== undefined){
      if(b === true){
        this.sharedArray[0] = 1;
      }
    }
  }

  public setValue(b: boolean) {
    if(b === true){
      this.sharedArray[0] = 1;
    }
    else {
      this.sharedArray[0] = 0;
    }
  }

  public getValue(): boolean {
    if (this.sharedArray[0] == 0) {
      return false;
    }
    return true;
  }
}

export class SharedString {
  private sharedArray: Uint8Array = new Uint8Array([]);

  constructor(s ?: string) {
    if (s !== undefined){
      this.setValue(s);
    }
  }

  public setValue(s: string) {

  }

  public getValue() {
    let receivedString = "";
    for(let i = 0; i < this.sharedArray.length && this.sharedArray[i] !== 0; i++){
      receivedString += String.fromCharCode(this.sharedArray[i]);
    }
    return receivedString;
  }
}

export class SharedNumber {
  private sharedArray: Float64Array = new Float64Array([]);

  constructor(n ?: number) {
    this.sharedArray[0] = 0;
    if(n !== undefined){
      this.sharedArray[0] = n;
    }
  }

  public setValue(n: number) {
    this.sharedArray[0] = n;
  }

  public getValue(): number {
    return this.sharedArray[0];
  }
}

export class Syc {
  public synArray: Int32Array = new Int32Array([]);
  public wnSynArray: Int32Array = new Int32Array([]);

  constructor() {
    this.synArray[0] = 1;
    this.wnSynArray[0] = 0;
  }
}

export function SynStart(syc: Syc){

}

export function SynEnd(syc: Syc){

}

export function wait(syc: Syc){

}

export function notify(syc: Syc){

}

export function addFunc(runnableShared: object, archetype: object){

}
