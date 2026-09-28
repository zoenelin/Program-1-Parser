%{
#include "cmd_data.h"
#include "cmd_parse.h"

#include <stdio.h>

/* The following definition ensures that helpful syntax errors are printed: do not  */
#define YY_USER_ACTION \
    yylloc->first_line = yylloc->last_line; \
    yylloc->first_column = yylloc->last_column; \
    for(int i = 0; yytext[i] != '\0'; i++) { \
        if(yytext[i] == '\n') { \
            yylloc->last_line++; \
            yylloc->last_column = 0; \
        } \
        else { \
            yylloc->last_column++; \
        } \
    }

/* The definition below allows for interactive input. */
#define YY_USER_INIT \
  yy_set_interactive(yyin == stdin);

%}

%option outfile="cmd_lex.c" header-file="cmd_lex.h"

%option reentrant noyywrap
%option bison-bridge bison-locations
%%

\"([^\\\"]|\\.)*\" { yylval->str_temp = strdup(yytext); }

[ \n\r\f\t]*  { continue; }

%%
