using Config;
using GLib;

public class SettingsWindow: Gtk.Window {
    Gtk.Notebook notebook;

    public SettingsWindow() {
        Object();
        set_title(_("Applet Settings"));
        set_type_hint(Gdk.WindowTypeHint.DIALOG);
        gravity = Gdk.Gravity.CENTER;
        set_default_size (640, 480);
        get_style_context().add_class("discovery-settings");

        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        add(layout);

        notebook = new Gtk.Notebook();
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        notebook.show_border = false;
        layout.pack_start(notebook, false);

        var feedSettings = new FeedSettings(this);
        notebook.append_page(feedSettings, new Gtk.Label(_("Feeds")));

        var widgetSettings = new WidgetSettings(this);
        notebook.append_page(widgetSettings, new Gtk.Label(_("Widgets")));

        load_style_sheet();
        show_all ();
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