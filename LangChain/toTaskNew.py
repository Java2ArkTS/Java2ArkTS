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
    def __init__(self, flag=0, refer="", origin_code=""):
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

    def addWash(self, code):
        refer = """export function sharedWash(runnable: Runnable) {
  let archetype: Runnable;
  if (runnable.className == ...) {
    archetype = new ...;
  } else {
    archetype = new Thread();
  }
  addFunc(runnable, archetype);
  runnable.run();
}
"""
        template = """
You are a TypeScript expert.
Given the sharedWash function below, extend the function so that it handles only classes that implement the Runnable interface.

For each class that implements Runnable, add an if...else if branch to compare runnable.className.
Instantiate the corresponding class inside the branch and assign it to the archetype variable.

If no match is found, use the default Thread class in the else block.

Ensure correct instantiation of each class that implement the Runnable interface(e.g., new ClassName()).

Do not change the function signature. Only modify the body to include the logic for all Runnable implementations.

Here is the start code:

{refer}

Output only the completed function. No extra text. Output only the code!
✅ Only include classes that explicitly implement the Runnable interface.
❌ Do NOT include any class that does not implement Runnable. No exceptions.
Only include classes that implement the Runnable interface, do not include any other classes.
Under no circumstance should a class that does not implement Runnable be added to the if...else chain.
"""
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "refer": refer})


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

SynStart(synchronized_object.syn);
At the end of the block, add:

SynEnd(synchronized_object.syn);
Replace wait() calls with:

wait(synchronized_object.syn);
Replace notify() calls with:

notify(synchronized_object.syn);
Example:
Input:
{input}

Output:
{output}

Ensure that SynStart(synchronized_object.syn) and SynEnd(synchronized_object.syn) are inside the code block.

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
            SynStart(obj.syn);
            wait(obj.syn);
            SynEnd(obj.syn);
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
        You are a skilled TypeScript code transformer.

Your task is to transform only the member variables declared in the current TypeScript class whose types are boolean, string, or number 
into their corresponding SharedBoolean, SharedString, and SharedNumber wrapper types.

Do not transform:
Local variables (inside functions)
Function parameters
External variables or variables from other objects
Member variables of other classes or objects
Any variable that is not a class member declared in this class

Please follow these transformation rules strictly:
1. Initialization:
Convert
public count: number = 5;

to
public count = new SharedNumber(5);

2. Accessing values:
Replace all reads or usages of these variables in expressions with this.varName.getValue()
Example:
const total = this.count + 10;

becomes
const total = this.count.getValue() + 10;

3. Updating values:
Replace all assignments to these variables with this.varName.setValue(value)
Example:
this.count = 100;

becomes
this.count.setValue(100);

Do not modify the logic of the code. Only refactor variable types and access/mutation style.
Do not write additional functions. Output only the modified class. No extra text. Output only the code!
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code})

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

Elements inside SynStart, SynEnd, wait, and notify.

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

Modify the user's provided class by adding the following three member variables:

public syn: Syc = new Syc();
public static staticSyn: Syc = new Syc();
public className: string = "className"; ← Replace "ClassName" with the actual name of the class being modified.

Ensure that:
Insert these variables as class members.
Set className to the exact name of the current class.
If the class already contains member variables with the same names (syn, staticSyn, or className), 
replace them regardless of their access modifier (e.g., public, private, or protected).
Output only the modified class—no explanations, extra text, or markdown formatting.
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code})

    def run(self, code):
        # if self.flag % 2 == 1:
        #     st.write("start analysing code")
        #     message = self.getMessage()
        #     st.write("start initializing")
        #     code = deleteZhu(self.addChu(code, message))
        if int(self.flag / 2) == 1:
            st.write("start dealing with synchronized")
            code = deleteZhu(self.changeFuncSyn(code))
            code = deleteZhu(self.transSyc(code))
        st.write("start converting to TS")
        code = deleteZhu(self.getStart(code))
        st.write("start using set and get")
        code = deleteZhu(self.changeDing(code))
        st.write("start adding variables")
        code = deleteZhu(self.addCheng(code))
        # st.code(code)
        return code

