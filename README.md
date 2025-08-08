# README

## News

Compatible with API 10 and above versions

## LLM-Based Java Concurrent Program to ArkTS Converter

## ABSTRACT

HarmonyOS NEXT is a distributed operating system developed to
support HarmonyOS native apps. To support the new and independent Harmony ecosystem, developers are required to migrate their
applications from Android to HarmonyOS. However, HarmonyOS
utilizes ArkTS, a superset of TypeScript, as the programming language for application development. Hence, migrating applications
to HarmonyOS requires translating programs across different program languages, e.g., Java, which is known to be very challenging,
especially for concurrency programs. Java utilizes shared memory to implement concurrency programs, while ArkTS relies on
message passing (i.e., Actor model). This paper presents an LLMbased concurrent Java program to ArkTS converter. This converter
leverages the sophisticated code comprehension and generation
capabilities of large language models (LLMs) to streamline the translation process. By integrating the SharedArrayBuffer API native to
ArkTS, we’ve crafted ThreadBridge, a shared library that replicates
Java’s shared memory paradigm. Employing this library and LLM’s
Chain-of-thought mechanism, our approach divides the translation
challenge into specialized chains: the TypeScript (TS) chain, the
concurrency chain, and the synchronization chain. These targeted
chains are designed to efficiently translate Java’s source code into
its ArkTS equivalent, handling TypeScript-specific syntax, concurrency patterns, and synchronization logic with precision. In particular, this study provides a set of effective solutions to overcome the
differences in concurrency models between Java and ArkTS. With
this converter, developers can reduce manual code rewriting and
accelerate application adaptation and deployment on HarmonyOS
NEXT. Experimental results show that our converter successfully
compiles 66% of the 53 test samples, with an accuracy rate of 69%
for the successfully compiled results. In conclusion, our approach
demonstrates promising potential in handling the conversion of
concurrent Java programs to ArkTS, providing a foundation for
further improvement and optimization.

### Introduce of running

First you need to install LangChain and its package of openai

```
pip install -r requirements.txt
```

Set environment variables `OPENAI_API_KEY` to your api_key of openai.

To run the AST, you need to install Java 17.

To perform compilation check, you need to install tsc.

```
cd LangChain
streamlit run start.py
```

demo: https://youtu.be/EPcs96vQzpg
