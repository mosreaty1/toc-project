# Project 1: Lexical Analyzer Using Lex

**Course:** CSE411 – Theory of Computation & Compilers  
**University:** Alamein University – Faculty of Computer Science & Engineering  
**Due:** 26/4/2026

---

## Description

This project implements a lexical analyzer (scanner) using **Flex** (the free, open-source version of Lex). The analyzer reads a C-like source file and classifies every character sequence into one of the following token types:

| Token Type   | Description                                                  |
|--------------|--------------------------------------------------------------|
| KEYWORD      | Reserved words: `int`, `float`, `if`, `while`, `return`, … |
| DIRECTIVE    | Preprocessor lines: `#include`, `#define`, …                |
| IDENTIFIER   | User-defined names (variables, functions, …)                |
| INTEGER      | Whole-number literals: `0`, `42`, `100`                     |
| FLOAT        | Decimal/exponent literals: `3.14`, `1.5e2`, `0.001`         |
| STRING       | Double-quoted string literals: `"hello"`                    |
| CHAR_LIT     | Single-quoted character literals: `'A'`                     |
| OPERATOR     | Arithmetic, relational, logical, assignment operators       |
| DELIMITER    | Punctuation: `( ) { } [ ] ; , . :`                         |
| COMMENT(SL)  | Single-line comment `// …`                                  |
| COMMENT(ML)  | Multi-line comment `/* … */`                                |
| UNKNOWN      | Any character that does not match a known pattern           |

For each recognized token the analyzer prints its **line number**, **type**, and **value**. At the end it prints a **summary table** with per-category counts and total tokens.

---

## Files

```
toc-project/
├── lexer.l          ← Flex source (the lexical analyzer)
├── sample_input.c   ← Sample C-like program used as test input
├── output.txt       ← Pre-generated output for sample_input.c
└── README.md        ← This file
```

---

## Requirements

| Tool  | Version tested |
|-------|---------------|
| Flex  | 2.6.4         |
| GCC   | 13+           |

Install on Debian/Ubuntu:

```bash
sudo apt-get install flex gcc
```

---

## How to Compile and Run

### Step 1 – Generate C source from the Flex file

```bash
flex -o lexer.c lexer.l
```

### Step 2 – Compile the generated C source

```bash
gcc -o lexer lexer.c -lfl
```

> The `-lfl` flag links the Flex runtime library. On some systems you may need
> `-ll` instead, or remove it if `yywrap` is already defined (it is, in `lexer.l`).

### Step 3 – Run the analyzer

**On a file:**

```bash
./lexer sample_input.c
```

**Redirect output to a text file:**

```bash
./lexer sample_input.c > my_output.txt
```

**Read from standard input (type / paste code, then Ctrl-D):**

```bash
./lexer
```

---

## Sample Output (excerpt)

```
=======================================================
  Lexical Analyzer  --  CSE411, Alamein University
=======================================================

[Line   4] COMMENT(ML) : (multi-line comment)
[Line   6] DIRECTIVE   : #include <stdio.h>
[Line  11] COMMENT(SL) : // Compute the factorial of n recursively
[Line  12] KEYWORD     : int
[Line  12] IDENTIFIER  : factorial
[Line  12] DELIMITER   : (
[Line  12] KEYWORD     : int
[Line  12] IDENTIFIER  : n
[Line  12] DELIMITER   : )
[Line  12] DELIMITER   : {
...

=======================================================
  Token Summary
=======================================================
  Keywords      : 41
  Identifiers   : 53
  Integers      : 17
  Floats        : 4
  Strings       : 4
  Operators     : 37
  Delimiters    : 85
  Comments      : 9
  Unknown       : 0
-------------------------------------------------------
  TOTAL TOKENS  : 250
  Lines scanned : 73
=======================================================
```

---

## How It Works

The Flex file `lexer.l` is divided into three sections separated by `%%`:

1. **Definitions section** – C headers, counter variables, named regex patterns  
   (`DIGIT`, `LETTER`, `IDENTIFIER`, `INTEGER`, `FLOAT`, `STRING`).

2. **Rules section** – Pattern–action pairs. Flex tries rules top-to-bottom and
   applies the **longest match**. Keywords are listed before the `IDENTIFIER`
   rule so reserved words are not misclassified. Multi-line comments use an
   **exclusive start condition** (`%x BLOCK_COMMENT`) to consume everything
   until `*/` is found, correctly tracking embedded newlines.

3. **User code section** – `main()` opens the input file (or `stdin`), calls
   `yylex()`, and prints the summary report.
