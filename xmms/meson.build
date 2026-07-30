configure_file(input: 'i18n.h.in', output: 'i18n.h', copy: true)

xmms_sources = files(
  'bmp.c', 'skin.c', 'util.c', 'output.c', 'fft.c', 'input.c', 'effect.c',
  'general.c', 'visualization.c', 'fullscreen.c', 'pluginenum.c',
  'outputplugin.c', 'playlist.c', 'controlsocket.c', 'dock.c', 'widget.c',
  'ui_control.c', 'sbutton.c', 'pbutton.c', 'tbutton.c', 'textbox.c',
  'menurow.c', 'hslider.c', 'monostereo.c', 'vis.c', 'svis.c', 'number.c',
  'playstatus.c', 'playlist_list.c', 'playlist_slider.c', 'playlist_popup.c',
  'eq_graph.c', 'eq_slider.c', 'main.c', 'skinwin.c', 'prefswin.c',
  'playlistwin.c', 'equalizer.c', 'hints.c', 'about.c', 'sm.c', 'getopt.c',
  'getopt1.c', 'urldecode.c', 'mkdtemp.c', 'glib_thread_compat.c',
)

x11_dep = dependency('x11')
sm_dep = cc.find_library('SM', required: false)
ice_dep = cc.find_library('ICE', required: false)
xf86vm_dep = cc.find_library('Xxf86vm', required: false)

xmms = executable(
  'xmms',
  xmms_sources,
  dependencies: [glib_dep, gtk2_dep, threads_dep, libxmms_dep, x11_dep,
                 sm_dep, ice_dep, xf86vm_dep],
  include_directories: [xmms_include_dir, include_directories('.')],
  c_args: xmms_compile_args,
  export_dynamic: true,
  install: true,
)

install_headers('plugin.h', 'fullscreen.h', subdir: 'xmms')
