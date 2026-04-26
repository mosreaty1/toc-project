%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int count_keywords    = 0;
int count_identifiers = 0;
int count_integers    = 0;
int count_floats      = 0;
int count_strings     = 0;
int count_operators   = 0;
int count_delimiters  = 0;
int count_comments    = 0;
int count_unknown     = 0;
int line_number       = 1;
%}

%x BLOCK_COMMENT

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]
IDENTIFIER  {LETTER}{ALNUM}*
INTEGER     {DIGIT}+
FLOAT       {DIGIT}+\.{DIGIT}*([eE][+-]?{DIGIT}+)?|\.{DIGIT}+([eE][+-]?{DIGIT}+)?
STRING      \"([^\"\n\\]|\\.)*\"
WHITESPACE  [ \t\r]+

%%

"int"       |
"float"     |
"double"    |
"char"      |
"void"      |
"bool"      |
"string"    |
"return"    |
"if"        |
"else"      |
"while"     |
"for"       |
"do"        |
"switch"    |
"case"      |
"break"     |
"continue"  |
"struct"    |
"typedef"   |
"true"      |
"false"     |
"null"      |
"NULL"      |
"default"   {
                count_keywords++;
                printf("[Line %3d] KEYWORD     : %s\n", line_number, yytext);
            }

"#"[^\n]*   {
                count_keywords++;
                printf("[Line %3d] DIRECTIVE   : %s\n", line_number, yytext);
            }

{IDENTIFIER} {
                count_identifiers++;
                printf("[Line %3d] IDENTIFIER  : %s\n", line_number, yytext);
             }

{FLOAT}     {
                count_floats++;
                printf("[Line %3d] FLOAT       : %s\n", line_number, yytext);
            }

{INTEGER}   {
                count_integers++;
                printf("[Line %3d] INTEGER     : %s\n", line_number, yytext);
            }

{STRING}    {
                count_strings++;
                printf("[Line %3d] STRING      : %s\n", line_number, yytext);
            }

\'([^'\\\n]|\\.)\' {
                count_strings++;
                printf("[Line %3d] CHAR_LIT    : %s\n", line_number, yytext);
            }

"//"[^\n]*  {
                count_comments++;
                printf("[Line %3d] COMMENT(SL) : %s\n", line_number, yytext);
            }

"/*"        {
                count_comments++;
                BEGIN(BLOCK_COMMENT);
            }

<BLOCK_COMMENT>{
    "*/"    {
                printf("[Line %3d] COMMENT(ML) : (multi-line comment)\n", line_number);
                BEGIN(INITIAL);
            }
    \n      { line_number++; }
    .       { }
}

"=="        { count_operators++; printf("[Line %3d] OPERATOR    : ==\n",  line_number); }
"!="        { count_operators++; printf("[Line %3d] OPERATOR    : !=\n",  line_number); }
"<="        { count_operators++; printf("[Line %3d] OPERATOR    : <=\n",  line_number); }
">="        { count_operators++; printf("[Line %3d] OPERATOR    : >=\n",  line_number); }
"&&"        { count_operators++; printf("[Line %3d] OPERATOR    : &&\n",  line_number); }
"||"        { count_operators++; printf("[Line %3d] OPERATOR    : ||\n",  line_number); }
"++"        { count_operators++; printf("[Line %3d] OPERATOR    : ++\n",  line_number); }
"--"        { count_operators++; printf("[Line %3d] OPERATOR    : --\n",  line_number); }
"+="        { count_operators++; printf("[Line %3d] OPERATOR    : +=\n",  line_number); }
"-="        { count_operators++; printf("[Line %3d] OPERATOR    : -=\n",  line_number); }
"*="        { count_operators++; printf("[Line %3d] OPERATOR    : *=\n",  line_number); }
"/="        { count_operators++; printf("[Line %3d] OPERATOR    : /=\n",  line_number); }

[-+*/=<>!%&|^~]  {
                    count_operators++;
                    printf("[Line %3d] OPERATOR    : %s\n", line_number, yytext);
                 }

[(){}\[\];:,.]  {
                    count_delimiters++;
                    printf("[Line %3d] DELIMITER   : %s\n", line_number, yytext);
                }

\n          { line_number++; }

{WHITESPACE} { }

.           {
                count_unknown++;
                printf("[Line %3d] UNKNOWN     : %s\n", line_number, yytext);
            }

%%

int yywrap(void) { return 1; }

int main(int argc, char *argv[])
{
    if (argc > 1) {
        FILE *fp = fopen(argv[1], "r");
        if (!fp) {
            fprintf(stderr, "Error: cannot open file '%s'\n", argv[1]);
            return EXIT_FAILURE;
        }
        yyin = fp;
    } else {
        yyin = stdin;
    }

    printf("=======================================================\n");
    printf("  Lexical Analyzer  --  CSE411, Alamein University\n");
    printf("  Student: Mohamed Alsariti\n");
    printf("=======================================================\n\n");

    yylex();

    int total = count_keywords    + count_identifiers + count_integers
              + count_floats      + count_strings     + count_operators
              + count_delimiters  + count_comments    + count_unknown;

    printf("\n=======================================================\n");
    printf("  Token Summary\n");
    printf("=======================================================\n");
    printf("  Keywords      : %d\n", count_keywords);
    printf("  Identifiers   : %d\n", count_identifiers);
    printf("  Integers      : %d\n", count_integers);
    printf("  Floats        : %d\n", count_floats);
    printf("  Strings       : %d\n", count_strings);
    printf("  Operators     : %d\n", count_operators);
    printf("  Delimiters    : %d\n", count_delimiters);
    printf("  Comments      : %d\n", count_comments);
    printf("  Unknown       : %d\n", count_unknown);
    printf("-------------------------------------------------------\n");
    printf("  TOTAL TOKENS  : %d\n", total);
    printf("  Lines scanned : %d\n", line_number);
    printf("=======================================================\n");

    if (argc > 1) fclose(yyin);
    return EXIT_SUCCESS;
}
