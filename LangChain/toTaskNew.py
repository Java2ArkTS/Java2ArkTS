from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai.chat_models import ChatOpenAI
import streamlit as st


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


class ToTaskNew:
    def __init__(self, flag, refer, origin_code):
        self.model = ChatOpenAI(temperature=0, model="gpt-4o")
        self.origin_code = origin_code
        # self.model = ChatOpenAI(temperature=0)
        self.output_parser = StrOutputParser()
        self.flag = flag
        self.refer = refer

        self.template_changeFunc = """
        你是一个十分精通Java的程序员。
        请将user提供的Java类中标记在方法上的synchronized关键字改为标记在代码块的形式，括号中的对象为"this"例如：
        {input}
        改为
        {output}
        
        *********************************************
        代码的上下文如下，不要额外import：
        {refer}
        *********************************************
        
        输出直接输出更改后的类，不要有其他东西。
        """
        self.prompt_changeFunc = ChatPromptTemplate.from_messages([
            ("system", self.template_changeFunc),
            ("user", "{code}")
        ])

    def getMessage(self):
        template = """
        你是一个十分擅长Java的程序员。
        请分析用户传入的Java代码中每个类的构造方法，指导用户如何构建每个类的实例并给出示范。
        请输出的尽量少。
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        # st.code("开始分析成员变量")
        return chain.invoke({"code": self.origin_code})

    def addChu(self, code, message):
        template = """
        你是一个十分擅长Java的程序员。
        请参考用户提供的代码的上下文，将用户传入的类中未初始化的成员变量初始化，请从用户提供的代码的上下文中找到成员变量的构造函数中可能需要参数。
        若已经初始化，不做任何更改。
        请注意，输出中除了转换后的类不要有任何东西。
        例如：
        public int a;
        改成：
        public int a = 0;
        再例如：
        public Test test;
        改成：
        public Test test = new Test(1);
        
        ********************************************
        生成类的实例的指导如下：
        {message}

        *********************************************
        代码的上下文如下，禁止额外import：
        {refer}
        *********************************************
        只输出代码！！！只输出代码！！！只输出代码！！！
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        # st.code("开始初始化成员变量")
        return chain.invoke({"code": code, "refer": self.refer, "message": message})

    def getStart(self, code):
        template = """
        你是一个十分擅长Java与typescript的程序员。
        请将user提供的Java类转换成typescript代码。
        不要新增任何的类和函数，因为代码上下文已经给出
        请注意，输出中除了转换后的类不要有任何东西。
        
        *********************************************
        代码的上下文如下，禁止额外import：
        {refer}
        *********************************************
        只输出代码！！！只输出代码！！！只输出代码！！！
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        # st.code("开始类的转换")
        return chain.invoke({"code": code, "refer": self.refer})

    def transSyc(self, code):
        # st.code("开始转换synchronized关键字")
        prompt = ChatPromptTemplate.from_template("""
        {code}
        你是一个十分擅长Java的程序员。
        请将上述Java类做如下更改：找到被synchronized关键字标记的代码块，将synchronized标记删除。在其第一行加上
        SynStart(synchronized关键字目前为止的数量, synArray); 
        在其最后加上SynEnd(synchronized关键字目前为止的数量, synArray); 例如
        {input}
        改成
        {output}
        请注意SynStart(i, synArray),SynEnd(i, synArray)应该在代码块内.
        
        *********************************************
        代码的上下文如下，禁止额外import：
        {refer}
        *********************************************
        
        所有函数都在import中给出，不需要额外编写。
        输出直接输出更改后的类，不要有其他东西。
        只输出代码！！！只输出代码！！！只输出代码！！！
        """)
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "input": """
        synchronized(对象){
            代码块体
        }
        """, "output": """
        {
            SynStart(1, synArray);
            代码块体
            SynEnd(1, synArray);
        }
        """, "refer": self.refer})

    def changeFuncSyn(self, code):
        chain = self.prompt_changeFunc | self.model | self.output_parser
        # st.code("开始转换函数上的synchronized关键字")
        return chain.invoke({"code": code, "input": """
        public synchronized 返回值类型 函数名(){
            函数体
        }
        """, "output": """
        public 返回值类型 函数名(){
            synchronized(this){
                函数体
            }
        }
        """, "refer": self.refer})

    def changeDing(self, code):
        template = """
        你是一个十分擅长typescript的程序员，请将用户输入的类用以下函数更改。
        现在有一个函数getClass(type: string, inClass ?: any)，
        作用是传入类型与值，返回一个any类型的对象。
        接收user输入的类，使用getClass改变成员变量的定义，例如：
        private a : number = 0;
        改成：
        private a : any = getClass('number', 0);
        再例如
        public s : string = 'test';
        改成：
        public s : any = getClass('string', 'test');
        再例如：
        public Test test = new Test();
        改成：
        public test : Test = getClass('Test', new Test());
        
        注意，请只在成员变量定义处改变，避免更改成员方法以及成员方法中的变量。
        
        *********************************************
        代码的上下文如下，禁止额外import：
        {refer}
        *********************************************
        
        不要额外编写函数。
        输出直接输出更改后的类，不要有其他东西。
        只输出代码！！！只输出代码！！！只输出代码！！！
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        # st.code("开始改变成员变量定义")
        return chain.invoke({"code": code, "refer": self.refer})

    def changeSetGet(self, code):
        template = """
        你是一个十分擅长typescript的程序员，请将用户输入的类用以下函数更改。
        现有函数getValues(code: any)，
        作用是传入类型为any的成员变量,返回其对应的值。
        只输出代码，不要输出其他分析。
        
        例如
        console.log(this.s+"ok");
        改为
        console.log(getValues(this.s)+"ok");
        例如：
        a = this.test.getNum();
        改为：
        a = getValues(this.test.getNum());
        再例如：
        this.son.run();
        改为：
        getValues(this.son.run());
        再例如：
        this.son.begin(this.a, this.b);
        改为：
        getValues(this.son.begin(getValues(this.a), getValues(this.b)));
        
        还有函数setValues(obj: any, tmp: any)，作用是传入类型为any的成员变量obj，将其赋值为对应类型的变量tmp。
        使用setValues改变成员变量被赋值的方式，例如
        this.a = 1;
        改成
        setValues(a, 1);
        请注意，对于等号前后都有成员变量的赋值语句，例如
        this.a = this.b + 1;
        改为
        setValues(this.a, getValues(this.b) + 1);
        
        *********************************************
        代码的上下文如下，禁止额外import：
        {refer}
        *********************************************
        
        不要额外编写函数。不要对非成员函数做这些。
        输出直接输出更改后的类，不要有其他东西。
        只输出代码！！！只输出代码！！！只输出代码！！！
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
        只输出代码，不要输出其他分析。
        你是一个十分擅长typescript的程序员，
        在用户传入的类中添加两个成员变量：
        public synArray : any = getSyc();
        public sharedType: string = "object";
                
        不要额外编写函数，若已存在上述成员变量，将其替换为上述变量。
        例如：
        public synArray : any = [];
        public sharedType: string = "object";
        改为：
        public synArray : any = getSyc();
        public sharedType: string = "object";
        输出直接输出更改后的类，请去除开头和结尾的```标记。不要输出其他信息。
        只输出代码！！！只输出代码！！！只输出代码！！！
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", template),
            ("user", "{code}")
        ])
        chain = prompt | self.model | self.output_parser
        # st.code("开始添加成员变量")
        return chain.invoke({"code": code})

    def run(self, code):
        if self.flag % 2 == 1:
            st.write("start analysing code")
            message = self.getMessage()
            # st.code(message)
            st.write("start initializing")
            code = deleteZhu(self.addChu(code, message))
            # st.code(code)
        if int(self.flag / 2) == 1:
            st.write("start dealing with synchronized")
            code = deleteZhu(self.changeFuncSyn(code))
            # st.code(code)
            code = deleteZhu(self.transSyc(code))
            # st.code(code)
        st.write("start converting to TS")
        code = deleteZhu(self.getStart(code))
        # st.code(code)
        st.write("start using set and get")
        code = deleteZhu(self.changeSetGet(code))
        # st.code(code)
        if self.flag % 2 == 1:
            st.write("start changing variables")
            code = deleteZhu(self.changeDing(code))
            # st.code(code)
        st.write("start adding variables")
        code = deleteZhu(self.addCheng(code))
        # st.code(code)
        return code


# with open('../tests/Syn.java', 'r') as file:
#     mycode = file.read()
#     print(ToTaskNew().changeSetGet(mycode))
