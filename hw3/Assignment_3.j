.class public main
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
	.limit stack 10
	.limit locals 10
ldc 0.000
fstore 0
ldc 6.880000
fstore 1
ldc 10
istore 2
fload 1
getstatic java/lang/System/out Ljava/io/PrintStream;
swap       ;swap the top two items on the stack 
invokevirtual java/io/PrintStream/println(F)V
fload 1
ldc 2.000000
fdiv
ldc 0.120000
fadd 
fstore 0
fload 0
getstatic java/lang/System/out Ljava/io/PrintStream;
swap       ;swap the top two items on the stack 
invokevirtual java/io/PrintStream/println(F)V
fload 1
fload 1
fadd 
fstore 3
fload 3
getstatic java/lang/System/out Ljava/io/PrintStream;
swap       ;swap the top two items on the stack 
invokevirtual java/io/PrintStream/println(F)V
iload 2
iload 2
iload 2
iadd 
imul
iload 2
ldc 2
idiv
idiv
istore 4
iload 4
getstatic java/lang/System/out Ljava/io/PrintStream;
swap       ;swap the top two items on the stack 
invokevirtual java/io/PrintStream/println(I)V
ldc "

Compile Success!"
getstatic java/lang/System/out Ljava/io/PrintStream;
swap       ;swap the top two items on the stack 
invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V
return
.end method
