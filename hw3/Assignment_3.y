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

FILE *file;

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

bool ID_err = false, isINT = true, TopOfStackNotFloat = true;
int lnum = 1;
int errCount = 0;

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
    : Arith '<' Arith         {printf("Start while loop with (%.0f < %.0f)\n", $1, $3);}
    | Arith '>' Arith         {printf("Start while loop with (%.0f > %.0f)\n", $1, $3);}
    | Arith LE Arith          {printf("Start while loop with (%.0f <= %.0f)\n", $1, $3);}
    | Arith GE Arith          {printf("Start while loop with (%.0f >= %.0f)\n", $1, $3);}
    | Arith EQ Arith          {printf("Start while loop with (%.0f == %.0f)\n", $1, $3);}
    | Arith NE Arith          {printf("Start while loop with (%.0f != %.0f)\n", $1, $3);}
    ;

Decl
    : INT ID                  {fprintf(file, "ldc 0\n");insert_symbol($2, "int", 0);}
    | DOUBLE ID               {fprintf(file, "ldc 0.000\n");insert_symbol($2, "double", 0);}
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
    | Arith ADD Term          {
                                $$ = $1 + $3;
                                printf("ADD\n");
                                if(isINT){
                                  fprintf(file,"iadd \n");
                                }
                                else
                                  fprintf(file,"fadd \n");
                              }
    | Arith SUB Term          {
                                $$ = $1 - $3;
                                printf("SUB\n");
                                if(isINT){
                                  fprintf(file,"isub \n");
                                }
                                else
                                  fprintf(file,"fsub \n");
                              }
    ;

Term
    : Factor                  {$$ = $1;}
    | Term MUL Factor         { if(isINT){
                                  $$ = (int)($1 * $3);
                                  fprintf(file, "imul\n");
                                }
                                else{
                                  $$ = $1 * $3;
                                  fprintf(file, "fmul\n");
                                }
                                printf("MUL \n");
                              }
    | Term DIV Factor         { printf("DIV\n");
                                if($3==0){
                                  char errmsg[500] = "<ERROR> cannot divide by 0 ";
                                  yyerror(errmsg);
                                  errCount++;
                                }
                                else if(isINT){
                                  $$ = (int)$1 / (int)$3;
                                  fprintf(file, "idiv\n");
                                }
                                else{
                                  $$ = $1 / $3;
                                  fprintf(file, "fdiv\n");
                                }
                              }
    ;

Factor
    : Group                   {$$ = $1;}
    | NUMBER                  {$$ = $1;fprintf(file, "ldc %i\n", (int)$1);}
    | FLOATNUM                {$$ = $1;isINT=false;fprintf(file, "ldc %f\n",$1);}
    | ID                      {
                                if(lookup_symbol($1)==-1){
                                  char errmsg[500] = "<ERROR> variable ";
                                  strcat(errmsg, $1);
                                  strcat(errmsg, " not declared \t");
                                  yyerror(errmsg);
                                  errCount++;
                                  ID_err = true;
                                }
                                else {
                                  struct SymbolTable *tmp;
                                  tmp = start;
                                  while(tmp!=NULL){
		                                  if(strcmp(tmp->id,$1)==0){
                                        $$ = tmp->data;
                                        if(tmp->type==t_double){
                                          isINT=false;
                                          fprintf(file, "fload %i\n", tmp->index);
                                        }
                                        else{
                                          fprintf(file, "iload %i\n", tmp->index);
                                        }
                                      }
		                                    tmp=tmp->next;
	                                }
                                }
                              }
    ;

Print
    : PRINT Group             { if(!ID_err){
                                  if(isINT){
                                    printf("Print : %i\n", (int)$2);
                                    fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                                            "swap       ;swap the top two items on the stack \n"
                                            "invokevirtual java/io/PrintStream/println(I)V\n" );
                                  }
                                  else{
                                    printf("Print : %.4f\n", $2);
                                    fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                                            "swap       ;swap the top two items on the stack \n"
                                            "invokevirtual java/io/PrintStream/println(F)V\n" );
                                  }
                                }
                              }
    | PRINT LB STRING RB      {
                                printf("Print : %s\n", $3);
                                fprintf(file, "ldc %s\n", $3);
                                fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
                                        "swap       ;swap the top two items on the stack \n"
                                        "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
                              }
    ;

Group
    : LB Arith RB             {$$ = $2;}
    ;


%%

int main(int argc, char** argv)
{
  file = fopen("Assignment_3.j","w");

  fprintf(file, ".class public main\n"
		     	".super java/lang/Object\n"
			".method public static main([Ljava/lang/String;)V\n"
			"	.limit stack %d\n"
			"	.limit locals %d\n",10,10);

  yylineno = 1;
  symnum = 0;
  yyparse();
  if(errCount>0){
    fprintf(file, "ldc \"\n\nCompile Failure!\"\n");
    fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
            "swap       ;swap the top two items on the stack \n"
            "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
    fprintf(file, "ldc \"Exist %i errors\"\n", errCount);
    fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
            "swap       ;swap the top two items on the stack \n"
            "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
  }
  else{
    fprintf(file, "ldc \"\n\nCompile Success!\"\n");
    fprintf(file,   "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
            "swap       ;swap the top two items on the stack \n"
            "invokevirtual java/io/PrintStream/println(Ljava/lang/String;)V\n" );
  }
  printf("\n\nTotal lines : %d \n",lnum);
	dump_symbol();

  fprintf(file, "return\n"
        ".end method\n");
  fclose(file);
  printf("\n\n\nGenerated: Assignment_3.j\n");



    return 0;
}

void yyerror(char *s) {
    printf("%s on line %d \n", s , lnum);
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
    if(t==t_int){
      fprintf(file,"istore %i\n", new->index);
    }
    else fprintf(file, "fstore %i\n", new->index);
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
    if(t==t_int){
      fprintf(file,"istore %i\n", new->index);
    }
    else fprintf(file, "fstore %i\n", new->index);
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
    errCount++;
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
      int d = data;
      fprintf(file, "istore %i\n",tmp->index);
      return;
    }
		tmp=tmp->next;
	}
  char errmsg[500] = "<ERROR> variable ";
  strcat(errmsg, id);
  strcat(errmsg, " not declared \t");
  ID_err = true;
  yyerror(errmsg);
  errCount++;
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
        errCount++;
      }
      tmp->data = data;
      fprintf(file, "fstore %i\n", tmp->index);
      return;
    }
		tmp=tmp->next;
	}
  char errmsg[500] = "<ERROR> variable ";
  strcat(errmsg, id);
  strcat(errmsg, "not declared \t");
  ID_err = true;
  yyerror(errmsg);
  errCount++;
}

/*symbol dump function*/
void dump_symbol(){
  if(start==NULL){
    printf("The symbol table is empty\n");
    return;
  }
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
