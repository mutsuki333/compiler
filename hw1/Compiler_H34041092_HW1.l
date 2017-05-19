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
	struct SymbolTable *start=NULL, *new, *last;

	void create_symbol();
	void insert_symbol(char*, Type);
	int lookup_symbol(char*);
	void dump_symbol();
	int linenum = 1;

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
if [iI][fF]
else [eE][lL][sS][eE]
Lcomment ("//"[^\n]*\n)

%x Comment String
%%

 /*	Rules section */

";" 				{printf("%s \t SEMICOLON \n",yytext); }
"," 				{printf("%s \t COMMA \n",yytext); }
"="					{printf("%s \t ASSIGN \n",yytext);}
"("					{printf("%s \t LB \n",yytext);}
")"					{printf("%s \t RB \n",yytext);}
{print}     {printf("%s \t PRINT FUNCTION \n",yytext);}
"/*"				{printf("start comments\n%s",yytext);BEGIN Comment;}
<Comment>[^(\*/)]*"*/" {printf("%s\n",yytext);BEGIN 0;}
{Lcomment}				{printf("start comments\n%s\n",yytext);}
\+				 	{printf("%s \t OPERATOR ADD \n",yytext);}
\-				 	{printf("%s \t OPERATOR MINUS \n",yytext);}
\*				 	{printf("%s \t OPERATOR MULTI \n",yytext);}
\/				 	{printf("%s \t OPERATOR DIVISION \n",yytext);}
\^				 	{printf("%s \t OPERATOR EXPO \n",yytext);}
"%"				 	{printf("%s \t OPERATOR REMAINDER \n",yytext);}
([><]=?)|([=!]=)			{printf("%s \t RELATIONAL \n",yytext);}
{int}     	{declare=INT;}
{double}    {declare=DOUBLE;}
{while}    {printf("%s \t WHILE FUNCTION \n",yytext);}
\"				 {printf("%s \t QUOTATION \n",yytext); BEGIN String;}
<String>[^"]* {printf("%s \t STRING \n",yytext);}
<String>\" {printf("%s \t QUOTATION \n",yytext); BEGIN 0;}
{if}    {printf("%s \t IF FUNCTION \n",yytext);}
{else}    {printf("%s \t ELSE FUNCTION \n",yytext);}
{id} 				{if(declare==nill)
							printf("%s \t ID \n",yytext);
						else{
							char* a;
							if(declare==DOUBLE)a="double";else a="int";
							printf("%s \t %s TYPE VAR \n",yytext,a);
							insert_symbol(yytext, declare);
						declare = nill;}
						}
{digit}+		{printf("%s \t NUMBER \n",yytext);}
{float}     {printf("%s \t FLOATNUMBER \n",yytext);}
[{}]*				;
[ \t]				;
[\n]				{++linenum;}
<Comment>[\n] {printf("%s",yytext);++linenum;}


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
	printf("Create a symbol table\n");
	new = (struct SymbolTable *)malloc(sizeof(struct SymbolTable));
	start = new;
	new->next = NULL;
	last = new;
}

void insert_symbol(char* s, Type t){
	if(start==NULL){
		create_symbol();
		printf("Insert a symbol: %s\n", s);
		new->index=0;
		new->type=t;
		new->id = malloc(strlen(s)+1);
		strcpy(new->id, s);
	}
	else if(lookup_symbol(s)){
		printf("Insert a symbol: %s\n", s);
		new = (struct SymbolTable *)malloc(sizeof(struct SymbolTable));
		new->index=last->index+1;
		new->type=t;
		new->id = malloc(strlen(s)+1);
		strcpy(new->id, s);
		last->next = new;
		new->next = NULL;
		last = new;
	}
}

int lookup_symbol(char* sym){
	struct SymbolTable *tmp;
	tmp = start;
	while(tmp!=NULL){
		if(strcmp(tmp->id,sym)==0)return tmp->index;
		tmp=tmp->next;
	}
	return -1;
}

void dump_symbol(){
	printf("\nThe symbol table dump:\n");
	struct SymbolTable *tmp, *tmp1;
	tmp = start;
	while(tmp!=NULL){
		char* a;
		if(tmp->type==DOUBLE)a="double";else a="int";
		printf("%i \t %s \t %s\n", tmp->index, tmp->id, a);
		tmp1 = tmp;
		tmp=tmp->next;
		free(tmp1);
	}
}
