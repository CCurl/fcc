app := tc

ARCH ?= 32
CXX := clang
CFLAGS := -m$(ARCH) -O3 -D IS_LINUX

srcfiles := $(shell find . -name "*.c")
incfiles := $(shell find . -name "*.h")
LDLIBS   := -lm

# -------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------

all: fcc

fcc: fcc.c heap.c heap.h
	$(CXX) $(CFLAGS) $(LDFLAGS) -o fcc fcc.c heap.c $(LDLIBS)
	ls -l fcc

bin: all
	cp -u -p fcc ~/bin/

# -------------------------------------------------------------------
# Scripts
# -------------------------------------------------------------------

clean:
	rm -f fcc

test: fcc test.fcc
	./fcc test.fcc > test.asm
	fasm test.asm test
	chmod +x test
