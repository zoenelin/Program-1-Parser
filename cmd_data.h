#ifndef CMD_DATA_H
#define CMD_DATA_H

typedef struct CLObj CLObj;

typedef enum {
  STRING,
  INTEGER,
  FLOAT,
  VARIABLE,
  SYMBOL
} Obj;

struct CLObj {
  Obj type;
  char *value;
};

void evaluate(CLObj *);

#endif
