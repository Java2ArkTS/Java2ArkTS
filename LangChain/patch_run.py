from psutil import process_iter

from toTs import ToTs
from toTaskNew import ToTaskNew
import os
import subprocess
import json

def process_all_java_files(root_dir):
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename.endswith(".java"):
                java_path = os.path.join(dirpath, filename)

                # 读取 .java 文件内容
                with open(java_path, 'r', encoding='utf-8') as f:
                    java_content = f.read()
                with open('Tmp.java', 'w') as new_file:
                    new_file.write(java_content)

                # 处理内容
                processed_content = run()

                # 写入 index.ets（同目录下，追加模式）
                ets_path = os.path.join(dirpath, "index.ets")
                with open(ets_path, 'w', encoding='utf-8') as f:
                    f.write(processed_content)


def run_jar_with_input():
    result = subprocess.run(['java', '-jar', 'java_target/maven-demo.jar'], capture_output=True, text=True)
    if result.returncode != 0:
        raise RuntimeError("Java environment not detected, terminating the program.")
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


def run():
    run_jar_with_input()
    file_path = 'result.json'
    with open(file_path, 'r') as file:
        result = json.load(file)
    code = result['ast_output']
    origin_code = code
    flag = result['flag']
    flag = flag % 4
    if flag / 2 == 1:
        code = ''
        refer = ("import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from "
                 "'./ThreadBridge';\n\n") + code
        for c in result['classes']:
            class_code = c['class_code']
            class_flag = c['class_flag']
            tmp = ToTaskNew(class_flag, refer, origin_code).run(class_code) + '\n\n\n'
            tmp = deleteZhu(tmp)
            code += tmp
            # st.code(tmp)
    else:
        code = ToTs().getStart(code)

    if flag / 2 == 1:
        refer = ("import { SynStart, SynEnd, wait, notify, SharedBoolean, SharedString, SharedNumber, Syc, isMainThread, addFunc, Runnable, Thread } from "
                    "'./ThreadBridge';\n\n")
        wash = deleteZhu(ToTaskNew().addWash(refer + code))
        code = refer + wash + '\n\n' + code
    code = ToTs().getClean(code)
    code = deleteZhu(code)
    main_code = """if (isMainThread()) {
  // You can put the entry of your code here to test.
}"""
    code = code + '\n\n' + main_code

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
    return code

if __name__ == "__main__":
    # 设置你要处理的目录 # 可以修改为你实际的路径
    process_all_java_files(root_dir)

