ARCH ?= 32
CXX := clang
CFLAGS := -m$(ARCH) -O3

# -------------------------------------------------------------------
# Targets
# -------------------------------------------------------------------

all: fcl

fcl: fcl.c
	$(CXX) $(CFLAGS) -o fcl fcl.c
	ls -l fcl

bin: all
	cp -u -p fcl ~/bin/

# -------------------------------------------------------------------
# Scripts
# -------------------------------------------------------------------

clean:
	rm -f fcl

test: fcl test.fth
	./fcl test.fth > test.asm
	fasm test.asm test
	chmod +x test
	./test
	