CPPFLAGS += -I../libxmms
CFLAGS += $(shell pkg-config --cflags gtk+-2.0)
LDLIBS += $(shell pkg-config --libs gtk+-2.0)

.PHONY: check clean

check: test-xentry
	./test-xentry

test-xentry: test-xentry.c ../libxmms/xentry.c ../libxmms/xentry.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ test-xentry.c ../libxmms/xentry.c $(LDLIBS)

clean:
	rm -f test-xentry
