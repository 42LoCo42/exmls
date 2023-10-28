CFLAGS := \
	-Wall -Wextra -Werror \
	-fPIC -shared \
	-I $(ERL_INCLUDE_PATH) \
	-I $(HPKE)/include/hpke \
	-L $(HPKE)/lib -l hpke

nif.so: nif.c
	$(CC) $(CFLAGS) $< -o $@

install: nif.so
	mkdir -p "$(out)"
	cp $< "$(out)"
.PHONY: install
