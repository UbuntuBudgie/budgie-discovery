project_name = meson.project_name()
project_version = meson.project_version()

prefix = get_option('prefix')
bindir = get_option('bindir')
datadir = get_option('datadir')
localedir = get_option('localedir')

conf_data = configuration_data()
conf_data.set_quoted('PACKAGE_NAME', project_name)
conf_data.set_quoted('PACKAGE_VERSION', project_version)
conf_data.set_quoted('GETTEXT_PACKAGE', project_name)
conf_data.set_quoted('DATA_DIR', join_paths(prefix, datadir))
conf_data.set_quoted('LOCALE_DIR', join_paths(prefix, localedir))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

discovery_applet_sources = ['Applet.vala']

discovery_applet_deps = [dependency('gtk+-3.0', version: '>=3.18'),
            dependency('budgie-1.0', version: '>=2')]

discovery_applet_vala_args = ['--target-glib=2.50', config_header]

shared_library('discoveryapplet', discovery_applet_sources,
               dependencies: discovery_applet_deps,
               vala_args: discovery_applet_vala_args,
               install: true,
               install_dir: lib_install_dir)
