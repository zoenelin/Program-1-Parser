#ifndef CMD_DATA_H
#define CMD_DATA_H

typedef struct CLObj CLObj;

typedef enum {
  STRING,
  INTEGER,
  FLOAT,
  VARIABLE,
  SYMBOL,
  COMMAND,
  LONG_OPTION, 
  FUNCTION,
  FLAG
} Obj;

struct CLObj {
  Obj type;
  char *value;
  int count;
  CLObj *child;
  CLObj *next;
};

void evaluate(CLObj *);

#endif
