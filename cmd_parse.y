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
    CLObj* obj_temp;
}

    %token VARREF OPTSTART OPTPAIR CMDSEP LPAR RPAR LBRACE RBRACE LABEL
    %token <str_temp> STR SYM INT FLT
    %type <obj_temp> variable sym int float string name_list function value_expression long_option arguments_list command command_list


%%

/* TODO: Fill in the parser */

variable:   VARREF SYM {
              $$ = malloc(sizeof(CLObj));
              $$->type = VARIABLE;
              $$->value = $2;
            }
            ;

sym:        SYM {
              $$ = malloc(sizeof(CLObj));
              $$->type = SYMBOL;
              $$->value = $1;
            }
            ;

int:        INT {
              $$ = malloc(sizeof(CLObj));
              $$->type = INTEGER;
              $$->value = $1;
            }
            ;

float:      FLT {
              $$ = malloc(sizeof(CLObj));
              $$->type = FLOAT;
              $$->value = $1;
            }
            ;

string:     STR {
              $$ = malloc(sizeof(CLObj));
              $$->type = STRING;
              $$->value = $1;
            }
            ;

name_list:        %empty                { $$ = NULL; }
                  | variable name_list  { $1->next = $2; $$ = $1; } 
                  ;

function:         LABEL SYM LPAR name_list RPAR LBRACE command_list RBRACE   { $$ = malloc(sizeof(CLObj)); $$->type = FUNCTION; $$->value = $2; $$->child = $4; $$->next = NULL;
                                                                               $$->count = 0; CLObj *current = $4; 
                                                                               while (current != NULL){
                                                                                $$->count++;
                                                                                current = current->next;
                                                                               }
                                                                               if($4 == NULL){
                                                                                $$->child = $7;
                                                                               } else {
                                                                                current = $4;
                                                                                while (current->next != NULL) {
                                                                                  current = current->next;
                                                                                }
                                                                                current->next = $7;
                                                                                }
                                                                              }
                                                                              ;

value_expression: sym
                  | int                { $$ = $1; }
                  | float              { $$ = $1; }
                  | string             { $$ = $1; }
                  | variable           { $$ = $1; }
                  | LPAR command RPAR  { $$ = $2; }
                  ;

long_option:      OPTSTART SYM                              { $$ = malloc(sizeof(CLObj)); $$->type = FLAG; $$->value = $2; $$->child = NULL; $$->next = NULL; }
                  | OPTSTART SYM OPTPAIR value_expression   { $$ = malloc(sizeof(CLObj)); $$->type = LONG_OPTION; $$->value = $2; $$->child = $4; $$->next = NULL; }
                  ;

arguments_list:  %empty                               { $$ = NULL; }      
                  | value_expression arguments_list   { $1->next = $2; $$ = $1; }
                  | long_option arguments_list        { $1->next = $2; $$ = $1; }
                  ;

command:          sym arguments_list { $$ = malloc(sizeof(CLObj)); $$->type = COMMAND; $$->value = $1->value; $$->child = $2; $$->next = NULL; }
                  ;

command_list:     %empty                          { $$ = NULL; }
                  | function command_list         { $1->next = $2; $$ = $1; }
                  | command CMDSEP command_list   { $1->next = $3; $$ = $1; }
                  ;

/* TODO: Your top-level rule should put an object of type CLObj* into *expression */
input:          command_list { *expression = $1;  } /* deleted the empty terminal as command_list already has empty and don't want to cause errors */
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
