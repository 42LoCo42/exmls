# show all tasks
help:
	just -l

# internal check, don't use
check_use name:
	#!/usr/bin/env bash
	# find incorrect usage of a type string
	# like ExMLS.Structs.Foo (missing a final .t())
	out="$(rg -n '{{name}}\.' | rg -v '\.t()')"
	if [ -n "$out" ]; then
		echo "$out"
		exit 1
	fi

# build the release with Nix
build:
	nix build -L

# run sanity checks, static analysis and tests
test:
	# just check_use Enums
	# just check_use Structs
	mix dialyzer
	mix test

# run the projet
run:
	mix run

# enter an interactive shell
shell:
	iex -S mix

# build the documentation
docs:
	mix docs

# remove unused dependencies
clean:
	mix deps.clean --unlock --unused
