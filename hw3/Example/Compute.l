%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "y.tab.h"	/* header file generated by bison */
extern int yylineno;
%}

%%

[0-9]+   	{ 
			//printf("%s is a number \n", yytext); 			
			sscanf(yytext,"%d",&yylval.intVal); 
			return NUMBER; 
		} 
[\n]   { yylineno++; return '\n'; }
[ \t]   ;

.   { return yytext[0]; }

%%
int yywrap()
{
    return 1;
}

