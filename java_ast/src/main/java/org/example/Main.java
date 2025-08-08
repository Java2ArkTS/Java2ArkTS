package org.example;
import com.github.javaparser.JavaParser;
import com.github.javaparser.ast.CompilationUnit;
import com.github.javaparser.ast.body.BodyDeclaration;
import com.github.javaparser.ast.body.ClassOrInterfaceDeclaration;
import com.github.javaparser.ast.body.FieldDeclaration;
import com.github.javaparser.ast.type.Type;
import com.github.javaparser.ast.visitor.VoidVisitorAdapter;
import com.github.javaparser.ast.Modifier;
import com.github.javaparser.ast.type.*;
import java.io.*;
import java.util.*;
import com.github.javaparser.ParserConfiguration;
import com.github.javaparser.ast.body.MethodDeclaration;
import java.util.List;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import com.github.javaparser.ast.comments.LineComment;
import com.github.javaparser.ast.expr.NameExpr;
import com.github.javaparser.ast.stmt.BlockStmt;
import com.github.javaparser.ast.stmt.ExpressionStmt;
import com.github.javaparser.ast.stmt.SynchronizedStmt;
import com.github.javaparser.ast.comments.Comment;
import org.json.JSONArray;
import org.json.JSONObject;

// 添加到 import 列表中
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.charset.StandardCharsets;

public class Main {
    static int synchronizednum=0;
    static int Synchronizednum2=0;
    public static List<MethodDeclaration> methodlist = new ArrayList<>();
    static int is_innerclass_flag=0;
    static int bingfanum=0;
    static int classnum=0;
    static int is_run_flag=0;
    static boolean isSynchronized = false;
    static int is_SynchronizedStmt_flag=0;
    public static void main(String[] args) throws Exception {
        JSONObject resultJson = new JSONObject(); // 总结果JSON对象
        JSONArray classList = new JSONArray(); // 保存每个类的结构内容
        try {
            FileInputStream fileInputStream = new FileInputStream("Tmp.java");
            ParserConfiguration parserConfiguration = new ParserConfiguration();
            JavaParser javaParser = new JavaParser(parserConfiguration);
            CompilationUnit cu = javaParser.parse(fileInputStream).getResult().orElse(null);

            delet visitored = new delet();
            cu.accept(visitored,null);
            ClassVisitor visitor = new ClassVisitor(classList); // 传入 JSONArray
            cu.accept(visitor, null);
            change visitorred = new change();
            cu.accept(visitorred,null);

            int flag = 0;
            if(is_innerclass_flag==1) flag+=1;
            if(is_run_flag==1) flag+=2;
            if(is_SynchronizedStmt_flag==1) flag+=4;

            resultJson.put("classnum", classnum);
            resultJson.put("flag", flag);
            resultJson.put("ast_output", cu.toString());
            resultJson.put("classes", classList); // 添加类列表

            // 将结果写入 result.json 文件
            Files.write(Paths.get("result.json"), resultJson.toString(4).getBytes(StandardCharsets.UTF_8));

        }catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
    // 访问者类，用于遍历AST并修改内部类为public类名 = class

    private static class delet extends VoidVisitorAdapter<Void> {
        public void visit(CompilationUnit cu, Void arg) {
            super.visit(cu, arg);
            // 删除所有注释
            cu.getAllContainedComments().forEach(Comment::remove);
        }
    }
    private static class ClassVisitor extends VoidVisitorAdapter<Void> {
        private JSONArray classList;
        public ClassVisitor(JSONArray classList) {
            this.classList = classList;
        }

        private HashMap<ClassOrInterfaceDeclaration, MethodDeclaration> newMethods = new HashMap<>();

        @Override
        public void visit(ClassOrInterfaceDeclaration classDeclaration, Void arg) {
            super.visit(classDeclaration, arg);
            isSynchronized = false;

            classDeclaration.getMethods().forEach(method -> {
                if (method.isSynchronized()) isSynchronized = true;
                method.accept(new MethodVisitor(), null);
            });

            boolean hasMemberVariable = !classDeclaration.getFields().isEmpty();

            int tmp = 0;
            if (hasMemberVariable) tmp += 1;
            if (isSynchronized) tmp += 2;

            JSONObject classObj = new JSONObject();
            classObj.put("class_index", classnum);
            classObj.put("class_flag", tmp);
            classObj.put("class_code", classDeclaration.toString());
            classList.put(classObj);

            classnum++;

            if (classDeclaration.getExtendedTypes().stream().anyMatch(type -> type.getNameAsString().equals("Thread"))) {
                classDeclaration.setComment(new LineComment("threadAble_class"));
                is_run_flag = 1;
            }

            if (classDeclaration.isInnerClass()) {
                is_innerclass_flag = 1;
            }

            if (classDeclaration.getImplementedTypes().stream()
                    .anyMatch(type -> type.getNameAsString().equals("Runnable"))) {
                for (MethodDeclaration method : classDeclaration.getMethods()) {
                    if (method.getNameAsString().equals("run") &&
                            method.getType().toString().equals("void") &&
                            method.getParameters().isEmpty()) {
                    }
                }
                is_run_flag = 1;
                classDeclaration.setComment(new LineComment("threadAble_class"));
            }
        }

        @Override
        public void visit(MethodDeclaration method, Void arg) {
            super.visit(method, arg);
            if (method.isSynchronized()) {
                is_SynchronizedStmt_flag = 1;
            }
        }

        public void visit(SynchronizedStmt synchronizedStmt, Void arg) {
            super.visit(synchronizedStmt, arg);
            is_SynchronizedStmt_flag = 1;
            synchronizednum++;
            MethodDeclaration newMethod = createNewMethod(synchronizedStmt);
            ClassOrInterfaceDeclaration containingClass = synchronizedStmt.findAncestor(ClassOrInterfaceDeclaration.class).orElse(null);
            newMethods.put(containingClass, newMethod);
            methodlist.add(newMethod);
        }

        private static MethodDeclaration createNewMethod(SynchronizedStmt synchronizedStmt) {
            MethodDeclaration method = new MethodDeclaration();
            method.setModifiers(Modifier.publicModifier().getKeyword());
            method.setName("sychronize_method" + synchronizednum);
            method.setType(new VoidType());
            method.setBody(synchronizedStmt.getBody());
            return method;
        }
    }

    private static class MethodVisitor extends VoidVisitorAdapter<Void> {

        @Override
        public void visit(SynchronizedStmt synchronizedStmt, Void arg) {
            super.visit(synchronizedStmt, arg);
            isSynchronized = true;
        }
    }
    private static class change extends VoidVisitorAdapter<Void> {
        public void visit(SynchronizedStmt synchronizedStmt, Void arg) {
            super.visit(synchronizedStmt, arg);

            BlockStmt newBody = new BlockStmt();
            // 在新的 BlockStmt 中添加你需要的语句
            newBody.addStatement(new ExpressionStmt(new NameExpr(methodlist.get(Synchronizednum2).getName()+"();")));
            synchronizedStmt.setBody(newBody);
            Synchronizednum2++;
        }
    }
}
