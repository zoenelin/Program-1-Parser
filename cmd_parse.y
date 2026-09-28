%{
#include "cmd_data.h"
#include "cmd_parse.h"
#include "cmd_lex.h"

#define YYPARSE_PARAM scanner
#define YYLEX_PARAM scanner

int yyerror(YYLTYPE*, CLObj**, yyscan_t, const char*);

void print_loc(FILE*, YYLTYPE);
#define YYLOCATION_PRINT print_loc

%}
%locations

%code requires {
    typedef void *yyscan_t;
}

%output "cmd_parse.c"
%defines "cmd_parse.h"

%define api.pure full
%define parse.error custom
%lex-param { yyscan_t scanner }
%parse-param { CLObj **expression }
%parse-param { yyscan_t scanner }

%union {
    char* str_temp;
}

%%

/* TODO: Fill in the parser */

/* TODO: Your top-level rule should put an object of type CLObj* into *expression */
input:          %empty { *expression = NULL; }
        ;

%%

/* The code below produces more helpful syntax errors. */
int
yyreport_syntax_error (const yypcontext_t *ctx, CLObj **expr, yyscan_t scanner)
{
  int res = 0;
  YYLOCATION_PRINT (stderr, *yypcontext_location (ctx));
  fprintf (stderr, ": syntax error");
  // Report the tokens expected at this point.
  {
    enum { TOKENMAX = 5 };
    yysymbol_kind_t expected[TOKENMAX];
    int n = yypcontext_expected_tokens (ctx, expected, TOKENMAX);
    if (n < 0)
      // Forward errors to yyparse.
      res = n;
    else
      for (int i = 0; i < n; ++i)
        fprintf (stderr, "%s %s",
                 i == 0 ? ": expected" : " or", yysymbol_name (expected[i]));
  }
  // Report the unexpected token.
  {
    yysymbol_kind_t lookahead = yypcontext_token (ctx);
    if (lookahead != YYSYMBOL_YYEMPTY)
      fprintf (stderr, " before %s", yysymbol_name (lookahead));
  }
  fprintf (stderr, "\n");
  return res;
}

void print_loc(FILE* stream, YYLTYPE loc)
{
    if (loc.first_line == loc.last_line)
        fprintf(stream, "Error: %d:(%d-%d)",
                loc.first_line,
                loc.first_column,
                loc.last_column);
    else
        fprintf(stream, "Error: %d:%d-%d:%d",
                loc.first_line,
                loc.first_column,
                loc.last_line,
                loc.last_column);
}
