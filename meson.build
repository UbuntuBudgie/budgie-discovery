project('discovery-applet',
        ['vala', 'c'],
        version: '5.1',
        meson_version: '>=0.40.0',
        license: 'GPL2')

add_project_arguments([
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    '-Wno-unused-variable',
    '-Wunused-but-set-variable',
    '-Wno-unused-function',
    '-Wno-unused-label'
],
    language: 'c',
)

i18n = import('i18n')

lib_install_dir = join_paths(get_option('prefix'), get_option(
    'libdir'), 'budgie-desktop', 'plugins', meson.project_name())

subdir('src')

install_data('src/discovery-applet.plugin',
  install_dir : join_paths(get_option('libdir'), 'budgie-desktop', 'plugins', 'discovery-applet')
)

install_data('src/style.css', install_dir: lib_install_dir)
