public class FeedWidget: Gtk.Box {
    private Gtk.Label feedLabel;

    public FeedWidget() {
        Object();
        set_orientation(Gtk.Orientation.VERTICAL);
        set_spacing(5);
        get_style_context().add_class("feed-widget");

        feedLabel = new Gtk.Label("Feed content will be displayed here.");
        feedLabel.set_halign(Gtk.Align.CENTER);
        feedLabel.set_valign(Gtk.Align.START);
        pack_start(feedLabel, true, true, 0);
    }

    public void update_feed(string feedContent) {
        feedLabel.set_text(feedContent);
    }
}