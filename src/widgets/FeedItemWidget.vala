public class FeedItemWidget: Card {
    public FeedItemWidget(FeedItem feedItem) {
        base();

        var cardBody = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        cardBody.get_style_context ().add_class ("card-body");
        pack_start(cardBody);

        var image = new FeedItemImageWidget(feedItem);
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
    }
}