test_include_dirs = [
  xmms_include_dir,
  include_directories('..', '../libxmms', '../xmms'),
]
test_gc_c_args = ['-ffunction-sections', '-fdata-sections']
test_gc_link_args = ['-Wl,--gc-sections']
test_math_dep = cc.find_library('m')
test_dl_dep = cc.find_library('dl')

subdir('test-plugins/Input/fixture/.libs')
subdir('test-plugins/Output/fixture/.libs')
subdir('test-outputplugin-plugins/Output/alsa/.libs')

test_xentry = executable(
  'test-xentry',
  files('test-xentry.c', '../libxmms/xentry.c'),
  dependencies: [glib_dep, gtk2_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('xentry', test_xentry)

test_filebrowser = executable(
  'test-filebrowser',
  files('test-filebrowser.c', '../xmms/util.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('filebrowser', test_filebrowser)

test_font_load = executable(
  'test-font-load',
  files('test-font-load.c', '../xmms/util.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('font-load', test_font_load)

test_popup_position = executable(
  'test-popup-position',
  files('test-popup-position.c', '../xmms/util.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('popup-position', test_popup_position)

test_pbutton_baseline = executable(
  'test-pbutton-baseline',
  files('test-pbutton-baseline.c', '../xmms/pbutton.c', '../xmms/ui_control.c',
        '../xmms/widget.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep, threads_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('pbutton-baseline', test_pbutton_baseline)

test_ui_control = executable(
  'test-ui-control',
  files('test-ui-control.c', '../xmms/ui_control.c'),
  dependencies: glib_dep,
  include_directories: test_include_dirs,
  install: false,
)
test('ui-control', test_ui_control)

test('gnome-c-foundations', find_program('test-gnome-c-foundations.sh'),
  args: [meson.project_source_root(), '--gobject-boundaries'],
  workdir: meson.project_source_root(),
  suite: 'gobject-boundaries',
)

test('gnome-c-dependency-contract',
  find_program('test-gnome-c-foundations.sh'),
  args: [meson.project_source_root(), '--dependency-contract'],
  workdir: meson.project_source_root(),
  suite: 'gobject-boundaries',
)

test('gnome-c-format', find_program('../tools/check-gnome-c-format.sh'),
  args: [meson.project_source_root()],
  workdir: meson.project_source_root(),
  suite: 'gobject-boundaries',
)

test('gnome-c-format-contract', find_program('test-gnome-c-format.sh'),
  args: [meson.project_source_root()],
  workdir: meson.project_source_root(),
  suite: 'gobject-boundaries',
)

if gtk3_dep.found()
  gtk3_proof = executable(
    'test-gtk3-play-button-proof',
    files('test-gtk3-play-button-proof.c', '../xmms/ui_control.c',
          '../xmms/ui_gtk3_control.c'),
    dependencies: gtk3_dep,
    include_directories: test_include_dirs,
    install: false,
  )
  test('gtk3-play-button-proof', gtk3_proof, suite: 'gobject-boundaries')

  gtk3_main_window_shell = executable(
    'test-gtk3-main-window-shell',
    files('test-gtk3-main-window-shell.c', '../xmms/ui_gtk3_shell.c'),
    dependencies: gtk3_dep,
    include_directories: test_include_dirs,
    install: false,
  )
  test('gtk3-main-window-shell', gtk3_main_window_shell,
       suite: 'gobject-boundaries')

  gtk3_main_window_transport = executable(
    'test-gtk3-main-window-transport',
    files('test-gtk3-main-window-transport.c', '../xmms/ui_control.c',
          '../xmms/ui_gtk3_control.c'),
    dependencies: gtk3_dep,
    include_directories: test_include_dirs,
    install: false,
  )
  test('gtk3-main-window-transport', gtk3_main_window_transport,
       suite: 'gobject-boundaries')
endif

test_pluginenum = executable(
  'test-pluginenum',
  files('test-pluginenum.c', '../xmms/pluginenum.c'),
  c_args: test_gc_c_args + [
    '-DBUILD_PLUGIN_DIR="' + meson.current_build_dir() + '/test-plugins"',
    '-DPLUGIN_DIR="/nonexistent"',
    '-DPLUGINSUBS="Output","Input"',
  ],
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep, threads_dep, test_dl_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('pluginenum', test_pluginenum,
     depends: [fixture_input_plugin, fixture_output_plugin])

test_pluginenum_meson_build = executable(
  'test-pluginenum-meson-build',
  files('test-pluginenum-meson-build.c', '../xmms/pluginenum.c'),
  c_args: test_gc_c_args + [
    '-DBUILD_PLUGIN_DIR="' + meson.project_build_root() + '"',
    '-DPLUGIN_DIR="/nonexistent"',
    '-DPLUGINSUBS=0',
  ],
  link_args: test_gc_link_args + ['-Wl,--export-dynamic'],
  dependencies: [glib_dep, gtk2_dep, threads_dep, test_dl_dep, libxmms_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('pluginenum-meson-build', test_pluginenum_meson_build,
     depends: [mpg123_module, alsa_module],
     env: [
       'HOME=' + meson.current_build_dir() / 'pluginenum-meson-build-home',
       'LD_LIBRARY_PATH=' + meson.project_build_root() / 'libxmms',
     ])

test_outputplugin = executable(
  'test-outputplugin',
  files('test-outputplugin.c', '../xmms/outputplugin.c'),
  c_args: [
    '-DBUILD_PLUGIN_DIR="' + meson.current_build_dir() + '/test-outputplugin-plugins"',
    '-DPLUGIN_DIR="/nonexistent"',
  ],
  dependencies: glib_dep,
  include_directories: test_include_dirs,
  install: false,
)
test('outputplugin', test_outputplugin, depends: alsa_output_fixture)

test_outputplugin_meson_build = executable(
  'test-outputplugin-meson-build',
  files('test-outputplugin-meson-build.c', '../xmms/outputplugin.c'),
  c_args: [
    '-DBUILD_PLUGIN_DIR="' + meson.project_build_root() + '"',
    '-DPLUGIN_DIR="/nonexistent"',
  ],
  dependencies: glib_dep,
  include_directories: test_include_dirs,
  install: false,
)
test('outputplugin-meson-build', test_outputplugin_meson_build,
     depends: alsa_module)

test_alsa_pcm_state = executable(
  'test-alsa-pcm-state',
  files('test-alsa-pcm-state.c', '../Output/alsa/pcm-state.c'),
  dependencies: glib_dep,
  include_directories: test_include_dirs,
  install: false,
)
test('alsa-pcm-state', test_alsa_pcm_state)

test_alsa_volume = executable(
  'test-alsa-volume',
  files('test-alsa-volume.c', '../Output/alsa/audio.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep, threads_dep, alsa_dep, test_math_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('alsa-volume', test_alsa_volume)

test_mpg123_file_duration = executable(
  'test-mpg123-file-duration',
  files('test-mpg123-file-duration.c', '../Input/mpg123/mpg123.c',
        '../Input/mpg123/common.c', '../Input/mpg123/dxhead.c'),
  c_args: test_gc_c_args,
  link_args: test_gc_link_args,
  dependencies: [glib_dep, gtk2_dep, threads_dep, test_math_dep],
  include_directories: test_include_dirs,
  install: false,
)
test('mpg123-file-duration', test_mpg123_file_duration)

test_mpg123_stream_position = executable(
  'test-mpg123-stream-position',
  files('test-mpg123-stream-position.c', '../Input/mpg123/stream-position.c'),
  dependencies: glib_dep,
  include_directories: test_include_dirs,
  install: false,
)
test('mpg123-stream-position', test_mpg123_stream_position)

test('no-autotools-artifacts', find_program('verify-no-autotools-artifacts.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('no-autotools-artifacts-source', find_program('test-no-autotools-artifacts.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('c-lint', find_program('test-c-lint.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root(),
     timeout: 120)
test('meson-migration-contracts', find_program('test-meson-migration-contracts.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('preflight', find_program('test-preflight.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('meson-documentation-contract',
     find_program('test-meson-documentation-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('meson-configure-contract', find_program('test-meson-configure-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root(),
     is_parallel: false)
test('mikmod-build-contract', find_program('test-mikmod-build-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('build-parity-contract', find_program('test-build-parity-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root(),
     timeout: 120, is_parallel: false)
test('package-recipes', find_program('test-package-recipes.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('debian-package-contract', find_program('test-package-artifact-contracts.sh'),
     args: [meson.project_source_root(),
            meson.project_source_root() / 'tests/verify-debian-package-contract.sh'],
     workdir: meson.project_source_root())
test('release-artifacts', find_program('test-package-artifact-contracts.sh'),
     args: [meson.project_source_root(),
            meson.project_source_root() / 'tools/verify-release-artifacts.sh'],
     workdir: meson.project_source_root())
test('plugin-linkage', find_program('test-plugin-linkage.sh'),
     args: [meson.project_build_root()], depends: mpg123_module)
test('meson-output-contract', find_program('verify-meson-output-contract.sh'),
     args: [meson.project_build_root()], depends: meson_output_contract_targets)
test('release-tools', find_program('test-release-tools.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('solo-git-workflow', find_program('test-solo-git-workflow.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('autonomous-epic-workflow', find_program('test-autonomous-epic-workflow.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
test('meson-test-suite-contract', find_program('test-meson-test-suite-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root(),
     is_parallel: false)
test('meson-dist-contract', find_program('test-meson-dist-contract.sh'),
     args: [meson.project_source_root()], workdir: meson.project_source_root())
