if cc.has_header('linux/cdrom.h')
  cdaudio_module = shared_module('cdaudio', files('cdaudio.c', 'configure.c', 'cdinfo.c', 'cddb.c', 'http.c'), dependencies: gtk2_dep, include_directories: [xmms_include_dir, xmms_i18n_include_dir], install: false)
endif
