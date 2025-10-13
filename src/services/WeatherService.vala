using GLib;
using Gee;
using Config;
using Posix;

public class WeatherService: Service {
    private Json.Parser parser;
    private LocationItem? locationItem;
    private static string? cacheDir;
    private bool fetching = false;
    private DateTime lastFetched;
    private uint timer;

    public signal void weatherUpdated(Json.Object weather);

    public WeatherService(LocationItem value) {
        locationItem = value;
        cacheDir = "%s/%s".printf(Environment.get_user_cache_dir(), PACKAGE_NAME);
        if(!FileUtils.test (cacheDir, FileTest.IS_DIR)) {
            DirUtils.create_with_parents(cacheDir, 700);
            if(!FileUtils.test (cacheDir, FileTest.IS_DIR)) {
                warning("Unable to create cache directory %s", cacheDir);
                Process.exit(1);
            }
        }
    }

    public new void start_service() {
        var latitude = ("%f".printf(locationItem.latitude)).replace(",", ".");
        var longitude = ("%f".printf(locationItem.longitude)).replace(",", ".");

        string qs = "latitude=%s&longitude=%s&daily=weather_code,temperature_2m_max,temperature_2m_min&current=temperature_2m,weather_code,rain,showers,snowfall,wind_speed_10m,wind_direction_10m,is_day&timezone=%s"
            .printf (latitude, longitude, Uri.escape_string("Europe/Berlin"));

        var url = "https://api.open-meteo.com/v1/forecast?%s".printf(qs);
        fetch_weather_data.begin("GET", url);

        // Set up a periodic fetch every minute
        timer = Timeout.add_seconds(5, () => {
            fetch_weather_data.begin("GET", url);
            return true; // Continue the timeout
        });
    }

    public new void stop_service() {
        parser = null;
        if(timer != 0) {
            Source.remove(timer);
            timer = 0;
        }
    }

    public new void update_service(bool force) {
        // do nothing
    }

    private async void fetch_weather_data(string method, string location) {
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
                lastFetched = current;

                parser = new Json.Parser();
                parser.load_from_data(response, response.length);
                var json = parser.get_root().get_object();
                weatherUpdated(json);
            } catch(Error e) {
                warning("Error initiating fetch: %s", e.message);
            }
            fetching = false;
        });
    }
}