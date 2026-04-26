# Lexical Analyzer Using Lex/Flex

| | |
|---|---|
| **University** | Alamein University |
| **Faculty** | Computer Science & Engineering |
| **Course** | CSE411 – Theory of Computation & Compilers |
| **Project** | Project 1 – Building a Lexical Analyzer Using Lex |
| **Student** | Mohamed Alsariti |
| **Due Date** | 26 April 2026 |

---

## Overview

This project implements a **lexical analyzer (scanner)** using **Flex** — the open-source implementation of the Unix Lex tool. The analyzer accepts any C-like source file as input, scans it character by character, and groups character sequences into classified **tokens**. Each token is printed with its line number, type, and matched value. A summary report is produced at the end.

---

## Token Types

| Token | Description | Examples |
|---|---|---|
| `KEYWORD` | Reserved language words | `int`, `if`, `while`, `return`, `true` |
| `DIRECTIVE` | Preprocessor instructions | `#include <stdio.h>`, `#define MAX 100` |
| `IDENTIFIER` | User-defined names | `main`, `factorial`, `isPrime` |
| `INTEGER` | Whole-number literals | `0`, `42`, `100` |
| `FLOAT` | Decimal / scientific literals | `3.14`, `0.0`, `1.5e2` |
| `STRING` | Double-quoted string literals | `"hello"`, `"Alamein"` |
| `CHAR_LIT` | Single-quoted character literals | `'A'`, `'\n'` |
| `OPERATOR` | Arithmetic, relational, logical, assignment | `+`, `==`, `&&`, `+=`, `++` |
| `DELIMITER` | Punctuation and separators | `(`, `)`, `{`, `}`, `;`, `,` |
| `COMMENT(SL)` | Single-line comment | `// text` |
| `COMMENT(ML)` | Multi-line block comment | `/* text */` |
| `UNKNOWN` | Unrecognized character | any unexpected symbol |

---

## Project Structure

```
toc-project/
├── lexer.l          — Flex source file (lexical analyzer)
├── sample_input.c   — Sample C-like program used as test input
├── output.txt       — Pre-generated output from running the analyzer
└── README.md        — This file
```

---

## Requirements

| Dependency | Version | Install (Debian / Ubuntu) |
|---|---|---|
| Flex | 2.6+ | `sudo apt-get install flex` |
| GCC | 9+ | `sudo apt-get install gcc` |

---

## Build & Run

### 1. Generate C source from the Flex file

```bash
flex -o lexer.c lexer.l
```

### 2. Compile

```bash
gcc -o lexer lexer.c -lfl
```

> On some systems use `-ll` instead of `-lfl`.

### 3. Run on an input file

```bash
./lexer sample_input.c
```

### 4. Save output to a file

```bash
./lexer sample_input.c > output.txt
```

### 5. Read from standard input

```bash
./lexer
```
Type or paste code, then press **Ctrl-D** to end input.

---

## Sample Output

```
=======================================================
  Lexical Analyzer  --  CSE411, Alamein University
  Student: Mohamed Alsariti
=======================================================

[Line   1] DIRECTIVE   : #include <stdio.h>
[Line   2] DIRECTIVE   : #include <stdlib.h>
[Line   4] DIRECTIVE   : #define MAX_SIZE 100
[Line   6] KEYWORD     : int
[Line   6] IDENTIFIER  : factorial
[Line   6] DELIMITER   : (
[Line   6] KEYWORD     : int
[Line   6] IDENTIFIER  : n
[Line   6] DELIMITER   : )
[Line   6] DELIMITER   : {
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
  Comments      : 0
  Unknown       : 0
-------------------------------------------------------
  TOTAL TOKENS  : 241
  Lines scanned : 61
=======================================================
```

---

## How It Works

A Flex `.l` file is divided into three sections, each separated by `%%`.

**Section 1 — Definitions**
Named regular-expression patterns are declared here (e.g. `DIGIT`, `IDENTIFIER`, `FLOAT`). These act as reusable building blocks for the rules below.

**Section 2 — Rules**
Each rule is a pattern–action pair. When the scanner finds the longest match for a pattern, it executes the corresponding action. Key design decisions:

- Keywords are listed **before** the `IDENTIFIER` rule so reserved words are never misclassified as identifiers.
- Floats are matched **before** integers to ensure `3.14` is not split into `3` and `.14`.
- Multi-line comments use an **exclusive start condition** (`%x BLOCK_COMMENT`). Once `/*` is matched, the scanner enters this state and consumes all characters — tracking newlines for accurate line counting — until `*/` is found.

**Section 3 — User Code**
The `main()` function opens the target file (or falls back to `stdin`), calls `yylex()` to start scanning, then prints the final token summary.

---

## Design Notes

- **Longest-match rule**: Flex always selects the longest possible match, so `==` is tokenized as one `OPERATOR` rather than two `=` tokens.
- **Line tracking**: A `line_number` counter is incremented on every newline, including newlines inside block comments.
- **No unknown tokens**: The sample input produces zero unknown tokens, confirming full coverage of standard C-like syntax.
