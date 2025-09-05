using Gdk;
using Soup;

public class FeedItemImageWidget : Gtk.DrawingArea {
    private Soup.Session session = new Soup.Session ();
    private Gdk.Pixbuf? pixbuf = null;
    private Gdk.Pixbuf scaled = null;
    private string imageUrl;
    private static GLib.Regex regex;

    private int last_width = 0;
    private int last_height = 0;

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

        Idle.add (() => {
            loadFeedSource.begin(feedItem.link);
            return false;
        });
    }

    private async void loadFeedSource(string url) {
        try {
            var msg = new Message ("GET", url);
            Bytes body = yield session.send_and_read_async (msg, Priority.DEFAULT, null);

            string html = (string) body.get_data ();

            MatchInfo info;
            if (regex.match (html, 0, out info)) {
                imageUrl = info.fetch (1);
                loadImage.begin();
            }
        } catch(Error e) {
            // not handled
        }
    }

    private async void loadImage () {
        if (!(imageUrl.has_prefix ("http://") || imageUrl.has_prefix ("https://")))
            return;

        var msg = new Soup.Message ("GET", imageUrl);
        try {
            var bytes = yield session.send_and_read_async(msg, Priority.DEFAULT, null);
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
    }

    protected override bool draw (Cairo.Context cr) {
        int width = get_allocated_width ();
        int height = get_allocated_height ();

        if (pixbuf != null && width > 0 && height > 0) {
            if (scaled == null || width != last_width || height != last_height) {
                scaled = pixbuf.scale_simple (width, height, Gdk.InterpType.BILINEAR);
                last_width = width;
                last_height = height;
            }

            double radius = 10.0;
            cr.new_sub_path ();
            cr.arc (width - radius, radius, radius, -90 * (Math.PI/180.0), 0);
            cr.arc (width - radius, height - radius, radius, 0, 90 * (Math.PI/180.0));
            cr.arc (radius, height - radius, radius, 90 * (Math.PI/180.0), 180 * (Math.PI/180.0));
            cr.arc (radius, radius, radius, 180 * (Math.PI/180.0), 270 * (Math.PI/180.0));
            cr.close_path ();
            cr.clip ();

            Gdk.cairo_set_source_pixbuf (cr, scaled, 0, 0);
            cr.paint ();
            
        } else {

            double radius = 10.0;
            cr.new_sub_path ();
            cr.arc (width - radius, radius, radius, -90 * (Math.PI/180.0), 0);
            cr.arc (width - radius, height - radius, radius, 0, 90 * (Math.PI/180.0));
            cr.arc (radius, height - radius, radius, 90 * (Math.PI/180.0), 180 * (Math.PI/180.0));
            cr.arc (radius, radius, radius, 180 * (Math.PI/180.0), 270 * (Math.PI/180.0));
            cr.close_path ();

            cr.set_source_rgb (0.9, 0.9, 0.9); // hellgrau
            cr.fill ();
        }

        return true;
    }
}