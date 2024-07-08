from toTs import ToTs
from toTaskNew import ToTaskNew
import streamlit as st
import os
from io import BytesIO
import subprocess

st.title('LLM-Based Java Concurrent Program to ArkTS Converter')

filename = "ThreadBridge.ets"
with open(filename, 'r') as file:
    Ku = file.read()
file_bytes = Ku.encode('utf-8')
st.download_button(label='download ThreadBridge', data=BytesIO(file_bytes), file_name=filename)

uploaded_file = st.file_uploader('Upload a file')
name = ' '

if uploaded_file is not None:
    st.write('File uploaded successfully!')
    file_content = uploaded_file.read()  # Display file content
    name = uploaded_file.name[:-5]
    with open('Tmp.java', 'w') as new_file:
        new_file.write(file_content.decode())


def run_jar_with_input():
    result = subprocess.run(['java', '-jar', 'target/maven-demo.jar'], capture_output=True, text=True)
    return result.stdout


def deleteZhu(mycode):
    if mycode[0] == '`':
        lines = mycode.splitlines()
        # 使用切片操作去掉第一行和最后一行
        lines = lines[1:-1]
        if lines[-1][0] == '`':
            lines = lines[0:-1]
        # 将处理后的列表重新拼接为字符串
        result_string = "\n".join(lines)
        return result_string
    else:
        return mycode


if st.button('run'):
    ast_result = run_jar_with_input()
    st.write(ast_result)
    file_path = 'tmp.txt'
    with open(file_path, 'r') as file:
        code = file.read()
        origin_code = code
    file_path = 'flag.txt'
    with open(file_path, 'r') as file:
        flag = int(file.read())
    flag = flag % 4
    if flag / 2 == 1:
        code = ''
        with open('classnum.txt', 'r') as file:
            class_num = int(file.read())
        refer = ("import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from "
                 "'./ThreadBridge';\n\n") + code
        for i in range(class_num):
            class_file_path = 'class'+str(i)+'.txt'
            with open(class_file_path, 'r') as file:
                class_code = file.read()
            class_flag_path = 'class_flag' + str(i) + '.txt'
            # st.code(class_code)
            with open(class_flag_path, 'r') as file:
                class_flag = int(file.read())
                print(class_flag)
                tmp = ToTaskNew(class_flag, refer, origin_code).run(class_code) + '\n\n\n'
                tmp = deleteZhu(tmp)
                code += tmp
                # st.code(tmp)
    else:
        code = ToTs().getStart(code)

    if flag % 2 == 1:
        code = ToTs().getPublic(code)

    if flag / 2 == 1:
        code = """
import { setValues, getSyc, getClass, getValues, SynStart, SynEnd, addFunc, Runnable, Thread, wait, notify } from './ThreadBridge';

export function sharedWash(threadId: number){
  let archetype = Thread.runnableList[threadId];
  archetype.run();
}

        """ + code
    code = ToTs().getClean(code)
    code = deleteZhu(code)
    last_code = code
    error_flag = 0
    for _ in range(3):
        process = subprocess.Popen(['tsc', 'Output.ts'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        stdout, stderr = process.communicate()
        if len(stdout.decode()) == 0:
            error_flag = 0
            break
        # st.code(stdout.decode())
        error_flag = 1
        code = deleteZhu(ToTs().getFix(code, stdout.decode()))
        # st.code(code)
    if error_flag == 1:
        code = last_code
    print(code)
    with open('Output.ts', 'w') as file:
        file.write(code)
    st.code(code)

    st.code("convert finish")
    filename = "Index.ets"
    file_bytes = code.encode('utf-8')
    st.download_button(label='Download File', data=BytesIO(file_bytes), file_name=filename)
