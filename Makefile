.PHONY: all
all: main

CFLAGS	   := -ggdb -Wall
LEX	   := flex
BISON	   := bison
BISONFLAGS :=
DOT        := dot
DOTFLAGS   :=

%.gv: %.y
	$(BISON) $(BISONFLAGS) --graph $<

%.png: %.gv
	$(DOT) $(DOTFLAGS) -Tpng -o $@ $<

%.output: %.y
	$(BISON) $(BISONFLAGS) --report all $<

%.counterexample: %.y
	$(BISON) $(BISONFLAGS) -Wcounterexamples $< 2>&1 | tee $@

%.c %.h: %.y
	$(BISON) $(BISONFLAGS) $<

main: cmd_lex.c cmd_parse.c cmd_data.c main.c
	$(CC) $(CFLAGS) $^ -o $@

.PHONY: debug
debug: cmd_parse.output cmd_parse.counterexample cmd_parse.png

.PHONY: clean
clean:
	$(RM) *.o cmd_lex.c cmd_lex.h cmd_parse.c cmd_parse.h main *.o submission.tbz2 cmd_parse.gv cmd_parse.png cmd_parse.output cmd_parse.counterexample distribution.tbz2

.PHONY: submission
submission: clean submission.tbz2

submission.tbz2: cmd_data.c cmd_data.h cmd_lex.l cmd_parse.y main.c Makefile SUBMISSION_DATA.json
	tar cjvf $@ $^

.PHONY: distribution
distribution: clean distribution.tbz2

distribution.tbz2: cmd_data.c cmd_data.h cmd_lex.l cmd_parse.y main.c Makefile SUBMISSION_DATA.json run-tests tests/*
	tar cjvf $@ $^
