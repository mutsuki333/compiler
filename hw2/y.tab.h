/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    SEM = 258,
    PRINT = 259,
    WHILE = 260,
    INT = 261,
    DOUBLE = 262,
    LB = 263,
    RB = 264,
    LCB = 265,
    RCB = 266,
    LE = 267,
    GE = 268,
    EQ = 269,
    NE = 270,
    STRING = 271,
    ADD = 272,
    SUB = 273,
    MUL = 274,
    DIV = 275,
    ASSIGN = 276,
    NUMBER = 277,
    FLOATNUM = 278,
    ID = 279
  };
#endif
/* Tokens.  */
#define SEM 258
#define PRINT 259
#define WHILE 260
#define INT 261
#define DOUBLE 262
#define LB 263
#define RB 264
#define LCB 265
#define RCB 266
#define LE 267
#define GE 268
#define EQ 269
#define NE 270
#define STRING 271
#define ADD 272
#define SUB 273
#define MUL 274
#define DIV 275
#define ASSIGN 276
#define NUMBER 277
#define FLOATNUM 278
#define ID 279

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 73 "Assignment_2.y" /* yacc.c:1909  */

  int intNum;
  double doubleNum;
  char *str;
  int boolean;

#line 109 "y.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
