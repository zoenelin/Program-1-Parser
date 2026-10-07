#include "cmd_data.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

static void print(CLObj *e) {
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

    case FLAG:
      printf("FLAG %s\n", e->value);
      break;

    case LONG_OPTION:
      printf("LONG OPT %s\n", e->value);
      print(e->child);
      break;

    case COMMAND: 
      {
        printf("COMMAND %s\n", e->value);
        int count = 0;
        CLObj *current = e->child;
        while (current != NULL) {
          count++;
          current = current->next;
        }
        printf("ARGS %d\n", count);
        current = e->child;
        while (current != NULL) {
          print(current);
          current = current->next;
        }
        break;
      }

    case FUNCTION: 
      {
        printf("FUNCTION %s\n", e ->value);
        printf("ARGUMENTS %d\n", e->count);
        CLObj *current = e->child;
        int i = 0;
        while (current != NULL && i < e->count) {
          print(current);
          current = current->next;
          i++;
        }
        int bodyCount = 0;
        CLObj *body = current;
        while (body != NULL) {
          bodyCount++;
          body = body->next;
        }
        printf("BODY %d\n", bodyCount);
        while (current != NULL) {
          print(current);
          current = current->next;
        }
        break;
      }
  }
}

void evaluate(CLObj *e)
{
  /* TODO: Implement output routine */
  int count = 0;
  CLObj *current = e;

  while (current != NULL) {
    count++;
    current = current->next;
  }
  printf("PROGRAM %d\n", count);
  current = e;

  while (current != NULL) {
    print(current);
    current = current->next;
  }
}
