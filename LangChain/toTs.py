from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai.chat_models import ChatOpenAI
import streamlit as st


class ToTs:
    def __init__(self):
        self.model = ChatOpenAI(temperature=0, model="gpt-4o")

        self.template_start = """
        请将user提供的Java代码格式化，并转换成typescript代码。
        输出中除了转换后的typescript代码不要有任何东西。
        """
        self.prompt_start = ChatPromptTemplate.from_messages([
            ("system", self.template_start),
            ("user", "{code}")
        ])

        self.template_exim = """
        在 TypeScript 中，通常是不允许将类的定义放在类的使用之后的。
        请将user提供的typescript代码改正确。
        """
        self.prompt_exim = ChatPromptTemplate.from_messages([
            ("system", self.template_exim),
            ("user", "{code}")
        ])

        self.output_parser = StrOutputParser()

    def getStart(self, code):
        st.write("start converting")
        # st.code("开始初步转换")
        chain = self.prompt_start | self.model | self.output_parser
        return chain.invoke({"code": code})

    def getExim(self, code):
        st.write("start changing code structure")
        # st.code("开始改正代码结构")
        chain = self.prompt_exim | self.model | self.output_parser
        return chain.invoke({"code": code})

    def getTest(self, code):
        st.write("start dealing with inner class")
        # st.code("开始处理内部类")
        model = ChatOpenAI()
        template = """
        {code}请使用类字段的方法定义内部类，并将外部类实例传递进去。
        """
        prompt = ChatPromptTemplate.from_template(template)
        chain = prompt | model | self.output_parser
        return chain.invoke({"code": code})

    def getPublic(self, code):
        code = self.getTest(code)
        st.write("start correcting inner class")
        # st.code("开始内部类细节修正")
        model = ChatOpenAI()
        template = """
                {code}请将内部类构造方法中的外部类变量访问权限改为public。
                """
        prompt = ChatPromptTemplate.from_template(template)
        chain = prompt | model | self.output_parser
        return chain.invoke({"code": code})

    def getClean(self, code):
        # code = self.getExim(code)
        st.write("start repairing detail")
        # st.code("开始细节修正")
        model = ChatOpenAI()
        template = """
        将typescript代码格式化。
        不要更改任何代码逻辑。
        注意，只输出可运行的代码，不输出其他文本。
        {code}
        """
        prompt = ChatPromptTemplate.from_template(template)
        chain = prompt | model | self.output_parser
        return chain.invoke({"code": code})

    def getFix(self, code, error_message):
        st.write("start repairing code")
        # st.code("开始编译修正")
        sys_template = """
        你是一个十分擅长typescript的程序员。
        你要根据用户提供的报错信息修复传入的typescript代码。
        如果有import与下方代码冲突时，以import为主。
        输出直接输出更改后的可运行代码，请去除开头和结尾的```标记。不要输出其他信息。
        """
        user_template = """
        代码：
        {code}
        
        ********************************************
        
        报错信息：
        {error_message}
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", sys_template),
            ("user", user_template)
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "error_message": error_message})
