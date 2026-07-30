mpg123_sources = files(
  'mpg123.c', 'common.c', 'stream-position.c', 'tabinit.c', 'configure.c',
  'fileinfo.c', 'decode_2to1.c', 'decode_4to1.c', 'layer1.c', 'layer2.c',
  'layer3.c', 'equalizer.c', 'http.c', 'dxhead.c', 'id3.c', 'id3_frame.c',
  'id3_frame_content.c', 'id3_frame_text.c', 'id3_frame_url.c', 'id3_tag.c',
  'unicode.c', 'decode.c', 'dct64.c',
)

mpg123_module = shared_module(
  'mpg123',
  mpg123_sources,
  dependencies: [glib_dep, gtk2_dep, threads_dep, zlib_dep, libxmms_dep,
                 cc.find_library('m')],
  include_directories: [xmms_include_dir, xmms_i18n_include_dir],
  install: false,
)
