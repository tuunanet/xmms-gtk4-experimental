CPPFLAGS += -I.. -I../libxmms -I../xmms
CFLAGS += $(shell pkg-config --cflags gtk+-2.0)
LDLIBS += $(shell pkg-config --libs gtk+-2.0)

.PHONY: check clean

check: test-xentry test-filebrowser test-pluginenum test-outputplugin test-alsa-pcm-state
	./test-xentry
	./test-filebrowser
	./test-pluginenum
	./test-outputplugin
	./test-alsa-pcm-state

test-xentry: test-xentry.c ../libxmms/xentry.c ../libxmms/xentry.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-xentry.c ../libxmms/xentry.c $(LDLIBS)

test-filebrowser: CFLAGS += -ffunction-sections -fdata-sections
test-filebrowser: LDFLAGS += -Wl,--gc-sections
test-filebrowser: test-filebrowser.c ../xmms/util.c ../xmms/util.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-filebrowser.c ../xmms/util.c $(LDLIBS)

test-pluginenum: CFLAGS += -ffunction-sections -fdata-sections -DBUILD_PLUGIN_DIR=\"$(CURDIR)/test-plugins\" -DPLUGIN_DIR=\"/nonexistent\" -DPLUGINSUBS='"Output","Input"'
test-pluginenum: LDFLAGS += -Wl,--gc-sections
test-pluginenum: test-pluginenum.c ../xmms/pluginenum.c ../xmms/pluginenum.h test-plugins/Input/fixture/.libs/libfixture-input.so test-plugins/Output/fixture/.libs/libfixture-output.so
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-pluginenum.c ../xmms/pluginenum.c $(LDLIBS) -ldl

test-plugins/Input/fixture/.libs/libfixture-input.so: fixture-input-plugin.c
	mkdir -p test-plugins/Input/fixture/.libs
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -shared -o $@ $<

test-plugins/Output/fixture/.libs/libfixture-output.so: fixture-output-plugin.c
	mkdir -p test-plugins/Output/fixture/.libs
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -shared -o $@ $<

test-outputplugin: CFLAGS += -DBUILD_PLUGIN_DIR=\"$(CURDIR)/test-outputplugin-plugins\" -DPLUGIN_DIR=\"/nonexistent\"
test-outputplugin: test-outputplugin.c ../xmms/outputplugin.c ../xmms/outputplugin.h test-outputplugin-plugins/Output/alsa/.libs/libALSA.so
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-outputplugin.c ../xmms/outputplugin.c $(LDLIBS)

test-outputplugin-plugins/Output/alsa/.libs/libALSA.so:
	mkdir -p test-outputplugin-plugins/Output/alsa/.libs
	touch $@

test-alsa-pcm-state: test-alsa-pcm-state.c ../Output/alsa/pcm-state.c ../Output/alsa/pcm-state.h
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ test-alsa-pcm-state.c ../Output/alsa/pcm-state.c $(LDLIBS)

clean:
	rm -rf test-xentry test-filebrowser test-pluginenum test-outputplugin test-alsa-pcm-state test-plugins test-outputplugin-plugins
