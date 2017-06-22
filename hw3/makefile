output: lex.yy.c y.tab.c
	gcc lex.yy.c y.tab.c -o output

lex.yy.c: Assignment_3.l
	flex Assignment_3.l

y.tab.c: Assignment_3.y
	yacc Assignment_3.y -d


clean:
	rm lex.yy.c y.tab.h y.tab.c output
