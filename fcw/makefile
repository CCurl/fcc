ARCH ?= 32
CXX := clang
CFLAGS := -m$(ARCH) -O3

# -------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------

all: fcl

fcl: fcc.c system.c
	$(CXX) $(CFLAGS) -o fcl fcc.c system.c
	ls -l fcl

bin: all
	cp -u -p fcl ~/bin/

# -------------------------------------------------------------------
# Scripts
# -------------------------------------------------------------------

clean:
	rm -f fcl

test: fcl tlin.fth
	./fcl tlin.fth > tlin.asm
	fasm tlin.asm tlin
	chmod +x tlin
	./tlin
	