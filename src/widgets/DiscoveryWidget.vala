using Gee;
using GLib;
using Xml;

public class DiscoveryWidget: Gtk.Box {
    private GreetingWidget greetingWidget;
    private Gtk.Box widgetLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    private Gtk.Box mainLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    private Budgie.Popover popup;
    private Gtk.Notebook notebook;
    private SettingsService settingsService;
    private Gtk.Button reloadButton;
    private Gtk.Label messageLabel = new Gtk.Label(_("There are no feeds configured"));

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

        notebook = new Gtk.Notebook();
        notebook.scrollable = true;
        notebook.show_border = false;
        notebook.get_style_context().add_class("no-border");
        mainLayout.pack_start(notebook, true, true, 0);
        notebook.hide();

        mainLayout.pack_start(messageLabel, true);
        messageLabel.no_show_all = true;
        messageLabel.get_style_context().add_class("text-secondary");
        messageLabel.hide();

        /* WIDGETS */
        var widgetsLabel = new Gtk.Label("Widgets");
        widgetsLabel.get_style_context().add_class("text-size-small");
        widgetsLabel.set_halign(Gtk.Align.START);
        widgetLayout.pack_start(widgetsLabel, false);

        settingsService = SettingsService.getInstance();
        settingsService.settings_changed.connect(loadViewsFromSettings);

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

        loadViewsFromSettings(null);
    }

    ~DiscoveryWidget() {
        removeWidgets();
    }

    private void removeWidgets() {
        // reset all views
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
    }

    private void loadViewsFromSettings(string? key) {
        removeWidgets();
        messageLabel.hide();
        notebook.hide();

        // read changed settings
        var configuredFeeds = settingsService.get_value("feeds");
        if(configuredFeeds == null) {
            configuredFeeds = new Json.Node(Json.NodeType.ARRAY);
            var feedArray = new Json.Array();
            configuredFeeds.set_array(feedArray);
        }
        reloadButton.set_sensitive(configuredFeeds.get_array().get_length() > 0);

        var feedsLength = configuredFeeds.get_array().get_length ();
        if(feedsLength == 0) {
            messageLabel.show();
        }

        for(var i = 0; i < feedsLength; i++) {
            var item = configuredFeeds.get_array().get_object_element(i);
            var config = new FeedConfigItem();
            config.name = item.get_string_member("name");
            config.uri = item.get_string_member("uri");
            config.uid = item.get_string_member("uid");

            var widget = new FeedView(popup, config);
            widget.get_style_context().add_class ("no-background");
            var label = new Gtk.Label(item.get_string_member("name"));
            label.get_style_context().add_class("text-size-small");
            notebook.append_page(widget, label);
        }

        var weatherNode = settingsService.get_value("weather");
        if(weatherNode == null) {
            weatherNode = new Json.Node(Json.NodeType.OBJECT);
            weatherNode.set_object(new Json.Object());
        }
        Json.Array weatherLocations = null;
        if(!weatherNode.get_object().has_member("locations")) {
            weatherLocations = new Json.Array();
            weatherNode.get_object().set_array_member("locations", weatherLocations);
        }
        weatherLocations = weatherNode.get_object().get_array_member("locations");

        weatherLocations.foreach_element((element, index) => {
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

        widgetLayout.show_all();

        if(notebook.get_n_pages() > 0)
            notebook.show_all();

        resizeChildren();
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

        int secondWidth = ((mainLayoutWidth / 3) - 5) * 2;
        if(notebook.get_n_pages() == 0) {
            messageLabel.set_size_request(secondWidth, -1);
            return;
        }
        notebook.set_size_request(secondWidth, -1);
    }
}