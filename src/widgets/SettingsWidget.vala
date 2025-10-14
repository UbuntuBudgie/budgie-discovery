
public class SettingsWidget: Gtk.Box {
    private Gtk.Notebook notebook;

    public SettingsWidget() {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 5);
        get_style_context().add_class("feed-widget");

        var label = new Gtk.Label("Settings goes here");
        pack_start(label, false);

        notebook = new Gtk.Notebook();
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        notebook.show_border = false;
        pack_start(notebook, false);

        var feedSettings = new FeedSettings();
        notebook.append_page(feedSettings, new Gtk.Label(_("Feeds")));

        var widgetSettings = new WidgetSettings();
        notebook.append_page(widgetSettings, new Gtk.Label(_("Weather")));
    }
}