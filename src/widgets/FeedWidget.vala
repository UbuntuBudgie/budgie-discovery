using Gee;
using GLib;
using Xml;

public class FeedWidget: Gtk.Box {
    private GreetingWidget greetingWidget;
    private Gtk.Box widgetLayout = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
    private Gtk.Box mainLayout = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
    private Budgie.Popover popup;
    private Gtk.Notebook notebook;

    public FeedWidget(Budgie.Popover popover) {
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

        var reloadButton = new Gtk.Button.from_icon_name("view-refresh-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        greetingWidget.addButton(reloadButton);

        var settingsButton = new Gtk.Button.from_icon_name("preferences-system-symbolic", Gtk.IconSize.SMALL_TOOLBAR);
        greetingWidget.addButton(settingsButton);

        settingsButton.button_press_event.connect((event) => {
            var settingsDialog = new SettingsWindow();
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

        var settingsFile = SettingsUtils.getSettingsFilePath();
        var parser = new Json.Parser();

        var service = SettingsService.getInstance();
        if(service == null) {
            warning("unable to get service");
        }
        service.settingsChanged.connect(() => {
            try {
                while (notebook.get_n_pages() > 0) {
                    var page = notebook.get_nth_page(0);
                    notebook.remove_page(0);
                    if (page != null) {
                        page.destroy();
                    }
                    page = null;
                }

                if(parser.load_from_file(settingsFile)) {
                    var rootNode = parser.get_root();
                    var configuredFeeds = rootNode.get_object().get_array_member("feeds");
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
                } else {
                    warning("UNABLE TO READ SETTINGS");
                }
            } catch(GLib.Error e) {
                warning(e.message);
                // do nothing
            }
            show_all();
        });

        /* WIDGETS */
        var widgetsLabel = new Gtk.Label("Widgets");
        widgetsLabel.get_style_context().add_class("text-size-small");
        widgetsLabel.set_halign(Gtk.Align.START);
        widgetLayout.pack_start(widgetsLabel, false);

        var weatherWidget = new WeatherWidget();
        widgetLayout.pack_start(weatherWidget, false, false, 0);

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