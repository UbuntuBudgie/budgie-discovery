public class FeedItemWidget: Card {
    public FeedItemWidget(FeedItem feedItem) {
        base();

        var cardBody = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        cardBody.get_style_context ().add_class ("card-body");
        pack_start(cardBody);

        var image = new FeedItemImageWidget(feedItem.image);
        image.set_size_request(120, 100);
        cardBody.pack_start(image, false);

        /*
        var publisherLabel = new Gtk.Label("");
        publisherLabel.get_style_context().add_class("text-size-small");
        publisherLabel.get_style_context().add_class("text-secondary");
        publisherLabel.set_label (feedItem.publisher);
        publisherLabel.set_line_wrap(true);
        publisherLabel.set_line_wrap_mode(Pango.WrapMode.WORD);
        publisherLabel.set_lines(3);
        publisherLabel.set_ellipsize(Pango.EllipsizeMode.END);
        publisherLabel.set_justify(Gtk.Justification.LEFT);
        publisherLabel.set_halign(Gtk.Align.START);
        publisherLabel.set_valign(Gtk.Align.START);
        cardBody.pack_start(publisherLabel, false);
        */

        message(feedItem.image);

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