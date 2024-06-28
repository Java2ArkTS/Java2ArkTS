import { sharedWash } from './Index';
import taskpool from '@ohos.taskpool';

function booleanDecoder(sharedArray : Uint8Array){
  if(sharedArray[0]===0){
    return false;
  }
  return true;
}

function stringDecoder(sharedArray : Uint8Array) : string{
  let receivedString = "";
  for(let i = 0;i<sharedArray.length && sharedArray[i] !== 0;i++){
    receivedString += String.fromCharCode(sharedArray[i]);
  }
  return receivedString;
}

export function getValues(code: any){
  if(code == undefined){
    return ;
  }
  if(code['sharedType'] == undefined){
    return code;
  }
  let type = code.sharedType;
  if(type === "number"){
    return code.sharedValue[0];
  }
  else if(type === "string"){
    return stringDecoder(code.sharedValue);
  }
  else if(type === "boolean"){
    return booleanDecoder(code.sharedValue);
  }
  else if(type === "bigint"){
    return code.sharedValue[0];
  }
  else if(type === "undefined"){
    return undefined;
  }
  else{
    return code;
  }
}

function booleanChanger(sharedArray : any, b : boolean){
  sharedArray[0] = 0;
  if(b === true){
    sharedArray[0] = 1;
  }
}

function stringChanger(sharedArray: any, s: string){
  for(let i=0;i<s.length;i++){
    sharedArray[i] = s.charCodeAt(i);
  }
  sharedArray[s.length] = 0;
}

export function setValues(obj: any, tmp: any){
  if(tmp['sharedType']!=undefined){
    const members = Object.getOwnPropertyNames(obj);
    for(let i :number = 0;i<members.length;i++){
      obj[members[i]] = tmp[members[i]];
    }
    return ;
  }
  let type = obj.sharedType;
  if(type === "number"){
    obj.sharedValue[0] = tmp;
  }
  else if(type === "string"){
    stringChanger(obj.sharedValue, tmp);
  }
  else if(type === "boolean"){
    booleanChanger(obj.sharedValue, tmp);
  }
  else if(type === "bigint"){
    obj.sharedValue[0] = tmp;
  }
  else if(type === "undefined"){
    return ;
  }
  else if(type === "Function"){
    return ;
  }
  else {
    const members = Object.getOwnPropertyNames(obj);
    for(let i :number = 0;i<members.length;i++){
      if(members[i]!=="sharedType"&&typeof obj[members[i]] != 'function') {
        setValues(obj[members[i]], tmp[members[i]]);
      }
    }
  }
}

function numberEncoder(n ?: number){
  const buffer = new SharedArrayBuffer(8);
  const sharedArray = new Float64Array(buffer);
  sharedArray[0] = 0;
  if(n!==null){
    sharedArray[0] = n;
  }
  return {"sharedValue": sharedArray, "sharedType": "number"};
}

function bigIntEncoder(n ?: bigint){
  const buffer = new SharedArrayBuffer(8);
  const sharedArray = new BigInt64Array(buffer);
  if(n!==null){
    sharedArray[0] = n;
  }
  return {"sharedValue": sharedArray, "sharedType": "number"};
}

function booleanEncoder(b ?: boolean){
  const buffer = new SharedArrayBuffer(1);
  const sharedArray = new Uint8Array(buffer);
  sharedArray[0] = 0;
  if(b!==null){
    if(b === true){
      sharedArray[0] = 1;
    }
  }
  return {"sharedValue": sharedArray, "sharedType": "boolean"};
}

function stringEncoder(s ?: string){
  let long : number = 0;
  if(s!==null){
    long = s.length + 3;
  }
  else{
    long = 1024;
  }
  const buffer = new SharedArrayBuffer(long);
  const sharedArray = new Uint8Array(buffer);
  if(s!==null) {
    for(let i=0;i<s.length;i++){
      sharedArray[i] = s.charCodeAt(i);
    }
    sharedArray[s.length] = 0;
  }
  return {"sharedValue": sharedArray, "sharedType": "string"};
}

export function getClass(type: string, inClass ?: any){
  if(type === 'number'){
    return numberEncoder(inClass);
  }
  else if(type === 'boolean'){
    return booleanEncoder(inClass);
  }
  else if(type === 'string') {
    return stringEncoder(inClass);
  }
  else if(type === 'bigint') {
    return bigIntEncoder(inClass);
  }
  else if(type === 'undefined'){
    return {"sharedValue": undefined, "sharedType": "undefined"};
  }
  else{
    return inClass;
  }
}

export function getSyc(){
  let syn = new SharedArrayBuffer(200);
  let synArray = new Int8Array(syn);
  for(let i=0;i<180;i++){
    synArray[i] = 1;
  }
  return synArray;
}

export interface Runnable{
  run(): void;
}

export class Thread{
  static runnableList : any = [];
  private runnableShared : any = null;
  static runnableNum : number = 0;
  private threadId : number = 0;

  static getThreadOwn(myClass : any) :  any{
    return myClass;
  }

  public start(){
    taskpool.execute(threadStart, this.threadId);
  }

  constructor(runnableShared: any = null) {
    if(runnableShared !== null){
      this.runnableShared = runnableShared;
    }
    else{
      this.runnableShared = Thread.getThreadOwn(this);
    }
    this.threadId = Thread.runnableNum;
    Thread.runnableNum++;
    Thread.runnableList.push(this.runnableShared);
  }
}

export function addFunc(runnableShared: any, archetype: any){
  if(runnableShared['sharedType'] === 'object'){
    const members = Object.getOwnPropertyNames(runnableShared);
    for(let i :number = 0;i<members.length;i++){
      if(members[i]!=="sharedType") {
        addFunc(runnableShared[members[i]], archetype[members[i]]);
      }
    }

    const methodNames = Object.getOwnPropertyNames(archetype.__proto__).filter(
      name => typeof (archetype.__proto__ as any)[name] === "function"
    );
    for(let i:number = 0;i<methodNames.length;i++){
      runnableShared[methodNames[i]] = archetype.__proto__[methodNames[i]];
    }
  }
  return;
}


// @ts-ignore
@Concurrent
function threadStart(threadId: number){
  sharedWash(threadId);
}


export function SynStart(i : number, synArray: Int8Array){
  let lockState:number=0;
  do {
    lockState = Atomics.exchange(synArray, i, 0);
  } while (lockState !== 1);
}

export function SynEnd(i : number, synArray: Int8Array){
  Atomics.exchange(synArray, i, 1);
}
