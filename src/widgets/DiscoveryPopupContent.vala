using Config;

public class DiscoveryPopupContent: Gtk.Box {
    private Gtk.Box navigationBox;
    private Gtk.Stack stackView;
    private int activeTabIndex = 0;
    private Budgie.Popover popover;

    public DiscoveryPopupContent(Budgie.Popover? parent) {
        Object();
        popover = parent;
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        hexpand = false;
        get_style_context().add_class("discovery-popup-content");

        navigationBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        navigationBox.get_style_context().add_class("navigation-box");
        pack_start(navigationBox, false, false, 0);

        stackView = new Gtk.Stack();
        stackView.get_style_context().add_class("content-stack");
        stackView.set_transition_type(Gtk.StackTransitionType.NONE);
        stackView.set_transition_duration(150);
        stackView.hexpand = false;
        pack_start(stackView, true, true, 0);

        var feedWidget = new DiscoveryWidget(parent);
        feedWidget.set_name("feed");
        stackView.add_named(feedWidget, "feed");

        var bookmarksWidget = new BookmarksWidget(parent);
        bookmarksWidget.set_name("bookmarks");
        stackView.add_named(bookmarksWidget, "bookmarks");

        var applicationsWidget = new ApplicationsWidget(parent);
        applicationsWidget.set_name("applications");
        stackView.add_named(applicationsWidget, "applications");

        var settingsWidget = new SettingsWidget();
        settingsWidget.set_name("settings-widget");
        stackView.add_named(settingsWidget, "settings");

        // Add tabs to the navigation box
        add_tab(0, "feed", "accessories-dictionary-symbolic");
        add_tab(1, "bookmarks", "user-bookmarks-symbolic");
        add_tab(2, "applications", "system-software-install-symbolic");
        add_tab(3, "settings", "preferences-system-symbolic");

        // TODO separate code for that
        var buttonBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        var menuButton = new Gtk.MenuButton();
        menuButton.set_image(new Gtk.Image.from_icon_name("system-shutdown-symbolic", Gtk.IconSize.SMALL_TOOLBAR));
        //menuButton.get_style_context().add_class("flat");
        menuButton.valign = Gtk.Align.END;
        
        buttonBox.pack_start(menuButton, false);
        navigationBox.pack_start(buttonBox, true);

        var menu = new PowerMenu(parent);

        menuButton.set_popup (menu);
        menu.show_all();
    }

    ~DiscoveryPopupContent() {
        stackView.foreach(child => {
            stackView.remove(child);
            child.destroy();
            child = null;
        });
    }

    public override void get_preferred_width(out int minimum_width, out int natural_width) {
        int w = 0;
        stackView.get_preferred_width(out w, out w);

        minimum_width = w;
        natural_width = w;
    }

    private void add_tab(int index, string name, string iconName) {
        var tabButton = new Gtk.Button();
        tabButton.set_size_request(24, 24);
        tabButton.margin_end = 10;
        tabButton.margin_bottom = 5;
        tabButton.set_halign(Gtk.Align.START);
        tabButton.set_name(name);
        tabButton.clicked.connect(() => {
            set_active_index(index);
        });

        var icon = new Gtk.Image.from_icon_name(iconName, Gtk.IconSize.SMALL_TOOLBAR);
        tabButton.set_image(icon);
        //tabButton.get_style_context().add_class("flat");
        navigationBox.pack_start(tabButton, false, false, 0);
    }

    public void set_active_index(int index) {
        if (index < 0 || index >= stackView.get_children().length()) {
            warning("Invalid index: %d", index);
            return;
        }

        if (activeTabIndex == index) {
            return; // No change needed
        }

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
    }
}