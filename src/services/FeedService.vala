public class FeedService: IService {
    private static bool fetching = false;
    private static DateTime lastFetched;

    public void start_service() {
        string url = "https://news.google.com/rss/search?hl=de&gl=DE&ceid=DE:de&oc=11&q=news";
        fetch_data.begin("GET", url);

        // Set up a periodic fetch every minute
        Timeout.add_seconds(5, () => {
            fetch_data.begin("GET", url);
            return true; // Continue the timeout
        });
    }

    public void stop_service() {
        // Implementation for stopping the feed service
    }

    public void update_service() {
        // Implementation for updating the feed service
    }

    private async void fetch_data(string method, string location) {
        if(fetching) return;

        DateTime current = new DateTime.now_local();
        if(lastFetched != null) {
            if(lastFetched.add_hours(1).to_unix() > current.to_unix() ) {
                return;
            }
        }

        fetching = true;
        var file = File.new_for_uri (location);
        file.load_contents_async.begin (null, (obj, res) => {
            try {
                uint8[] contents;
                string etag_out;

                file.load_contents_async.end (res, out contents, out etag_out);
                string response = (string) contents;
                message(response);
                lastFetched = current;
            } catch(Error e) {
                warning("Error initiating fetch: %s", e.message);
            }
            fetching = false;
        });
    }
}