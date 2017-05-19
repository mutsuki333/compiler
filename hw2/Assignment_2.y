/*
	Topic: Homework2 for Compiler Course
	Deadline: xxx.xx.xxxx
*/

%{

/*	Definition section */
/*	insert the C library and variables you need */

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*Extern variables that communicate with lex*/

extern int yylineno;
extern int yylex();

void yyerror(char *);


/*	Symbol table function

	TAs create the basic function which you have to fill.
	We encourage you define new function to make the program work better.
	However, the five basic functions must be finished.
*/

typedef enum {t_int,t_double,nill}Type;

struct SymbolTable{
  int index;
  Type type;
  char* id;
  double data;
  struct SymbolTable *next;
};

Type declare=nill;
struct SymbolTable *start=NULL, *new, *last;

void create_symbol();								/*establish the symbol table structure*/
void insert_symbol(char* id, char* type, double data);	/*Insert an undeclared ID in symbol table*/
void symbol_assign_int(char* id, double data);				/*Assign value to a declared ID in symbol table*/
void symbol_assign_double(char* id, double data);				/*Assign value to a declared ID in symbol table*/
int lookup_symbol(char* id);						/*Confirm the ID exists in the symbol table*/
void dump_symbol();									/*List the ids and values of all data*/

bool ID_err = false, isINT = true;
int lnum = 0;

int symnum;											/*The number of the symbol*/
//char errmsg[500];

/* Note that you should define the data structure of the symbol table yourself by any form */

%}


/* Token definition */
%token SEM PRINT WHILE INT DOUBLE LB RB LCB RCB LE GE EQ NE
%token STRING ADD SUB MUL DIV
%token ASSIGN NUMBER FLOATNUM ID

/* Type definition :

	Define the type by %union{} to specify the type of token

*/
%union {
  int intNum;
  double doubleNum;
  char *str;
  int boolean;
}

/* Type declaration :

	Use %type to specify the type of token within < >
	if the token or name of grammar rule will return value($$)

*/
%type <intNum> NUMBER
%type <doubleNum> FLOATNUM Arith Group Factor Term Stmt
%type <str> SEM PRINT WHILE INT DOUBLE LB RB STRING ADD SUB MUL DIV ASSIGN ID
%type <str> Decl Assign Print While
%type <boolean> Continue

%left ADD SUB MUL DIV '<' '>' LE GE EQ NE

%%

/* Define your parser grammar rule and the rule action */

Prog
    :
    | Prog Line
    | Prog Stmt Line           {ID_err = false; isINT = true;}
    ;

Line
    : '\n'                     {lnum++;}
    |
    ;

Stmt
    : Print SEM
    | Decl SEM
    | Assign SEM
    | Arith SEM
    | While
    ;

While
    : WHILE LB Continue RB Block {printf("End while loop\n");}
    ;

Block
    : LCB Prog RCB
    ;

Continue
    : Arith '<' Arith         {printf("Start while loop with %.0f < %.0f\n", $1, $3);}
    | Arith '>' Arith         {printf("Start while loop with %.0f > %.0f\n", $1, $3);}
    | Arith LE Arith          {printf("Start while loop with %.0f <= %.0f\n", $1, $3);}
    | Arith GE Arith          {printf("Start while loop with %.0f >= %.0f\n", $1, $3);}
    | Arith EQ Arith          {printf("Start while loop with %.0f == %.0f\n", $1, $3);}
    | Arith NE Arith          {printf("Start while loop with %.0f != %.0f\n", $1, $3);}
    ;

Decl
    : INT ID                  {insert_symbol($2, "int", 0);}
    | DOUBLE ID               {insert_symbol($2, "double", 0);}
    | INT ID ASSIGN Arith     {insert_symbol($2, "int", $4);}
    | DOUBLE ID ASSIGN Arith  {insert_symbol($2, "double", $4);}
    ;

Assign
    : ID ASSIGN Arith         { if(isINT)symbol_assign_int($1, (double)$3);
                                else
                                  symbol_assign_double($1, (double)$3);
                              }
    ;

Arith
    : Term                    {$$ = $1;}
    | Arith ADD Term          {$$ = $1 + $3;printf("ADD\n");}
    | Arith SUB Term          {$$ = $1 - $3;printf("SUB\n");}
    ;

Term
    : Factor                  {$$ = $1;}
    | Term MUL Factor         { if(isINT)$$ = (int)($1 * $3);
                                else
                                  $$ = $1 * $3;
                                printf("MUL \n");
                              }
    | Term DIV Factor         { printf("DIV\n");
                                if($3==0){
                                  char errmsg[500] = "<ERROR> cannot divide by 0 ";
                                  yyerror(errmsg);
                                }
                                else if(isINT){
                                  $$ = (int)$1 / (int)$3;
                                }
                                else
                                  $$ = $1 / $3;
                              }
    ;

