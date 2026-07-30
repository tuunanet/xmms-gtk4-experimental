if gtk3_dep.found()
  gtk3_proof = executable(
    'test-gtk3-play-button-proof',
    files('test-gtk3-play-button-proof.c', '../xmms/ui_control.c',
          '../xmms/ui_gtk3_control.c'),
    dependencies: gtk3_dep,
    include_directories: xmms_include_dir,
    install: false,
  )
endif
