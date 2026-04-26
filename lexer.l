%{
/*
 * lexer.l -- Lexical Analyzer
 * Course  : CSE411 -- Theory of Computation & Compilers
 * Student : Mohamed Alsariti
 * Univ.   : Alamein University, Faculty of CS & Engineering
 * Due     : 26/4/2026
 *
 * This file defines a lexical analyzer using Flex.
 * It reads a C-like source file and classifies every token into:
 *   Keywords, Directives, Identifiers, Integers, Floats,
 *   Strings, Char literals, Operators, Delimiters, Comments,
 *   and Unknown characters.
 * A per-token line is printed for each match, followed by a
 * summary table showing counts for every token category.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Counters -- one per token category */
int count_keywords    = 0;
int count_identifiers = 0;
int count_integers    = 0;
int count_floats      = 0;
int count_strings     = 0;
int count_operators   = 0;
int count_delimiters  = 0;
int count_comments    = 0;
int count_unknown     = 0;
int line_number       = 1;   /* tracks the current line for reporting */
%}

/* Exclusive start condition for multi-line block comments.
   When the opening delimiter is matched the scanner switches into
   this state and consumes all text until the closing delimiter. */
%x BLOCK_COMMENT

/* Named pattern definitions.
   Giving patterns a name makes the rules section easier to read
   and avoids repeating the same regex in multiple places. */

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ALNUM       [a-zA-Z0-9_]

/* Identifier: letter/underscore followed by letters, digits, underscores */
IDENTIFIER  {LETTER}{ALNUM}*

/* Integer: one or more consecutive digits */
INTEGER     {DIGIT}+

/* Float: digits.digits or .digits with an optional exponent (e.g. 1.5e2) */
FLOAT       {DIGIT}+\.{DIGIT}*([eE][+-]?{DIGIT}+)?|\.{DIGIT}+([eE][+-]?{DIGIT}+)?

/* String: text between double quotes; handles escaped characters */
STRING      \"([^\"\n\\]|\\.)*\"

/* Whitespace: spaces, tabs, carriage returns (skipped silently) */
WHITESPACE  [ \t\r]+

%%

 /* Rules Section
    Flex selects the rule with the LONGEST match. When two rules match
    the same length the one listed first wins. Keywords must therefore
    appear before the IDENTIFIER rule so "int" is not classified as an
    identifier. Floats must appear before integers so "3.14" is not
    split into "3" and ".14". */

 /* Keywords: reserved words that cannot be used as identifiers.
    Multiple patterns share one action using the trailing-| technique. */
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

 /* Preprocessor directives: lines beginning with # (e.g. #include, #define).
    The pattern [^\n]* consumes everything up to but not including the newline. */
"#"[^\n]*   {
                count_keywords++;
                printf("[Line %3d] DIRECTIVE   : %s\n", line_number, yytext);
            }

 /* Identifiers: any word that was not already matched as a keyword above. */
{IDENTIFIER} {
                count_identifiers++;
                printf("[Line %3d] IDENTIFIER  : %s\n", line_number, yytext);
             }

 /* Floating-point numbers must appear BEFORE integers.
    Without this order "3.14" would match "3" as INTEGER first. */
{FLOAT}     {
                count_floats++;
                printf("[Line %3d] FLOAT       : %s\n", line_number, yytext);
            }

 /* Integer literals: one or more digits. */
{INTEGER}   {
                count_integers++;
                printf("[Line %3d] INTEGER     : %s\n", line_number, yytext);
            }

 /* Double-quoted string literals. */
{STRING}    {
                count_strings++;
                printf("[Line %3d] STRING      : %s\n", line_number, yytext);
            }

 /* Single-quoted character literals (e.g. 'A', '\n'). */
\'([^'\\\n]|\\.)\' {
                count_strings++;
                printf("[Line %3d] CHAR_LIT    : %s\n", line_number, yytext);
            }

 /* Single-line comment: two slashes followed by everything to end of line. */
"//"[^\n]*  {
                count_comments++;
                printf("[Line %3d] COMMENT(SL) : %s\n", line_number, yytext);
            }

 /* Multi-line block comment: opening delimiter switches to BLOCK_COMMENT state.
    The counter is incremented here so the count is correct regardless of
    how many lines the comment spans. */
"/*"        {
                count_comments++;
                BEGIN(BLOCK_COMMENT);
            }

 /* Rules active only inside a block comment. */
<BLOCK_COMMENT>"*/"  {
                        /* Closing delimiter: print and return to normal scanning */
                        printf("[Line %3d] COMMENT(ML) : (multi-line comment)\n", line_number);
                        BEGIN(INITIAL);
                     }
<BLOCK_COMMENT>\n    { line_number++; /* count newlines to keep line_number accurate */ }
<BLOCK_COMMENT>.     { /* consume every other character without producing a token */ }

 /* Multi-character operators must appear BEFORE the single-character rule.
    Without this order "==" would be tokenized as two separate "=" operators. */
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

 /* Single-character operators: arithmetic, relational, bitwise, logical. */
[-+*/=<>!%&|^~]  {
                    count_operators++;
                    printf("[Line %3d] OPERATOR    : %s\n", line_number, yytext);
                 }

 /* Delimiters: brackets, braces, parentheses, and punctuation marks. */
[(){}\[\];:,.]  {
                    count_delimiters++;
                    printf("[Line %3d] DELIMITER   : %s\n", line_number, yytext);
                }

 /* Newline: not a token itself, but line_number must be incremented. */
\n          { line_number++; }

 /* Whitespace (spaces and tabs): silently ignored. */
{WHITESPACE} { }

 /* Catch-all: any character that did not match any rule above is flagged
    as UNKNOWN so the user knows it was not recognized by the analyzer. */
.           {
                count_unknown++;
                printf("[Line %3d] UNKNOWN     : %s\n", line_number, yytext);
            }

%%

int yywrap(void) { return 1; }

int main(int argc, char *argv[])
{
    /* Accept an optional filename argument; fall back to stdin. */
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

    yylex();   /* start scanning */

    /* Compute the grand total across all categories. */
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
