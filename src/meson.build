project_name = meson.project_name()
project_version = meson.project_version()

prefix = get_option('prefix')
datadir = get_option('datadir')
localedir = get_option('localedir')

conf_data = configuration_data()
conf_data.set_quoted('PACKAGE_NAME', project_name)
conf_data.set_quoted('PACKAGE_VERSION', project_version)
conf_data.set_quoted('GETTEXT_PACKAGE', project_name)
conf_data.set_quoted('DATA_DIR', join_paths(prefix, datadir))
conf_data.set_quoted('LOCALE_DIR', join_paths(prefix, localedir))
conf_data.set_quoted('PLUGIN_DIR', lib_install_dir)
conf_data.set_quoted('ICONS_DIR', join_paths(lib_install_dir, 'resources', 'icons'))

config_header = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

discovery_applet_sources = [
    'Applet.vala', 
    'DiscoveryPopup.vala',

    'core/IService.vala',
    'core/WeatherRespository.vala',

    'widgets/ApplicationsWidget.vala',
    'widgets/SettingsWidget.vala',
    'widgets/ChatGptWidget.vala',
    'widgets/DiscoveryPopupContent.vala',
    'widgets/FeedWidget.vala',
    'widgets/GreetingWidget.vala',
    'widgets/PowerWidget.vala',
    'widgets/SettingsWidget.vala',
    'widgets/WeatherForecastDayWidget.vala',
    'widgets/WeatherWidget.vala',

    'services/FeedService.vala', 
    'services/WeatherService.vala'
]

discovery_applet_deps = [
    dependency('gtk+-3.0', version: '>=3.18'),
    dependency('budgie-1.0', version: '>=2'),
    dependency('webkit2gtk-4.1', version: '>=2.48'),
    dependency('json-glib-1.0', version: '>=1.10'),
    dependency('libsoup-3.0', version: '>=2.4'),
    dependency('sqlite3', version: '>=3.46'),
    dependency('libpeas-1.0', version: '>=1.36')
]

discovery_applet_vala_args = [
    '--target-glib=2.50', 
    '--pkg', 'posix', 
    '--pkg', 'webkit2gtk-4.1', 
    config_header
]

subdir('resources')

shared_library('discoveryapplet', discovery_applet_sources,
    dependencies: discovery_applet_deps,
    vala_args: discovery_applet_vala_args,
    c_args: [
        '-Wno-unused-variable',
        '-Wunused-but-set-variable',
        '-Wno-unused-function',
        '-Wno-unused-label'
    ],
    install: true,
    install_dir: lib_install_dir
)
