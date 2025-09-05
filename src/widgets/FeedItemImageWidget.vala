using Gdk;
using Soup;

public class FeedItemImageWidget : Gtk.DrawingArea {
    private Soup.Session session = new Soup.Session ();
    private Gdk.Pixbuf? pixbuf = null;
    private string imageUrl;
    private static GLib.Regex regex;

    public FeedItemImageWidget (FeedItem feedItem) {
        get_style_context ().add_class ("card-image");

        if(regex == null) {
            try {
                regex = new GLib.Regex (
                    "<meta[^>]+property=['\"]og:image['\"][^>]+content=['\"]([^'\"]+)['\"]",
                    GLib.RegexCompileFlags.CASELESS | GLib.RegexCompileFlags.DOTALL,
                    0
                );
            } catch(Error e) {}
        }

        loadFeedSource(feedItem.link);
    }

    private void loadFeedSource(string url) {
        try {
            var msg = new Message ("GET", url);
            var bytes = session.send_and_read (msg, null);
            string html = (string) bytes.get_data ();

            MatchInfo info;
            if (regex.match (html, 0, out info)) {
                imageUrl = info.fetch (1);
                loadImage ();
            }
        } catch(Error e) {
            // not handled
        }
    }

    private void loadImage () {
        if (!(imageUrl.has_prefix ("http://") || imageUrl.has_prefix ("https://")))
            return;

        var msg = new Soup.Message ("GET", imageUrl);

        session.send_and_read_async.begin (msg, GLib.Priority.DEFAULT, null, (obj, res) => {
            try {
                var bytes = session.send_and_read_async.end (res);
                uint8[] data = bytes.get_data ();

                var loader = new Gdk.PixbufLoader ();
                loader.write (data);
                loader.close ();
                pixbuf = loader.get_pixbuf ();

                if (pixbuf != null) {
                    Idle.add (() => {
                        queue_draw (); // neu rendern
                        return false;
                    });
                }
            } catch (Error e) {
                warning ("Fehler beim Laden von Bild %s: %s", imageUrl, e.message);
            }
        });
    }

    protected override bool draw (Cairo.Context cr) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        if (pixbuf != null && width > 0 && height > 0) {
            // Pixbuf auf Widgetgröße skalieren
            var scaled = pixbuf.scale_simple (width, height, Gdk.InterpType.BILINEAR);

            // Radius (z.B. 12px wie in CSS)
            double radius = 10.0;

            // Abgerundetes Rechteck zeichnen
            cr.new_sub_path ();
            cr.arc (width - radius, radius, radius, -90 * (Math.PI/180.0), 0);
            cr.arc (width - radius, height - radius, radius, 0, 90 * (Math.PI/180.0));
            cr.arc (radius, height - radius, radius, 90 * (Math.PI/180.0), 180 * (Math.PI/180.0));
            cr.arc (radius, radius, radius, 180 * (Math.PI/180.0), 270 * (Math.PI/180.0));
            cr.close_path ();
            cr.clip ();

            // Bild zeichnen
            Gdk.cairo_set_source_pixbuf (cr, scaled, 0, 0);
            cr.paint ();
        } else {

        }

        return true;
    }
}