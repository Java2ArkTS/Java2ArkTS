import { process } from '@kit.ArkTS'
import { sharedWash } from "./Index"
import taskpool from "@ohos.taskpool";

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
    await taskpool.execute(runThread, this.runnableShared);
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

@Concurrent
function runThread(runnable: Runnable) {
  sharedWash(runnable);
}

export function isMainThread(): boolean {
  return process.pid == process.tid;
}

export class SharedBoolean{
  private sharedArray: Uint8Array = new Uint8Array(new SharedArrayBuffer(1));

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
  private sharedArray: Uint8Array = new Uint8Array(new SharedArrayBuffer(1024));

  constructor(s ?: string) {
    if (s !== undefined){
      this.setValue(s);
    }
  }

  public setValue(s: string) {
    let length: number = s.length + 3;
    let buffer: SharedArrayBuffer = new SharedArrayBuffer(length);
    let sharedArray: Uint8Array = new Uint8Array(buffer);

    for(let i=0;i<s.length;i++){
      sharedArray[i] = s.charCodeAt(i);
    }
    sharedArray[s.length] = 0;
    this.sharedArray = sharedArray;
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
  private sharedArray: Float64Array = new Float64Array(new SharedArrayBuffer(8));

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
  public synArray: Int32Array = new Int32Array(new SharedArrayBuffer(32));
  public wnSynArray: Int32Array = new Int32Array(new SharedArrayBuffer(32));

  constructor() {
    this.synArray[0] = 1;
    this.wnSynArray[0] = 0;
  }
}

export function SynStart(syc: Syc){
  let synArray: Int32Array = syc.synArray;
  while(Atomics.exchange(synArray, 0, 0) !== 1);
}

export function SynEnd(syc: Syc){
  let synArray: Int32Array = syc.synArray;
  Atomics.exchange(synArray, 0, 1);
}

export function wait(syc: Syc){
  let wnSynArray: Int32Array = syc.wnSynArray;
  SynEnd(syc);
  wnSynArray[0] = 0;
  while(Atomics.exchange(wnSynArray, 0, 0) !== 1);
}

export function notify(syc: Syc){
  let wnSynArray: Int32Array = syc.wnSynArray;
  Atomics.exchange(wnSynArray, 0, 0)
}

export function addFunc(runnableShared: object, archetype: object){
  if (runnableShared === archetype) {
    return ;
  }

  const members = Object.getOwnPropertyNames(runnableShared);
  for(let i :number = 0;i<members.length;i++){
    addFunc(runnableShared[members[i]], archetype[members[i]]);
  }

  runnableShared['__proto__'] = archetype['__proto__'];
}
