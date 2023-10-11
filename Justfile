help:
	just -l

check_use name:
	#!/usr/bin/env bash
	out="$(rg -n '{{name}}\.' | rg -v '\.t()')"
	if [ -n "$out" ]; then
		echo "$out"
		exit 1
	fi

test:
	just check_use Enums
	just check_use Structs
	mix dialyzer
	mix test
	nix build -L

