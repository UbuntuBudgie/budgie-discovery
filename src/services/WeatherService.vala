using GLib;
using Gee;
using Config;

public class WeatherService: IService {
    private static Json.Parser jsonParser = new Json.Parser();
    private static WeatherRepository weatherRepository;

    private static bool fetching = false;
    private static DateTime lastFetched;

    public WeatherService() {
        weatherRepository = WeatherRepository.getInstance();
    }

    public static WeatherRepository getWeatherRepository() {
        return weatherRepository;
    }

    public void start_service() {
        string url = "https://api.open-meteo.com/v1/forecast?latitude=47.789&longitude=11.8338&daily=weather_code,temperature_2m_max,temperature_2m_min&current=temperature_2m,weather_code,rain,showers,snowfall,wind_speed_10m,wind_direction_10m,is_day&timezone=Europe%2FBerlin&forecast_hours=6";
        fetch_weather_data.begin("GET", url);

        // Set up a periodic fetch every minute
        Timeout.add_seconds(5, () => {
            fetch_weather_data.begin("GET", url);
            return true; // Continue the timeout
        });
    }

    public void stop_service() {
        jsonParser = null;
    }

    public void update_service() {
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
                weatherRepository.save(response);
                lastFetched = current;
            } catch(Error e) {
                warning("Error initiating fetch: %s", e.message);
            }
            fetching = false;
        });
    }
}