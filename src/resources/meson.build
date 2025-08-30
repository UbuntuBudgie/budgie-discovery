install_subdir('icons',
  install_dir : join_paths(get_option('libdir'), 'budgie-desktop', 'plugins', 'discovery-applet', 'resources')
)

install_data('weather-codes.json',
  install_dir : join_paths(get_option('libdir'), 'budgie-desktop', 'plugins', 'discovery-applet', 'resources')
)

run_command('mkdir',
'-p',
join_paths(get_option('prefix'), get_option('libdir'), 'budgie-desktop', 'plugins', 'discovery-applet', 'resources', 'weather-icons'),
  capture : true,
  check : false
)