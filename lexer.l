%{
/*
 * lexer.l - Lexical Analyzer using Lex/Flex
 * Course: CSE411 - Theory of Computation & Compilers
 * Alamein University - Faculty of Computer Science & Engineering
 * Due: 26/4/2026
 *
 * This lexer reads input and classifies tokens into:
 *   - Keywords (reserved words of C-like languages)
 *   - Identifiers (variable/function names)
 *   - Integer literals
 *   - Floating-point literals
 *   - String literals
 *   - Operators (arithmetic, relational, logical, assignment)
 *   - Delimiters / punctuation
 *   - Comments (single-line and multi-line)
 *   - Whitespace (silently skipped)
 *   - Unknown characters (flagged)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Token counters */
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

/* Start condition for multi-line comments */
%x BLOCK_COMMENT

/* ── Named pattern definitions ── */

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]

/* Identifier: starts with letter/underscore */
IDENTIFIER  {LETTER}{ALNUM}*

/* Integer: one or more digits */
INTEGER     {DIGIT}+

/* Float: digits.digits with optional exponent */
FLOAT       {DIGIT}+\.{DIGIT}*([eE][+-]?{DIGIT}+)?|\.{DIGIT}+([eE][+-]?{DIGIT}+)?

/* String literal: characters between double quotes */
STRING      \"([^\"\n\\]|\\.)*\"

/* Whitespace */
WHITESPACE  [ \t\r]+

%%

 /* ─────────────────────────────────────────────────────
  * Rules are tried in order; longest match wins.
  * Keywords must appear before the IDENTIFIER rule so
  * reserved words are not classified as identifiers.
  * ───────────────────────────────────────────────────── */

 /* ── Keywords (C-like reserved words) ── */
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

 /* ── Preprocessor directives ── */
"#"[^\n]*   {
                /* e.g. #include <stdio.h>, #define MAX 100 */
                count_keywords++;
                printf("[Line %3d] DIRECTIVE   : %s\n", line_number, yytext);
            }

 /* ── Identifiers ── */
{IDENTIFIER} {
                count_identifiers++;
                printf("[Line %3d] IDENTIFIER  : %s\n", line_number, yytext);
             }

 /* ── Floating-point numbers (before integers to get longest match) ── */
{FLOAT}     {
                count_floats++;
                printf("[Line %3d] FLOAT       : %s\n", line_number, yytext);
            }

 /* ── Integer numbers ── */
{INTEGER}   {
                count_integers++;
                printf("[Line %3d] INTEGER     : %s\n", line_number, yytext);
            }

 /* ── String literals (double-quoted) ── */
{STRING}    {
                count_strings++;
                printf("[Line %3d] STRING      : %s\n", line_number, yytext);
            }

 /* ── Character literals (single-quoted) ── */
\'([^'\\\n]|\\.)\'  {
                count_strings++;
                printf("[Line %3d] CHAR_LIT    : %s\n", line_number, yytext);
            }

 /* ── Single-line comment: // to end of line ── */
"//"[^\n]*  {
                count_comments++;
                printf("[Line %3d] COMMENT(SL) : %s\n", line_number, yytext);
            }

 /* ── Multi-line comment: enter BLOCK_COMMENT state ── */
"/*"        {
                count_comments++;
                BEGIN(BLOCK_COMMENT);
            }

<BLOCK_COMMENT>{
    "*/"    {
                /* End of block comment — return to normal scanning */
                printf("[Line %3d] COMMENT(ML) : (multi-line comment)\n", line_number);
                BEGIN(INITIAL);
            }
    \n      { line_number++; }  /* track newlines inside comment */
    .       { /* consume everything else inside the comment */ }
}

 /* ── Multi-character operators (must precede single-char rules) ── */
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

 /* ── Single-character operators ── */
[-+*/=<>!%&|^~]  {
                    count_operators++;
                    printf("[Line %3d] OPERATOR    : %s\n", line_number, yytext);
                 }

 /* ── Delimiters / punctuation ── */
[(){}\[\];:,.]  {
                    count_delimiters++;
                    printf("[Line %3d] DELIMITER   : %s\n", line_number, yytext);
                }

 /* ── Newline: update line counter ── */
\n          { line_number++; }

 /* ── Whitespace: skip silently ── */
{WHITESPACE} { /* ignored */ }

 /* ── Anything else is flagged as unknown ── */
.           {
                count_unknown++;
                printf("[Line %3d] UNKNOWN     : %s\n", line_number, yytext);
            }

%%

/* ── User code section ── */

int yywrap(void) { return 1; }

int main(int argc, char *argv[])
{
    /* Open an input file if provided, otherwise read from stdin */
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
    printf("=======================================================\n\n");

    yylex();

    /* Summary report */
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
