public class FeedItemWidget: Card {
    private FeedItem itemData;

    public signal void clicked();

    public FeedItemWidget(FeedItem feedItem) {
        base();
        get_style_context().add_class ("feed-item");
        itemData = feedItem;

        var cardBody = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        cardBody.get_style_context ().add_class ("card-body");
        
        var eventBox = new Gtk.EventBox ();
        eventBox.set_visible_window(true);
        eventBox.add_events(Gdk.EventMask.POINTER_MOTION_MASK |
                Gdk.EventMask.ENTER_NOTIFY_MASK |
                Gdk.EventMask.LEAVE_NOTIFY_MASK);

        eventBox.add (cardBody);
        pack_start(eventBox, true);

        var image = new FeedItemImageWidget(feedItem);
        image.set_sensitive (false);
        image.set_size_request(120, 100);
        cardBody.pack_start(image, false);

        Gtk.Label label = new Gtk.Label("");
        label.get_style_context().add_class("card-title");
        label.set_label(feedItem.title);
        label.set_line_wrap(true);
        label.set_line_wrap_mode(Pango.WrapMode.WORD);
        label.set_lines(3);
        label.set_ellipsize(Pango.EllipsizeMode.END);
        label.set_justify(Gtk.Justification.LEFT);
        label.set_halign(Gtk.Align.START);
        label.set_valign(Gtk.Align.START);
        label.hexpand = true;
        label.xalign = 0;
        cardBody.pack_start(label,true);

        eventBox.button_press_event.connect((event) => {
            clicked();
            Idle.add(() => {
                try {
                    AppInfo.launch_default_for_uri (itemData.link, null);
                } catch(Error e) {
                    message ("unable to open url for %s: %s", itemData.link, e.message);
                }
                return false;
            });
            return true;
        });

        eventBox.enter_notify_event.connect((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) return false;
            var display = Gdk.Display.get_default();
            var cursor = new Gdk.Cursor.from_name(display, "pointer");
            eventBox.get_window().set_cursor(cursor);

            get_style_context().add_class("hover");
            return false;
        });
        eventBox.leave_notify_event.connect((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) return false;
            eventBox.get_window().set_cursor(null);

            get_style_context().remove_class("hover");
            return false;
        });
    }
}