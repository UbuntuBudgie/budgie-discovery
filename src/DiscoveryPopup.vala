using Config;

public class DiscoveryPopup {
    private Budgie.Popover popover;
    private GreetingWidget greetingWidget;
    private Gdk.Screen screen;

    public DiscoveryPopup(Gtk.Widget parentWidget) {
        screen = parentWidget.get_screen();
        this.popover = new Budgie.Popover(parentWidget);
        this.popover.get_style_context ().add_class ("discovery-popup");

        var popoverLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popoverLayout.get_style_context ().add_class ("popup-content");
        this.popover.add(popoverLayout);

        var topRow = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);

        greetingWidget = new GreetingWidget();
        topRow.pack_start (greetingWidget.getLabel(), false);
        popoverLayout.pack_start (topRow, false);

        var dummyWidget = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        popoverLayout.pack_start(dummyWidget, true);

        var powerWidget = new PowerWidget();
        popoverLayout.pack_start(powerWidget, false);
        powerWidget.invoke_action.connect(popover.hide);

        var g = screen.get_display().get_primary_monitor().get_geometry();
        var popupWidth = g.width / 3;
        var popupHeight = (g.height / 3) * 2;
        popoverLayout.set_size_request(popupWidth, popupHeight);

        load_style_sheet();
    }

    public Budgie.Popover getPopover() {
        return this.popover;
    }

    private void load_style_sheet() {
        var css = new Gtk.CssProvider();
        try {
            string css_path = PLUGIN_DIR + "/style.css";
            css.load_from_path(css_path);
            Gtk.StyleContext.add_provider_for_screen(
                Gdk.Screen.get_default(),
                css,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        } catch (Error e) {
            warning("Konnte CSS nicht laden: %s", e.message);
        }
    }
}