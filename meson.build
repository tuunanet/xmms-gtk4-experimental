project(
  'xmms',
  'c',
  version: '0.0.1',
  meson_version: '>=1.3.2',
  default_options: ['warning_level=1'],
)

cc = meson.get_compiler('c')
glib_dep = dependency('glib-2.0', version: '>=2.0.0')
gtk2_dep = dependency('gtk+-2.0', version: '>=2.0.0')
threads_dep = dependency('threads')
gtk3_dep = dependency(
  'gtk+-3.0',
  version: '>=3.24',
  required: get_option('gtk3-proof'),
)

xmms_conf = configuration_data()
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
