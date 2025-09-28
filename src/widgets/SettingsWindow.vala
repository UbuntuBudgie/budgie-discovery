public class SettingsWindow: Gtk.Window {
    public SettingsWindow() {
        Object();
        set_title("Settings");
        set_type_hint(Gdk.WindowTypeHint.DIALOG);
        gravity = Gdk.Gravity.CENTER;

        resize (640, 480);

        var notebook = new Gtk.Notebook();
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        add(notebook);

        /*
        var generalBox = new GeneralSettingsWidget();
        notebook.append_page(generalBox, new Gtk.Label("General"));

        var feedBox = new FeedSettingsWidget();
        notebook.append_page(feedBox, new Gtk.Label("Feeds"));

        var aboutBox = new AboutWidget();
        notebook.append_page(aboutBox, new Gtk.Label("About"));
        */
        show_all();
    }
}