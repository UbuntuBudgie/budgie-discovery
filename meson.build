project('discovery-applet',
        ['vala', 'c'],
        version: '5.1',
        meson_version: '>=0.50.0',
        license: 'GPL2')

lib_install_dir = join_paths(get_option('prefix'), get_option('libdir'), 'budgie-desktop', 'plugins', meson.project_name())
gettext_dir = join_paths(lib_install_dir, 'resources', 'locale')

add_project_arguments([
    '-DGETTEXT_DIR="@0@"'.format(gettext_dir),
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    '-Wno-unused-variable',
    '-Wunused-but-set-variable',
    '-Wno-unused-function',
    '-Wno-unused-label',
],
    language: 'c',
)

i18n = import('i18n')
i18n.gettext(meson.project_name(),
  install_dir: join_paths(lib_install_dir, 'resources', 'locale')
)

subdir('src')

run_result = run_command('bash', './gen-mo.sh', check: false)
if run_result.returncode() != 0
  error('Script schlug fehl: ' + run_result.stdout())
endif

install_data('src/discovery-applet.plugin',
  install_dir : join_paths(get_option('libdir'), 'budgie-desktop', 'plugins', 'discovery-applet')
)

install_subdir('locale',
  install_dir : join_paths(lib_install_dir, 'resources')
)

install_data('src/style.css', install_dir: lib_install_dir)

run_command('gen-mo.sh', capture:true, check:false)
