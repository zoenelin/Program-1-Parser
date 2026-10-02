#include "cmd_data.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


void evaluate(CLObj *e)
{
  /* TODO: Implement output routine */
  if (e == NULL) {
    return;
  }
  switch (e->type) {
    case STRING:
      printf("STRING %lu %s\n", strlen(e->value), e->value);
      break;
    case INTEGER:
      printf("INTEGER %d\n", atoi(e->value));
      break;
    case FLOAT:
      printf("FLOAT %f\n", atof(e->value));
      break;
    case VARIABLE:
      printf("VARREF %s\n", e->value);
      break;
    case SYMBOL:
      printf("SYMBOL %s\n", e->value);
      break;
  }
}
