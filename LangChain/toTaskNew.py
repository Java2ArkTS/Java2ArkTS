from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai.chat_models import ChatOpenAI
import streamlit as st


def deleteZhu(mycode):
    if mycode[0] == '`':
        lines = mycode.splitlines()
        lines = lines[1:-1]
        if lines[-1][0] == '`':
            lines = lines[0:-1]
        result_string = "\n".join(lines)
        return result_string
    else:
        return mycode


class ToTaskNew:
    def __init__(self, flag, refer, origin_code):
        self.model = ChatOpenAI(temperature=0, model="gpt-4o")
        self.origin_code = origin_code
        # self.model = ChatOpenAI(temperature=0)
        self.output_parser = StrOutputParser()
        self.flag = flag
        self.refer = refer

        self.template_changeFunc = """
        You are a highly proficient Java programmer.
Please modify the Java class provided by the user by changing the synchronized keyword from method-level to block-level, using "this" as the synchronization object.

For example:
Input:
{input}

Output:
{output}

Context of the code (Do not add extra imports):
{refer}

Directly output the modified class without any additional text.
        """
        self.prompt_changeFunc = ChatPromptTemplate.from_messages([
            ("system", self.template_changeFunc),
            ("user", "{code}")
        ])

    def getMessage(self):
        template = """
        You are a highly skilled Java programmer.
Analyze the constructors in the provided Java code and guide the user on how to instantiate each class, providing concise examples.

Keep the output as brief as possible.
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": self.origin_code})

    def addChu(self, code, message):
        template = """
        ou are a highly skilled Java programmer.

Based on the provided code context, initialize uninitialized member variables in the given class. If initialization requires parameters, infer them from the provided context.

If a variable is already initialized, do not modify it.

Example:

public int a;
→

public int a = 0;

Another example:

public Test test;
→

public Test test = new Test(1);

Instance creation guidelines:
{message}

Code context (Do not add extra imports):
{refer}

Output only the modified class. No extra text. Output only the code!
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "refer": self.refer, "message": message})

    def getStart(self, code):
        template = """
        You are highly skilled in both Java and TypeScript.

Convert the provided Java class into TypeScript without adding any new classes or functions, as the code context has already been provided.

Code context (Do not add extra imports):
{refer}

Output only the converted class. No extra text. Output only the code!
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "refer": self.refer})

    def transSyc(self, code):
        prompt = ChatPromptTemplate.from_template("""
{code}

You are a highly skilled Java programmer.

Modify the given Java class as follows:

Find code blocks marked with the synchronized keyword and remove the synchronized modifier.

At the beginning of the block, add:

SynStart(synchronized_object['synArray']);
At the end of the block, add:

SynEnd(synchronized_object['synArray']);
Replace wait() calls with:

wait(synchronized_object['synArray']);
Replace notify() calls with:

notify(synchronized_object['synArray']);
Example:
Input:
{input}

Output:
{output}

Ensure that SynStart(synchronized_object['synArray']) and SynEnd(synchronized_object['synArray']) are inside the code block.

Code context (Do not add extra imports):
{refer}

All required functions are already included in the imports—do not add extra code.

Output only the modified class. No extra text. Output only the code!
        """)
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "input": """
        synchronized(obj){
            obj.wait();
        }
        """, "output": """
        {
            SynStart(obj['synArray']);
            wait(obj['synArray']);
            SynEnd(obj['synArray']);
        }
        """, "refer": self.refer})

    def changeFuncSyn(self, code):
        chain = self.prompt_changeFunc | self.model | self.output_parser
        return chain.invoke({"code": code, "input": """
        public synchronized ReturnType methodName(){
            // method body
        }
        """, "output": """
        public ReturnType methodName(){
            synchronized(this){
                // method body
            }
        }
        """, "refer": self.refer})

    def changeDing(self, code):
        template = """
        You are a highly skilled TypeScript programmer.

Modify the user's input class using the following function:

getClass(type: string, inClass?: any): any
This function takes a type and a value, returning an object of type any.

Modification Rules:

Update member variable definitions using getClass, while keeping their initial values.

Do not modify methods or variables inside methods.

Examples:
Input:

private a: number = 0;
Output:

private a: any = getClass('number', 0);
Input:

public s: string = 'test';
Output:

public s: any = getClass('string', 'test');
Input:

public test: Test = new Test();
Output:

public test: Test = getClass('Test', new Test());
Code context (Do not add extra imports):
{refer}

Do not write additional functions. Output only the modified class. No extra text. Output only the code!
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "refer": self.refer})

    def changeSetGet(self, code):
        template = """
        You are a highly skilled TypeScript programmer.

Modify the user's input class using the following functions:

getValues(code: any): any
Takes a variable of type any and returns its corresponding value.

Apply getValues to all relevant expressions involving member variables.

setValues(obj: any, tmp: any): void
Takes a member variable obj of type any and assigns it a corresponding value tmp.

Use setValues for assignments to member variables.

Modification Rules:
Apply getValues for:

Member variables used in expressions.

Function arguments involving member variables.

Apply setValues for:

Assignments to member variables.

Do not modify:

Non-member variables.

Function definitions.

Examples:
Input:

console.log(this.s + "ok");
Output:

console.log(getValues(this.s) + "ok");
Input:

a = this.test.getNum();
Output:

a = getValues(this.test.getNum());
Input:

this.son.run();
Output:

getValues(this.son.run());
Input:

this.son.begin(this.a, this.b);
Output:

getValues(this.son.begin(getValues(this.a), getValues(this.b)));
Input:

this.a = 1;
Output:

setValues(this.a, 1);
Input:

this.a = this.b + 1;
Output:

setValues(this.a, getValues(this.b) + 1);
Code Context (Do Not Add Extra Imports):
{refer}

Do not write additional functions. Do not modify non-member functions.
Output only the modified class—no extra text!
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        #  st.code("开始设置set与get")
        return chain.invoke({"code": code, "refer": self.refer})

    def addCheng(self, code):
        template = """
        Output only the modified class—no additional text or analysis.

You are a highly skilled TypeScript programmer.

Modify the user's provided class by adding the following two member variables:

public synArray: any = getSyc();
public sharedType: string = "object";
Ensure that:

The variables are added as class members.

The output contains only the modified class—no extra text, no analysis, and no markdown formatting (```).
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code})

    def run(self, code):
        if self.flag % 2 == 1:
            st.write("start analysing code")
            message = self.getMessage()
            st.write("start initializing")
            code = deleteZhu(self.addChu(code, message))
        if int(self.flag / 2) == 1:
            st.write("start dealing with synchronized")
            code = deleteZhu(self.changeFuncSyn(code))
            code = deleteZhu(self.transSyc(code))
        st.write("start converting to TS")
        code = deleteZhu(self.getStart(code))
        st.write("start using set and get")
        code = deleteZhu(self.changeSetGet(code))
        if self.flag % 2 == 1:
            st.write("start changing variables")
            code = deleteZhu(self.changeDing(code))
        st.write("start adding variables")
        code = deleteZhu(self.addCheng(code))
        # st.code(code)
        return code

