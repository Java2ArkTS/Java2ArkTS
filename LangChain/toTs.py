from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai.chat_models import ChatOpenAI
import streamlit as st


class ToTs:
    def __init__(self):
        self.model = ChatOpenAI(temperature=0, model="gpt-4o")

        self.template_start = """
        Format the Java code provided by the user and convert it to TypeScript.

Ensure that:

The output contains only the converted TypeScript code.

No additional text, explanations, or formatting markers (e.g., ```).
        """
        self.prompt_start = ChatPromptTemplate.from_messages([
            ("system", self.template_start),
            ("user", "{code}")
        ])

        self.template_exim = """
       In TypeScript, it is generally not allowed to define a class after it is used.

Please correct the TypeScript code provided by the user.
        """
        self.prompt_exim = ChatPromptTemplate.from_messages([
            ("system", self.template_exim),
            ("user", "{code}")
        ])

        self.output_parser = StrOutputParser()

    def getStart(self, code):
        st.write("start converting")
        chain = self.prompt_start | self.model | self.output_parser
        return chain.invoke({"code": code})

    def getExim(self, code):
        st.write("start changing code structure")
        chain = self.prompt_exim | self.model | self.output_parser
        return chain.invoke({"code": code})

    def getTest(self, code):
        st.write("start dealing with inner class")
        model = ChatOpenAI()
        template = """
        Please define the inner class using a class field method and pass the instance of the outer class into it.
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
                Please change the access modifier of the outer class variables in the constructor of the inner class to public.
                """
        prompt = ChatPromptTemplate.from_template(template)
        chain = prompt | model | self.output_parser
        return chain.invoke({"code": code})

    def getClean(self, code):
        # code = self.getExim(code)
        st.write("start repairing detail")
        model = ChatOpenAI()
        template = """
        Format the TypeScript code.
Do not change any code logic.
Ensure that only the runnable code is output—no additional text.
{code}
        """
        prompt = ChatPromptTemplate.from_template(template)
        chain = prompt | model | self.output_parser
        return chain.invoke({"code": code})

    def getFix(self, code, error_message):
        st.write("start repairing code")
        # st.code("开始编译修正")
        sys_template = """
        You are a highly skilled TypeScript programmer.
You need to fix the TypeScript code provided by the user based on the error messages.
If there is a conflict between imports and the code below, prioritize the imports.
Output only the modified, runnable code—no markdown formatting (```) and no additional text.
        """
        user_template = """
        Code:
{code}

Error Message:
{error_message}
        """
        prompt = ChatPromptTemplate.from_messages([
            ("system", sys_template),
            ("user", user_template)
        ])
        chain = prompt | self.model | self.output_parser
        return chain.invoke({"code": code, "error_message": error_message})
