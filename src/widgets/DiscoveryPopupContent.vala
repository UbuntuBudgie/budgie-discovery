using Config;
using WebKit;

public class DiscoveryPopupContent: Gtk.Box {
    private Gtk.Box navigationBox;
    private Gtk.Stack stackView;
    private int activeTabIndex = 0;

    public DiscoveryPopupContent() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("discovery-popup-content");

        navigationBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        navigationBox.get_style_context().add_class("navigation-box");
        pack_start(navigationBox, false, false, 0);

        stackView = new Gtk.Stack();
        stackView.get_style_context().add_class("content-stack");
        stackView.set_transition_type(Gtk.StackTransitionType.CROSSFADE);
        stackView.set_transition_duration(150);
        pack_start(stackView, true, true, 0);

        var feedWidget = new FeedWidget();
        stackView.add_named(feedWidget, "feed");

        var weatherWidget = new WeatherWidget();
        stackView.add_named(weatherWidget, "weather");

        var chatGptWidget = new ChatGptWidget();
        stackView.add_named(chatGptWidget, "chat-gpt");

        var applicationsWidget = new ApplicationsWidget();
        stackView.add_named(applicationsWidget, "applications");

        var settingsWidget = new SettingsWidget();
        stackView.add_named(settingsWidget, "settings");

        // Add tabs to the navigation box
        add_tab(0, ICONS_DIR + "/feed-64.png");
        add_tab(1, ICONS_DIR + "/weather-64.png");
        add_tab(2, ICONS_DIR + "/chatgpt-64.png");
        add_tab(3, ICONS_DIR + "/apps-64.png");
        add_tab(4, ICONS_DIR + "/settings-64.png");
    }

    private void add_tab(int index, string iconName) {
        try {
            var tabButton = new Gtk.Button();
            tabButton.set_size_request(24, 24);
            tabButton.set_halign(Gtk.Align.START);
            tabButton.clicked.connect(() => {
                set_active_index(index);
            });

            var icon = new Gtk.Image.from_gicon(Icon.new_for_string(iconName), Gtk.IconSize.LARGE_TOOLBAR);
            icon.set_pixel_size(36);
            tabButton.set_image(icon);

            navigationBox.pack_start(tabButton, false, false, 5);
        }
        catch (Error e) {
            warning("Failed to create tab button: %s", e.message);
        }
    }

    public void set_active_index(int index) {
        if (index < 0 || index >= stackView.get_children().length()) {
            warning("Invalid index: %d", index);
            return;
        }

        if (activeTabIndex == index) {
            return; // No change needed
        }

        var widget = (Gtk.Widget) stackView.get_children().nth(index).data;
        if(widget == null) {
            warning("Widget at index %d is null", index);
            return;
        }
        if (!widget.get_visible()) {
            warning("Widget at index %d is not visible", index);
            return;
        }
        activeTabIndex = index;
        stackView.set_visible_child( widget );
    }
}