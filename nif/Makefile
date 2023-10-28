CFLAGS := -Wall -Wextra -Werror -fPIC -shared -I $(ERL_INCLUDE_PATH)

nif.so: nif.c
	$(CC) $(CFLAGS) $< -o $@

install: nif.so
	mkdir -p "$(out)"
	cp $< "$(out)"
.PHONY: install
