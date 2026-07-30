shared_module(
  'esdout',
  files('esd.c', 'mixer.c', 'about.c', 'configure.c', 'audio.c', 'init.c'),
  dependencies: [gtk2_dep, threads_dep, esd_dep],
  include_directories: [xmms_include_dir, xmms_i18n_include_dir],
  install: true,
  install_dir: xmms_plugin_dir / 'Output',
)
