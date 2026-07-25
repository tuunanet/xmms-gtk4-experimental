CPPFLAGS += -I.. -I../libxmms -I../xmms
CFLAGS += $(shell pkg-config --cflags gtk+-2.0)
LDLIBS += $(shell pkg-config --libs gtk+-2.0)

.PHONY: check clean

check: test-xentry test-filebrowser
	./test-xentry
	./test-filebrowser

test-xentry: test-xentry.c ../libxmms/xentry.c ../libxmms/xentry.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-xentry.c ../libxmms/xentry.c $(LDLIBS)

test-filebrowser: CFLAGS += -ffunction-sections -fdata-sections
test-filebrowser: LDFLAGS += -Wl,--gc-sections
test-filebrowser: test-filebrowser.c ../xmms/util.c ../xmms/util.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-filebrowser.c ../xmms/util.c $(LDLIBS)

clean:
	rm -f test-xentry test-filebrowser
