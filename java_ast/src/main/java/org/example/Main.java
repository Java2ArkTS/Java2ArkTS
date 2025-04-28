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
        try {
            System.out.println("ast调用成功");
            FileInputStream fileInputStream = new FileInputStream("Tmp.java");

            ParserConfiguration parserConfiguration = new ParserConfiguration();
            JavaParser javaParser = new JavaParser(parserConfiguration);

            // 解析Java源文件并创建AST
            CompilationUnit cu = javaParser.parse(fileInputStream).getResult().orElse(null);

            // 修改AST，
            delet visitored = new delet();
            cu.accept(visitored,null);
            ClassVisitor visitor = new ClassVisitor();
            cu.accept(visitor, null);
            change visitorred = new change();
            cu.accept(visitorred,null);
            int flag=0;
            BufferedWriter writer1 = null;
            writer1 = new BufferedWriter(new FileWriter("classnum.txt"));
            writer1.write(Integer.toString(classnum));
            writer1.close();
            if(is_innerclass_flag==1) flag+=1;
            if(is_run_flag==1) flag+=2;
            if(is_SynchronizedStmt_flag==1) flag+=4;

            BufferedWriter writer = new BufferedWriter(new FileWriter("tmp.txt"));
            writer.write(cu.toString());
            writer.close();

            BufferedWriter writer2 = new BufferedWriter(new FileWriter("flag.txt"));
            writer2.write(Integer.toString(flag));
            writer2.close();

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
    private static class ClassVisitor extends VoidVisitorAdapter<Void> {//这一部分均为访问节点
        private HashMap<ClassOrInterfaceDeclaration,MethodDeclaration> newMethods = new HashMap<>();

        @Override
        public void visit(ClassOrInterfaceDeclaration classDeclaration, Void arg) {
            super.visit(classDeclaration, arg);
            isSynchronized = false;
            classDeclaration.getMethods().forEach(method -> {

                // 检查方法是否同步
                if (method.isSynchronized()) {
                    isSynchronized = true;
                }

                // 检查方法体中的同步块
                method.accept(new MethodVisitor(), null);
            });
            boolean hasMemberVariable = !classDeclaration.getFields().isEmpty();
            BufferedWriter writer = null;
            try {
                writer = new BufferedWriter(new FileWriter("class_flag"+classnum+".txt"));
                int tmp = 0;
                if(hasMemberVariable) {
                    tmp += 1;
                }
                if(isSynchronized) {
                    tmp += 2;
                }

                writer.write(Integer.toString(tmp));
                writer.close();
                writer = new BufferedWriter(new FileWriter("class"+classnum+".txt"));
                writer.write(classDeclaration.toString());
                writer.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
            classnum++;
            if (classDeclaration.getExtendedTypes().stream()
                    .anyMatch(type -> type.getNameAsString().equals("Thread"))) {
                // 在类定义中添加标签
                classDeclaration.setComment(new LineComment("threadAble_class"));
                is_run_flag=1;
            }
//             判断是否为内部类
            if (classDeclaration.isInnerClass()) {
//                // 修改为public类名 = class
//                Comment classComment = new LineComment("inner_class");
//                classDeclaration.setComment(classComment);
                is_innerclass_flag=1;
            }

            //是否实现runable
            if (classDeclaration.getImplementedTypes().stream()
                    .anyMatch(type -> type.getNameAsString().equals("Runnable"))) {
                // 遍历类中的方法
                for (MethodDeclaration method : classDeclaration.getMethods()) {
                    // 检查方法是否为 run 方法
                    if (method.getNameAsString().equals("run") &&
                            method.getType().toString().equals("void") &&
                            method.getParameters().isEmpty()) {
                    }
                }
                is_run_flag=1;
                classDeclaration.setComment(new LineComment("threadAble_class"));
            }
        }
        @Override
        public void visit(MethodDeclaration method, Void arg) {
            super.visit(method, arg);
            if (method.isSynchronized()) {
                //method.setComment(new LineComment("Synchronized_method"));
                is_SynchronizedStmt_flag=1;
            }

        }

        public void visit(SynchronizedStmt synchronizedStmt, Void arg) {
            super.visit(synchronizedStmt, arg);
            // 在 synchronized 块前添加注释
            //synchronizedStmt.setComment(new LineComment("Synchronized block"));
            is_SynchronizedStmt_flag=1;
            synchronizednum++;
            BlockStmt synchronizedBlock = synchronizedStmt.getBody();
            ClassOrInterfaceDeclaration containingClass = synchronizedStmt.findAncestor(ClassOrInterfaceDeclaration.class).orElse(null);
            Map<String, Type> externalVariables = new HashMap<>();
            synchronizedBlock.getStatements().forEach(statement -> {
                // 如果语句是一个表达式语句
                if (statement.isExpressionStmt()) {
                    ExpressionStmt exprStmt = statement.asExpressionStmt();
                    // 如果表达式是一个名称表达式（即变量）
                    if (exprStmt.getExpression().isNameExpr()) {
                        NameExpr nameExpr = exprStmt.getExpression().asNameExpr();
                        // 获取变量名和类型
                        String variableName = nameExpr.getNameAsString();
                        Type variableType = (Type) nameExpr.calculateResolvedType();
                        // 记录外部变量及其类型
                        externalVariables.put(variableName, variableType);
                    }
                }
            });
            MethodDeclaration newMethod = createNewMethod(synchronizedStmt);
            newMethods.put(containingClass,newMethod);
            methodlist.add(newMethod);
        }
        private static MethodDeclaration createNewMethod(SynchronizedStmt synchronizedStmt) {
            // 创建一个新的方法
            MethodDeclaration method = new MethodDeclaration();

            // 设置方法的修饰符和名称
            method.setModifiers(Modifier.publicModifier().getKeyword()); // 可以根据需要修改访问修饰符
            method.setName("sychronize_method"+synchronizednum);
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
