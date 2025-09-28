public class SettingsWindow: Gtk.Window {
    Gtk.Notebook notebook;
    public SettingsWindow() {
        Object();
        set_title("Settings");
        set_type_hint(Gdk.WindowTypeHint.DIALOG);
        gravity = Gdk.Gravity.CENTER;
        set_default_size (640, 480);

        var layout = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        add(layout);

        notebook = new Gtk.Notebook();
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        notebook.show_border = false;
        layout.pack_start(notebook, false);

        var feedBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        notebook.append_page(feedBox, new Gtk.Label("Feeds"));

        var aboutBox = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
        notebook.append_page(aboutBox, new Gtk.Label("Weather"));
        layout.show_all ();
    }
}