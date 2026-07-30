shared_module(
  'ALSA',
  files('alsa.c', 'about.c', 'audio.c', 'pcm-state.c', 'configure.c',
        'init.c'),
  dependencies: [glib_dep, gtk2_dep, threads_dep, alsa_dep],
  include_directories: [xmms_include_dir, xmms_i18n_include_dir],
  install: false,
)
