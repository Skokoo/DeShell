S = nydia.s data/data.s data/save.s gcore/actions.s gcore/loop.s gcore/rng.s

all:
	@clang -o deshell $(S)
	@echo -e "\033[1mdone\033[0m, go on check the binary"

clean:
	rm -f deshell
