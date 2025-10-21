
public class SettingsWidget: Gtk.Box {
    private Gtk.Notebook notebook;

    public SettingsWidget() {
        Object(orientation: Gtk.Orientation.VERTICAL, spacing: 10);
        get_style_context().add_class("feed-widget");

        var headerLabel = new Gtk.Label(_("Applet Settings"));
        headerLabel.set_halign(Gtk.Align.START);
        headerLabel.get_style_context().add_class ("header-label");
        pack_start(headerLabel, false);

        notebook = new Gtk.Notebook();
        notebook.margin_top = 10;
        notebook.set_tab_pos(Gtk.PositionType.TOP);
        notebook.set_scrollable(true);
        notebook.show_border = false;
        pack_start(notebook, false);

        var feedSettings = new FeedSettings();
        notebook.append_page(feedSettings, new Gtk.Label(_("Feeds")));

        var widgetSettings = new WidgetSettings();
        notebook.append_page(widgetSettings, new Gtk.Label(_("Weather")));

        this.map.connect(() => {
            //notebook.set_current_page (0);
        });
    }
}