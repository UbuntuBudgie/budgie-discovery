using Config;
using WebKit;

public class DiscoveryPopupContent: Gtk.Box {
    private Gtk.Box navigationBox;
    private Gtk.Stack stackView;
    private int activeTabIndex = 0;

    public DiscoveryPopupContent(Budgie.Popover? parent = null) {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("discovery-popup-content");
        set_hexpand(false);
        set_vexpand(false);

        navigationBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        navigationBox.get_style_context().add_class("navigation-box");
        pack_start(navigationBox, false, false, 0);

        stackView = new Gtk.Stack();
        stackView.get_style_context().add_class("content-stack");
        stackView.set_transition_type(Gtk.StackTransitionType.NONE);
        stackView.set_transition_duration(0);
        pack_start(stackView, true, true, 0);

        var feedWidget = new FeedWidget();
        feedWidget.set_name("feed");
        stackView.add_named(feedWidget, "feed");

        var chatGptWidget = new ChatGptWidget();
        chatGptWidget.set_name("chat-gpt");
        stackView.add_named(chatGptWidget, "chat-gpt");

        var applicationsWidget = new ApplicationsWidget();
        applicationsWidget.set_name("applications");
        stackView.add_named(applicationsWidget, "applications");

        var settingsWidget = new SettingsWidget();
        settingsWidget.set_name("settings");
        stackView.add_named(settingsWidget, "settings");

        // Add tabs to the navigation box
        add_tab(0, "feed", ICONS_DIR + "/feed-64.png");
        add_tab(1, "chat-gpt", ICONS_DIR + "/chatgpt-64.png");
        add_tab(2, "applications", ICONS_DIR + "/apps-64.png");
        add_tab(3, "settings", ICONS_DIR + "/settings-64.png");

        // TODO separate code for that
        var buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        var menuButton = new Gtk.MenuButton();
        menuButton.set_image(new Gtk.Image.from_icon_name("system-shutdown-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        menuButton.valign = Gtk.Align.END;
        
        buttonBox.pack_start(menuButton, false);
        navigationBox.pack_start(buttonBox, true);

        var menu = new Gtk.Menu ();
        var item1 = new Gtk.MenuItem.with_label ("Lock Screen");
        item1.activate.connect (() => {
            print ("Option 1 gewählt\n");
            parent.hide();
        });
        menu.append (item1);

        var item2 = new Gtk.MenuItem.with_label ("Sleep");
        item2.activate.connect (() => {
            print ("Option 2 gewählt\n");
            parent.hide();
        });
        menu.append (item2);

        var item3 = new Gtk.MenuItem.with_label ("Shut down");
        item3.activate.connect (() => {
            print ("Option 3 gewählt\n");
            parent.hide();
        });
        menu.append (item3);

        var item4 = new Gtk.MenuItem.with_label ("Restart");
        item4.activate.connect (() => {
            print ("Option 4 gewählt\n");
            parent.hide();
        });
        menu.append (item4);

        menuButton.set_popup (menu);
        menu.show_all();
    }

    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        int w = 0;
        stackView.get_preferred_width(out w, out w);

        minimum_width = w;
        natural_width = w;
    }

    private void add_tab(int index, string name, string iconName) {
        try {
            var tabButton = new Gtk.Button();
            tabButton.set_size_request(24, 24);
            tabButton.set_halign(Gtk.Align.START);
            tabButton.set_name(name);
            tabButton.clicked.connect(() => {
                set_active_index(index);
            });

            var icon = new Gtk.Image.from_gicon(Icon.new_for_string(iconName), Gtk.IconSize.LARGE_TOOLBAR);
            icon.set_pixel_size(36);
            tabButton.set_image(icon);

            if(index == 0) {
                // Highlight the first tab as active
                tabButton.set_state_flags(Gtk.StateFlags.ACTIVE, true);
                tabButton.get_style_context().add_class("active");
            } else {
                tabButton.set_state_flags(Gtk.StateFlags.NORMAL, true);
            }

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

        // reset button states
        navigationBox.get_children().foreach((child) => {
            if (child is Gtk.Button) {
                var button = (Gtk.Button) child;
                button.set_state_flags(Gtk.StateFlags.NORMAL, true);
                button.get_style_context().remove_class("active");
            } else {
                warning("Child is not a Gtk.Button: %s", child.get_name());
            }
        });

        var widget = (Gtk.Widget) stackView.get_children().nth_data(index);
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

        navigationBox.get_children().foreach((child) => {
            if (child is Gtk.Button) {
                var button = (Gtk.Button) child;
                if (child.get_name() == widget.get_name()) {
                    // Highlight the active tab button
                    button.set_state_flags(Gtk.StateFlags.ACTIVE|Gtk.StateFlags.FOCUSED|Gtk.StateFlags.SELECTED, true);
                    button.get_style_context().add_class("active");
                } else {
                    button.set_state_flags(Gtk.StateFlags.NORMAL, true);
                    button.get_style_context().remove_class("active");
                }
            } else {
                warning("Child is not a Gtk.Button: %s", child.get_name());
            }
        });
    }
}