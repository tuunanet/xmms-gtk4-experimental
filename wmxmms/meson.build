wmxmms = executable(
  'wmxmms',
  files('getopt.c', 'getopt1.c', 'wmxmms.c'),
  dependencies: [glib_dep, gtk2_dep, threads_dep, libxmms_dep,
                 dependency('x11')],
  include_directories: xmms_include_dir,
  c_args: xmms_compile_args,
  install: true,
)

install_data('wmxmms.xpm', install_dir: get_option('datadir') / 'xmms')
