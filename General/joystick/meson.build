if cc.has_header('linux/joystick.h')
  joystick_module = shared_module('joy', files('joy.c', 'configure.c', 'about.c'), dependencies: [gtk2_dep, threads_dep], include_directories: [xmms_include_dir, xmms_i18n_include_dir], install: true, install_dir: xmms_plugin_dir / 'General')
endif
