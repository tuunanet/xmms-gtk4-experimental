libxmms_sources = files(
  'configfile.c',
  'xmmsctrl.c',
  'dirbrowser.c',
  'util.c',
  'formatter.c',
  'titlestring.c',
  'xentry.c',
  'xconvert.c',
  'charset.c',
)

libxmms = shared_library(
  'xmms',
  libxmms_sources,
  dependencies: [glib_dep, gtk2_dep, threads_dep, cc.find_library('m')],
  include_directories: xmms_include_dir,
  version: '4.1.3',
  soversion: '4',
  install: true,
  install_dir: get_option('libdir'),
)

install_headers(
  'configfile.h', 'xmmsctrl.h', 'dirbrowser.h', 'util.h', 'formatter.h',
  'titlestring.h',
  subdir: 'xmms',
)
libxmms_dep = declare_dependency(
  link_with: libxmms,
  dependencies: [glib_dep, gtk2_dep, threads_dep, cc.find_library('m')],
  include_directories: xmms_include_dir,
)
