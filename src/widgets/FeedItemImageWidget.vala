using Config;
using Gdk;
using Soup;

public class FeedItemImageWidget : Gtk.DrawingArea {
    private Gdk.Pixbuf? pixbuf = null;
    private Gdk.Pixbuf scaled = null;
    private string imageUrl;
    private static Soup.Session session;
    private string refererUrl;

    private int last_width = 0;
    private int last_height = 0;

    public FeedItemImageWidget () {
        get_style_context ().add_class ("card-image");
        if(session == null) {
            session = new Soup.Session();
            session.add_feature(new Soup.CookieJar());
            session.add_feature(new Soup.HSTSEnforcer());
            session.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0";
            session.set_property("use-http2", true);
        }
    }

    public void loadFeedSource(string? url) {
        if(url == null || url.length == 0) {
            message("no Feed source found");
            return;
        }

        var downloader = new HTMLDownLoader ();
        downloader.contentLoaded.connect(content => {
            imageUrl = extractImageUrl (content, url);
            refererUrl = url;
            loadImage.begin();
        });
        downloader.load_html.begin(url);
    }

    private async void loadImage () {
        if (imageUrl == null || !(imageUrl.has_prefix ("http://") || imageUrl.has_prefix ("https://"))) {
            loadPlaceHolder();
            return;
        }

        try {
            var msg = new Soup.Message ("GET", imageUrl);
            msg.request_headers.append ("Accept", "image/webp,image/apng,image/*,*/*;q=0.8");
            msg.request_headers.append("Referer", refererUrl);
            msg.request_headers.append ("Accept-Language", "de-DE,de;q=0.9,en;q=0.8");

            var bytes = yield session.send_and_read_async(msg, Priority.DEFAULT, null);
            var contentType = msg.get_response_headers().get_content_type(null);

            if(bytes == null || contentType == null || contentType.index_of("image/") == -1) {
                loadPlaceHolder();
                return;
            }

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
        }
        catch(Error e) {
            warning (e.message);
            loadPlaceHolder();
        }
    }

    private void loadPlaceHolder() {
        try {
            string filePath = "%s/icons/broken-image.png".printf (RESOURCES_DIR);
            pixbuf = new Pixbuf.from_file(filePath);

            if (pixbuf != null) {
                Idle.add (() => {
                    queue_draw (); // neu rendern
                    return false;
                });
            }
        } catch(Error e) {
            
        }
    }

    private string? extractImageUrl(string? html, string source) {
        if(html == null) return null;
        try {
            var meta_re = new Regex ("<meta\\b[^>]*>", RegexCompileFlags.CASELESS | RegexCompileFlags.DOTALL);
            var prop_re = new Regex ("property=['\\\"]og:image|twitter:image['\\\"]", RegexCompileFlags.CASELESS);

            var image_re = new Regex("content=['\"](.+?)['\"]", RegexCompileFlags.CASELESS | RegexCompileFlags.DOTALL);

            MatchInfo meta_info;
            if (meta_re.match (html, 0, out meta_info)) {
                do {
                    string tag = meta_info.fetch (0).replace("\r", "").replace("\n", "");

                    MatchInfo property_info;
                    if(prop_re.match (tag, 0, out property_info)) {
                        MatchInfo image_info;
                        if(image_re.match (tag, 0, out image_info)) {
                            var image = image_info.fetch (1);
                            if(image.index_of ("/") == 0) {
                                image = "%s%s".printf (source.substring(0, source.index_of("/", 9)), image);
                            }
                            return image;
                        }
                    }
                } while (meta_info.next ());
            }
        } catch(Error e) {
            warning ("Unable to parse string: %s", e.message);
        }
        return null;
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