using Gdk;

public class FeedItemImageWidget : Gtk.DrawingArea {
    private Soup.Session session = new Soup.Session ();
    private Gdk.Pixbuf? pixbuf = null;
    private string image_url;

    public FeedItemImageWidget (string imageUrl) {
        this.image_url = imageUrl;
        get_style_context ().add_class ("card-image");

        load_image ();
    }

    private void load_image () {
        if (!(image_url.has_prefix ("http://") || image_url.has_prefix ("https://")))
            return;

        var msg = new Soup.Message ("GET", image_url);

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
                warning ("Fehler beim Laden von Bild %s: %s", image_url, e.message);
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
        }

        return true;
    }
}