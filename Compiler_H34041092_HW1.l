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
	void create_symbol();
	void insert_symbol();
	int lookup_symbol();
	void dump_symbol();
	int linenum = 0;

%}

/*	define regular expression label */

letter [a-zA-Z]
digit [0-9]
id {letter}+({letter}|{digit})*

%%

 /*	Rules section */

";" 				{printf("%s \t SEM \n",yytext); }
"print"				{	/* C action code */	;}
"=" 				{printf("%s \t ASSIGN \n",yytext);}
"+" 				{printf("%s \t ADD \n",yytext);}
{id} 				{printf("%s \t ID \n",yytext); }
{digit}+			{printf("%s \t NUM \n",yytext);}
[\n]				{;}


%%

/*	C Code section */

/*	You have to define your C function in this section */

int main(int argc,char *argv[]){

	yyin = fopen(argv[1],"r");
	yylex();
	dump_symbol();

	return 0;
}

int yywrap(void) {
    return 1;
}

void create_symbol(){

}

void insert_symbol(char* s){

}

int lookup_symbol(char* sym){

}

void dump_symbol(){

}
