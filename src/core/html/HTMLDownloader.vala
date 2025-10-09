public class HTMLDownLoader : Object {
    private static Soup.Session session ;
    public signal void contentLoaded(string? content);

    public HTMLDownLoader() {
        if(session == null) {
            session = new Soup.Session();
            session.add_feature(new Soup.CookieJar());
            session.add_feature(new Soup.HSTSEnforcer());
            session.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:131.0) Gecko/20100101 Firefox/131.0";
        }
    }

    public async void load_html(string url) {
        var msg = new Soup.Message ("GET", url);
        msg.request_headers.append ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");

        try {
            var bytes = yield session.send_and_read_async(msg, Priority.DEFAULT, null);
            if (msg.get_status () != 200) {
                //warning ("HTTP error %u for %s", msg.get_status (), url);
                contentLoaded(null);
                return;
            }

            var html = (string) bytes.get_data ();
            html = html.substring (0, (int) bytes.get_size ());
            
            contentLoaded(html);
        } catch(Error e) {

        }
    }
}

