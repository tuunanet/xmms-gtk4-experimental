project(
  'xmms',
  'c',
  version: '0.0.5',
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
esd_dep = dependency('esound', required: get_option('esd'))

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
if esd_dep.found() and cc.has_function('esd_get_latency', dependencies: esd_dep)
  xmms_conf.set('HAVE_ESD_GET_LATENCY', 1)
endif
if gtk3_dep.found()
  xmms_conf.set('GTK3_PROOF_ENABLED', 1)
endif

configure_file(output: 'config.h', configuration: xmms_conf)

xmms_include_dir = include_directories('.')
xmms_i18n_include_dir = include_directories('xmms')
xmms_plugin_dir = get_option('libdir') / 'xmms'
xmms_compile_args = [
  '-DDATA_DIR="' + get_option('prefix') / get_option('datadir') / 'xmms"',
  '-DPLUGIN_DIR="' + get_option('prefix') / get_option('libdir') / 'xmms"',
  '-DBUILD_PLUGIN_DIR="' + meson.project_build_root() + '"',
  '-DPLUGINSUBS=0',
  '-DLOCALEDIR="' + get_option('prefix') / get_option('localedir') + '"',
]

xmms_config = configuration_data()
xmms_config.set('prefix', get_option('prefix'))
xmms_config.set('exec_prefix', get_option('prefix'))
xmms_config.set('datarootdir', get_option('prefix') / get_option('datadir'))
xmms_config.set('datadir', get_option('prefix') / get_option('datadir'))
xmms_config.set('PACKAGE', 'xmms')
xmms_config.set('VERSION', meson.project_version())
xmms_config.set('includedir', get_option('prefix') / get_option('includedir'))
xmms_config.set('libdir', get_option('prefix') / get_option('libdir'))
xmms_config.set('GTK_LIBS', '')
xmms_config.set('GTK_CFLAGS', '')
xmms_config.set('plugindir', get_option('prefix') / xmms_plugin_dir)
xmms_config.set('VISUALIZATION_PLUGIN_DIR', 'Visualization')
xmms_config.set('INPUT_PLUGIN_DIR', 'Input')
xmms_config.set('OUTPUT_PLUGIN_DIR', 'Output')
xmms_config.set('EFFECT_PLUGIN_DIR', 'Effect')
xmms_config.set('GENERAL_PLUGIN_DIR', 'General')
configure_file(input: 'xmms-config.meson.in', output: 'xmms-config', configuration: xmms_config, install: true, install_dir: get_option('bindir'), install_mode: 'rwxr-xr-x')
configure_file(input: 'xmms.1.in', output: 'xmms.1', configuration: xmms_config, install: true, install_dir: get_option('mandir') / 'man1')
configure_file(input: 'wmxmms.1.in', output: 'wmxmms.1', configuration: xmms_config, install: true, install_dir: get_option('mandir') / 'man1')

foreach locale : ['af', 'az', 'be', 'bg', 'bs', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'en', 'en_GB', 'eo', 'es', 'et', 'eu', 'fi', 'fr', 'ga', 'gl', 'hr', 'hu', 'id', 'it', 'ja', 'ka', 'ko', 'lt', 'lv', 'mk', 'ms', 'nn', 'nl', 'no', 'pl', 'pt', 'pt_BR', 'ro', 'ru', 'sk', 'sl', 'sq', 'sr', 'sr@Latn', 'sv', 'tg', 'th', 'tr', 'uk', 'uz', 'vi', 'wa', 'zh_CN', 'zh_TW']
  install_data('po/' + locale + '.gmo', install_dir: get_option('localedir') / locale / 'LC_MESSAGES', rename: 'xmms.mo')
endforeach
subdir('libxmms')
subdir('xmms')
subdir('wmxmms')
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
if esd_dep.found()
  subdir('Output/esd')
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

meson_output_contract_targets = [
  libxmms,
  xmms,
  wmxmms,
  mpg123_module,
  wav_module,
  tonegen_module,
  alsa_module,
  disk_writer_module,
  echo_module,
  voice_module,
  stereo_module,
  song_change_module,
  ir_module,
  sanalyzer_module,
  blur_scope_module,
]
if cc.has_header('linux/cdrom.h')
  meson_output_contract_targets += cdaudio_module
endif
if vorbis_dep.found()
  meson_output_contract_targets += vorbis_module
endif
if mikmod_dep.found()
  meson_output_contract_targets += mikmod_module
endif
if not get_option('oss').disabled()
  meson_output_contract_targets += oss_module
endif
if esd_dep.found()
  meson_output_contract_targets += esd_module
endif
if cc.has_header('linux/joystick.h')
  meson_output_contract_targets += joystick_module
endif
if opengl_dep.found()
  meson_output_contract_targets += opengl_spectrum_module
endif

subdir('tests')
