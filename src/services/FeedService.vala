using GLib;

public class FeedService: IService {
    private static bool fetching = false;
    private static DateTime lastFetched;
    private static FeedRepository feedRepository;

    public FeedService() {
        if(feedRepository == null)
            feedRepository = FeedRepository.getInstance();
    }

    public void start_service() {
        update_service(false);

        Timeout.add_seconds(5, () => {
            update_service(false);
            return true;
        });
    }

    public void stop_service() {
        // Implementation for stopping the feed service
    }

    public void update_service(bool force) {
        string url = "https://www.n-tv.de/rss";
        fetch_data(url, force);
    }

    private void fetch_data(string location, bool force) {
        if(fetching) return;

        DateTime current = new DateTime.now_local();
        if(lastFetched != null) {
            if(lastFetched.add_hours(1).to_unix() > current.to_unix() && !force) {
                return;
            }
        }

        fetching = true;
        var file = File.new_for_uri (location);

        try {
            string etag_out;
            uint8[]? contents;
            file.load_contents (null, out contents, out etag_out);
            
            feedRepository.save((string) contents);
            lastFetched = current;
        } catch (Error e) {
            warning ("Fehler: %s", e.message);
        }
        fetching = false;
    }
}