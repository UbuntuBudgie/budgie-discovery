using Config;

public class DiscoveryPopup: Budgie.Popover {
    private DiscoveryPopupContent popupContentWidget;
    private Gtk.Box popoverLayout;
    //private Gdk.Screen screen;

    public DiscoveryPopup(Gtk.Widget parentWidget) {
        Object(relative_to: parentWidget);
        var g = screen.get_display().get_primary_monitor().get_geometry();
        int popupWidth = (g.width / 3) + 150;
        int popupHeight = ((g.height / 3) * 2) + 100;

        //popover = new Budgie.Popover(parentWidget);
        get_style_context ().add_class ("discovery-popup");
        set_halign(Gtk.Align.START);
        set_size_request(popupWidth, popupHeight);
        set_hexpand(false);
        set_vexpand(false);

        popoverLayout = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        popoverLayout.get_style_context ().add_class ("popup-content");
        popoverLayout.set_hexpand(false);
        popoverLayout.set_halign(Gtk.Align.START);
        popoverLayout.set_size_request(popupWidth, popupHeight);
        add(popoverLayout);

        
        popupContentWidget = new DiscoveryPopupContent(this);
        popoverLayout.pack_start(popupContentWidget, true, true);

        load_style_sheet();
    }

    ~DiscoveryPopup() {
        popoverLayout.remove(popupContentWidget);
        popupContentWidget.destroy();
        popupContentWidget = null;
    }

    public void set_active_index(int index) {
        popupContentWidget.set_active_index(index);
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