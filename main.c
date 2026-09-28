#include "cmd_data.h"
#include "cmd_parse.h"
#include "cmd_lex.h"

#include <stdio.h>


int yyerror(YYLTYPE* locp, const char *msg) {
    fprintf(stderr, "%d:%d-%d:%d:\t%s\n",
            locp->first_line,
            locp->first_column,
            locp->last_line,
            locp->last_column,
            msg);
    return 1;
}


int main(int argc, char const* argv[])
{
  FILE *input_file;
  CLObj* e;
  yyscan_t scanner;

  yylex_init(&scanner);

  if (argc <= 1)
    {
      input_file = stdin;
    }
  else
    {
      if (!(input_file = fopen(argv[1], "r")))
        {
          fprintf(stderr, strerror(errno));
          return errno;
        }
    }

  yyset_in(input_file, scanner);
  yyset_debug(1, scanner);
  yyparse(&e, scanner);

  evaluate(e);
  return 0;
}
