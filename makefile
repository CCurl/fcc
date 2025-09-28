ARCH ?= 32
CXX := clang
CFLAGS := -m$(ARCH) -O3

# -------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------

all: fcl

fcl: fcc.c
	$(CXX) $(CFLAGS) -o fcl fcc.c
	ls -l fcl

bin: all
	cp -u -p fcl ~/bin/

# -------------------------------------------------------------------
# Scripts
# -------------------------------------------------------------------

clean:
	rm -f fcl tlin

test: fcl tlin.fth
	./fcl tlin.fth > tlin.asm
	fasm tlin.asm tlin
	chmod +x tlin
	./tlin
	