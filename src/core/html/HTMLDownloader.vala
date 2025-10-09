public class HTMLDownLoader : Object {
    private static Soup.Session httpSession ;
    public signal void contentLoaded(string? content);

    public HTMLDownLoader() {
        if(httpSession == null)
            httpSession = SessionManager.get_default();
    }

    public async void load_html(string url) {
        try {
            var msg = new Soup.Message ("GET", url);
            msg.request_headers.append ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
            msg.request_headers.append ("Accept-Language", "de-DE,de;q=0.9,en;q=0.8");
            msg.request_headers.append("User-Agent", httpSession.user_agent);

            var bytes = yield httpSession.send_and_read_async(msg, Priority.DEFAULT, null);
            if (msg.get_status () != 200) {
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

