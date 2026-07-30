project(
  'xmms',
  'c',
  version: '0.0.1',
  meson_version: '>=1.3.2',
  default_options: ['warning_level=1'],
)

cc = meson.get_compiler('c')
add_project_arguments('-DHAVE_CONFIG_H', language: 'c')
glib_dep = dependency('glib-2.0', version: '>=2.0.0')
gtk2_dep = dependency('gtk+-2.0', version: '>=2.0.0')
threads_dep = dependency('threads')
gtk3_dep = dependency(
  'gtk+-3.0',
  version: '>=3.24',
  required: get_option('gtk3-proof'),
)
zlib_dep = dependency('zlib')
alsa_dep = dependency('alsa')
vorbis_dep = dependency('vorbis', required: get_option('vorbis'))
vorbisfile_dep = dependency('vorbisfile', required: get_option('vorbis'))
ogg_dep = dependency('ogg', required: get_option('vorbis'))
mikmod_dep = dependency('libmikmod', required: get_option('mikmod'))
opengl_dep = dependency('gl', required: get_option('opengl'))

xmms_conf = configuration_data()
xmms_conf.set_quoted('PACKAGE', 'xmms')
xmms_conf.set_quoted('VERSION', meson.project_version())
if cc.has_header('unistd.h')
  xmms_conf.set('HAVE_UNISTD_H', 1)
endif
if cc.has_header('linux/cdrom.h')
  xmms_conf.set('HAVE_LINUX_CDROM_H', 1)
  if host_machine.system() == 'linux'
    xmms_conf.set('XMMS_CDROM_SOLARIS', 1)
  endif
endif
if cc.has_header('linux/joystick.h')
  xmms_conf.set('HAVE_LINUX_JOYSTICK_H', 1)
endif
xmms_conf.set_quoted('DEV_DSP', get_option('dev-dsp'))
xmms_conf.set_quoted('DEV_MIXER', get_option('dev-mixer'))
if get_option('cdda-device') != ''
  xmms_conf.set_quoted('CDDA_DEVICE', get_option('cdda-device'))
endif
if get_option('cdda-dir') != ''
  xmms_conf.set_quoted('CDDA_DIRECTORY', get_option('cdda-dir'))
endif
if not get_option('user-plugin-dir')
  xmms_conf.set('DISABLE_USER_PLUGIN_DIR', 1)
endif
if get_option('simd')
  xmms_conf.set('USE_SIMD', 1)
endif
if get_option('ipv6')
  xmms_conf.set('USE_IPV6', 1)
endif
if get_option('oss').enabled()
  xmms_conf.set('HAVE_OSS', 1)
endif
if gtk3_dep.found()
  xmms_conf.set('GTK3_PROOF_ENABLED', 1)
endif

configure_file(output: 'config.h', configuration: xmms_conf)

xmms_include_dir = include_directories('.')
xmms_i18n_include_dir = include_directories('xmms')
xmms_compile_args = [
  '-DDATA_DIR="' + get_option('prefix') / get_option('datadir') / 'xmms"',
  '-DPLUGIN_DIR="' + get_option('prefix') / get_option('libdir') / 'xmms"',
  '-DBUILD_PLUGIN_DIR="."',
  '-DPLUGINSUBS=0',
  '-DLOCALEDIR="' + get_option('prefix') / get_option('localedir') + '"',
]

subdir('libxmms')
subdir('xmms')
subdir('wmxmms')
subdir('tests')
subdir('Input/mpg123')
subdir('Output/alsa')
subdir('Effect/echo_plugin')
subdir('General/song_change')
subdir('Visualization/sanalyzer')
subdir('Input/wav')
subdir('Input/tonegen')
subdir('Input/cdaudio')
if vorbis_dep.found()
  subdir('Input/vorbis')
endif
if mikmod_dep.found()
  subdir('Input/mikmod')
endif
if not get_option('oss').disabled()
  subdir('Output/OSS')
endif
subdir('Output/disk_writer')
subdir('Effect/voice')
subdir('Effect/stereo_plugin')
subdir('General/ir')
subdir('General/joystick')
subdir('Visualization/blur_scope')
if opengl_dep.found()
  subdir('Visualization/opengl_spectrum')
endif
