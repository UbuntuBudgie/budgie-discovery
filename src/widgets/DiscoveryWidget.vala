using Gee;
using GLib;
using Xml;

public class DiscoveryWidget: Gtk.Box {
    private GreetingWidget greetingWidget;
    private Gtk.Box widgetLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    private Gtk.Box mainLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    private Budgie.Popover popup;
    private Gtk.Notebook notebook;
    private SettingsWindow settingsDialog;
    private SettingsService settingsService;
    private Gtk.Button reloadButton;

    public DiscoveryWidget(Budgie.Popover popover) {
        Object();
        popup = popover;
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(0);
        get_style_context().add_class("feed-widget");

        greetingWidget = new GreetingWidget();
        pack_start (greetingWidget, false);

        pack_start(mainLayout, true);

        mainLayout.hexpand = false;
        mainLayout.pack_start(widgetLayout, true, true);

        reloadButton = new Gtk.Button.from_icon_name("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        reloadButton.set_sensitive(false);
        greetingWidget.addButton(reloadButton);

        var settingsButton = new Gtk.Button.from_icon_name("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        greetingWidget.addButton(settingsButton);

        settingsButton.button_press_event.connect((event) => {
            if(settingsDialog != null) {
                settingsDialog.destroy();
                settingsDialog = null;
            }
            settingsDialog = new SettingsWindow();
            settingsDialog.show_all();
            settingsDialog.present();
            popover.hide();
            return true;
        });

        notebook = new Gtk.Notebook();
        notebook.scrollable = true;
        notebook.show_border = false;
        notebook.get_style_context().add_class("no-border");
        mainLayout.pack_start(notebook, true, true, 0);

        /* WIDGETS */
        var widgetsLabel = new Gtk.Label("Widgets");
        widgetsLabel.get_style_context().add_class("text-size-small");
        widgetsLabel.set_halign(Gtk.Align.START);
        widgetLayout.pack_start(widgetsLabel, false);

        SettingsUtils.checkSettingsFile();
        var settingsFile = SettingsUtils.getSettingsFilePath();
        var parser = new Json.Parser();

        settingsService = SettingsService.getInstance();
        settingsService.settingsChanged.connect(() => {
            try {
                while (notebook.get_n_pages() > 0) {
                    var page = notebook.get_nth_page(0);
                    notebook.remove_page(0);
                    if (page != null) {
                        page.destroy();
                    }
                    page = null;
                }

                widgetLayout.get_children().foreach((child) => {
                    if((child is WeatherWidget) == false) return;
                    widgetLayout.remove(child);
                    child.destroy();
                    child = null;
                });

                if(parser.load_from_file(settingsFile)) {
                    var rootNode = parser.get_root().get_object();
                    var configuredFeeds = rootNode.get_array_member("feeds");
                    reloadButton.set_sensitive(configuredFeeds.get_length() > 0);

                    for(var i = 0; i < configuredFeeds.get_length (); i++) {
                        var item = configuredFeeds.get_object_element(i);
                        var config = new FeedConfigItem();
                        config.name = item.get_string_member("name");
                        config.uri = item.get_string_member("uri");
                        config.uid = item.get_string_member("uid");

                        var widget = new FeedView(popover, config);
                        widget.get_style_context().add_class ("no-background");
                        var label = new Gtk.Label(item.get_string_member("name"));
                        label.get_style_context().add_class("text-size-small");
                        notebook.append_page(widget, label);
                    }

                    if(rootNode.has_member("weather") && rootNode.get_object_member("weather").has_member("locations")) {
                        var configuredLocations = rootNode.get_object_member("weather").get_array_member("locations");
                        configuredLocations.foreach_element((element, index) => {
                            var locationData = element.get_object_element(index);
                            var name = locationData.get_string_member("name");
                            var country = locationData.get_string_member("country");
                            var latitude = locationData.get_double_member("latitude");
                            var longitude = locationData.get_double_member("longitude");
                            var admin1 = locationData.has_member("admin1") ? locationData.get_string_member("admin1") : null;
                            var admin2 = locationData.has_member("admin2") ? locationData.get_string_member("admin2") : null;
                            var admin3 = locationData.has_member("admin3") ? locationData.get_string_member("admin3") : null;
                            var admin4 = locationData.has_member("admin4") ? locationData.get_string_member("admin4") : null;

                            var location = new LocationItem();
                            location.name = name;
                            location.country = country;
                            location.admin1 = admin1;
                            location.admin2 = admin2;
                            location.admin3 = admin3;
                            location.admin4 = admin4;
                            location.latitude = latitude;
                            location.longitude = longitude;

                            var widget = new WeatherWidget(location);
                            widgetLayout.pack_start(widget, false);
                        });
                    }
                } else {
                    warning("UNABLE TO READ SETTINGS");
                }
            } catch(GLib.Error e) {
                warning(e.message);
                // do nothing
            }
            show_all();
            resizeChildren();
        });

        this.map.connect(() => {
            notebook.set_current_page(0);
        });

        size_allocate.connect((allocation) => {
            resizeChildren();
        });

        reloadButton.clicked.connect(() => {
            Idle.add(() => {
                var index = notebook.get_current_page();
                var page = (FeedView) notebook.get_nth_page(index);
                page.reload();
                return false;
            });
        });
    }

    ~DiscoveryWidget() {
        for(var i = 0; i < notebook.get_n_pages(); i++) {
            var page = notebook.get_nth_page(i);
            notebook.remove(page);
            page.destroy();
            page = null;
        }

        widgetLayout.foreach(child => {
            widgetLayout.remove(child);
            child.destroy();
            child = null;
        });
    }

    private void resizeChildren() {
        int mainLayoutWidth = get_allocated_width();
        if(mainLayoutWidth <= 1) return;

        int columnWidth = (mainLayoutWidth / 3) - 15;
        widgetLayout.set_size_request(columnWidth, -1);
        
        int index = 0;
        widgetLayout.get_children().foreach(child => {
            if(index == 0) {
                index++;
                return;
            }

            child.set_size_request(columnWidth, columnWidth);
        });

        int notebookWidth = ((mainLayoutWidth / 3) - 5) * 2;
        notebook.set_size_request(notebookWidth, -1);
    }
}