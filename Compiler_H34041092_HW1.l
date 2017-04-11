/*
	Topic: Homework1 for Compiler Course
	Deadline: xxx.xx.xxxx
*/

%{

/*	Definition section */

/*	insert the C library and variables you need */

	#include <stdio.h>
	#include <stdlib.h>
	#include <ctype.h>

/*
	Symbol table function

	TAs create the basic function which you have to fill.
	We encourage you define new function to make the program work better.
	However, the four basic functions must be finished.
*/

	typedef enum {INT,DOUBLE,nill}Type;

	struct SymbolTable{
		int index;
		Type type;
		char* id;
		struct SymbolTable *next;
	};

	Type declare=nill;
	struct SymbolTable* start=NULL;

	void create_symbol();
	void insert_symbol(char*, Type);
	int lookup_symbol(char*);
	void dump_symbol();
	int linenum = 0;

%}

/*	define regular expression label */

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*
number {digit}+
float {number}+"."{number}+
int [iI][nN][tT]
double [dD][oO][uU][bB][lL][eE]
print [pP][rR][iI][nN][tT]
while [wW][hH][iI][lL][eE]
Lcomment ("//"[^\n]*\n)

%x Comment
%%

 /*	Rules section */

";" 				{printf("%s \t SEMICOLON \n",yytext); }
"="					{printf("%s \t ASSIGN \n",yytext);}
"("					{printf("%s \t LB \n",yytext);}
")"					{printf("%s \t RB \n",yytext);}
{print}     {printf("%s \t PRINT FUNCTION \n",yytext);}
"/*"				{printf("start comments\n%s",yytext);BEGIN Comment;}
<Comment>[^(\*/)]"*/" {printf("%s",yytext);BEGIN 0;}
{Lcomment}				{printf("start comments\n%s",yytext);}
[\+\-\*\/%\^] 	{printf("%s \t OPERATOR \n",yytext);}
([><]=?)|([=!]=)			{printf("%s \t RELATIONAL \n",yytext);}
{int}     	{declare=INT;}
{double}    {declare=DOUBLE;}
{while}    {printf("%s \t WHILE FUNCTION \n",yytext);}
{id} 				{if(declare==nill)
							printf("%s \t ID \n",yytext);
						else{
							char* a;
							if(declare==DOUBLE)a="double";else a="int";
							printf("%s \t %s TYPE VAR \n",yytext,a);
						declare = nill;}
						}
{digit}+		{printf("%s \t NUMBER \n",yytext);}
{float}     {printf("%s \t FLOATNUMBER \n",yytext);}
[.]*				;
[ \t]				;
[\n]				{++linenum;}
<Comment>[\n] {printf("%s",yytext);++linenum}


%%

/*	C Code section */

/*	You have to define your C function in this section */

int main(int argc,char *argv[]){

	yyin = fopen(argv[1],"r");
	yylex();
	printf("\nParse over, the line number is %i.\n",linenum);
	dump_symbol();

	return 0;
}

int yywrap(void) {
    return 1;
}

void create_symbol(){
	printf("Create a symbol table");
	start = (stuct SymbolTable *)malloc(sizeof(struct SymbolTable));
	start->next = NULL;
}

void insert_symbol(char* s, Type t){
	if(start==NULL)create_symbol();
	if(lookup_symbol(s))
}

int lookup_symbol(char* sym){

}

void dump_symbol(){

}
