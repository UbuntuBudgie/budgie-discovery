using Config;
using WebKit;

public class DiscoveryPopupContent: Gtk.Box {
    private Gtk.Box navigationBox;
    private int activeTabIndex = 0;

    public DiscoveryPopupContent() {
        Object();
        set_orientation(Gtk.Orientation.HORIZONTAL);
        set_spacing(5);
        get_style_context().add_class("discovery-popup-content");

        navigationBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        navigationBox.get_style_context().add_class("navigation-box");
        pack_start(navigationBox, false, false, 0);

        var stack = new Gtk.Stack();
        stack.get_style_context().add_class("content-stack");
        pack_start(stack, true, true, 0);

        var scrollView = new Gtk.ScrolledWindow(null, null);
        scrollView.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        scrollView.get_style_context().add_class("content-scrollview");
        scrollView.set_shadow_type(Gtk.ShadowType.NONE);

        var webView = new WebKit.WebView();
        webView.get_style_context().add_class("webview");
        webView.load_uri("https://www.chatgpt.com");
        scrollView.add(webView);
        stack.add_titled(scrollView, "webview", "Web View");

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
                print("INDEX CLICKED: %d\n", index);
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
    
}