Factor
    : Group                   {$$ = $1;}
    | NUMBER                  {$$ = $1;}
    | FLOATNUM                {$$ = $1;isINT=false;}
    | ID                      {
                                if(lookup_symbol($1)==-1){
                                  char errmsg[500] = "<ERROR> variable ";
                                  strcat(errmsg, $1);
                                  strcat(errmsg, " not declared \t");
                                  yyerror(errmsg);
                                  ID_err = true;
                                }
                                else {
                                  struct SymbolTable *tmp;
                                  tmp = start;
                                  while(tmp!=NULL){
		                                  if(strcmp(tmp->id,$1)==0){
                                        $$ = tmp->data;
                                        if(tmp->type==t_double)isINT=false;
                                      }
		                                    tmp=tmp->next;
	                                }
                                }
                              }
    ;

Print
    : PRINT Group             { if(!ID_err){
                                  if(isINT)
                                    printf("Print : %i\n", (int)$2);
                                  else
                                    printf("Print : %.4f\n", $2);
                                }
                              }
    | PRINT LB STRING RB      {printf("Print : %s\n", $3);}
    ;

Group
    : LB Arith RB             {$$ = $2;}
    ;


%%

int main(int argc, char** argv)
{
    yylineno = 1;
    symnum = 0;

    yyparse();

	printf("\n\nTotal lines : %d \n",yylineno);
	dump_symbol();
    return 0;
}

void yyerror(char *s) {
    printf("%s on %d line \n", s , yylineno);
}


/*symbol create function*/
void create_symbol() {
  printf("Create a symbol table\n");
	new = (struct SymbolTable *)malloc(sizeof(struct SymbolTable));
	start = new;
	new->next = NULL;
	last = new;
}

/*symbol insert function*/
void insert_symbol(char* id, char* type, double data) {
  Type t;
  if(strcmp(type,"int")==0) t=t_int;
  if(strcmp(type,"double")==0) t=t_double;
  if(start==NULL){
		create_symbol();
		printf("Insert a symbol: %s\n", id);
		new->index=0;
		new->type=t;
    new->data = data;
		new->id = malloc(strlen(id)+1);
		strcpy(new->id, id);
	}
	else if(lookup_symbol(id)<0){
		printf("Insert a symbol: %s\n", id);
		new = (struct SymbolTable *)malloc(sizeof(struct SymbolTable));
		new->index=last->index+1;
		new->type=t;
    new->data = data;
		new->id = malloc(strlen(id)+1);
		strcpy(new->id, id);
		last->next = new;
		new->next = NULL;
		last = new;
	}
  else {
    char a[500]="<ERROR> re-declaration for variable ";
    strcat(a, id);
    strcat(a, " \t");
    yyerror(a);
  }
}


/*symbol value lookup and check exist function*/
int lookup_symbol(char* id){
  struct SymbolTable *tmp;
  tmp = start;
  while(tmp!=NULL){
		if(strcmp(tmp->id,id)==0)return tmp->index;
		tmp=tmp->next;
	}
	return -1;
}

/*symbol value assign function*/
void symbol_assign_int(char* id, double data) {
  if(ID_err)return;
  printf("ASSIGN\n");
  struct SymbolTable *tmp;
  tmp = start;
  while(tmp!=NULL){
		if(strcmp(tmp->id,id)==0){
      tmp->data = data;
      return;
    }
		tmp=tmp->next;
	}
  char errmsg[500] = "<ERROR> variable ";
  strcat(errmsg, id);
  strcat(errmsg, " not declared \t");
  ID_err = true;
  yyerror(errmsg);
}

void symbol_assign_double(char* id, double data) {
  if(ID_err)return;
  printf("ASSIGN\n");
  struct SymbolTable *tmp;
  tmp = start;
  while(tmp!=NULL){
		if(strcmp(tmp->id,id)==0){
      if(tmp->type==t_int){
        char errmsg[500]="<ERROR> cannot convert double to int";
        yyerror(errmsg);
      }
      tmp->data = data;
      return;
    }
		tmp=tmp->next;
	}
  char errmsg[500] = "<ERROR> variable ";
  strcat(errmsg, id);
  strcat(errmsg, "not declared \t");
  ID_err = true;
  yyerror(errmsg);
}

/*symbol dump function*/
void dump_symbol(){
  printf("\nThe symbol table :\n");
  printf("ID\t\tType\tData\n");
	struct SymbolTable *tmp, *tmp1;
	tmp = start;
	while(tmp!=NULL){
		char* a;
		if(tmp->type==t_double){
      a="double";
      printf("%s\t\t%s\t%f\n", tmp->id, a, tmp->data);
    }
    else {
      a="int";
      int d = tmp->data;
      printf("%s\t\t%s\t%i\n", tmp->id, a, d);
		}
		tmp1 = tmp;
		tmp=tmp->next;
		free(tmp1);
	}
}
