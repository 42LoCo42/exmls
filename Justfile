help:
	just -l

test:
	mix dialyzer
	mix test
	nix build -L
